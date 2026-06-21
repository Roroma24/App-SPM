from flask import Blueprint, request, jsonify
from bson import ObjectId
from datetime import datetime
import logging

from database.db import db

notifications = Blueprint('notifications', __name__)
logger = logging.getLogger(__name__)

# GET todas las notificaciones del usuario
@notifications.route('/<user_id>', methods=['GET'])
def get_notifications(user_id):
    try:
        user_obj_id = ObjectId(user_id)
        notifs = list(db.notifications.find(
            {"user_id": user_obj_id}
        ).sort("created_at", -1))
        
        for notif in notifs:
            notif['_id'] = str(notif['_id'])
            notif['user_id'] = str(notif['user_id'])
            if notif.get('related_id'):
                notif['related_id'] = str(notif['related_id'])
        
        unread_count = db.notifications.count_documents(
            {"user_id": user_obj_id, "is_read": False}
        )
        
        logger.info(f"Retrieved {len(notifs)} notifications for user {user_id}")
        
        return jsonify({
            "success": True,
            "notifications": notifs,
            "unread_count": unread_count
        }), 200
    except Exception as e:
        logger.error(f"Error getting notifications: {str(e)}")
        return jsonify({"success": False, "message": str(e)}), 500

# PATCH marcar notificación como leída
@notifications.route('/<notif_id>/read', methods=['PATCH'])
def mark_as_read(notif_id):
    try:
        result = db.notifications.update_one(
            {"_id": ObjectId(notif_id)},
            {
                "$set": {
                    "is_read": True,
                    "read_at": datetime.utcnow()
                }
            }
        )
        logger.info(f"Marked notification {notif_id} as read")
        return jsonify({
            "success": result.modified_count > 0,
            "message": "Notificación marcada como leída"
        }), 200
    except Exception as e:
        logger.error(f"Error marking notification as read: {str(e)}")
        return jsonify({"success": False, "message": str(e)}), 500

# PATCH marcar como no leída
@notifications.route('/<notif_id>/unread', methods=['PATCH'])
def mark_as_unread(notif_id):
    try:
        result = db.notifications.update_one(
            {"_id": ObjectId(notif_id)},
            {
                "$set": {
                    "is_read": False,
                    "read_at": None
                }
            }
        )
        logger.info(f"Marked notification {notif_id} as unread")
        return jsonify({
            "success": result.modified_count > 0,
            "message": "Notificación marcada como no leída"
        }), 200
    except Exception as e:
        logger.error(f"Error marking notification as unread: {str(e)}")
        return jsonify({"success": False, "message": str(e)}), 500

# POST crear notificación
@notifications.route('/', methods=['POST'])
def create_notification():
    try:
        data = request.json
        notification = {
            "user_id": ObjectId(data['user_id']),
            "title": data['title'],
            "message": data['message'],
            "type": data.get('type', 'system'),
            "is_read": False,
            "created_at": datetime.utcnow(),
            "read_at": None,
            "related_id": ObjectId(data['related_id']) if data.get('related_id') else None
        }
        result = db.notifications.insert_one(notification)
        logger.info(f"Created notification {result.inserted_id}")
        return jsonify({
            "success": True,
            "notification_id": str(result.inserted_id)
        }), 201
    except Exception as e:
        logger.error(f"Error creating notification: {str(e)}")
        return jsonify({"success": False, "message": str(e)}), 500

# DELETE marcar todas como leídas
@notifications.route('/<user_id>/mark-all-read', methods=['PATCH'])
def mark_all_as_read(user_id):
    try:
        user_obj_id = ObjectId(user_id)
        result = db.notifications.update_many(
            {"user_id": user_obj_id, "is_read": False},
            {
                "$set": {
                    "is_read": True,
                    "read_at": datetime.utcnow()
                }
            }
        )
        logger.info(f"Marked {result.modified_count} notifications as read for user {user_id}")
        return jsonify({
            "success": True,
            "message": f"Se marcaron {result.modified_count} notificaciones como leídas"
        }), 200
    except Exception as e:
        logger.error(f"Error marking all notifications as read: {str(e)}")
        return jsonify({"success": False, "message": str(e)}), 500
