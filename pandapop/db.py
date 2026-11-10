"""Acceso a la base de datos MySQL/MariaDB con PyMySQL.

- Una conexión por petición (se guarda en `g` y se cierra sola al terminar).
- Siempre consultas parametrizadas (%s): así se evita la inyección SQL.
- Los identificadores de la base son UUID de 36 caracteres (CHAR(36)).
"""
import uuid
from contextlib import contextmanager

import pymysql
from flask import current_app, g
from pymysql.cursors import DictCursor


def nuevo_id():
    """Genera un UUID nuevo para una llave primaria CHAR(36)."""
    return str(uuid.uuid4())


def get_db():
    """Devuelve la conexión de la petición actual (la crea si no existe)."""
    if "db" not in g:
        cfg = current_app.config
        g.db = pymysql.connect(
            host=cfg["DB_HOST"],
            port=cfg["DB_PORT"],
            user=cfg["DB_USER"],
            password=cfg["DB_PASSWORD"],
            database=cfg["DB_NAME"],
            charset="utf8mb4",
            cursorclass=DictCursor,
            autocommit=True,
            connect_timeout=5,
            # Las fechas de la base están en hora de Colombia.
            init_command="SET time_zone = '%s'" % cfg["DB_TIMEZONE"],
        )
    return g.db


def cerrar_db(_error=None):
    conexion = g.pop("db", None)
    if conexion is not None:
        conexion.close()


def query_all(sql, args=None):
    """SELECT que devuelve una lista de diccionarios."""
    with get_db().cursor() as cur:
        cur.execute(sql, args)
        return list(cur.fetchall())


def query_one(sql, args=None):
    """SELECT que devuelve un solo diccionario (o None)."""
    with get_db().cursor() as cur:
        cur.execute(sql, args)
        return cur.fetchone()


def execute(sql, args=None):
    """INSERT/UPDATE/DELETE. Devuelve las filas afectadas."""
    with get_db().cursor() as cur:
        return cur.execute(sql, args)


@contextmanager
def transaccion():
    """Agrupa varias escrituras: o se guardan todas o no se guarda ninguna."""
    conexion = get_db()
    conexion.begin()
    try:
        yield
        conexion.commit()
    except Exception:
        conexion.rollback()
        raise


def init_app(app):
    app.teardown_appcontext(cerrar_db)
