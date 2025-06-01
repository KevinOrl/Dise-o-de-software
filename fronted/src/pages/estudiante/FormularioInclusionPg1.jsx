import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';

const FormularioInclusionPg1 = ({ onNext, formData, setFormData, onExit }) => {
  const [sedes, setSedes] = useState([]);
  const [carreras, setCarreras] = useState([]);
  const navigate = useNavigate();

  useEffect(() => {
    const user = JSON.parse(localStorage.getItem('userData'));
    if (user) {
      setFormData(prev => ({
        ...prev,
        nombre: user.nombre || '',
        correo: user.email || '',
        carnet: user.carnet || '',
        id_carrera: user.id_carrera || '',
        id_sede: user.id_sede || ''
      }));
    }

    axios.get('http://localhost:5000/api/sedes')
      .then(res => setSedes(res.data.sedes || []))
      .catch(err => console.error('Error al obtener sedes', err));

    axios.get('http://localhost:5000/api/carreras')
      .then(res => setCarreras(res.data.carreras || []))
      .catch(err => console.error('Error al obtener carreras', err));
  }, [setFormData]);

  const handleChange = e => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  return (
  <div className="p-6 bg-gray-100 rounded-md max-w-6xl mx-auto">
      <div className="flex justify-between mb-4">
        <span className="text-sm text-gray-500">Página 1 de 2</span>
        <button 
          onClick={() => window.location.href = '/estudiante'} 
          className="text-sm text-red-600 hover:underline"
        >
          Salir del formulario
        </button>
      </div>

      <h2 className="text-xl font-semibold text-[#00548f] mb-4">Formulario de Inclusión</h2>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <input type="text" name="nombre" value={formData.nombre || ''} onChange={handleChange} placeholder="Nombre del Estudiante" className="input" />
        <input type="text" name="carnet" value={formData.carnet || ''} onChange={handleChange} placeholder="Carnet" className="input" />
        <input type="email" name="correo" value={formData.correo || ''} onChange={handleChange} placeholder="Correo estudiantec" className="input" />
        <input type="number" name="cursos_faltantes" value={formData.cursos_faltantes || ''} onChange={handleChange} placeholder="¿Cuántos cursos le faltan?" className="input" />

        <select name="id_carrera" value={formData.id_carrera || ''} onChange={handleChange} className="input">
          <option value="">Seleccione su Carrera</option>
          {carreras.map(c => <option key={c.id_carrera} value={c.id_carrera}>{c.nombre}</option>)}
        </select>

        <select name="id_sede" value={formData.id_sede || ''} onChange={handleChange} className="input">
          <option value="">Seleccione una Sede</option>
          {sedes.map(s => <option key={s.id_sede} value={s.id_sede}>{s.nombre}</option>)}
        </select>

        <input type="file" name="documento_aprobacion" className="input" />
        <select name="choque_horario" value={formData.choque_horario || ''} onChange={handleChange} className="input">
          <option value="">¿Presenta choque de horario?</option>
          <option value="si">Sí</option>
          <option value="no">No</option>
        </select>
      </div>

      <div className="mt-6 flex justify-end">
        <button onClick={onNext} className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
          Siguiente Página
        </button>
      </div>
    </div>
  );
};

export default FormularioInclusionPg1;
