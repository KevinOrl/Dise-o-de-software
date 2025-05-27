from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS, cross_origin
import os
from dotenv import load_dotenv
from sqlalchemy import text


# Cargar variables de entorno
load_dotenv()

# Configuración de la aplicación
app = Flask(__name__)

# Configuración de PostgreSQL
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
CORS(app)

# Inicializar la conexión a la BD
db = SQLAlchemy(app)

# Endpoint de prueba
@app.route('/api/test', methods=['GET'])
def test_connection():
    try:
        # Intenta hacer una consulta simple para verificar la conexión
        db.session.execute(text('SELECT 1'))        
        return jsonify({
            'status': 'success',
            'message': 'Conexión a la API y base de datos exitosa!'
        })
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': f'Error de conexión: {str(e)}'
        }), 500

# Endpoint para crear una sede usando SQL directo
@app.route('/api/sedes', methods=['POST'])
def crear_sede():
    try:
        # Obtener datos del request
        data = request.json
        
        # Validar datos
        if not data or 'id_sede' not in data or 'nombre' not in data:
            return jsonify({
                'status': 'error',
                'message': 'Se requieren los campos id_sede y nombre'
            }), 400
            
        # Ejecutar SQL directamente para insertar la sede
        # Nota: ARRAY[...] crea un array PostgreSQL
        sql = text("INSERT INTO \"Sede\" (id_sede, nombre) VALUES (:id, ARRAY[:nombre])")
        db.session.execute(sql, {"id": data['id_sede'], "nombre": data['nombre']})
        db.session.commit()
        
        return jsonify({
            'status': 'success',
            'message': 'Sede creada correctamente',
            'sede': {
                'id_sede': data['id_sede'],
                'nombre': data['nombre']
            }
        }), 201
        
    except Exception as e:
        # Hacer rollback en caso de error
        db.session.rollback()
        return jsonify({
            'status': 'error',
            'message': f'Error al crear sede: {str(e)}'
        }), 500

# Endpoint para listar sedes (para verificación)
@app.route('/api/sedes', methods=['GET'])
def listar_sedes():
    try:
        # Consulta SQL directa para obtener todas las sedes
        resultado = db.session.execute(text('SELECT id_sede, nombre FROM "Sede"'))
        
        # Convertir resultados a lista de diccionarios
        sedes = []
        for fila in resultado:
            # El campo nombre es un array en PostgreSQL, tomamos el primer elemento
            nombre_valor = fila.nombre[0] if fila.nombre else None
            sedes.append({
                'id_sede': fila.id_sede,
                'nombre': nombre_valor
            })
        
        return jsonify({
            'status': 'success',
            'sedes': sedes
        })
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': f'Error al listar sedes: {str(e)}'
        }), 500

# Endpoint para autenticación de usuarios
@app.route('/api/auth/login', methods=['POST'])
def login():
    try:
        # Obtener credenciales del request
        data = request.json
        
        if not data or 'email' not in data or 'password' not in data:
            return jsonify({
                'status': 'error',
                'message': 'Se requieren email y contraseña'
            }), 400
        
        email = data['email']
        password = data['password']
        
        # Determinar tipo de usuario basado en el dominio del correo
        if '@estudiantec.cr' in email:
            # Buscar estudiante en la base de datos
            query = text("""
                SELECT e.id_estudiante, e.carnet, e.id_sede, e.id_carrera, p.nombre, p.apellido, p."contraseña"
                FROM "Estudiante" e
                JOIN "Persona" p ON LOWER(p.correo[1]) = LOWER(:email)
                WHERE LOWER(p.correo[1]) = LOWER(:email)
            """)
            result = db.session.execute(query, {"email": email})
            user_data = result.fetchone()
            
            if not user_data:
                return jsonify({
                    'status': 'error',
                    'message': 'Usuario no encontrado'
                }), 404
            
            # Verificar contraseña (en producción usar hash)
            if user_data.contraseña[0] != password:
                return jsonify({
                    'status': 'error',
                    'message': 'Contraseña incorrecta'
                }), 401
            
            return jsonify({
                'status': 'success',
                'userType': 'estudiante',
                'user': {
                    'id': user_data.id_estudiante,
                    'email': email,
                    'nombre': user_data.nombre[0] if user_data.nombre else '',
                    'apellido': user_data.apellido[0] if user_data.apellido else '',
                    'carnet': user_data.carnet,
                    'id_sede': user_data.id_sede,
                    'id_carrera': user_data.id_carrera
                }
            })
            
        elif '@itcr.ac.cr' in email:
            # Buscar administrativo en la base de datos
            query = text("""
                SELECT a.id_admin, a."id_sedeXescuela", a.id_departamento, a."Rol", p.nombre, p.apellido, p."contraseña"
                FROM "Administrativo" a
                JOIN "Persona" p ON p.id_persona_escalar = a.id_persona_fk
                WHERE LOWER(p.correo[1]) = LOWER(:email)      
            """)
            result = db.session.execute(query, {"email": email})
            user_data = result.fetchone()
            
            if not user_data:
                return jsonify({
                    'status': 'error',
                    'message': 'Usuario no encontrado'
                }), 404
            
            # Verificar contraseña (en producción usar hash)
            if user_data.contraseña[0] != password:
                return jsonify({
                    'status': 'error',
                    'message': 'Contraseña incorrecta'
                }), 401
            
            return jsonify({
                'status': 'success',
                'userType': 'admin',
                'user': {
                    'id': user_data.id_admin,
                    'email': email,
                    'nombre': user_data.nombre[0] if user_data.nombre else '',
                    'apellido': user_data.apellido[0] if user_data.apellido else '',
                    'role': user_data.Rol[0] if user_data.Rol else 'USUARIO',
                    'id_sedeXescuela': user_data.id_sedeXescuela,
                    'id_departamento': user_data.id_departamento
                }
            })
        else:
            return jsonify({
                'status': 'error',
                'message': 'Dominio de correo no válido para este sistema'
            }), 400
            
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': f'Error en autenticación: {str(e)}'
        }), 500


###LEVANTAMIENTOS ADMINISTRATIVOS
###
###

@app.route('/api/solicitudes/levantamiento/<sedexescuela>', methods=['GET'])
@cross_origin()
def get_solicitudes_levantamiento(sedexescuela):
    """
    Obtiene la lista de cursos con sus solicitudes de levantamiento
    agrupados por curso y grupo
    """
    try:
        # Utilizamos SQLAlchemy (db) en lugar de una conexión directa
        query = text("""
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
            'Levantamiento' = ANY(s.tipo_solicitud) and g."id_sedeXescuela" = :sedexescuela
        GROUP BY 
            c.codigo_curso, c.nombre, c.creditos, g.id_grupo
        ORDER BY
            c.codigo_curso
        """)
        
        # Ejecutar la consulta usando SQLAlchemy
        result = db.session.execute(query, {"sedexescuela": sedexescuela})
        
        # Convertir resultados a una lista de diccionarios
        resultado = []
        for row in result:
            resultado.append({
                "codigo": row.codigo_curso,
                "nombre": row.nombre,
                "creditos": row.creditos,
                "grupo": row.id_grupo,
                "solicitudes": int(row.total_solicitudes)
            })
        
        return jsonify({
            "status": "success",
            "data": resultado,
            "message": "Datos de solicitudes de levantamiento obtenidos correctamente"
        }), 200
        
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": f"Error al obtener las solicitudes: {str(e)}"
        }), 500

@app.route('/api/solicitudes/levantamiento/<codigo>/<grupo>', methods=['GET'])
@cross_origin()
def get_solicitudes_levantamiento_por_curso_grupo(codigo, grupo):
    """
    Obtiene las solicitudes de levantamiento para un curso y grupo específico
    """
    try:
        # Obtener información del curso
        curso_query = text("""
        SELECT 
            c.codigo_curso, 
            c.nombre as nombre, 
            c.creditos
        FROM 
            public."Curso" c  
        WHERE 
            c.codigo_curso = :codigo
        """)
        
        curso_result = db.session.execute(curso_query, {"codigo": codigo})
        curso_data = curso_result.fetchone()
        
        if not curso_data:
            return jsonify({
                "status": "error",
                "message": f"No se encontró el curso con código {codigo}"
            }), 404
            
        # Obtener las solicitudes para el grupo específico
        solicitudes_query = text("""
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
        """)
        
        solicitudes_result = db.session.execute(solicitudes_query, {"grupo": grupo})
        
        # Convertir los resultados a lista de diccionarios
        solicitudes = []
        for row in solicitudes_result:
            solicitudes.append({
                "id": row.id_solicitud,
                "carnet": row.carnet,
                "nombre": row.nombre_estudiante,
                "fecha": row.fecha_solicitud,
                "prioridad": row.prioridad,
                "estado": row.estado
            })
        
        # Construir respuesta
        return jsonify({
            "status": "success",
            "data": {
                "curso": {
                    "codigo": curso_data.codigo_curso,
                    "nombre": curso_data.nombre,
                    "creditos": curso_data.creditos,
                    "grupo": grupo
                },
                "solicitudes": solicitudes,
                "total": len(solicitudes)
            },
            "message": "Datos de solicitudes obtenidos correctamente"
        }), 200
        
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": f"Error al obtener las solicitudes para el curso {codigo}, grupo {grupo}: {str(e)}"
        }), 500

# Endpoint para obtener detalles de una solicitud específica
@app.route('/api/solicitudes/levantamiento/<codigo>/<grupo>/<int:id_solicitud>', methods=['GET'])
@cross_origin()
def get_detalle_solicitud_levantamiento_individual(codigo, grupo, id_solicitud):
    """
    Obtiene los detalles de una solicitud específica de levantamiento
    """
    try:
        # Obtener información del curso
        curso_query = text("""
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
            c.codigo_curso = :codigo AND g.id_grupo = :grupo
        """)
        
        curso_result = db.session.execute(curso_query, {"codigo": codigo, "grupo": grupo})
        curso_data = curso_result.fetchone()
        
        if not curso_data:
            return jsonify({
                "status": "error",
                "message": f"No se encontró el curso {codigo} con grupo {grupo}"
            }), 404
        
        # Obtener requisitos del curso
        requisitos_query = text("""
        SELECT 
            c2.codigo_curso,
            c2.nombre as nombre,
            r.tipo
        FROM 
            "Requisitos" r
        INNER JOIN 
            "Curso" c2 ON c2.codigo_curso = r.codigo_requisito
        WHERE 
            r.codigo_curso = :codigo
        """)
        
        requisitos_result = db.session.execute(requisitos_query, {"codigo": codigo})
        requisitos = []
        
        for req in requisitos_result:
            requisitos.append({
                "codigo": req.codigo_curso,
                "nombre": req.nombre,
                "tipo": "Requisito" if req.tipo == 1 else "Correquisito"
            })
        
        # Obtener la solicitud específica
        solicitud_query = text("""
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
            s.id_solicitud = :id_solicitud AND
            s.id_grupo = :grupo
        """)
        
        solicitud_result = db.session.execute(solicitud_query, {
            "id_solicitud": id_solicitud,
            "grupo": grupo
        })
        
        solicitud_data = solicitud_result.fetchone()
        
        if not solicitud_data:
            return jsonify({
                "status": "error",
                "message": f"No se encontró la solicitud con ID {id_solicitud}"
            }), 404
        
        # Obtener datos del estudiante
        estudiante_query = text("""
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
            e.carnet = :carnet
        """)
        
        estudiante_result = db.session.execute(estudiante_query, {"carnet": solicitud_data.carnet})
        estudiante_data = estudiante_result.fetchone()
        
        # Obtener documentos adjuntos (si hay)
        # Aquí usaría una tabla de documentos si existiera
        documentos = [
            {"nombre": "certificacion_notas.pdf", "url": "#"},
            {"nombre": "programa_curso.pdf", "url": "#"}
        ]
        
        return jsonify({
            "status": "success",
            "data": {
                "solicitud": {
                    "id": solicitud_data.id_solicitud,
                    "carnet": solicitud_data.carnet,
                    "fecha": solicitud_data.fecha_solicitud,
                    "revisado": solicitud_data.revisado,
                    "estado": solicitud_data.estado,
                    "motivo": solicitud_data.motivo,
                    "comentarioAdmin": solicitud_data.comentario_admin,
                    "prioridad": solicitud_data.prioridad,
                    "documentos": documentos
                },
                "estudiante": {
                    "nombre": estudiante_data.nombre,
                    "correo": estudiante_data.correo,
                    "telefono": estudiante_data.telefono
                },
                "curso": {
                    "codigo": curso_data.codigo_curso,
                    "nombre": curso_data.nombre,
                    "creditos": curso_data.creditos,
                    "grupo": curso_data.id_grupo,
                    "requisitos": requisitos
                }
            },
            "message": "Datos de la solicitud obtenidos correctamente"
        }), 200
        
    except Exception as e:
        import traceback
        print(f"Error en detalle de solicitud: {str(e)}")
        print(traceback.format_exc())
        
        return jsonify({
            "status": "error",
            "message": f"Error al obtener los detalles de la solicitud: {str(e)}"
        }), 500

# Endpoint para marcar una solicitud como revisada (rol asistente)
@app.route('/api/solicitudes/levantamiento/<int:id_solicitud>/revisar', methods=['PUT'])
@cross_origin()
def revisar_solicitud_levantamiento(id_solicitud):
    """
    Marca una solicitud como revisada (rol asistente)
    """
    try:
        data = request.json
        comentario = data.get('comentario', '')
        
        query = text("""
        UPDATE public."Solicitudes"
        SET 
            revisado = TRUE,
            estado = ARRAY['Pendiente']::varchar[],
            comentario_admin = ARRAY[:comentario]::varchar[]
        WHERE 
            id_solicitud = :id_solicitud AND
            'Levantamiento' = ANY(tipo_solicitud)
        RETURNING id_solicitud
        """)
        
        result = db.session.execute(query, {"id_solicitud": id_solicitud, "comentario": comentario})
        updated = result.fetchone()
        db.session.commit()
        
        if not updated:
            return jsonify({
                "status": "error",
                "message": f"No se encontró la solicitud con ID {id_solicitud} o no es de tipo levantamiento"
            }), 404
            
        return jsonify({
            "status": "success",
            "message": "Solicitud marcada como revisada correctamente"
        }), 200
            
    except Exception as e:
        db.session.rollback()
        return jsonify({
            "status": "error",
            "message": f"Error al actualizar la solicitud: {str(e)}"
        }), 500

# Endpoint para aprobar una solicitud (rol coordinador)
@app.route('/api/solicitudes/levantamiento/<int:id_solicitud>/aprobar', methods=['PUT'])
@cross_origin()
def aprobar_solicitud_levantamiento(id_solicitud):
    """
    Aprueba una solicitud de levantamiento (rol coordinador)
    """
    try:
        data = request.json
        comentario = data.get('comentario', '')
        
        # Primero verificamos que la solicitud esté revisada
        check_query = text("""
        SELECT revisado FROM public."Solicitudes"
        WHERE id_solicitud = :id_solicitud
        """)
        
        check_result = db.session.execute(check_query, {"id_solicitud": id_solicitud})
        solicitud = check_result.fetchone()
        
        if not solicitud:
            return jsonify({
                "status": "error",
                "message": f"No se encontró la solicitud con ID {id_solicitud}"
            }), 404
            
        if not solicitud.revisado:
            return jsonify({
                "status": "error",
                "message": "La solicitud debe ser revisada antes de poder ser aprobada"
            }), 400
        
        # Actualizar la solicitud
        query = text("""
        UPDATE public."Solicitudes"
        SET 
            estado = ARRAY['Aprobada']::varchar[],
            comentario_admin = ARRAY[:comentario]::varchar[]
        WHERE 
            id_solicitud = :id_solicitud AND
            'Levantamiento' = ANY(tipo_solicitud) AND
            revisado = TRUE
        RETURNING id_solicitud
        """)
        
        result = db.session.execute(query, {"id_solicitud": id_solicitud, "comentario": comentario})
        updated = result.fetchone()
        db.session.commit()
        
        if not updated:
            return jsonify({
                "status": "error",
                "message": f"No se pudo aprobar la solicitud con ID {id_solicitud}"
            }), 400
            
        return jsonify({
            "status": "success",
            "message": "Solicitud aprobada correctamente"
        }), 200
            
    except Exception as e:
        db.session.rollback()
        return jsonify({
            "status": "error",
            "message": f"Error al aprobar la solicitud: {str(e)}"
        }), 500

# Endpoint para denegar una solicitud (rol coordinador)
@app.route('/api/solicitudes/levantamiento/<int:id_solicitud>/denegar', methods=['PUT'])
@cross_origin()
def denegar_solicitud_levantamiento(id_solicitud):
    """
    Deniega una solicitud de levantamiento (rol coordinador)
    """
    try:
        data = request.json
        comentario = data.get('comentario', '')
        
        if not comentario.strip():
            return jsonify({
                "status": "error",
                "message": "Se requiere un comentario para denegar una solicitud"
            }), 400
        
        # Primero verificamos que la solicitud esté revisada
        check_query = text("""
        SELECT revisado FROM public."Solicitudes"
        WHERE id_solicitud = :id_solicitud
        """)
        
        check_result = db.session.execute(check_query, {"id_solicitud": id_solicitud})
        solicitud = check_result.fetchone()
        
        if not solicitud:
            return jsonify({
                "status": "error",
                "message": f"No se encontró la solicitud con ID {id_solicitud}"
            }), 404
            
        if not solicitud.revisado:
            return jsonify({
                "status": "error",
                "message": "La solicitud debe ser revisada antes de poder ser denegada"
            }), 400
        
        # Actualizar la solicitud
        query = text("""
        UPDATE public."Solicitudes"
        SET 
            estado = ARRAY['Denegada']::varchar[],
            comentario_admin = ARRAY[:comentario]::varchar[]
        WHERE 
            id_solicitud = :id_solicitud AND
            'Levantamiento' = ANY(tipo_solicitud) AND
            revisado = TRUE
        RETURNING id_solicitud
        """)
        
        result = db.session.execute(query, {"id_solicitud": id_solicitud, "comentario": comentario})
        updated = result.fetchone()
        db.session.commit()
        
        if not updated:
            return jsonify({
                "status": "error",
                "message": f"No se pudo denegar la solicitud con ID {id_solicitud}"
            }), 400
            
        return jsonify({
            "status": "success",
            "message": "Solicitud denegada correctamente"
        }), 200
            
    except Exception as e:
        db.session.rollback()
        return jsonify({
            "status": "error",
            "message": f"Error al denegar la solicitud: {str(e)}"
        }), 500


###INCLUSIONES
###
###

@app.route('/api/solicitudes/inclusiones/<sedexescuela>', methods=['GET'])
@cross_origin()
def get_solicitudes_inclusiones(sedexescuela):
    """
    Obtiene la lista de cursos con sus solicitudes de inclusion
    agrupados por curso y grupo
    """
    try:
        # Utilizamos SQLAlchemy (db) en lugar de una conexión directa
        query = text("""
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
        """)
        
        # Ejecutar la consulta usando SQLAlchemy
        result = db.session.execute(query, {"sedexescuela": sedexescuela})
        
        # Convertir resultados a una lista de diccionarios
        resultado = []
        for row in result:
            resultado.append({
                "codigo": row.codigo_curso,
                "nombre": row.nombre,
                "creditos": row.creditos,
                "grupo": row.id_grupo,
                "solicitudes": int(row.total_solicitudes)
            })
        
        return jsonify({
            "status": "success",
            "data": resultado,
            "message": "Datos de solicitudes de levantamiento obtenidos correctamente"
        }), 200
        
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": f"Error al obtener las solicitudes: {str(e)}"
        }), 500


@app.route('/api/solicitudes/inclusion/<codigo>/<grupo>', methods=['GET'])
@cross_origin()
def get_solicitudes_inclusion_por_curso_grupo(codigo, grupo):
    """
    Obtiene las solicitudes de inclusion para un curso y grupo específico
    """
    try:
        # Obtener información del curso
        curso_query = text("""
        SELECT 
            c.codigo_curso, 
            c.nombre as nombre, 
            c.creditos
        FROM 
            public."Curso" c  
        WHERE 
            c.codigo_curso = :codigo
        """)
        
        curso_result = db.session.execute(curso_query, {"codigo": codigo})
        curso_data = curso_result.fetchone()
        
        if not curso_data:
            return jsonify({
                "status": "error",
                "message": f"No se encontró el curso con código {codigo}"
            }), 404
            
        # Obtener las solicitudes para el grupo específico
        solicitudes_query = text("""
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
            'Inclusion' = ANY(s.tipo_solicitud)
        ORDER BY
            -- Ordenar por prioridad (Alta, Media, Baja) y luego por ID
            CASE 
                WHEN s.id_solicitud % 3 = 0 THEN 1  -- Alta primero
                WHEN s.id_solicitud % 3 = 1 THEN 2  -- Media segundo
                ELSE 3  -- Baja último
            END,
            s.id_solicitud
        """)
        
        solicitudes_result = db.session.execute(solicitudes_query, {"grupo": grupo})
        
        # Convertir los resultados a lista de diccionarios
        solicitudes = []
        for row in solicitudes_result:
            solicitudes.append({
                "id": row.id_solicitud,
                "carnet": row.carnet,
                "nombre": row.nombre_estudiante,
                "fecha": row.fecha_solicitud,
                "prioridad": row.prioridad,
                "estado": row.estado
            })
        
        # Construir respuesta
        return jsonify({
            "status": "success",
            "data": {
                "curso": {
                    "codigo": curso_data.codigo_curso,
                    "nombre": curso_data.nombre,
                    "creditos": curso_data.creditos,
                    "grupo": grupo
                },
                "solicitudes": solicitudes,
                "total": len(solicitudes)
            },
            "message": "Datos de solicitudes obtenidos correctamente"
        }), 200
        
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": f"Error al obtener las solicitudes para el curso {codigo}, grupo {grupo}: {str(e)}"
        }), 500

# Endpoint para obtener detalles de una solicitud específica
@app.route('/api/solicitudes/inclusion/<codigo>/<grupo>/<int:id_solicitud>', methods=['GET'])
@cross_origin()
def get_detalle_solicitud_inclusion_individual(codigo, grupo, id_solicitud):
    """
    Obtiene los detalles de una solicitud específica de inclusion
    """
    try:
        # Obtener información del curso
        curso_query = text("""
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
            c.codigo_curso = :codigo AND g.id_grupo = :grupo
        """)
        
        curso_result = db.session.execute(curso_query, {"codigo": codigo, "grupo": grupo})
        curso_data = curso_result.fetchone()
        
        if not curso_data:
            return jsonify({
                "status": "error",
                "message": f"No se encontró el curso {codigo} con grupo {grupo}"
            }), 404
        
        # Obtener requisitos del curso
        requisitos_query = text("""
        SELECT 
            c2.codigo_curso,
            c2.nombre as nombre,
            r.tipo
        FROM 
            "Requisitos" r
        INNER JOIN 
            "Curso" c2 ON c2.codigo_curso = r.codigo_requisito
        WHERE 
            r.codigo_curso = :codigo
        """)
        
        requisitos_result = db.session.execute(requisitos_query, {"codigo": codigo})
        requisitos = []
        
        for req in requisitos_result:
            requisitos.append({
                "codigo": req.codigo_curso,
                "nombre": req.nombre,
                "tipo": "Requisito" if req.tipo == 1 else "Correquisito"
            })
        
        # Obtener la solicitud específica
        solicitud_query = text("""
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
            s.id_solicitud = :id_solicitud AND
            s.id_grupo = :grupo
        """)
        
        solicitud_result = db.session.execute(solicitud_query, {
            "id_solicitud": id_solicitud,
            "grupo": grupo
        })
        
        solicitud_data = solicitud_result.fetchone()
        
        if not solicitud_data:
            return jsonify({
                "status": "error",
                "message": f"No se encontró la solicitud con ID {id_solicitud}"
            }), 404
        
        # Obtener datos del estudiante
        estudiante_query = text("""
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
            e.carnet = :carnet
        """)
        
        estudiante_result = db.session.execute(estudiante_query, {"carnet": solicitud_data.carnet})
        estudiante_data = estudiante_result.fetchone()
        
        # Obtener documentos adjuntos (si hay)
        # Aquí usaría una tabla de documentos si existiera
        documentos = [
            {"nombre": "certificacion_notas.pdf", "url": "#"},
            {"nombre": "programa_curso.pdf", "url": "#"}
        ]
        
        return jsonify({
            "status": "success",
            "data": {
                "solicitud": {
                    "id": solicitud_data.id_solicitud,
                    "carnet": solicitud_data.carnet,
                    "fecha": solicitud_data.fecha_solicitud,
                    "revisado": solicitud_data.revisado,
                    "estado": solicitud_data.estado,
                    "motivo": solicitud_data.motivo,
                    "comentarioAdmin": solicitud_data.comentario_admin,
                    "prioridad": solicitud_data.prioridad,
                    "documentos": documentos
                },
                "estudiante": {
                    "nombre": estudiante_data.nombre,
                    "correo": estudiante_data.correo,
                    "telefono": estudiante_data.telefono
                },
                "curso": {
                    "codigo": curso_data.codigo_curso,
                    "nombre": curso_data.nombre,
                    "creditos": curso_data.creditos,
                    "grupo": curso_data.id_grupo,
                    "requisitos": requisitos
                }
            },
            "message": "Datos de la solicitud obtenidos correctamente"
        }), 200
        
    except Exception as e:
        import traceback
        print(f"Error en detalle de solicitud: {str(e)}")
        print(traceback.format_exc())
        
        return jsonify({
            "status": "error",
            "message": f"Error al obtener los detalles de la solicitud: {str(e)}"
        }), 500

# Endpoint para marcar una solicitud como revisada (rol asistente)
@app.route('/api/solicitudes/inclusion/<int:id_solicitud>/revisar', methods=['PUT'])
@cross_origin()
def revisar_solicitud_inclusion(id_solicitud):
    """
    Marca una solicitud como revisada (rol asistente)
    """
    try:
        data = request.json
        comentario = data.get('comentario', '')
        
        query = text("""
        UPDATE public."Solicitudes"
        SET 
            revisado = TRUE,
            estado = ARRAY['Pendiente']::varchar[],
            comentario_admin = ARRAY[:comentario]::varchar[]
        WHERE 
            id_solicitud = :id_solicitud AND
            'Inclusion' = ANY(tipo_solicitud)
        RETURNING id_solicitud
        """)
        
        result = db.session.execute(query, {"id_solicitud": id_solicitud, "comentario": comentario})
        updated = result.fetchone()
        db.session.commit()
        
        if not updated:
            return jsonify({
                "status": "error",
                "message": f"No se encontró la solicitud con ID {id_solicitud} o no es de tipo levantamiento"
            }), 404
            
        return jsonify({
            "status": "success",
            "message": "Solicitud marcada como revisada correctamente"
        }), 200
            
    except Exception as e:
        db.session.rollback()
        return jsonify({
            "status": "error",
            "message": f"Error al actualizar la solicitud: {str(e)}"
        }), 500

# Endpoint para aprobar una solicitud (rol coordinador)
@app.route('/api/solicitudes/inclusion/<int:id_solicitud>/aprobar', methods=['PUT'])
@cross_origin()
def aprobar_solicitud_inclusion(id_solicitud):
    """
    Aprueba una solicitud de inclusion (rol coordinador)
    """
    try:
        data = request.json
        comentario = data.get('comentario', '')
        
        # Primero verificamos que la solicitud esté revisada
        check_query = text("""
        SELECT revisado FROM public."Solicitudes"
        WHERE id_solicitud = :id_solicitud
        """)
        
        check_result = db.session.execute(check_query, {"id_solicitud": id_solicitud})
        solicitud = check_result.fetchone()
        
        if not solicitud:
            return jsonify({
                "status": "error",
                "message": f"No se encontró la solicitud con ID {id_solicitud}"
            }), 404
            
        if not solicitud.revisado:
            return jsonify({
                "status": "error",
                "message": "La solicitud debe ser revisada antes de poder ser aprobada"
            }), 400
        
        # Actualizar la solicitud
        query = text("""
        UPDATE public."Solicitudes"
        SET 
            estado = ARRAY['Aprobada']::varchar[],
            comentario_admin = ARRAY[:comentario]::varchar[]
        WHERE 
            id_solicitud = :id_solicitud AND
            'Inclusion' = ANY(tipo_solicitud) AND
            revisado = TRUE
        RETURNING id_solicitud
        """)
        
        result = db.session.execute(query, {"id_solicitud": id_solicitud, "comentario": comentario})
        updated = result.fetchone()
        db.session.commit()
        
        if not updated:
            return jsonify({
                "status": "error",
                "message": f"No se pudo aprobar la solicitud con ID {id_solicitud}"
            }), 400
            
        return jsonify({
            "status": "success",
            "message": "Solicitud aprobada correctamente"
        }), 200
            
    except Exception as e:
        db.session.rollback()
        return jsonify({
            "status": "error",
            "message": f"Error al aprobar la solicitud: {str(e)}"
        }), 500

# Endpoint para denegar una solicitud (rol coordinador)
@app.route('/api/solicitudes/inclusion/<int:id_solicitud>/denegar', methods=['PUT'])
@cross_origin()
def denegar_solicitud_inclusion(id_solicitud):
    """
    Deniega una solicitud de inclusion (rol coordinador)
    """
    try:
        data = request.json
        comentario = data.get('comentario', '')
        
        if not comentario.strip():
            return jsonify({
                "status": "error",
                "message": "Se requiere un comentario para denegar una solicitud"
            }), 400
        
        # Primero verificamos que la solicitud esté revisada
        check_query = text("""
        SELECT revisado FROM public."Solicitudes"
        WHERE id_solicitud = :id_solicitud
        """)
        
        check_result = db.session.execute(check_query, {"id_solicitud": id_solicitud})
        solicitud = check_result.fetchone()
        
        if not solicitud:
            return jsonify({
                "status": "error",
                "message": f"No se encontró la solicitud con ID {id_solicitud}"
            }), 404
            
        if not solicitud.revisado:
            return jsonify({
                "status": "error",
                "message": "La solicitud debe ser revisada antes de poder ser denegada"
            }), 400
        
        # Actualizar la solicitud
        query = text("""
        UPDATE public."Solicitudes"
        SET 
            estado = ARRAY['Denegada']::varchar[],
            comentario_admin = ARRAY[:comentario]::varchar[]
        WHERE 
            id_solicitud = :id_solicitud AND
            'Inclusion' = ANY(tipo_solicitud) AND
            revisado = TRUE
        RETURNING id_solicitud
        """)
        
        result = db.session.execute(query, {"id_solicitud": id_solicitud, "comentario": comentario})
        updated = result.fetchone()
        db.session.commit()
        
        if not updated:
            return jsonify({
                "status": "error",
                "message": f"No se pudo denegar la solicitud con ID {id_solicitud}"
            }), 400
            
        return jsonify({
            "status": "success",
            "message": "Solicitud denegada correctamente"
        }), 200
            
    except Exception as e:
        db.session.rollback()
        return jsonify({
            "status": "error",
            "message": f"Error al denegar la solicitud: {str(e)}"
        }), 500

# Ejecutar la aplicación
if __name__ == '__main__':
    app.run(debug=True)