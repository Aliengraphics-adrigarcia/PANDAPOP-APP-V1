"""Punto de entrada de PandaPOP.

Uso local (con MySQL de XAMPP encendido):
    python run.py
y abrir http://127.0.0.1:5000 
"""
import os
import threading
import webbrowser

from pandapop import create_app

app = create_app()

HOST = "127.0.0.1"   # solo accesible desde este computador (más seguro en desarrollo)
PORT = 5000
URL = f"http://{HOST}:{PORT}"

if __name__ == "__main__":
    # En modo debug Flask lanza dos procesos; solo el principal avisa y abre el navegador.
    if os.environ.get("WERKZEUG_RUN_MAIN") != "true":
        print("\n" + "=" * 58)
        print("  PandaPop está listo.  Abre en tu navegador:")
        print(f"      {URL}")
        print("  (para detener la app: Ctrl + C)")
        print("=" * 58 + "\n", flush=True)
        # Abre el navegador 1,5 s después de arrancar el servidor.
        threading.Timer(1.5, lambda: webbrowser.open(URL)).start()
    app.run(host=HOST, port=PORT, debug=app.config["DEBUG"])
