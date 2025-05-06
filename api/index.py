from flask import Flask, request, jsonify
import psycopg, os

app = Flask(__name__)

# Conexão à BD
def get_connection():
    return psycopg.connect(os.environ.get("CONNECTION_STRING"))


@app.route('/auth/register', methods=['POST'])
def register():
    data = request.get_json()
    nome = data.get("nome")
    email = data.get("email")
    password = data.get("password")
    tipo = data.get("tipo_utilizador")

    # Validação básica
    if not all([nome, email, password, tipo]):
        return jsonify({"erro": "Todos os campos são obrigatórios."}), 400


    try:
        conn = get_connection()
        cur = conn.cursor()

        # Chamar a função PL/pgSQL
        cur.execute("SELECT inserir_utilizador(%s, %s, %s, %s)", (nome, email, password, tipo))

        conn.commit()
        cur.close()
        conn.close()

        return jsonify({"mensagem": "Utilizador registado com sucesso."}), 201

    except psycopg.Error as e:
        conn.rollback()
        return jsonify({"erro": str(e)}), 400

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
