import psycopg
from .connection import get_connection
from .auth import verify_token, get_user_type
from flask import request, jsonify, Blueprint

reserva = Blueprint('reserva', __name__)
@reserva.route('/reservas', methods=['POST'])
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

        cur.execute("SELECT NUMERO FROM QUARTOS WHERE ID_QUARTOS = %s", (id_quarto,))
        quarto_result = cur.fetchone()
        if not quarto_result:
            return jsonify({"erro": "numero do quarto não encontrado."}), 404
        num_quarto = quarto_result[0]

        # Verifica a disponibilidade do quarto
        cur.execute("SELECT is_available(%s, %s)", (num_quarto, data_inicio))
        result = cur.fetchone()[0]
        # Se o quarto estiver disponível, insere a reserva
        if result is True:
            cur.execute("CALL inserir_reserva(%s, %s, %s, %s, %s)",(id_utilizador, id_quarto, data_inicio, data_fim, None))
            reserva_id = cur.fetchone()[0]
            cur.execute("CALL inserir_pagamento(%s, %s)", (reserva_id, pagamento))
        elif result is False:
            return jsonify({"disponibilidade": "Quarto indisponível."}), 400

        conn.commit()
        cur.close()
        conn.close()

        return jsonify({"mensagem": "Reserva registada com sucesso."}), 201

    except psycopg.Error as e:
        conn.rollback()
        return jsonify({"erro": str(e)}), 400

ver_reserva = Blueprint('ver_reserva', __name__)
@ver_reserva.route('/reservas/<id>', methods=['GET'])
def get_reserva(id):
    id_utilizador, error = verify_token()
    if error:
        msg, status = error
        return jsonify(message=msg), status

    try:
        conn = get_connection()
        cur = conn.cursor()
        tipo_utilizador, error = get_user_type(id_utilizador)
        if error:
            return jsonify(message=error), 404

        # Verifica se o utilizador é um administrador ou rececionista
        if tipo_utilizador in ['administrador', 'recepcionista']:
            sql = "SELECT * FROM RESERVAS WHERE ID_RESERVAS = %s"
            params = (id,)  # id aqui é o ID da reserva da rota
        else:
            sql = "SELECT * FROM RESERVAS WHERE ID_RESERVAS = %s AND ID_UTILIZADORES = %s"
            params = (id, id_utilizador)  # id da reserva e id do utilizador logado

        cur.execute(sql, params)
        result = cur.fetchone()
        # Verifica se a reserva existe
        if not result:
            return jsonify({"erro": "Reserva não encontrada."}), 404 #por algum motivo ele não entra aqui
        # Se a reserva existir, retorna os detalhes
        conn.commit()
        cur.close()
        conn.close()

        return jsonify({"reserva": result}), 200
    except psycopg.Error as e:
        if conn:
            conn.rollback()
        return jsonify({"erro": str(e)}), 400

cancelar_reserva = Blueprint('cancelar_reserva', __name__)
@cancelar_reserva.route('/reservas/<id>/cancelar', methods=['PUT'])
def cancel_reserva(id):
    id_utilizador, error = verify_token()
    if error:
        msg, status = error
        return jsonify(message=msg), status

    try:
        conn = get_connection()
        cur = conn.cursor()
        tipo_utilizador, error = get_user_type(id_utilizador)
        if error:
            return jsonify(message=error), 404

        # Verifica se o utilizador é um administrador ou rececionista
        if tipo_utilizador in ['administrador', 'recepcionista']:
            sql = "UPDATE RESERVAS SET ESTADO_RESERVA = 'cancelada' WHERE ID_RESERVAS = %s"
            params = (id,)  # id aqui é o ID da reserva da rota
        else:
            sql = "UPDATE RESERVAS SET ESTADO_RESERVA = 'cancelada' WHERE ID_RESERVAS = %s AND ID_UTILIZADORES = %s"
            params = (id, id_utilizador)  # id da reserva e id do utilizador logado
        cur.execute(sql, params)

        # Verifica se a reserva existe
        if cur.rowcount == 0:
            return jsonify({"erro": "Reserva não encontrada ou não autorizada."}), 404

        conn.commit()
        cur.close()
        conn.close()

        return jsonify({"mensagem": "Reserva cancelada"}), 200
    except psycopg.Error as e:
        if conn:
            conn.rollback()
        return jsonify({"erro": str(e)}), 400