/* PandaPop · mejoras progresivas (la app funciona igual sin JavaScript).
   Sin dependencias externas ni código en línea: compatible con la CSP estricta. */
(function () {
  "use strict";

  // Marca que JS está activo para mostrar los botones que lo necesitan.
  document.documentElement.classList.add("js");

  // 1) Mostrar u ocultar la clave en los campos de contraseña.
  document.querySelectorAll("[data-toggle-clave]").forEach(function (boton) {
    boton.setAttribute("aria-pressed", "false");
    boton.addEventListener("click", function () {
      var campo = document.getElementById(boton.getAttribute("data-toggle-clave"));
      if (!campo) { return; }
      var visible = campo.type === "text";
      campo.type = visible ? "password" : "text";
      boton.setAttribute("aria-pressed", visible ? "false" : "true");
    });
  });

  // 2) Registro: avisa que un niño necesita a su acudiente cuando elige "Niño".
  var aviso = document.querySelector("[data-aviso-nino]");
  var opciones = document.querySelectorAll('input[name="quien"]');
  if (aviso && opciones.length) {
    var actualizar = function () {
      var elegido = document.querySelector('input[name="quien"]:checked');
      aviso.hidden = !(elegido && elegido.value === "nino");
    };
    opciones.forEach(function (op) { op.addEventListener("change", actualizar); });
    actualizar();
  }
})();
