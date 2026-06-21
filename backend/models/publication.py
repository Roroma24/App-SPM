from datetime import datetime
from bson.objectid import ObjectId

class Publication:
    """Modelo para publicaciones en el muro"""
    
    def __init__(
        self,
        user_id: str,
        user_alias: str,
        user_name: str,
        content: str,
        created_at: datetime = None,
        likes: int = 0,
        dislikes: int = 0,
        liked_by: list = None,
        disliked_by: list = None,
        _id: ObjectId = None,
    ):
        self._id = _id or ObjectId()
        self.user_id = ObjectId(user_id) if isinstance(user_id, str) else user_id
        self.user_alias = user_alias
        self.user_name = user_name
        self.content = content
        self.created_at = created_at or datetime.utcnow()
        self.likes = likes
        self.dislikes = dislikes
        self.liked_by = liked_by or []
        self.disliked_by = disliked_by or []
    
    def to_dict(self):
        """Convertir a diccionario para MongoDB"""
        return {
            "_id": self._id,
            "user_id": self.user_id,
            "user_alias": self.user_alias,
            "user_name": self.user_name,
            "content": self.content,
            "created_at": self.created_at,
            "likes": self.likes,
            "dislikes": self.dislikes,
            "liked_by": self.liked_by,
            "disliked_by": self.disliked_by,
        }
    
    @staticmethod
    def from_dict(data: dict):
        """Crear desde diccionario de MongoDB"""
        return Publication(
            _id=data.get("_id"),
            user_id=data.get("user_id"),
            user_alias=data.get("user_alias"),
            user_name=data.get("user_name"),
            content=data.get("content"),
            created_at=data.get("created_at"),
            likes=data.get("likes", 0),
            dislikes=data.get("dislikes", 0),
            liked_by=data.get("liked_by", []),
            disliked_by=data.get("disliked_by", []),
        )
