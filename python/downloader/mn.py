from flask import Flask, request, make_response, jsonify

app = Flask(__name__)
@app.route("/")
def status():
    return "Healthy"

if __name__ == "__main__":
    app.run(port=8000)