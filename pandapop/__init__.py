"""Fábrica de la aplicación PandaPOP (Flask)."""
import logging
import os

import pymysql
from flask import Flask, render_template, request, session
from flask_wtf.csrf import CSRFError, CSRFProtect

from . import db

csrf = CSRFProtect()

# Política de seguridad de contenido: solo se carga lo que viene de nuestro propio
# servidor. No hay estilos ni scripts "en línea", por eso esta política es estricta.
CSP = (
    "default-src 'self'; img-src 'self' data:; style-src 'self'; script-src 'self'; "
    "font-src 'self'; form-action 'self'; frame-ancestors 'none'; base-uri 'self'; "
    "object-src 'none'"
)


def create_app(config_object="config.Config"):
    app = Flask(__name__)
    app.config.from_object(config_object)

    if not app.config["SECRET_KEY"]:
        if app.config["DEBUG"]:
            # Solo para desarrollo: las sesiones se pierden al reiniciar.
            app.config["SECRET_KEY"] = os.urandom(32).hex()
            logging.warning("Falta SECRET_KEY en .env: se usa una clave temporal.")
        else:
            raise RuntimeError("Define SECRET_KEY en el archivo .env antes de arrancar.")

    csrf.init_app(app)
    db.init_app(app)

    from . import auth, nino

    app.register_blueprint(auth.bp)
    app.register_blueprint(nino.bp)

    @app.context_processor
    def datos_globales():
        return {"nombre_sesion": session.get("nombre")}

    @app.after_request
    def cabeceras_de_seguridad(respuesta):
        respuesta.headers["Content-Security-Policy"] = CSP
        respuesta.headers["X-Content-Type-Options"] = "nosniff"
        respuesta.headers["X-Frame-Options"] = "DENY"
        respuesta.headers["Referrer-Policy"] = "same-origin"
        respuesta.headers["Permissions-Policy"] = "camera=(), microphone=(), geolocation=()"
        respuesta.headers["Cross-Origin-Opener-Policy"] = "same-origin"
        if app.config["SESSION_COOKIE_SECURE"]:
            respuesta.headers["Strict-Transport-Security"] = "max-age=31536000"
        # Las páginas con datos del niño no deben quedar guardadas en el navegador.
        if not request.path.startswith("/static/"):
            respuesta.headers["Cache-Control"] = "no-store"
        return respuesta

    # ---------------------------------------------------------- errores
    def pagina_error(codigo, titulo, mensaje):
        return render_template("error.html", codigo=codigo, titulo=titulo, mensaje=mensaje), codigo

    @app.errorhandler(404)
    def no_encontrado(_e):
        return pagina_error(404, "¡Ups! No encontramos esa página", "Vuelve al inicio y sigue explorando.")

    @app.errorhandler(403)
    def prohibido(_e):
        return pagina_error(403, "No tienes permiso para entrar aquí", "Vuelve al inicio.")

    @app.errorhandler(405)
    def metodo_no_permitido(_e):
        return pagina_error(405, "Esa acción no está permitida", "Vuelve al inicio.")

    @app.errorhandler(413)
    def muy_grande(_e):
        return pagina_error(413, "Los datos enviados son demasiado grandes", "Revisa el formulario.")

    @app.errorhandler(429)
    def demasiados(_e):
        return pagina_error(429, "Demasiados intentos", "Espera unos minutos y vuelve a intentarlo.")

    @app.errorhandler(CSRFError)
    def csrf_vencido(_e):
        return pagina_error(
            400, "La página estuvo abierta mucho tiempo", "Vuelve atrás, recarga la página e inténtalo de nuevo."
        )

    @app.errorhandler(pymysql.err.OperationalError)
    def base_no_disponible(error):
        app.logger.error("Error de base de datos: %s", error)
        mensaje = "Intenta de nuevo en unos minutos."
        if app.config["DEBUG"]:
            mensaje = "No hay conexión con MySQL. ¿Está encendido en el panel de XAMPP y importaste pandapop_bd.sql?"
        return pagina_error(503, "No pudimos conectar con la base de datos", mensaje)

    @app.errorhandler(500)
    def error_interno(_e):
        return pagina_error(500, "Algo salió mal", "Ya estamos revisando. Vuelve al inicio.")

    return app
