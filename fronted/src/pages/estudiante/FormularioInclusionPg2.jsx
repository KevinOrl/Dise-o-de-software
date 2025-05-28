import React, { useState } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';

const FormularioInclusionPg2 = ({ formData, onBack }) => {
  const [datos, setDatos] = useState({
    cursos_logrados: '',
    intentos: '',
    estado_rn: '',
    detalle_rn: '',
    correquisitos_aprobados: '',
    motivo: ''
  });

  const navigate = useNavigate();

  const handleChange = (e) => {
    const { name, value } = e.target;
    setDatos(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async () => {
    try {
      const estudiante = JSON.parse(localStorage.getItem('userData'));
      if (!estudiante?.id) {
        alert('No se pudo obtener el ID del estudiante.');
        return;
      }

      const payload = {
        id_estudiante: estudiante.id,
        id_grupo: formData.grupo,
        codigo_curso: formData.curso,
        motivo: datos.motivo,
      };

      const response = await axios.post('http://localhost:5000/api/solicitudes/inclusion', payload);

      if (response.data.status === 'success') {
        alert('Solicitud enviada exitosamente');
        navigate('/estudiante');
      } else {
        alert('Error al enviar solicitud');
      }
    } catch (err) {
      console.error(err);
      alert('Error al conectar con el servidor');
    }
  };

  return (
    <div className="max-w-6xl mx-auto p-6 bg-gray-100 rounded">
      <h2 className="text-xl font-semibold text-[#00548f] mb-6">Formulario de Inclusión</h2>

      <div className="grid grid-cols-2 gap-6">
        <div>
          <label className="block mb-1">¿Cuáles cursos logró matricular?</label>
          <input name="cursos_logrados" value={datos.cursos_logrados} onChange={handleChange} className="w-full border p-2 rounded" />
        </div>

        <div>
          <label className="block mb-1">¿Cuántas veces ha intentado matricular el curso?</label>
          <input name="intentos" value={datos.intentos} onChange={handleChange} className="w-full border p-2 rounded" />
        </div>

        <div>
          <label className="block mb-1">¿Presenta estado RN en el curso?</label>
          <select name="estado_rn" value={datos.estado_rn} onChange={handleChange} className="w-full border p-2 rounded">
            <option value="">Seleccione una opción</option>
            <option value="si">Sí</option>
            <option value="no">No</option>
          </select>
        </div>

        <div>
          <label className="block mb-1">Si marcó sí, indique el estado RN que presenta</label>
          <input name="detalle_rn" value={datos.detalle_rn} onChange={handleChange} className="w-full border p-2 rounded" />
        </div>

        <div>
          <label className="block mb-1">¿Ha aprobado los correquisitos del Curso?</label>
          <select name="correquisitos_aprobados" value={datos.correquisitos_aprobados} onChange={handleChange} className="w-full border p-2 rounded">
            <option value="">Seleccione una opción</option>
            <option value="si">Sí</option>
            <option value="no">No</option>
          </select>
        </div>

        <div className="col-span-2">
          <label className="block mb-1">Explique brevemente su razón de la solicitud</label>
          <textarea name="motivo" value={datos.motivo} onChange={handleChange} className="w-full border p-2 rounded h-24" />
        </div>
      </div>

      <div className="mt-6 flex justify-between">
        <button onClick={onBack} className="bg-gray-500 text-white px-4 py-2 rounded hover:bg-gray-600">
          ← Regresar
        </button>
        <button onClick={handleSubmit} className="bg-green-600 text-white px-6 py-2 rounded hover:bg-green-700">
          Finalizar solicitud
        </button>
      </div>
    </div>
  );
};

export default FormularioInclusionPg2;
