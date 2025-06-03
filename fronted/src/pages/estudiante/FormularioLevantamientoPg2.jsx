import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';

const FormularioLevantamientoPg2 = ({ formData, onBack }) => {
  const [datos, setDatos] = useState({
    creditos_matricular: '',
    intentos: '',
    estado_rn: '',
    detalle_rn: '',
    motivo: ''
  });

  const navigate = useNavigate();

  // Efecto para limpiar el detalle_rn cuando se cambia el estado_rn a "no"
  useEffect(() => {
    if (datos.estado_rn === 'no') {
      setDatos(prev => ({ ...prev, detalle_rn: '' }));
    }
  }, [datos.estado_rn]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setDatos((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async () => {
    try {
        const estudiante = JSON.parse(localStorage.getItem('userData'));
        if (!estudiante?.id) {
        alert('No se pudo obtener el ID del estudiante.');
        return;
        }

        if (!formData.curso || !formData.grupo) {
        alert('Faltan datos del curso o grupo.');
        return;
        }

        const payload = {
        id_estudiante: estudiante.id,
        id_grupo: formData.grupo,
        codigo_curso: formData.curso,
        motivo: datos.motivo
        };

        const response = await axios.post('http://localhost:5000/api/solicitudes/levantamiento', payload);

        if (response.data.status === 'success') {
        alert('Solicitud enviada exitosamente');
        window.location.href = '/estudiante';
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
      <div className="flex justify-between mb-4">
        <p className="text-sm text-gray-500">Página 2 de 2</p>
        <button
          onClick={() => window.location.href = '/estudiante'} 
          className="text-sm text-red-600 hover:underline"
        >
          Salir del formulario
        </button>
      </div>

      <h2 className="text-xl font-semibold text-[#00548f] mb-4">Formulario de Levantamiento</h2>

      <div className="grid grid-cols-2 gap-6">
        <div>
          <label className="block mb-1">¿Cuántos créditos espera matricular?</label>
          <input name="creditos_matricular" placeholder="Coloque un número" value={datos.creditos_matricular} onChange={handleChange} className="w-full border p-2 rounded" />
        </div>

        <div>
          <label className="block mb-1">¿Cuántas veces ha intentado matricular el curso?</label>
          <input name="intentos" placeholder="Coloque el número de veces" value={datos.intentos} onChange={handleChange} className="w-full border p-2 rounded" />
        </div>

        <div>
          <label className="block mb-1">¿Presenta estado RN en el curso?</label>
          <select 
            name="estado_rn" 
            value={datos.estado_rn} 
            onChange={handleChange} 
            className="w-full border p-2 rounded"
            aria-controls="detalle-rn-container"
          >
            <option value="">Seleccione una opción</option>
            <option value="si">Sí</option>
            <option value="no">No</option>
          </select>
        </div>

        {/* Mostrar el campo detalle_rn solo si estado_rn es "si" */}
        {datos.estado_rn === 'si' && (
          <div id="detalle-rn-container">
            <label className="block mb-1">Indique el estado RN que presenta</label>
            <input 
              name="detalle_rn" 
              placeholder="Coloque un número" 
              value={datos.detalle_rn} 
              onChange={handleChange} 
              className="w-full border p-2 rounded" 
            />
          </div>
        )}

        <div className="col-span-2">
          <label className="block mb-1">Explique brevemente su razón de la solicitud</label>
          <textarea 
            name="motivo" 
            placeholder="Razon personal por la cual desea el levantamiento" 
            value={datos.motivo} 
            onChange={handleChange} 
            className="w-full border p-2 rounded h-24" 
          />
        </div>
      </div>

      <div className="mt-6 flex justify-between">
        <button
          onClick={onBack}
          className="bg-gray-500 text-white px-4 py-2 rounded hover:bg-gray-600"
        >
          ← Regresar
        </button>
        <button
          onClick={handleSubmit}
          className="bg-green-600 text-white px-6 py-2 rounded hover:bg-green-700"
        >
          Finalizar solicitud
        </button>
      </div>
    </div>
  );
};

export default FormularioLevantamientoPg2;
