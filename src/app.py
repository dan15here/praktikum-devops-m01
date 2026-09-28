from flask import Flask, jsonify
import os, datetime

app = Flask(__name__)
BUILD = os.getenv("BUILD_ID", "dev-local")

@app.route("/")
def index():
    return jsonify(
        service="sentra-digital-batam",
        status="running",
        build=BUILD,
        time=datetime.datetime.now().isoformat(timespec="seconds"),
    )

@app.route("/health")
def health():
    return jsonify(status="ok"), 200

if __name__ == "__main__":
    import os
    port = int(os.environ.get("PORT",5000))
    app.run(host="127.0.0.1", port=port)
