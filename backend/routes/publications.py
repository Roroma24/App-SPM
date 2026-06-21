from flask import Blueprint, request, jsonify
from datetime import datetime
from bson.objectid import ObjectId
from database.db import db
from models.publication import Publication
import logging

logger = logging.getLogger(__name__)

publications_bp = Blueprint("publications", __name__, url_prefix="/publications")

# ========================
# CREATE - Crear publicación
# ========================
@publications_bp.route("", methods=["POST"])
def create_publication():
    """Crear nueva publicación en el muro"""
    try:
        data = request.get_json()
        
        # Validar datos requeridos
        required_fields = ["user_id", "user_alias", "user_name", "content"]
        if not all(field in data for field in required_fields):
            return {"error": "Faltan campos requeridos"}, 400
        
        # Crear publicación
        publication = Publication(
            user_id=data["user_id"],
            user_alias=data["user_alias"],
            user_name=data["user_name"],
            content=data["content"],
        )
        
        # Guardar en MongoDB
        result = db.publications.insert_one(publication.to_dict())
        
        logger.info(f"Publicación creada: {result.inserted_id}")
        
        return {
            "message": "Publicación creada exitosamente",
            "publication_id": str(result.inserted_id)
        }, 201
    
    except Exception as e:
        logger.error(f"Error al crear publicación: {e}")
        return {"error": str(e)}, 500

# ========================
# READ - Obtener publicaciones
# ========================
@publications_bp.route("", methods=["GET"])
def get_publications():
    """Obtener todas las publicaciones ordenadas por fecha descendente"""
    try:
        # Parámetros de filtro
        search = request.args.get("search", "")
        filter_by = request.args.get("filter_by", "date")  # date, user, age
        
        # Construir query
        query = {}
        
        if search:
            # Buscar en contenido o usuario
            query["$or"] = [
                {"content": {"$regex": search, "$options": "i"}},
                {"user_alias": {"$regex": search, "$options": "i"}},
                {"user_name": {"$regex": search, "$options": "i"}},
            ]
        
        # Obtener publicaciones
        publications = list(db.publications.find(query))
        
        # Ordenar según filtro
        if filter_by == "user":
            publications.sort(key=lambda x: x["user_alias"])
        elif filter_by == "age":
            publications.sort(key=lambda x: x["created_at"])  # Más antiguas primero
        else:  # date (más nuevas primero)
            publications.sort(key=lambda x: x["created_at"], reverse=True)
        
        # Convertir ObjectId a string
        for pub in publications:
            pub["_id"] = str(pub["_id"])
            pub["user_id"] = str(pub["user_id"])
            pub["created_at"] = pub["created_at"].isoformat() if pub["created_at"] else None
        
        return {"publications": publications}, 200
    
    except Exception as e:
        logger.error(f"Error al obtener publicaciones: {e}")
        return {"error": str(e)}, 500

# ========================
# READ - Obtener publicación por ID
# ========================
@publications_bp.route("/<publication_id>", methods=["GET"])
def get_publication(publication_id):
    """Obtener una publicación específica"""
    try:
        publication = db.publications.find_one({"_id": ObjectId(publication_id)})
        
        if not publication:
            return {"error": "Publicación no encontrada"}, 404
        
        publication["_id"] = str(publication["_id"])
        publication["user_id"] = str(publication["user_id"])
        publication["created_at"] = publication["created_at"].isoformat() if publication["created_at"] else None
        
        return publication, 200
    
    except Exception as e:
        logger.error(f"Error al obtener publicación: {e}")
        return {"error": str(e)}, 500

# ========================
# UPDATE - Agregar/quitar like
# ========================
@publications_bp.route("/<publication_id>/like", methods=["POST"])
def toggle_like(publication_id):
    """Agregar o quitar like a una publicación"""
    try:
        data = request.get_json()
        user_id = data.get("user_id")
        
        if not user_id:
            return {"error": "user_id requerido"}, 400
        
        publication = db.publications.find_one({"_id": ObjectId(publication_id)})
        
        if not publication:
            return {"error": "Publicación no encontrada"}, 404
        
        # Obtener listas actuales
        liked_by = publication.get("liked_by", [])
        disliked_by = publication.get("disliked_by", [])
        
        # Si ya le dio like, remover
        if user_id in liked_by:
            liked_by.remove(user_id)
            new_likes = len(liked_by)
        else:
            # Remover dislike si existe
            if user_id in disliked_by:
                disliked_by.remove(user_id)
            
            # Agregar like
            liked_by.append(user_id)
            new_likes = len(liked_by)
        
        # Actualizar en BD
        db.publications.update_one(
            {"_id": ObjectId(publication_id)},
            {
                "$set": {
                    "liked_by": liked_by,
                    "disliked_by": disliked_by,
                    "likes": new_likes,
                    "dislikes": len(disliked_by),
                }
            }
        )
        
        return {
            "message": "Like actualizado",
            "likes": new_likes,
            "dislikes": len(disliked_by)
        }, 200
    
    except Exception as e:
        logger.error(f"Error al actualizar like: {e}")
        return {"error": str(e)}, 500

# ========================
# UPDATE - Agregar/quitar dislike
# ========================
@publications_bp.route("/<publication_id>/dislike", methods=["POST"])
def toggle_dislike(publication_id):
    """Agregar o quitar dislike a una publicación"""
    try:
        data = request.get_json()
        user_id = data.get("user_id")
        
        if not user_id:
            return {"error": "user_id requerido"}, 400
        
        publication = db.publications.find_one({"_id": ObjectId(publication_id)})
        
        if not publication:
            return {"error": "Publicación no encontrada"}, 404
        
        # Obtener listas actuales
        liked_by = publication.get("liked_by", [])
        disliked_by = publication.get("disliked_by", [])
        
        # Si ya le dio dislike, remover
        if user_id in disliked_by:
            disliked_by.remove(user_id)
            new_dislikes = len(disliked_by)
        else:
            # Remover like si existe
            if user_id in liked_by:
                liked_by.remove(user_id)
            
            # Agregar dislike
            disliked_by.append(user_id)
            new_dislikes = len(disliked_by)
        
        # Actualizar en BD
        db.publications.update_one(
            {"_id": ObjectId(publication_id)},
            {
                "$set": {
                    "liked_by": liked_by,
                    "disliked_by": disliked_by,
                    "likes": len(liked_by),
                    "dislikes": new_dislikes,
                }
            }
        )
        
        return {
            "message": "Dislike actualizado",
            "likes": len(liked_by),
            "dislikes": new_dislikes
        }, 200
    
    except Exception as e:
        logger.error(f"Error al actualizar dislike: {e}")
        return {"error": str(e)}, 500

# ========================
# UPDATE - Editar publicación
# ========================
@publications_bp.route("/<publication_id>", methods=["PUT"])
def update_publication(publication_id):
    """Editar el contenido de una publicación"""
    try:
        data = request.get_json()
        
        if not data.get("content"):
            return {"error": "El contenido no puede estar vacío"}, 400
        
        publication = db.publications.find_one({"_id": ObjectId(publication_id)})
        
        if not publication:
            return {"error": "Publicación no encontrada"}, 404
        
        # Verificar que el usuario sea el creador
        if str(publication["user_id"]) != str(data.get("user_id")):
            return {"error": "No tienes permiso para editar esta publicación"}, 403
        
        # Actualizar contenido
        result = db.publications.update_one(
            {"_id": ObjectId(publication_id)},
            {"$set": {"content": data["content"]}}
        )
        
        if result.modified_count == 0:
            return {"error": "No se pudo actualizar la publicación"}, 400
        
        return {
            "message": "Publicación actualizada exitosamente"
        }, 200
    
    except Exception as e:
        logger.error(f"Error al actualizar publicación: {e}")
        return {"error": str(e)}, 500

# ========================
# DELETE - Eliminar publicación
# ========================
@publications_bp.route("/<publication_id>", methods=["DELETE"])
def delete_publication(publication_id):
    """Eliminar una publicación"""
    try:
        result = db.publications.delete_one({"_id": ObjectId(publication_id)})
        
        if result.deleted_count == 0:
            return {"error": "Publicación no encontrada"}, 404
        
        return {"message": "Publicación eliminada exitosamente"}, 200
    
    except Exception as e:
        logger.error(f"Error al eliminar publicación: {e}")
        return {"error": str(e)}, 500
