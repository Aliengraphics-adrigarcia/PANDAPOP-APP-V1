"""Pantallas del perfil del niño.

Alcance de esta entrega: maqueta navegable. El niño recorre módulos y actividades
y ve una pantalla de resultado de ejemplo; todavía NO se califican respuestas ni se
guardan puntos nuevos (no hay tablas de preguntas/respuestas en la base de datos).
Las "monedas" son los puntos reales de `movimiento_puntos`.
"""
from flask import Blueprint, abort, g, render_template

from .db import query_all, query_one
from .security import nino_required

bp = Blueprint("nino", __name__)

# Cómo se agrupan los niveles de dificultad (1 a 5) en las 3 secciones del diseño.
NIVELES = [
    ("basico", "Básico", 1, 2),
    ("intermedio", "Intermedio", 3, 3),
    ("avanzado", "Avanzado", 4, 5),
]
# Progreso mostrado en la misión según el estado de la asignación (1 PENDIENTE, 2 EN_CURSO, 3 COMPLETADA).
PROGRESO_POR_ESTADO = {1: 0, 2: 50, 3: 100}

# Condición "el módulo es para la edad del niño".
POR_EDAD = "%s BETWEEN m.edad_minima AND m.edad_maxima"


@bp.context_processor
def datos_del_nino():
    return {"nino": getattr(g, "nino", None)}


def etiqueta_nivel(numero):
    for _slug, titulo, minimo, maximo in NIVELES:
        if minimo <= numero <= maximo:
            return titulo
    return "Básico"


def estado_puntos(id_nino):
    """Monedas (puntos), nivel actual y avance hacia el siguiente nivel."""
    fila = query_one(
        "SELECT puntos_totales, numero_nivel, nivel FROM vw_puntos_nivel_nino WHERE id_nino = %s", (id_nino,)
    )
    puntos = int(fila["puntos_totales"]) if fila else 0
    numero = fila["numero_nivel"] if fila else 0
    nombre = fila["nivel"] if fila else "Cachorro"

    actual = query_one("SELECT puntos_requeridos FROM nivel WHERE numero_nivel = %s", (numero,))
    siguiente = query_one(
        "SELECT nombre, puntos_requeridos FROM nivel WHERE estado = 1 AND puntos_requeridos > %s "
        "ORDER BY puntos_requeridos LIMIT 1",
        (puntos,),
    )
    base = actual["puntos_requeridos"] if actual else 0
    porcentaje, faltan, nombre_siguiente = 100, 0, None
    if siguiente:
        tramo = siguiente["puntos_requeridos"] - base
        porcentaje = max(0, min(100, round(100 * (puntos - base) / tramo))) if tramo > 0 else 100
        faltan = siguiente["puntos_requeridos"] - puntos
        nombre_siguiente = siguiente["nombre"]
    return {
        "puntos": puntos, "numero": numero, "nombre": nombre,
        "porcentaje": porcentaje, "faltan": faltan, "siguiente": nombre_siguiente,
    }


def misiones_del_dia(nino):
    """Hasta 2 misiones: primero lo asignado al niño; si falta, actividades sugeridas para su edad."""
    misiones = query_all(
        """SELECT a.id_actividad, a.titulo, a.duracion_min, m.titulo AS modulo, an.id_estado_asignacion AS estado
           FROM asignacion_nino an
           JOIN asignacion s ON s.id_asignacion = an.id_asignacion AND s.estado = 1
           JOIN actividad a ON a.id_actividad = s.id_actividad AND a.estado = 1
           JOIN modulo_educativo m ON m.id_modulo = a.id_modulo AND m.estado = 1
           WHERE an.id_nino = %s AND an.id_estado_asignacion IN (1, 2)
           ORDER BY (s.fecha_limite IS NULL), s.fecha_limite, s.fecha_asignacion
           LIMIT 2""",
        (nino["id_usuario"],),
    )
    if len(misiones) < 2:
        usadas = {m["id_actividad"] for m in misiones}
        sugeridas = query_all(
            f"""SELECT a.id_actividad, a.titulo, a.duracion_min, m.titulo AS modulo, 1 AS estado
                FROM actividad a JOIN modulo_educativo m ON m.id_modulo = a.id_modulo
                WHERE a.estado = 1 AND m.estado = 1 AND {POR_EDAD}
                ORDER BY m.nivel_dificultad, m.titulo, a.orden LIMIT 6""",
            (nino["edad"],),
        )
        for s in sugeridas:
            if s["id_actividad"] not in usadas and len(misiones) < 2:
                misiones.append(s)
    for m in misiones:
        m["progreso"] = PROGRESO_POR_ESTADO.get(m["estado"], 0)
    return misiones


def modulos_para_edad(edad):
    return query_all(
        f"""SELECT m.id_modulo, m.titulo, m.descripcion, m.nivel_dificultad, c.nombre AS categoria,
                   (SELECT COUNT(*) FROM actividad a WHERE a.id_modulo = m.id_modulo AND a.estado = 1) AS total_actividades
            FROM modulo_educativo m JOIN categoria c ON c.id_categoria = m.id_categoria
            WHERE m.estado = 1 AND c.estado = 1 AND {POR_EDAD}
            ORDER BY m.nivel_dificultad, m.titulo""",
        (edad,),
    )


def obtener_actividad(id_actividad):
    """Actividad activa cuyo módulo es apropiado para la edad del niño; si no, 404."""
    actividad = query_one(
        f"""SELECT a.id_actividad, a.titulo, a.instrucciones, a.pista, a.puntaje_maximo, a.duracion_min, a.orden,
                   m.id_modulo, m.titulo AS modulo, m.nivel_dificultad, ta.nombre AS tipo
            FROM actividad a
            JOIN modulo_educativo m ON m.id_modulo = a.id_modulo
            JOIN tipo_actividad ta ON ta.id_tipo_actividad = a.id_tipo_actividad
            WHERE a.id_actividad = %s AND a.estado = 1 AND m.estado = 1 AND {POR_EDAD}""",
        (id_actividad, g.nino["edad"]),
    )
    if not actividad:
        abort(404)
    return actividad


# ------------------------------------------------------------------ pantallas
@bp.route("/inicio")
@nino_required
def inicio():
    nino = g.nino
    modulos = modulos_para_edad(nino["edad"])
    niveles = [
        {"slug": slug, "titulo": titulo, "total": sum(1 for m in modulos if minimo <= m["nivel_dificultad"] <= maximo)}
        for slug, titulo, minimo, maximo in NIVELES
    ]
    resumen = query_one(
        f"""SELECT
              (SELECT COUNT(*) FROM actividad a JOIN modulo_educativo m ON m.id_modulo = a.id_modulo
                WHERE a.estado = 1 AND m.estado = 1 AND a.id_tipo_actividad = 2 AND {POR_EDAD}) AS juegos,
              (SELECT COUNT(*) FROM asignacion_nino WHERE id_nino = %s AND id_estado_asignacion IN (1, 2)) AS pendientes,
              (SELECT COUNT(*) FROM nino_recompensa WHERE id_nino = %s) AS logros""",
        (nino["edad"], nino["id_usuario"], nino["id_usuario"]),
    )
    return render_template(
        "nino/inicio.html",
        nav="inicio", puntos=estado_puntos(nino["id_usuario"]),
        misiones=misiones_del_dia(nino), niveles=niveles, resumen=resumen,
    )


@bp.route("/modulos")
@nino_required
def modulos():
    todos = modulos_para_edad(g.nino["edad"])
    grupos = [
        {"slug": slug, "titulo": titulo, "modulos": [m for m in todos if minimo <= m["nivel_dificultad"] <= maximo]}
        for slug, titulo, minimo, maximo in NIVELES
    ]
    return render_template("nino/modulos.html", nav="modulos", grupos=grupos)


@bp.route("/modulos/<id_modulo>")
@nino_required
def modulo(id_modulo):
    datos = query_one(
        f"""SELECT m.id_modulo, m.titulo, m.descripcion, m.nivel_dificultad, c.nombre AS categoria
            FROM modulo_educativo m JOIN categoria c ON c.id_categoria = m.id_categoria
            WHERE m.id_modulo = %s AND m.estado = 1 AND {POR_EDAD}""",
        (id_modulo, g.nino["edad"]),
    )
    if not datos:
        abort(404)
    actividades = query_all(
        """SELECT a.id_actividad, a.titulo, a.duracion_min, a.puntaje_maximo, ta.nombre AS tipo
           FROM actividad a JOIN tipo_actividad ta ON ta.id_tipo_actividad = a.id_tipo_actividad
           WHERE a.id_modulo = %s AND a.estado = 1 ORDER BY a.orden, a.titulo""",
        (id_modulo,),
    )
    return render_template(
        "nino/modulo.html", nav="modulos", modulo=datos, actividades=actividades,
        nivel_texto=etiqueta_nivel(datos["nivel_dificultad"]),
    )


@bp.route("/actividad/<id_actividad>")
@nino_required
def actividad(id_actividad):
    datos = obtener_actividad(id_actividad)
    return render_template(
        "nino/actividad.html", nav="modulos", actividad=datos, nivel_texto=etiqueta_nivel(datos["nivel_dificultad"])
    )


@bp.route("/actividad/<id_actividad>/resultado")
@nino_required
def resultado(id_actividad):
    datos = obtener_actividad(id_actividad)
    siguiente = query_one(
        "SELECT id_actividad FROM actividad WHERE id_modulo = %s AND estado = 1 AND orden > %s ORDER BY orden LIMIT 1",
        (datos["id_modulo"], datos["orden"]),
    )
    return render_template("nino/resultado.html", nav="modulos", actividad=datos, siguiente=siguiente)


@bp.route("/menu")
@nino_required
def menu():
    return render_template("nino/menu.html", nav="menu")


@bp.route("/juegos")
@nino_required
def juegos():
    lista = query_all(
        f"""SELECT a.id_actividad, a.titulo, a.duracion_min, a.puntaje_maximo, 'JUEGO' AS tipo, m.titulo AS modulo
            FROM actividad a JOIN modulo_educativo m ON m.id_modulo = a.id_modulo
            WHERE a.estado = 1 AND m.estado = 1 AND a.id_tipo_actividad = 2 AND {POR_EDAD}
            ORDER BY m.nivel_dificultad, a.titulo""",
        (g.nino["edad"],),
    )
    return render_template(
        "nino/actividades_lista.html", nav="menu", titulo="Juegos y Retos", lista=lista,
        vacio="Pronto habrá juegos nuevos para ti.",
    )


@bp.route("/actividades")
@nino_required
def actividades():
    lista = query_all(
        """SELECT a.id_actividad, a.titulo, a.duracion_min, a.puntaje_maximo, ta.nombre AS tipo,
                  m.titulo AS modulo, e.nombre_estado AS estado
           FROM asignacion_nino an
           JOIN estado_asignacion e ON e.id_estado_asignacion = an.id_estado_asignacion
           JOIN asignacion s ON s.id_asignacion = an.id_asignacion
           JOIN actividad a ON a.id_actividad = s.id_actividad
           JOIN tipo_actividad ta ON ta.id_tipo_actividad = a.id_tipo_actividad
           JOIN modulo_educativo m ON m.id_modulo = a.id_modulo
           WHERE an.id_nino = %s AND e.nombre_estado <> 'CANCELADA'
           ORDER BY an.id_estado_asignacion, s.fecha_asignacion DESC""",
        (g.nino["id_usuario"],),
    )
    return render_template(
        "nino/actividades_lista.html", nav="menu", titulo="Mis Actividades", lista=lista,
        vacio="Aún no tienes actividades asignadas. ¡Explora los módulos!",
    )


def _recompensas(solo_obtenidas):
    return query_all(
        f"""SELECT r.nombre, r.descripcion, r.condicion, tr.nombre AS tipo, nr.fecha_obtencion
            FROM recompensa r
            JOIN tipo_recompensa tr ON tr.id_tipo_recompensa = r.id_tipo_recompensa
            {'JOIN' if solo_obtenidas else 'LEFT JOIN'} nino_recompensa nr
                 ON nr.id_recompensa = r.id_recompensa AND nr.id_nino = %s
            WHERE r.estado = 1
            ORDER BY (nr.fecha_obtencion IS NULL), nr.fecha_obtencion DESC, r.nombre""",
        (g.nino["id_usuario"],),
    )


@bp.route("/logros")
@nino_required
def logros():
    return render_template(
        "nino/recompensas.html", nav="menu", titulo="Mis Logros", lista=_recompensas(True),
        vacio="Completa actividades para ganar tus primeros logros.",
    )


@bp.route("/recompensas")
@nino_required
def recompensas():
    return render_template(
        "nino/recompensas.html", nav="menu", titulo="Recompensas", lista=_recompensas(False), vacio="Pronto habrá recompensas.",
    )


@bp.route("/avances")
@nino_required
def avances():
    id_nino = g.nino["id_usuario"]
    resumen = query_one("SELECT * FROM vw_resumen_actividad_nino WHERE id_nino = %s", (id_nino,))
    movimientos = query_all(
        "SELECT puntos, motivo, fecha_movimiento FROM movimiento_puntos WHERE id_nino = %s "
        "ORDER BY fecha_movimiento DESC LIMIT 8",
        (id_nino,),
    )
    return render_template(
        "nino/avances.html", nav="menu", puntos=estado_puntos(id_nino), resumen=resumen, movimientos=movimientos
    )


@bp.route("/ayuda")
@nino_required
def ayuda():
    return render_template("nino/ayuda.html", nav="ayuda")


@bp.route("/perfil")
@nino_required
def perfil():
    institucion = query_one(
        """SELECT i.nombre FROM membresia_institucion mi
           JOIN institucion i ON i.id_institucion = mi.id_institucion
           WHERE mi.id_usuario = %s AND mi.id_rol = 1 AND mi.estado = 1 LIMIT 1""",
        (g.nino["id_usuario"],),
    )
    return render_template(
        "nino/perfil.html", nav="perfil", institucion=institucion, puntos=estado_puntos(g.nino["id_usuario"])
    )
