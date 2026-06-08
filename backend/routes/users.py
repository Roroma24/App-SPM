from flask import Blueprint, request
from database.db import db
import bcrypt

users = Blueprint("users", __name__)

users_collection = db["users"]


@users.route("/register", methods=["POST"])
def register():

    data = request.json

    correo = data.get("correo")

    existing_user = users_collection.find_one({
        "correo": correo
    })

    if existing_user:
        return {
            "success": False,
            "message": "El correo ya está registrado"
        }, 400

    password = data.get("password")

    password_hash = bcrypt.hashpw(
        password.encode("utf-8"),
        bcrypt.gensalt()
    ).decode("utf-8")

    user = {
        "alias": data.get("alias"),
        "nombre_completo": data.get("nombre_completo"),
        "matricula": data.get("matricula"),
        "correo": correo,
        "password": password_hash,
        "carrera": data.get("carrera"),
        "campus": data.get("campus"),
        "edad": data.get("edad"),
        "fecha_nacimiento": data.get("fecha_nacimiento"),
        "foto_perfil": data.get("foto_perfil", "")
    }

    result = users_collection.insert_one(user)

    return {
        "success": True,
        "message": "Usuario registrado correctamente",
        "id": str(result.inserted_id)
    }, 201

@users.route("/login", methods=["POST"])
def login():

    data = request.json

    correo = data.get("correo")
    password = data.get("password")

    user = users_collection.find_one({
        "correo": correo
    })

    if not user:
        return {
            "success": False,
            "message": "Correo o contraseña incorrectos"
        }, 401

    password_ok = bcrypt.checkpw(
        password.encode("utf-8"),
        user["password"].encode("utf-8")
    )

    if not password_ok:
        return {
            "success": False,
            "message": "Correo o contraseña incorrectos"
        }, 401

    user["_id"] = str(user["_id"])

    user.pop("password", None)

    return {
        "success": True,
        "message": "Login correcto",
        "user": user
    }, 200