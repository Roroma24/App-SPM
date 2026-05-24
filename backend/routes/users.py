from flask import Blueprint, request
from database.db import db

users = Blueprint("users", __name__)

# =========================
# REGISTER
# =========================
@users.route("/register", methods=["POST"])
def register():

    data = request.json

    alias = data.get("alias")
    nombre_completo = data.get("nombre_completo")
    matricula = data.get("matricula")
    correo = data.get("correo")
    password = data.get("password")
    carrera = data.get("carrera")
    campus = data.get("campus")
    edad = data.get("edad")
    fecha_nacimiento = data.get("fecha_nacimiento")

    cursor = db.cursor()

    sql = """
    INSERT INTO users (
        alias,
        nombre_completo,
        matricula,
        correo,
        password,
        carrera,
        campus,
        edad,
        fecha_nacimiento
    )
    VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)
    """

    values = (
        alias,
        nombre_completo,
        matricula,
        correo,
        password,
        carrera,
        campus,
        edad,
        fecha_nacimiento
    )

    cursor.execute(sql, values)
    db.commit()

    return {
        "message": "Usuario registrado correctamente"
    }, 201

# =========================
# LOGIN
# =========================
@users.route("/login", methods=["POST"])
def login():

    data = request.json

    correo = data.get("correo")
    password = data.get("password")

    cursor = db.cursor(dictionary=True)

    sql = """
    SELECT * FROM users
    WHERE correo = %s AND password = %s
    """

    cursor.execute(sql, (correo, password))

    user = cursor.fetchone()

    if user:

        return {
            "message": "Login correcto",
            "user": user
        }, 200

    return {
        "message": "Correo o contraseña incorrectos"
    }, 401
