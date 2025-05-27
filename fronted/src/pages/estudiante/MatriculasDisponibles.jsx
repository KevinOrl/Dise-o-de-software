import React, { useState, useEffect } from 'react';
import axios from 'axios';

const MatriculasDisponibles = ({ idEstudiante }) => {
  const [tipoSeleccionado, setTipoSeleccionado] = useState('Semestre');
  const [cursos, setCursos] = useState([]);
  const [loading, setLoading] = useState(false);

  const fetchCursos = async (tipo) => {
    setLoading(true);
    try {
      // Aquí se debería llamar a tu endpoint real según el tipo
      const tipoMap = {
        'Semestre': 'semestre',
        'Inclusiones': 'inclusion',
        'Levantamientos': 'levantamiento'
      };
      const tipoApi = tipoMap[tipo] || 'semestre';
      const response = await axios.get(`http://localhost:5000/api/matriculas/${tipoApi}`);
      setCursos(response.data.data || []);
    } catch (error) {
      console.error('Error al cargar cursos:', error);
      setCursos([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCursos(tipoSeleccionado);
  }, [tipoSeleccionado]);

  return (
    <div className="w-full max-w-6xl mx-auto mt-12">
      <h2 className="text-lg font-semibold text-center bg-[#003366] text-white py-2 rounded-t">
        Matrículas Disponibles
      </h2>

      <div className="flex justify-center my-4 space-x-4">
        {['Semestre', 'Inclusiones', 'Levantamientos'].map((tipo) => (
          <button
            key={tipo}
            onClick={() => setTipoSeleccionado(tipo)}
            className={`px-4 py-2 rounded ${tipoSeleccionado === tipo ? 'bg-blue-600 text-white' : 'bg-gray-200'}`}
          >
            {tipo}
          </button>
        ))}
      </div>

      <table className="w-full border border-gray-300 text-sm bg-white shadow">
        <thead className="bg-gray-100 text-left">
          <tr>
            <th className="px-4 py-2">Código</th>
            <th className="px-4 py-2">Nombre</th>
            <th className="px-4 py-2">Créditos</th>
            <th className="px-4 py-2">Grupo</th>
            <th className="px-4 py-2">Acción</th>
          </tr>
        </thead>
        <tbody>
          {loading ? (
            <tr><td colSpan="5" className="text-center py-4">Cargando...</td></tr>
          ) : cursos.length > 0 ? (
            cursos.map((curso, index) => (
              <tr key={index} className="border-t">
                <td className="px-4 py-2">{curso.codigo}</td>
                <td className="px-4 py-2">{curso.nombre}</td>
                <td className="px-4 py-2">{curso.creditos}</td>
                <td className="px-4 py-2">{curso.grupo}</td>
                <td className="px-4 py-2">
                  <button className="text-sm text-white bg-blue-600 px-2 py-1 rounded hover:bg-blue-700">
                    Ver formulario
                  </button>
                </td>
              </tr>
            ))
          ) : (
            <tr><td colSpan="5" className="text-center py-4">No hay cursos disponibles</td></tr>
          )}
        </tbody>
      </table>
    </div>
  );
};

export default MatriculasDisponibles;
