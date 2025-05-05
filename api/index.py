from flask import Flask, request, jsonify
import psycopg, os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

# Conexão à BD
def get_connection():
    return psycopg.connect(os.getenv("CONNECTION_STRING"))


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

    return psycopg.connect('CONNECTION_STRING')


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