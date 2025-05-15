import os
import psycopg
from flask import jsonify, Blueprint

# Conexão à BD
def get_connection():
    return psycopg.connect(os.environ.get("CONNECTION_STRING"))

quarto = Blueprint('quarto', __name__)
@quarto.route('/room/<room_num>/<date>', methods=['GET'])
def get_room_availability(room_num, date):
    try:
        conn = get_connection()
        cur = conn.cursor()

        cur.execute("SELECT is_available(%s, %s)", (room_num, date))
        result = cur.fetchone()[0]

        conn.commit()
        cur.close()
        conn.close()

        if result is True:
            return jsonify({"disponibilidade": "Quarto disponível."}), 200
        elif result is False:
            return jsonify({"disponibilidade": "Quarto indisponível."}), 200

    except psycopg.Error as e:
        return jsonify({"erro": str(e)}), 400