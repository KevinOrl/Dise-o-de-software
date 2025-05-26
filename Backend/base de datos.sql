--
-- PostgreSQL database script corregido
-- Eliminados los bloques COPY que causaban errores

-- Configuración inicial
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';
SET default_table_access_method = heap;

-- Crear las tablas en orden correcto (sin dependencias primero)

-- Tabla: Tipo Identificación
CREATE TABLE public."Tipo Identificación" (
    id_tipo integer NOT NULL,
    nombre character varying(20)[] NOT NULL
);
ALTER TABLE public."Tipo Identificación" OWNER TO postgres;

-- Tabla: Departamento
CREATE TABLE public."Departamento" (
    id_departamento integer NOT NULL,
    nombre character varying(50)[] NOT NULL
);
ALTER TABLE public."Departamento" OWNER TO postgres;

-- Tabla: Sede
CREATE TABLE public."Sede" (
    id_sede integer NOT NULL,
    nombre character varying(40)[] NOT NULL
);
ALTER TABLE public."Sede" OWNER TO postgres;

-- Tabla: Escuela
CREATE TABLE public."Escuela" (
    id_escuela integer NOT NULL,
    nombre character varying(65)[] NOT NULL
);
ALTER TABLE public."Escuela" OWNER TO postgres;

-- Tabla: Persona
CREATE TABLE public."Persona" (
    identificacion character varying(20)[] NOT NULL,
    id_tipo integer NOT NULL,
    nombre character varying(50)[] NOT NULL,
    apellido character varying(50)[],
    correo character varying(80)[] NOT NULL,
    "contraseña" character varying(50)[] NOT NULL
);
ALTER TABLE public."Persona" OWNER TO postgres;

-- Tabla: SedeEscuela
CREATE TABLE public."SedeEscuela" (
    "id_sedeXescuela" integer NOT NULL,
    id_sede integer NOT NULL,
    id_escuela integer NOT NULL
);
ALTER TABLE public."SedeEscuela" OWNER TO postgres;

-- Tabla: Carrera
CREATE TABLE public."Carrera" (
    id_carrera integer NOT NULL,
    nombre character varying(65)[] NOT NULL,
    "id_sedeXescuela" integer
);
ALTER TABLE public."Carrera" OWNER TO postgres;

-- Tabla: Profesor
CREATE TABLE public."Profesor" (
    id_profesor integer NOT NULL,
    id_escuela integer NOT NULL,
    nombre character varying(50)[]
);
ALTER TABLE public."Profesor" OWNER TO postgres;

-- Tabla: Estudiante
CREATE TABLE public."Estudiante" (
    id_estudiante integer NOT NULL,
    carnet bigint NOT NULL,
    id_sede integer NOT NULL,
    id_carrera integer NOT NULL
);
ALTER TABLE public."Estudiante" OWNER TO postgres;

-- Tabla: Administrativo
CREATE TABLE public."Administrativo" (
    id_admin integer NOT NULL,
    "id_sedeXescuela" integer NOT NULL,
    id_departamento integer NOT NULL,
    "Rol" character varying(50)[] NOT NULL
);
ALTER TABLE public."Administrativo" OWNER TO postgres;

-- Tabla: Curso
CREATE TABLE public."Curso" (
    codigo_curso character varying(6) NOT NULL,  
    nombre character varying(50)[] NOT NULL,
    creditos integer NOT NULL,
    id_escuela integer
);
ALTER TABLE public."Curso" OWNER TO postgres;

-- Tabla: Grupo
CREATE TABLE public."Grupo" (
    id_grupo integer NOT NULL,
    codigo_curso character varying(6),  
    "id_sedeXescuela" integer,
    aula character varying(10)[],
    horario character varying(50)[],
    modalidad character varying(14)[],
    periodo integer,
    cupos integer,
    id_profesor integer
);
ALTER TABLE public."Grupo" OWNER TO postgres;

-- Tabla: Solicitudes
CREATE TABLE public."Solicitudes" (
    id_solicitud integer NOT NULL,
    id_estudiante integer,
    id_grupo integer,
    tipo_solicitud character varying(14)[] NOT NULL,
    "fechaSolicitud" date,
    revisado boolean NOT NULL,
    estado character varying(20)[],
    motivo character varying(200)[]
);
ALTER TABLE public."Solicitudes" OWNER TO postgres;

-- Tabla: HorarioClases
CREATE TABLE public."HorarioClases" (
    id_horario_clases integer NOT NULL,
    id_grupo integer,
    dia character varying(9)[],
    "horaInicio" time without time zone,
    "horaFinal" time without time zone
);
ALTER TABLE public."HorarioClases" OWNER TO postgres;

-- Tabla: EstadoCurso
CREATE TABLE public."EstadoCurso" (
    "id_estadoCurso" integer NOT NULL,
    estado character varying(20)[]
);
ALTER TABLE public."EstadoCurso" OWNER TO postgres;

-- Tabla: HistorialAcademico
CREATE TABLE public."HistorialAcademico" (
    id_historial integer NOT NULL,
    codigo_curso character varying(6),  
    "id_sedeXescuela" integer,
    carnet bigint NOT NULL,
    semestre integer,
    "año" integer,
    "id_estadoCurso" integer
);
ALTER TABLE public."HistorialAcademico" OWNER TO postgres;

-- Tabla: HistorialSolicitudes
CREATE TABLE public."HistorialSolicitudes" (
    id_historial_solicitud integer NOT NULL,
    id_estudiante integer,
    codigo_curso character varying(6),  
    "fechaRetiro" date,
    semestre integer,
    "año" integer,
    id_solicitud integer
);
ALTER TABLE public."HistorialSolicitudes" OWNER TO postgres;

-- Tabla: HistorialRetiros
CREATE TABLE public."HistorialRetiros" (
    id_retiro integer NOT NULL,
    id_estudiante integer,
    codigo_curso character varying(6),  
    "fechaRetiro" date,
    semestre integer,
    "año" integer
);
ALTER TABLE public."HistorialRetiros" OWNER TO postgres;

-- Tabla: Procesos
CREATE TABLE public."Procesos" (
    id_proceso integer NOT NULL,
    "tipoProceso" character varying(14)[],
    "fechaInicio" date,
    "fechaFinal" date,
    estado boolean,
    "id_sedeXescuela" integer,
    id_admin integer
);
ALTER TABLE public."Procesos" OWNER TO postgres;

-- Tabla: citasMatricula
CREATE TABLE public."citasMatricula" (
    id_cita integer NOT NULL,
    id_estudiante integer,
    "fechaCita" date,
    "horaCita" time without time zone,
    "tipoCita" character varying(14)[]
);
ALTER TABLE public."citasMatricula" OWNER TO postgres;

-- Claves primarias
ALTER TABLE ONLY public."Administrativo"
    ADD CONSTRAINT "Administrativo_pkey" PRIMARY KEY (id_admin);

ALTER TABLE ONLY public."Carrera"
    ADD CONSTRAINT "Carrera_pkey" PRIMARY KEY (id_carrera);

ALTER TABLE ONLY public."Curso"
    ADD CONSTRAINT "Curso_pkey" PRIMARY KEY (codigo_curso);

ALTER TABLE ONLY public."Departamento"
    ADD CONSTRAINT "Departamento_pkey" PRIMARY KEY (id_departamento);

ALTER TABLE ONLY public."Escuela"
    ADD CONSTRAINT "Escuela_pkey" PRIMARY KEY (id_escuela);

ALTER TABLE ONLY public."EstadoCurso"
    ADD CONSTRAINT "EstadoCurso_pkey" PRIMARY KEY ("id_estadoCurso");

ALTER TABLE ONLY public."Estudiante"
    ADD CONSTRAINT "Estudiante_pkey" PRIMARY KEY (id_estudiante);

ALTER TABLE ONLY public."Grupo"
    ADD CONSTRAINT "Grupo_pkey" PRIMARY KEY (id_grupo);

ALTER TABLE ONLY public."HistorialAcademico"
    ADD CONSTRAINT "HistorialAcademico_pkey" PRIMARY KEY (id_historial);

ALTER TABLE ONLY public."HistorialRetiros"
    ADD CONSTRAINT "HistorialRetiros_pkey" PRIMARY KEY (id_retiro);

ALTER TABLE ONLY public."HistorialSolicitudes"
    ADD CONSTRAINT "HistorialSolicitudes_pkey" PRIMARY KEY (id_historial_solicitud);

ALTER TABLE ONLY public."HorarioClases"
    ADD CONSTRAINT "HorarioClases_pkey" PRIMARY KEY (id_horario_clases);

ALTER TABLE ONLY public."Persona"
    ADD CONSTRAINT "Persona_pkey" PRIMARY KEY (identificacion);

ALTER TABLE ONLY public."Procesos"
    ADD CONSTRAINT "Procesos_pkey" PRIMARY KEY (id_proceso);

ALTER TABLE ONLY public."Profesor"
    ADD CONSTRAINT "Profesor_pkey" PRIMARY KEY (id_profesor);

ALTER TABLE ONLY public."SedeEscuela"
    ADD CONSTRAINT "SedeEscuela_pkey" PRIMARY KEY ("id_sedeXescuela");

ALTER TABLE ONLY public."Sede"
    ADD CONSTRAINT "Sede_pkey" PRIMARY KEY (id_sede);

ALTER TABLE ONLY public."Solicitudes"
    ADD CONSTRAINT "Solicitudes_pkey" PRIMARY KEY (id_solicitud);

ALTER TABLE ONLY public."Tipo Identificación"
    ADD CONSTRAINT "Tipo Identificación_pkey" PRIMARY KEY (id_tipo);

ALTER TABLE ONLY public."citasMatricula"
    ADD CONSTRAINT "citasMatricula_pkey" PRIMARY KEY (id_cita);

-- Claves foráneas
ALTER TABLE ONLY public."Persona"
    ADD CONSTRAINT "FK_Persona" FOREIGN KEY (id_tipo) REFERENCES public."Tipo Identificación"(id_tipo);

ALTER TABLE ONLY public."Administrativo"
    ADD CONSTRAINT "FK_administrativo_departamento" FOREIGN KEY (id_departamento) REFERENCES public."Departamento"(id_departamento) NOT VALID;

ALTER TABLE ONLY public."Administrativo"
    ADD CONSTRAINT "FK_administrativo_sedeXescuela" FOREIGN KEY ("id_sedeXescuela") REFERENCES public."SedeEscuela"("id_sedeXescuela") NOT VALID;

ALTER TABLE ONLY public."Carrera"
    ADD CONSTRAINT "FK_carrera_sedeXescuela" FOREIGN KEY ("id_sedeXescuela") REFERENCES public."SedeEscuela"("id_sedeXescuela");

ALTER TABLE ONLY public."citasMatricula"
    ADD CONSTRAINT "FK_citaMatricula_estudiante" FOREIGN KEY (id_estudiante) REFERENCES public."Estudiante"(id_estudiante);

ALTER TABLE ONLY public."Curso"
    ADD CONSTRAINT "FK_curso_escuela" FOREIGN KEY (id_escuela) REFERENCES public."Escuela"(id_escuela);

ALTER TABLE ONLY public."Estudiante"
    ADD CONSTRAINT "FK_estudiante_carrera" FOREIGN KEY (id_carrera) REFERENCES public."Carrera"(id_carrera) NOT VALID;

ALTER TABLE ONLY public."Estudiante"
    ADD CONSTRAINT "FK_estudiante_sede" FOREIGN KEY (id_sede) REFERENCES public."Sede"(id_sede) NOT VALID;

ALTER TABLE ONLY public."Grupo"
    ADD CONSTRAINT "FK_grupo_curso" FOREIGN KEY (codigo_curso) REFERENCES public."Curso"(codigo_curso) NOT VALID;

ALTER TABLE ONLY public."Grupo"
    ADD CONSTRAINT "FK_grupo_profesor" FOREIGN KEY (id_profesor) REFERENCES public."Profesor"(id_profesor);

ALTER TABLE ONLY public."Grupo"
    ADD CONSTRAINT "FK_grupo_sedeXescuela" FOREIGN KEY ("id_sedeXescuela") REFERENCES public."SedeEscuela"("id_sedeXescuela") NOT VALID;

ALTER TABLE ONLY public."HistorialRetiros"
    ADD CONSTRAINT "FK_historialRetiros_curso" FOREIGN KEY (codigo_curso) REFERENCES public."Curso"(codigo_curso);

ALTER TABLE ONLY public."HistorialRetiros"
    ADD CONSTRAINT "FK_historialRetiros_estudiante" FOREIGN KEY (id_estudiante) REFERENCES public."Estudiante"(id_estudiante);

ALTER TABLE ONLY public."HistorialSolicitudes"
    ADD CONSTRAINT "FK_historialSolicitud" FOREIGN KEY (id_solicitud) REFERENCES public."Solicitudes"(id_solicitud);

ALTER TABLE ONLY public."HistorialSolicitudes"
    ADD CONSTRAINT "FK_historialSolicitud_curso" FOREIGN KEY (codigo_curso) REFERENCES public."Curso"(codigo_curso);

ALTER TABLE ONLY public."HistorialSolicitudes"
    ADD CONSTRAINT "FK_historialSolicitud_estudiante" FOREIGN KEY (id_estudiante) REFERENCES public."Estudiante"(id_estudiante);

ALTER TABLE ONLY public."HistorialAcademico"
    ADD CONSTRAINT "FK_historial_codigoCurso" FOREIGN KEY (codigo_curso) REFERENCES public."Curso"(codigo_curso);

ALTER TABLE ONLY public."HistorialAcademico"
    ADD CONSTRAINT "FK_historial_estadoCurso" FOREIGN KEY ("id_estadoCurso") REFERENCES public."EstadoCurso"("id_estadoCurso") NOT VALID;

ALTER TABLE ONLY public."HistorialAcademico"
    ADD CONSTRAINT "FK_historial_sedeXescuela" FOREIGN KEY ("id_sedeXescuela") REFERENCES public."SedeEscuela"("id_sedeXescuela");

ALTER TABLE ONLY public."HorarioClases"
    ADD CONSTRAINT "FK_horarioClases_grupo" FOREIGN KEY (id_grupo) REFERENCES public."Grupo"(id_grupo);

ALTER TABLE ONLY public."Procesos"
    ADD CONSTRAINT "FK_procesos_administrador" FOREIGN KEY (id_admin) REFERENCES public."Administrativo"(id_admin);

ALTER TABLE ONLY public."Procesos"
    ADD CONSTRAINT "FK_procesos_sedeXescuela" FOREIGN KEY ("id_sedeXescuela") REFERENCES public."SedeEscuela"("id_sedeXescuela");

ALTER TABLE ONLY public."Profesor"
    ADD CONSTRAINT "FK_profesor_escuela" FOREIGN KEY (id_escuela) REFERENCES public."Escuela"(id_escuela) NOT VALID;

ALTER TABLE ONLY public."SedeEscuela"
    ADD CONSTRAINT "FK_sedeXescuela_escuela" FOREIGN KEY (id_escuela) REFERENCES public."Escuela"(id_escuela) NOT VALID;

ALTER TABLE ONLY public."SedeEscuela"
    ADD CONSTRAINT "FK_sedeXescuela_sede" FOREIGN KEY (id_sede) REFERENCES public."Sede"(id_sede) NOT VALID;

ALTER TABLE ONLY public."Solicitudes"
    ADD CONSTRAINT "FK_solicitudes_estudiante" FOREIGN KEY (id_estudiante) REFERENCES public."Estudiante"(id_estudiante);

ALTER TABLE ONLY public."Solicitudes"
    ADD CONSTRAINT "FK_solicitudes_grupo" FOREIGN KEY (id_grupo) REFERENCES public."Grupo"(id_grupo);

