from flask import Flask, request, jsonify
import psycopg, os
from .auth import register

app = Flask(__name__)
app.register_blueprint(register)

# Conexão à BD
def get_connection():
    return psycopg.connect(os.environ.get("CONNECTION_STRING"))

@app.route('/reserva/register', methods=['POST'])
def register_reserva():
    data = request.get_json()
    id_utilizador = data.get("id_utilizador")
    id_quarto = data.get("id_quarto")
    data_inicio = data.get("data_inicio")
    data_fim = data.get("data_fim")
    pagamento = data.get("pagamento")

    # Validação básica
    if not all([id_utilizador, id_quarto, data_inicio, data_fim, pagamento]):
        return jsonify({"erro": "Todos os campos são obrigatórios."}), 400

    try:
        conn = get_connection()
        cur = conn.cursor()

        cur.execute("CALL inserir_reserva(%s, %s, %s, %s, %s)",(id_utilizador, id_quarto, data_inicio, data_fim, None))
        reserva_id = cur.fetchone()[0]
        cur.execute("CALL inserir_pagamento(%s, %s)", (reserva_id, pagamento))

        conn.commit()
        cur.close()
        conn.close()

        return jsonify({"mensagem": "Reserva registada com sucesso."}), 201

    except psycopg.Error as e:
        conn.rollback()
        return jsonify({"erro": str(e)}), 400

@app.route('/room/<room_num>/<date>', methods=['GET'])
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

if __name__ == "__main__":
    app.run(debug=True)
    
