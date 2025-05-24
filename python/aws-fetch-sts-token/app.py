from flask import Flask, request, make_response, jsonify
from fetch import get_sts_token
from cryptography.fernet import Fernet

app = Flask(__name__)

key = b"<GENERATE_ONE_KEY_USING_ABOVE>"
fernet = Fernet(key)


@app.route("/")
def status():
    return "Healthy"


@app.route("/sts-token", methods=["POST"])
def sts_token():
    if request.method == "POST":
        if request.headers.get("Content-Type") == "application/json":
            data = request.json
            username = data["username"]
            password = data["password"]
            if "IsEncrypted" in data and data["IsEncrypted"] == "true":
                username = fernet.decrypt(username.encode()).decode()
                password = fernet.decrypt(password.encode()).decode()
            if username == "test" and password == "test":
                try:
                    result = get_sts_token(data['role_to_assume'])
                    print(result)
                    return jsonify(result)
                except Exception as e:
                    res = make_response(f"<h2>{e}</h2>")
                    res.status_code = 404
                    return res
            else:
                res = make_response("<h2>Invalid username or password.</h2>")
                res.status_code = 401
                return res
        else:
            res = make_response("<h2>Bad/Invalid input details provided.</h2>")
            res.status_code = 422
            return res


if __name__ == "__main__":
    app.run(debug=True, port=5000)
