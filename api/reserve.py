import jwt
import os
import psycopg
from .auth import verify_token
from flask import Flask, request, jsonify, Blueprint

# Conexão à BD
def get_connection():
    return psycopg.connect(os.environ.get("CONNECTION_STRING"))

reserva = Blueprint('reserva', __name__)
@reserva.route('/reserva/register', methods=['POST'])
def register_reserva():
    id_utilizador, error = verify_token()
    if error:
        msg, status = error
        return jsonify(message=msg), status
    data = request.get_json()
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
    
ver_reserva = Blueprint('ver_reserva', __name__)
@ver_reserva.route('/reserva/<id>', methods=['GET'])
def get_reserva(id):
    try:
        conn = get_connection()
        cur = conn.cursor()
        cur.execute("SELECT * FROM RESERVAS WHERE ID_RESERVAS = (%s)", (id,))
        result = cur.fetchone()

        conn.commit()
        cur.close()
        conn.close()

        if result:
            return jsonify({"reserva": result}), 200
        else:
            return jsonify({"erro": "Reserva não encontrada."}), 404
    except psycopg.Error as e:
        if conn:
            conn.rollback()
        return jsonify({"erro": str(e)}), 400
    
cancelar_reserva = Blueprint('cancelar_reserva', __name__)
@cancelar_reserva.route('/reserva/<id>/cancelar', methods=['PUT'])
def cancel_reserva(id):
    try:
        conn = get_connection()
        cur = conn.cursor()
        cur.execute("UPDATE RESERVAS SET ESTADO_RESERVA = 'cancelada' WHERE ID_RESERVAS = (%s)", (id,))

        conn.commit()
        cur.close()
        conn.close()

        return jsonify({"mensagem": "Reserva cancelada"}), 200
    except psycopg.Error as e:
        if conn:
            conn.rollback()
        return jsonify({"erro": str(e)}), 400
