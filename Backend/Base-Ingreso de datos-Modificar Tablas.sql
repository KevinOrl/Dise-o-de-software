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

