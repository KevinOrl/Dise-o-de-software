ALTER TABLE public."Departamento" 
    ALTER COLUMN nombre TYPE character varying(150)[] USING nombre;

-- También conviene aumentar la capacidad de otras tablas con nombres potencialmente largos
ALTER TABLE public."Escuela" 
    ALTER COLUMN nombre TYPE character varying(100)[] USING nombre;

ALTER TABLE public."Carrera" 
    ALTER COLUMN nombre TYPE character varying(100)[] USING nombre;

-- Confirmar cambio
COMMENT ON TABLE public."Departamento" IS 'Almacena los departamentos del TEC con nombres de hasta 150 caracteres';

-- Tabla: Requisitos (para manejar requisitos y correquisitos)
CREATE TABLE public."Requisitos" (
    id_requisito SERIAL NOT NULL,
    codigo_curso character varying(6) NOT NULL,  -- Curso que tiene el requisito
    codigo_requisito character varying(6) NOT NULL,  -- Curso que es requisito/correquisito
    tipo integer NOT NULL,  -- 1=Requisito, 2=Correquisito
    CONSTRAINT "Requisitos_pkey" PRIMARY KEY (id_requisito),
    CONSTRAINT "FK_requisito_curso" FOREIGN KEY (codigo_curso) 
        REFERENCES public."Curso"(codigo_curso) ON DELETE CASCADE,
    CONSTRAINT "FK_requisito_prerequisito" FOREIGN KEY (codigo_requisito) 
        REFERENCES public."Curso"(codigo_curso) ON DELETE CASCADE,
    CONSTRAINT "tipo_valido" CHECK (tipo IN (1, 2))
);

-- Agregar comentarios para claridad
COMMENT ON TABLE public."Requisitos" IS 'Almacena los requisitos y correquisitos de los cursos';
COMMENT ON COLUMN public."Requisitos".tipo IS '1=Requisito, 2=Correquisito';

-- Asignar propietario 
ALTER TABLE public."Requisitos" OWNER TO postgres;

-- Crear un índice para mejorar el rendimiento de las consultas
CREATE INDEX "idx_requisitos_curso" ON public."Requisitos" (codigo_curso);

-- Agregar restricción para evitar que un curso sea requisito de sí mismo
ALTER TABLE public."Requisitos"
    ADD CONSTRAINT "no_auto_requisito" CHECK (codigo_curso <> codigo_requisito);

INSERT INTO public."Tipo Identificación" (id_tipo, nombre) VALUES
(1, ARRAY['Cédula Nacional']),
(2, ARRAY['DIMEX']),
(3, ARRAY['Pasaporte']);


-- Insertar departamentos del TEC
INSERT INTO public."Departamento" (id_departamento, nombre) VALUES
(1, ARRAY['Auditoría Interna']),
(2, ARRAY['Biblioteca José Figueres Ferrer']),
(3, ARRAY['Centro de Desarrollo Académico (CEDA)']),
(4, ARRAY['Centro de Vinculación Universidad Empresa']),
(5, ARRAY['Clínica de Atención Integral en Salud']),
(6, ARRAY['Clúster de Logística del Caribe']),
(7, ARRAY['Comisión de Asuntos Académicos y Estudiantiles']),
(8, ARRAY['Comisión de Estatuto Orgánico']),
(9, ARRAY['Comisión de Planificación y Administración']),
(10, ARRAY['Congreso Institucional']),
(11, ARRAY['Departamento de Administración de Mantenimiento']),
(12, ARRAY['Departamento de Administración de Tecnologías de Información y Comunicaciones (DATIC)']),
(13, ARRAY['Departamento de Admisión y Registro']),
(14, ARRAY['Departamento de Aprovisionamiento']),
(15, ARRAY['Departamento de Becas y Gestión Social']),
(16, ARRAY['Departamento de Gestión del Talento Humano']),
(17, ARRAY['Departamento de Orientación y Psicología (DOP)']),
(18, ARRAY['Departamento de Servicios Generales']),
(19, ARRAY['Departamento de Vida Estudiantil y Servicios Académicos (DEVESA)']),
(20, ARRAY['Departamento de Vida Estudiantil y Servicios Académicos, Campus Tecnológico Local San Carlos']),
(21, ARRAY['Departamento Financiero Contable']),
(22, ARRAY['Dirección de Cooperación y Asuntos Internacionales']),
(23, ARRAY['Dirección de Extensión']),
(24, ARRAY['Dirección de Investigación']),
(25, ARRAY['Dirección de Posgrado']),
(26, ARRAY['Editorial Tecnológica de Costa Rica']),
(27, ARRAY['Federación de Estudiantes del Tecnológico de Costa Rica (FEITEC)']),
(28, ARRAY['Oficina de Asesoría Legal']),
(29, ARRAY['Oficina de Comunicación y Mercadeo']),
(30, ARRAY['Oficina de Equidad de Género']),
(31, ARRAY['Oficina de Ingeniería']),
(32, ARRAY['Oficina de Planificación Institucional, (OPI)']),
(33, ARRAY['Rectoría']),
(34, ARRAY['Restaurante Institucional']),
(35, ARRAY['Sistema de Bibliotecas (SIBITEC)']),
(36, ARRAY['TEC Digital']),
(37, ARRAY['TEC Emprende Lab']),
(38, ARRAY['Tribunal Institucional Electoral']),
(39, ARRAY['Unidad de Análisis y Gestión de la Información']),
(40, ARRAY['Unidad de Conserjería']),
(41, ARRAY['Unidad de Formulación y Evaluación de Planes Institucionales (UFEPI)']),
(42, ARRAY['Unidad de Maquinaria Agrícola']),
(43, ARRAY['Unidad de Publicaciones']),
(44, ARRAY['Unidad de Seguridad y Vigilancia USEVI']),
(45, ARRAY['Unidad de Transportes']),
(46, ARRAY['Unidad del Centro de Archivo y Comunicación']),
(47, ARRAY['Unidad Especializada de Control Interno (UECI)']),
(48, ARRAY['Unidad Especializada de Investigación contra el Acoso Laboral']),
(49, ARRAY['Unidad Institucional de Gestión Ambiental y Seguridad Laboral (GASEL)']),
(50, ARRAY['Vicerrectoría de Administración']),
(51, ARRAY['Vicerrectoría de Docencia']),
(52, ARRAY['Vicerrectoría de Investigación y Extensión']),
(53, ARRAY['Vicerrectoría de Vida Estudiantil y Servicios Académicos']),
(54, ARRAY['Vivero Forestal']);

-- Primero modificamos la capacidad del campo nombre en la tabla Sede
ALTER TABLE public."Sede" 
    ALTER COLUMN nombre TYPE character varying(150)[] USING nombre;

-- Insertar las sedes del TEC
INSERT INTO public."Sede" (id_sede, nombre) VALUES
(1, ARRAY['Campus Tecnológico Central Cartago']),
(2, ARRAY['Campus Tecnológico Local San Carlos']),
(3, ARRAY['Campus Tecnológico Local San José']),
(4, ARRAY['Centro Académico de Alajuela']),
(5, ARRAY['Centro Académico de Limón']),
(6, ARRAY['Centro de Transferencia Tecnológica y Educación Continua del Campus Tecnológico Local San Carlos']);

-- Agregar comentario a la tabla
COMMENT ON TABLE public."Sede" IS 'Almacena las sedes y centros académicos del TEC';

-- Primero aumentamos la capacidad del campo nombre
ALTER TABLE public."Escuela" 
    ALTER COLUMN nombre TYPE character varying(100)[] USING nombre;

-- Insertar todas las escuelas del TEC
INSERT INTO public."Escuela" (id_escuela, nombre) VALUES
(1, ARRAY['Escuela de Administración de Empresas']),
(2, ARRAY['Escuela de Administración de Tecnologías de Información']),
(3, ARRAY['Escuela de Agronegocios']),
(4, ARRAY['Escuela de Arquitectura y Urbanismo']),
(5, ARRAY['Escuela de Biología']),
(6, ARRAY['Escuela de Ciencia e Ingeniería de los Materiales']),
(7, ARRAY['Escuela de Ciencias del Lenguaje']),
(8, ARRAY['Escuela de Ciencias Naturales y Exactas']),
(9, ARRAY['Escuela de Ciencias Sociales']),
(10, ARRAY['Escuela de Cultura y Deporte']),
(11, ARRAY['Escuela de Diseño Industrial']),
(12, ARRAY['Escuela de Educación Técnica']),
(13, ARRAY['Escuela de Física']),
(14, ARRAY['Escuela de Idiomas y Ciencias Sociales']),
(15, ARRAY['Escuela de Ingeniería Agrícola']),
(16, ARRAY['Escuela de Ingeniería Electromecánica']),
(17, ARRAY['Escuela de Ingeniería Electrónica']),
(18, ARRAY['Escuela de Ingeniería en Agronomía']),
(19, ARRAY['Escuela de Ingeniería en Computación']),
(20, ARRAY['Escuela de Ingeniería en Computadores']),
(21, ARRAY['Escuela de Ingeniería en Construcción']),
(22, ARRAY['Escuela de Ingeniería en Producción Industrial']),
(23, ARRAY['Escuela de Ingeniería en Seguridad Laboral e Higiene Ambiental']),
(24, ARRAY['Escuela de Ingeniería Forestal']),
(25, ARRAY['Escuela de Ingeniería Mecatrónica']),
(26, ARRAY['Escuela de Matemática']),
(27, ARRAY['Escuela de Química']);

-- Agregar comentario a la tabla
COMMENT ON TABLE public."Escuela" IS 'Almacena las escuelas académicas del TEC';

-- PRIMERO: Aumentar la capacidad del campo nombre en tablas
ALTER TABLE public."Carrera" 
    ALTER COLUMN nombre TYPE character varying(100)[] USING nombre;

-- SEGUNDO: Insertar relaciones entre sedes y escuelas
INSERT INTO public."SedeEscuela" ("id_sedeXescuela", id_sede, id_escuela) VALUES
-- Escuelas que están en todas las sedes
-- Ciencias del Lenguaje (id=7)
(1, 1, 7),  -- Cartago
(2, 2, 7),  -- San Carlos
(3, 3, 7),  -- San José
(4, 4, 7),  -- Alajuela
(5, 5, 7),  -- Limón
-- Cultura y Deporte (id=10)
(6, 1, 10),  -- Cartago
(7, 2, 10),  -- San Carlos
(8, 3, 10),  -- San José
(9, 4, 10),  -- Alajuela
(10, 5, 10), -- Limón
-- Idiomas y Ciencias Sociales (id=14)
(11, 1, 14), -- Cartago
(12, 2, 14), -- San Carlos
(13, 3, 14), -- San José
(14, 4, 14), -- Alajuela
(15, 5, 14), -- Limón

-- CARTAGO (id=1)
(16, 1, 1),  -- Administración de Empresas
(17, 1, 19), -- Ingeniería en Computación
(18, 1, 21), -- Ingeniería en Construcción
(19, 1, 17), -- Ingeniería en Electrónica
(20, 1, 24), -- Ingeniería Forestal
(21, 1, 15), -- Ingeniería Agrícola
(22, 1, 5),  -- Biología (para Biotecnología)
(23, 1, 16), -- Ingeniería Electromecánica (para Mantenimiento Industrial)
(24, 1, 22), -- Ingeniería en Producción Industrial
(25, 1, 23), -- Ingeniería en Seguridad Laboral e Higiene Ambiental
(26, 1, 6),  -- Ciencia e Ingeniería de los Materiales
(27, 1, 27), -- Química (para Ingeniería Ambiental)
(28, 1, 2),  -- Administración de Tecnologías de Información
(29, 1, 11), -- Diseño Industrial
(30, 1, 20), -- Ingeniería en Computadores
(31, 1, 25), -- Ingeniería Mecatrónica
(32, 1, 3),  -- Agronegocios
(33, 1, 13), -- Física
(34, 1, 26), -- Matemática

-- SAN CARLOS (id=2)
(35, 2, 18), -- Ingeniería en Agronomía
(36, 2, 1),  -- Administración de Empresas
(37, 2, 19), -- Ingeniería en Computación
(38, 2, 22), -- Ingeniería en Producción Industrial
(39, 2, 17), -- Ingeniería en Electrónica
(40, 2, 3),  -- Agronegocios (para Gestión en Sostenibilidad Turística)

-- SAN JOSÉ (id=3)
(41, 3, 1),  -- Administración de Empresas
(42, 3, 4),  -- Arquitectura y Urbanismo
(43, 3, 19), -- Ingeniería en Computación

-- ALAJUELA (id=4)
(44, 4, 19), -- Ingeniería en Computación
(45, 4, 17), -- Ingeniería en Electrónica

-- LIMÓN (id=5)
(46, 5, 1),  -- Administración de Empresas
(47, 5, 22), -- Ingeniería en Producción Industrial
(48, 5, 19); -- Ingeniería en Computación

-- TERCERO: Insertar carreras asociadas a las relaciones sede-escuela
INSERT INTO public."Carrera" (id_carrera, nombre, "id_sedeXescuela") VALUES
-- CARTAGO
(1, ARRAY['Administración de Empresas - Diurna'], 16),
(2, ARRAY['Administración de Empresas - Nocturna'], 16),
(3, ARRAY['Ingeniería en Computación'], 17),
(4, ARRAY['Ingeniería en Construcción'], 18),
(5, ARRAY['Ingeniería en Electrónica'], 19),
(6, ARRAY['Ingeniería Forestal'], 20),
(7, ARRAY['Ingeniería Agrícola'], 21),
(8, ARRAY['Ingeniería en Biotecnología'], 22),
(9, ARRAY['Ingeniería en Mantenimiento Industrial'], 23),
(10, ARRAY['Ingeniería en Producción Industrial'], 24),
(11, ARRAY['Ingeniería en Seguridad Laboral e Higiene Ambiental'], 25),
(12, ARRAY['Ingeniería en Materiales'], 26),
(13, ARRAY['Ingeniería Ambiental'], 27),
(14, ARRAY['Administración de Tecnología de Información'], 28),
(15, ARRAY['Ingeniería en Diseño Industrial'], 29),
(16, ARRAY['Ingeniería en Computadores'], 30),
(17, ARRAY['Ingeniería Mecatrónica'], 31),
(18, ARRAY['Ingeniería en Agronegocios'], 32),
(19, ARRAY['Ingeniería Física'], 33),
(20, ARRAY['Enseñanza de la Matemática con Entornos Tecnológicos'], 34),

-- SAN CARLOS
(21, ARRAY['Ingeniería en Agronomía'], 35),
(22, ARRAY['Administración de Empresas'], 36),
(23, ARRAY['Ingeniería en Computación'], 37),
(24, ARRAY['Ingeniería en Producción Industrial'], 38),
(25, ARRAY['Ingeniería en Electrónica'], 39),
(26, ARRAY['Gestión en Sostenibilidad Turística'], 40),

-- SAN JOSÉ
(27, ARRAY['Administración de Empresas - Nocturna'], 41),
(28, ARRAY['Arquitectura y Urbanismo'], 42),
(29, ARRAY['Ingeniería en Computación'], 43),

-- ALAJUELA
(30, ARRAY['Ingeniería en Computación'], 44),
(31, ARRAY['Ingeniería en Electrónica'], 45),

-- LIMÓN
(32, ARRAY['Administración de Empresas - Nocturna'], 46),
(33, ARRAY['Ingeniería en Producción Industrial'], 47),
(34, ARRAY['Ingeniería en Computación'], 48);


-- 1. Agregar el campo horas a la tabla Curso si no existe
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT FROM information_schema.columns 
    WHERE table_name = 'Curso' AND column_name = 'horas'
  ) THEN
    ALTER TABLE public."Curso" ADD COLUMN horas integer;
  END IF;
END $$;

-- 2. Modificar la capacidad del campo nombre en la tabla Curso
ALTER TABLE public."Curso" 
    ALTER COLUMN nombre TYPE character varying(100)[] USING nombre;




-- 1. Modificar la tabla Requisitos para incluir el plan de estudios
ALTER TABLE public."Requisitos" 
ADD COLUMN id_plan integer;

-- 2. Crear las tablas de Plan de Estudio
CREATE TABLE IF NOT EXISTS public."PlanEstudio" (
    id_plan SERIAL NOT NULL,
    nombre character varying(100)[] NOT NULL,
    id_carrera integer NOT NULL,
    anio_inicio integer NOT NULL,
    vigente boolean DEFAULT true,
    CONSTRAINT "PlanEstudio_pkey" PRIMARY KEY (id_plan),
    CONSTRAINT "FK_plan_carrera" FOREIGN KEY (id_carrera) 
        REFERENCES public."Carrera"(id_carrera) ON DELETE CASCADE
);
ALTER TABLE public."PlanEstudio" OWNER TO postgres;

CREATE TABLE IF NOT EXISTS public."PlanCurso" (
    id_plan_curso SERIAL NOT NULL,
    id_plan integer NOT NULL,
    codigo_curso character varying(6) NOT NULL,
    bloque integer NOT NULL,
    optativo boolean DEFAULT false,
    CONSTRAINT "PlanCurso_pkey" PRIMARY KEY (id_plan_curso),
    CONSTRAINT "FK_planCurso_plan" FOREIGN KEY (id_plan) 
        REFERENCES public."PlanEstudio"(id_plan) ON DELETE CASCADE,
    CONSTRAINT "FK_planCurso_curso" FOREIGN KEY (codigo_curso) 
        REFERENCES public."Curso"(codigo_curso) ON DELETE CASCADE
);
ALTER TABLE public."PlanCurso" OWNER TO postgres;

-- 3. Agregar la referencia del plan a la tabla Requisitos
ALTER TABLE public."Requisitos"
ADD CONSTRAINT "FK_requisito_plan" FOREIGN KEY (id_plan) 
    REFERENCES public."PlanEstudio"(id_plan) ON DELETE CASCADE;

-- 4. Modificar la tabla Estudiante para agregar el plan de estudios
ALTER TABLE public."Estudiante"
ADD COLUMN id_plan integer,
ADD CONSTRAINT "FK_estudiante_plan" FOREIGN KEY (id_plan) 
    REFERENCES public."PlanEstudio"(id_plan);


-- 6. Modificar la capacidad del campo nombre en la tabla Curso
ALTER TABLE public."Curso" 
    ALTER COLUMN nombre TYPE character varying(100)[] USING nombre;

-- 7. Insertar cursos del plan de ATI
INSERT INTO public."Curso" (codigo_curso, nombre, creditos, horas, id_escuela) VALUES
-- Bloque 0
('CI0200', ARRAY['EXAMEN DIAGNÓSTICO'], 0, 0, 7),
('CI0202', ARRAY['INGLÉS BÁSICO'], 2, 3, 7),
('MA0101', ARRAY['MATEMÁTICA GENERAL'], 2, 5, 26),

-- Bloque 1
('CI1106', ARRAY['COMUNICACIÓN ESCRITA'], 2, 6, 7),
('MA1403', ARRAY['MATEMÁTICA DISCRETA'], 4, 4, 26),
('SE1100', ARRAY['ACTIVIDAD CULTURAL I'], 0, 2, 10),
('TI1102', ARRAY['INFORMACIÓN CONTABLE'], 3, 9, 2),
('TI1103', ARRAY['MODELOS ORGANIZACIONALES Y GESTIÓN DE TI'], 3, 9, 2),
('TI1400', ARRAY['INTRODUCCIÓN A LA PROGRAMACIÓN'], 3, 4, 2),
('TI1401', ARRAY['TALLER DE PROGRAMACIÓN'], 3, 4, 2),

-- Bloque 2
('CI1107', ARRAY['COMUNICACIÓN ORAL'], 1, 3, 7),
('FH1000', ARRAY['CENTROS DE FORMACIÓN HUMANÍSTICA'], 0, 2, 9),
('MA1102', ARRAY['CÁLCULO DIFERENCIAL E INTEGRAL'], 4, 5, 26),
('SE1200', ARRAY['ACTIVIDAD DEPORTIVA I'], 0, 2, 10),
('TI1201', ARRAY['COMPORTAMIENTO ORGANIZACIONAL Y TALENTO HUMANO'], 3, 9, 2),
('TI2402', ARRAY['ALGORITMOS Y ESTRUCTURAS DE DATOS'], 4, 4, 2),
('TI2404', ARRAY['ORGANIZACIÓN Y ARQUITECTURA DE COMPUTADORAS'], 3, 4, 2),
('TI4500', ARRAY['INGENIERÍA DE REQUERIMIENTOS'], 3, 4, 2),

-- Bloque 3
('CI3400', ARRAY['INGLÉS 1 (ATI)'], 2, 6, 7),
('MA1103', ARRAY['CÁLCULO Y ALGEBRA LINEAL'], 4, 4, 26),
('SE1400', ARRAY['ACTIVIDAD CULTURAL-DEPORTIVA'], 0, 2, 10),
('TI2800', ARRAY['ADMINISTRACIÓN DE PROYECTOS I'], 3, 9, 2),
('TI3103', ARRAY['COSTOS EN AMBIENTES INFORMÁTICOS'], 3, 4, 2),
('TI3600', ARRAY['BASES DE DATOS'], 3, 4, 2),
('TI4200', ARRAY['ECONOMÍA'], 3, 4, 2),

-- Bloque 4
('CI4401', ARRAY['INGLÉS II (ATI)'], 2, 6, 7),
('MA2404', ARRAY['PROBABILIDADES'], 4, 4, 26),
('TI2201', ARRAY['PROGRAMACIÓN ORIENTADA A OBJETOS'], 3, 9, 2),
('TI3801', ARRAY['ADMINISTRACIÓN DE PROYECTOS II'], 3, 4, 2),
('TI4101', ARRAY['PLANIFICACIÓN Y PRESUPUESTO'], 2, 4, 2),
('TI4601', ARRAY['BASES DE DATOS AVANZADOS'], 4, 4, 2),

-- Bloque 5
('CS3404', ARRAY['SEMINARIO DE ÉTICA PARA LA INGENIERÍA'], 2, 5, 9),
('MA3405', ARRAY['ESTADÍSTICA'], 4, 4, 26),
('TI3500', ARRAY['MERCADEO EN LA ERA DIGITAL'], 3, 9, 2),
('TI3501', ARRAY['FUNDAMENTOS DE SISTEMAS OPERATIVOS'], 3, 9, 2),
('TI5100', ARRAY['GESTIÓN Y TOMA DE DECISIONES FINANCIERAS'], 3, 4, 2),
('TI5501', ARRAY['DISEÑO DE SOFTWARE'], 3, 4, 2),

-- Bloque 6
('CS2304', ARRAY['DERECHO LABORAL'], 2, 3, 9),
('TI3601', ARRAY['MODELO DE TOMA DE DECISIONES'], 2, 6, 2),
('TI3602', ARRAY['PRODUCCIÓN, LOGÍSTICA Y CALIDAD'], 2, 6, 2),
('TI3603', ARRAY['CALIDAD EN SISTEMAS DE INFORMACIÓN'], 3, 9, 2),
('TI3604', ARRAY['FUNDAMENTOS DE REDES'], 3, 9, 2),
('TI6900', ARRAY['INTELIGENCIA DE NEGOCIOS'], 3, 9, 2),
('TI9003', ARRAY['COMPUTACIÓN Y SOCIEDAD'], 2, 4, 2),

-- Bloque 7
('CS3405', ARRAY['DERECHO INFORMÁTICO Y MERCANTIL'], 3, 9, 9),
('TI4701', ARRAY['SEGURIDAD EN SISTEMAS DE INFORMACIÓN'], 3, 9, 2),
('TI5000', ARRAY['ELECTIVA 1'], 3, 4, 2),
('TI7503', ARRAY['ARQUITECTURA DE APLICACIONES'], 3, 9, 2),
('TI7901', ARRAY['NEGOCIOS ELECTRÓNICOS'], 3, 4, 2),
('TI8109', ARRAY['FORMULACIÓN Y EVALUACIÓN DE PROYECTOS DE TI'], 3, 4, 2),

-- Bloque 8
('TI6000', ARRAY['ELECTIVA 2'], 3, 9, 2),
('TI8902', ARRAY['ADQUISICIÓN DE TI'], 3, 4, 2),
('TI8904', ARRAY['ADMINISTRACIÓN DE PROCESOS DE NEGOCIOS'], 3, 9, 2),
('TI8905', ARRAY['ADMINISTRACIÓN DE SERVICIOS DE TECNOLOGÍAS DE INFORMACIÓN I'], 3, 9, 2),
('TI9805', ARRAY['AUDITORÍA DE TI'], 3, 4, 2),
('TI9905', ARRAY['SISTEMAS DE INFORMACIÓN EMPRESARIAL'], 3, 4, 2),

-- Bloque 9
('TI5901', ARRAY['ESPÍRITU EMPRENDEDOR Y CREACIÓN DE EMPRESAS'], 3, 13, 2),
('TI5902', ARRAY['ANALÍTICA EMPRESARIAL'], 3, 9, 2),
('TI5903', ARRAY['PLANIFICACIÓN ESTRATÉGICA DE TECNOLOGÍA DE INFORMACIÓN'], 3, 9, 2),
('TI5904', ARRAY['INVESTIGACIÓN EN SISTEMAS DE INFORMACIÓN'], 3, 9, 2),
('TI5905', ARRAY['FUNDAMENTOS DE ARQUITECTURA EMPRESARIAL'], 3, 9, 2),
('TI9004', ARRAY['ADMINISTRACIÓN DE SERVICIOS DE TECNOLOGÍAS DE INFORMACIÓN II'], 3, 9, 2),

-- Bloque 10
('TI9000', ARRAY['TRABAJO FINAL DE GRADUACIÓN'], 10, 0, 2)
ON CONFLICT (codigo_curso) DO UPDATE 
SET nombre = EXCLUDED.nombre, 
    creditos = EXCLUDED.creditos, 
    horas = EXCLUDED.horas, 
    id_escuela = EXCLUDED.id_escuela;

-- 8. Insertar el plan de estudios de ATI
INSERT INTO public."PlanEstudio" (id_plan, nombre, id_carrera, anio_inicio, vigente) 
VALUES (1, ARRAY['Plan 2023 - Administración de Tecnologías de Información'], 2, 2023, true)
ON CONFLICT DO NOTHING;

-- 9. Insertar los cursos en el plan por bloques
INSERT INTO public."PlanCurso" (id_plan, codigo_curso, bloque) VALUES
-- Bloque 0
(1, 'CI0200', 0),
(1, 'CI0202', 0),
(1, 'MA0101', 0),

-- Bloque 1
(1, 'CI1106', 1),
(1, 'MA1403', 1),
(1, 'SE1100', 1),
(1, 'TI1102', 1),
(1, 'TI1103', 1),
(1, 'TI1400', 1),
(1, 'TI1401', 1),

-- Bloque 2
(1, 'CI1107', 2),
(1, 'FH1000', 2),
(1, 'MA1102', 2),
(1, 'SE1200', 2),
(1, 'TI1201', 2),
(1, 'TI2402', 2),
(1, 'TI2404', 2),
(1, 'TI4500', 2),

-- Bloque 3
(1, 'CI3400', 3),
(1, 'MA1103', 3),
(1, 'SE1400', 3),
(1, 'TI2800', 3),
(1, 'TI3103', 3),
(1, 'TI3600', 3),
(1, 'TI4200', 3),

-- Bloque 4
(1, 'CI4401', 4),
(1, 'MA2404', 4),
(1, 'TI2201', 4),
(1, 'TI3801', 4),
(1, 'TI4101', 4),
(1, 'TI4601', 4),

-- Bloque 5
(1, 'CS3404', 5),
(1, 'MA3405', 5),
(1, 'TI3500', 5),
(1, 'TI3501', 5),
(1, 'TI5100', 5),
(1, 'TI5501', 5),

-- Bloque 6
(1, 'CS2304', 6),
(1, 'TI3601', 6),
(1, 'TI3602', 6),
(1, 'TI3603', 6),
(1, 'TI3604', 6),
(1, 'TI6900', 6),
(1, 'TI9003', 6),

-- Bloque 7
(1, 'CS3405', 7),
(1, 'TI4701', 7),
(1, 'TI5000', 7),
(1, 'TI7503', 7),
(1, 'TI7901', 7),
(1, 'TI8109', 7),

-- Bloque 8
(1, 'TI6000', 8),
(1, 'TI8902', 8),
(1, 'TI8904', 8),
(1, 'TI8905', 8),
(1, 'TI9805', 8),
(1, 'TI9905', 8),

-- Bloque 9
(1, 'TI5901', 9),
(1, 'TI5902', 9),
(1, 'TI5903', 9),
(1, 'TI5904', 9),
(1, 'TI5905', 9),
(1, 'TI9004', 9),

-- Bloque 10
(1, 'TI9000', 10)
ON CONFLICT DO NOTHING;

-- 10. Insertar los requisitos y correquisitos específicos para el plan de ATI
INSERT INTO public."Requisitos" (codigo_curso, codigo_requisito, tipo, id_plan) VALUES
-- Bloque 1
('TI1401', 'TI1400', 2, 1),  -- Correquisito

-- Bloque 2
('MA1102', 'MA0101', 1, 1),  -- Requisito
('MA1102', 'MA1403', 1, 1),  -- Requisito
('TI1201', 'TI1103', 1, 1),  -- Requisito
('TI2402', 'TI1400', 1, 1),  -- Requisito
('TI2402', 'TI1401', 1, 1),  -- Requisito
('TI2404', 'TI1401', 1, 1),  -- Requisito
('TI4500', 'TI1400', 1, 1),  -- Requisito

-- Bloque 3
('CI3400', 'CI0200', 1, 1),  -- Requisito
('CI3400', 'CI0202', 1, 1),  -- Requisito
('MA1103', 'MA1102', 1, 1),  -- Requisito
('TI2800', 'TI4500', 1, 1),  -- Requisito
('TI3103', 'TI1102', 1, 1),  -- Requisito
('TI3600', 'MA1403', 1, 1),  -- Requisito
('TI3600', 'TI2402', 1, 1),  -- Requisito
('TI4200', 'MA1102', 1, 1),  -- Requisito

-- Bloque 4
('CI4401', 'CI3400', 1, 1),  -- Requisito
('MA2404', 'MA1103', 1, 1),  -- Requisito
('TI2201', 'TI3600', 1, 1),  -- Requisito
('TI3801', 'TI2800', 1, 1),  -- Requisito
('TI4101', 'TI3103', 1, 1),  -- Requisito
('TI4601', 'TI3600', 1, 1),  -- Requisito

-- Bloque 5
('CS3404', 'TI3801', 1, 1),  -- Requisito
('MA3405', 'MA2404', 1, 1),  -- Requisito
('TI3500', 'MA2404', 1, 1),  -- Requisito
('TI3501', 'TI2201', 1, 1),  -- Requisito
('TI3501', 'TI2404', 1, 1),  -- Requisito
('TI5100', 'TI4101', 1, 1),  -- Requisito
('TI5100', 'TI4200', 1, 1),  -- Requisito
('TI5501', 'TI2201', 1, 1),  -- Requisito
('TI5501', 'TI4500', 1, 1),  -- Requisito

-- Bloque 6
('CS2304', 'CS3404', 1, 1),  -- Requisito
('TI3601', 'MA3405', 1, 1),  -- Requisito
('TI3601', 'TI5100', 1, 1),  -- Requisito
('TI3602', 'MA3405', 1, 1),  -- Requisito
('TI3602', 'TI5100', 1, 1),  -- Requisito
('TI3603', 'TI3801', 1, 1),  -- Requisito
('TI3603', 'TI5501', 1, 1),  -- Requisito
('TI3604', 'TI3501', 1, 1),  -- Requisito
('TI6900', 'TI4601', 1, 1),  -- Requisito
('TI9003', 'CS3404', 1, 1),  -- Requisito
('TI9003', 'TI1201', 1, 1),  -- Requisito

-- Bloque 7
('CS3405', 'TI1201', 1, 1),  -- Requisito
('TI4701', 'TI3604', 1, 1),  -- Requisito
('TI7503', 'TI3604', 1, 1),  -- Requisito
('TI7503', 'TI5501', 1, 1),  -- Requisito
('TI7901', 'TI3603', 1, 1),  -- Requisito
('TI7901', 'TI6900', 1, 1),  -- Requisito
('TI8109', 'TI3500', 1, 1),  -- Requisito
('TI8109', 'TI3601', 1, 1),  -- Requisito

-- Bloque 8
('TI8902', 'TI7503', 1, 1),  -- Requisito
('TI8902', 'TI8109', 1, 1),  -- Requisito
('TI8904', 'TI7503', 1, 1),  -- Requisito
('TI8905', 'TI4701', 1, 1),  -- Requisito
('TI8905', 'TI7901', 1, 1),  -- Requisito
('TI9805', 'TI4701', 1, 1),  -- Requisito
('TI9905', 'TI7901', 1, 1),  -- Requisito

-- Bloque 9
('TI5901', 'TI8109', 1, 1),  -- Requisito
('TI5902', 'TI9905', 1, 1),  -- Requisito
('TI5903', 'TI8902', 1, 1),  -- Requisito
('TI5904', 'TI8904', 1, 1),  -- Requisito
('TI5904', 'TI9905', 1, 1),  -- Requisito
('TI5905', 'TI8904', 1, 1),  -- Requisito
('TI9004', 'TI8905', 1, 1),  -- Requisito

-- Bloque 10
('TI9000', 'TI5901', 1, 1),  -- Requisito
('TI9000', 'TI5902', 1, 1),  -- Requisito
('TI9000', 'TI5903', 1, 1),  -- Requisito
('TI9000', 'TI5904', 1, 1),  -- Requisito
('TI9000', 'TI5905', 1, 1),  -- Requisito
('TI9000', 'TI9004', 1, 1)   -- Requisito
ON CONFLICT DO NOTHING;

-- 11. Agregar comentarios explicativos
COMMENT ON COLUMN public."Curso".horas IS 'Horas de dedicación semanal del curso';
COMMENT ON TABLE public."PlanEstudio" IS 'Almacena los diferentes planes de estudio de las carreras';
COMMENT ON TABLE public."PlanCurso" IS 'Relaciona los cursos con sus respectivos planes de estudio y bloques';
COMMENT ON COLUMN public."Requisitos".id_plan IS 'Plan específico al que aplica este requisito. NULL = aplica a todos los planes';
COMMENT ON COLUMN public."Estudiante".id_plan IS 'Plan de estudios al que está asociado el estudiante';

-- 12. Añadir índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS "idx_plancurso_plan" ON public."PlanCurso" (id_plan);
CREATE INDEX IF NOT EXISTS "idx_plancurso_curso" ON public."PlanCurso" (codigo_curso);
CREATE INDEX IF NOT EXISTS "idx_requisitos_curso" ON public."Requisitos" (codigo_curso);
CREATE INDEX IF NOT EXISTS "idx_requisitos_plan" ON public."Requisitos" (id_plan);




-- 5. Insertar cursos de Ingeniería en Computación
INSERT INTO public."Curso" (codigo_curso, nombre, creditos, horas, id_escuela) VALUES
-- Bloque 0
('CI0200', ARRAY['EXAMEN DIAGNÓSTICO'], 0, 0, 7),
('CI0202', ARRAY['INGLÉS BÁSICO'], 2, 3, 7),
('MA0101', ARRAY['MATEMÁTICA GENERAL'], 2, 5, 26),

-- Bloque 1
('CI1106', ARRAY['COMUNICACIÓN ESCRITA'], 2, 6, 7),
('IC1400', ARRAY['FUNDAMENTOS DE ORGANIZACIÓN DE COMPUTADORAS'], 3, 9, 19),
('IC1802', ARRAY['INTRODUCCIÓN A LA PROGRAMACIÓN'], 3, 4, 19),
('IC1803', ARRAY['TALLER DE PROGRAMACIÓN'], 3, 4, 19),
('MA1403', ARRAY['MATEMÁTICA DISCRETA'], 4, 4, 26),
('SE1100', ARRAY['ACTIVIDAD CULTURAL I'], 0, 2, 10),

-- Bloque 2
('CI1107', ARRAY['COMUNICACIÓN ORAL'], 1, 3, 7),
('CI1230', ARRAY['INGLÉS I'], 2, 6, 7),
('FH1000', ARRAY['CENTROS DE FORMACIÓN HUMANÍSTICA'], 0, 2, 9),
('IC2001', ARRAY['ESTRUCTURAS DE DATOS'], 4, 12, 19),
('IC2101', ARRAY['PROGRAMACIÓN ORIENTADA A OBJETOS'], 3, 9, 19),
('IC3101', ARRAY['ARQUITECTURA DE COMPUTADORES'], 4, 4, 19),
('MA1102', ARRAY['CÁLCULO DIFERENCIAL E INTEGRAL'], 4, 5, 26),
('SE1200', ARRAY['ACTIVIDAD DEPORTIVA I'], 0, 2, 10),

-- Bloque 3
('CI1231', ARRAY['INGLÉS II'], 2, 3, 7),
('IC3002', ARRAY['ANÁLISIS DE ALGORITMOS'], 4, 12, 19),
('IC4301', ARRAY['BASES DE DATOS I'], 4, 9, 19),
('IC5821', ARRAY['REQUERIMIENTOS DE SOFTWARE'], 4, 12, 19),
('MA1103', ARRAY['CÁLCULO Y ALGEBRA LINEAL'], 4, 4, 26),
('SE1400', ARRAY['ACTIVIDAD CULTURAL-DEPORTIVA'], 0, 2, 10),

-- Bloque 4
('CS2101', ARRAY['AMBIENTE HUMANO'], 2, 6, 9),
('IC4302', ARRAY['BASES DE DATOS II'], 3, 9, 19),
('IC4700', ARRAY['LENGUAJES DE PROGRAMACIÓN'], 4, 4, 19),
('IC6821', ARRAY['DISEÑO DE SOFTWARE'], 4, 12, 19),
('MA2404', ARRAY['PROBABILIDADES'], 4, 4, 26),

-- Bloque 5
('CS3401', ARRAY['SEMINARIO DE ESTUDIOS FILOSÓFICOS HISTÓRICOS'], 2, 3, 9),
('IC4810', ARRAY['ADMINISTRACIÓN DE PROYECTOS'], 4, 4, 19),
('IC5701', ARRAY['COMPILADORES E INTERPRETES'], 4, 4, 19),
('IC6831', ARRAY['ASEGURAMIENTO DE LA CALIDAD DEL SOFTWARE'], 3, 9, 19),
('MA3405', ARRAY['ESTADÍSTICA'], 4, 4, 26),

-- Bloque 6
('CS4402', ARRAY['SEMINARIO DE ESTUDIOS COSTARRICENSES'], 2, 3, 9),
('IC4003', ARRAY['ELECTIVA I'], 3, 4, 19),
('IC6400', ARRAY['INVESTIGACIÓN DE OPERACIONES'], 4, 4, 19),
('IC6600', ARRAY['PRINCIPIOS DE SISTEMAS OPERATIVOS'], 4, 4, 19),
('IC7900', ARRAY['COMPUTACIÓN Y SOCIEDAD'], 2, 7, 19),
('IC8071', ARRAY['SEGURIDAD DEL SOFTWARE'], 3, 9, 19),

-- Bloque 7
('AE4208', ARRAY['DESARROLLO DE EMPRENDEDORES'], 4, 4, 1),
('IC5001', ARRAY['ELECTIVA II'], 3, 4, 19),
('IC6200', ARRAY['INTELIGENCIA ARTIFICIAL'], 4, 4, 19),
('IC7602', ARRAY['REDES'], 4, 12, 19),
('IC7841', ARRAY['PROYECTO DE INGENIERÍA DE SOFTWARE'], 3, 9, 19),

-- Bloque 8
('IC8842', ARRAY['PRÁCTICA PROFESIONAL'], 12, 40, 19)
ON CONFLICT (codigo_curso) DO UPDATE 
SET nombre = EXCLUDED.nombre, 
    creditos = EXCLUDED.creditos, 
    horas = EXCLUDED.horas, 
    id_escuela = EXCLUDED.id_escuela;

-- 6. Insertar el plan de estudios de Ingeniería en Computación
INSERT INTO public."PlanEstudio" (id_plan, nombre, id_carrera, anio_inicio, vigente) 
VALUES (2, ARRAY['Plan 2023 - Ingeniería en Computación'], 3, 2023, true)
ON CONFLICT DO NOTHING;

-- 7. Insertar los cursos en el plan por bloques
INSERT INTO public."PlanCurso" (id_plan, codigo_curso, bloque) VALUES
-- Bloque 0
(2, 'CI0200', 0),
(2, 'CI0202', 0),
(2, 'MA0101', 0),

-- Bloque 1
(2, 'CI1106', 1),
(2, 'IC1400', 1),
(2, 'IC1802', 1),
(2, 'IC1803', 1),
(2, 'MA1403', 1),
(2, 'SE1100', 1),

-- Bloque 2
(2, 'CI1107', 2),
(2, 'CI1230', 2),
(2, 'FH1000', 2),
(2, 'IC2001', 2),
(2, 'IC2101', 2),
(2, 'IC3101', 2),
(2, 'MA1102', 2),
(2, 'SE1200', 2),

-- Bloque 3
(2, 'CI1231', 3),
(2, 'IC3002', 3),
(2, 'IC4301', 3),
(2, 'IC5821', 3),
(2, 'MA1103', 3),
(2, 'SE1400', 3),

-- Bloque 4
(2, 'CS2101', 4),
(2, 'IC4302', 4),
(2, 'IC4700', 4),
(2, 'IC6821', 4),
(2, 'MA2404', 4),

-- Bloque 5
(2, 'CS3401', 5),
(2, 'IC4810', 5),
(2, 'IC5701', 5),
(2, 'IC6831', 5),
(2, 'MA3405', 5),

-- Bloque 6
(2, 'CS4402', 6),
(2, 'IC4003', 6),
(2, 'IC6400', 6),
(2, 'IC6600', 6),
(2, 'IC7900', 6),
(2, 'IC8071', 6),

-- Bloque 7
(2, 'AE4208', 7),
(2, 'IC5001', 7),
(2, 'IC6200', 7),
(2, 'IC7602', 7),
(2, 'IC7841', 7),

-- Bloque 8
(2, 'IC8842', 8)
ON CONFLICT DO NOTHING;

-- 8. Insertar los requisitos y correquisitos específicos para el plan de Ing. en Computación
INSERT INTO public."Requisitos" (codigo_curso, codigo_requisito, tipo, id_plan) VALUES
-- Bloque 1
('IC1400', 'MA1403', 2, 2),  -- Correquisito

-- Bloque 2
('CI1107', 'CI1106', 1, 2),  -- Requisito
('CI1230', 'CI0200', 1, 2),  -- Requisito
('CI1230', 'CI0202', 1, 2),  -- Requisito
('IC2001', 'IC2101', 2, 2),  -- Correquisito
('IC2101', 'IC1802', 1, 2),  -- Requisito
('IC2101', 'IC1803', 1, 2),  -- Requisito
('IC3101', 'IC1400', 1, 2),  -- Requisito
('IC3101', 'IC1803', 1, 2),  -- Requisito
('MA1102', 'MA0101', 1, 2),  -- Requisito
('MA1102', 'MA1403', 1, 2),  -- Requisito

-- Bloque 3
('CI1231', 'CI1230', 1, 2),  -- Requisito
('IC3002', 'IC2001', 1, 2),  -- Requisito
('IC3002', 'MA1102', 1, 2),  -- Requisito
('IC4301', 'IC2001', 1, 2),  -- Requisito
('IC4301', 'MA1103', 2, 2),  -- Correquisito
('IC5821', 'IC4301', 2, 2),  -- Correquisito
('MA1103', 'MA1102', 1, 2),  -- Requisito

-- Bloque 4
('CS2101', 'CI1107', 1, 2),  -- Requisito
('IC4302', 'IC4301', 1, 2),  -- Requisito
('IC4700', 'IC3002', 1, 2),  -- Requisito
('IC4700', 'IC3101', 1, 2),  -- Requisito
('IC6821', 'IC5821', 1, 2),  -- Requisito
('MA2404', 'MA1103', 1, 2),  -- Requisito

-- Bloque 5
('CS3401', 'CS2101', 1, 2),  -- Requisito
('IC4810', 'IC5821', 1, 2),  -- Requisito
('IC5701', 'IC4700', 1, 2),  -- Requisito
('IC6831', 'IC6821', 1, 2),  -- Requisito
('IC6831', 'IC4810', 2, 2),  -- Correquisito
('MA3405', 'MA2404', 1, 2),  -- Requisito

-- Bloque 6
('CS4402', 'CS3401', 1, 2),  -- Requisito
('IC6400', 'MA3405', 1, 2),  -- Requisito
('IC6600', 'IC5701', 1, 2),  -- Requisito
('IC7900', 'IC4810', 1, 2),  -- Requisito
('IC7900', 'CS4402', 2, 2),  -- Correquisito
('IC8071', 'IC5701', 1, 2),  -- Requisito

-- Bloque 7
('AE4208', 'IC7841', 2, 2),  -- Correquisito
('IC6200', 'IC5701', 1, 2),  -- Requisito
('IC6200', 'IC6400', 1, 2),  -- Requisito
('IC7602', 'IC6600', 1, 2),  -- Requisito
('IC7841', 'IC4302', 1, 2),  -- Requisito
('IC7841', 'IC6831', 1, 2),  -- Requisito

-- Bloque 8
('IC8842', 'AE4208', 1, 2),  -- Requisito
('IC8842', 'FH1000', 1, 2),  -- Requisito
('IC8842', 'IC4003', 1, 2),  -- Requisito
('IC8842', 'IC5001', 1, 2),  -- Requisito
('IC8842', 'IC6200', 1, 2),  -- Requisito
('IC8842', 'IC7602', 1, 2),  -- Requisito
('IC8842', 'IC7841', 1, 2),  -- Requisito
('IC8842', 'SE1100', 1, 2),  -- Requisito
('IC8842', 'SE1200', 1, 2),  -- Requisito
('IC8842', 'SE1400', 1, 2)   -- Requisito
ON CONFLICT DO NOTHING;

-- 9. Agregar comentarios explicativos
COMMENT ON COLUMN public."Curso".horas IS 'Horas de dedicación semanal del curso';
COMMENT ON TABLE public."PlanEstudio" IS 'Almacena los diferentes planes de estudio de las carreras';
COMMENT ON TABLE public."PlanCurso" IS 'Relaciona los cursos con sus respectivos planes de estudio y bloques';
COMMENT ON COLUMN public."Requisitos".id_plan IS 'Plan específico al que aplica este requisito. NULL = aplica a todos los planes';
COMMENT ON COLUMN public."Estudiante".id_plan IS 'Plan de estudios al que está asociado el estudiante';

-- 10. Añadir índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS "idx_plancurso_plan" ON public."PlanCurso" (id_plan);
CREATE INDEX IF NOT EXISTS "idx_plancurso_curso" ON public."PlanCurso" (codigo_curso);
CREATE INDEX IF NOT EXISTS "idx_requisitos_curso" ON public."Requisitos" (codigo_curso);
CREATE INDEX IF NOT EXISTS "idx_requisitos_plan" ON public."Requisitos" (id_plan);



-- =============================================
-- 1. INSERCIÓN DE PROFESORES
-- =============================================

-- Crear secuencia para los IDs de profesor si no existe
CREATE SEQUENCE IF NOT EXISTS profesor_id_seq 
    START WITH 1 
    INCREMENT BY 1 
    NO MINVALUE 
    NO MAXVALUE 
    CACHE 1;

-- Insertar profesores para las diferentes escuelas
INSERT INTO public."Profesor" (id_profesor, id_escuela, nombre) VALUES
-- Profesores de ATI (Escuela 2)
(nextval('profesor_id_seq')::integer, 2, ARRAY['María Elena Rodríguez']),
(nextval('profesor_id_seq')::integer, 2, ARRAY['Carlos Jiménez Sánchez']),
(nextval('profesor_id_seq')::integer, 2, ARRAY['Valeria Méndez Castro']),
(nextval('profesor_id_seq')::integer, 2, ARRAY['Alejandro Mora Rojas']),
(nextval('profesor_id_seq')::integer, 2, ARRAY['Diana Fonseca Vargas']),
(nextval('profesor_id_seq')::integer, 2, ARRAY['Roberto Pérez Alvarado']),
(nextval('profesor_id_seq')::integer, 2, ARRAY['Silvia Navarro Hidalgo']),
(nextval('profesor_id_seq')::integer, 2, ARRAY['Gabriel Araya Solano']),

-- Profesores de Computación (Escuela 19)
(nextval('profesor_id_seq')::integer, 19, ARRAY['Luis Quesada Ramírez']),
(nextval('profesor_id_seq')::integer, 19, ARRAY['Andrea Calderón Brenes']),
(nextval('profesor_id_seq')::integer, 19, ARRAY['Mario Segura Zamora']),
(nextval('profesor_id_seq')::integer, 19, ARRAY['Laura Campos Pacheco']),
(nextval('profesor_id_seq')::integer, 19, ARRAY['Esteban Murillo Soto']),
(nextval('profesor_id_seq')::integer, 19, ARRAY['Raquel Villalobos Cruz']),
(nextval('profesor_id_seq')::integer, 19, ARRAY['Jorge Zúñiga Madrigal']),
(nextval('profesor_id_seq')::integer, 19, ARRAY['Adriana Chacón Varela']),

-- Profesores de Matemática (Escuela 26)
(nextval('profesor_id_seq')::integer, 26, ARRAY['Santiago Rojas Ugalde']),
(nextval('profesor_id_seq')::integer, 26, ARRAY['Carmen Solís Morales']),
(nextval('profesor_id_seq')::integer, 26, ARRAY['Fernando Moreira Quirós']),
(nextval('profesor_id_seq')::integer, 26, ARRAY['Lucía Bonilla Castro']),

-- Profesores de Ciencias del Lenguaje (Escuela 7)
(nextval('profesor_id_seq')::integer, 7, ARRAY['Eduardo Miranda Sánchez']),
(nextval('profesor_id_seq')::integer, 7, ARRAY['Natalia Herrera Chaves']),
(nextval('profesor_id_seq')::integer, 7, ARRAY['Víctor Delgado Robles']),

-- Profesores de Ciencias Sociales (Escuela 9)
(nextval('profesor_id_seq')::integer, 9, ARRAY['Patricia Aguilar Mora']),
(nextval('profesor_id_seq')::integer, 9, ARRAY['Mauricio Benavides Vargas']),
(nextval('profesor_id_seq')::integer, 9, ARRAY['Cecilia López Alvarado']),

-- Profesores de Cultura y Deporte (Escuela 10)
(nextval('profesor_id_seq')::integer, 10, ARRAY['Gerardo Vega Chavarría']),
(nextval('profesor_id_seq')::integer, 10, ARRAY['Carolina Rivas Monge']),
(nextval('profesor_id_seq')::integer, 10, ARRAY['Javier Alfaro Castro']),

-- Profesores de Administración de Empresas (Escuela 1)
(nextval('profesor_id_seq')::integer, 1, ARRAY['Daniela Cordero Molina']),
(nextval('profesor_id_seq')::integer, 1, ARRAY['Ricardo Salgado Torres'])
ON CONFLICT (id_profesor) DO NOTHING;

-- Resetear la secuencia para asegurar que comienza después del último ID insertado
SELECT setval('profesor_id_seq', COALESCE((SELECT MAX(id_profesor) FROM public."Profesor"), 0) + 1);

-- =============================================
-- 2. CREACIÓN DE GRUPOS
-- =============================================

-- Crear secuencia para los IDs de grupo si no existe
CREATE SEQUENCE IF NOT EXISTS grupo_id_seq 
    START WITH 1 
    INCREMENT BY 1 
    NO MINVALUE 
    NO MAXVALUE 
    CACHE 1;

-- Crear tabla auxiliar con los horarios estándar
CREATE TEMPORARY TABLE horarios_estandar (
    id SERIAL PRIMARY KEY,
    descripcion VARCHAR(20),
    hora_inicio TIME,
    hora_fin TIME
);

INSERT INTO horarios_estandar (descripcion, hora_inicio, hora_fin) VALUES
    ('7:30-9:20', '07:30:00', '09:20:00'),
    ('9:30-11:20', '09:30:00', '11:20:00'),
    ('13:00-14:50', '13:00:00', '14:50:00'),
    ('15:00-16:50', '15:00:00', '16:50:00'),
    ('17:00-18:50', '17:00:00', '18:50:00'),
    ('19:00-20:50', '19:00:00', '20:50:00');

-- Obtener todos los cursos disponibles
WITH cursos_disponibles AS (
    SELECT DISTINCT c.codigo_curso, c.id_escuela
    FROM public."Curso" c
)
-- Insertar grupos para la sede Cartago (I Semestre)
INSERT INTO public."Grupo" (
    id_grupo, 
    codigo_curso, 
    "id_sedeXescuela", 
    aula, 
    horario, 
    modalidad, 
    periodo, 
    cupos, 
    id_profesor
)
SELECT 
    nextval('grupo_id_seq')::integer,  -- ID grupo 1 para cada curso
    cd.codigo_curso,
    -- Cartago para primer grupo
    CASE 
        WHEN cd.id_escuela = 2 THEN 16  -- ATI en Cartago
        WHEN cd.id_escuela = 19 THEN 17  -- Computación en Cartago
        WHEN cd.id_escuela = 26 THEN 22  -- Matemática en Cartago
        WHEN cd.id_escuela = 7 THEN 13  -- Ciencias Lenguaje en Cartago
        WHEN cd.id_escuela = 9 THEN 14  -- Ciencias Sociales en Cartago
        WHEN cd.id_escuela = 10 THEN 15  -- Cultura y Deporte en Cartago
        ELSE 16  -- Default a ATI si no hay coincidencia
    END,
    ARRAY['A-' || (floor(random() * 300) + 101)::text],  -- Aula aleatoria
    ARRAY[
        CASE (floor(random() * 3))::integer
            WHEN 0 THEN 'L ' || (SELECT descripcion FROM horarios_estandar WHERE id = 1 + (floor(random() * 2))::integer)  -- Mañana
            WHEN 1 THEN 'K ' || (SELECT descripcion FROM horarios_estandar WHERE id = 3 + (floor(random() * 2))::integer)  -- Tarde
            ELSE 'M ' || (SELECT descripcion FROM horarios_estandar WHERE id = 1 + (floor(random() * 2))::integer)  -- Mañana
        END
    ],
    ARRAY[
        CASE floor(random() * 3)::integer
            WHEN 0 THEN 'PRESENCIAL'
            WHEN 1 THEN 'VIRTUAL'
            ELSE 'HÍBRIDO'
        END
    ],
    1,  -- I Semestre
    25 + floor(random() * 11)::integer,  -- Cupos entre 25 y 35
    -- Escoger un profesor aleatorio de la misma escuela
    (SELECT id_profesor FROM public."Profesor" 
     WHERE id_escuela = cd.id_escuela 
     ORDER BY random() LIMIT 1)
FROM cursos_disponibles cd;


WITH cursos_disponibles AS (
    SELECT DISTINCT c.codigo_curso, c.id_escuela
    FROM public."Curso" c
)
-- Insertar grupos para la sede San José (I Semestre)
INSERT INTO public."Grupo" (
    id_grupo, 
    codigo_curso, 
    "id_sedeXescuela", 
    aula, 
    horario, 
    modalidad, 
    periodo, 
    cupos, 
    id_profesor
)
SELECT 
    nextval('grupo_id_seq')::integer,  -- ID grupo 2 para cada curso
    cd.codigo_curso,
    -- San José para segundo grupo
    CASE 
        WHEN cd.id_escuela = 2 THEN 41  -- ATI en San José
        WHEN cd.id_escuela = 19 THEN 42  -- Computación en San José
        WHEN cd.id_escuela = 26 THEN 47  -- Matemática en San José
        WHEN cd.id_escuela = 7 THEN 38  -- Ciencias Lenguaje en San José
        WHEN cd.id_escuela = 9 THEN 39  -- Ciencias Sociales en San José
        WHEN cd.id_escuela = 10 THEN 40  -- Cultura y Deporte en San José
        ELSE 41  -- Default a ATI si no hay coincidencia
    END,
    ARRAY['B-' || (floor(random() * 300) + 101)::text],  -- Aula aleatoria
    ARRAY[
        CASE (floor(random() * 3))::integer
            WHEN 0 THEN 'J ' || (SELECT descripcion FROM horarios_estandar WHERE id = 5 + (floor(random() * 1))::integer)  -- Tarde-Noche
            WHEN 1 THEN 'K-J ' || (SELECT descripcion FROM horarios_estandar WHERE id = 5)  -- 17:00-18:50
            ELSE 'V ' || (SELECT descripcion FROM horarios_estandar WHERE id = 6)  -- 19:00-20:50
        END
    ],
    ARRAY[
        CASE floor(random() * 3)::integer
            WHEN 0 THEN 'PRESENCIAL'
            WHEN 1 THEN 'VIRTUAL'
            ELSE 'HÍBRIDO'
        END
    ],
    1,  -- I Semestre
    25 + floor(random() * 11)::integer,  -- Cupos entre 25 y 35
    -- Escoger un profesor aleatorio de la misma escuela
    (SELECT id_profesor FROM public."Profesor" 
     WHERE id_escuela = cd.id_escuela 
     ORDER BY random() LIMIT 1)
FROM cursos_disponibles cd;

-- Insertar grupos para algunos cursos iniciales en San Carlos (II Semestre)
WITH cursos_iniciales AS (
    SELECT DISTINCT c.codigo_curso, c.id_escuela
    FROM public."Curso" c
    WHERE c.codigo_curso LIKE 'MA01%' OR c.codigo_curso LIKE 'CI02%' OR 
          c.codigo_curso LIKE 'IC1%' OR c.codigo_curso LIKE 'TI1%' OR
          c.codigo_curso LIKE 'SE1%'
    LIMIT 15  -- Limitamos a algunos cursos iniciales
)
INSERT INTO public."Grupo" (
    id_grupo, 
    codigo_curso, 
    "id_sedeXescuela", 
    aula, 
    horario, 
    modalidad, 
    periodo, 
    cupos, 
    id_profesor
)
SELECT 
    nextval('grupo_id_seq')::integer,
    ci.codigo_curso,
    -- San Carlos para tercer grupo
    CASE 
        WHEN ci.id_escuela = 2 THEN 36  -- ATI en San Carlos
        WHEN ci.id_escuela = 19 THEN 37  -- Computación en San Carlos
        WHEN ci.id_escuela = 26 THEN 32  -- Matemática en San Carlos
        WHEN ci.id_escuela = 7 THEN 33  -- Ciencias Lenguaje en San Carlos
        WHEN ci.id_escuela = 9 THEN 34  -- Ciencias Sociales en San Carlos
        WHEN ci.id_escuela = 10 THEN 35  -- Cultura y Deporte en San Carlos
        ELSE 36  -- Default a ATI si no hay coincidencia
    END,
    ARRAY['C-' || (floor(random() * 200) + 101)::text],
    ARRAY[
        CASE (floor(random() * 3))::integer
            WHEN 0 THEN 'L-M ' || (SELECT descripcion FROM horarios_estandar WHERE id = 3)  -- 13:00-14:50
            WHEN 1 THEN 'K ' || (SELECT descripcion FROM horarios_estandar WHERE id = 1)  -- 7:30-9:20
            ELSE 'M-V ' || (SELECT descripcion FROM horarios_estandar WHERE id = 2)  -- 9:30-11:20
        END
    ],
    ARRAY[
        CASE floor(random() * 3)::integer
            WHEN 0 THEN 'PRESENCIAL'
            WHEN 1 THEN 'VIRTUAL'
            ELSE 'HÍBRIDO'
        END
    ],
    2,  -- II Semestre
    25 + floor(random() * 11)::integer,
    -- Escoger un profesor aleatorio de la misma escuela
    (SELECT id_profesor FROM public."Profesor" 
     WHERE id_escuela = ci.id_escuela 
     ORDER BY random() LIMIT 1)
FROM cursos_iniciales ci;

-- Resetear la secuencia para asegurar que comienza después del último ID insertado
SELECT setval('grupo_id_seq', COALESCE((SELECT MAX(id_grupo) FROM public."Grupo"), 0) + 1);

-- =============================================
-- 3. CREACIÓN DE HORARIOS PARA CADA GRUPO
-- =============================================

-- Crear horarios para el día principal de cada grupo
INSERT INTO public."HorarioClases" (
    id_horario_clases,
    id_grupo,
    dia,
    "horaInicio",
    "horaFinal"
)
SELECT 
    g.id_grupo * 10 + (CASE 
                        WHEN position('L' in g.horario[1]) > 0 THEN 1
                        WHEN position('K' in g.horario[1]) > 0 THEN 2
                        WHEN position('M' in g.horario[1]) > 0 THEN 3
                        WHEN position('J' in g.horario[1]) > 0 THEN 4
                        WHEN position('V' in g.horario[1]) > 0 THEN 5
                        ELSE 1 END),
    g.id_grupo,
    ARRAY[CASE 
            WHEN position('L' in g.horario[1]) > 0 THEN 'LUNES'
            WHEN position('K' in g.horario[1]) > 0 THEN 'MARTES'
            WHEN position('M' in g.horario[1]) > 0 THEN 'MIÉRCOLES'
            WHEN position('J' in g.horario[1]) > 0 THEN 'JUEVES'
            WHEN position('V' in g.horario[1]) > 0 THEN 'VIERNES'
            ELSE 'LUNES' END],
    CASE 
        WHEN position('7:30-9:20' in g.horario[1]) > 0 THEN '07:30:00'::time
        WHEN position('9:30-11:20' in g.horario[1]) > 0 THEN '09:30:00'::time
        WHEN position('13:00-14:50' in g.horario[1]) > 0 THEN '13:00:00'::time
        WHEN position('15:00-16:50' in g.horario[1]) > 0 THEN '15:00:00'::time
        WHEN position('17:00-18:50' in g.horario[1]) > 0 THEN '17:00:00'::time
        WHEN position('19:00-20:50' in g.horario[1]) > 0 THEN '19:00:00'::time
        ELSE '07:30:00'::time
    END,
    CASE 
        WHEN position('7:30-9:20' in g.horario[1]) > 0 THEN '09:20:00'::time
        WHEN position('9:30-11:20' in g.horario[1]) > 0 THEN '11:20:00'::time
        WHEN position('13:00-14:50' in g.horario[1]) > 0 THEN '14:50:00'::time
        WHEN position('15:00-16:50' in g.horario[1]) > 0 THEN '16:50:00'::time
        WHEN position('17:00-18:50' in g.horario[1]) > 0 THEN '18:50:00'::time
        WHEN position('19:00-20:50' in g.horario[1]) > 0 THEN '20:50:00'::time
        ELSE '09:20:00'::time
    END
FROM public."Grupo" g
ON CONFLICT DO NOTHING;

-- Crear horarios para el día secundario de grupos que tienen dos días
INSERT INTO public."HorarioClases" (
    id_horario_clases,
    id_grupo,
    dia,
    "horaInicio",
    "horaFinal"
)
SELECT 
    g.id_grupo * 10 + (CASE 
                        WHEN position('-J' in g.horario[1]) > 0 THEN 4
                        WHEN position('-V' in g.horario[1]) > 0 THEN 5
                        WHEN position('-M' in g.horario[1]) > 0 THEN 3
                        ELSE 2 END),
    g.id_grupo,
    ARRAY[CASE 
            WHEN position('-J' in g.horario[1]) > 0 THEN 'JUEVES'
            WHEN position('-V' in g.horario[1]) > 0 THEN 'VIERNES'
            WHEN position('-M' in g.horario[1]) > 0 THEN 'MIÉRCOLES'
            ELSE 'MARTES' END],
    CASE 
        WHEN position('7:30-9:20' in g.horario[1]) > 0 THEN '07:30:00'::time
        WHEN position('9:30-11:20' in g.horario[1]) > 0 THEN '09:30:00'::time
        WHEN position('13:00-14:50' in g.horario[1]) > 0 THEN '13:00:00'::time
        WHEN position('15:00-16:50' in g.horario[1]) > 0 THEN '15:00:00'::time
        WHEN position('17:00-18:50' in g.horario[1]) > 0 THEN '17:00:00'::time
        WHEN position('19:00-20:50' in g.horario[1]) > 0 THEN '19:00:00'::time
        ELSE '07:30:00'::time
    END,
    CASE 
        WHEN position('7:30-9:20' in g.horario[1]) > 0 THEN '09:20:00'::time
        WHEN position('9:30-11:20' in g.horario[1]) > 0 THEN '11:20:00'::time
        WHEN position('13:00-14:50' in g.horario[1]) > 0 THEN '14:50:00'::time
        WHEN position('15:00-16:50' in g.horario[1]) > 0 THEN '16:50:00'::time
        WHEN position('17:00-18:50' in g.horario[1]) > 0 THEN '18:50:00'::time
        WHEN position('19:00-20:50' in g.horario[1]) > 0 THEN '20:50:00'::time
        ELSE '09:20:00'::time
    END
FROM public."Grupo" g
WHERE g.horario[1] LIKE '%-%'  -- Solo para los que tienen formato con guión (dos días)
ON CONFLICT DO NOTHING;

-- =============================================
-- 4. COMENTARIOS Y DOCUMENTACIÓN
-- =============================================

COMMENT ON TABLE public."Profesor" IS 'Almacena información de los profesores asociados a cada escuela';
COMMENT ON TABLE public."Grupo" IS 'Almacena los grupos disponibles para cada curso';
COMMENT ON TABLE public."HorarioClases" IS 'Detalla los días y horas específicas para cada grupo';
COMMENT ON COLUMN public."Grupo".periodo IS '1=I Semestre, 2=II Semestre, 3=Verano';
COMMENT ON COLUMN public."HorarioClases".dia IS 'Día de la semana en que se imparte la clase';




-- Crear secuencia para los IDs de EstadoCurso si no existe
CREATE SEQUENCE IF NOT EXISTS estado_curso_id_seq 
    START WITH 1 
    INCREMENT BY 1 
    NO MINVALUE 
    NO MAXVALUE 
    CACHE 1;

-- Insertar los estados básicos de un curso
INSERT INTO public."EstadoCurso" ("id_estadoCurso", estado) VALUES
(nextval('estado_curso_id_seq')::integer, ARRAY['APROBADO']),
(nextval('estado_curso_id_seq')::integer, ARRAY['REPROBADO']),
(nextval('estado_curso_id_seq')::integer, ARRAY['EN CURSO'])
ON CONFLICT ("id_estadoCurso") DO NOTHING;

-- Insertar estados adicionales que podrían ser útiles
INSERT INTO public."EstadoCurso" ("id_estadoCurso", estado) VALUES
(nextval('estado_curso_id_seq')::integer, ARRAY['RETIRADO']),
(nextval('estado_curso_id_seq')::integer, ARRAY['CONGELADO']),
(nextval('estado_curso_id_seq')::integer, ARRAY['SUFICIENCIA']),
(nextval('estado_curso_id_seq')::integer, ARRAY['RECONOCIMIENTO'])
ON CONFLICT ("id_estadoCurso") DO NOTHING;

-- Resetear la secuencia para asegurar que comienza después del último ID insertado
SELECT setval('estado_curso_id_seq', COALESCE((SELECT MAX("id_estadoCurso") FROM public."EstadoCurso"), 0) + 1);

-- Agregar comentario explicativo
COMMENT ON TABLE public."EstadoCurso" IS 'Estados posibles de un curso en el historial académico de un estudiante';





-- 1. Crear secuencia para los IDs de proceso si no existe
CREATE SEQUENCE IF NOT EXISTS proceso_id_seq 
    START WITH 1 
    INCREMENT BY 1 
    NO MINVALUE 
    NO MAXVALUE 
    CACHE 1;

-- 2. Crear algunos administradores si es necesario (si aún no existen)
DO $$
DECLARE
    admin_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO admin_count FROM public."Administrativo";
    
    IF admin_count = 0 THEN
        -- Crear administradores para distintas sedes/escuelas
        INSERT INTO public."Administrativo" (id_admin, "id_sedeXescuela", id_departamento, "Rol") VALUES
        (1, 16, 1, ARRAY['COORDINADOR']),  -- ATI en Cartago
        (2, 17, 1, ARRAY['COORDINADOR']),  -- Computación en Cartago
        (3, 41, 1, ARRAY['COORDINADOR']),  -- ATI en San José
        (4, 42, 1, ARRAY['COORDINADOR']),  -- Computación en San José
        (5, 36, 1, ARRAY['COORDINADOR']),  -- ATI en San Carlos
        (6, 37, 1, ARRAY['COORDINADOR']),  -- Computación en San Carlos
        (7, 22, 1, ARRAY['COORDINADOR']),  -- Matemática en Cartago
        (8, 13, 1, ARRAY['COORDINADOR']),  -- Ciencias Lenguaje en Cartago
        (9, 14, 1, ARRAY['COORDINADOR']),  -- Ciencias Sociales en Cartago
        (10, 15, 1, ARRAY['COORDINADOR'])  -- Cultura y Deporte en Cartago
        ON CONFLICT DO NOTHING;
    END IF;
END $$;

-- 3. Crear procesos de matrícula por inclusión para el I Semestre 2025
-- Para las principales sedes/escuelas
INSERT INTO public."Procesos" (
    id_proceso,
    "tipoProceso",
    "fechaInicio",
    "fechaFinal",
    estado,
    "id_sedeXescuela",
    id_admin
)
SELECT 
    nextval('proceso_id_seq')::integer,
    ARRAY['INCLUSIÓN'],
    -- Fechas para I Semestre: después de matrícula ordinaria
    '2025-02-17'::date,  -- 17 de febrero 2025
    '2025-02-21'::date,  -- 21 de febrero 2025
    true,  -- Activo
    se."id_sedeXescuela",
    -- Asignar administradores según sede/escuela
    CASE 
        WHEN se.id_sede = 1 AND se.id_escuela = 2 THEN 1  -- ATI en Cartago
        WHEN se.id_sede = 1 AND se.id_escuela = 19 THEN 2  -- Computación en Cartago
        WHEN se.id_sede = 3 AND se.id_escuela = 2 THEN 3  -- ATI en San José
        WHEN se.id_sede = 3 AND se.id_escuela = 19 THEN 4  -- Computación en San José
        WHEN se.id_sede = 2 AND se.id_escuela = 2 THEN 5  -- ATI en San Carlos
        WHEN se.id_sede = 2 AND se.id_escuela = 19 THEN 6  -- Computación en San Carlos
        WHEN se.id_sede = 1 AND se.id_escuela = 26 THEN 7  -- Matemática en Cartago
        WHEN se.id_sede = 1 AND se.id_escuela = 7 THEN 8  -- Ciencias Lenguaje en Cartago
        WHEN se.id_sede = 1 AND se.id_escuela = 9 THEN 9  -- Ciencias Sociales en Cartago
        WHEN se.id_sede = 1 AND se.id_escuela = 10 THEN 10  -- Cultura y Deporte en Cartago
        ELSE 1  -- Default
    END
FROM public."SedeEscuela" se
-- Limitamos a las escuelas principales que ofrecen cursos
WHERE se.id_escuela IN (2, 19, 26, 7, 9, 10);

-- 4. Crear procesos de matrícula por inclusión para el II Semestre 2025
INSERT INTO public."Procesos" (
    id_proceso,
    "tipoProceso",
    "fechaInicio",
    "fechaFinal",
    estado,
    "id_sedeXescuela",
    id_admin
)
SELECT 
    nextval('proceso_id_seq')::integer,
    ARRAY['INCLUSIÓN'],
    -- Fechas para II Semestre: después de matrícula ordinaria
    '2025-07-21'::date,  -- 21 de julio 2025
    '2025-07-25'::date,  -- 25 de julio 2025
    false,  -- No activo aún
    se."id_sedeXescuela",
    -- Asignar administradores según sede/escuela
    CASE 
        WHEN se.id_sede = 1 AND se.id_escuela = 2 THEN 1  -- ATI en Cartago
        WHEN se.id_sede = 1 AND se.id_escuela = 19 THEN 2  -- Computación en Cartago
        WHEN se.id_sede = 3 AND se.id_escuela = 2 THEN 3  -- ATI en San José
        WHEN se.id_sede = 3 AND se.id_escuela = 19 THEN 4  -- Computación en San José
        WHEN se.id_sede = 2 AND se.id_escuela = 2 THEN 5  -- ATI en San Carlos
        WHEN se.id_sede = 2 AND se.id_escuela = 19 THEN 6  -- Computación en San Carlos
        WHEN se.id_sede = 1 AND se.id_escuela = 26 THEN 7  -- Matemática en Cartago
        WHEN se.id_sede = 1 AND se.id_escuela = 7 THEN 8  -- Ciencias Lenguaje en Cartago
        WHEN se.id_sede = 1 AND se.id_escuela = 9 THEN 9  -- Ciencias Sociales en Cartago
        WHEN se.id_sede = 1 AND se.id_escuela = 10 THEN 10  -- Cultura y Deporte en Cartago
        ELSE 1  -- Default
    END
FROM public."SedeEscuela" se
-- Limitamos a las escuelas principales que ofrecen cursos
WHERE se.id_escuela IN (2, 19, 26, 7, 9, 10);

-- 5. Crear procesos de levantamiento de requisitos para el I Semestre 2025
INSERT INTO public."Procesos" (
    id_proceso,
    "tipoProceso",
    "fechaInicio",
    "fechaFinal",
    estado,
    "id_sedeXescuela",
    id_admin
)
SELECT 
    nextval('proceso_id_seq')::integer,
    ARRAY['LEVANTAMIENTO'],
    -- Fechas para I Semestre: antes de matrícula ordinaria
    '2025-01-20'::date,  -- 20 de enero 2025
    '2025-01-31'::date,  -- 31 de enero 2025
    true,  -- Activo
    se."id_sedeXescuela",
    -- Asignar administradores según sede/escuela
    CASE 
        WHEN se.id_sede = 1 AND se.id_escuela = 2 THEN 1  -- ATI en Cartago
        WHEN se.id_sede = 1 AND se.id_escuela = 19 THEN 2  -- Computación en Cartago
        WHEN se.id_sede = 3 AND se.id_escuela = 2 THEN 3  -- ATI en San José
        WHEN se.id_sede = 3 AND se.id_escuela = 19 THEN 4  -- Computación en San José
        WHEN se.id_sede = 2 AND se.id_escuela = 2 THEN 5  -- ATI en San Carlos
        WHEN se.id_sede = 2 AND se.id_escuela = 19 THEN 6  -- Computación en San Carlos
        WHEN se.id_sede = 1 AND se.id_escuela = 26 THEN 7  -- Matemática en Cartago
        WHEN se.id_sede = 1 AND se.id_escuela = 7 THEN 8  -- Ciencias Lenguaje en Cartago
        WHEN se.id_sede = 1 AND se.id_escuela = 9 THEN 9  -- Ciencias Sociales en Cartago
        WHEN se.id_sede = 1 AND se.id_escuela = 10 THEN 10  -- Cultura y Deporte en Cartago
        ELSE 1  -- Default
    END
FROM public."SedeEscuela" se
-- Limitamos a las escuelas principales que ofrecen cursos
WHERE se.id_escuela IN (2, 19, 26, 7, 9, 10);

-- 6. Crear procesos de levantamiento de requisitos para el II Semestre 2025
INSERT INTO public."Procesos" (
    id_proceso,
    "tipoProceso",
    "fechaInicio",
    "fechaFinal",
    estado,
    "id_sedeXescuela",
    id_admin
)
SELECT 
    nextval('proceso_id_seq')::integer,
    ARRAY['LEVANTAMIENTO'],
    -- Fechas para II Semestre: antes de matrícula ordinaria
    '2025-06-23'::date,  -- 23 de junio 2025
    '2025-07-04'::date,  -- 4 de julio 2025
    false,  -- No activo aún
    se."id_sedeXescuela",
    -- Asignar administradores según sede/escuela
    CASE 
        WHEN se.id_sede = 1 AND se.id_escuela = 2 THEN 1  -- ATI en Cartago
        WHEN se.id_sede = 1 AND se.id_escuela = 19 THEN 2  -- Computación en Cartago
        WHEN se.id_sede = 3 AND se.id_escuela = 2 THEN 3  -- ATI en San José
        WHEN se.id_sede = 3 AND se.id_escuela = 19 THEN 4  -- Computación en San José
        WHEN se.id_sede = 2 AND se.id_escuela = 2 THEN 5  -- ATI en San Carlos
        WHEN se.id_sede = 2 AND se.id_escuela = 19 THEN 6  -- Computación en San Carlos
        WHEN se.id_sede = 1 AND se.id_escuela = 26 THEN 7  -- Matemática en Cartago
        WHEN se.id_sede = 1 AND se.id_escuela = 7 THEN 8  -- Ciencias Lenguaje en Cartago
        WHEN se.id_sede = 1 AND se.id_escuela = 9 THEN 9  -- Ciencias Sociales en Cartago
        WHEN se.id_sede = 1 AND se.id_escuela = 10 THEN 10  -- Cultura y Deporte en Cartago
        ELSE 1  -- Default
    END
FROM public."SedeEscuela" se
-- Limitamos a las escuelas principales que ofrecen cursos
WHERE se.id_escuela IN (2, 19, 26, 7, 9, 10);

-- Resetear la secuencia para asegurar que comienza después del último ID insertado
SELECT setval('proceso_id_seq', COALESCE((SELECT MAX(id_proceso) FROM public."Procesos"), 0) + 1);

-- 7. Agregar comentarios explicativos
COMMENT ON TABLE public."Procesos" IS 'Almacena información sobre procesos académicos como inclusiones y levantamientos';
COMMENT ON COLUMN public."Procesos"."tipoProceso" IS 'Tipo de proceso: INCLUSIÓN, LEVANTAMIENTO, etc.';
COMMENT ON COLUMN public."Procesos".estado IS 'true=activo, false=inactivo';



-- 1. Insertar las personas primero
INSERT INTO public."Persona" (identificacion, id_tipo, nombre, apellido, correo, "contraseña")
VALUES
-- Estudiante
(ARRAY['107890456'], 1, ARRAY['Juan Carlos'], ARRAY['Mora', 'Pérez'], ARRAY['jc.mora@estudiantec.cr'], ARRAY['estud123']),
-- Coordinador
(ARRAY['205670891'], 1, ARRAY['María Fernanda'], ARRAY['Jiménez', 'Sánchez'], ARRAY['mf.jimenez@itcr.ac.cr'], ARRAY['coord456']),
-- Asistente
(ARRAY['304560789'], 1, ARRAY['Roberto'], ARRAY['González', 'Ramírez'], ARRAY['roberto.gonzalez@itcr.ac.cr'], ARRAY['asis789'])
ON CONFLICT (identificacion) DO NOTHING;

-- 2. Insertar estudiante
INSERT INTO public."Estudiante" (id_estudiante, carnet, id_sede, id_carrera)
VALUES (
    COALESCE((SELECT MAX(id_estudiante) FROM public."Estudiante"), 0) + 1, -- ID autoincremental
    2023123456, -- Carnet
    1,          -- Sede Cartago (id=1)
    3           -- Carrera Ingeniería en Computación (id=3)
);

-- 3. Insertar administrativo coordinador
INSERT INTO public."Administrativo" (id_admin, "id_sedeXescuela", id_departamento, "Rol")
VALUES (
    COALESCE((SELECT MAX(id_admin) FROM public."Administrativo"), 0) + 1, -- ID autoincremental
    17,  -- Computación en Cartago (id=17)
    1,   -- Departamento de Admisión y Registro (id=1)
    ARRAY['COORDINADOR']
);

-- 4. Insertar administrativo asistente
INSERT INTO public."Administrativo" (id_admin, "id_sedeXescuela", id_departamento, "Rol")
VALUES (
    COALESCE((SELECT MAX(id_admin) FROM public."Administrativo"), 0) + 1, -- ID autoincremental
    17,  -- Computación en Cartago (id=17)
    1,   -- Departamento de Admisión y Registro (id=1)
    ARRAY['ASISTENTE']
);


select * from public."Curso" c  inner join "Grupo" g on g.codigo_curso  = c.codigo_curso where c.codigo_curso = 'IC7900'



-- Inserción de solicitudes de levantamiento para cursos de computación
-- Nota: Asegúrate de que los IDs de estudiantes y grupos existan en tus tablas

-- Solicitud de levantamiento para Bases de Datos II
INSERT INTO public."Solicitudes" (
    id_solicitud,
    id_estudiante,
    id_grupo,
    tipo_solicitud,
    "fechaSolicitud",
    revisado,
    estado,
    motivo
) VALUES (
    1,                       -- ID de solicitud único
    1,                       -- ID del estudiante (ajustar según tus datos)
    50,                        -- ID del grupo de Bases de Datos II (ajustar según tus datos)
    '{"Levantamiento"}',        -- Tipo de solicitud como array
    '2025-05-20',               -- Fecha actual
    false,                      -- No revisado aún
    '{"Pendiente"}',            -- Estado como array
    '{"Necesito el curso para poder graduarme este semestre y ya he aprobado todos los requisitos."}'
),(
    2,                       -- ID de solicitud único
    1,                       -- ID del estudiante (ajustar según tus datos)
    52,                        -- ID del grupo de Requerimientos (ajustar según tus datos)
    '{"Levantamiento"}',        -- Tipo de solicitud como array
    '2025-05-21',               -- Fecha actual
    false,                      -- No revisado aún
    '{"Pendiente"}',            -- Estado como array
    '{"El curso es un requisito para poder llevar otros cursos el próximo semestre y mantener mi plan de estudios."}'
),(
    3,                       -- ID de solicitud único
    1,                       -- ID del estudiante (ajustar según tus datos)
    86,                        -- ID del grupo de Análisis de Algoritmos (ajustar según tus datos)
    '{"Levantamiento"}',        -- Tipo de solicitud como array
    '2025-05-22',               -- Fecha actual
    false,                      -- No revisado aún
    '{"Pendiente"}',            -- Estado como array
    '{"Solicito el levantamiento de este curso porque ya aprobé todos los requisitos y necesito llevarlo para continuar con mi malla curricular."}'
)


SELECT 
    c.codigo_curso, 
    c.nombre, 
    c.creditos, 
    g.id_grupo, 
    COUNT(s.id_solicitud) as total_solicitudes
FROM 
    public."Curso" c  
INNER JOIN 
    "Grupo" g ON g.codigo_curso = c.codigo_curso 
LEFT JOIN 
    "Solicitudes" s ON s.id_grupo = g.id_grupo
WHERE 
    'Levantamiento' = ANY(s.tipo_solicitud)
GROUP BY 
    c.codigo_curso, c.nombre, c.creditos, g.id_grupo
ORDER BY
    c.codigo_curso;


-- 1. Agregar una columna escalar en Persona para almacenar la identificación principal
ALTER TABLE public."Persona" 
ADD COLUMN id_persona_escalar character varying(20);

-- 2. Llenar esta columna con el primer elemento del array de identificación
UPDATE public."Persona"
SET id_persona_escalar = (identificacion[1]);

-- 3. Crear índice único para esta columna
CREATE UNIQUE INDEX idx_persona_id_escalar ON public."Persona" (id_persona_escalar);

-- 4. Añadir columnas escalares (NO arrays) a Estudiante y Administrativo
ALTER TABLE public."Estudiante"
ADD COLUMN id_persona_fk character varying(20);

ALTER TABLE public."Administrativo"
ADD COLUMN id_persona_fk character varying(20);

-- 5. Crear las claves foráneas usando columnas escalares
ALTER TABLE ONLY public."Estudiante"
    ADD CONSTRAINT "FK_estudiante_persona" FOREIGN KEY (id_persona_fk) 
    REFERENCES public."Persona" (id_persona_escalar);

ALTER TABLE ONLY public."Administrativo"
    ADD CONSTRAINT "FK_administrativo_persona" FOREIGN KEY (id_persona_fk) 
    REFERENCES public."Persona" (id_persona_escalar);



SELECT 
            s.id_solicitud,
            e.carnet,
            p.nombre[1] || ' ' || p.apellido[1] as nombre_estudiante,
            TO_CHAR(s."fechaSolicitud", 'DD/MM/YYYY') as fecha_solicitud,
            -- Asignar prioridad basada en alguna lógica (por ejemplo, MOD de id_solicitud)
            CASE 
                WHEN s.id_solicitud % 3 = 0 THEN 'Alta'
                WHEN s.id_solicitud % 3 = 1 THEN 'Media'
                ELSE 'Baja'
            END as prioridad,
            s.estado[1] as estado
        FROM 
            "Solicitudes" s
        INNER JOIN 
            "Estudiante" e ON e.id_estudiante = s.id_estudiante
        INNER JOIN 
            "Persona" p ON p.id_persona_escalar = e.id_persona_fk
        WHERE 
            s.id_grupo = :grupo AND
            'Levantamiento' = ANY(s.tipo_solicitud)
        ORDER BY
            -- Ordenar por prioridad (Alta, Media, Baja) y luego por ID
            CASE 
                WHEN s.id_solicitud % 3 = 0 THEN 1  -- Alta primero
                WHEN s.id_solicitud % 3 = 1 THEN 2  -- Media segundo
                ELSE 3  -- Baja último
            END,
            s.id_solicitud
            
SELECT 
            c.codigo_curso, 
            c.nombre as nombre, 
            c.creditos,
            g.id_grupo
        FROM 
            public."Curso" c  
        INNER JOIN 
            "Grupo" g ON g.codigo_curso = c.codigo_curso 
        WHERE 
            c.codigo_curso = 'IC4302' AND g.id_grupo = 50
            
SELECT 
            c2.codigo_curso,
            c2.nombre as nombre,
            r.tipo
        FROM 
            "Requisitos" r
        INNER JOIN 
            "Curso" c2 ON c2.codigo_curso = r.codigo_requisito
        WHERE 
            r.codigo_curso = 'IC4302'

-- Añadir campo comentario_admin como array de strings a la tabla Solicitudes
ALTER TABLE public."Solicitudes" 
ADD COLUMN comentario_admin character varying(255)[] NULL; 
            
SELECT 
            s.id_solicitud,
            e.carnet,
            s."fechaSolicitud",
            to_char(s."fechaSolicitud", 'DD/MM/YYYY') as fecha_solicitud,
            s.revisado,
            s.estado[1] as estado,
            s.motivo[1] as motivo,
            s.comentario_admin[1] as comentario_admin,
            CASE 
                WHEN s.id_solicitud % 3 = 0 THEN 'Alta'
                WHEN s.id_solicitud % 3 = 1 THEN 'Media'
                ELSE 'Baja'
            END as prioridad
        FROM 
            "Solicitudes" s
        INNER JOIN 
            "Estudiante" e ON e.id_estudiante = s.id_estudiante
        WHERE 
            s.id_solicitud = 1 AND
            s.id_grupo = 50
            
SELECT 
            e.carnet,
            p.nombre[1] || ' ' || p.apellido[1] as nombre,
            p.correo[1] as correo,
            e.telefono as telefono
        FROM 
            "Estudiante" e
        INNER JOIN 
            "Persona" p ON p.id_persona_escalar = e.id_persona_fk
        WHERE 
            e.carnet = 2023147852         

ALTER TABLE public."Estudiante"
ADD COLUMN telefono character varying(20);

SELECT revisado FROM public."Solicitudes"
        WHERE id_solicitud = 1            
        
SELECT a.id_admin, a."id_sedeXescuela", a.id_departamento, a."Rol"[1], p.nombre, p.apellido, p."contraseña"
                FROM "Administrativo" a
                JOIN "Persona" p ON LOWER(p.correo[1]) = LOWER(:email)
                WHERE LOWER(p.correo[1]) = LOWER(:email)        
                
                
UPDATE public."Solicitudes"
        SET 
            revisado = TRUE,
            estado = ARRAY['Pendiente']::varchar[],
            comentario_admin = ARRAY['apruebo']::varchar[]
        WHERE 
            id_solicitud = 1 AND
            'Levantamiento' = ANY(tipo_solicitud)
        RETURNING id_solicitud             
        
        
select * from public."Curso" c  inner join "Grupo" g on g.codigo_curso  = c.codigo_curso where c.codigo_curso = 'IC4003' or c.codigo_curso = 'IC6831'
        
        
INSERT INTO public."Solicitudes" (id_solicitud, id_estudiante, id_grupo, tipo_solicitud, "fechaSolicitud", revisado, estado, motivo) VALUES 
(5, 1, 11, -- ID del grupo
 '{"Inclusion"}', '2025-05-20', false, '{"Pendiente"}', '{"Necesito el curso para poder graduarme este semestre y ya he aprobado todos los requisitos."}'),
 (6, 1, 129, -- ID del grupo
 '{"Inclusion"}', '2025-05-20', false, '{"Pendiente"}', '{"Necesito el curso para poder graduarme este semestre y ya he aprobado todos los requisitos."}')
 
SELECT 
            c.codigo_curso, 
            c.nombre as nombre, 
            c.creditos, 
            g.id_grupo, 
            COUNT(s.id_solicitud) as total_solicitudes
        FROM 
            public."Curso" c  
        INNER JOIN 
            "Grupo" g ON g.codigo_curso = c.codigo_curso 
        LEFT JOIN 
            "Solicitudes" s ON s.id_grupo = g.id_grupo
        WHERE 
            'Inclusion' = ANY(s.tipo_solicitud) and g."id_sedeXescuela" = 17
        GROUP BY 
            c.codigo_curso, c.nombre, c.creditos, g.id_grupo
        ORDER BY
            c.codigo_curso
            
            
            
INSERT INTO public."Solicitudes" (id_solicitud, id_estudiante, id_grupo, tipo_solicitud, "fechaSolicitud", revisado, estado, motivo, comentario_admin) VALUES
(7, 1, 106, ARRAY['Inclusion'], '2025-03-31', true, ARRAY['Aceptado'], ARRAY['Me gustaria llevar este curso para no atrasarme'], ARRAY['Entendido']),
(8, 1, 111, ARRAY['Inclusion'], '2025-03-26', false, ARRAY['Pendiente'], ARRAY['Necesito llevar este curso'], NULL),
(9, 1, 114, ARRAY['Levantamiento'], '2025-04-01', false, ARRAY['Pendiente'], ARRAY['No me quiero atrasar'], NULL);

INSERT INTO public."HistorialSolicitudes" (id_historial_solicitud, id_estudiante, codigo_curso, "fechaRetiro", semestre, año, id_solicitud) VALUES
(1, 1, 'IC7841', '2025-03-31', 1, 2025, 1),
(2, 1, 'CI1107', '2025-03-26', 1, 2025, 2),
(3, 1, 'IC1802', '2025-04-01', 1, 2025, 3);



CREATE TABLE IF NOT EXISTS public."HistorialProcesos" (
    id_historial SERIAL PRIMARY KEY,
    fecha_accion TIMESTAMP NOT NULL DEFAULT NOW(),
    accion VARCHAR(100) NOT NULL,
    id_proceso INTEGER NOT NULL REFERENCES public."Procesos" (id_proceso) ON DELETE CASCADE,
    id_admin INTEGER NOT NULL REFERENCES public."Administrativo" (id_admin) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_historial_proceso ON public."HistorialProcesos" (id_proceso);
CREATE INDEX IF NOT EXISTS idx_historial_admin ON public."HistorialProcesos" (id_admin);
CREATE INDEX IF NOT EXISTS idx_historial_fecha ON public."HistorialProcesos" (fecha_accion);

COMMENT ON TABLE public."HistorialProcesos" IS 'Registra los cambios realizados en los procesos';

insert into public."Procesos" (id_proceso, "tipoProceso", "fechaInicio", "fechaFinal", estado, "id_sedeXescuela", id_admin) values
(1, ARRAY['Inclusion'], '2025-05-27', '2025-06-03', true, 17, 11),
(2, ARRAY['Levantamiento'], '2025-05-27', '2025-06-03', true, 17, 11)



WITH RankedProcesos AS (
            SELECT 
                p.*,
                ROW_NUMBER() OVER (PARTITION BY p."tipoProceso"[1] ORDER BY p.id_proceso DESC) as rn
            FROM 
                "Procesos" p
            WHERE 
                p."id_sedeXescuela" = 17
        )
        SELECT 
            id_proceso,
            "tipoProceso"[1] as tipo_proceso,
            "fechaInicio",
            "fechaFinal",
            estado,
            "id_sedeXescuela",
            id_admin
        FROM 
            RankedProcesos
        WHERE 
            rn = 1
        ORDER BY 
            "tipoProceso"[1]
            
            
            
SELECT 
            h.id_historial,
            h.fecha_accion,
            h.accion,
            h.id_proceso,
            p."tipoProceso"[1] as tipo_proceso,
            a."Rol"[1] as rol_admin,
            pe.nombre[1] || ' ' || pe.apellido[1] as nombre_usuario
        FROM 
            "HistorialProcesos" h
        INNER JOIN 
            "Procesos" p ON h.id_proceso = p.id_proceso
        INNER JOIN
            "Administrativo" a ON h.id_admin = a.id_admin
        INNER JOIN
            "Persona" pe ON a.id_persona_fk = pe.id_persona_escalar
        WHERE 
            p."id_sedeXescuela" = 17
        ORDER BY 
            h.fecha_accion DESC
        LIMIT 10            
        
        
        
SELECT 
            id_proceso,
            "tipoProceso"[1] as tipo_proceso,
            "id_sedeXescuela",
            estado
        FROM 
            "Procesos"
        WHERE 
            id_proceso = 1   
            
            
SELECT COUNT(*) as count
            FROM "Procesos"
            WHERE 
                "id_sedeXescuela" = 17 AND
                "tipoProceso"[1] = 'Levantamiento' AND
                estado = true AND
                id_proceso != 2
                
UPDATE "Procesos"
        SET estado = NOT estado
        WHERE id_proceso = 1
        RETURNING estado
        
INSERT INTO "HistorialProcesos" (fecha_accion, accion, id_proceso, id_admin)
        VALUES (NOW(), 'Activación de proceso', 1, 11)
        

        
UPDATE "Procesos"
        SET 
            "fechaInicio" = '2025-05-27',
            "fechaFinal" = '2025-05-05'
        WHERE 
            id_proceso = 1
        RETURNING "tipoProceso"[1] as tipo_proceso
        
INSERT INTO "HistorialProcesos" (fecha_accion, accion, id_proceso, id_admin)
        VALUES (NOW(), 'Modificación de fechas', 1, 11)   
        
        
        
SELECT 
                p."tipoProceso"[1] as tipo_proceso,
                s.nombre as nombre_sede,
                e.nombre as nombre_escuela,
                p2.nombre[1] || ' ' || p2.apellido[1] || ' ' || p2.apellido[2] nombre_admin 
            FROM 
                "Procesos" p
            JOIN 
                "SedeEscuela" se ON p."id_sedeXescuela" = se."id_sedeXescuela"
            JOIN 
                "Sede" s ON se.id_sede = s.id_sede
            JOIN 
                "Escuela" e ON se.id_escuela = e.id_escuela
            join "Administrativo" a on a."id_sedeXescuela" = p."id_sedeXescuela"
            join "Persona" p2 on  a.id_persona_fk = p2.id_persona_escalar  
            WHERE 
                p.id_proceso = 1     
                
                
SELECT e.correo 
                FROM "Persona" e
                WHERE correo[1] LIKE '%@estudiantec.cr'            