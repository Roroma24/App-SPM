from flask import Blueprint, request
from database.db import db
import bcrypt
from bson.objectid import ObjectId
import logging

logger = logging.getLogger(__name__)

users = Blueprint("users", __name__)

users_collection = db["users"]
publications_collection = db["publications"]


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


@users.route("/logout", methods=["POST"])
def logout():
    """Endpoint para cerrar sesión (actualmente solo retorna confirmación)"""
    return {
        "success": True,
        "message": "Sesión cerrada correctamente"
    }, 200


@users.route("/profile/<user_id>", methods=["GET"])
def get_profile(user_id):
    """Obtener perfil de usuario por ID"""
    try:
        user = users_collection.find_one({"_id": ObjectId(user_id)})
        
        if not user:
            return {
                "success": False,
                "message": "Usuario no encontrado"
            }, 404
        
        user["_id"] = str(user["_id"])
        user.pop("password", None)
        
        return {
            "success": True,
            "user": user
        }, 200
    
    except Exception as e:
        return {
            "success": False,
            "message": str(e)
        }, 500


@users.route("/profile/<user_id>", methods=["PUT"])
def update_profile(user_id):
    """Actualizar perfil de usuario"""
    try:
        data = request.json
        
        if not data:
            return {
                "success": False,
                "message": "No se enviaron datos"
            }, 400
        
        user = users_collection.find_one({"_id": ObjectId(user_id)})
        
        if not user:
            return {
                "success": False,
                "message": "Usuario no encontrado"
            }, 404
        
        # Obtener el alias anterior para comparar
        old_alias = user.get("alias")
        new_alias = data.get("alias")
        
        # Actualizar solo los campos permitidos
        allowed_fields = ["alias", "campus"]
        update_data = {}
        
        for field in allowed_fields:
            if field in data:
                update_data[field] = data[field]
        
        if update_data:
            result = users_collection.update_one(
                {"_id": ObjectId(user_id)},
                {"$set": update_data}
            )
            
            if result.modified_count == 0:
                return {
                    "success": False,
                    "message": "No se realizaron cambios"
                }, 400
            
            # Si el alias cambió, actualizar todas las publicaciones del usuario
            if new_alias and new_alias != old_alias:
                try:
                    # Convertir user_id a ObjectId para buscar en publicaciones
                    user_object_id = ObjectId(user_id)
                    result = publications_collection.update_many(
                        {"user_id": user_object_id},
                        {"$set": {"user_alias": new_alias}}
                    )
                    logger.info(f"Publicaciones actualizadas: {result.modified_count} registros")
                except Exception as e:
                    logger.error(f"Error al actualizar publicaciones: {e}")
        
        # Obtener usuario actualizado
        updated_user = users_collection.find_one({"_id": ObjectId(user_id)})
        updated_user["_id"] = str(updated_user["_id"])
        updated_user.pop("password", None)
        
        return {
            "success": True,
            "message": "Perfil actualizado correctamente",
            "user": updated_user
        }, 200
    
    except Exception as e:
        return {
            "success": False,
            "message": str(e)
        }, 500