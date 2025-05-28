import datetime
from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS, cross_origin
import os
from dotenv import load_dotenv
from sqlalchemy import text
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import datetime

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

# Endpoint para listar carreras
@app.route('/api/carreras', methods=['GET'])
def listar_carreras():
    try:
        resultado = db.session.execute(text('SELECT id_carrera, nombre FROM "Carrera"'))

        carreras = []
        for fila in resultado:
            nombre_valor = fila.nombre[0] if fila.nombre else None
            carreras.append({
                'id_carrera': fila.id_carrera,
                'nombre': nombre_valor
            })

        return jsonify({
            'status': 'success',
            'carreras': carreras
        })
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': f'Error al listar carreras: {str(e)}'
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

# Endpoint para obtener el historial de solicitudes de un estudiante
@app.route('/api/historial-solicitudes/<int:id_estudiante>', methods=['GET'])
def historial_solicitudes(id_estudiante):
    try:
        sql = text("""
            SELECT id_historial_solicitud AS id_historial_solicitud, codigo_curso, "fechaRetiro", semestre, anio, id_solicitud
            FROM "HistorialSolicitudes"
            WHERE id_estudiante = :id
            ORDER BY anio DESC, semestre DESC, "fechaRetiro" DESC
        """)
        resultado = db.session.execute(sql, {"id": id_estudiante})
        historial = [{
            "id_historial_solicitud": r.id_historial_solicitud,
            "codigo_curso": r.codigo_curso,
            "fechaRetiro": r.fechaRetiro,
            "semestre": r.semestre,
            "anio": r.anio,
            "id_solicitud": r.id_solicitud
        } for r in resultado]

        return jsonify({"status": "success", "data": historial})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

# Endpoint para obtener el historial de retiros de un estudiante
@app.route('/api/historial-retiros/<int:id_estudiante>', methods=['GET'])
def historial_retiros(id_estudiante):
    try:
        sql = text("""
            SELECT id_retiro, codigo_curso, "fechaRetiro", semestre, anio
            FROM "HistorialRetiros"
            WHERE id_estudiante = :id
            ORDER BY anio DESC, semestre DESC, "fechaRetiro" DESC
        """)
        resultado = db.session.execute(sql, {"id": id_estudiante})
        historial = [{
            "id_retiro": r.id_retiro,
            "codigo_curso": r.codigo_curso,
            "fechaRetiro": r.fechaRetiro,
            "semestre": r.semestre,
            "anio": r.anio
        } for r in resultado]

        return jsonify({"status": "success", "data": historial})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

# Endpoint para obtener los cursos disponibles según el tipo de matrícula
@app.route('/api/matriculas/<tipo>', methods=['GET'])
def cursos_disponibles(tipo):
    try:
        tipo = tipo.lower()
        if tipo not in ['semestre', 'inclusion', 'levantamiento']:
            return jsonify({
                'status': 'error',
                'message': 'Tipo de matrícula no válido.'
            }), 400

        # Armar la cláusula WHERE según el tipo
        condicion_tipo = ""
        if tipo == 'semestre':
            condicion_tipo = "TRUE"  # Todos los grupos normales
        else:
            condicion_tipo = f"'{tipo.capitalize()}' = ANY(s.tipo_solicitud)"

        # Consulta SQL dinámica
        sql = text(f"""
            SELECT 
                c.codigo_curso,
                c.nombre[1] AS nombre,
                c.creditos,
                g.id_grupo
            FROM 
                public."Curso" c
            INNER JOIN 
                "Grupo" g ON g.codigo_curso = c.codigo_curso
            LEFT JOIN 
                "Solicitudes" s ON s.id_grupo = g.id_grupo
            WHERE 
                {condicion_tipo}
            GROUP BY 
                c.codigo_curso, c.nombre, c.creditos, g.id_grupo
            ORDER BY 
                c.codigo_curso
        """)

        result = db.session.execute(sql)

        cursos = []
        for row in result:
            cursos.append({
                "codigo": row.codigo_curso,
                "nombre": row.nombre,
                "creditos": row.creditos,
                "grupo": row.id_grupo
            })

        return jsonify({
            "status": "success",
            "data": cursos
        }), 200

    except Exception as e:
        return jsonify({
            "status": "error",
            "message": f"Error al obtener cursos disponibles: {str(e)}"
        }), 500



####PROCESOS
#
#
#

@app.route('/api/procesos/<int:id_sede_escuela>', methods=['GET'])
@cross_origin()
def get_procesos(id_sede_escuela):
    """
    Obtiene los procesos activos de inclusión y levantamiento para una sede/escuela específica
    """
    try:
        # Consulta para obtener procesos por tipo
        query = text("""
        WITH RankedProcesos AS (
            SELECT 
                p.*,
                ROW_NUMBER() OVER (PARTITION BY p."tipoProceso"[1] ORDER BY p.id_proceso DESC) as rn
            FROM 
                "Procesos" p
            WHERE 
                p."id_sedeXescuela" = :sede_escuela
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
        """)
        
        result = db.session.execute(query, {"sede_escuela": id_sede_escuela})
        
        # Convertir resultados a diccionario
        procesos = {}
        for row in result:
            procesos[row.tipo_proceso] = {
                "id": row.id_proceso,
                "tipo": row.tipo_proceso,
                "fechaInicio": row.fechaInicio.strftime('%d/%m/%Y') if row.fechaInicio else None,
                "fechaFinal": row.fechaFinal.strftime('%d/%m/%Y') if row.fechaFinal else None,
                "estado": row.estado,
                "id_sedeXescuela": row.id_sedeXescuela,
                "id_admin": row.id_admin
            }
        
        # Consulta para obtener historial de cambios
        historial_query = text("""
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
            p."id_sedeXescuela" = :sede_escuela
        ORDER BY 
            h.fecha_accion DESC
        LIMIT 10
        """)
        
        historial_result = db.session.execute(historial_query, {"sede_escuela": id_sede_escuela})
        
        historial = []
        for row in historial_result:
            historial.append({
                "id": row.id_historial,
                "fecha": row.fecha_accion.strftime('%d/%m/%Y %H:%M'),
                "usuario": row.nombre_usuario,
                "proceso": row.tipo_proceso,
                "accion": row.accion,
                "rol": row.rol_admin.lower()
            })
        
        return jsonify({
            "status": "success",
            "data": {
                "procesos": procesos,
                "historial": historial
            },
            "message": "Procesos obtenidos correctamente"
        }), 200
        
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": f"Error al obtener los procesos: {str(e)}"
        }), 500

@app.route('/api/procesos/<int:id_proceso>/toggle', methods=['PUT'])
@cross_origin()
def toggle_proceso(id_proceso):
    """
    Activa o desactiva un proceso
    """
    try:
        data = request.get_json()
        id_admin = data.get('id_admin')
        
        # Verificar si el proceso existe
        proceso_query = text("""
        SELECT 
            id_proceso,
            "tipoProceso"[1] as tipo_proceso,
            "id_sedeXescuela",
            estado
        FROM 
            "Procesos"
        WHERE 
            id_proceso = :id_proceso
        """)
        
        proceso_result = db.session.execute(proceso_query, {"id_proceso": id_proceso})
        proceso = proceso_result.fetchone()
        
        if not proceso:
            return jsonify({
                "status": "error",
                "message": "Proceso no encontrado"
            }), 404
        
        # Comprobar si hay otro proceso del mismo tipo activo para esa sede/escuela
        if not proceso.estado:  # Si estamos activando
            check_query = text("""
            SELECT COUNT(*) as count
            FROM "Procesos"
            WHERE 
                "id_sedeXescuela" = :sede_escuela AND
                "tipoProceso"[1] = :tipo_proceso AND
                estado = true AND
                id_proceso != :id_proceso
            """)
            
            check_result = db.session.execute(check_query, {
                "sede_escuela": proceso.id_sedeXescuela,
                "tipo_proceso": proceso.tipo_proceso,
                "id_proceso": id_proceso
            })
            
            if check_result.fetchone().count > 0:
                return jsonify({
                    "status": "error",
                    "message": f"Ya existe un proceso de {proceso.tipo_proceso} activo para esta sede/escuela"
                }), 400
        
        # Actualizar estado del proceso
        update_query = text("""
        UPDATE "Procesos"
        SET estado = NOT estado
        WHERE id_proceso = :id_proceso
        RETURNING estado
        """)
        
        update_result = db.session.execute(update_query, {"id_proceso": id_proceso})
        nuevo_estado = update_result.fetchone().estado
        
        # Registrar en historial
        accion = "Activación de proceso" if nuevo_estado else "Desactivación de proceso"
        historial_query = text("""
        INSERT INTO "HistorialProcesos" (fecha_accion, accion, id_proceso, id_admin)
        VALUES (NOW(), :accion, :id_proceso, :id_admin)
        """)
        
        db.session.execute(historial_query, {
            "accion": accion,
            "id_proceso": id_proceso,
            "id_admin": id_admin
        })
        
        db.session.commit()
        
        return jsonify({
            "status": "success",
            "data": {
                "estado": nuevo_estado
            },
            "message": f"Proceso {'activado' if nuevo_estado else 'desactivado'} correctamente"
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            "status": "error",
            "message": f"Error al modificar el estado del proceso: {str(e)}"
        }), 500

def format_date(iso_date):
    """Convierte una fecha ISO a formato legible"""
    try:
        date_obj = datetime.strptime(iso_date, '%Y-%m-%d')
        return date_obj.strftime('%d/%m/%Y')
    except:
        return iso_date

def send_email_notification(recipients, subject, message):
    """
    Envía correos electrónicos a múltiples destinatarios
    """
    # Cargar las credenciales desde variables de entorno
    smtp_server = os.getenv('SMTP_SERVER', 'smtp.gmail.com')
    smtp_port = int(os.getenv('SMTP_PORT', 587))
    smtp_user = os.getenv('SMTP_USER', 'tecmodfechas@gmail.com')  
    smtp_password = os.getenv('SMTP_PASSWORD', 'w s x q j a l p f r w l p w e n')  
    
    # Crear el remitente
    sender = f"Sistema TEC <{smtp_user}>"
    
    # Configurar servidor SMTP
    try:
        server = smtplib.SMTP(smtp_server, smtp_port)
        server.ehlo()
        server.starttls()
        server.login(smtp_user, smtp_password)
        
        # Para cada destinatario, enviar un correo personalizado
        success_count = 0
        error_count = 0
        
        # Limitar el número de destinatarios para evitar sobrecarga
        batch_size = 50
        recipient_batches = [recipients[i:i + batch_size] for i in range(0, len(recipients), batch_size)]
        
        for batch in recipient_batches:
            for recipient in batch:
                try:
                    print(f"Enviando correo a {recipient}...")
                    msg = MIMEMultipart()
                    msg['From'] = sender
                    msg['To'] = recipient
                    msg['Subject'] = subject
                    
                    # Agregar cuerpo del mensaje
                    msg.attach(MIMEText(message, 'html'))
                    
                    # Enviar correo
                    server.sendmail(sender, recipient, msg.as_string())
                    success_count += 1
                except Exception as e:
                    print(f"Error enviando correo a {recipient}: {str(e)}")
                    error_count += 1
        
        print(f"Correos enviados: {success_count}, Errores: {error_count}")
        server.quit()
        return True, success_count, error_count
    except Exception as e:
        print(f"Error en servidor SMTP: {str(e)}")
        return False, 0, 0


@app.route('/api/procesos/<int:id_proceso>/fechas', methods=['PUT'])
@cross_origin()
def actualizar_fechas_proceso(id_proceso):
    """
    Actualiza las fechas de inicio y fin de un proceso
    """
    try:
        data = request.get_json()
        fecha_inicio = data.get('fechaInicio')
        fecha_final = data.get('fechaFinal')
        id_admin = data.get('id_admin')
        notificar_estudiantes = data.get('notificarEstudiantes', False)
        
        # Validar fechas
        if not fecha_inicio or not fecha_final:
            return jsonify({
                "status": "error",
                "message": "Fechas de inicio y fin son requeridas"
            }), 400
            
        fecha_inicio_dt = datetime.strptime(fecha_inicio, '%Y-%m-%d')
        fecha_final_dt = datetime.strptime(fecha_final, '%Y-%m-%d')
        
        if fecha_inicio_dt > fecha_final_dt:
            return jsonify({
                "status": "error",
                "message": "La fecha de inicio no puede ser posterior a la fecha final"
            }), 400
        
        # Actualizar fechas en la base de datos
        update_query = text("""
        UPDATE "Procesos"
        SET 
            "fechaInicio" = :fecha_inicio,
            "fechaFinal" = :fecha_final
        WHERE 
            id_proceso = :id_proceso
        RETURNING "tipoProceso"[1] as tipo_proceso
        """)
        
        update_result = db.session.execute(update_query, {
            "fecha_inicio": fecha_inicio,
            "fecha_final": fecha_final,
            "id_proceso": id_proceso
        })
        
        proceso_result = update_result.fetchone()
        
        if not proceso_result:
            return jsonify({
                "status": "error",
                "message": "Proceso no encontrado"
            }), 404
            
        tipo_proceso = proceso_result.tipo_proceso
        
        # Si se marcó la opción de notificar
        if notificar_estudiantes:
            # Obtener información del proceso, escuela y sede
            sede_escuela_query = text("""
            SELECT 
                p."tipoProceso"[1] as tipo_proceso,
                s.nombre[1] as nombre_sede,
                e.nombre[1] as nombre_escuela,
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
                p.id_proceso = :id_proceso
            """)
            
            sede_info = db.session.execute(sede_escuela_query, {"id_proceso": id_proceso}).fetchone()
            
            if sede_info:
                # Obtener todos los correos de estudiantes
                estudiantes_query = text("""
                SELECT e.correo[1] as correo 
                FROM "Persona" e
                WHERE correo[1] LIKE '%@estudiantec.cr' 
                """)
                
                estudiantes_result = db.session.execute(estudiantes_query)
                
                # Extraer correos a una lista
                correos = [row.correo for row in estudiantes_result if row.correo]
                
                if correos:
                    # Preparar contenido del correo
                    fecha_inicio_formateada = format_date(fecha_inicio)
                    fecha_final_formateada = format_date(fecha_final)
                    
                    subject = f"Actualización de fechas: Proceso de {tipo_proceso}"
                    
                    # Crear mensaje HTML más atractivo
                    message = f"""
                    <html>
                    <head>
                        <style>
                            body {{ font-family: Arial, sans-serif; line-height: 1.6; }}
                            .container {{ padding: 20px; border: 1px solid #ddd; border-radius: 5px; }}
                            .header {{ background-color: #005085; color: white; padding: 10px; text-align: center; }}
                            .content {{ padding: 15px; }}
                            .footer {{ font-size: 12px; text-align: center; margin-top: 20px; color: #777; }}
                            .highlight {{ background-color: #f0f7ff; padding: 10px; border-left: 3px solid #005085; }}
                        </style>
                    </head>
                    <body>
                        <div class="container">
                            <div class="header">
                                <h2>Actualización de Fechas en Proceso</h2>
                            </div>
                            <div class="content">
                                <p>Estimado(a) estudiante:</p>
                                
                                <p>Le informamos que la <strong>{sede_info.nombre_escuela}</strong> de la sede <strong>{sede_info.nombre_sede}</strong> 
                                ha modificado las fechas del proceso de <strong>{tipo_proceso}</strong>.</p>
                                
                                <div class="highlight">
                                    <p><strong>Nuevas fechas:</strong></p>
                                    <p>Fecha de inicio: {fecha_inicio_formateada}</p>
                                    <p>Fecha de finalización: {fecha_final_formateada}</p>
                                </div>
                                
                                <p>Por favor, tome en cuenta estas nuevas fechas para realizar sus trámites correspondientes.</p>
                                
                                <p>Atentamente,<br>
                                {sede_info.nombre_admin}<br>
                                Administrador del Sistema</p>
                            </div>
                            <div class="footer">
                                <p>Este es un mensaje automático, por favor no responda a este correo.</p>
                                <p>© {datetime.now().year} Instituto Tecnológico de Costa Rica</p>
                            </div>
                        </div>
                    </body>
                    </html>
                    """
                    
                    # Enviar correos
                    success, sent_count, error_count = send_email_notification(correos, subject, message)
                    
                    # Registrar en historial con detalles del envío
                    accion_texto = f"Modificación de fechas con notificación a estudiantes (correos {sent_count} enviados, {error_count} fallidos)"
                else:
                    # No se encontraron correos de estudiantes
                    accion_texto = "Modificación de fechas (no se encontraron correos para notificar)"
            else:
                # No se pudo obtener información de sede/escuela
                accion_texto = "Modificación de fechas (error al obtener información de sede/escuela)"
        else:
            # Simplemente modificación de fechas sin notificación
            accion_texto = "Modificación de fechas"
        
        # Registrar en historial
        historial_query = text("""
        INSERT INTO "HistorialProcesos" (fecha_accion, accion, id_proceso, id_admin)
        VALUES (NOW(), :accion, :id_proceso, :id_admin)
        """)
        
        db.session.execute(historial_query, {
            "accion": accion_texto,
            "id_proceso": id_proceso,
            "id_admin": id_admin
        })
        
        db.session.commit()
        return jsonify({
            "status": "success", 
            "message": "Fechas actualizadas correctamente" + 
                (" y notificaciones enviadas a los estudiantes" if notificar_estudiantes else "")
        })
        
    except Exception as e:
        db.session.rollback()
        import traceback
        print(traceback.format_exc())
        return jsonify({
            "status": "error", 
            "message": f"Error al actualizar fechas: {str(e)}"
        }), 500



# Ejecutar la aplicación
if __name__ == '__main__':
    app.run(debug=True)