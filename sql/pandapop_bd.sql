-- =====================================================================
-- PandaPOP · Base de datos relacional (MySQL / MariaDB)
-- Proyecto formativo SENA · Tecnología en Análisis y Desarrollo de Software
-- Ficha 3336125 · Envigado, Antioquia
-- Equipo: Adriana García Toro (Backend Lead) · Angie Lorena Montañez Hernández (UX/UI)
--         Blanca Katerine León Pinza (Analista de requisitos)
-- Instructor: Jorge Luis Ballesteros Vargas
-- Generado: 2026-11-01
-- ---------------------------------------------------------------------
-- Compatibilidad: MariaDB 10.11 (XAMPP) y MySQL 8.0+. Motor InnoDB, utf8mb4.
-- Contenido: 47 tablas · 333 columnas · 72 llaves foráneas · 5 vistas
--            · 6 triggers · datos de prueba ficticios (572 filas).
-- Importación en phpMyAdmin: pestaña "Importar" > elegir este archivo > Continuar.
--   (Use un usuario con permiso para crear bases de datos, p. ej. root en XAMPP.)
-- ATENCIÓN: el script elimina y recrea los objetos de la base `pandapop`.
-- Clave de todos los usuarios de prueba: PandaPop#2026  (almacenada como hash bcrypt).
-- Todas las personas, correos (@pandapop.test) y fechas son ficticios.
-- Regla de edad: el niño debe tener de 6 a 14 años (trigger en la sección 6).
-- =====================================================================

/*!40101 SET NAMES utf8mb4 */;
SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS = 0;
SET time_zone = '-05:00';

CREATE DATABASE IF NOT EXISTS `pandapop` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `pandapop`;

-- =====================================================================
-- 1. LIMPIEZA (permite importar el script más de una vez)
-- =====================================================================

DROP VIEW IF EXISTS `vw_ninos`;
DROP VIEW IF EXISTS `vw_puntos_nivel_nino`;
DROP VIEW IF EXISTS `vw_resumen_actividad_nino`;
DROP VIEW IF EXISTS `vw_inactividad_nino`;
DROP VIEW IF EXISTS `vw_alerta_emocion_negativa`;
DROP TABLE IF EXISTS `auditoria`;
DROP TABLE IF EXISTS `preferencia_notificacion`;
DROP TABLE IF EXISTS `notificacion`;
DROP TABLE IF EXISTS `tipo_notificacion`;
DROP TABLE IF EXISTS `mensaje`;
DROP TABLE IF EXISTS `reporte`;
DROP TABLE IF EXISTS `tipo_reporte`;
DROP TABLE IF EXISTS `observacion`;
DROP TABLE IF EXISTS `tipo_observacion`;
DROP TABLE IF EXISTS `registro_emocion`;
DROP TABLE IF EXISTS `emocion`;
DROP TABLE IF EXISTS `nino_recompensa`;
DROP TABLE IF EXISTS `movimiento_puntos`;
DROP TABLE IF EXISTS `recompensa`;
DROP TABLE IF EXISTS `tipo_recompensa`;
DROP TABLE IF EXISTS `regla_puntuacion`;
DROP TABLE IF EXISTS `nivel`;
DROP TABLE IF EXISTS `progreso_nino`;
DROP TABLE IF EXISTS `resultado_actividad`;
DROP TABLE IF EXISTS `asignacion_nino`;
DROP TABLE IF EXISTS `asignacion`;
DROP TABLE IF EXISTS `estado_asignacion`;
DROP TABLE IF EXISTS `plan_terapeutico`;
DROP TABLE IF EXISTS `actividad`;
DROP TABLE IF EXISTS `visualizacion_contenido`;
DROP TABLE IF EXISTS `favorito_contenido`;
DROP TABLE IF EXISTS `contenido_etiqueta`;
DROP TABLE IF EXISTS `etiqueta`;
DROP TABLE IF EXISTS `contenido_multimedia`;
DROP TABLE IF EXISTS `tipo_contenido`;
DROP TABLE IF EXISTS `biblioteca_educativa`;
DROP TABLE IF EXISTS `tipo_actividad`;
DROP TABLE IF EXISTS `modulo_educativo`;
DROP TABLE IF EXISTS `categoria`;
DROP TABLE IF EXISTS `consentimiento_datos`;
DROP TABLE IF EXISTS `vinculo_nino_adulto`;
DROP TABLE IF EXISTS `tipo_vinculo`;
DROP TABLE IF EXISTS `grupo_nino`;
DROP TABLE IF EXISTS `grupo_docente`;
DROP TABLE IF EXISTS `grupo`;
DROP TABLE IF EXISTS `membresia_institucion`;
DROP TABLE IF EXISTS `institucion`;
DROP TABLE IF EXISTS `perfil_profesional`;
DROP TABLE IF EXISTS `perfil_nino`;
DROP TABLE IF EXISTS `usuario_rol`;
DROP TABLE IF EXISTS `usuario`;
DROP TABLE IF EXISTS `rol`;

-- =====================================================================
-- 2. TABLAS (ordenadas por dependencias de llaves foráneas)
-- =====================================================================

-- [M1] Identidad, instituciones y vínculos · HU: HU-001, HU-002
CREATE TABLE `rol` (
  `id_rol` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador del registro del catálogo.',
  `nombre_rol` VARCHAR(30) NOT NULL COMMENT 'Nombre del rol: NINO, ACUDIENTE, DOCENTE, TERAPEUTA o ADMINISTRADOR.',
  `descripcion` VARCHAR(200) NULL DEFAULT NULL COMMENT 'Descripción breve del significado del elemento.',
  `estado` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indicador de registro activo (1) o inactivo (0); permite la baja lógica sin perder trazabilidad.',
  PRIMARY KEY (`id_rol`),
  UNIQUE KEY `uq_rol_nombre_rol` (`nombre_rol`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Roles de la plataforma (control de acceso por rol).';


-- [M1] Identidad, instituciones y vínculos · HU: HU-001, HU-002
CREATE TABLE `usuario` (
  `id_usuario` CHAR(36) NOT NULL DEFAULT (UUID()) COMMENT 'Identificador único universal (UUID) de la cuenta.',
  `nombres` VARCHAR(100) NOT NULL COMMENT 'Nombres de la persona.',
  `apellidos` VARCHAR(100) NOT NULL COMMENT 'Apellidos de la persona.',
  `nombre_usuario` VARCHAR(50) NULL DEFAULT NULL COMMENT 'Alias de acceso, usado por los niños que no tienen correo electrónico.',
  `correo` VARCHAR(150) NULL DEFAULT NULL COMMENT 'Correo electrónico de acceso; obligatorio para adultos y opcional para niños.',
  `clave_hash` VARCHAR(255) NOT NULL COMMENT 'Clave o PIN almacenado como hash (nunca en texto plano).',
  `telefono` VARCHAR(20) NULL DEFAULT NULL COMMENT 'Teléfono de contacto.',
  `idioma` CHAR(2) NOT NULL DEFAULT 'es' COMMENT 'Idioma preferido de la interfaz: es (español) o en (inglés).',
  `correo_verificado` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Indica si el correo fue verificado mediante el enlace enviado (1) o no (0).',
  `fecha_verificacion` DATETIME NULL DEFAULT NULL COMMENT 'Fecha y hora en que se verificó el correo.',
  `ultimo_acceso` DATETIME NULL DEFAULT NULL COMMENT 'Fecha y hora del último inicio de sesión.',
  `estado` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indicador de registro activo (1) o inactivo (0); permite la baja lógica sin perder trazabilidad.',
  `fecha_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creación del registro.',
  `fecha_actualizacion` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la última modificación del registro.',
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `uq_usuario_nombre_usuario` (`nombre_usuario`),
  UNIQUE KEY `uq_usuario_correo` (`correo`),
  CONSTRAINT `chk_usuario_acceso` CHECK (correo IS NOT NULL OR nombre_usuario IS NOT NULL),
  CONSTRAINT `chk_usuario_idioma` CHECK (idioma IN ('es','en'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Cuenta de acceso de cualquier persona de la plataforma (niño, acudiente, docente, terapeuta o administrador). Corresponde a la superclase Usuario del diagrama de clases.';


-- [M1] Identidad, instituciones y vínculos · HU: HU-002
CREATE TABLE `usuario_rol` (
  `id_usuario` CHAR(36) NOT NULL COMMENT 'Usuario al que se asigna el rol.',
  `id_rol` INT UNSIGNED NOT NULL COMMENT 'Rol asignado.',
  `fecha_asignacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora en que se asignó el rol.',
  PRIMARY KEY (`id_usuario`, `id_rol`),
  CONSTRAINT `fk_usuario_rol_id_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_usuario_rol_id_rol` FOREIGN KEY (`id_rol`) REFERENCES `rol` (`id_rol`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Asignación de roles a usuarios (relación N:M); una persona puede ser, por ejemplo, docente y acudiente.';


-- [M1] Identidad, instituciones y vínculos · HU: HU-001
CREATE TABLE `perfil_nino` (
  `id_usuario` CHAR(36) NOT NULL COMMENT 'Identificador del usuario que es niño (llave primaria y foránea).',
  `fecha_nacimiento` DATE NOT NULL COMMENT 'Fecha de nacimiento; la edad (6 a 14 años) se valida con el trigger de la sección 6.',
  `grado` VARCHAR(20) NULL DEFAULT NULL COMMENT 'Grado escolar que cursa (por ejemplo, 3°).',
  `fecha_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creación del registro.',
  `fecha_actualizacion` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la última modificación del registro.',
  PRIMARY KEY (`id_usuario`),
  KEY `idx_perfil_nino_nacimiento` (`fecha_nacimiento`),
  CONSTRAINT `fk_perfil_nino_id_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Datos propios del niño (6 a 14 años). Corresponde a la subclase Niño del diagrama de clases.';


-- [M1] Identidad, instituciones y vínculos · HU: HU-001
CREATE TABLE `perfil_profesional` (
  `id_usuario` CHAR(36) NOT NULL COMMENT 'Identificador del usuario profesional (llave primaria y foránea).',
  `especialidad` VARCHAR(100) NOT NULL COMMENT 'Asignatura (docente) o especialidad clínica (terapeuta).',
  `registro_profesional` VARCHAR(50) NULL DEFAULT NULL COMMENT 'Número de tarjeta o registro profesional, si aplica.',
  `fecha_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creación del registro.',
  `fecha_actualizacion` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la última modificación del registro.',
  PRIMARY KEY (`id_usuario`),
  CONSTRAINT `fk_perfil_profesional_id_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Datos propios del docente o terapeuta. Agrupa las subclases Docente (asignatura) y Terapeuta (especialidad).';


-- [M1] Identidad, instituciones y vínculos · HU: HU-006
CREATE TABLE `institucion` (
  `id_institucion` CHAR(36) NOT NULL DEFAULT (UUID()) COMMENT 'Identificador único de la institución.',
  `nombre` VARCHAR(150) NOT NULL COMMENT 'Nombre oficial de la institución.',
  `tipo_institucion` VARCHAR(30) NOT NULL COMMENT 'Tipo: COLEGIO, CENTRO_TERAPEUTICO u OTRA.',
  `nit` VARCHAR(20) NULL DEFAULT NULL COMMENT 'Número de identificación tributaria.',
  `ciudad` VARCHAR(80) NOT NULL COMMENT 'Ciudad donde opera.',
  `correo_contacto` VARCHAR(150) NULL DEFAULT NULL COMMENT 'Correo de contacto institucional.',
  `telefono` VARCHAR(20) NULL DEFAULT NULL COMMENT 'Teléfono de contacto.',
  `estado` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indicador de registro activo (1) o inactivo (0); permite la baja lógica sin perder trazabilidad.',
  `fecha_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creación del registro.',
  `fecha_actualizacion` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la última modificación del registro.',
  PRIMARY KEY (`id_institucion`),
  UNIQUE KEY `uq_institucion_nit` (`nit`),
  CONSTRAINT `chk_institucion_tipo` CHECK (tipo_institucion IN ('COLEGIO','CENTRO_TERAPEUTICO','OTRA'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Colegio o centro terapéutico que usa la plataforma (modelo multi-institución).';


-- [M1] Identidad, instituciones y vínculos · HU: HU-006
CREATE TABLE `membresia_institucion` (
  `id_membresia` CHAR(36) NOT NULL DEFAULT (UUID()) COMMENT 'Identificador único de la membresía.',
  `id_institucion` CHAR(36) NOT NULL COMMENT 'Institución a la que pertenece.',
  `id_usuario` CHAR(36) NOT NULL COMMENT 'Usuario miembro de la institución.',
  `id_rol` INT UNSIGNED NOT NULL COMMENT 'Rol que cumple dentro de la institución.',
  `fecha_inicio` DATE NOT NULL COMMENT 'Fecha de inicio de la pertenencia.',
  `fecha_fin` DATE NULL DEFAULT NULL COMMENT 'Fecha de finalización de la pertenencia.',
  `estado` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indicador de registro activo (1) o inactivo (0); permite la baja lógica sin perder trazabilidad.',
  PRIMARY KEY (`id_membresia`),
  UNIQUE KEY `uq_membresia` (`id_institucion`, `id_usuario`, `id_rol`),
  CONSTRAINT `fk_membresia_institucion_id_institucion` FOREIGN KEY (`id_institucion`) REFERENCES `institucion` (`id_institucion`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_membresia_institucion_id_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_membresia_institucion_id_rol` FOREIGN KEY (`id_rol`) REFERENCES `rol` (`id_rol`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Pertenencia de usuarios a instituciones con el rol que cumplen allí (N:M).';


-- [M1] Identidad, instituciones y vínculos · HU: HU-006
CREATE TABLE `grupo` (
  `id_grupo` CHAR(36) NOT NULL DEFAULT (UUID()) COMMENT 'Identificador único del grupo.',
  `id_institucion` CHAR(36) NOT NULL COMMENT 'Institución a la que pertenece el grupo.',
  `nombre` VARCHAR(80) NOT NULL COMMENT 'Nombre del grupo (por ejemplo, Tercero A).',
  `grado` VARCHAR(20) NOT NULL COMMENT 'Grado escolar del grupo.',
  `anio_lectivo` SMALLINT UNSIGNED NOT NULL COMMENT 'Año lectivo del grupo.',
  `estado` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indicador de registro activo (1) o inactivo (0); permite la baja lógica sin perder trazabilidad.',
  `fecha_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creación del registro.',
  PRIMARY KEY (`id_grupo`),
  UNIQUE KEY `uq_grupo` (`id_institucion`, `nombre`, `anio_lectivo`),
  CONSTRAINT `fk_grupo_id_institucion` FOREIGN KEY (`id_institucion`) REFERENCES `institucion` (`id_institucion`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Grupo o curso de una institución al que se asignan actividades de forma colectiva.';


-- [M1] Identidad, instituciones y vínculos · HU: HU-006
CREATE TABLE `grupo_docente` (
  `id_grupo` CHAR(36) NOT NULL COMMENT 'Grupo en el que dicta clase.',
  `id_docente` CHAR(36) NOT NULL COMMENT 'Docente que dicta clase.',
  `asignatura` VARCHAR(80) NULL DEFAULT NULL COMMENT 'Asignatura que dicta en el grupo.',
  `es_titular` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Indica si es el director de grupo (1) o no (0).',
  PRIMARY KEY (`id_grupo`, `id_docente`),
  CONSTRAINT `fk_grupo_docente_id_grupo` FOREIGN KEY (`id_grupo`) REFERENCES `grupo` (`id_grupo`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_grupo_docente_id_docente` FOREIGN KEY (`id_docente`) REFERENCES `perfil_profesional` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Docentes que dictan clase en un grupo (N:M).';


-- [M1] Identidad, instituciones y vínculos · HU: HU-006
CREATE TABLE `grupo_nino` (
  `id_grupo` CHAR(36) NOT NULL COMMENT 'Grupo en el que está matriculado.',
  `id_nino` CHAR(36) NOT NULL COMMENT 'Niño matriculado.',
  `fecha_ingreso` DATE NOT NULL COMMENT 'Fecha de ingreso al grupo.',
  `fecha_salida` DATE NULL DEFAULT NULL COMMENT 'Fecha de salida del grupo.',
  `estado` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indicador de registro activo (1) o inactivo (0); permite la baja lógica sin perder trazabilidad.',
  PRIMARY KEY (`id_grupo`, `id_nino`),
  CONSTRAINT `fk_grupo_nino_id_grupo` FOREIGN KEY (`id_grupo`) REFERENCES `grupo` (`id_grupo`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_grupo_nino_id_nino` FOREIGN KEY (`id_nino`) REFERENCES `perfil_nino` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Matrícula de niños en grupos (N:M con historial de ingreso y salida).';


-- [M1] Identidad, instituciones y vínculos · HU: HU-001, HU-007
CREATE TABLE `tipo_vinculo` (
  `id_tipo_vinculo` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador del tipo de vínculo.',
  `nombre` VARCHAR(40) NOT NULL COMMENT 'MADRE, PADRE, TUTOR_LEGAL, ACUDIENTE, DOCENTE o TERAPEUTA.',
  `clase_vinculo` VARCHAR(12) NOT NULL COMMENT 'Clase del vínculo: FAMILIAR o PROFESIONAL.',
  `descripcion` VARCHAR(200) NULL DEFAULT NULL COMMENT 'Descripción del tipo de vínculo.',
  `estado` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indicador de registro activo (1) o inactivo (0); permite la baja lógica sin perder trazabilidad.',
  PRIMARY KEY (`id_tipo_vinculo`),
  UNIQUE KEY `uq_tipo_vinculo_nombre` (`nombre`),
  CONSTRAINT `chk_tipo_vinculo_clase` CHECK (clase_vinculo IN ('FAMILIAR','PROFESIONAL'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tipos de vínculo entre un niño y un adulto (familiar o profesional).';


-- [M1] Identidad, instituciones y vínculos · HU: HU-001, HU-007, HU-012
CREATE TABLE `vinculo_nino_adulto` (
  `id_vinculo` CHAR(36) NOT NULL DEFAULT (UUID()) COMMENT 'Identificador único del vínculo.',
  `id_nino` CHAR(36) NOT NULL COMMENT 'Niño vinculado.',
  `id_adulto` CHAR(36) NOT NULL COMMENT 'Adulto vinculado (acudiente, docente o terapeuta).',
  `id_tipo_vinculo` INT UNSIGNED NOT NULL COMMENT 'Tipo de vínculo.',
  `parentesco` VARCHAR(50) NULL DEFAULT NULL COMMENT 'Parentesco descriptivo (por ejemplo, Abuela materna).',
  `es_principal` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Indica si es el responsable principal del niño (1) o no (0).',
  `puede_ver_progreso` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Permiso para ver el progreso en actividades.',
  `puede_ver_emocional` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para ver el registro emocional.',
  `puede_ver_observaciones` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para ver observaciones compartidas.',
  `puede_recibir_reportes` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para generar o recibir reportes.',
  `fecha_inicio` DATE NOT NULL COMMENT 'Fecha de inicio del vínculo.',
  `fecha_fin` DATE NULL DEFAULT NULL COMMENT 'Fecha de fin del vínculo.',
  `estado` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indicador de registro activo (1) o inactivo (0); permite la baja lógica sin perder trazabilidad.',
  PRIMARY KEY (`id_vinculo`),
  UNIQUE KEY `uq_vinculo` (`id_nino`, `id_adulto`, `id_tipo_vinculo`),
  KEY `idx_vinculo_adulto` (`id_adulto`),
  CONSTRAINT `fk_vinculo_nino_adulto_id_nino` FOREIGN KEY (`id_nino`) REFERENCES `perfil_nino` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_vinculo_nino_adulto_id_adulto` FOREIGN KEY (`id_adulto`) REFERENCES `usuario` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_vinculo_nino_adulto_id_tipo_vinculo` FOREIGN KEY (`id_tipo_vinculo`) REFERENCES `tipo_vinculo` (`id_tipo_vinculo`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Relación entre un niño y los adultos responsables o profesionales que lo acompañan, con los permisos de visualización (un niño puede tener varios).';


-- [M1] Identidad, instituciones y vínculos · HU: HU-001 (RNF04)
CREATE TABLE `consentimiento_datos` (
  `id_consentimiento` CHAR(36) NOT NULL DEFAULT (UUID()) COMMENT 'Identificador único del consentimiento.',
  `id_nino` CHAR(36) NOT NULL COMMENT 'Niño titular de los datos.',
  `id_acudiente` CHAR(36) NOT NULL COMMENT 'Adulto que otorga o revoca el consentimiento.',
  `finalidad` VARCHAR(40) NOT NULL COMMENT 'Finalidad: TRATAMIENTO_DATOS, DATOS_EMOCIONALES o NOTIFICACIONES.',
  `version_politica` VARCHAR(20) NOT NULL COMMENT 'Versión de la política de tratamiento aceptada.',
  `otorgado` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indica si el consentimiento está vigente (1) o fue revocado (0).',
  `medio` VARCHAR(20) NOT NULL COMMENT 'Medio de otorgamiento: CORREO, APP o PRESENCIAL.',
  `fecha_otorgado` DATETIME NOT NULL COMMENT 'Fecha y hora en que se otorgó.',
  `fecha_revocado` DATETIME NULL DEFAULT NULL COMMENT 'Fecha y hora en que se revocó.',
  PRIMARY KEY (`id_consentimiento`),
  KEY `idx_consentimiento_nino` (`id_nino`, `finalidad`),
  CONSTRAINT `fk_consentimiento_datos_id_nino` FOREIGN KEY (`id_nino`) REFERENCES `perfil_nino` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_consentimiento_datos_id_acudiente` FOREIGN KEY (`id_acudiente`) REFERENCES `usuario` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_consent_finalidad` CHECK (finalidad IN ('TRATAMIENTO_DATOS','DATOS_EMOCIONALES','NOTIFICACIONES')),
  CONSTRAINT `chk_consent_medio` CHECK (medio IN ('CORREO','APP','PRESENCIAL'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Consentimiento parental verificable para el tratamiento de datos del menor (Ley 1581 de 2012, COPPA y GDPR-K).';


-- [M2] Catálogo educativo y biblioteca · HU: HU-004
CREATE TABLE `categoria` (
  `id_categoria` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador del registro del catálogo.',
  `nombre` VARCHAR(60) NOT NULL COMMENT 'Nombre de la categoría (Matemáticas, Lenguaje, Ciencias, Emociones).',
  `descripcion` VARCHAR(200) NULL DEFAULT NULL COMMENT 'Descripción breve del significado del elemento.',
  `estado` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indicador de registro activo (1) o inactivo (0); permite la baja lógica sin perder trazabilidad.',
  PRIMARY KEY (`id_categoria`),
  UNIQUE KEY `uq_categoria_nombre` (`nombre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Categorías académicas y emocionales de módulos y contenidos.';


-- [M2] Catálogo educativo y biblioteca · HU: HU-004, HU-005
CREATE TABLE `modulo_educativo` (
  `id_modulo` CHAR(36) NOT NULL DEFAULT (UUID()) COMMENT 'Identificador único del módulo.',
  `id_categoria` INT UNSIGNED NOT NULL COMMENT 'Categoría del módulo.',
  `titulo` VARCHAR(120) NOT NULL COMMENT 'Título del módulo.',
  `descripcion` TEXT NULL DEFAULT NULL COMMENT 'Descripción del contenido del módulo.',
  `nivel_dificultad` TINYINT UNSIGNED NOT NULL COMMENT 'Nivel de dificultad de 1 (básico) a 5 (avanzado).',
  `edad_minima` TINYINT UNSIGNED NOT NULL COMMENT 'Edad mínima recomendada (6 a 14).',
  `edad_maxima` TINYINT UNSIGNED NOT NULL COMMENT 'Edad máxima recomendada (6 a 14).',
  `id_creado_por` CHAR(36) NULL DEFAULT NULL COMMENT 'Usuario que creó el módulo.',
  `estado` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indicador de registro activo (1) o inactivo (0); permite la baja lógica sin perder trazabilidad.',
  `fecha_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creación del registro.',
  `fecha_actualizacion` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la última modificación del registro.',
  PRIMARY KEY (`id_modulo`),
  KEY `idx_modulo_categoria` (`id_categoria`, `edad_minima`, `edad_maxima`),
  CONSTRAINT `fk_modulo_educativo_id_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `categoria` (`id_categoria`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_modulo_educativo_id_creado_por` FOREIGN KEY (`id_creado_por`) REFERENCES `usuario` (`id_usuario`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_modulo_dificultad` CHECK (nivel_dificultad BETWEEN 1 AND 5),
  CONSTRAINT `chk_modulo_edades` CHECK (edad_minima BETWEEN 6 AND 14 AND edad_maxima BETWEEN 6 AND 14 AND edad_minima <= edad_maxima)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Módulo educativo que agrupa actividades por categoría, dificultad y rango de edad (clase MóduloEducativo).';


-- [M2] Catálogo educativo y biblioteca · HU: HU-005
CREATE TABLE `tipo_actividad` (
  `id_tipo_actividad` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador del registro del catálogo.',
  `nombre` VARCHAR(30) NOT NULL COMMENT 'QUIZ, JUEGO, LECTURA, VIDEO o EJERCICIO.',
  `descripcion` VARCHAR(200) NULL DEFAULT NULL COMMENT 'Descripción breve del significado del elemento.',
  `estado` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indicador de registro activo (1) o inactivo (0); permite la baja lógica sin perder trazabilidad.',
  PRIMARY KEY (`id_tipo_actividad`),
  UNIQUE KEY `uq_tipo_actividad_nombre` (`nombre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tipos de actividad (enumeración TipoActividad del diagrama de clases).';


-- [M2] Catálogo educativo y biblioteca · HU: HU-004
CREATE TABLE `biblioteca_educativa` (
  `id_biblioteca` CHAR(36) NOT NULL DEFAULT (UUID()) COMMENT 'Identificador único de la biblioteca.',
  `id_institucion` CHAR(36) NULL DEFAULT NULL COMMENT 'Institución propietaria; NULL indica biblioteca global de PandaPOP.',
  `titulo` VARCHAR(120) NOT NULL COMMENT 'Título de la biblioteca.',
  `descripcion` VARCHAR(300) NULL DEFAULT NULL COMMENT 'Descripción de la biblioteca.',
  `estado` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indicador de registro activo (1) o inactivo (0); permite la baja lógica sin perder trazabilidad.',
  `fecha_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creación del registro.',
  PRIMARY KEY (`id_biblioteca`),
  CONSTRAINT `fk_biblioteca_educativa_id_institucion` FOREIGN KEY (`id_institucion`) REFERENCES `institucion` (`id_institucion`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Biblioteca digital que agrupa contenidos; puede ser global o propia de una institución.';


-- [M2] Catálogo educativo y biblioteca · HU: HU-004, HU-009
CREATE TABLE `tipo_contenido` (
  `id_tipo_contenido` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador del registro del catálogo.',
  `nombre` VARCHAR(30) NOT NULL COMMENT 'VIDEO, PODCAST, LECTURA o IMAGEN.',
  `descripcion` VARCHAR(200) NULL DEFAULT NULL COMMENT 'Descripción breve del significado del elemento.',
  `estado` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indicador de registro activo (1) o inactivo (0); permite la baja lógica sin perder trazabilidad.',
  PRIMARY KEY (`id_tipo_contenido`),
  UNIQUE KEY `uq_tipo_contenido_nombre` (`nombre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tipos de contenido multimedia (enumeración TipoContenido).';


-- [M2] Catálogo educativo y biblioteca · HU: HU-004, HU-009
CREATE TABLE `contenido_multimedia` (
  `id_contenido` CHAR(36) NOT NULL DEFAULT (UUID()) COMMENT 'Identificador único del contenido.',
  `id_biblioteca` CHAR(36) NOT NULL COMMENT 'Biblioteca que agrupa el contenido.',
  `id_categoria` INT UNSIGNED NOT NULL COMMENT 'Categoría del contenido.',
  `id_tipo_contenido` INT UNSIGNED NOT NULL COMMENT 'Tipo de contenido.',
  `titulo` VARCHAR(150) NOT NULL COMMENT 'Título del contenido.',
  `descripcion` VARCHAR(500) NULL DEFAULT NULL COMMENT 'Descripción del contenido.',
  `url_recurso` VARCHAR(500) NOT NULL COMMENT 'Ubicación (URL) del archivo del recurso.',
  `duracion_seg` INT UNSIGNED NULL DEFAULT NULL COMMENT 'Duración en segundos para audio o video.',
  `edad_minima` TINYINT UNSIGNED NOT NULL COMMENT 'Edad mínima recomendada (6 a 14).',
  `edad_maxima` TINYINT UNSIGNED NOT NULL COMMENT 'Edad máxima recomendada (6 a 14).',
  `nivel_dificultad` TINYINT UNSIGNED NULL DEFAULT NULL COMMENT 'Nivel de dificultad de 1 a 5.',
  `id_subido_por` CHAR(36) NULL DEFAULT NULL COMMENT 'Administrador que publicó el contenido.',
  `fecha_publicacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de publicación.',
  `estado` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indicador de registro activo (1) o inactivo (0); permite la baja lógica sin perder trazabilidad.',
  `fecha_actualizacion` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la última modificación del registro.',
  PRIMARY KEY (`id_contenido`),
  KEY `idx_contenido_filtro` (`id_categoria`, `id_tipo_contenido`, `edad_minima`),
  CONSTRAINT `fk_contenido_multimedia_id_biblioteca` FOREIGN KEY (`id_biblioteca`) REFERENCES `biblioteca_educativa` (`id_biblioteca`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_contenido_multimedia_id_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `categoria` (`id_categoria`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_contenido_multimedia_id_tipo_contenido` FOREIGN KEY (`id_tipo_contenido`) REFERENCES `tipo_contenido` (`id_tipo_contenido`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_contenido_multimedia_id_subido_por` FOREIGN KEY (`id_subido_por`) REFERENCES `usuario` (`id_usuario`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_contenido_edades` CHECK (edad_minima BETWEEN 6 AND 14 AND edad_maxima BETWEEN 6 AND 14 AND edad_minima <= edad_maxima)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Recurso multimedia (video, podcast, lectura o imagen) gestionado por el administrador y clasificado por categoría, edad y nivel.';


-- [M2] Catálogo educativo y biblioteca · HU: HU-009
CREATE TABLE `etiqueta` (
  `id_etiqueta` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador de la etiqueta.',
  `nombre` VARCHAR(40) NOT NULL COMMENT 'Texto de la etiqueta.',
  PRIMARY KEY (`id_etiqueta`),
  UNIQUE KEY `uq_etiqueta_nombre` (`nombre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Etiquetas para clasificar contenidos (HU-009).';


-- [M2] Catálogo educativo y biblioteca · HU: HU-009
CREATE TABLE `contenido_etiqueta` (
  `id_contenido` CHAR(36) NOT NULL COMMENT 'Contenido etiquetado.',
  `id_etiqueta` INT UNSIGNED NOT NULL COMMENT 'Etiqueta asignada.',
  PRIMARY KEY (`id_contenido`, `id_etiqueta`),
  CONSTRAINT `fk_contenido_etiqueta_id_contenido` FOREIGN KEY (`id_contenido`) REFERENCES `contenido_multimedia` (`id_contenido`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_contenido_etiqueta_id_etiqueta` FOREIGN KEY (`id_etiqueta`) REFERENCES `etiqueta` (`id_etiqueta`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Relación N:M entre contenidos y etiquetas.';


-- [M2] Catálogo educativo y biblioteca · HU: HU-004
CREATE TABLE `favorito_contenido` (
  `id_nino` CHAR(36) NOT NULL COMMENT 'Niño que marca el favorito.',
  `id_contenido` CHAR(36) NOT NULL COMMENT 'Contenido marcado.',
  `fecha_favorito` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora en que se marcó.',
  PRIMARY KEY (`id_nino`, `id_contenido`),
  CONSTRAINT `fk_favorito_contenido_id_nino` FOREIGN KEY (`id_nino`) REFERENCES `perfil_nino` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_favorito_contenido_id_contenido` FOREIGN KEY (`id_contenido`) REFERENCES `contenido_multimedia` (`id_contenido`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Contenidos marcados como favoritos por un niño.';


-- [M2] Catálogo educativo y biblioteca · HU: HU-004
CREATE TABLE `visualizacion_contenido` (
  `id_visualizacion` CHAR(36) NOT NULL DEFAULT (UUID()) COMMENT 'Identificador único de la visualización.',
  `id_nino` CHAR(36) NOT NULL COMMENT 'Niño que consulta el contenido.',
  `id_contenido` CHAR(36) NOT NULL COMMENT 'Contenido consultado.',
  `fecha_visualizacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la consulta.',
  `segundos_vistos` INT UNSIGNED NULL DEFAULT NULL COMMENT 'Segundos reproducidos o leídos.',
  `completado` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Indica si el niño terminó el contenido (1) o no (0).',
  PRIMARY KEY (`id_visualizacion`),
  KEY `idx_visualizacion_nino` (`id_nino`, `fecha_visualizacion`),
  CONSTRAINT `fk_visualizacion_contenido_id_nino` FOREIGN KEY (`id_nino`) REFERENCES `perfil_nino` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_visualizacion_contenido_id_contenido` FOREIGN KEY (`id_contenido`) REFERENCES `contenido_multimedia` (`id_contenido`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Historial de contenidos vistos por cada niño.';


-- [M2] Catálogo educativo y biblioteca · HU: HU-005, HU-006
CREATE TABLE `actividad` (
  `id_actividad` CHAR(36) NOT NULL DEFAULT (UUID()) COMMENT 'Identificador único de la actividad.',
  `id_modulo` CHAR(36) NOT NULL COMMENT 'Módulo al que pertenece.',
  `id_tipo_actividad` INT UNSIGNED NOT NULL COMMENT 'Tipo de actividad.',
  `titulo` VARCHAR(120) NOT NULL COMMENT 'Título de la actividad.',
  `instrucciones` TEXT NOT NULL COMMENT 'Instrucciones que ve el niño.',
  `puntaje_maximo` INT UNSIGNED NOT NULL COMMENT 'Puntaje máximo alcanzable.',
  `duracion_min` SMALLINT UNSIGNED NOT NULL COMMENT 'Duración estimada en minutos.',
  `max_intentos` TINYINT UNSIGNED NOT NULL DEFAULT 3 COMMENT 'Intentos permitidos antes de mostrar la solución.',
  `pista` TEXT NULL DEFAULT NULL COMMENT 'Pista mostrada cuando el niño falla.',
  `orden` SMALLINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Posición de la actividad dentro del módulo.',
  `id_contenido` CHAR(36) NULL DEFAULT NULL COMMENT 'Recurso multimedia asociado a la actividad.',
  `estado` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indicador de registro activo (1) o inactivo (0); permite la baja lógica sin perder trazabilidad.',
  `fecha_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creación del registro.',
  `fecha_actualizacion` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la última modificación del registro.',
  PRIMARY KEY (`id_actividad`),
  KEY `idx_actividad_modulo` (`id_modulo`, `orden`),
  CONSTRAINT `fk_actividad_id_modulo` FOREIGN KEY (`id_modulo`) REFERENCES `modulo_educativo` (`id_modulo`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_actividad_id_tipo_actividad` FOREIGN KEY (`id_tipo_actividad`) REFERENCES `tipo_actividad` (`id_tipo_actividad`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_actividad_id_contenido` FOREIGN KEY (`id_contenido`) REFERENCES `contenido_multimedia` (`id_contenido`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_actividad_puntaje` CHECK (puntaje_maximo > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Actividad gamificada de un módulo (quiz, juego, lectura, video o ejercicio).';


-- [M3] Asignación, ejecución y progreso · HU: HU-006, HU-012
CREATE TABLE `plan_terapeutico` (
  `id_plan` CHAR(36) NOT NULL DEFAULT (UUID()) COMMENT 'Identificador único del plan.',
  `id_nino` CHAR(36) NOT NULL COMMENT 'Niño al que se dirige el plan.',
  `id_terapeuta` CHAR(36) NOT NULL COMMENT 'Terapeuta responsable.',
  `objetivo` TEXT NOT NULL COMMENT 'Objetivo terapéutico o pedagógico del plan.',
  `fecha_inicio` DATE NOT NULL COMMENT 'Fecha de inicio del plan.',
  `fecha_fin` DATE NULL DEFAULT NULL COMMENT 'Fecha de finalización prevista o real.',
  `estado_plan` VARCHAR(15) NOT NULL DEFAULT 'ACTIVO' COMMENT 'Estado: ACTIVO, PAUSADO o FINALIZADO.',
  `fecha_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creación del registro.',
  `fecha_actualizacion` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la última modificación del registro.',
  PRIMARY KEY (`id_plan`),
  KEY `idx_plan_nino` (`id_nino`, `estado_plan`),
  CONSTRAINT `fk_plan_terapeutico_id_nino` FOREIGN KEY (`id_nino`) REFERENCES `perfil_nino` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_plan_terapeutico_id_terapeuta` FOREIGN KEY (`id_terapeuta`) REFERENCES `perfil_profesional` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_plan_estado` CHECK (estado_plan IN ('ACTIVO','PAUSADO','FINALIZADO')),
  CONSTRAINT `chk_plan_fechas` CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Plan de intervención de un terapeuta para un niño (clase PlanTerapéutico).';


-- [M3] Asignación, ejecución y progreso · HU: HU-006
CREATE TABLE `estado_asignacion` (
  `id_estado_asignacion` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador del estado.',
  `nombre_estado` VARCHAR(30) NOT NULL COMMENT 'PENDIENTE, EN_CURSO, COMPLETADA, VENCIDA o CANCELADA.',
  `es_final` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Indica si es un estado terminal (1) o no (0).',
  `estado` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indicador de registro activo (1) o inactivo (0); permite la baja lógica sin perder trazabilidad.',
  PRIMARY KEY (`id_estado_asignacion`),
  UNIQUE KEY `uq_estado_asignacion_nombre_estado` (`nombre_estado`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Estados de una actividad asignada a un niño.';


-- [M3] Asignación, ejecución y progreso · HU: HU-006
CREATE TABLE `asignacion` (
  `id_asignacion` CHAR(36) NOT NULL DEFAULT (UUID()) COMMENT 'Identificador único de la asignación.',
  `id_actividad` CHAR(36) NOT NULL COMMENT 'Actividad asignada.',
  `id_asignado_por` CHAR(36) NOT NULL COMMENT 'Docente o terapeuta que asigna.',
  `id_grupo` CHAR(36) NULL DEFAULT NULL COMMENT 'Grupo destinatario; NULL si la asignación es individual.',
  `id_plan` CHAR(36) NULL DEFAULT NULL COMMENT 'Plan terapéutico al que responde, si aplica.',
  `fecha_asignacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de asignación.',
  `fecha_limite` DATETIME NULL DEFAULT NULL COMMENT 'Fecha límite de entrega (opcional).',
  `instrucciones` TEXT NULL DEFAULT NULL COMMENT 'Instrucciones adicionales del docente o terapeuta.',
  `estado` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indicador de registro activo (1) o inactivo (0); permite la baja lógica sin perder trazabilidad.',
  PRIMARY KEY (`id_asignacion`),
  KEY `idx_asignacion_actividad` (`id_actividad`),
  KEY `idx_asignacion_asignador` (`id_asignado_por`, `fecha_asignacion`),
  CONSTRAINT `fk_asignacion_id_actividad` FOREIGN KEY (`id_actividad`) REFERENCES `actividad` (`id_actividad`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_asignacion_id_asignado_por` FOREIGN KEY (`id_asignado_por`) REFERENCES `usuario` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_asignacion_id_grupo` FOREIGN KEY (`id_grupo`) REFERENCES `grupo` (`id_grupo`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_asignacion_id_plan` FOREIGN KEY (`id_plan`) REFERENCES `plan_terapeutico` (`id_plan`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Cabecera de la asignación de una actividad por un docente o terapeuta, a un niño o a un grupo (clase Asignación).';


-- [M3] Asignación, ejecución y progreso · HU: HU-006
CREATE TABLE `asignacion_nino` (
  `id_asignacion_nino` CHAR(36) NOT NULL DEFAULT (UUID()) COMMENT 'Identificador único del registro.',
  `id_asignacion` CHAR(36) NOT NULL COMMENT 'Asignación a la que pertenece.',
  `id_nino` CHAR(36) NOT NULL COMMENT 'Niño destinatario.',
  `id_estado_asignacion` INT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Estado de cumplimiento.',
  `fecha_completado` DATETIME NULL DEFAULT NULL COMMENT 'Fecha y hora en que el niño completó la actividad.',
  PRIMARY KEY (`id_asignacion_nino`),
  UNIQUE KEY `uq_asignacion_nino` (`id_asignacion`, `id_nino`),
  KEY `idx_asignacion_nino_nino` (`id_nino`, `id_estado_asignacion`),
  CONSTRAINT `fk_asignacion_nino_id_asignacion` FOREIGN KEY (`id_asignacion`) REFERENCES `asignacion` (`id_asignacion`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_asignacion_nino_id_nino` FOREIGN KEY (`id_nino`) REFERENCES `perfil_nino` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_asignacion_nino_id_estado_asignacion` FOREIGN KEY (`id_estado_asignacion`) REFERENCES `estado_asignacion` (`id_estado_asignacion`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Destinatarios de una asignación y su estado de cumplimiento individual.';


-- [M3] Asignación, ejecución y progreso · HU: HU-005, HU-007
CREATE TABLE `resultado_actividad` (
  `id_resultado` CHAR(36) NOT NULL DEFAULT (UUID()) COMMENT 'Identificador único del resultado.',
  `id_nino` CHAR(36) NOT NULL COMMENT 'Niño que ejecuta la actividad.',
  `id_actividad` CHAR(36) NOT NULL COMMENT 'Actividad ejecutada.',
  `id_asignacion_nino` CHAR(36) NULL DEFAULT NULL COMMENT 'Asignación que originó la ejecución; NULL si fue libre.',
  `puntaje` INT UNSIGNED NOT NULL COMMENT 'Puntaje obtenido.',
  `tiempo_usado_seg` INT UNSIGNED NOT NULL COMMENT 'Tiempo empleado en segundos.',
  `intentos` TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Intentos realizados.',
  `pistas_usadas` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Pistas solicitadas.',
  `completado` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Indica si la actividad fue completada (1) o no (0).',
  `fecha_inicio` DATETIME NOT NULL COMMENT 'Fecha y hora de inicio de la ejecución.',
  `fecha_completado` DATETIME NULL DEFAULT NULL COMMENT 'Fecha y hora de finalización.',
  PRIMARY KEY (`id_resultado`),
  KEY `idx_resultado_nino_fecha` (`id_nino`, `fecha_inicio`),
  KEY `idx_resultado_actividad` (`id_actividad`),
  CONSTRAINT `fk_resultado_actividad_id_nino` FOREIGN KEY (`id_nino`) REFERENCES `perfil_nino` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_resultado_actividad_id_actividad` FOREIGN KEY (`id_actividad`) REFERENCES `actividad` (`id_actividad`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_resultado_actividad_id_asignacion_nino` FOREIGN KEY (`id_asignacion_nino`) REFERENCES `asignacion_nino` (`id_asignacion_nino`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Resultado de cada ejecución de una actividad por un niño (clase ResultadoActividad).';


-- [M3] Asignación, ejecución y progreso · HU: HU-007, HU-008
CREATE TABLE `progreso_nino` (
  `id_progreso` CHAR(36) NOT NULL DEFAULT (UUID()) COMMENT 'Identificador único del consolidado.',
  `id_nino` CHAR(36) NOT NULL COMMENT 'Niño evaluado.',
  `tipo_periodo` VARCHAR(10) NOT NULL COMMENT 'Periodo: SEMANAL, MENSUAL o ANUAL.',
  `fecha_inicio` DATE NOT NULL COMMENT 'Inicio del periodo.',
  `fecha_fin` DATE NOT NULL COMMENT 'Fin del periodo.',
  `actividades_asignadas` SMALLINT UNSIGNED NOT NULL COMMENT 'Actividades asignadas vigentes en el periodo.',
  `actividades_completadas` SMALLINT UNSIGNED NOT NULL COMMENT 'Actividades completadas en el periodo.',
  `porcentaje_cumplimiento` DECIMAL(5,2) NULL DEFAULT NULL COMMENT 'Porcentaje de cumplimiento (0 a 100); NULL si no hubo asignaciones en el periodo.',
  `puntaje_promedio` DECIMAL(6,2) NULL DEFAULT NULL COMMENT 'Puntaje promedio de las actividades completadas.',
  `emociones_registradas` SMALLINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Cantidad de emociones registradas en el periodo.',
  `promedio_valencia_emocional` DECIMAL(4,2) NULL DEFAULT NULL COMMENT 'Promedio de valencia emocional (-1 a 1) del periodo.',
  `observaciones` TEXT NULL DEFAULT NULL COMMENT 'Observaciones del consolidado.',
  `fecha_calculo` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora en que se calculó el consolidado.',
  PRIMARY KEY (`id_progreso`),
  UNIQUE KEY `uq_progreso_periodo` (`id_nino`, `tipo_periodo`, `fecha_inicio`),
  CONSTRAINT `fk_progreso_nino_id_nino` FOREIGN KEY (`id_nino`) REFERENCES `perfil_nino` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_progreso_periodo` CHECK (tipo_periodo IN ('SEMANAL','MENSUAL','ANUAL')),
  CONSTRAINT `chk_progreso_fechas` CHECK (fecha_fin >= fecha_inicio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Consolidado periódico del avance de un niño (clase Progreso): cumplimiento, puntaje y bienestar emocional.';


-- [M4] Gamificación · HU: HU-010
CREATE TABLE `nivel` (
  `id_nivel` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador del nivel.',
  `numero_nivel` TINYINT UNSIGNED NOT NULL COMMENT 'Número ordinal del nivel.',
  `nombre` VARCHAR(50) NOT NULL COMMENT 'Nombre temático del nivel.',
  `puntos_requeridos` INT UNSIGNED NOT NULL COMMENT 'Puntos acumulados necesarios para alcanzar el nivel.',
  `estado` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indicador de registro activo (1) o inactivo (0); permite la baja lógica sin perder trazabilidad.',
  PRIMARY KEY (`id_nivel`),
  UNIQUE KEY `uq_nivel_numero_nivel` (`numero_nivel`),
  UNIQUE KEY `uq_nivel_puntos_requeridos` (`puntos_requeridos`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Niveles del sistema de gamificación y puntos requeridos (configurable por el administrador).';


-- [M4] Gamificación · HU: HU-010
CREATE TABLE `regla_puntuacion` (
  `id_regla` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador de la regla.',
  `codigo` VARCHAR(40) NOT NULL COMMENT 'Código único de la regla.',
  `descripcion` VARCHAR(200) NOT NULL COMMENT 'Descripción de la regla.',
  `evento` VARCHAR(30) NOT NULL COMMENT 'Evento que otorga puntos: ACTIVIDAD_COMPLETADA, RACHA_ACIERTOS o EMOCION_REGISTRADA.',
  `puntos` INT NOT NULL COMMENT 'Puntos otorgados por el evento.',
  `umbral` SMALLINT UNSIGNED NULL DEFAULT NULL COMMENT 'Cantidad mínima requerida (por ejemplo, racha de 3).',
  `id_modificado_por` CHAR(36) NULL DEFAULT NULL COMMENT 'Administrador que modificó la regla por última vez.',
  `estado` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indicador de registro activo (1) o inactivo (0); permite la baja lógica sin perder trazabilidad.',
  `fecha_actualizacion` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la última modificación del registro.',
  PRIMARY KEY (`id_regla`),
  UNIQUE KEY `uq_regla_puntuacion_codigo` (`codigo`),
  CONSTRAINT `fk_regla_puntuacion_id_modificado_por` FOREIGN KEY (`id_modificado_por`) REFERENCES `usuario` (`id_usuario`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_regla_evento` CHECK (evento IN ('ACTIVIDAD_COMPLETADA','RACHA_ACIERTOS','EMOCION_REGISTRADA'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Reglas de puntuación configurables por el administrador.';


-- [M4] Gamificación · HU: HU-010
CREATE TABLE `tipo_recompensa` (
  `id_tipo_recompensa` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador del registro del catálogo.',
  `nombre` VARCHAR(30) NOT NULL COMMENT 'PUNTOS, INSIGNIA, NIVEL o CERTIFICADO.',
  `descripcion` VARCHAR(200) NULL DEFAULT NULL COMMENT 'Descripción breve del significado del elemento.',
  `estado` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indicador de registro activo (1) o inactivo (0); permite la baja lógica sin perder trazabilidad.',
  PRIMARY KEY (`id_tipo_recompensa`),
  UNIQUE KEY `uq_tipo_recompensa_nombre` (`nombre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tipos de recompensa (enumeración TipoRecompensa).';


-- [M4] Gamificación · HU: HU-010
CREATE TABLE `recompensa` (
  `id_recompensa` CHAR(36) NOT NULL DEFAULT (UUID()) COMMENT 'Identificador único de la recompensa.',
  `id_tipo_recompensa` INT UNSIGNED NOT NULL COMMENT 'Tipo de recompensa.',
  `nombre` VARCHAR(80) NOT NULL COMMENT 'Nombre de la recompensa.',
  `descripcion` VARCHAR(255) NULL DEFAULT NULL COMMENT 'Descripción de la recompensa.',
  `valor_puntos` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Valor en puntos asociado.',
  `imagen_url` VARCHAR(500) NULL DEFAULT NULL COMMENT 'Imagen de la insignia o recompensa.',
  `condicion` VARCHAR(255) NOT NULL COMMENT 'Condición para obtenerla, en lenguaje natural.',
  `id_nivel` INT UNSIGNED NULL DEFAULT NULL COMMENT 'Nivel que representa, si es de tipo NIVEL.',
  `estado` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indicador de registro activo (1) o inactivo (0); permite la baja lógica sin perder trazabilidad.',
  `fecha_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creación del registro.',
  PRIMARY KEY (`id_recompensa`),
  CONSTRAINT `fk_recompensa_id_tipo_recompensa` FOREIGN KEY (`id_tipo_recompensa`) REFERENCES `tipo_recompensa` (`id_tipo_recompensa`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_recompensa_id_nivel` FOREIGN KEY (`id_nivel`) REFERENCES `nivel` (`id_nivel`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Recompensas disponibles: puntos, insignias, niveles y certificados (clase Recompensa).';


-- [M4] Gamificación · HU: HU-005, HU-010
CREATE TABLE `movimiento_puntos` (
  `id_movimiento` CHAR(36) NOT NULL DEFAULT (UUID()) COMMENT 'Identificador único del movimiento.',
  `id_nino` CHAR(36) NOT NULL COMMENT 'Niño que recibe los puntos.',
  `id_regla` INT UNSIGNED NULL DEFAULT NULL COMMENT 'Regla aplicada.',
  `id_resultado` CHAR(36) NULL DEFAULT NULL COMMENT 'Resultado de actividad que originó el movimiento.',
  `puntos` INT NOT NULL COMMENT 'Puntos del movimiento (positivo suma, negativo resta).',
  `motivo` VARCHAR(150) NOT NULL COMMENT 'Motivo legible del movimiento.',
  `fecha_movimiento` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora del movimiento.',
  PRIMARY KEY (`id_movimiento`),
  KEY `idx_movimiento_nino` (`id_nino`, `fecha_movimiento`),
  CONSTRAINT `fk_movimiento_puntos_id_nino` FOREIGN KEY (`id_nino`) REFERENCES `perfil_nino` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_movimiento_puntos_id_regla` FOREIGN KEY (`id_regla`) REFERENCES `regla_puntuacion` (`id_regla`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_movimiento_puntos_id_resultado` FOREIGN KEY (`id_resultado`) REFERENCES `resultado_actividad` (`id_resultado`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Libro de movimientos de puntos del niño; el total y el nivel se calculan a partir de aquí.';


-- [M4] Gamificación · HU: HU-007, HU-010
CREATE TABLE `nino_recompensa` (
  `id_nino_recompensa` CHAR(36) NOT NULL DEFAULT (UUID()) COMMENT 'Identificador único del registro.',
  `id_nino` CHAR(36) NOT NULL COMMENT 'Niño que obtiene la recompensa.',
  `id_recompensa` CHAR(36) NOT NULL COMMENT 'Recompensa obtenida.',
  `fecha_obtencion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora en que se obtuvo.',
  PRIMARY KEY (`id_nino_recompensa`),
  UNIQUE KEY `uq_nino_recompensa` (`id_nino`, `id_recompensa`),
  CONSTRAINT `fk_nino_recompensa_id_nino` FOREIGN KEY (`id_nino`) REFERENCES `perfil_nino` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_nino_recompensa_id_recompensa` FOREIGN KEY (`id_recompensa`) REFERENCES `recompensa` (`id_recompensa`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Recompensas obtenidas por cada niño (clase NiñoRecompensa).';


-- [M5] Seguimiento emocional, observaciones y reportes · HU: HU-003
CREATE TABLE `emocion` (
  `id_emocion` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador de la emoción.',
  `nombre` VARCHAR(30) NOT NULL COMMENT 'Nombre de la emoción (Feliz, Tranquilo, Triste, Enojado, Asustado).',
  `icono` VARCHAR(60) NOT NULL COMMENT 'Archivo del ícono o emoji que se muestra al niño.',
  `color_hex` CHAR(7) NOT NULL COMMENT 'Color asociado en formato #RRGGBB.',
  `valencia` TINYINT NOT NULL COMMENT 'Valencia emocional: 1 positiva, 0 neutra o -1 negativa.',
  `estado` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indicador de registro activo (1) o inactivo (0); permite la baja lógica sin perder trazabilidad.',
  PRIMARY KEY (`id_emocion`),
  UNIQUE KEY `uq_emocion_nombre` (`nombre`),
  CONSTRAINT `chk_emocion_valencia` CHECK (valencia IN (-1,0,1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Catálogo de las cinco emociones visuales que el niño puede elegir.';


-- [M5] Seguimiento emocional, observaciones y reportes · HU: HU-003, HU-007, HU-011
CREATE TABLE `registro_emocion` (
  `id_registro_emocion` CHAR(36) NOT NULL DEFAULT (UUID()) COMMENT 'Identificador único del registro.',
  `id_nino` CHAR(36) NOT NULL COMMENT 'Niño que registra la emoción.',
  `id_emocion` INT UNSIGNED NOT NULL COMMENT 'Emoción elegida.',
  `frase` VARCHAR(255) NULL DEFAULT NULL COMMENT 'Frase corta opcional escrita por el niño.',
  `fecha_registro` DATE NOT NULL COMMENT 'Día del registro.',
  `hora_registro` TIME NOT NULL COMMENT 'Hora del registro.',
  PRIMARY KEY (`id_registro_emocion`),
  UNIQUE KEY `uq_registro_emocion_dia` (`id_nino`, `fecha_registro`),
  KEY `idx_registro_emocion_emocion` (`id_emocion`),
  CONSTRAINT `fk_registro_emocion_id_nino` FOREIGN KEY (`id_nino`) REFERENCES `perfil_nino` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_registro_emocion_id_emocion` FOREIGN KEY (`id_emocion`) REFERENCES `emocion` (`id_emocion`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Registro diario de la emoción del niño, con frase opcional (un registro por día).';


-- [M5] Seguimiento emocional, observaciones y reportes · HU: HU-012
CREATE TABLE `tipo_observacion` (
  `id_tipo_observacion` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador del registro del catálogo.',
  `nombre` VARCHAR(30) NOT NULL COMMENT 'PEDAGOGICA, CONDUCTUAL, EMOCIONAL o ACADEMICA.',
  `descripcion` VARCHAR(200) NULL DEFAULT NULL COMMENT 'Descripción breve del significado del elemento.',
  `estado` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indicador de registro activo (1) o inactivo (0); permite la baja lógica sin perder trazabilidad.',
  PRIMARY KEY (`id_tipo_observacion`),
  UNIQUE KEY `uq_tipo_observacion_nombre` (`nombre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tipos de observación (enumeración TipoObservación).';


-- [M5] Seguimiento emocional, observaciones y reportes · HU: HU-012
CREATE TABLE `observacion` (
  `id_observacion` CHAR(36) NOT NULL DEFAULT (UUID()) COMMENT 'Identificador único de la observación.',
  `id_nino` CHAR(36) NOT NULL COMMENT 'Niño observado.',
  `id_profesional` CHAR(36) NOT NULL COMMENT 'Docente o terapeuta autor.',
  `id_tipo_observacion` INT UNSIGNED NOT NULL COMMENT 'Tipo de observación.',
  `descripcion` TEXT NOT NULL COMMENT 'Texto libre de la observación.',
  `es_privada` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1 = visible solo para el equipo profesional; 0 = compartida con acudientes autorizados.',
  `fecha_observacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la observación.',
  `estado` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indicador de registro activo (1) o inactivo (0); permite la baja lógica sin perder trazabilidad.',
  `fecha_actualizacion` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la última modificación del registro.',
  PRIMARY KEY (`id_observacion`),
  KEY `idx_observacion_nino` (`id_nino`, `fecha_observacion`),
  CONSTRAINT `fk_observacion_id_nino` FOREIGN KEY (`id_nino`) REFERENCES `perfil_nino` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_observacion_id_profesional` FOREIGN KEY (`id_profesional`) REFERENCES `perfil_profesional` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_observacion_id_tipo_observacion` FOREIGN KEY (`id_tipo_observacion`) REFERENCES `tipo_observacion` (`id_tipo_observacion`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Observación cualitativa de un docente o terapeuta sobre un niño (clase Observación).';


-- [M5] Seguimiento emocional, observaciones y reportes · HU: HU-008
CREATE TABLE `tipo_reporte` (
  `id_tipo_reporte` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador del registro del catálogo.',
  `nombre` VARCHAR(30) NOT NULL COMMENT 'ACADEMICO, EMOCIONAL, INTEGRAL o CONDUCTUAL.',
  `descripcion` VARCHAR(200) NULL DEFAULT NULL COMMENT 'Descripción breve del significado del elemento.',
  `estado` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indicador de registro activo (1) o inactivo (0); permite la baja lógica sin perder trazabilidad.',
  PRIMARY KEY (`id_tipo_reporte`),
  UNIQUE KEY `uq_tipo_reporte_nombre` (`nombre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tipos de reporte (enumeración TipoReporte).';


-- [M5] Seguimiento emocional, observaciones y reportes · HU: HU-008
CREATE TABLE `reporte` (
  `id_reporte` CHAR(36) NOT NULL DEFAULT (UUID()) COMMENT 'Identificador único del reporte.',
  `id_nino` CHAR(36) NOT NULL COMMENT 'Niño al que corresponde.',
  `id_tipo_reporte` INT UNSIGNED NOT NULL COMMENT 'Tipo de reporte.',
  `id_generado_por` CHAR(36) NOT NULL COMMENT 'Usuario que genera el reporte.',
  `periodo_inicio` DATE NOT NULL COMMENT 'Inicio del periodo reportado.',
  `periodo_fin` DATE NOT NULL COMMENT 'Fin del periodo reportado.',
  `contenido_json` JSON NULL DEFAULT NULL COMMENT 'Contenido estructurado del reporte (gráficos, logros y observaciones).',
  `url_pdf` VARCHAR(500) NULL DEFAULT NULL COMMENT 'Ubicación del PDF generado.',
  `es_automatico` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 si fue generado por programación automática.',
  `fecha_generacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de generación.',
  PRIMARY KEY (`id_reporte`),
  KEY `idx_reporte_nino` (`id_nino`, `periodo_fin`),
  CONSTRAINT `fk_reporte_id_nino` FOREIGN KEY (`id_nino`) REFERENCES `perfil_nino` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_reporte_id_tipo_reporte` FOREIGN KEY (`id_tipo_reporte`) REFERENCES `tipo_reporte` (`id_tipo_reporte`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_reporte_id_generado_por` FOREIGN KEY (`id_generado_por`) REFERENCES `usuario` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_reporte_periodo` CHECK (periodo_fin >= periodo_inicio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Reporte automatizado en PDF del progreso académico y emocional de un niño (clase Reporte).';


-- [M6] Comunicación y trazabilidad · HU: Comunicación segura
CREATE TABLE `mensaje` (
  `id_mensaje` CHAR(36) NOT NULL DEFAULT (UUID()) COMMENT 'Identificador único del mensaje.',
  `id_remitente` CHAR(36) NOT NULL COMMENT 'Usuario que envía.',
  `id_destinatario` CHAR(36) NOT NULL COMMENT 'Usuario que recibe.',
  `id_nino` CHAR(36) NULL DEFAULT NULL COMMENT 'Niño sobre quien trata la conversación (contexto).',
  `contenido` TEXT NOT NULL COMMENT 'Texto del mensaje (la capa de aplicación lo cifra, RNF08).',
  `fecha_envio` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de envío.',
  `leido` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Indica si fue leído (1) o no (0).',
  `fecha_lectura` DATETIME NULL DEFAULT NULL COMMENT 'Fecha y hora de lectura.',
  `eliminado_remitente` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'El remitente lo ocultó de su bandeja.',
  `eliminado_destinatario` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'El destinatario lo ocultó de su bandeja.',
  PRIMARY KEY (`id_mensaje`),
  KEY `idx_mensaje_destinatario` (`id_destinatario`, `leido`),
  KEY `idx_mensaje_remitente` (`id_remitente`, `fecha_envio`),
  CONSTRAINT `fk_mensaje_id_remitente` FOREIGN KEY (`id_remitente`) REFERENCES `usuario` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_mensaje_id_destinatario` FOREIGN KEY (`id_destinatario`) REFERENCES `usuario` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_mensaje_id_nino` FOREIGN KEY (`id_nino`) REFERENCES `perfil_nino` (`id_usuario`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Mensajería interna segura entre acudientes y profesionales (clase Mensaje).';


-- [M6] Comunicación y trazabilidad · HU: HU-011
CREATE TABLE `tipo_notificacion` (
  `id_tipo_notificacion` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador del registro del catálogo.',
  `nombre` VARCHAR(40) NOT NULL COMMENT 'ACTIVIDAD_COMPLETADA, EMOCION_NEGATIVA_CONSECUTIVA, INACTIVIDAD, ASIGNACION_NUEVA, REPORTE_DISPONIBLE, MENSAJE_NUEVO o LOGRO_OBTENIDO.',
  `descripcion` VARCHAR(200) NULL DEFAULT NULL COMMENT 'Descripción breve del significado del elemento.',
  `estado` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indicador de registro activo (1) o inactivo (0); permite la baja lógica sin perder trazabilidad.',
  PRIMARY KEY (`id_tipo_notificacion`),
  UNIQUE KEY `uq_tipo_notificacion_nombre` (`nombre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tipos de notificación inteligente.';


-- [M6] Comunicación y trazabilidad · HU: HU-011
CREATE TABLE `notificacion` (
  `id_notificacion` CHAR(36) NOT NULL DEFAULT (UUID()) COMMENT 'Identificador único de la notificación.',
  `id_usuario` CHAR(36) NOT NULL COMMENT 'Usuario destinatario.',
  `id_nino` CHAR(36) NULL DEFAULT NULL COMMENT 'Niño sobre quien trata el evento.',
  `id_tipo_notificacion` INT UNSIGNED NOT NULL COMMENT 'Tipo de notificación.',
  `titulo` VARCHAR(120) NOT NULL COMMENT 'Título breve.',
  `mensaje` VARCHAR(500) NOT NULL COMMENT 'Texto de la notificación.',
  `url_accion` VARCHAR(255) NULL DEFAULT NULL COMMENT 'Ruta de la aplicación a la que lleva la notificación.',
  `leida` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Indica si fue leída (1) o no (0).',
  `enviada_correo` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Indica si además se envió por correo.',
  `fecha_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creación.',
  `fecha_lectura` DATETIME NULL DEFAULT NULL COMMENT 'Fecha y hora de lectura.',
  PRIMARY KEY (`id_notificacion`),
  KEY `idx_notificacion_usuario` (`id_usuario`, `leida`, `fecha_creacion`),
  CONSTRAINT `fk_notificacion_id_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_notificacion_id_nino` FOREIGN KEY (`id_nino`) REFERENCES `perfil_nino` (`id_usuario`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_notificacion_id_tipo_notificacion` FOREIGN KEY (`id_tipo_notificacion`) REFERENCES `tipo_notificacion` (`id_tipo_notificacion`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Notificaciones generadas por eventos relevantes (clase Notificación).';


-- [M6] Comunicación y trazabilidad · HU: HU-011
CREATE TABLE `preferencia_notificacion` (
  `id_usuario` CHAR(36) NOT NULL COMMENT 'Usuario que configura.',
  `id_tipo_notificacion` INT UNSIGNED NOT NULL COMMENT 'Tipo de notificación configurado.',
  `canal_app` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Recibir dentro de la aplicación.',
  `canal_correo` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Recibir por correo electrónico.',
  `fecha_actualizacion` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la última modificación del registro.',
  PRIMARY KEY (`id_usuario`, `id_tipo_notificacion`),
  CONSTRAINT `fk_preferencia_notificacion_id_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_preferencia_notificacion_id_tipo_notificacion` FOREIGN KEY (`id_tipo_notificacion`) REFERENCES `tipo_notificacion` (`id_tipo_notificacion`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Preferencias de cada usuario sobre qué eventos notificar y por qué canal.';


-- [M6] Comunicación y trazabilidad · HU: RNF03, RNF04, RNF08
CREATE TABLE `auditoria` (
  `id_auditoria` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador consecutivo de la auditoría.',
  `id_usuario` CHAR(36) NULL DEFAULT NULL COMMENT 'Usuario que realizó la acción.',
  `id_nino` CHAR(36) NULL DEFAULT NULL COMMENT 'Niño cuyos datos fueron afectados o consultados.',
  `entidad` VARCHAR(50) NOT NULL COMMENT 'Tabla o recurso afectado.',
  `id_registro` CHAR(36) NULL DEFAULT NULL COMMENT 'Identificador del registro afectado.',
  `accion` VARCHAR(20) NOT NULL COMMENT 'Acción: CREAR, ACTUALIZAR, ELIMINAR, CONSULTAR, EXPORTAR o LOGIN.',
  `campo_modificado` VARCHAR(50) NULL DEFAULT NULL COMMENT 'Campo modificado.',
  `valor_anterior` TEXT NULL DEFAULT NULL COMMENT 'Valor antes del cambio.',
  `valor_nuevo` TEXT NULL DEFAULT NULL COMMENT 'Valor después del cambio.',
  `ip_origen` VARCHAR(45) NULL DEFAULT NULL COMMENT 'Dirección IP de origen (IPv4 o IPv6).',
  `observacion` VARCHAR(255) NULL DEFAULT NULL COMMENT 'Comentario adicional.',
  `fecha_accion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la acción.',
  PRIMARY KEY (`id_auditoria`),
  KEY `idx_auditoria_nino` (`id_nino`, `fecha_accion`),
  KEY `idx_auditoria_usuario` (`id_usuario`, `fecha_accion`),
  CONSTRAINT `fk_auditoria_id_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_auditoria_id_nino` FOREIGN KEY (`id_nino`) REFERENCES `perfil_nino` (`id_usuario`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_auditoria_accion` CHECK (accion IN ('CREAR','ACTUALIZAR','ELIMINAR','CONSULTAR','EXPORTAR','LOGIN'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bitácora de trazabilidad de accesos y cambios sobre datos de menores (Ley 1581 de 2012).';

-- =====================================================================
-- 3. VISTAS
-- =====================================================================

-- Niños con su edad calculada y la validación de la regla de 6 a 14 años.
CREATE OR REPLACE VIEW `vw_ninos` AS
SELECT u.`id_usuario` AS `id_nino`, u.`nombres`, u.`apellidos`, p.`fecha_nacimiento`,
       TIMESTAMPDIFF(YEAR, p.`fecha_nacimiento`, CURDATE()) AS `edad`,
       (TIMESTAMPDIFF(YEAR, p.`fecha_nacimiento`, CURDATE()) BETWEEN 6 AND 14) AS `edad_valida`,
       p.`grado`, u.`estado`
FROM `perfil_nino` p
JOIN `usuario` u ON u.`id_usuario` = p.`id_usuario`;

-- Puntos acumulados y nivel actual de cada niño, calculados desde el libro de movimientos.
CREATE OR REPLACE VIEW `vw_puntos_nivel_nino` AS
SELECT t.`id_nino`, t.`puntos_totales`, n.`numero_nivel`, n.`nombre` AS `nivel`
FROM (
  SELECT p.`id_usuario` AS `id_nino`, CAST(COALESCE(SUM(m.`puntos`), 0) AS SIGNED) AS `puntos_totales`
  FROM `perfil_nino` p
  LEFT JOIN `movimiento_puntos` m ON m.`id_nino` = p.`id_usuario`
  GROUP BY p.`id_usuario`
) t
JOIN `nivel` n ON n.`id_nivel` = (
  SELECT n2.`id_nivel` FROM `nivel` n2
  WHERE n2.`estado` = 1 AND n2.`puntos_requeridos` <= t.`puntos_totales`
  ORDER BY n2.`puntos_requeridos` DESC LIMIT 1
);

-- Cumplimiento de asignaciones, puntaje promedio y última actividad de cada niño.
CREATE OR REPLACE VIEW `vw_resumen_actividad_nino` AS
SELECT p.`id_usuario` AS `id_nino`,
  (SELECT COUNT(*) FROM `asignacion_nino` an
     JOIN `estado_asignacion` e ON e.`id_estado_asignacion` = an.`id_estado_asignacion`
    WHERE an.`id_nino` = p.`id_usuario` AND e.`nombre_estado` <> 'CANCELADA') AS `asignaciones`,
  (SELECT COUNT(*) FROM `asignacion_nino` an
     JOIN `estado_asignacion` e ON e.`id_estado_asignacion` = an.`id_estado_asignacion`
    WHERE an.`id_nino` = p.`id_usuario` AND e.`nombre_estado` = 'COMPLETADA') AS `asignaciones_completadas`,
  (SELECT ROUND(100 * SUM(e.`nombre_estado` = 'COMPLETADA') / COUNT(*), 2) FROM `asignacion_nino` an
     JOIN `estado_asignacion` e ON e.`id_estado_asignacion` = an.`id_estado_asignacion`
    WHERE an.`id_nino` = p.`id_usuario` AND e.`nombre_estado` <> 'CANCELADA') AS `porcentaje_cumplimiento`,
  (SELECT COUNT(*) FROM `resultado_actividad` r
    WHERE r.`id_nino` = p.`id_usuario` AND r.`completado` = 1) AS `actividades_completadas`,
  (SELECT ROUND(AVG(100 * r.`puntaje` / a.`puntaje_maximo`), 2) FROM `resultado_actividad` r
     JOIN `actividad` a ON a.`id_actividad` = r.`id_actividad`
    WHERE r.`id_nino` = p.`id_usuario` AND r.`completado` = 1) AS `puntaje_promedio_pct`,
  (SELECT MAX(r.`fecha_inicio`) FROM `resultado_actividad` r WHERE r.`id_nino` = p.`id_usuario`) AS `ultima_actividad`
FROM `perfil_nino` p;

-- Días sin actividad de cada niño y bandera de alerta (3 o más días, HU-011).
CREATE OR REPLACE VIEW `vw_inactividad_nino` AS
SELECT v.`id_nino`, v.`nombres`, v.`apellidos`, x.`ultima_actividad`,
       DATEDIFF(CURDATE(), DATE(x.`ultima_actividad`)) AS `dias_sin_actividad`,
       (x.`ultima_actividad` IS NULL OR DATEDIFF(CURDATE(), DATE(x.`ultima_actividad`)) >= 3) AS `requiere_alerta`
FROM `vw_ninos` v
LEFT JOIN (
  SELECT `id_nino`, MAX(`fecha_inicio`) AS `ultima_actividad`
  FROM `resultado_actividad` GROUP BY `id_nino`
) x ON x.`id_nino` = v.`id_nino`
WHERE v.`estado` = 1;

-- Días en que un niño completa 3 registros consecutivos de emociones negativas (HU-011).
CREATE OR REPLACE VIEW `vw_alerta_emocion_negativa` AS
SELECT r0.`id_nino`, DATE_SUB(r0.`fecha_registro`, INTERVAL 2 DAY) AS `inicio_racha`,
       r0.`fecha_registro` AS `fin_racha`, e0.`nombre` AS `ultima_emocion`
FROM `registro_emocion` r0
JOIN `emocion` e0 ON e0.`id_emocion` = r0.`id_emocion` AND e0.`valencia` < 0
JOIN `registro_emocion` r1 ON r1.`id_nino` = r0.`id_nino` AND r1.`fecha_registro` = DATE_SUB(r0.`fecha_registro`, INTERVAL 1 DAY)
JOIN `emocion` e1 ON e1.`id_emocion` = r1.`id_emocion` AND e1.`valencia` < 0
JOIN `registro_emocion` r2 ON r2.`id_nino` = r0.`id_nino` AND r2.`fecha_registro` = DATE_SUB(r0.`fecha_registro`, INTERVAL 2 DAY)
JOIN `emocion` e2 ON e2.`id_emocion` = r2.`id_emocion` AND e2.`valencia` < 0;

-- =====================================================================
-- 4. DATOS DE PRUEBA (ficticios; fecha de referencia: domingo 01/11/2026)
-- =====================================================================

-- rol (5 filas)
INSERT INTO `rol` (`id_rol`, `nombre_rol`, `descripcion`) VALUES
  (1, 'NINO', 'Niño de 6 a 14 años: realiza actividades y registra emociones.'),
  (2, 'ACUDIENTE', 'Madre, padre, tutor o familiar responsable del niño.'),
  (3, 'DOCENTE', 'Docente que asigna actividades y observa el progreso en el aula.'),
  (4, 'TERAPEUTA', 'Profesional psicopedagógico que diseña planes de intervención.'),
  (5, 'ADMINISTRADOR', 'Gestiona usuarios, contenidos, reglas de puntuación y reportes globales.');


-- usuario (21 filas)
INSERT INTO `usuario` (`id_usuario`, `nombres`, `apellidos`, `nombre_usuario`, `correo`, `clave_hash`, `telefono`, `idioma`, `correo_verificado`, `fecha_verificacion`, `ultimo_acceso`) VALUES
  ('00000001-0000-4000-8000-000000000001', 'Laura', 'Vélez Montoya', NULL, 'laura.velez@pandapop.test', '$2b$10$MUAGChNtgGcIAobnzxZh1u/WFdORBuey6pWheP.P0ZXuRuOz83j6K', '3001100001', 'es', 1, '2026-01-20 09:00:00', '2026-11-01 07:50:00'),
  ('00000001-0000-4000-8000-000000000002', 'Sandra Milena', 'Giraldo Ríos', NULL, 'sandra.giraldo@pandapop.test', '$2b$10$MUAGChNtgGcIAobnzxZh1u/WFdORBuey6pWheP.P0ZXuRuOz83j6K', '3001100002', 'es', 1, '2026-01-20 09:00:00', '2026-10-31 07:45:00'),
  ('00000001-0000-4000-8000-000000000003', 'Andrés Felipe', 'Zapata Cano', NULL, 'andres.zapata@pandapop.test', '$2b$10$MUAGChNtgGcIAobnzxZh1u/WFdORBuey6pWheP.P0ZXuRuOz83j6K', '3001100003', 'es', 1, '2026-01-20 09:00:00', '2026-11-01 09:00:00'),
  ('00000001-0000-4000-8000-000000000004', 'Paula Andrea', 'Henao Mejía', NULL, 'paula.henao@pandapop.test', '$2b$10$MUAGChNtgGcIAobnzxZh1u/WFdORBuey6pWheP.P0ZXuRuOz83j6K', '3001100004', 'es', 1, '2026-01-20 09:00:00', '2026-10-29 07:50:00'),
  ('00000001-0000-4000-8000-000000000005', 'Mariana', 'Escobar Londoño', NULL, 'mariana.escobar@pandapop.test', '$2b$10$MUAGChNtgGcIAobnzxZh1u/WFdORBuey6pWheP.P0ZXuRuOz83j6K', '3001100005', 'es', 1, '2026-01-20 09:00:00', '2026-11-01 08:10:00'),
  ('00000001-0000-4000-8000-000000000006', 'Camilo', 'Arango Peña', NULL, 'camilo.arango@pandapop.test', '$2b$10$MUAGChNtgGcIAobnzxZh1u/WFdORBuey6pWheP.P0ZXuRuOz83j6K', '3001100006', 'es', 1, '2026-01-20 09:00:00', '2026-10-30 09:30:00'),
  ('00000001-0000-4000-8000-000000000007', 'Carolina', 'Durán Ospina', NULL, 'carolina.duran@pandapop.test', '$2b$10$MUAGChNtgGcIAobnzxZh1u/WFdORBuey6pWheP.P0ZXuRuOz83j6K', '3001100007', 'es', 1, '2026-01-20 09:00:00', '2026-10-31 18:00:00'),
  ('00000001-0000-4000-8000-000000000008', 'Julián', 'Mesa Arboleda', NULL, 'julian.mesa@pandapop.test', '$2b$10$MUAGChNtgGcIAobnzxZh1u/WFdORBuey6pWheP.P0ZXuRuOz83j6K', '3001100008', 'es', 1, '2026-01-20 09:00:00', '2026-10-27 21:10:00'),
  ('00000001-0000-4000-8000-000000000009', 'Luz Marina', 'Cardona Ruiz', NULL, 'luz.cardona@pandapop.test', '$2b$10$MUAGChNtgGcIAobnzxZh1u/WFdORBuey6pWheP.P0ZXuRuOz83j6K', '3001100009', 'es', 1, '2026-01-20 09:00:00', '2026-10-20 10:15:00'),
  ('00000001-0000-4000-8000-000000000010', 'Diana Patricia', 'Toro Salazar', NULL, 'diana.toro@pandapop.test', '$2b$10$MUAGChNtgGcIAobnzxZh1u/WFdORBuey6pWheP.P0ZXuRuOz83j6K', '3001100010', 'es', 1, '2026-01-20 09:00:00', '2026-10-30 19:40:00'),
  ('00000001-0000-4000-8000-000000000011', 'Esteban', 'Rendón Gil', NULL, 'esteban.rendon@pandapop.test', '$2b$10$MUAGChNtgGcIAobnzxZh1u/WFdORBuey6pWheP.P0ZXuRuOz83j6K', '3001100011', 'es', 1, '2026-01-20 09:00:00', '2026-10-28 17:20:00'),
  ('00000001-0000-4000-8000-000000000012', 'Gloria Inés', 'Pérez Vargas', NULL, 'gloria.perez@pandapop.test', '$2b$10$MUAGChNtgGcIAobnzxZh1u/WFdORBuey6pWheP.P0ZXuRuOz83j6K', '3001100012', 'es', 1, '2026-01-20 09:00:00', '2026-11-01 07:35:00'),
  ('00000001-0000-4000-8000-000000000013', 'Ricardo', 'Salazar Mora', NULL, 'ricardo.salazar@pandapop.test', '$2b$10$MUAGChNtgGcIAobnzxZh1u/WFdORBuey6pWheP.P0ZXuRuOz83j6K', '3001100013', 'es', 1, '2026-01-20 09:00:00', '2026-10-29 19:00:00'),
  ('00000001-0000-4000-8000-000000000014', 'Sofía', 'Mesa Durán', 'sofia.mesa', NULL, '$2b$10$MUAGChNtgGcIAobnzxZh1u/WFdORBuey6pWheP.P0ZXuRuOz83j6K', NULL, 'es', 0, NULL, '2026-11-01 10:05:00'),
  ('00000001-0000-4000-8000-000000000015', 'Tomás', 'Pérez Vargas', 'tomas.perez', NULL, '$2b$10$MUAGChNtgGcIAobnzxZh1u/WFdORBuey6pWheP.P0ZXuRuOz83j6K', NULL, 'es', 0, NULL, '2026-10-22 16:30:00'),
  ('00000001-0000-4000-8000-000000000016', 'Mateo', 'Mesa Durán', 'mateo.mesa', NULL, '$2b$10$MUAGChNtgGcIAobnzxZh1u/WFdORBuey6pWheP.P0ZXuRuOz83j6K', NULL, 'es', 0, NULL, '2026-10-31 16:20:00'),
  ('00000001-0000-4000-8000-000000000017', 'Valentina', 'Cardona Pérez', 'valentina.cardona', NULL, '$2b$10$MUAGChNtgGcIAobnzxZh1u/WFdORBuey6pWheP.P0ZXuRuOz83j6K', NULL, 'es', 0, NULL, '2026-11-01 09:30:00'),
  ('00000001-0000-4000-8000-000000000018', 'Samuel', 'Rendón Toro', 'samuel.rendon', NULL, '$2b$10$MUAGChNtgGcIAobnzxZh1u/WFdORBuey6pWheP.P0ZXuRuOz83j6K', NULL, 'es', 0, NULL, '2026-11-01 11:10:00'),
  ('00000001-0000-4000-8000-000000000019', 'Emilia', 'Rendón Toro', 'emilia.rendon', NULL, '$2b$10$MUAGChNtgGcIAobnzxZh1u/WFdORBuey6pWheP.P0ZXuRuOz83j6K', NULL, 'es', 0, NULL, '2026-11-01 11:20:00'),
  ('00000001-0000-4000-8000-000000000020', 'Juan David', 'Pérez Vargas', 'juandavid.perez', NULL, '$2b$10$MUAGChNtgGcIAobnzxZh1u/WFdORBuey6pWheP.P0ZXuRuOz83j6K', NULL, 'es', 0, NULL, '2026-11-01 12:00:00'),
  ('00000001-0000-4000-8000-000000000021', 'Isabella', 'Salazar Mora', 'isabella.salazar', 'isabella.salazar@pandapop.test', '$2b$10$MUAGChNtgGcIAobnzxZh1u/WFdORBuey6pWheP.P0ZXuRuOz83j6K', NULL, 'es', 1, '2026-01-20 09:00:00', '2026-10-31 16:10:00');


-- usuario_rol (21 filas)
INSERT INTO `usuario_rol` (`id_usuario`, `id_rol`, `fecha_asignacion`) VALUES
  ('00000001-0000-4000-8000-000000000001', 5, '2026-01-20 09:00:00'),
  ('00000001-0000-4000-8000-000000000002', 3, '2026-01-20 09:00:00'),
  ('00000001-0000-4000-8000-000000000003', 3, '2026-01-20 09:00:00'),
  ('00000001-0000-4000-8000-000000000004', 3, '2026-01-20 09:00:00'),
  ('00000001-0000-4000-8000-000000000005', 4, '2026-01-20 09:00:00'),
  ('00000001-0000-4000-8000-000000000006', 4, '2026-01-20 09:00:00'),
  ('00000001-0000-4000-8000-000000000007', 2, '2026-01-20 09:00:00'),
  ('00000001-0000-4000-8000-000000000008', 2, '2026-01-20 09:00:00'),
  ('00000001-0000-4000-8000-000000000009', 2, '2026-01-20 09:00:00'),
  ('00000001-0000-4000-8000-000000000010', 2, '2026-01-20 09:00:00'),
  ('00000001-0000-4000-8000-000000000011', 2, '2026-01-20 09:00:00'),
  ('00000001-0000-4000-8000-000000000012', 2, '2026-01-20 09:00:00'),
  ('00000001-0000-4000-8000-000000000013', 2, '2026-01-20 09:00:00'),
  ('00000001-0000-4000-8000-000000000014', 1, '2026-01-20 09:00:00'),
  ('00000001-0000-4000-8000-000000000015', 1, '2026-01-20 09:00:00'),
  ('00000001-0000-4000-8000-000000000016', 1, '2026-01-20 09:00:00'),
  ('00000001-0000-4000-8000-000000000017', 1, '2026-01-20 09:00:00'),
  ('00000001-0000-4000-8000-000000000018', 1, '2026-01-20 09:00:00'),
  ('00000001-0000-4000-8000-000000000019', 1, '2026-01-20 09:00:00'),
  ('00000001-0000-4000-8000-000000000020', 1, '2026-01-20 09:00:00'),
  ('00000001-0000-4000-8000-000000000021', 1, '2026-01-20 09:00:00');


-- perfil_nino (8 filas)
INSERT INTO `perfil_nino` (`id_usuario`, `fecha_nacimiento`, `grado`) VALUES
  ('00000001-0000-4000-8000-000000000014', '2020-03-15', '1°'),
  ('00000001-0000-4000-8000-000000000015', '2019-09-08', '1°'),
  ('00000001-0000-4000-8000-000000000016', '2018-08-02', '3°'),
  ('00000001-0000-4000-8000-000000000017', '2017-06-11', '3°'),
  ('00000001-0000-4000-8000-000000000018', '2016-09-30', '5°'),
  ('00000001-0000-4000-8000-000000000019', '2015-04-05', '5°'),
  ('00000001-0000-4000-8000-000000000020', '2014-02-19', '7°'),
  ('00000001-0000-4000-8000-000000000021', '2012-12-24', '7°');


-- perfil_profesional (5 filas)
INSERT INTO `perfil_profesional` (`id_usuario`, `especialidad`, `registro_profesional`) VALUES
  ('00000001-0000-4000-8000-000000000002', 'Matemáticas', NULL),
  ('00000001-0000-4000-8000-000000000003', 'Lenguaje', NULL),
  ('00000001-0000-4000-8000-000000000004', 'Ciencias naturales', NULL),
  ('00000001-0000-4000-8000-000000000005', 'Psicopedagogía', 'TP-0001-FIC'),
  ('00000001-0000-4000-8000-000000000006', 'Psicología infantil', 'TP-0002-FIC');


-- institucion (2 filas)
INSERT INTO `institucion` (`id_institucion`, `nombre`, `tipo_institucion`, `nit`, `ciudad`, `correo_contacto`, `telefono`) VALUES
  ('00000002-0000-4000-8000-000000000001', 'Colegio Aurora del Valle', 'COLEGIO', '900000001-1', 'Envigado', 'contacto@aurora.pandapop.test', '6040000001'),
  ('00000002-0000-4000-8000-000000000002', 'Centro Terapéutico Luz de Bambú', 'CENTRO_TERAPEUTICO', '900000002-2', 'Medellín', 'contacto@luzdebambu.pandapop.test', '6040000002');


-- membresia_institucion (19 filas)
INSERT INTO `membresia_institucion` (`id_membresia`, `id_institucion`, `id_usuario`, `id_rol`, `fecha_inicio`, `fecha_fin`) VALUES
  ('00000004-0000-4000-8000-000000000001', '00000002-0000-4000-8000-000000000001', '00000001-0000-4000-8000-000000000001', 5, '2026-01-12', NULL),
  ('00000004-0000-4000-8000-000000000002', '00000002-0000-4000-8000-000000000002', '00000001-0000-4000-8000-000000000001', 5, '2026-01-12', NULL),
  ('00000004-0000-4000-8000-000000000003', '00000002-0000-4000-8000-000000000001', '00000001-0000-4000-8000-000000000002', 3, '2026-01-26', NULL),
  ('00000004-0000-4000-8000-000000000004', '00000002-0000-4000-8000-000000000001', '00000001-0000-4000-8000-000000000003', 3, '2026-01-26', NULL),
  ('00000004-0000-4000-8000-000000000005', '00000002-0000-4000-8000-000000000001', '00000001-0000-4000-8000-000000000004', 3, '2026-01-26', NULL),
  ('00000004-0000-4000-8000-000000000006', '00000002-0000-4000-8000-000000000002', '00000001-0000-4000-8000-000000000005', 4, '2026-03-02', NULL),
  ('00000004-0000-4000-8000-000000000007', '00000002-0000-4000-8000-000000000002', '00000001-0000-4000-8000-000000000006', 4, '2026-03-02', NULL),
  ('00000004-0000-4000-8000-000000000008', '00000002-0000-4000-8000-000000000001', '00000001-0000-4000-8000-000000000014', 1, '2026-01-26', NULL),
  ('00000004-0000-4000-8000-000000000009', '00000002-0000-4000-8000-000000000001', '00000001-0000-4000-8000-000000000015', 1, '2026-01-26', NULL),
  ('00000004-0000-4000-8000-000000000010', '00000002-0000-4000-8000-000000000001', '00000001-0000-4000-8000-000000000016', 1, '2026-01-26', NULL),
  ('00000004-0000-4000-8000-000000000011', '00000002-0000-4000-8000-000000000001', '00000001-0000-4000-8000-000000000017', 1, '2026-01-26', NULL),
  ('00000004-0000-4000-8000-000000000012', '00000002-0000-4000-8000-000000000001', '00000001-0000-4000-8000-000000000018', 1, '2026-01-26', NULL),
  ('00000004-0000-4000-8000-000000000013', '00000002-0000-4000-8000-000000000001', '00000001-0000-4000-8000-000000000019', 1, '2026-01-26', NULL),
  ('00000004-0000-4000-8000-000000000014', '00000002-0000-4000-8000-000000000001', '00000001-0000-4000-8000-000000000020', 1, '2026-01-26', NULL),
  ('00000004-0000-4000-8000-000000000015', '00000002-0000-4000-8000-000000000001', '00000001-0000-4000-8000-000000000021', 1, '2026-01-26', NULL),
  ('00000004-0000-4000-8000-000000000016', '00000002-0000-4000-8000-000000000002', '00000001-0000-4000-8000-000000000015', 1, '2026-03-02', NULL),
  ('00000004-0000-4000-8000-000000000017', '00000002-0000-4000-8000-000000000002', '00000001-0000-4000-8000-000000000017', 1, '2026-03-02', NULL),
  ('00000004-0000-4000-8000-000000000018', '00000002-0000-4000-8000-000000000002', '00000001-0000-4000-8000-000000000019', 1, '2026-03-02', NULL),
  ('00000004-0000-4000-8000-000000000019', '00000002-0000-4000-8000-000000000002', '00000001-0000-4000-8000-000000000021', 1, '2026-03-02', NULL);


-- grupo (4 filas)
INSERT INTO `grupo` (`id_grupo`, `id_institucion`, `nombre`, `grado`, `anio_lectivo`) VALUES
  ('00000003-0000-4000-8000-000000000001', '00000002-0000-4000-8000-000000000001', 'Primero A', '1°', 2026),
  ('00000003-0000-4000-8000-000000000002', '00000002-0000-4000-8000-000000000001', 'Tercero A', '3°', 2026),
  ('00000003-0000-4000-8000-000000000003', '00000002-0000-4000-8000-000000000001', 'Quinto B', '5°', 2026),
  ('00000003-0000-4000-8000-000000000004', '00000002-0000-4000-8000-000000000001', 'Séptimo A', '7°', 2026);


-- grupo_docente (8 filas)
INSERT INTO `grupo_docente` (`id_grupo`, `id_docente`, `asignatura`, `es_titular`) VALUES
  ('00000003-0000-4000-8000-000000000001', '00000001-0000-4000-8000-000000000002', 'Matemáticas', 1),
  ('00000003-0000-4000-8000-000000000001', '00000001-0000-4000-8000-000000000003', 'Lenguaje', 0),
  ('00000003-0000-4000-8000-000000000002', '00000001-0000-4000-8000-000000000003', 'Lenguaje', 1),
  ('00000003-0000-4000-8000-000000000002', '00000001-0000-4000-8000-000000000002', 'Matemáticas', 0),
  ('00000003-0000-4000-8000-000000000003', '00000001-0000-4000-8000-000000000004', 'Ciencias naturales', 1),
  ('00000003-0000-4000-8000-000000000003', '00000001-0000-4000-8000-000000000002', 'Matemáticas', 0),
  ('00000003-0000-4000-8000-000000000004', '00000001-0000-4000-8000-000000000004', 'Ciencias naturales', 1),
  ('00000003-0000-4000-8000-000000000004', '00000001-0000-4000-8000-000000000003', 'Lenguaje', 0);


-- grupo_nino (8 filas)
INSERT INTO `grupo_nino` (`id_grupo`, `id_nino`, `fecha_ingreso`, `fecha_salida`) VALUES
  ('00000003-0000-4000-8000-000000000001', '00000001-0000-4000-8000-000000000014', '2026-01-26', NULL),
  ('00000003-0000-4000-8000-000000000001', '00000001-0000-4000-8000-000000000015', '2026-01-26', NULL),
  ('00000003-0000-4000-8000-000000000002', '00000001-0000-4000-8000-000000000016', '2026-01-26', NULL),
  ('00000003-0000-4000-8000-000000000002', '00000001-0000-4000-8000-000000000017', '2026-01-26', NULL),
  ('00000003-0000-4000-8000-000000000003', '00000001-0000-4000-8000-000000000018', '2026-01-26', NULL),
  ('00000003-0000-4000-8000-000000000003', '00000001-0000-4000-8000-000000000019', '2026-01-26', NULL),
  ('00000003-0000-4000-8000-000000000004', '00000001-0000-4000-8000-000000000020', '2026-01-26', NULL),
  ('00000003-0000-4000-8000-000000000004', '00000001-0000-4000-8000-000000000021', '2026-01-26', NULL);


-- tipo_vinculo (6 filas)
INSERT INTO `tipo_vinculo` (`id_tipo_vinculo`, `nombre`, `clase_vinculo`, `descripcion`) VALUES
  (1, 'MADRE', 'FAMILIAR', 'Madre biológica o adoptiva.'),
  (2, 'PADRE', 'FAMILIAR', 'Padre biológico o adoptivo.'),
  (3, 'TUTOR_LEGAL', 'FAMILIAR', 'Persona con la tutela legal del menor.'),
  (4, 'ACUDIENTE', 'FAMILIAR', 'Familiar o persona autorizada que acompaña al niño.'),
  (5, 'DOCENTE', 'PROFESIONAL', 'Docente que atiende al niño en el colegio.'),
  (6, 'TERAPEUTA', 'PROFESIONAL', 'Terapeuta psicopedagógico del niño.');


-- vinculo_nino_adulto (25 filas)
INSERT INTO `vinculo_nino_adulto` (`id_vinculo`, `id_nino`, `id_adulto`, `id_tipo_vinculo`, `parentesco`, `es_principal`, `puede_ver_progreso`, `puede_ver_emocional`, `puede_ver_observaciones`, `puede_recibir_reportes`, `fecha_inicio`, `fecha_fin`) VALUES
  ('00000005-0000-4000-8000-000000000001', '00000001-0000-4000-8000-000000000014', '00000001-0000-4000-8000-000000000007', 1, 'Madre', 1, 1, 1, 1, 1, '2026-01-20', NULL),
  ('00000005-0000-4000-8000-000000000002', '00000001-0000-4000-8000-000000000014', '00000001-0000-4000-8000-000000000008', 2, 'Padre', 0, 1, 0, 0, 1, '2026-01-20', NULL),
  ('00000005-0000-4000-8000-000000000003', '00000001-0000-4000-8000-000000000016', '00000001-0000-4000-8000-000000000007', 1, 'Madre', 1, 1, 1, 1, 1, '2026-01-20', NULL),
  ('00000005-0000-4000-8000-000000000004', '00000001-0000-4000-8000-000000000016', '00000001-0000-4000-8000-000000000008', 2, 'Padre', 0, 1, 0, 0, 1, '2026-01-20', NULL),
  ('00000005-0000-4000-8000-000000000005', '00000001-0000-4000-8000-000000000015', '00000001-0000-4000-8000-000000000012', 1, 'Madre', 1, 1, 1, 1, 1, '2026-01-20', NULL),
  ('00000005-0000-4000-8000-000000000006', '00000001-0000-4000-8000-000000000020', '00000001-0000-4000-8000-000000000012', 1, 'Madre', 1, 1, 1, 1, 1, '2026-01-20', NULL),
  ('00000005-0000-4000-8000-000000000007', '00000001-0000-4000-8000-000000000017', '00000001-0000-4000-8000-000000000012', 1, 'Madre', 1, 1, 1, 1, 1, '2026-01-20', NULL),
  ('00000005-0000-4000-8000-000000000008', '00000001-0000-4000-8000-000000000017', '00000001-0000-4000-8000-000000000009', 4, 'Abuela paterna', 0, 1, 0, 0, 0, '2026-01-20', NULL),
  ('00000005-0000-4000-8000-000000000009', '00000001-0000-4000-8000-000000000018', '00000001-0000-4000-8000-000000000010', 1, 'Madre', 1, 1, 1, 1, 1, '2026-01-20', NULL),
  ('00000005-0000-4000-8000-000000000010', '00000001-0000-4000-8000-000000000018', '00000001-0000-4000-8000-000000000011', 2, 'Padre', 0, 1, 1, 1, 1, '2026-01-20', NULL),
  ('00000005-0000-4000-8000-000000000011', '00000001-0000-4000-8000-000000000019', '00000001-0000-4000-8000-000000000010', 1, 'Madre', 1, 1, 1, 1, 1, '2026-01-20', NULL),
  ('00000005-0000-4000-8000-000000000012', '00000001-0000-4000-8000-000000000019', '00000001-0000-4000-8000-000000000011', 2, 'Padre', 0, 1, 1, 1, 1, '2026-01-20', NULL),
  ('00000005-0000-4000-8000-000000000013', '00000001-0000-4000-8000-000000000021', '00000001-0000-4000-8000-000000000013', 3, 'Tío materno', 1, 1, 1, 1, 1, '2026-01-20', NULL),
  ('00000005-0000-4000-8000-000000000014', '00000001-0000-4000-8000-000000000014', '00000001-0000-4000-8000-000000000002', 5, 'Docente de aula', 0, 1, 1, 1, 1, '2026-01-26', NULL),
  ('00000005-0000-4000-8000-000000000015', '00000001-0000-4000-8000-000000000015', '00000001-0000-4000-8000-000000000002', 5, 'Docente de aula', 0, 1, 1, 1, 1, '2026-01-26', NULL),
  ('00000005-0000-4000-8000-000000000016', '00000001-0000-4000-8000-000000000016', '00000001-0000-4000-8000-000000000003', 5, 'Docente de aula', 0, 1, 1, 1, 1, '2026-01-26', NULL),
  ('00000005-0000-4000-8000-000000000017', '00000001-0000-4000-8000-000000000017', '00000001-0000-4000-8000-000000000003', 5, 'Docente de aula', 0, 1, 1, 1, 1, '2026-01-26', NULL),
  ('00000005-0000-4000-8000-000000000018', '00000001-0000-4000-8000-000000000018', '00000001-0000-4000-8000-000000000004', 5, 'Docente de aula', 0, 1, 1, 1, 1, '2026-01-26', NULL),
  ('00000005-0000-4000-8000-000000000019', '00000001-0000-4000-8000-000000000019', '00000001-0000-4000-8000-000000000004', 5, 'Docente de aula', 0, 1, 1, 1, 1, '2026-01-26', NULL),
  ('00000005-0000-4000-8000-000000000020', '00000001-0000-4000-8000-000000000020', '00000001-0000-4000-8000-000000000004', 5, 'Docente de aula', 0, 1, 1, 1, 1, '2026-01-26', NULL),
  ('00000005-0000-4000-8000-000000000021', '00000001-0000-4000-8000-000000000021', '00000001-0000-4000-8000-000000000004', 5, 'Docente de aula', 0, 1, 1, 1, 1, '2026-01-26', NULL),
  ('00000005-0000-4000-8000-000000000022', '00000001-0000-4000-8000-000000000015', '00000001-0000-4000-8000-000000000005', 6, 'Terapeuta', 0, 1, 1, 1, 1, '2026-03-02', NULL),
  ('00000005-0000-4000-8000-000000000023', '00000001-0000-4000-8000-000000000017', '00000001-0000-4000-8000-000000000005', 6, 'Terapeuta', 0, 1, 1, 1, 1, '2026-03-02', NULL),
  ('00000005-0000-4000-8000-000000000024', '00000001-0000-4000-8000-000000000019', '00000001-0000-4000-8000-000000000006', 6, 'Terapeuta', 0, 1, 1, 1, 1, '2026-03-02', NULL),
  ('00000005-0000-4000-8000-000000000025', '00000001-0000-4000-8000-000000000021', '00000001-0000-4000-8000-000000000006', 6, 'Terapeuta', 0, 1, 1, 1, 1, '2026-03-02', NULL);


-- consentimiento_datos (24 filas)
INSERT INTO `consentimiento_datos` (`id_consentimiento`, `id_nino`, `id_acudiente`, `finalidad`, `version_politica`, `otorgado`, `medio`, `fecha_otorgado`, `fecha_revocado`) VALUES
  ('00000006-0000-4000-8000-000000000001', '00000001-0000-4000-8000-000000000014', '00000001-0000-4000-8000-000000000007', 'TRATAMIENTO_DATOS', 'v1.0', 1, 'APP', '2026-01-20 10:00:00', NULL),
  ('00000006-0000-4000-8000-000000000002', '00000001-0000-4000-8000-000000000014', '00000001-0000-4000-8000-000000000007', 'DATOS_EMOCIONALES', 'v1.0', 1, 'APP', '2026-01-20 10:00:00', NULL),
  ('00000006-0000-4000-8000-000000000003', '00000001-0000-4000-8000-000000000014', '00000001-0000-4000-8000-000000000007', 'NOTIFICACIONES', 'v1.0', 1, 'APP', '2026-01-20 10:00:00', NULL),
  ('00000006-0000-4000-8000-000000000004', '00000001-0000-4000-8000-000000000015', '00000001-0000-4000-8000-000000000012', 'TRATAMIENTO_DATOS', 'v1.0', 1, 'PRESENCIAL', '2026-01-20 10:00:00', NULL),
  ('00000006-0000-4000-8000-000000000005', '00000001-0000-4000-8000-000000000015', '00000001-0000-4000-8000-000000000012', 'DATOS_EMOCIONALES', 'v1.0', 1, 'PRESENCIAL', '2026-01-20 10:00:00', NULL),
  ('00000006-0000-4000-8000-000000000006', '00000001-0000-4000-8000-000000000015', '00000001-0000-4000-8000-000000000012', 'NOTIFICACIONES', 'v1.0', 1, 'PRESENCIAL', '2026-01-20 10:00:00', NULL),
  ('00000006-0000-4000-8000-000000000007', '00000001-0000-4000-8000-000000000016', '00000001-0000-4000-8000-000000000007', 'TRATAMIENTO_DATOS', 'v1.0', 1, 'APP', '2026-01-20 10:00:00', NULL),
  ('00000006-0000-4000-8000-000000000008', '00000001-0000-4000-8000-000000000016', '00000001-0000-4000-8000-000000000007', 'DATOS_EMOCIONALES', 'v1.0', 1, 'APP', '2026-01-20 10:00:00', NULL),
  ('00000006-0000-4000-8000-000000000009', '00000001-0000-4000-8000-000000000016', '00000001-0000-4000-8000-000000000007', 'NOTIFICACIONES', 'v1.0', 1, 'APP', '2026-01-20 10:00:00', NULL),
  ('00000006-0000-4000-8000-000000000010', '00000001-0000-4000-8000-000000000017', '00000001-0000-4000-8000-000000000012', 'TRATAMIENTO_DATOS', 'v1.0', 1, 'PRESENCIAL', '2026-01-20 10:00:00', NULL),
  ('00000006-0000-4000-8000-000000000011', '00000001-0000-4000-8000-000000000017', '00000001-0000-4000-8000-000000000012', 'DATOS_EMOCIONALES', 'v1.0', 1, 'PRESENCIAL', '2026-01-20 10:00:00', NULL),
  ('00000006-0000-4000-8000-000000000012', '00000001-0000-4000-8000-000000000017', '00000001-0000-4000-8000-000000000012', 'NOTIFICACIONES', 'v1.0', 1, 'PRESENCIAL', '2026-01-20 10:00:00', NULL),
  ('00000006-0000-4000-8000-000000000013', '00000001-0000-4000-8000-000000000018', '00000001-0000-4000-8000-000000000010', 'TRATAMIENTO_DATOS', 'v1.0', 1, 'CORREO', '2026-01-20 10:00:00', NULL),
  ('00000006-0000-4000-8000-000000000014', '00000001-0000-4000-8000-000000000018', '00000001-0000-4000-8000-000000000010', 'DATOS_EMOCIONALES', 'v1.0', 1, 'CORREO', '2026-01-20 10:00:00', NULL),
  ('00000006-0000-4000-8000-000000000015', '00000001-0000-4000-8000-000000000018', '00000001-0000-4000-8000-000000000010', 'NOTIFICACIONES', 'v1.0', 1, 'CORREO', '2026-01-20 10:00:00', NULL),
  ('00000006-0000-4000-8000-000000000016', '00000001-0000-4000-8000-000000000019', '00000001-0000-4000-8000-000000000010', 'TRATAMIENTO_DATOS', 'v1.0', 1, 'CORREO', '2026-01-20 10:00:00', NULL),
  ('00000006-0000-4000-8000-000000000017', '00000001-0000-4000-8000-000000000019', '00000001-0000-4000-8000-000000000010', 'DATOS_EMOCIONALES', 'v1.0', 1, 'CORREO', '2026-01-20 10:00:00', NULL),
  ('00000006-0000-4000-8000-000000000018', '00000001-0000-4000-8000-000000000019', '00000001-0000-4000-8000-000000000010', 'NOTIFICACIONES', 'v1.0', 1, 'CORREO', '2026-01-20 10:00:00', NULL),
  ('00000006-0000-4000-8000-000000000019', '00000001-0000-4000-8000-000000000020', '00000001-0000-4000-8000-000000000012', 'TRATAMIENTO_DATOS', 'v1.0', 1, 'PRESENCIAL', '2026-01-20 10:00:00', NULL),
  ('00000006-0000-4000-8000-000000000020', '00000001-0000-4000-8000-000000000020', '00000001-0000-4000-8000-000000000012', 'DATOS_EMOCIONALES', 'v1.0', 1, 'PRESENCIAL', '2026-01-20 10:00:00', NULL),
  ('00000006-0000-4000-8000-000000000021', '00000001-0000-4000-8000-000000000020', '00000001-0000-4000-8000-000000000012', 'NOTIFICACIONES', 'v1.0', 1, 'PRESENCIAL', '2026-01-20 10:00:00', NULL),
  ('00000006-0000-4000-8000-000000000022', '00000001-0000-4000-8000-000000000021', '00000001-0000-4000-8000-000000000013', 'TRATAMIENTO_DATOS', 'v1.0', 1, 'PRESENCIAL', '2026-01-20 10:00:00', NULL),
  ('00000006-0000-4000-8000-000000000023', '00000001-0000-4000-8000-000000000021', '00000001-0000-4000-8000-000000000013', 'DATOS_EMOCIONALES', 'v1.0', 1, 'PRESENCIAL', '2026-01-20 10:00:00', NULL),
  ('00000006-0000-4000-8000-000000000024', '00000001-0000-4000-8000-000000000021', '00000001-0000-4000-8000-000000000013', 'NOTIFICACIONES', 'v1.0', 0, 'PRESENCIAL', '2026-01-20 10:00:00', '2026-10-15 09:30:00');


-- categoria (4 filas)
INSERT INTO `categoria` (`id_categoria`, `nombre`, `descripcion`) VALUES
  (1, 'Matemáticas', 'Números, operaciones y pensamiento lógico.'),
  (2, 'Lenguaje', 'Lectura, escritura y comprensión.'),
  (3, 'Ciencias', 'Naturaleza, cuerpo humano y experimentos.'),
  (4, 'Emociones', 'Reconocimiento y regulación emocional.');


-- modulo_educativo (7 filas)
INSERT INTO `modulo_educativo` (`id_modulo`, `id_categoria`, `titulo`, `descripcion`, `nivel_dificultad`, `edad_minima`, `edad_maxima`, `id_creado_por`) VALUES
  ('00000007-0000-4000-8000-000000000001', 1, 'Sumas y restas en el bosque de bambú', 'Operaciones básicas con apoyo visual.', 1, 6, 8, '00000001-0000-4000-8000-000000000002'),
  ('00000007-0000-4000-8000-000000000002', 1, 'Multiplicación y fracciones', 'Tablas de multiplicar y primeras fracciones.', 3, 8, 12, '00000001-0000-4000-8000-000000000002'),
  ('00000007-0000-4000-8000-000000000003', 2, 'Lectura de cuentos y comprensión', 'Lectura guiada y preguntas de comprensión.', 2, 6, 12, '00000001-0000-4000-8000-000000000003'),
  ('00000007-0000-4000-8000-000000000004', 2, 'Redacción y ortografía creativa', 'Escritura de textos cortos y ortografía.', 4, 10, 14, '00000001-0000-4000-8000-000000000003'),
  ('00000007-0000-4000-8000-000000000005', 3, 'Explorando el cuerpo y los ecosistemas', 'Cuerpo humano, agua y ecosistemas.', 3, 8, 14, '00000001-0000-4000-8000-000000000004'),
  ('00000007-0000-4000-8000-000000000006', 4, 'Conociendo mis emociones', 'Identificar y nombrar lo que siento.', 1, 6, 10, '00000001-0000-4000-8000-000000000005'),
  ('00000007-0000-4000-8000-000000000007', 4, 'Estrategias de calma y autoestima', 'Respiración, calma y pensamientos positivos.', 3, 9, 14, '00000001-0000-4000-8000-000000000005');


-- tipo_actividad (5 filas)
INSERT INTO `tipo_actividad` (`id_tipo_actividad`, `nombre`, `descripcion`) VALUES
  (1, 'QUIZ', 'Preguntas de selección con retroalimentación inmediata.'),
  (2, 'JUEGO', 'Mecánica de juego con puntaje.'),
  (3, 'LECTURA', 'Lectura guiada con preguntas.'),
  (4, 'VIDEO', 'Video corto con verificación de comprensión.'),
  (5, 'EJERCICIO', 'Práctica guiada paso a paso.');


-- biblioteca_educativa (2 filas)
INSERT INTO `biblioteca_educativa` (`id_biblioteca`, `id_institucion`, `titulo`, `descripcion`) VALUES
  ('00000009-0000-4000-8000-000000000001', NULL, 'Biblioteca PandaPOP', 'Contenidos globales disponibles para todas las instituciones.'),
  ('00000009-0000-4000-8000-000000000002', '00000002-0000-4000-8000-000000000001', 'Biblioteca Colegio Aurora', 'Recursos propios del Colegio Aurora del Valle.');


-- tipo_contenido (4 filas)
INSERT INTO `tipo_contenido` (`id_tipo_contenido`, `nombre`, `descripcion`) VALUES
  (1, 'VIDEO', 'Recurso multimedia de tipo video.'),
  (2, 'PODCAST', 'Recurso multimedia de tipo podcast.'),
  (3, 'LECTURA', 'Recurso multimedia de tipo lectura.'),
  (4, 'IMAGEN', 'Recurso multimedia de tipo imagen.');


-- contenido_multimedia (8 filas)
INSERT INTO `contenido_multimedia` (`id_contenido`, `id_biblioteca`, `id_categoria`, `id_tipo_contenido`, `titulo`, `descripcion`, `url_recurso`, `duracion_seg`, `edad_minima`, `edad_maxima`, `nivel_dificultad`, `id_subido_por`, `fecha_publicacion`) VALUES
  ('00000010-0000-4000-8000-000000000001', '00000009-0000-4000-8000-000000000001', 3, 1, 'El ciclo del agua', 'Cómo viaja el agua entre el mar, las nubes y la lluvia.', '/media/videos/ciclo-agua.mp4', 180, 8, 12, 2, '00000001-0000-4000-8000-000000000001', '2026-10-02 10:00:00'),
  ('00000010-0000-4000-8000-000000000002', '00000009-0000-4000-8000-000000000001', 2, 2, 'Cuentos del bosque de bambú', 'Historias cortas narradas por Pandi.', '/media/audio/cuentos-bambu.mp3', 420, 6, 9, 1, '00000001-0000-4000-8000-000000000001', '2026-10-02 10:00:00'),
  ('00000010-0000-4000-8000-000000000003', '00000009-0000-4000-8000-000000000002', 2, 3, 'El panda que no sabía dormir', 'Cuento ilustrado sobre las rutinas de descanso.', '/media/lecturas/panda-dormir.pdf', NULL, 6, 10, 1, '00000001-0000-4000-8000-000000000001', '2026-10-02 10:00:00'),
  ('00000010-0000-4000-8000-000000000004', '00000009-0000-4000-8000-000000000001', 4, 4, 'Termómetro de emociones', 'Lámina para identificar cómo me siento.', '/media/imagenes/termometro.png', NULL, 6, 14, 1, '00000001-0000-4000-8000-000000000001', '2026-10-02 10:00:00'),
  ('00000010-0000-4000-8000-000000000005', '00000009-0000-4000-8000-000000000001', 4, 1, 'Respira como un panda', 'Ejercicio guiado de respiración en 5 pasos.', '/media/videos/respira-panda.mp4', 150, 6, 14, 1, '00000001-0000-4000-8000-000000000001', '2026-10-02 10:00:00'),
  ('00000010-0000-4000-8000-000000000006', '00000009-0000-4000-8000-000000000002', 1, 3, 'Mi primer cuento de fracciones', 'La pizza del panda dividida en partes iguales.', '/media/lecturas/fracciones.pdf', NULL, 8, 12, 3, '00000001-0000-4000-8000-000000000001', '2026-10-02 10:00:00'),
  ('00000010-0000-4000-8000-000000000007', '00000009-0000-4000-8000-000000000001', 3, 2, 'Ciencia en 5 minutos', 'Preguntas curiosas respondidas por científicos.', '/media/audio/ciencia-5min.mp3', 300, 10, 14, 3, '00000001-0000-4000-8000-000000000001', '2026-10-02 10:00:00'),
  ('00000010-0000-4000-8000-000000000008', '00000009-0000-4000-8000-000000000002', 1, 1, 'Tablas del 2 al 5 cantando', 'Canción para memorizar las tablas.', '/media/videos/tablas-cancion.mp4', 240, 6, 9, 2, '00000001-0000-4000-8000-000000000001', '2026-10-02 10:00:00');


-- etiqueta (6 filas)
INSERT INTO `etiqueta` (`id_etiqueta`, `nombre`) VALUES
  (1, 'naturaleza'),
  (2, 'relajación'),
  (3, 'cuentos'),
  (4, 'canciones'),
  (5, 'números'),
  (6, 'emociones');


-- contenido_etiqueta (11 filas)
INSERT INTO `contenido_etiqueta` (`id_contenido`, `id_etiqueta`) VALUES
  ('00000010-0000-4000-8000-000000000001', 1),
  ('00000010-0000-4000-8000-000000000002', 3),
  ('00000010-0000-4000-8000-000000000002', 1),
  ('00000010-0000-4000-8000-000000000003', 3),
  ('00000010-0000-4000-8000-000000000004', 6),
  ('00000010-0000-4000-8000-000000000005', 2),
  ('00000010-0000-4000-8000-000000000005', 6),
  ('00000010-0000-4000-8000-000000000006', 5),
  ('00000010-0000-4000-8000-000000000007', 1),
  ('00000010-0000-4000-8000-000000000008', 5),
  ('00000010-0000-4000-8000-000000000008', 4);


-- favorito_contenido (8 filas)
INSERT INTO `favorito_contenido` (`id_nino`, `id_contenido`, `fecha_favorito`) VALUES
  ('00000001-0000-4000-8000-000000000014', '00000010-0000-4000-8000-000000000002', '2026-10-24 17:05:00'),
  ('00000001-0000-4000-8000-000000000014', '00000010-0000-4000-8000-000000000008', '2026-10-26 16:10:00'),
  ('00000001-0000-4000-8000-000000000016', '00000010-0000-4000-8000-000000000008', '2026-10-27 17:20:00'),
  ('00000001-0000-4000-8000-000000000017', '00000010-0000-4000-8000-000000000005', '2026-10-30 18:05:00'),
  ('00000001-0000-4000-8000-000000000017', '00000010-0000-4000-8000-000000000004', '2026-10-31 18:15:00'),
  ('00000001-0000-4000-8000-000000000018', '00000010-0000-4000-8000-000000000001', '2026-10-22 15:10:00'),
  ('00000001-0000-4000-8000-000000000019', '00000010-0000-4000-8000-000000000007', '2026-10-25 11:05:00'),
  ('00000001-0000-4000-8000-000000000021', '00000010-0000-4000-8000-000000000005', '2026-10-25 10:55:00');


-- visualizacion_contenido (10 filas)
INSERT INTO `visualizacion_contenido` (`id_visualizacion`, `id_nino`, `id_contenido`, `fecha_visualizacion`, `segundos_vistos`, `completado`) VALUES
  ('00000024-0000-4000-8000-000000000001', '00000001-0000-4000-8000-000000000014', '00000010-0000-4000-8000-000000000002', '2026-10-24 17:00:00', 420, 1),
  ('00000024-0000-4000-8000-000000000002', '00000001-0000-4000-8000-000000000014', '00000010-0000-4000-8000-000000000008', '2026-10-26 16:00:00', 240, 1),
  ('00000024-0000-4000-8000-000000000003', '00000001-0000-4000-8000-000000000016', '00000010-0000-4000-8000-000000000008', '2026-10-27 17:10:00', 200, 0),
  ('00000024-0000-4000-8000-000000000004', '00000001-0000-4000-8000-000000000016', '00000010-0000-4000-8000-000000000006', '2026-10-29 16:40:00', 300, 1),
  ('00000024-0000-4000-8000-000000000005', '00000001-0000-4000-8000-000000000017', '00000010-0000-4000-8000-000000000005', '2026-10-30 18:00:00', 150, 1),
  ('00000024-0000-4000-8000-000000000006', '00000001-0000-4000-8000-000000000017', '00000010-0000-4000-8000-000000000004', '2026-10-31 18:10:00', 60, 1),
  ('00000024-0000-4000-8000-000000000007', '00000001-0000-4000-8000-000000000018', '00000010-0000-4000-8000-000000000001', '2026-10-22 15:05:00', 180, 1),
  ('00000024-0000-4000-8000-000000000008', '00000001-0000-4000-8000-000000000019', '00000010-0000-4000-8000-000000000007', '2026-10-25 11:00:00', 210, 0),
  ('00000024-0000-4000-8000-000000000009', '00000001-0000-4000-8000-000000000021', '00000010-0000-4000-8000-000000000005', '2026-10-25 10:50:00', 150, 1),
  ('00000024-0000-4000-8000-000000000010', '00000001-0000-4000-8000-000000000020', '00000010-0000-4000-8000-000000000007', '2026-10-27 18:00:00', 300, 1);


-- actividad (15 filas)
INSERT INTO `actividad` (`id_actividad`, `id_modulo`, `id_tipo_actividad`, `titulo`, `instrucciones`, `puntaje_maximo`, `duracion_min`, `max_intentos`, `pista`, `orden`, `id_contenido`) VALUES
  ('00000008-0000-4000-8000-000000000001', '00000007-0000-4000-8000-000000000001', 1, 'Suma de bambúes', 'Elige la respuesta correcta para cada suma.', 100, 10, 3, 'Cuenta con tus dedos o con los bambúes del dibujo.', 1, NULL),
  ('00000008-0000-4000-8000-000000000002', '00000007-0000-4000-8000-000000000001', 2, 'Cuenta los bambúes', 'Arrastra los bambúes a la canasta hasta llegar al número pedido.', 100, 8, 3, 'Agrupa de a cinco para contar más rápido.', 2, NULL),
  ('00000008-0000-4000-8000-000000000003', '00000007-0000-4000-8000-000000000002', 5, 'Tablas del 2 al 5', 'Completa las tablas de multiplicar paso a paso.', 100, 12, 3, 'Piensa en sumas repetidas.', 1, '00000010-0000-4000-8000-000000000008'),
  ('00000008-0000-4000-8000-000000000004', '00000007-0000-4000-8000-000000000002', 1, 'Fracciones en pizza', 'Une cada pizza con su fracción.', 100, 10, 3, 'Cuenta cuántas partes tiene en total.', 2, '00000010-0000-4000-8000-000000000006'),
  ('00000008-0000-4000-8000-000000000005', '00000007-0000-4000-8000-000000000003', 3, 'El panda que no sabía dormir', 'Lee el cuento y responde las preguntas.', 50, 10, 3, 'Vuelve a leer el segundo párrafo.', 1, '00000010-0000-4000-8000-000000000003'),
  ('00000008-0000-4000-8000-000000000006', '00000007-0000-4000-8000-000000000003', 1, '¿Qué entendí del cuento?', 'Responde sobre los personajes y el final.', 100, 8, 3, 'Piensa en lo que hizo Pandi al inicio.', 2, NULL),
  ('00000008-0000-4000-8000-000000000007', '00000007-0000-4000-8000-000000000004', 5, 'Ortografía creativa', 'Corrige las palabras y escribe una frase nueva.', 100, 15, 3, 'Recuerda las reglas de la tilde.', 1, NULL),
  ('00000008-0000-4000-8000-000000000008', '00000007-0000-4000-8000-000000000004', 2, 'Palabras escondidas', 'Encuentra las palabras del bosque en la sopa de letras.', 100, 10, 3, 'Busca primero las palabras largas.', 2, NULL),
  ('00000008-0000-4000-8000-000000000009', '00000007-0000-4000-8000-000000000005', 4, 'El ciclo del agua', 'Mira el video y marca los pasos del ciclo.', 50, 5, 3, 'Ordena los pasos de arriba hacia abajo.', 1, '00000010-0000-4000-8000-000000000001'),
  ('00000008-0000-4000-8000-000000000010', '00000007-0000-4000-8000-000000000005', 1, 'Ecosistemas del mundo', 'Relaciona cada animal con su ecosistema.', 100, 10, 3, 'Piensa dónde encuentra su comida.', 2, NULL),
  ('00000008-0000-4000-8000-000000000011', '00000007-0000-4000-8000-000000000005', 5, 'El cuerpo humano', 'Ubica los órganos en el cuerpo.', 100, 12, 3, 'Empieza por los más grandes.', 3, '00000010-0000-4000-8000-000000000007'),
  ('00000008-0000-4000-8000-000000000012', '00000007-0000-4000-8000-000000000006', 2, 'Mi termómetro emocional', 'Mueve el termómetro hasta la emoción que sientes.', 100, 6, 3, 'No hay respuestas malas: todas las emociones valen.', 1, '00000010-0000-4000-8000-000000000004'),
  ('00000008-0000-4000-8000-000000000013', '00000007-0000-4000-8000-000000000006', 3, 'Cuando me siento triste', 'Lee la historia y cuéntale a Pandi qué harías tú.', 50, 8, 3, 'Pide un abrazo si lo necesitas.', 2, NULL),
  ('00000008-0000-4000-8000-000000000014', '00000007-0000-4000-8000-000000000007', 5, 'Respira como un panda', 'Sigue las cinco respiraciones guiadas.', 100, 5, 3, 'Infla la barriga como un globo.', 1, '00000010-0000-4000-8000-000000000005'),
  ('00000008-0000-4000-8000-000000000015', '00000007-0000-4000-8000-000000000007', 1, 'Soy capaz', 'Elige los pensamientos que te dan fuerza.', 100, 8, 3, 'Piensa en algo difícil que ya lograste.', 2, NULL);


-- plan_terapeutico (3 filas)
INSERT INTO `plan_terapeutico` (`id_plan`, `id_nino`, `id_terapeuta`, `objetivo`, `fecha_inicio`, `fecha_fin`, `estado_plan`) VALUES
  ('00000011-0000-4000-8000-000000000001', '00000001-0000-4000-8000-000000000015', '00000001-0000-4000-8000-000000000005', 'Fortalecer la atención sostenida y la lectoescritura inicial con actividades cortas y refuerzo positivo.', '2026-09-14', NULL, 'ACTIVO'),
  ('00000011-0000-4000-8000-000000000002', '00000001-0000-4000-8000-000000000017', '00000001-0000-4000-8000-000000000005', 'Reconocer y regular emociones mediante el registro diario y actividades de calma.', '2026-09-21', NULL, 'ACTIVO'),
  ('00000011-0000-4000-8000-000000000003', '00000001-0000-4000-8000-000000000021', '00000001-0000-4000-8000-000000000006', 'Disminuir la tensión ante evaluaciones de matemáticas con técnicas de respiración.', '2026-10-05', NULL, 'ACTIVO');


-- estado_asignacion (5 filas)
INSERT INTO `estado_asignacion` (`id_estado_asignacion`, `nombre_estado`, `es_final`) VALUES
  (1, 'PENDIENTE', 0),
  (2, 'EN_CURSO', 0),
  (3, 'COMPLETADA', 1),
  (4, 'VENCIDA', 1),
  (5, 'CANCELADA', 1);


-- asignacion (6 filas)
INSERT INTO `asignacion` (`id_asignacion`, `id_actividad`, `id_asignado_por`, `id_grupo`, `id_plan`, `fecha_asignacion`, `fecha_limite`, `instrucciones`) VALUES
  ('00000012-0000-4000-8000-000000000001', '00000008-0000-4000-8000-000000000001', '00000001-0000-4000-8000-000000000002', '00000003-0000-4000-8000-000000000001', NULL, '2026-10-19 08:00:00', '2026-10-26 23:59:00', 'Resuelve las sumas con ayuda de los bambúes. ¡Tú puedes!'),
  ('00000012-0000-4000-8000-000000000002', '00000008-0000-4000-8000-000000000005', '00000001-0000-4000-8000-000000000003', '00000003-0000-4000-8000-000000000002', NULL, '2026-10-20 08:00:00', '2026-10-27 23:59:00', 'Lee el cuento con calma y responde con tus palabras.'),
  ('00000012-0000-4000-8000-000000000003', '00000008-0000-4000-8000-000000000009', '00000001-0000-4000-8000-000000000004', '00000003-0000-4000-8000-000000000003', NULL, '2026-10-21 08:00:00', '2026-10-30 23:59:00', 'Mira el video completo antes de marcar los pasos.'),
  ('00000012-0000-4000-8000-000000000004', '00000008-0000-4000-8000-000000000012', '00000001-0000-4000-8000-000000000005', NULL, '00000011-0000-4000-8000-000000000002', '2026-10-26 09:00:00', '2026-11-02 23:59:00', 'Úsalo todos los días para contarle a Pandi cómo te sientes.'),
  ('00000012-0000-4000-8000-000000000005', '00000008-0000-4000-8000-000000000002', '00000001-0000-4000-8000-000000000005', NULL, '00000011-0000-4000-8000-000000000001', '2026-10-22 09:00:00', '2026-10-29 23:59:00', 'Hazlo en dos ratos cortos; puedes pedir pistas.'),
  ('00000012-0000-4000-8000-000000000006', '00000008-0000-4000-8000-000000000010', '00000001-0000-4000-8000-000000000004', '00000003-0000-4000-8000-000000000004', NULL, '2026-10-28 08:00:00', '2026-11-04 23:59:00', 'Relaciona con calma; recuerda respirar antes de empezar.');


-- asignacion_nino (10 filas)
INSERT INTO `asignacion_nino` (`id_asignacion_nino`, `id_asignacion`, `id_nino`, `id_estado_asignacion`, `fecha_completado`) VALUES
  ('00000013-0000-4000-8000-000000000001', '00000012-0000-4000-8000-000000000001', '00000001-0000-4000-8000-000000000014', 3, '2026-10-20 15:38:00'),
  ('00000013-0000-4000-8000-000000000002', '00000012-0000-4000-8000-000000000001', '00000001-0000-4000-8000-000000000015', 3, '2026-10-21 15:50:00'),
  ('00000013-0000-4000-8000-000000000003', '00000012-0000-4000-8000-000000000002', '00000001-0000-4000-8000-000000000016', 3, '2026-10-21 16:08:00'),
  ('00000013-0000-4000-8000-000000000004', '00000012-0000-4000-8000-000000000002', '00000001-0000-4000-8000-000000000017', 3, '2026-10-22 15:59:20'),
  ('00000013-0000-4000-8000-000000000005', '00000012-0000-4000-8000-000000000003', '00000001-0000-4000-8000-000000000018', 3, '2026-10-22 15:05:00'),
  ('00000013-0000-4000-8000-000000000006', '00000012-0000-4000-8000-000000000003', '00000001-0000-4000-8000-000000000019', 2, NULL),
  ('00000013-0000-4000-8000-000000000007', '00000012-0000-4000-8000-000000000004', '00000001-0000-4000-8000-000000000017', 2, NULL),
  ('00000013-0000-4000-8000-000000000008', '00000012-0000-4000-8000-000000000005', '00000001-0000-4000-8000-000000000015', 4, NULL),
  ('00000013-0000-4000-8000-000000000009', '00000012-0000-4000-8000-000000000006', '00000001-0000-4000-8000-000000000020', 3, '2026-10-30 16:08:20'),
  ('00000013-0000-4000-8000-000000000010', '00000012-0000-4000-8000-000000000006', '00000001-0000-4000-8000-000000000021', 1, NULL);


-- resultado_actividad (28 filas)
INSERT INTO `resultado_actividad` (`id_resultado`, `id_nino`, `id_actividad`, `id_asignacion_nino`, `puntaje`, `tiempo_usado_seg`, `intentos`, `pistas_usadas`, `completado`, `fecha_inicio`, `fecha_completado`) VALUES
  ('00000014-0000-4000-8000-000000000001', '00000001-0000-4000-8000-000000000014', '00000008-0000-4000-8000-000000000001', '00000013-0000-4000-8000-000000000001', 90, 480, 1, 0, 1, '2026-10-20 15:30:00', '2026-10-20 15:38:00'),
  ('00000014-0000-4000-8000-000000000002', '00000001-0000-4000-8000-000000000015', '00000008-0000-4000-8000-000000000001', '00000013-0000-4000-8000-000000000002', 70, 600, 2, 2, 1, '2026-10-21 15:40:00', '2026-10-21 15:50:00'),
  ('00000014-0000-4000-8000-000000000003', '00000001-0000-4000-8000-000000000016', '00000008-0000-4000-8000-000000000005', '00000013-0000-4000-8000-000000000003', 45, 480, 1, 0, 1, '2026-10-21 16:00:00', '2026-10-21 16:08:00'),
  ('00000014-0000-4000-8000-000000000004', '00000001-0000-4000-8000-000000000018', '00000008-0000-4000-8000-000000000009', '00000013-0000-4000-8000-000000000005', 50, 300, 1, 0, 1, '2026-10-22 15:00:00', '2026-10-22 15:05:00'),
  ('00000014-0000-4000-8000-000000000005', '00000001-0000-4000-8000-000000000017', '00000008-0000-4000-8000-000000000005', '00000013-0000-4000-8000-000000000004', 40, 560, 1, 1, 1, '2026-10-22 15:50:00', '2026-10-22 15:59:20'),
  ('00000014-0000-4000-8000-000000000006', '00000001-0000-4000-8000-000000000015', '00000008-0000-4000-8000-000000000002', '00000013-0000-4000-8000-000000000008', 30, 540, 3, 3, 0, '2026-10-22 16:00:00', NULL),
  ('00000014-0000-4000-8000-000000000007', '00000001-0000-4000-8000-000000000020', '00000008-0000-4000-8000-000000000007', NULL, 78, 780, 2, 1, 1, '2026-10-22 17:00:00', '2026-10-22 17:13:00'),
  ('00000014-0000-4000-8000-000000000008', '00000001-0000-4000-8000-000000000014', '00000008-0000-4000-8000-000000000002', NULL, 80, 400, 2, 1, 1, '2026-10-23 16:00:00', '2026-10-23 16:06:40'),
  ('00000014-0000-4000-8000-000000000009', '00000001-0000-4000-8000-000000000021', '00000008-0000-4000-8000-000000000008', NULL, 90, 520, 1, 0, 1, '2026-10-23 17:30:00', '2026-10-23 17:38:40'),
  ('00000014-0000-4000-8000-000000000010', '00000001-0000-4000-8000-000000000019', '00000008-0000-4000-8000-000000000008', NULL, 95, 500, 1, 0, 1, '2026-10-24 15:30:00', '2026-10-24 15:38:20'),
  ('00000014-0000-4000-8000-000000000011', '00000001-0000-4000-8000-000000000018', '00000008-0000-4000-8000-000000000010', NULL, 85, 560, 1, 0, 1, '2026-10-25 10:30:00', '2026-10-25 10:39:20'),
  ('00000014-0000-4000-8000-000000000012', '00000001-0000-4000-8000-000000000021', '00000008-0000-4000-8000-000000000014', NULL, 100, 280, 1, 0, 1, '2026-10-25 11:00:00', '2026-10-25 11:04:40'),
  ('00000014-0000-4000-8000-000000000013', '00000001-0000-4000-8000-000000000020', '00000008-0000-4000-8000-000000000015', NULL, 85, 420, 1, 0, 1, '2026-10-26 16:30:00', '2026-10-26 16:37:00'),
  ('00000014-0000-4000-8000-000000000014', '00000001-0000-4000-8000-000000000014', '00000008-0000-4000-8000-000000000012', NULL, 100, 300, 1, 0, 1, '2026-10-27 15:45:00', '2026-10-27 15:50:00'),
  ('00000014-0000-4000-8000-000000000015', '00000001-0000-4000-8000-000000000017', '00000008-0000-4000-8000-000000000013', NULL, 50, 500, 1, 0, 1, '2026-10-27 16:30:00', '2026-10-27 16:38:20'),
  ('00000014-0000-4000-8000-000000000016', '00000001-0000-4000-8000-000000000016', '00000008-0000-4000-8000-000000000003', NULL, 85, 600, 1, 0, 1, '2026-10-28 15:00:00', '2026-10-28 15:10:00'),
  ('00000014-0000-4000-8000-000000000017', '00000001-0000-4000-8000-000000000016', '00000008-0000-4000-8000-000000000004', NULL, 75, 540, 2, 1, 1, '2026-10-28 15:20:00', '2026-10-28 15:29:00'),
  ('00000014-0000-4000-8000-000000000018', '00000001-0000-4000-8000-000000000016', '00000008-0000-4000-8000-000000000006', NULL, 90, 420, 1, 0, 1, '2026-10-28 15:45:00', '2026-10-28 15:52:00'),
  ('00000014-0000-4000-8000-000000000019', '00000001-0000-4000-8000-000000000019', '00000008-0000-4000-8000-000000000015', NULL, 88, 450, 1, 0, 1, '2026-10-28 16:10:00', '2026-10-28 16:17:30'),
  ('00000014-0000-4000-8000-000000000020', '00000001-0000-4000-8000-000000000021', '00000008-0000-4000-8000-000000000011', NULL, 80, 640, 1, 1, 1, '2026-10-28 16:45:00', '2026-10-28 16:55:40'),
  ('00000014-0000-4000-8000-000000000021', '00000001-0000-4000-8000-000000000018', '00000008-0000-4000-8000-000000000003', NULL, 70, 650, 2, 1, 1, '2026-10-29 16:00:00', '2026-10-29 16:10:50'),
  ('00000014-0000-4000-8000-000000000022', '00000001-0000-4000-8000-000000000017', '00000008-0000-4000-8000-000000000004', NULL, 60, 700, 3, 3, 1, '2026-10-29 16:10:00', '2026-10-29 16:21:40'),
  ('00000014-0000-4000-8000-000000000023', '00000001-0000-4000-8000-000000000019', '00000008-0000-4000-8000-000000000009', '00000013-0000-4000-8000-000000000006', 20, 120, 1, 0, 0, '2026-10-30 14:00:00', NULL),
  ('00000014-0000-4000-8000-000000000024', '00000001-0000-4000-8000-000000000020', '00000008-0000-4000-8000-000000000010', '00000013-0000-4000-8000-000000000009', 92, 500, 1, 0, 1, '2026-10-30 16:00:00', '2026-10-30 16:08:20'),
  ('00000014-0000-4000-8000-000000000025', '00000001-0000-4000-8000-000000000014', '00000008-0000-4000-8000-000000000013', NULL, 50, 520, 1, 0, 1, '2026-10-30 16:20:00', '2026-10-30 16:28:40'),
  ('00000014-0000-4000-8000-000000000026', '00000001-0000-4000-8000-000000000021', '00000008-0000-4000-8000-000000000007', NULL, 85, 760, 1, 0, 1, '2026-10-31 16:00:00', '2026-10-31 16:12:40'),
  ('00000014-0000-4000-8000-000000000027', '00000001-0000-4000-8000-000000000016', '00000008-0000-4000-8000-000000000012', NULL, 100, 280, 1, 0, 1, '2026-10-31 16:00:00', '2026-10-31 16:04:40'),
  ('00000014-0000-4000-8000-000000000028', '00000001-0000-4000-8000-000000000017', '00000008-0000-4000-8000-000000000012', '00000013-0000-4000-8000-000000000007', 40, 240, 2, 2, 0, '2026-10-31 17:00:00', NULL);


-- progreso_nino (16 filas)
INSERT INTO `progreso_nino` (`id_progreso`, `id_nino`, `tipo_periodo`, `fecha_inicio`, `fecha_fin`, `actividades_asignadas`, `actividades_completadas`, `porcentaje_cumplimiento`, `puntaje_promedio`, `emociones_registradas`, `promedio_valencia_emocional`, `observaciones`, `fecha_calculo`) VALUES
  ('00000015-0000-4000-8000-000000000001', '00000001-0000-4000-8000-000000000014', 'MENSUAL', '2026-10-01', '2026-10-31', 1, 1, 100.00, 92.50, 4, 1.00, '1 de 1 asignaciones cumplidas.', '2026-11-01 00:10:00'),
  ('00000015-0000-4000-8000-000000000002', '00000001-0000-4000-8000-000000000015', 'MENSUAL', '2026-10-01', '2026-10-31', 2, 1, 50.00, 70.00, 3, 0.33, '1 de 2 asignaciones cumplidas.', '2026-11-01 00:10:00'),
  ('00000015-0000-4000-8000-000000000003', '00000001-0000-4000-8000-000000000016', 'MENSUAL', '2026-10-01', '2026-10-31', 1, 1, 100.00, 88.00, 3, 1.00, '1 de 1 asignaciones cumplidas.', '2026-11-01 00:10:00'),
  ('00000015-0000-4000-8000-000000000004', '00000001-0000-4000-8000-000000000017', 'MENSUAL', '2026-10-01', '2026-10-31', 2, 1, 50.00, 80.00, 5, 0.20, '1 de 2 asignaciones cumplidas.', '2026-11-01 00:10:00'),
  ('00000015-0000-4000-8000-000000000005', '00000001-0000-4000-8000-000000000018', 'MENSUAL', '2026-10-01', '2026-10-31', 1, 1, 100.00, 85.00, 3, 1.00, '1 de 1 asignaciones cumplidas.', '2026-11-01 00:10:00'),
  ('00000015-0000-4000-8000-000000000006', '00000001-0000-4000-8000-000000000019', 'MENSUAL', '2026-10-01', '2026-10-31', 1, 0, 0.00, 91.50, 5, 0.60, '0 de 1 asignaciones cumplidas.', '2026-11-01 00:10:00'),
  ('00000015-0000-4000-8000-000000000007', '00000001-0000-4000-8000-000000000020', 'MENSUAL', '2026-10-01', '2026-10-31', 1, 1, 100.00, 85.00, 3, 1.00, '1 de 1 asignaciones cumplidas.', '2026-11-01 00:10:00'),
  ('00000015-0000-4000-8000-000000000008', '00000001-0000-4000-8000-000000000021', 'MENSUAL', '2026-10-01', '2026-10-31', 1, 0, 0.00, 88.75, 4, 0.50, '0 de 1 asignaciones cumplidas.', '2026-11-01 00:10:00'),
  ('00000015-0000-4000-8000-000000000009', '00000001-0000-4000-8000-000000000014', 'SEMANAL', '2026-10-26', '2026-11-01', 0, 0, NULL, 100.00, 3, 1.00, 'Sin asignaciones nuevas en el periodo.', '2026-11-01 00:10:00'),
  ('00000015-0000-4000-8000-000000000010', '00000001-0000-4000-8000-000000000015', 'SEMANAL', '2026-10-26', '2026-11-01', 0, 0, NULL, NULL, 0, NULL, 'Sin asignaciones nuevas en el periodo.', '2026-11-01 00:10:00'),
  ('00000015-0000-4000-8000-000000000011', '00000001-0000-4000-8000-000000000016', 'SEMANAL', '2026-10-26', '2026-11-01', 0, 0, NULL, 87.50, 2, 1.00, 'Sin asignaciones nuevas en el periodo.', '2026-11-01 00:10:00'),
  ('00000015-0000-4000-8000-000000000012', '00000001-0000-4000-8000-000000000017', 'SEMANAL', '2026-10-26', '2026-11-01', 1, 0, 0.00, 80.00, 6, 0.00, '0 de 1 asignaciones cumplidas.', '2026-11-01 00:10:00'),
  ('00000015-0000-4000-8000-000000000013', '00000001-0000-4000-8000-000000000018', 'SEMANAL', '2026-10-26', '2026-11-01', 0, 0, NULL, 70.00, 2, 1.00, 'Sin asignaciones nuevas en el periodo.', '2026-11-01 00:10:00'),
  ('00000015-0000-4000-8000-000000000014', '00000001-0000-4000-8000-000000000019', 'SEMANAL', '2026-10-26', '2026-11-01', 0, 0, NULL, 88.00, 5, 0.60, 'Sin asignaciones nuevas en el periodo.', '2026-11-01 00:10:00'),
  ('00000015-0000-4000-8000-000000000015', '00000001-0000-4000-8000-000000000020', 'SEMANAL', '2026-10-26', '2026-11-01', 1, 1, 100.00, 88.50, 3, 1.00, '1 de 1 asignaciones cumplidas.', '2026-11-01 00:10:00'),
  ('00000015-0000-4000-8000-000000000016', '00000001-0000-4000-8000-000000000021', 'SEMANAL', '2026-10-26', '2026-11-01', 1, 0, 0.00, 82.50, 3, 0.33, '0 de 1 asignaciones cumplidas.', '2026-11-01 00:10:00');


-- nivel (5 filas)
INSERT INTO `nivel` (`id_nivel`, `numero_nivel`, `nombre`, `puntos_requeridos`) VALUES
  (1, 1, 'Cachorro', 0),
  (2, 2, 'Explorador', 50),
  (3, 3, 'Aventurero', 120),
  (4, 4, 'Maestro Bambú', 250),
  (5, 5, 'Panda Legendario', 500);


-- regla_puntuacion (3 filas)
INSERT INTO `regla_puntuacion` (`id_regla`, `codigo`, `descripcion`, `evento`, `puntos`, `umbral`, `id_modificado_por`) VALUES
  (1, 'ACT_COMPLETADA', 'Puntos por completar una actividad.', 'ACTIVIDAD_COMPLETADA', 10, NULL, '00000001-0000-4000-8000-000000000001'),
  (2, 'RACHA_ACIERTOS', 'Bono por completar 3 o más actividades en el mismo día.', 'RACHA_ACIERTOS', 20, 3, '00000001-0000-4000-8000-000000000001'),
  (3, 'EMOCION_REGISTRADA', 'Puntos por registrar la emoción del día.', 'EMOCION_REGISTRADA', 5, NULL, '00000001-0000-4000-8000-000000000001');


-- tipo_recompensa (4 filas)
INSERT INTO `tipo_recompensa` (`id_tipo_recompensa`, `nombre`, `descripcion`) VALUES
  (1, 'PUNTOS', 'Recompensa de tipo puntos.'),
  (2, 'INSIGNIA', 'Recompensa de tipo insignia.'),
  (3, 'NIVEL', 'Recompensa de tipo nivel.'),
  (4, 'CERTIFICADO', 'Recompensa de tipo certificado.');


-- recompensa (5 filas)
INSERT INTO `recompensa` (`id_recompensa`, `id_tipo_recompensa`, `nombre`, `descripcion`, `valor_puntos`, `imagen_url`, `condicion`, `id_nivel`) VALUES
  ('00000016-0000-4000-8000-000000000001', 2, 'Primer paso', 'Completaste tu primera actividad.', 0, '/assets/insignias/primer-paso.png', 'Completar 1 actividad.', NULL),
  ('00000016-0000-4000-8000-000000000002', 2, 'Racha de bambú', 'Tres actividades en un solo día.', 0, '/assets/insignias/racha-bambu.png', 'Completar 3 actividades el mismo día.', NULL),
  ('00000016-0000-4000-8000-000000000003', 2, 'Corazón valiente', 'Cinco días contando cómo te sientes.', 0, '/assets/insignias/corazon-valiente.png', 'Registrar 5 emociones.', NULL),
  ('00000016-0000-4000-8000-000000000004', 3, 'Nivel Explorador', 'Llegaste al nivel 2.', 0, '/assets/niveles/explorador.png', 'Acumular 50 puntos.', 2),
  ('00000016-0000-4000-8000-000000000005', 4, 'Certificado Panda Constante', 'Certificado digital por constancia.', 0, '/assets/certificados/panda-constante.png', 'Acumular 120 puntos.', 3);


-- movimiento_puntos (62 filas)
INSERT INTO `movimiento_puntos` (`id_movimiento`, `id_nino`, `id_regla`, `id_resultado`, `puntos`, `motivo`, `fecha_movimiento`) VALUES
  ('00000017-0000-4000-8000-000000000001', '00000001-0000-4000-8000-000000000014', 3, NULL, 5, 'Emoción registrada el 2026-10-20', '2026-10-20 07:41:00'),
  ('00000017-0000-4000-8000-000000000002', '00000001-0000-4000-8000-000000000015', 3, NULL, 5, 'Emoción registrada el 2026-10-20', '2026-10-20 07:56:00'),
  ('00000017-0000-4000-8000-000000000003', '00000001-0000-4000-8000-000000000014', 1, '00000014-0000-4000-8000-000000000001', 10, 'Actividad completada: Suma de bambúes', '2026-10-20 15:38:00'),
  ('00000017-0000-4000-8000-000000000004', '00000001-0000-4000-8000-000000000016', 3, NULL, 5, 'Emoción registrada el 2026-10-21', '2026-10-21 07:31:00'),
  ('00000017-0000-4000-8000-000000000005', '00000001-0000-4000-8000-000000000015', 3, NULL, 5, 'Emoción registrada el 2026-10-21', '2026-10-21 07:56:00'),
  ('00000017-0000-4000-8000-000000000006', '00000001-0000-4000-8000-000000000015', 1, '00000014-0000-4000-8000-000000000002', 10, 'Actividad completada: Suma de bambúes', '2026-10-21 15:50:00'),
  ('00000017-0000-4000-8000-000000000007', '00000001-0000-4000-8000-000000000016', 1, '00000014-0000-4000-8000-000000000003', 10, 'Actividad completada: El panda que no sabía dormir', '2026-10-21 16:08:00'),
  ('00000017-0000-4000-8000-000000000008', '00000001-0000-4000-8000-000000000020', 3, NULL, 5, 'Emoción registrada el 2026-10-22', '2026-10-22 07:21:00'),
  ('00000017-0000-4000-8000-000000000009', '00000001-0000-4000-8000-000000000015', 3, NULL, 5, 'Emoción registrada el 2026-10-22', '2026-10-22 07:56:00'),
  ('00000017-0000-4000-8000-000000000010', '00000001-0000-4000-8000-000000000018', 3, NULL, 5, 'Emoción registrada el 2026-10-22', '2026-10-22 08:01:00'),
  ('00000017-0000-4000-8000-000000000011', '00000001-0000-4000-8000-000000000018', 1, '00000014-0000-4000-8000-000000000004', 10, 'Actividad completada: El ciclo del agua', '2026-10-22 15:05:00'),
  ('00000017-0000-4000-8000-000000000012', '00000001-0000-4000-8000-000000000017', 1, '00000014-0000-4000-8000-000000000005', 10, 'Actividad completada: El panda que no sabía dormir', '2026-10-22 15:59:20'),
  ('00000017-0000-4000-8000-000000000013', '00000001-0000-4000-8000-000000000020', 1, '00000014-0000-4000-8000-000000000007', 10, 'Actividad completada: Ortografía creativa', '2026-10-22 17:13:00'),
  ('00000017-0000-4000-8000-000000000014', '00000001-0000-4000-8000-000000000014', 3, NULL, 5, 'Emoción registrada el 2026-10-23', '2026-10-23 07:41:00'),
  ('00000017-0000-4000-8000-000000000015', '00000001-0000-4000-8000-000000000021', 3, NULL, 5, 'Emoción registrada el 2026-10-23', '2026-10-23 07:51:00'),
  ('00000017-0000-4000-8000-000000000016', '00000001-0000-4000-8000-000000000014', 1, '00000014-0000-4000-8000-000000000008', 10, 'Actividad completada: Cuenta los bambúes', '2026-10-23 16:06:40'),
  ('00000017-0000-4000-8000-000000000017', '00000001-0000-4000-8000-000000000021', 1, '00000014-0000-4000-8000-000000000009', 10, 'Actividad completada: Palabras escondidas', '2026-10-23 17:38:40'),
  ('00000017-0000-4000-8000-000000000018', '00000001-0000-4000-8000-000000000019', 3, NULL, 5, 'Emoción registrada el 2026-10-24', '2026-10-24 08:11:00'),
  ('00000017-0000-4000-8000-000000000019', '00000001-0000-4000-8000-000000000019', 1, '00000014-0000-4000-8000-000000000010', 10, 'Actividad completada: Palabras escondidas', '2026-10-24 15:38:20'),
  ('00000017-0000-4000-8000-000000000020', '00000001-0000-4000-8000-000000000021', 3, NULL, 5, 'Emoción registrada el 2026-10-25', '2026-10-25 07:51:00'),
  ('00000017-0000-4000-8000-000000000021', '00000001-0000-4000-8000-000000000018', 3, NULL, 5, 'Emoción registrada el 2026-10-25', '2026-10-25 08:01:00'),
  ('00000017-0000-4000-8000-000000000022', '00000001-0000-4000-8000-000000000018', 1, '00000014-0000-4000-8000-000000000011', 10, 'Actividad completada: Ecosistemas del mundo', '2026-10-25 10:39:20'),
  ('00000017-0000-4000-8000-000000000023', '00000001-0000-4000-8000-000000000021', 1, '00000014-0000-4000-8000-000000000012', 10, 'Actividad completada: Respira como un panda', '2026-10-25 11:04:40'),
  ('00000017-0000-4000-8000-000000000024', '00000001-0000-4000-8000-000000000020', 3, NULL, 5, 'Emoción registrada el 2026-10-26', '2026-10-26 07:21:00'),
  ('00000017-0000-4000-8000-000000000025', '00000001-0000-4000-8000-000000000019', 3, NULL, 5, 'Emoción registrada el 2026-10-26', '2026-10-26 08:11:00'),
  ('00000017-0000-4000-8000-000000000026', '00000001-0000-4000-8000-000000000020', 1, '00000014-0000-4000-8000-000000000013', 10, 'Actividad completada: Soy capaz', '2026-10-26 16:37:00'),
  ('00000017-0000-4000-8000-000000000027', '00000001-0000-4000-8000-000000000014', 3, NULL, 5, 'Emoción registrada el 2026-10-27', '2026-10-27 07:41:00'),
  ('00000017-0000-4000-8000-000000000028', '00000001-0000-4000-8000-000000000017', 3, NULL, 5, 'Emoción registrada el 2026-10-27', '2026-10-27 07:46:00'),
  ('00000017-0000-4000-8000-000000000029', '00000001-0000-4000-8000-000000000014', 1, '00000014-0000-4000-8000-000000000014', 10, 'Actividad completada: Mi termómetro emocional', '2026-10-27 15:50:00'),
  ('00000017-0000-4000-8000-000000000030', '00000001-0000-4000-8000-000000000017', 1, '00000014-0000-4000-8000-000000000015', 10, 'Actividad completada: Cuando me siento triste', '2026-10-27 16:38:20'),
  ('00000017-0000-4000-8000-000000000031', '00000001-0000-4000-8000-000000000016', 3, NULL, 5, 'Emoción registrada el 2026-10-28', '2026-10-28 07:31:00'),
  ('00000017-0000-4000-8000-000000000032', '00000001-0000-4000-8000-000000000017', 3, NULL, 5, 'Emoción registrada el 2026-10-28', '2026-10-28 07:46:00'),
  ('00000017-0000-4000-8000-000000000033', '00000001-0000-4000-8000-000000000021', 3, NULL, 5, 'Emoción registrada el 2026-10-28', '2026-10-28 07:51:00'),
  ('00000017-0000-4000-8000-000000000034', '00000001-0000-4000-8000-000000000019', 3, NULL, 5, 'Emoción registrada el 2026-10-28', '2026-10-28 08:11:00'),
  ('00000017-0000-4000-8000-000000000035', '00000001-0000-4000-8000-000000000016', 1, '00000014-0000-4000-8000-000000000016', 10, 'Actividad completada: Tablas del 2 al 5', '2026-10-28 15:10:00'),
  ('00000017-0000-4000-8000-000000000036', '00000001-0000-4000-8000-000000000016', 1, '00000014-0000-4000-8000-000000000017', 10, 'Actividad completada: Fracciones en pizza', '2026-10-28 15:29:00'),
  ('00000017-0000-4000-8000-000000000037', '00000001-0000-4000-8000-000000000016', 1, '00000014-0000-4000-8000-000000000018', 10, 'Actividad completada: ¿Qué entendí del cuento?', '2026-10-28 15:52:00'),
  ('00000017-0000-4000-8000-000000000038', '00000001-0000-4000-8000-000000000016', 2, '00000014-0000-4000-8000-000000000018', 20, 'Racha: 3 actividades el 2026-10-28', '2026-10-28 15:53:00'),
  ('00000017-0000-4000-8000-000000000039', '00000001-0000-4000-8000-000000000019', 1, '00000014-0000-4000-8000-000000000019', 10, 'Actividad completada: Soy capaz', '2026-10-28 16:17:30'),
  ('00000017-0000-4000-8000-000000000040', '00000001-0000-4000-8000-000000000021', 1, '00000014-0000-4000-8000-000000000020', 10, 'Actividad completada: El cuerpo humano', '2026-10-28 16:55:40'),
  ('00000017-0000-4000-8000-000000000041', '00000001-0000-4000-8000-000000000017', 3, NULL, 5, 'Emoción registrada el 2026-10-29', '2026-10-29 07:46:00'),
  ('00000017-0000-4000-8000-000000000042', '00000001-0000-4000-8000-000000000018', 3, NULL, 5, 'Emoción registrada el 2026-10-29', '2026-10-29 08:01:00'),
  ('00000017-0000-4000-8000-000000000043', '00000001-0000-4000-8000-000000000019', 3, NULL, 5, 'Emoción registrada el 2026-10-29', '2026-10-29 08:11:00'),
  ('00000017-0000-4000-8000-000000000044', '00000001-0000-4000-8000-000000000018', 1, '00000014-0000-4000-8000-000000000021', 10, 'Actividad completada: Tablas del 2 al 5', '2026-10-29 16:10:50'),
  ('00000017-0000-4000-8000-000000000045', '00000001-0000-4000-8000-000000000017', 1, '00000014-0000-4000-8000-000000000022', 10, 'Actividad completada: Fracciones en pizza', '2026-10-29 16:21:40'),
  ('00000017-0000-4000-8000-000000000046', '00000001-0000-4000-8000-000000000020', 3, NULL, 5, 'Emoción registrada el 2026-10-30', '2026-10-30 07:21:00'),
  ('00000017-0000-4000-8000-000000000047', '00000001-0000-4000-8000-000000000014', 3, NULL, 5, 'Emoción registrada el 2026-10-30', '2026-10-30 07:41:00'),
  ('00000017-0000-4000-8000-000000000048', '00000001-0000-4000-8000-000000000017', 3, NULL, 5, 'Emoción registrada el 2026-10-30', '2026-10-30 07:46:00'),
  ('00000017-0000-4000-8000-000000000049', '00000001-0000-4000-8000-000000000020', 1, '00000014-0000-4000-8000-000000000024', 10, 'Actividad completada: Ecosistemas del mundo', '2026-10-30 16:08:20'),
  ('00000017-0000-4000-8000-000000000050', '00000001-0000-4000-8000-000000000014', 1, '00000014-0000-4000-8000-000000000025', 10, 'Actividad completada: Cuando me siento triste', '2026-10-30 16:28:40'),
  ('00000017-0000-4000-8000-000000000051', '00000001-0000-4000-8000-000000000016', 3, NULL, 5, 'Emoción registrada el 2026-10-31', '2026-10-31 07:31:00'),
  ('00000017-0000-4000-8000-000000000052', '00000001-0000-4000-8000-000000000017', 3, NULL, 5, 'Emoción registrada el 2026-10-31', '2026-10-31 07:46:00'),
  ('00000017-0000-4000-8000-000000000053', '00000001-0000-4000-8000-000000000021', 3, NULL, 5, 'Emoción registrada el 2026-10-31', '2026-10-31 07:51:00'),
  ('00000017-0000-4000-8000-000000000054', '00000001-0000-4000-8000-000000000019', 3, NULL, 5, 'Emoción registrada el 2026-10-31', '2026-10-31 08:11:00'),
  ('00000017-0000-4000-8000-000000000055', '00000001-0000-4000-8000-000000000016', 1, '00000014-0000-4000-8000-000000000027', 10, 'Actividad completada: Mi termómetro emocional', '2026-10-31 16:04:40'),
  ('00000017-0000-4000-8000-000000000056', '00000001-0000-4000-8000-000000000021', 1, '00000014-0000-4000-8000-000000000026', 10, 'Actividad completada: Ortografía creativa', '2026-10-31 16:12:40'),
  ('00000017-0000-4000-8000-000000000057', '00000001-0000-4000-8000-000000000020', 3, NULL, 5, 'Emoción registrada el 2026-11-01', '2026-11-01 07:21:00'),
  ('00000017-0000-4000-8000-000000000058', '00000001-0000-4000-8000-000000000014', 3, NULL, 5, 'Emoción registrada el 2026-11-01', '2026-11-01 07:41:00'),
  ('00000017-0000-4000-8000-000000000059', '00000001-0000-4000-8000-000000000017', 3, NULL, 5, 'Emoción registrada el 2026-11-01', '2026-11-01 07:46:00'),
  ('00000017-0000-4000-8000-000000000060', '00000001-0000-4000-8000-000000000021', 3, NULL, 5, 'Emoción registrada el 2026-11-01', '2026-11-01 07:51:00'),
  ('00000017-0000-4000-8000-000000000061', '00000001-0000-4000-8000-000000000018', 3, NULL, 5, 'Emoción registrada el 2026-11-01', '2026-11-01 08:01:00'),
  ('00000017-0000-4000-8000-000000000062', '00000001-0000-4000-8000-000000000019', 3, NULL, 5, 'Emoción registrada el 2026-11-01', '2026-11-01 08:11:00');


-- nino_recompensa (20 filas)
INSERT INTO `nino_recompensa` (`id_nino_recompensa`, `id_nino`, `id_recompensa`, `fecha_obtencion`) VALUES
  ('00000018-0000-4000-8000-000000000001', '00000001-0000-4000-8000-000000000014', '00000016-0000-4000-8000-000000000001', '2026-10-20 15:39:00'),
  ('00000018-0000-4000-8000-000000000002', '00000001-0000-4000-8000-000000000015', '00000016-0000-4000-8000-000000000001', '2026-10-21 15:51:00'),
  ('00000018-0000-4000-8000-000000000003', '00000001-0000-4000-8000-000000000016', '00000016-0000-4000-8000-000000000001', '2026-10-21 16:09:00'),
  ('00000018-0000-4000-8000-000000000004', '00000001-0000-4000-8000-000000000018', '00000016-0000-4000-8000-000000000001', '2026-10-22 15:06:00'),
  ('00000018-0000-4000-8000-000000000005', '00000001-0000-4000-8000-000000000017', '00000016-0000-4000-8000-000000000001', '2026-10-22 16:00:20'),
  ('00000018-0000-4000-8000-000000000006', '00000001-0000-4000-8000-000000000020', '00000016-0000-4000-8000-000000000001', '2026-10-22 17:14:00'),
  ('00000018-0000-4000-8000-000000000007', '00000001-0000-4000-8000-000000000021', '00000016-0000-4000-8000-000000000001', '2026-10-23 17:39:40'),
  ('00000018-0000-4000-8000-000000000008', '00000001-0000-4000-8000-000000000019', '00000016-0000-4000-8000-000000000001', '2026-10-24 15:39:20'),
  ('00000018-0000-4000-8000-000000000009', '00000001-0000-4000-8000-000000000016', '00000016-0000-4000-8000-000000000004', '2026-10-28 15:53:00'),
  ('00000018-0000-4000-8000-000000000010', '00000001-0000-4000-8000-000000000016', '00000016-0000-4000-8000-000000000002', '2026-10-28 15:54:00'),
  ('00000018-0000-4000-8000-000000000011', '00000001-0000-4000-8000-000000000014', '00000016-0000-4000-8000-000000000004', '2026-10-30 07:42:00'),
  ('00000018-0000-4000-8000-000000000012', '00000001-0000-4000-8000-000000000017', '00000016-0000-4000-8000-000000000004', '2026-10-30 07:47:00'),
  ('00000018-0000-4000-8000-000000000013', '00000001-0000-4000-8000-000000000017', '00000016-0000-4000-8000-000000000003', '2026-10-31 07:47:00'),
  ('00000018-0000-4000-8000-000000000014', '00000001-0000-4000-8000-000000000021', '00000016-0000-4000-8000-000000000004', '2026-10-31 07:52:00'),
  ('00000018-0000-4000-8000-000000000015', '00000001-0000-4000-8000-000000000019', '00000016-0000-4000-8000-000000000003', '2026-10-31 08:12:00'),
  ('00000018-0000-4000-8000-000000000016', '00000001-0000-4000-8000-000000000020', '00000016-0000-4000-8000-000000000004', '2026-11-01 07:22:00'),
  ('00000018-0000-4000-8000-000000000017', '00000001-0000-4000-8000-000000000014', '00000016-0000-4000-8000-000000000003', '2026-11-01 07:42:00'),
  ('00000018-0000-4000-8000-000000000018', '00000001-0000-4000-8000-000000000021', '00000016-0000-4000-8000-000000000003', '2026-11-01 07:52:00'),
  ('00000018-0000-4000-8000-000000000019', '00000001-0000-4000-8000-000000000018', '00000016-0000-4000-8000-000000000004', '2026-11-01 08:02:00'),
  ('00000018-0000-4000-8000-000000000020', '00000001-0000-4000-8000-000000000019', '00000016-0000-4000-8000-000000000004', '2026-11-01 08:12:00');


-- emocion (5 filas)
INSERT INTO `emocion` (`id_emocion`, `nombre`, `icono`, `color_hex`, `valencia`) VALUES
  (1, 'Feliz', 'emoji_feliz.png', '#FFD93D', 1),
  (2, 'Tranquilo', 'emoji_tranquilo.png', '#6BCB77', 1),
  (3, 'Triste', 'emoji_triste.png', '#4D96FF', -1),
  (4, 'Enojado', 'emoji_enojado.png', '#FF6B6B', -1),
  (5, 'Asustado', 'emoji_asustado.png', '#C3A9FF', -1);


-- registro_emocion (36 filas)
INSERT INTO `registro_emocion` (`id_registro_emocion`, `id_nino`, `id_emocion`, `frase`, `fecha_registro`, `hora_registro`) VALUES
  ('00000019-0000-4000-8000-000000000001', '00000001-0000-4000-8000-000000000014', 1, NULL, '2026-10-20', '07:40:00'),
  ('00000019-0000-4000-8000-000000000002', '00000001-0000-4000-8000-000000000014', 1, NULL, '2026-10-23', '07:40:00'),
  ('00000019-0000-4000-8000-000000000003', '00000001-0000-4000-8000-000000000014', 2, 'Pandi me ayudó a contar.', '2026-10-27', '07:40:00'),
  ('00000019-0000-4000-8000-000000000004', '00000001-0000-4000-8000-000000000014', 1, NULL, '2026-10-30', '07:40:00'),
  ('00000019-0000-4000-8000-000000000005', '00000001-0000-4000-8000-000000000014', 2, NULL, '2026-11-01', '07:40:00'),
  ('00000019-0000-4000-8000-000000000006', '00000001-0000-4000-8000-000000000015', 2, NULL, '2026-10-20', '07:55:00'),
  ('00000019-0000-4000-8000-000000000007', '00000001-0000-4000-8000-000000000015', 1, NULL, '2026-10-21', '07:55:00'),
  ('00000019-0000-4000-8000-000000000008', '00000001-0000-4000-8000-000000000015', 5, 'El juego estuvo difícil.', '2026-10-22', '07:55:00'),
  ('00000019-0000-4000-8000-000000000009', '00000001-0000-4000-8000-000000000016', 1, NULL, '2026-10-21', '07:30:00'),
  ('00000019-0000-4000-8000-000000000010', '00000001-0000-4000-8000-000000000016', 1, 'Hice tres actividades seguidas.', '2026-10-28', '07:30:00'),
  ('00000019-0000-4000-8000-000000000011', '00000001-0000-4000-8000-000000000016', 2, NULL, '2026-10-31', '07:30:00'),
  ('00000019-0000-4000-8000-000000000012', '00000001-0000-4000-8000-000000000017', 1, NULL, '2026-10-27', '07:45:00'),
  ('00000019-0000-4000-8000-000000000013', '00000001-0000-4000-8000-000000000017', 2, NULL, '2026-10-28', '07:45:00'),
  ('00000019-0000-4000-8000-000000000014', '00000001-0000-4000-8000-000000000017', 2, NULL, '2026-10-29', '07:45:00'),
  ('00000019-0000-4000-8000-000000000015', '00000001-0000-4000-8000-000000000017', 3, 'Hoy no tuve ganas de jugar.', '2026-10-30', '07:45:00'),
  ('00000019-0000-4000-8000-000000000016', '00000001-0000-4000-8000-000000000017', 3, 'Extraño a mi papá.', '2026-10-31', '07:45:00'),
  ('00000019-0000-4000-8000-000000000017', '00000001-0000-4000-8000-000000000017', 3, 'Me quiero quedar en mi cuarto.', '2026-11-01', '07:45:00'),
  ('00000019-0000-4000-8000-000000000018', '00000001-0000-4000-8000-000000000018', 1, NULL, '2026-10-22', '08:00:00'),
  ('00000019-0000-4000-8000-000000000019', '00000001-0000-4000-8000-000000000018', 1, NULL, '2026-10-25', '08:00:00'),
  ('00000019-0000-4000-8000-000000000020', '00000001-0000-4000-8000-000000000018', 2, NULL, '2026-10-29', '08:00:00'),
  ('00000019-0000-4000-8000-000000000021', '00000001-0000-4000-8000-000000000018', 1, NULL, '2026-11-01', '08:00:00'),
  ('00000019-0000-4000-8000-000000000022', '00000001-0000-4000-8000-000000000019', 1, NULL, '2026-10-24', '08:10:00'),
  ('00000019-0000-4000-8000-000000000023', '00000001-0000-4000-8000-000000000019', 2, NULL, '2026-10-26', '08:10:00'),
  ('00000019-0000-4000-8000-000000000024', '00000001-0000-4000-8000-000000000019', 1, NULL, '2026-10-28', '08:10:00'),
  ('00000019-0000-4000-8000-000000000025', '00000001-0000-4000-8000-000000000019', 4, 'Me equivoqué y me dio rabia.', '2026-10-29', '08:10:00'),
  ('00000019-0000-4000-8000-000000000026', '00000001-0000-4000-8000-000000000019', 2, NULL, '2026-10-31', '08:10:00'),
  ('00000019-0000-4000-8000-000000000027', '00000001-0000-4000-8000-000000000019', 1, NULL, '2026-11-01', '08:10:00'),
  ('00000019-0000-4000-8000-000000000028', '00000001-0000-4000-8000-000000000020', 2, NULL, '2026-10-22', '07:20:00'),
  ('00000019-0000-4000-8000-000000000029', '00000001-0000-4000-8000-000000000020', 1, NULL, '2026-10-26', '07:20:00'),
  ('00000019-0000-4000-8000-000000000030', '00000001-0000-4000-8000-000000000020', 1, NULL, '2026-10-30', '07:20:00'),
  ('00000019-0000-4000-8000-000000000031', '00000001-0000-4000-8000-000000000020', 2, NULL, '2026-11-01', '07:20:00'),
  ('00000019-0000-4000-8000-000000000032', '00000001-0000-4000-8000-000000000021', 2, NULL, '2026-10-23', '07:50:00'),
  ('00000019-0000-4000-8000-000000000033', '00000001-0000-4000-8000-000000000021', 1, NULL, '2026-10-25', '07:50:00'),
  ('00000019-0000-4000-8000-000000000034', '00000001-0000-4000-8000-000000000021', 5, 'Me puse nerviosa en el quiz.', '2026-10-28', '07:50:00'),
  ('00000019-0000-4000-8000-000000000035', '00000001-0000-4000-8000-000000000021', 1, NULL, '2026-10-31', '07:50:00'),
  ('00000019-0000-4000-8000-000000000036', '00000001-0000-4000-8000-000000000021', 2, NULL, '2026-11-01', '07:50:00');


-- tipo_observacion (4 filas)
INSERT INTO `tipo_observacion` (`id_tipo_observacion`, `nombre`, `descripcion`) VALUES
  (1, 'PEDAGOGICA', 'Observación de tipo pedagogica.'),
  (2, 'CONDUCTUAL', 'Observación de tipo conductual.'),
  (3, 'EMOCIONAL', 'Observación de tipo emocional.'),
  (4, 'ACADEMICA', 'Observación de tipo academica.');


-- observacion (6 filas)
INSERT INTO `observacion` (`id_observacion`, `id_nino`, `id_profesional`, `id_tipo_observacion`, `descripcion`, `es_privada`, `fecha_observacion`) VALUES
  ('00000020-0000-4000-8000-000000000001', '00000001-0000-4000-8000-000000000017', '00000001-0000-4000-8000-000000000005', 3, 'Se observa decaimiento sostenido durante tres días consecutivos. Se programa conversación con la madre y se refuerza la actividad Mi termómetro emocional.', 1, '2026-11-01 08:25:00'),
  ('00000020-0000-4000-8000-000000000002', '00000001-0000-4000-8000-000000000015', '00000001-0000-4000-8000-000000000005', 2, 'Se frustra con el juego de conteo; responde mejor con pausas cortas y pistas visuales.', 0, '2026-10-22 17:10:00'),
  ('00000020-0000-4000-8000-000000000003', '00000001-0000-4000-8000-000000000014', '00000001-0000-4000-8000-000000000002', 1, 'Excelente ritmo en sumas. Puede avanzar a restas sencillas la próxima semana.', 0, '2026-10-30 10:00:00'),
  ('00000020-0000-4000-8000-000000000004', '00000001-0000-4000-8000-000000000016', '00000001-0000-4000-8000-000000000003', 4, 'Resolvió tres actividades seguidas el mismo día; muestra motivación alta y buena comprensión lectora.', 0, '2026-10-29 09:15:00'),
  ('00000020-0000-4000-8000-000000000005', '00000001-0000-4000-8000-000000000021', '00000001-0000-4000-8000-000000000004', 4, 'Responde con precisión en ciencias; se recomienda ampliar con retos de ecosistemas.', 0, '2026-10-31 11:00:00'),
  ('00000020-0000-4000-8000-000000000006', '00000001-0000-4000-8000-000000000021', '00000001-0000-4000-8000-000000000006', 3, 'Nerviosismo ante evaluaciones de matemáticas. Se sugiere respiración guiada antes de cada quiz.', 1, '2026-10-29 17:30:00');


-- tipo_reporte (4 filas)
INSERT INTO `tipo_reporte` (`id_tipo_reporte`, `nombre`, `descripcion`) VALUES
  (1, 'ACADEMICO', 'Reporte de tipo academico.'),
  (2, 'EMOCIONAL', 'Reporte de tipo emocional.'),
  (3, 'INTEGRAL', 'Reporte de tipo integral.'),
  (4, 'CONDUCTUAL', 'Reporte de tipo conductual.');


-- reporte (5 filas)
INSERT INTO `reporte` (`id_reporte`, `id_nino`, `id_tipo_reporte`, `id_generado_por`, `periodo_inicio`, `periodo_fin`, `contenido_json`, `url_pdf`, `es_automatico`, `fecha_generacion`) VALUES
  ('00000021-0000-4000-8000-000000000001', '00000001-0000-4000-8000-000000000014', 3, '00000001-0000-4000-8000-000000000007', '2026-10-01', '2026-10-31', '{"nino":"Sofía Mesa Durán","tipo":"INTEGRAL","periodo":{"inicio":"2026-10-01","fin":"2026-10-31"},"cumplimiento_pct":100.0,"puntaje_promedio":92.5,"actividades_completadas":4,"emociones":{"Feliz":3,"Tranquilo":1},"puntos_totales":65,"nivel":"Explorador"}', '/reportes/2026/00000021-0000-4000-8000-000000000001.pdf', 0, '2026-10-31 18:00:00'),
  ('00000021-0000-4000-8000-000000000002', '00000001-0000-4000-8000-000000000016', 1, '00000001-0000-4000-8000-000000000003', '2026-10-01', '2026-10-31', '{"nino":"Mateo Mesa Durán","tipo":"ACADEMICO","periodo":{"inicio":"2026-10-01","fin":"2026-10-31"},"cumplimiento_pct":100.0,"puntaje_promedio":88.0,"actividades_completadas":5,"emociones":{"Feliz":2,"Tranquilo":1},"puntos_totales":85,"nivel":"Explorador"}', '/reportes/2026/00000021-0000-4000-8000-000000000002.pdf', 0, '2026-10-31 19:00:00'),
  ('00000021-0000-4000-8000-000000000003', '00000001-0000-4000-8000-000000000017', 2, '00000001-0000-4000-8000-000000000005', '2026-10-26', '2026-11-01', '{"nino":"Valentina Cardona Pérez","tipo":"EMOCIONAL","periodo":{"inicio":"2026-10-26","fin":"2026-11-01"},"cumplimiento_pct":0.0,"puntaje_promedio":80.0,"actividades_completadas":2,"emociones":{"Feliz":1,"Tranquilo":2,"Triste":3},"puntos_totales":60,"nivel":"Explorador"}', '/reportes/2026/00000021-0000-4000-8000-000000000003.pdf', 0, '2026-11-01 08:30:00'),
  ('00000021-0000-4000-8000-000000000004', '00000001-0000-4000-8000-000000000018', 3, '00000001-0000-4000-8000-000000000001', '2026-10-01', '2026-10-31', '{"nino":"Samuel Rendón Toro","tipo":"INTEGRAL","periodo":{"inicio":"2026-10-01","fin":"2026-10-31"},"cumplimiento_pct":100.0,"puntaje_promedio":85.0,"actividades_completadas":3,"emociones":{"Feliz":2,"Tranquilo":1},"puntos_totales":50,"nivel":"Explorador"}', '/reportes/2026/00000021-0000-4000-8000-000000000004.pdf', 1, '2026-11-01 00:05:00'),
  ('00000021-0000-4000-8000-000000000005', '00000001-0000-4000-8000-000000000015', 4, '00000001-0000-4000-8000-000000000005', '2026-10-15', '2026-10-31', '{"nino":"Tomás Pérez Vargas","tipo":"CONDUCTUAL","periodo":{"inicio":"2026-10-15","fin":"2026-10-31"},"cumplimiento_pct":50.0,"puntaje_promedio":70.0,"actividades_completadas":1,"emociones":{"Tranquilo":1,"Feliz":1,"Asustado":1},"puntos_totales":25,"nivel":"Cachorro"}', '/reportes/2026/00000021-0000-4000-8000-000000000005.pdf', 0, '2026-10-31 10:00:00');


-- mensaje (9 filas)
INSERT INTO `mensaje` (`id_mensaje`, `id_remitente`, `id_destinatario`, `id_nino`, `contenido`, `fecha_envio`, `leido`, `fecha_lectura`, `eliminado_remitente`, `eliminado_destinatario`) VALUES
  ('00000022-0000-4000-8000-000000000001', '00000001-0000-4000-8000-000000000012', '00000001-0000-4000-8000-000000000005', '00000001-0000-4000-8000-000000000017', 'Buenas noches, Mariana. Noté a Valentina más callada estos días. ¿Podemos hablar mañana?', '2026-10-31 20:15:00', 1, '2026-11-01 07:40:00', 0, 0),
  ('00000022-0000-4000-8000-000000000002', '00000001-0000-4000-8000-000000000005', '00000001-0000-4000-8000-000000000012', '00000001-0000-4000-8000-000000000017', 'Hola Gloria, gracias por escribir. La app avisó que Valentina lleva tres días registrando Triste. ¿Le parece una llamada hoy a las 4 p. m.?', '2026-11-01 08:40:00', 0, NULL, 0, 0),
  ('00000022-0000-4000-8000-000000000003', '00000001-0000-4000-8000-000000000007', '00000001-0000-4000-8000-000000000002', '00000001-0000-4000-8000-000000000014', 'Profe Sandra, Sofía está feliz con las sumas. ¿Podría empezar con restas?', '2026-10-30 18:05:00', 1, '2026-10-31 07:30:00', 0, 0),
  ('00000022-0000-4000-8000-000000000004', '00000001-0000-4000-8000-000000000002', '00000001-0000-4000-8000-000000000007', '00000001-0000-4000-8000-000000000014', '¡Qué bueno, Carolina! La próxima semana le asigno restas sencillas.', '2026-10-31 07:45:00', 1, '2026-10-31 08:10:00', 0, 0),
  ('00000022-0000-4000-8000-000000000005', '00000001-0000-4000-8000-000000000013', '00000001-0000-4000-8000-000000000006', '00000001-0000-4000-8000-000000000021', 'Camilo, Isabella se puso nerviosa con el quiz de ecosistemas. ¿Qué puedo hacer en casa?', '2026-10-29 19:00:00', 1, '2026-10-30 09:00:00', 0, 0),
  ('00000022-0000-4000-8000-000000000006', '00000001-0000-4000-8000-000000000006', '00000001-0000-4000-8000-000000000013', '00000001-0000-4000-8000-000000000021', 'Ricardo, antes de cada quiz pídale que haga Respira como un panda (5 minutos). Lo revisamos en la próxima sesión.', '2026-10-30 09:30:00', 1, '2026-10-30 12:00:00', 0, 0),
  ('00000022-0000-4000-8000-000000000007', '00000001-0000-4000-8000-000000000011', '00000001-0000-4000-8000-000000000004', '00000001-0000-4000-8000-000000000018', 'Profe Paula, Samuel quiere más retos de ciencias. ¿Qué módulo recomienda?', '2026-10-28 17:20:00', 1, '2026-10-29 07:15:00', 0, 1),
  ('00000022-0000-4000-8000-000000000008', '00000001-0000-4000-8000-000000000004', '00000001-0000-4000-8000-000000000011', '00000001-0000-4000-8000-000000000018', 'Esteban, puede continuar con el módulo Explorando el cuerpo y los ecosistemas. Va muy bien.', '2026-10-29 07:50:00', 1, '2026-10-29 19:00:00', 0, 0),
  ('00000022-0000-4000-8000-000000000009', '00000001-0000-4000-8000-000000000003', '00000001-0000-4000-8000-000000000005', '00000001-0000-4000-8000-000000000017', 'Mariana, Valentina estuvo callada en clase. Comparto mi observación para el seguimiento.', '2026-11-01 09:00:00', 0, NULL, 0, 0);


-- tipo_notificacion (7 filas)
INSERT INTO `tipo_notificacion` (`id_tipo_notificacion`, `nombre`, `descripcion`) VALUES
  (1, 'ACTIVIDAD_COMPLETADA', 'Notificación de tipo actividad completada.'),
  (2, 'EMOCION_NEGATIVA_CONSECUTIVA', 'Notificación de tipo emocion negativa consecutiva.'),
  (3, 'INACTIVIDAD', 'Notificación de tipo inactividad.'),
  (4, 'ASIGNACION_NUEVA', 'Notificación de tipo asignacion nueva.'),
  (5, 'REPORTE_DISPONIBLE', 'Notificación de tipo reporte disponible.'),
  (6, 'MENSAJE_NUEVO', 'Notificación de tipo mensaje nuevo.'),
  (7, 'LOGRO_OBTENIDO', 'Notificación de tipo logro obtenido.');


-- notificacion (14 filas)
INSERT INTO `notificacion` (`id_notificacion`, `id_usuario`, `id_nino`, `id_tipo_notificacion`, `titulo`, `mensaje`, `url_accion`, `leida`, `enviada_correo`, `fecha_creacion`, `fecha_lectura`) VALUES
  ('00000023-0000-4000-8000-000000000001', '00000001-0000-4000-8000-000000000012', '00000001-0000-4000-8000-000000000017', 2, 'Alerta emocional: Valentina', 'Valentina registró Triste tres días seguidos (30 oct a 1 nov).', '/ninos/valentina/emociones', 0, 1, '2026-11-01 08:05:00', NULL),
  ('00000023-0000-4000-8000-000000000002', '00000001-0000-4000-8000-000000000005', '00000001-0000-4000-8000-000000000017', 2, 'Alerta emocional: Valentina', 'Valentina registró Triste tres días seguidos (30 oct a 1 nov).', '/ninos/valentina/emociones', 1, 1, '2026-11-01 08:05:00', '2026-11-01 08:12:00'),
  ('00000023-0000-4000-8000-000000000003', '00000001-0000-4000-8000-000000000003', '00000001-0000-4000-8000-000000000017', 2, 'Alerta emocional: Valentina', 'Valentina registró Triste tres días seguidos (30 oct a 1 nov).', '/ninos/valentina/emociones', 1, 0, '2026-11-01 08:05:00', '2026-11-01 09:00:00'),
  ('00000023-0000-4000-8000-000000000004', '00000001-0000-4000-8000-000000000012', '00000001-0000-4000-8000-000000000015', 3, 'Tomás lleva 3 días sin actividad', 'No registramos actividades de Tomás desde el 22 de octubre.', '/ninos/tomas/progreso', 1, 0, '2026-10-25 08:00:00', '2026-10-25 19:10:00'),
  ('00000023-0000-4000-8000-000000000005', '00000001-0000-4000-8000-000000000005', '00000001-0000-4000-8000-000000000015', 3, 'Tomás lleva 3 días sin actividad', 'No registramos actividades de Tomás desde el 22 de octubre.', '/ninos/tomas/progreso', 1, 0, '2026-10-25 08:00:00', '2026-10-26 08:30:00'),
  ('00000023-0000-4000-8000-000000000006', '00000001-0000-4000-8000-000000000002', '00000001-0000-4000-8000-000000000015', 3, 'Tomás lleva 3 días sin actividad', 'No registramos actividades de Tomás desde el 22 de octubre.', '/ninos/tomas/progreso', 0, 0, '2026-10-25 08:00:00', NULL),
  ('00000023-0000-4000-8000-000000000007', '00000001-0000-4000-8000-000000000007', '00000001-0000-4000-8000-000000000014', 1, 'Sofía completó una actividad', 'Sofía terminó Cuando me siento triste con 50 de 50 puntos.', '/ninos/sofia/progreso', 1, 0, '2026-10-30 16:30:00', '2026-10-30 18:00:00'),
  ('00000023-0000-4000-8000-000000000008', '00000001-0000-4000-8000-000000000002', '00000001-0000-4000-8000-000000000014', 1, 'Sofía completó una actividad', 'Sofía terminó Suma de bambúes con 90 de 100 puntos.', '/ninos/sofia/progreso', 1, 0, '2026-10-20 15:40:00', '2026-10-21 07:30:00'),
  ('00000023-0000-4000-8000-000000000009', '00000001-0000-4000-8000-000000000017', NULL, 4, '¡Nueva actividad!', 'Mariana te asignó Mi termómetro emocional.', '/actividades', 1, 0, '2026-10-26 09:05:00', '2026-10-26 15:30:00'),
  ('00000023-0000-4000-8000-000000000010', '00000001-0000-4000-8000-000000000021', NULL, 4, '¡Nueva actividad!', 'Paula te asignó Ecosistemas del mundo.', '/actividades', 0, 0, '2026-10-28 08:05:00', NULL),
  ('00000023-0000-4000-8000-000000000011', '00000001-0000-4000-8000-000000000016', NULL, 7, '¡Ganaste una insignia!', 'Racha de bambú: tres actividades en un día.', '/logros', 1, 0, '2026-10-28 15:55:00', '2026-10-28 16:00:00'),
  ('00000023-0000-4000-8000-000000000012', '00000001-0000-4000-8000-000000000007', '00000001-0000-4000-8000-000000000016', 7, 'Mateo ganó una insignia', 'Racha de bambú: tres actividades en un solo día.', '/ninos/mateo/logros', 1, 0, '2026-10-28 15:55:00', '2026-10-28 20:00:00'),
  ('00000023-0000-4000-8000-000000000013', '00000001-0000-4000-8000-000000000007', '00000001-0000-4000-8000-000000000014', 5, 'Reporte disponible', 'El reporte integral de octubre de Sofía está listo.', '/reportes', 0, 1, '2026-10-31 18:01:00', NULL),
  ('00000023-0000-4000-8000-000000000014', '00000001-0000-4000-8000-000000000005', '00000001-0000-4000-8000-000000000017', 6, 'Mensaje nuevo de Gloria Pérez', 'Tienes un mensaje sobre Valentina.', '/mensajes', 1, 0, '2026-10-31 20:16:00', '2026-11-01 07:40:00');


-- preferencia_notificacion (67 filas)
INSERT INTO `preferencia_notificacion` (`id_usuario`, `id_tipo_notificacion`, `canal_app`, `canal_correo`) VALUES
  ('00000001-0000-4000-8000-000000000007', 1, 1, 0),
  ('00000001-0000-4000-8000-000000000007', 2, 1, 1),
  ('00000001-0000-4000-8000-000000000007', 3, 1, 0),
  ('00000001-0000-4000-8000-000000000007', 5, 1, 1),
  ('00000001-0000-4000-8000-000000000007', 6, 1, 0),
  ('00000001-0000-4000-8000-000000000007', 7, 1, 0),
  ('00000001-0000-4000-8000-000000000008', 1, 1, 0),
  ('00000001-0000-4000-8000-000000000008', 2, 1, 1),
  ('00000001-0000-4000-8000-000000000008', 3, 1, 0),
  ('00000001-0000-4000-8000-000000000008', 5, 1, 1),
  ('00000001-0000-4000-8000-000000000008', 6, 1, 0),
  ('00000001-0000-4000-8000-000000000008', 7, 1, 0),
  ('00000001-0000-4000-8000-000000000009', 1, 1, 0),
  ('00000001-0000-4000-8000-000000000009', 2, 1, 1),
  ('00000001-0000-4000-8000-000000000009', 3, 1, 0),
  ('00000001-0000-4000-8000-000000000009', 5, 1, 1),
  ('00000001-0000-4000-8000-000000000009', 6, 1, 0),
  ('00000001-0000-4000-8000-000000000009', 7, 1, 0),
  ('00000001-0000-4000-8000-000000000010', 1, 1, 0),
  ('00000001-0000-4000-8000-000000000010', 2, 1, 1),
  ('00000001-0000-4000-8000-000000000010', 3, 1, 0),
  ('00000001-0000-4000-8000-000000000010', 5, 1, 1),
  ('00000001-0000-4000-8000-000000000010', 6, 1, 0),
  ('00000001-0000-4000-8000-000000000010', 7, 1, 0),
  ('00000001-0000-4000-8000-000000000011', 1, 1, 0),
  ('00000001-0000-4000-8000-000000000011', 2, 1, 1),
  ('00000001-0000-4000-8000-000000000011', 3, 1, 0),
  ('00000001-0000-4000-8000-000000000011', 5, 1, 1),
  ('00000001-0000-4000-8000-000000000011', 6, 1, 0),
  ('00000001-0000-4000-8000-000000000011', 7, 1, 0),
  ('00000001-0000-4000-8000-000000000012', 1, 1, 0),
  ('00000001-0000-4000-8000-000000000012', 2, 1, 1),
  ('00000001-0000-4000-8000-000000000012', 3, 1, 0),
  ('00000001-0000-4000-8000-000000000012', 5, 1, 1),
  ('00000001-0000-4000-8000-000000000012', 6, 1, 0),
  ('00000001-0000-4000-8000-000000000012', 7, 1, 0),
  ('00000001-0000-4000-8000-000000000013', 1, 1, 0),
  ('00000001-0000-4000-8000-000000000013', 2, 1, 1),
  ('00000001-0000-4000-8000-000000000013', 3, 1, 0),
  ('00000001-0000-4000-8000-000000000013', 5, 1, 1),
  ('00000001-0000-4000-8000-000000000013', 6, 1, 0),
  ('00000001-0000-4000-8000-000000000013', 7, 1, 0),
  ('00000001-0000-4000-8000-000000000002', 1, 1, 0),
  ('00000001-0000-4000-8000-000000000002', 2, 1, 1),
  ('00000001-0000-4000-8000-000000000002', 3, 1, 0),
  ('00000001-0000-4000-8000-000000000002', 5, 1, 0),
  ('00000001-0000-4000-8000-000000000002', 6, 1, 0),
  ('00000001-0000-4000-8000-000000000003', 1, 1, 0),
  ('00000001-0000-4000-8000-000000000003', 2, 1, 1),
  ('00000001-0000-4000-8000-000000000003', 3, 1, 0),
  ('00000001-0000-4000-8000-000000000003', 5, 1, 0),
  ('00000001-0000-4000-8000-000000000003', 6, 1, 0),
  ('00000001-0000-4000-8000-000000000004', 1, 1, 0),
  ('00000001-0000-4000-8000-000000000004', 2, 1, 1),
  ('00000001-0000-4000-8000-000000000004', 3, 1, 0),
  ('00000001-0000-4000-8000-000000000004', 5, 1, 0),
  ('00000001-0000-4000-8000-000000000004', 6, 1, 0),
  ('00000001-0000-4000-8000-000000000005', 1, 1, 0),
  ('00000001-0000-4000-8000-000000000005', 2, 1, 1),
  ('00000001-0000-4000-8000-000000000005', 3, 1, 0),
  ('00000001-0000-4000-8000-000000000005', 5, 1, 0),
  ('00000001-0000-4000-8000-000000000005', 6, 1, 0),
  ('00000001-0000-4000-8000-000000000006', 1, 1, 0),
  ('00000001-0000-4000-8000-000000000006', 2, 1, 1),
  ('00000001-0000-4000-8000-000000000006', 3, 1, 0),
  ('00000001-0000-4000-8000-000000000006', 5, 1, 0),
  ('00000001-0000-4000-8000-000000000006', 6, 1, 0);


-- auditoria (12 filas)
INSERT INTO `auditoria` (`id_usuario`, `id_nino`, `entidad`, `id_registro`, `accion`, `campo_modificado`, `valor_anterior`, `valor_nuevo`, `ip_origen`, `observacion`, `fecha_accion`) VALUES
  ('00000001-0000-4000-8000-000000000001', NULL, 'usuario', '00000001-0000-4000-8000-000000000001', 'LOGIN', NULL, NULL, NULL, '192.0.2.10', 'Inicio de sesión del administrador.', '2026-11-01 07:50:00'),
  ('00000001-0000-4000-8000-000000000005', NULL, 'usuario', '00000001-0000-4000-8000-000000000005', 'LOGIN', NULL, NULL, NULL, '192.0.2.21', 'Inicio de sesión de la terapeuta.', '2026-11-01 08:10:00'),
  ('00000001-0000-4000-8000-000000000007', '00000001-0000-4000-8000-000000000014', 'progreso_nino', NULL, 'CONSULTAR', NULL, NULL, NULL, '192.0.2.31', 'Consulta del progreso mensual de Sofía.', '2026-10-31 18:00:00'),
  ('00000001-0000-4000-8000-000000000012', '00000001-0000-4000-8000-000000000017', 'registro_emocion', NULL, 'CONSULTAR', NULL, NULL, NULL, '192.0.2.32', 'Consulta del seguimiento emocional.', '2026-11-01 07:35:00'),
  ('00000001-0000-4000-8000-000000000005', '00000001-0000-4000-8000-000000000017', 'observacion', '00000020-0000-4000-8000-000000000001', 'CREAR', NULL, NULL, NULL, '192.0.2.21', 'Observación emocional creada.', '2026-11-01 08:25:00'),
  ('00000001-0000-4000-8000-000000000005', '00000001-0000-4000-8000-000000000017', 'reporte', '00000021-0000-4000-8000-000000000003', 'EXPORTAR', NULL, NULL, NULL, '192.0.2.21', 'Reporte emocional exportado a PDF.', '2026-11-01 08:35:00'),
  ('00000001-0000-4000-8000-000000000001', NULL, 'regla_puntuacion', NULL, 'ACTUALIZAR', 'puntos', '15', '20', '192.0.2.10', 'id_regla=2 (RACHA_ACIERTOS).', '2026-10-12 10:20:00'),
  ('00000001-0000-4000-8000-000000000013', '00000001-0000-4000-8000-000000000021', 'consentimiento_datos', '00000006-0000-4000-8000-000000000024', 'ACTUALIZAR', 'otorgado', '1', '0', '192.0.2.33', 'Revocó el consentimiento de NOTIFICACIONES.', '2026-10-15 09:30:00'),
  ('00000001-0000-4000-8000-000000000002', NULL, 'asignacion', '00000012-0000-4000-8000-000000000001', 'CREAR', NULL, NULL, NULL, '192.0.2.41', 'Asignación grupal a Primero A.', '2026-10-19 08:00:00'),
  ('00000001-0000-4000-8000-000000000004', NULL, 'asignacion', '00000012-0000-4000-8000-000000000006', 'CREAR', NULL, NULL, NULL, '192.0.2.42', 'Asignación grupal a Séptimo A.', '2026-10-28 08:00:00'),
  ('00000001-0000-4000-8000-000000000001', NULL, 'contenido_multimedia', '00000010-0000-4000-8000-000000000007', 'CREAR', NULL, NULL, NULL, '192.0.2.10', 'Publicación de Ciencia en 5 minutos.', '2026-10-02 10:00:00'),
  ('00000001-0000-4000-8000-000000000003', '00000001-0000-4000-8000-000000000016', 'observacion', '00000020-0000-4000-8000-000000000004', 'CREAR', NULL, NULL, NULL, '192.0.2.43', 'Observación académica creada.', '2026-10-29 09:15:00');

SET UNIQUE_CHECKS = 1;
SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================================
-- 5. NOTAS DE USO
-- =====================================================================
-- Los totales de puntos y el nivel no se almacenan: se calculan con la vista
-- vw_puntos_nivel_nino a partir de movimiento_puntos (evita datos duplicados).
-- Las vistas vw_ninos, vw_inactividad_nino y las alertas dependen de la fecha
-- actual (CURDATE()); con los datos de prueba, los días sin actividad crecerán
-- con el tiempo.

-- =====================================================================
-- 6. TRIGGERS DE VALIDACIÓN (se crean al final para que la importación de los
--    datos de prueba no falle cuando, con los años, los niños superen los 14).
--    Requiere que el cliente soporte DELIMITER (phpMyAdmin y mysql lo soportan).
-- =====================================================================
DELIMITER $$
DROP TRIGGER IF EXISTS `trg_perfil_nino_bi`$$
CREATE TRIGGER `trg_perfil_nino_bi` BEFORE INSERT ON `perfil_nino` FOR EACH ROW
BEGIN
  IF TIMESTAMPDIFF(YEAR, NEW.fecha_nacimiento, CURDATE()) NOT BETWEEN 6 AND 14 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Edad no permitida: el niño debe tener entre 6 y 14 años.';
  END IF;
END$$
DROP TRIGGER IF EXISTS `trg_perfil_nino_bu`$$
CREATE TRIGGER `trg_perfil_nino_bu` BEFORE UPDATE ON `perfil_nino` FOR EACH ROW
BEGIN
  IF NOT (NEW.fecha_nacimiento <=> OLD.fecha_nacimiento)
     AND TIMESTAMPDIFF(YEAR, NEW.fecha_nacimiento, CURDATE()) NOT BETWEEN 6 AND 14 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Edad no permitida: el niño debe tener entre 6 y 14 años.';
  END IF;
END$$
DROP TRIGGER IF EXISTS `trg_vinculo_bi`$$
CREATE TRIGGER `trg_vinculo_bi` BEFORE INSERT ON `vinculo_nino_adulto` FOR EACH ROW
BEGIN
  IF NEW.id_nino = NEW.id_adulto THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El niño y el adulto vinculado deben ser usuarios distintos.';
  END IF;
END$$
DROP TRIGGER IF EXISTS `trg_vinculo_bu`$$
CREATE TRIGGER `trg_vinculo_bu` BEFORE UPDATE ON `vinculo_nino_adulto` FOR EACH ROW
BEGIN
  IF NEW.id_nino = NEW.id_adulto THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El niño y el adulto vinculado deben ser usuarios distintos.';
  END IF;
END$$
DROP TRIGGER IF EXISTS `trg_mensaje_bi`$$
CREATE TRIGGER `trg_mensaje_bi` BEFORE INSERT ON `mensaje` FOR EACH ROW
BEGIN
  IF NEW.id_remitente = NEW.id_destinatario THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El remitente y el destinatario deben ser distintos.';
  END IF;
END$$
DROP TRIGGER IF EXISTS `trg_mensaje_bu`$$
CREATE TRIGGER `trg_mensaje_bu` BEFORE UPDATE ON `mensaje` FOR EACH ROW
BEGIN
  IF NEW.id_remitente = NEW.id_destinatario THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El remitente y el destinatario deben ser distintos.';
  END IF;
END$$
DELIMITER ;

-- Fin del script PandaPOP.
