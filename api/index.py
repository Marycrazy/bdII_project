from flask import Flask, request, jsonify
import psycopg, os
from .auth import register
from .reserve import reserva
from .room import quarto

app = Flask(__name__)
app.register_blueprint(register)
app.register_blueprint(reserva)
app.register_blueprint(quarto)

if __name__ == "__main__":
    app.run(debug=True)
    
