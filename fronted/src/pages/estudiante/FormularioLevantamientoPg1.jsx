import React, { useEffect, useState } from 'react';
import axios from 'axios';

const FormularioLevantamientoPg1 = ({ onNext, formData, setFormData }) => {
  const [carreras, setCarreras] = useState([]);
  const [sedes, setSedes] = useState([]);

  useEffect(() => {
    axios.get('http://localhost:5000/api/carreras')
      .then(res => setCarreras(res.data.carreras || []))
      .catch(err => console.error('Error al obtener carreras:', err));

    axios.get('http://localhost:5000/api/sedes')
      .then(res => setSedes(res.data.sedes || []))
      .catch(err => console.error('Error al obtener sedes:', err));
  }, []);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  return (
    <div className="p-6 bg-gray-100 rounded-md max-w-6xl mx-auto">
      <h2 className="text-xl font-bold mb-4 text-[#00548f]">Formulario de Levantamiento</h2>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <input name="nombre" value={formData.nombre || ''} onChange={handleChange} placeholder="Nombre del Estudiante" className="input" />
        <input name="carnet" value={formData.carnet || ''} onChange={handleChange} placeholder="Ingrese el carnet" className="input" />
        <input name="correo" value={formData.correo || ''} onChange={handleChange} placeholder="Ingrese el correo estudiantec" className="input" />
        <input name="cursos_faltantes" value={formData.cursos_faltantes || ''} onChange={handleChange} placeholder="¿Cuantos cursos le faltan del plan de estudio?" className="input" />

        <select name="id_carrera" value={formData.id_carrera || ''} onChange={handleChange} className="input">
          <option value="">Seleccione su Carrera</option>
          {carreras.map(c => <option key={c.id_carrera} value={c.id_carrera}>{c.nombre}</option>)}
        </select>

        <select name="id_sede" value={formData.id_sede || ''} onChange={handleChange} className="input">
          <option value="">Seleccione una sede</option>
          {sedes.map(s => <option key={s.id_sede} value={s.id_sede}>{s.nombre}</option>)}
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

export default FormularioLevantamientoPg1;
