from flask import Flask, request, jsonify
import psycopg, os
from .auth import register, login
from .reserve import reserva
from .room import quarto

app = Flask(__name__)
app.register_blueprint(register)
app.register_blueprint(login)
app.register_blueprint(reserva)
app.register_blueprint(quarto)

if __name__ == "__main__":
    app.run(debug=True)
    
