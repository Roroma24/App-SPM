from flask import Blueprint, jsonify

from models.announcement import get_announcements

announcement_bp = Blueprint(
    "announcements",
    __name__
)

@announcement_bp.route(
    "/announcements",
    methods=["GET"]
)
def announcements():

    return jsonify(
        get_announcements()
    )