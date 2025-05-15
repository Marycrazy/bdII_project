import psycopg, imghdr, os
from flask import Blueprint, request, Response, jsonify
from psycopg import Binary

image_bp = Blueprint('image', __name__)

def get_connection():
    return psycopg.connect(os.environ.get("CONNECTION_STRING"))

ALLOWED_MIMETYPES = {'image/jpeg', 'image/png'}

def is_allowed_mimetype(file_storage):
    return file_storage.mimetype in ALLOWED_MIMETYPES

@image_bp.route('/upload-imagem', methods=['POST'])
def upload_imagem():
    file = request.files.get('image')
    if not file:
        return jsonify(error="No image provided"), 400

    room_id = request.form.get('room_id', type=int)
    if not room_id:
        return jsonify(error="Missing room_id"), 400

    if not is_allowed_mimetype(file):
        return jsonify(error="Unsupported file type; must be JPEG or PNG"), 400

    raw = file.read()

    try:
        conn = get_connection()
        cur = conn.cursor()
        cur.execute(
            "SELECT insert_room_image(%s, %s)",
            (room_id, Binary(raw))
        )
        image_id = cur.fetchone()[0]
        conn.commit()
        return jsonify(message="Image uploaded successfully", image_id=image_id), 201

    except psycopg.Error as e:
        conn.rollback()
        msg = str(e).split('\n')[0]
        if "Room does not exist" in msg:
            return jsonify(error="Room not found"), 404
        return jsonify(error=f"Operation failed: {msg}"), 500

    finally:
        cur.close()
        conn.close()


@image_bp.route('/quartos/<int:room_id>/imagem', methods=['GET'])
def list_room_images(room_id):
    try:
        conn = get_connection()
        cur = conn.cursor()
        cur.execute("SELECT get_room_image_ids(%s)", (room_id,))
        image_ids = cur.fetchone()[0]
        return jsonify(room_id=room_id, image_ids=image_ids), 200

    except psycopg.Error as e:
        msg = str(e).split('\n')[0]
        if "No images found for this room" in msg:
            return jsonify(error="No images found for this room"), 404
        return jsonify(error=f"Operation failed: {msg}"), 500

    finally:
        cur.close()
        conn.close()


@image_bp.route('/quartos/<int:room_id>/imagem/<int:image_id>', methods=['GET'])
def get_room_image(room_id, image_id):
    try:
        conn = get_connection()
        cur = conn.cursor()
        cur.execute("SELECT get_image_by_room_and_id(%s, %s)", (room_id, image_id))
        image_data = cur.fetchone()[0]

        if not image_data:
            return jsonify(error="Image not found"), 404

        kind = imghdr.what(None, image_data)
        if kind == 'png':
            mimetype = 'image/png'
        elif kind in ('jpeg', 'jpg'):
            mimetype = 'image/jpeg'
        else:
            mimetype = 'application/octet-stream'

        return Response(image_data, mimetype=mimetype), 200

    except psycopg.Error as e:
        msg = str(e).split('\n')[0]
        if "Image not found" in msg:
            return jsonify(error="Image not found"), 404
        return jsonify(error=f"Operation failed: {msg}"), 500

    finally:
        cur.close()
        conn.close()