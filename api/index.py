from flask import Flask

app = Flask(__name__)

@app.route('/')
def home():
    return 'Hello, World! wiii'

@app.route('/about')
def about():
    return 'About'
