from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
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

# Ejecutar la aplicación
if __name__ == '__main__':
    app.run(debug=True)