"""Utilidades de seguridad de PandaPOP.

- Claves con bcrypt (nunca se guardan en texto plano).
- Límite de intentos de inicio de sesión (frena la fuerza bruta).
- Decorador que protege las pantallas del niño.
- Registro de acciones en la tabla `auditoria`.
- Validación de la URL "next" para evitar redirecciones abiertas.
"""
import threading
import time
from collections import deque
from functools import wraps
from urllib.parse import urlparse

import bcrypt
from flask import g, redirect, request, session, url_for

from .db import execute, query_one

MAX_BYTES_CLAVE = 72  # límite real de bcrypt

# ---------------------------------------------------------------- claves


def hash_clave(clave):
    return bcrypt.hashpw(clave.encode("utf-8"), bcrypt.gensalt(rounds=12)).decode("ascii")


def verificar_clave(clave, hash_guardado):
    try:
        return bcrypt.checkpw(clave.encode("utf-8"), hash_guardado.encode("ascii"))
    except (ValueError, TypeError):
        return False


_hash_falso = None


def hash_falso():
    """Hash de relleno: se compara cuando el usuario no existe.

    Así el login tarda lo mismo exista o no la cuenta y no se puede
    descubrir qué usuarios existen midiendo el tiempo de respuesta.
    """
    global _hash_falso
    if _hash_falso is None:
        _hash_falso = hash_clave("clave-de-relleno-no-valida")
    return _hash_falso


# ------------------------------------------------- límite de intentos
# Memoria del proceso: suficiente para desarrollo local con un solo proceso.
# En producción con varios procesos conviene usar Redis o la base de datos.

_intentos = {}
_candado = threading.Lock()


def _depurar(cola, ventana, ahora):
    while cola and ahora - cola[0] > ventana:
        cola.popleft()


def bloqueado(clave, maximo, ventana_seg):
    ahora = time.monotonic()
    with _candado:
        cola = _intentos.get(clave)
        if not cola:
            return False
        _depurar(cola, ventana_seg, ahora)
        return len(cola) >= maximo


def registrar_fallo(clave, ventana_seg):
    ahora = time.monotonic()
    with _candado:
        if len(_intentos) > 10000:  # evita que la memoria crezca sin límite
            for k in [k for k, v in _intentos.items() if not v]:
                del _intentos[k]
        cola = _intentos.setdefault(clave, deque())
        _depurar(cola, ventana_seg, ahora)
        cola.append(ahora)


def olvidar_intentos(clave):
    with _candado:
        _intentos.pop(clave, None)


def ip_cliente():
    return (request.remote_addr or "desconocida")[:45]


# ------------------------------------------------------------ auditoría


def auditar(accion, entidad, id_registro=None, id_usuario=None, id_nino=None, observacion=None):
    """Guarda quién hizo qué (acciones válidas: CREAR, ACTUALIZAR, LOGIN...)."""
    execute(
        """INSERT INTO auditoria
               (id_usuario, id_nino, entidad, id_registro, accion, ip_origen, observacion)
           VALUES (%s, %s, %s, %s, %s, %s, %s)""",
        (id_usuario, id_nino, entidad, id_registro, accion, ip_cliente(), observacion),
    )


# ------------------------------------------------------------ redirecciones


def es_url_local(destino):
    """True solo si la URL apunta a esta misma aplicación."""
    if not destino or not destino.startswith("/") or destino.startswith(("//", "/\\")):
        return False
    partes = urlparse(destino)
    return not partes.scheme and not partes.netloc


# ------------------------------------------------------- protección de vistas


def nino_required(vista):
    """Solo deja pasar a un niño con sesión iniciada y cuenta activa."""

    @wraps(vista)
    def envoltura(*args, **kwargs):
        uid = session.get("uid")
        nino = None
        if uid:
            nino = query_one(
                """SELECT u.id_usuario, u.nombres, u.apellidos, u.nombre_usuario,
                          p.fecha_nacimiento, p.grado,
                          TIMESTAMPDIFF(YEAR, p.fecha_nacimiento, CURDATE()) AS edad
                   FROM usuario u
                   JOIN perfil_nino p ON p.id_usuario = u.id_usuario
                   JOIN usuario_rol ur ON ur.id_usuario = u.id_usuario AND ur.id_rol = 1
                   WHERE u.id_usuario = %s AND u.estado = 1""",
                (uid,),
            )
        if not nino:
            session.clear()
            return redirect(url_for("auth.ingresar", next=request.path))
        g.nino = nino
        return vista(*args, **kwargs)

    return envoltura
