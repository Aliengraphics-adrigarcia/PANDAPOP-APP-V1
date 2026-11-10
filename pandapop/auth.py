"""Inicio de sesión del niño y registro de la familia (el acudiente crea al niño)."""
import re
from datetime import date

import pymysql
from flask import Blueprint, abort, current_app, flash, redirect, render_template, request, session, url_for

from .db import execute, nuevo_id, query_all, query_one, transaccion
from .security import (
    MAX_BYTES_CLAVE,
    auditar,
    bloqueado,
    es_url_local,
    hash_clave,
    hash_falso,
    ip_cliente,
    olvidar_intentos,
    registrar_fallo,
    verificar_clave,
)

bp = Blueprint("auth", __name__)

# --------------------------------------------------------------- reglas de validación
RE_NOMBRE = re.compile(r"^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ][A-Za-zÁÉÍÓÚÜÑáéíóúüñ '’.-]{0,99}$")
RE_CORREO = re.compile(r"^[^@\s]{1,64}@[^@\s]+\.[^@\s]{2,}$")
RE_USUARIO = re.compile(r"^[a-z0-9._]{3,30}$")

# id_tipo_vinculo de la tabla tipo_vinculo (solo los familiares).
VINCULOS = {"1": "Madre", "2": "Padre", "3": "Tutor legal", "4": "Acudiente"}
GRADOS = ["Transición"] + [f"{n}°" for n in range(1, 10)]

MAX_REGISTROS_HORA = 20
VENTANA_REGISTRO = 3600


class ErrorRegistro(Exception):
    """Error de negocio al crear la familia (se muestra al usuario)."""

    def __init__(self, campo, mensaje):
        super().__init__(mensaje)
        self.campo = campo
        self.mensaje = mensaje


def _limpiar(texto):
    return re.sub(r"\s+", " ", (texto or "")).strip()


def calcular_edad(nacimiento, hoy=None):
    hoy = hoy or date.today()
    return hoy.year - nacimiento.year - ((hoy.month, hoy.day) < (nacimiento.month, nacimiento.day))


# -------------------------------------------------------------------- portada
@bp.route("/")
def inicio():
    if session.get("uid"):
        return redirect(url_for("nino.inicio"))
    return render_template("auth/inicio.html")


# ---------------------------------------------------------------------- login
@bp.route("/ingresar", methods=["GET", "POST"])
def ingresar():
    if session.get("uid"):
        return redirect(url_for("nino.inicio"))

    destino = request.values.get("next", "")
    error = None

    if request.method == "POST":
        identificador = (request.form.get("identificador") or "").strip().lower()[:150]
        clave = request.form.get("clave") or ""
        llave = f"login|{ip_cliente()}|{identificador}"
        maximo = current_app.config["LOGIN_MAX_INTENTOS"]
        ventana = current_app.config["LOGIN_BLOQUEO_SEG"]

        if bloqueado(llave, maximo, ventana):
            return render_template("auth/ingresar.html", error="Demasiados intentos. Espera unos minutos.", next=destino), 429

        usuario = None
        if identificador and clave:
            usuario = query_one(
                """SELECT id_usuario, nombres, clave_hash, estado
                   FROM usuario WHERE nombre_usuario = %s OR correo = %s LIMIT 1""",
                (identificador, identificador),
            )

        # Se verifica siempre una clave (real o de relleno) para que el tiempo no delate si la cuenta existe.
        hash_a_probar = usuario["clave_hash"] if usuario else hash_falso()
        clave_ok = verificar_clave(clave, hash_a_probar) and usuario is not None and usuario["estado"] == 1

        if not clave_ok:
            registrar_fallo(llave, ventana)
            _auditar_login(usuario, "Intento fallido")
            error = "El usuario o la clave no son correctos."
        else:
            es_nino = query_one(
                "SELECT 1 AS ok FROM usuario_rol WHERE id_usuario = %s AND id_rol = 1", (usuario["id_usuario"],)
            )
            if not es_nino:
                # Clave correcta, pero esta versión es solo para niños.
                error = "Esta versión de PandaPop es solo para niños. El acceso para adultos llegará pronto."
            else:
                olvidar_intentos(llave)
                session.clear()
                session["uid"] = usuario["id_usuario"]
                session["nombre"] = usuario["nombres"].split(" ")[0]
                session.permanent = True
                execute("UPDATE usuario SET ultimo_acceso = NOW() WHERE id_usuario = %s", (usuario["id_usuario"],))
                auditar("LOGIN", "usuario", usuario["id_usuario"], usuario["id_usuario"], usuario["id_usuario"], "Ingreso correcto")
                return redirect(destino if es_url_local(destino) else url_for("nino.inicio"))

    return render_template("auth/ingresar.html", error=error, next=destino if es_url_local(destino) else ""), (
        200 if not error else 401
    )


def _auditar_login(usuario, observacion):
    id_usuario = usuario["id_usuario"] if usuario else None
    auditar("LOGIN", "usuario", id_usuario, id_usuario, None, observacion)


@bp.route("/olvide")
def olvide():
    return render_template("auth/olvide.html")


@bp.route("/salir", methods=["POST"])
def salir():
    session.clear()
    return redirect(url_for("auth.inicio"))


# ------------------------------------------------------------------- registro
CAMPOS = [
    "quien", "acu_nombres", "acu_apellidos", "acu_correo", "acu_correo2", "vinculo",
    "nino_nombres", "nino_apellidos", "nino_nacimiento", "nino_grado", "nino_usuario", "institucion",
]


@bp.route("/registro", methods=["GET", "POST"])
def registro():
    if session.get("uid"):
        return redirect(url_for("nino.inicio"))

    instituciones = query_all("SELECT id_institucion, nombre FROM institucion WHERE estado = 1 ORDER BY nombre")
    datos = {"quien": "padre"}
    consent = {"datos": False, "emocional": False, "notif": False}
    errores = {}

    if request.method == "POST":
        llave = f"registro|{ip_cliente()}"
        if bloqueado(llave, MAX_REGISTROS_HORA, VENTANA_REGISTRO):
            abort(429)
        registrar_fallo(llave, VENTANA_REGISTRO)  # cada envío cuenta, sea correcto o no

        datos = {campo: _limpiar(request.form.get(campo)) for campo in CAMPOS}
        consent = {
            "datos": request.form.get("consent_datos") == "1",
            "emocional": request.form.get("consent_emocional") == "1",
            "notif": request.form.get("consent_notif") == "1",
        }
        claves = {
            "acu": request.form.get("acu_clave") or "",
            "acu2": request.form.get("acu_clave2") or "",
            "nino": request.form.get("nino_clave") or "",
        }
        ids_instituciones = {i["id_institucion"] for i in instituciones}
        errores = validar_registro(datos, claves, consent, ids_instituciones)

        if not errores:
            try:
                nino = crear_familia(datos, claves, consent)
            except ErrorRegistro as e:
                errores[e.campo] = e.mensaje
            else:
                session["registro_ok"] = nino
                return redirect(url_for("auth.registro_listo"))

    return render_template(
        "auth/registro.html",
        datos=datos, errores=errores, consent=consent,
        opciones_vinculo=list(VINCULOS.items()),
        opciones_grado=[(g, g) for g in GRADOS],
        opciones_institucion=[(i["id_institucion"], i["nombre"]) for i in instituciones],
        hoy=date.today().isoformat(),
        edad_min=current_app.config["EDAD_MIN"], edad_max=current_app.config["EDAD_MAX"],
    ), (422 if errores else 200)


def validar_registro(d, claves, consent, ids_instituciones):
    cfg = current_app.config
    e = {}

    if d["quien"] not in ("nino", "padre"):
        e["quien"] = "Elige quién eres."

    for campo in ("acu_nombres", "acu_apellidos", "nino_nombres", "nino_apellidos"):
        if not RE_NOMBRE.match(d[campo]):
            e[campo] = "Escribe solo letras (máximo 100)."

    d["acu_correo"] = d["acu_correo"].lower()
    d["acu_correo2"] = d["acu_correo2"].lower()
    if not RE_CORREO.match(d["acu_correo"]) or len(d["acu_correo"]) > 150:
        e["acu_correo"] = "Escribe un correo válido."
    elif d["acu_correo"] != d["acu_correo2"]:
        e["acu_correo2"] = "Los correos no coinciden."

    if d["vinculo"] not in VINCULOS:
        e["vinculo"] = "Elige tu vínculo con el niño."

    # Fecha de nacimiento (reemplaza el campo "Edad": la edad se calcula y siempre está al día).
    try:
        nacimiento = date.fromisoformat(d["nino_nacimiento"])
        edad = calcular_edad(nacimiento)
        if nacimiento > date.today() or not (cfg["EDAD_MIN"] <= edad <= cfg["EDAD_MAX"]):
            e["nino_nacimiento"] = f"PandaPop es para niños de {cfg['EDAD_MIN']} a {cfg['EDAD_MAX']} años."
    except ValueError:
        e["nino_nacimiento"] = "Elige una fecha válida."

    if d["nino_grado"] and d["nino_grado"] not in GRADOS:
        e["nino_grado"] = "Elige un grado de la lista."

    if not RE_USUARIO.match(d["nino_usuario"].lower()):
        e["nino_usuario"] = "De 3 a 30 caracteres: letras minúsculas, números, punto o guion bajo."
    d["nino_usuario"] = d["nino_usuario"].lower()

    if d["institucion"] and d["institucion"] not in ids_instituciones:
        e["institucion"] = "Elige una institución de la lista."

    # Claves
    clave = claves["acu"]
    if len(clave.encode("utf-8")) > MAX_BYTES_CLAVE or len(clave) < 8 or not (
        re.search(r"[A-Za-z]", clave) and re.search(r"\d", clave)
    ):
        e["acu_clave"] = "Mínimo 8 caracteres, con letras y números."
    elif clave != claves["acu2"]:
        e["acu_clave2"] = "Las claves no coinciden."

    clave_nino = claves["nino"]
    if not (6 <= len(clave_nino) <= 20):
        e["nino_clave"] = "La clave del niño debe tener de 6 a 20 caracteres."
    elif clave_nino.lower() == d["nino_usuario"]:
        e["nino_clave"] = "La clave no puede ser igual al usuario."

    if not consent["datos"]:
        e["consent"] = "Debes aceptar el tratamiento de datos para crear la cuenta."

    return e


def crear_familia(d, claves, consent):
    """Crea (o reutiliza) al acudiente y crea al niño con su vínculo y consentimientos."""
    version = current_app.config["POLITICA_VERSION"]
    try:
        with transaccion():
            acudiente = query_one("SELECT id_usuario, clave_hash FROM usuario WHERE correo = %s FOR UPDATE", (d["acu_correo"],))

            if acudiente:
                # El correo ya existe: solo se reutiliza si es un acudiente y escribe su clave actual.
                es_acudiente = query_one(
                    "SELECT 1 AS ok FROM usuario_rol WHERE id_usuario = %s AND id_rol = 2", (acudiente["id_usuario"],)
                )
                if not es_acudiente or not verificar_clave(claves["acu"], acudiente["clave_hash"]):
                    raise ErrorRegistro(
                        "acu_clave", "Revisa tu correo y tu clave. Si ya tienes cuenta, escribe la misma clave de siempre."
                    )
                id_acudiente = acudiente["id_usuario"]
            else:
                id_acudiente = nuevo_id()
                execute(
                    """INSERT INTO usuario (id_usuario, nombres, apellidos, correo, clave_hash, idioma, correo_verificado)
                       VALUES (%s, %s, %s, %s, %s, 'es', 0)""",
                    (id_acudiente, d["acu_nombres"], d["acu_apellidos"], d["acu_correo"], hash_clave(claves["acu"])),
                )
                execute("INSERT INTO usuario_rol (id_usuario, id_rol) VALUES (%s, 2)", (id_acudiente,))

            id_nino = nuevo_id()
            execute(
                """INSERT INTO usuario (id_usuario, nombres, apellidos, nombre_usuario, clave_hash, idioma, correo_verificado)
                   VALUES (%s, %s, %s, %s, %s, 'es', 0)""",
                (id_nino, d["nino_nombres"], d["nino_apellidos"], d["nino_usuario"], hash_clave(claves["nino"])),
            )
            execute("INSERT INTO usuario_rol (id_usuario, id_rol) VALUES (%s, 1)", (id_nino,))
            execute(
                "INSERT INTO perfil_nino (id_usuario, fecha_nacimiento, grado) VALUES (%s, %s, %s)",
                (id_nino, d["nino_nacimiento"], d["nino_grado"] or None),
            )
            execute(
                """INSERT INTO vinculo_nino_adulto
                       (id_vinculo, id_nino, id_adulto, id_tipo_vinculo, parentesco, es_principal,
                        puede_ver_progreso, puede_ver_emocional, puede_ver_observaciones,
                        puede_recibir_reportes, fecha_inicio, estado)
                   VALUES (%s, %s, %s, %s, %s, 1, 1, %s, 1, %s, CURDATE(), 1)""",
                (nuevo_id(), id_nino, id_acudiente, int(d["vinculo"]), VINCULOS[d["vinculo"]],
                 int(consent["emocional"]), int(consent["notif"])),
            )
            if d["institucion"]:
                execute(
                    """INSERT INTO membresia_institucion (id_membresia, id_institucion, id_usuario, id_rol, fecha_inicio, estado)
                       VALUES (%s, %s, %s, 1, CURDATE(), 1)""",
                    (nuevo_id(), d["institucion"], id_nino),
                )
            # Ley 1581 de 2012: se guarda qué autorizó el acudiente, cuándo y con qué versión de la política.
            for finalidad, otorgado in (
                ("TRATAMIENTO_DATOS", consent["datos"]),
                ("DATOS_EMOCIONALES", consent["emocional"]),
                ("NOTIFICACIONES", consent["notif"]),
            ):
                if otorgado:
                    execute(
                        """INSERT INTO consentimiento_datos
                               (id_consentimiento, id_nino, id_acudiente, finalidad, version_politica, otorgado, medio, fecha_otorgado)
                           VALUES (%s, %s, %s, %s, %s, 1, 'APP', NOW())""",
                        (nuevo_id(), id_nino, id_acudiente, finalidad, version),
                    )
            auditar("CREAR", "usuario", id_nino, id_acudiente, id_nino, "Registro del niño por su acudiente")
    except pymysql.err.IntegrityError as error:
        if error.args and error.args[0] == 1062:
            raise ErrorRegistro("nino_usuario", "Ese nombre de usuario ya existe. Prueba con otro.")
        raise
    except pymysql.err.MySQLError as error:
        if error.args and error.args[0] == 1644:  # regla de edad de la base de datos
            raise ErrorRegistro("nino_nacimiento", "PandaPop es para niños de 6 a 14 años.")
        raise

    return {"usuario": d["nino_usuario"], "nombre": d["nino_nombres"].split(" ")[0]}


@bp.route("/registro/listo")
def registro_listo():
    datos = session.pop("registro_ok", None)
    if not datos:
        return redirect(url_for("auth.registro"))
    return render_template("auth/registro_listo.html", datos=datos)
