from database.db import db

collection = db["announcements"]

def get_announcements():

    announcements = []

    for item in collection.find():

        announcements.append({
            "id": str(item["_id"]),
            "category": item.get("category"),
            "title": item.get("title"),
            "description": item.get("description"),
            "content": item.get("content", ""),
            "active": item.get("active")
        })

    return announcements