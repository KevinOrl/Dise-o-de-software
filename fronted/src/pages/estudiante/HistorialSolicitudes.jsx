import React, { useEffect, useState } from 'react';
import axios from 'axios';

const HistorialSolicitudes = ({ idEstudiante }) => {
  const [solicitudes, setSolicitudes] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchSolicitudes = async () => {
      try {
        const res = await axios.get(`http://localhost:5000/api/historial-solicitudes/${idEstudiante}`);
        if (res.data.status === 'success') {
          setSolicitudes(res.data.data);
        }
      } catch (err) {
        console.error('Error al cargar solicitudes:', err);
      } finally {
        setLoading(false);
      }
    };

    fetchSolicitudes();
  }, [idEstudiante]);

  return (
    <div className="w-full max-w-5xl mx-auto mt-12">
      <h2 className="text-lg font-semibold text-center bg-[#003366] text-white py-2 rounded-t">Historial Solicitudes</h2>
      <table className="w-full border border-gray-300 text-sm bg-white shadow">
        <thead className="bg-gray-100 text-left">
          <tr>
            <th className="px-4 py-2">Código del curso</th>
            <th className="px-4 py-2">Fecha de retiro</th>
            <th className="px-4 py-2">Semestre</th>
            <th className="px-4 py-2">Año</th>
            <th className="px-4 py-2">ID Solicitud</th>
          </tr>
        </thead>
        <tbody>
          {loading ? (
            <tr><td colSpan="5" className="text-center py-4">Cargando...</td></tr>
          ) : solicitudes.length > 0 ? (
            solicitudes.map((sol, index) => (
              <tr key={index} className="border-t">
                <td className="px-4 py-2">{sol.codigo_curso}</td>
                <td className="px-4 py-2">{new Date(sol.fechaRetiro).toLocaleDateString('es-CR')}</td>
                <td className="px-4 py-2">{sol.semestre}</td>
                <td className="px-4 py-2">{sol.anio}</td>
                <td className="px-4 py-2">{sol.id_solicitud}</td>
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

export default HistorialSolicitudes;
