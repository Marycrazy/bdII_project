import psycopg, os, jwt
from .connection import get_connection
from datetime import datetime, timedelta
from flask import request, jsonify, Blueprint

secret_key =  os.getenv("SECRET_KEY", "chave-super-secreta")

register = Blueprint('register', __name__)
@register.route('/auth/register', methods=['POST'])
def registar():
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
def autenticacao():
    data = request.get_json()
    email = data.get("email")
    password = data.get("password")

    # Validação básica
    if not all([email, password]):
        return jsonify({"erro": "Todos os campos são obrigatórios."}), 400

    try:
        conn = get_connection()
        cur = conn.cursor()
        print("email", email, "password", password)
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
            secret_key,
            algorithm="HS256"
        )
        cur.close()
        conn.close()
        return jsonify(token=token)

    except psycopg.Error as e:
        conn.rollback()
        return jsonify({"erro": str(e)}), 400

def verify_token():
    auth_header = request.headers.get('Authorization', None)
    if not auth_header:
        return None, ('Token é necessário!', 403)

    parts = auth_header.split()
    if parts[0].lower() != 'bearer' or len(parts) != 2:
        return None, ('Cabeçalho de autorização malformado!', 401)

    token = parts[1]
    try:
        payload = jwt.decode(token, secret_key, algorithms=['HS256'])
        return payload['user'], None
    except jwt.ExpiredSignatureError:
        return None, ('Token expirado! Faça login novamente.', 401)
    except jwt.InvalidTokenError:
        return None, ('Token inválido!', 403)

def get_user_type(id_utilizador):
    try:
        conn = get_connection()
        cur = conn.cursor()
        cur.execute("SELECT TIPO_UTILIZADOR FROM UTILIZADORES WHERE ID_UTILIZADORES = %s", (id_utilizador,))
        user_type = cur.fetchone()[0]
        cur.close()
        conn.close()
        return user_type, None
    except psycopg.Error as e:
        conn.rollback()
        return None, ("Utilizador não encontrado")