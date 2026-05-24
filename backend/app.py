from flask import Flask
from flask_cors import CORS

from config import Config
from routes.users import users

app = Flask(__name__)
CORS(app)

app.register_blueprint(users)

# =========================
# RUTA TEST
# =========================
@app.route("/")
def home():
    return {
        "message": "API Flask funcionando correctamente"
    }

# =========================
# INICIAR SERVIDOR
# =========================
if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=int(Config.PORT),
        debug=True
    )
