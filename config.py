"""Configuración de PandaPOP.

Todos los valores sensibles se leen del archivo .env (nunca se escriben en el código).
"""
import os
from datetime import timedelta

from dotenv import load_dotenv

BASE_DIR = os.path.abspath(os.path.dirname(__file__))
load_dotenv(os.path.join(BASE_DIR, ".env"))


def _bool(nombre, defecto="0"):
    return os.getenv(nombre, defecto).strip().lower() in ("1", "true", "si", "sí", "yes")


class Config:
    # --- Base de datos (MySQL/MariaDB de XAMPP) ---
    DB_HOST = os.getenv("DB_HOST", "127.0.0.1")
    DB_PORT = int(os.getenv("DB_PORT", "3306"))
    DB_USER = os.getenv("DB_USER", "root")
    DB_PASSWORD = os.getenv("DB_PASSWORD", "")
    DB_NAME = os.getenv("DB_NAME", "pandapop")
    # Zona horaria de Colombia: los datos de prueba usan -05:00.
    DB_TIMEZONE = "-05:00"

    # --- Seguridad ---
    SECRET_KEY = os.getenv("SECRET_KEY", "")
    SESSION_COOKIE_HTTPONLY = True
    SESSION_COOKIE_SAMESITE = "Lax"
    SESSION_COOKIE_SECURE = _bool("SESSION_COOKIE_SECURE")
    # La sesión de un niño caduca por inactividad (más corta = más seguro en equipos compartidos).
    PERMANENT_SESSION_LIFETIME = timedelta(hours=2)
    WTF_CSRF_TIME_LIMIT = 60 * 60 * 2
    MAX_CONTENT_LENGTH = 64 * 1024  # los formularios son pequeños

    # Intentos de inicio de sesión fallidos antes de bloquear temporalmente.
    LOGIN_MAX_INTENTOS = 5
    LOGIN_BLOQUEO_SEG = 15 * 60

    # --- Negocio ---
    EDAD_MIN = 6
    EDAD_MAX = 14
    POLITICA_VERSION = os.getenv("POLITICA_VERSION", "v1.0")

    DEBUG = _bool("FLASK_DEBUG", "1")
