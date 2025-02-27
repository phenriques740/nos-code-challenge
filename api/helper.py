from functools import wraps
import logging
from flask import request, jsonify
from config import API_KEY


def require_api_key(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if request.headers.get("X-API-KEY") != API_KEY:
            logging.warning("Unauthorized access attempt")
            return jsonify({"error": "Unauthorized access"}), 403
        return f(*args, **kwargs)
    return decorated_function