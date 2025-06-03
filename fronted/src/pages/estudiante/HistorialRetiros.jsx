import React, { useEffect, useState } from 'react';
import axios from 'axios';

const HistorialRetiros = ({ idEstudiante }) => {
  const [retiros, setRetiros] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchRetiros = async () => {
      try {
        const res = await axios.get(`http://localhost:5000/api/historial-retiros/${idEstudiante}`);
        if (res.data.status === 'success') {
          setRetiros(res.data.data);
        }
      } catch (err) {
        console.error('Error al cargar retiros:', err);
      } finally {
        setLoading(false);
      }
    };

    fetchRetiros();
  }, [idEstudiante]);

  return (
    <div className="w-full max-w-5xl mx-auto mt-12">
      <div className="flex justify-end mb-2">
        <button
          onClick={() => window.location.href = '/estudiante'}
          className="text-sm text-red-600 hover:underline"
        >
          Volver al inicio
        </button>
      </div>

      <h2 className="text-lg font-semibold text-center bg-[#003366] text-white py-2 rounded-t">
        Historial Retiros
      </h2>
      
      <table className="w-full border border-gray-300 text-sm bg-white shadow">
        <thead className="bg-gray-100 text-left">
          <tr>
            <th className="px-4 py-2">Código del curso</th>
            <th className="px-4 py-2">Fecha de retiro</th>
            <th className="px-4 py-2">Semestre</th>
            <th className="px-4 py-2">Año</th>
            <th className="px-4 py-2">ID Retiro</th>
          </tr>
        </thead>
        <tbody>
          {loading ? (
            <tr><td colSpan="5" className="text-center py-4">Cargando...</td></tr>
          ) : retiros.length > 0 ? (
            retiros.map((ret, index) => (
              <tr key={index} className="border-t">
                <td className="px-4 py-2">{ret.codigo_curso}</td>
                <td className="px-4 py-2">{new Date(ret.fechaRetiro).toLocaleDateString('es-CR')}</td>
                <td className="px-4 py-2">{ret.semestre}</td>
                <td className="px-4 py-2">{ret.anio}</td>
                <td className="px-4 py-2">{ret.id_retiro}</td>
              </tr>
            ))
          ) : (
            <tr><td colSpan="5" className="text-center py-4">No hay registros</td></tr>
          )}
        </tbody>
      </table>
    </div>
  );
};

export default HistorialRetiros;
