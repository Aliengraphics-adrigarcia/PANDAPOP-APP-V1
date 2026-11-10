# PandaPop · Perfil del niño (Flask + MySQL)

Aplicación web **mobile-first** para niños de 6 a 14 años, hecha con **Flask** y **MySQL/MariaDB**.
Esta entrega cubre **solo el perfil del niño** basado en las pantallas del prototipo de Figma que ya elaboré más el **registro**, donde el **acudiente crea el perfil del niño** por ser el responsable.


Qué incluye esta entrega:

| Pantalla | Ruta |
|---|---|
| Portada «Crecemos Aprendiendo» | `/` |

| Ingresar / Olvidé mi clave | `/ingresar`, `/olvide` |

| Registro (acudiente + niño + autorizaciones) | `/registro` |

| Inicio: nivel, monedas, misiones del día, módulos, atajos | `/inicio` |

| Módulos y detalle de módulo | `/modulos`, `/modulos/<id>` |

| Actividad (maqueta navegable) y resultado | `/actividad/<id>`, `/actividad/<id>/resultado` |

| Menú, Juegos y Retos, Mis Actividades, Mis Logros, Mis avances, Recompensas | `/menu`, `/juegos`, `/actividades`, `/logros`, `/avances`, `/recompensas` |

| Ayuda y Perfil | `/ayuda`, `/perfil` |


Requisitos técnicos:
- XAMPP 
- MySQL/MariaDB
- phpMyAdmin**).
- Python 3.10


**Importante:** Apache de XAMPP no ejecuta Flask directamente. XAMPP aporta la base de datos y la app se ejecuta con `python run.py` en http://127.0.0.1:5000.


## Puesta en marcha (Windows, XAMPP)

1. Abre el **Panel de XAMPP** y pulsa **Start** en **MySQL**.
2. Abre **phpMyAdmin** (`http://localhost/phpmyadmin`) → pestaña **Importar** → elige
   `sql/pandapop_bd.sql` → **Importar**. Esto crea la base `pandapop` con datos de prueba.
3. En una terminal, dentro de esta carpeta:

   ```bat
   py -m venv venv
   venv\Scripts\activate
   pip install -r requirements.txt
   copy .env.example .env
   ```

4. Abre `.env` y cambia `SECRET_KEY` por una clave propia. Genérala con:

   ```bat
   python -c "import secrets; print(secrets.token_hex(32))"
   ```

   En XAMPP el usuario `root` no tiene contraseña, así que `DB_USER=root` y `DB_PASSWORD=` vacío funcionan tal cual.

5. Ejecuta la app:

   ```bat
   python run.py
   ```

   La terminal mostrará un recuadro con la dirección y el navegador se abrirá solo en
   **http://127.0.0.1:5000**. Deja la terminal abierta mientras uses la app (se detiene con `Ctrl + C`).
   Usa `127.0.0.1` y no `localhost`: en Windows `localhost` a veces apunta a IPv6 y no carga.

   Lo que deberías ver: la portada **«Crecemos Aprendiendo»** (panda, niño con tableta y los botones
   *Crear cuenta* / *Iniciar sesión*). La portada carga aunque MySQL esté apagado; el ingreso y el registro sí lo necesitan.

En macOS/Linux usa `python3 -m venv venv`, `source venv/bin/activate` y `cp .env.example .env`.

## Usuarios de prueba

Clave de **todos** los usuarios sembrados: `PandaPop#2026`

| Rol | Usuario |
|---|---|
| Niña (6 años, 65 monedas) | `sofia.mesa` |
| Otros niños | `tomas.perez`, `mateo.mesa`, `valentina.cardona`, `samuel.rendon`, `emilia.rendon`, `juandavid.perez`, `isabella.salazar` |
| Acudiente | `carolina.duran@pandapop.test` |

Los adultos **no pueden entrar todavía**: esta versión es solo para niños y se les muestra un aviso claro.

## Estructura

```
run.py                  Arranque (127.0.0.1:5000)
config.py               Configuración leída desde .env
sql/pandapop_bd.sql     Base de datos (sin modificar)
pandapop/
  __init__.py           Fábrica de la app, cabeceras de seguridad (CSP), manejo de errores
  db.py                 Conexión PyMySQL, consultas parametrizadas y transacciones
  security.py           bcrypt, límite de intentos, auditoría, control de rol NIÑO
  auth.py               Portada, ingreso, registro, salir
  nino.py               Pantallas del niño
  templates/            Plantillas Jinja (base, partials, auth/, nino/)
  static/               CSS, JS, fuentes Poppins (OFL), imágenes
```

## Seguridad incorporada

- Claves con **bcrypt**; consultas **parametrizadas** (sin SQL concatenado).
- **CSRF** en todos los formularios; cierre de sesión solo por **POST**.
- Cookies `HttpOnly` + `SameSite=Lax` (y `Secure` con HTTPS), sesión de 2 horas.
- **CSP estricta** (sin estilos ni scripts en línea), `X-Frame-Options: DENY`, `nosniff`, `no-store`.
- **Límite de intentos**: 5 fallos de ingreso por 15 minutos; 20 registros por hora por IP.
- Respuesta de ingreso igual para usuario inexistente o clave errónea (sin enumeración de usuarios).
- Redirección `next` solo a rutas locales (sin *open redirect*).
- **Consentimiento (Ley 1581)** guardado en `consentimiento_datos` y acciones registradas en `auditoria`.
- Un niño solo ve sus propios datos; los módulos se filtran por su edad.

## Decisiones de esta versión

- **Actividades = maqueta navegable:** no se califican ni se guardan respuestas; la pantalla de
  resultado muestra monedas de ejemplo y no suma al total.
- **Monedas = puntos** (`movimiento_puntos` + vista `vw_puntos_nivel_nino`). El avance de una misión se
  muestra como 0 % / 50 % / 100 % según su estado.
- **Sin «Ranking»:** se quitó del menú para no comparar niños entre sí (privacidad de menores).
- **«Edad» → fecha de nacimiento:** la base calcula la edad y valida el rango 6–14 años.
- **Campo «# Identificación» del prototipo omitido:** la base de datos no tiene esa columna.
- «E-mail» del ingreso pasó a **«Usuario o correo»**: el niño ingresa con su usuario.
- La clave del niño tiene de 6 a 20 caracteres y no puede ser igual a su usuario.
- No implementado: ingreso social («o ingresa así»), verificación de correo y recuperación real de clave
  (la pantalla `/olvide` solo orienta al acudiente).
- El límite de intentos vive en memoria: se reinicia al reiniciar la app y no se comparte entre procesos.

## Pasar a producción

1. `FLASK_DEBUG=0`, `SESSION_COOKIE_SECURE=1` y HTTPS.
2. Servir con un servidor WSGI (por ejemplo `gunicorn` o `waitress`) detrás de Nginx/Apache; no uses `python run.py`.
3. No uses `root` en la base. Crea un usuario con permisos mínimos:

   ```sql
   CREATE USER 'pandapop_app'@'localhost' IDENTIFIED BY 'una-clave-larga';
   GRANT SELECT, INSERT, UPDATE, DELETE ON pandapop.* TO 'pandapop_app'@'localhost';
   ```

4. Reemplaza el límite en memoria por uno compartido (Redis) si usas varios procesos.
5. Cambia las claves de los usuarios de prueba o elimínalos.

## Solución de problemas

- **«No veo nada» al abrir la dirección:** revisa la terminal. Debe verse el recuadro «PandaPop está listo» y la línea
  `Running on http://127.0.0.1:5000`. Si la terminal queda en blanco o vuelve al símbolo sin mensajes, `python` no está
  apuntando a Python (en Windows prueba `py run.py`). Si la terminal muestra un error, ese texto indica la causa.
- **La página carga pero se ve sin colores ni estilos:** haz recarga forzada (`Ctrl + F5`) y confirma que abriste
  `http://127.0.0.1:5000` y no un archivo `.html` suelto.

- **Página «503 / No hay conexión con la base de datos»:** MySQL no está iniciado en XAMPP o `.env` tiene datos incorrectos.
- **`ModuleNotFoundError`:** activa el entorno (`venv\Scripts\activate`) y ejecuta `pip install -r requirements.txt`.
- **Error 1698 «Access denied for user root»** (MariaDB en Linux): crea el usuario de la sección anterior y ponlo en `.env`.
