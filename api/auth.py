import jwt
import os
import psycopg
from datetime import datetime, timedelta
from flask import Flask, request, jsonify, Blueprint

# Conexão à BD
def get_connection():
    return psycopg.connect(os.environ.get("CONNECTION_STRING"))

register = Blueprint('register', __name__)
@register.route('/auth/register', methods=['POST'])
def registers():
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

login = Blueprint('login', __name__)
@login.route('/auth/login', methods=['POST'])
def autebticacao():
    data = request.get_json()
    email = data.get("email")
    password = data.get("password")

    # Validação básica
    if not all([email, password]):
        return jsonify({"erro": "Todos os campos são obrigatórios."}), 400

    try:
        conn = get_connection()
        cur = conn.cursor()

        # Chamar a função PL/pgSQL
        cur.execute("SELECT autenticar_utilizador(%s, %s)", (email, password))
        result = cur.fetchone()
        print("resultado", result)
        if result[0] is None:
            return jsonify({"erro": "Credenciais inválidas."}), 401

        user_id = result[0]
        print("user_id", user_id)
        # Gerar token JWT
        token = jwt.encode(
            {"user": user_id, "exp": datetime.now() + timedelta(minutes=30)},
            os.getenv("SECRET_KEY", "sua-chave-super-secreta"),
            algorithm="HS256"
        )
        cur.close()
        conn.close()
        return jsonify(token=token)

    except psycopg.Error as e:
        conn.rollback()
        return jsonify({"erro": str(e)}), 400