from werkzeug.exceptions import RequestEntityTooLarge
from flask import Flask, jsonify
from .auth import register, login
from .reserve import reserva
from .room import quarto
from .image import image_bp

app = Flask(__name__)
app.config['MAX_CONTENT_LENGTH'] = 10 * 1024 * 1024
app.register_blueprint(register)
app.register_blueprint(login)
app.register_blueprint(reserva)
app.register_blueprint(quarto)
app.register_blueprint(image_bp)

@app.errorhandler(RequestEntityTooLarge)
def handle_request_entity_too_large(e):
    return jsonify(error="File too large (max 10 MB)"), 413

if __name__ == "__main__":
    app.run(debug=True)