import psycopg
from .connection import get_connection
from flask import jsonify, Blueprint

quarto = Blueprint('quarto', __name__)
@quarto.route('/room/<room_num>/<date>', methods=['GET'])
def get_room_availability(room_num, date):
    try:
        conn = get_connection()
        cur = conn.cursor()

        cur.execute("SELECT EXISTS(SELECT 1 FROM quartos WHERE numero = %s)", (room_num,))
        quarto_exists = cur.fetchone()[0]

        if not quarto_exists:
            return jsonify({"erro": "Quarto não encontrado."}), 404

        cur.execute("SELECT is_available(%s, %s)", (room_num, date))
        disponivel = cur.fetchone()[0]

        conn.commit()
        cur.close()
        conn.close()

        if disponivel:
            return jsonify({"disponibilidade": "Quarto disponível."}), 200
        else:
            return jsonify({"disponibilidade": "Quarto indisponível."}), 200

    except psycopg.Error:
        return jsonify({"erro": "Não foi possível verificar a disponibilidade do quarto."}), 400