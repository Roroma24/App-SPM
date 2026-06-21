from flask import Flask
from flask_cors import CORS

from config import Config
from routes.users import users
from routes.announcements import announcement_bp
from routes.publications import publications_bp
from database.db import db

app = Flask(__name__)
CORS(app)

app.register_blueprint(users)
app.register_blueprint(announcement_bp)
app.register_blueprint(publications_bp)

@app.route("/")
def home():
    return {
        "message": "API Flask funcionando correctamente"
    }

@app.route("/health")
def health():
    """Verificar el estado de la aplicación y la conexión a BD"""
    try:
        from database.db import client
        if client:
            client.admin.command('ping')
            return {
                "status": "healthy",
                "database": "connected"
            }, 200
        else:
            return {
                "status": "degraded",
                "database": "not connected",
                "message": "Check MongoDB credentials"
            }, 503
    except Exception as e:
        return {
            "status": "unhealthy",
            "database": "disconnected",
            "error": str(e)
        }, 500

if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=int(Config.PORT),
        debug=True
    )