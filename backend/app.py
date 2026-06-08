from flask import Flask
from flask_cors import CORS

from config import Config
from routes.users import users
from routes.announcements import announcement_bp

app = Flask(__name__)
CORS(app)

app.register_blueprint(users)
app.register_blueprint(announcement_bp)

@app.route("/")
def home():
    return {
        "message": "API Flask funcionando correctamente"
    }

if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=int(Config.PORT),
        debug=True
    )