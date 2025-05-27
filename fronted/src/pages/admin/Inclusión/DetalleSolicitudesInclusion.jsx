import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import NavBar from '../NavBar';
import './DetalleSolicitudesInclusion.css';
import logoTec from '../../../assets/images/logo-tec-white.png';
import axios from 'axios';

const DetalleSolicitudesInclusion = () => {
  const { codigo, grupo } = useParams();
  const navigate = useNavigate();

  // Estados para manejar los datos y la UI
  const [solicitudes, setSolicitudes] = useState([]);
  const [cursoInfo, setCursoInfo] = useState({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [currentPage, setCurrentPage] = useState(1);
  const [filtroEstado, setFiltroEstado] = useState('Todos');
  const [busqueda, setBusqueda] = useState('');

  const ITEMS_PER_PAGE = 5;
  const API_URL = 'http://localhost:5000';

  // Cargar datos desde la API
  useEffect(() => {
    const fetchSolicitudesDetalle = async () => {
      try {
        setLoading(true);
        const response = await axios.get(`${API_URL}/api/solicitudes/inclusion/${codigo}/${grupo}`);
        
        if (response.data.status === 'success') {
          setSolicitudes(response.data.data.solicitudes);
          setCursoInfo(response.data.data.curso);
        } else {
          setError('Error al cargar los datos: ' + response.data.message);
        }
      } catch (err) {
        setError('Error de conexión con el servidor: ' + (err.message || 'Error desconocido'));
        console.error('Error al cargar solicitudes detalladas:', err);
      } finally {
        setLoading(false);
      }
    };

    fetchSolicitudesDetalle();
  }, [codigo, grupo]);

  // Función para filtrar las solicitudes
  const filtrarSolicitudes = () => {
    let solicitudesFiltradas = [...solicitudes];
    
    // Filtrar por estado
    if (filtroEstado !== 'Todos') {
      solicitudesFiltradas = solicitudesFiltradas.filter(s => s.prioridad === filtroEstado);
    }
    
    // Filtrar por búsqueda (carnet o nombre)
    if (busqueda.trim()) {
      const busquedaLower = busqueda.toLowerCase();
      solicitudesFiltradas = solicitudesFiltradas.filter(s => 
        s.carnet.toString().includes(busqueda) || 
        s.nombre.toLowerCase().includes(busquedaLower)
      );
    }
    
    return solicitudesFiltradas;
  };

  const solicitudesFiltradas = filtrarSolicitudes();
  const totalPages = Math.ceil(solicitudesFiltradas.length / ITEMS_PER_PAGE);

  // Funciones de control
  const handlePageChange = (pageNumber) => {
    setCurrentPage(pageNumber);
  };

  const handleFiltroChange = (e) => {
    setFiltroEstado(e.target.value);
    setCurrentPage(1);
  };

  const handleBusquedaChange = (e) => {
    setBusqueda(e.target.value);
    setCurrentPage(1);
  };

  const getPrioridadClass = (prioridad) => {
    switch (prioridad) {
      case 'Alta': return 'prioridad-alta';
      case 'Media': return 'prioridad-media';
      case 'Baja': return 'prioridad-baja';
      default: return '';
    }
  };

  return (
    <div className="dashboard-container">
      <NavBar />
      
      <div className="dashboard-content">
        <div className="breadcrumb-container">
          <button 
            className="volver-btn" 
            onClick={() => navigate('/admin/solicitudes-inclusiones')}
            aria-label="Volver al listado"
          >
            <span className="volver-icono">&lt;</span> Volver al listado
          </button>
        </div>
        
        <div className="curso-header">
          <h1>{cursoInfo.codigo} - {cursoInfo.nombre}</h1>
          <div className="curso-info">
            <span>Grupo: {cursoInfo.grupo}</span>
            <span>Créditos: {cursoInfo.creditos}</span>
            <span>Total solicitudes: {solicitudes.length}</span>
          </div>
        </div>
        
        <div className="content-area">
          <h2>Listado de solicitudes pendientes</h2>
          
          <div className="filtros-container">
            <div className="filtro-estado">
              <label htmlFor="filtro-estado">Estado: </label>
              <select 
                id="filtro-estado" 
                value={filtroEstado} 
                onChange={handleFiltroChange}
                aria-label="Filtrar por estado"
              >
                <option value="Todos">Todos</option>
                <option value="Alta">Alta</option>
                <option value="Media">Media</option>
                <option value="Baja">Baja</option>
              </select>
            </div>
            
            <div className="buscar-container">
              <input 
                type="text" 
                placeholder="Buscar carnet o nombre..." 
                value={busqueda}
                onChange={handleBusquedaChange}
                aria-label="Buscar por carnet o nombre"
              />
              <button className="buscar-btn">Buscar</button>
            </div>
          </div>

          {loading ? (
            <div className="loading-indicator" role="status" aria-live="polite">
              <span>Cargando datos...</span>
            </div>
          ) : error ? (
            <div className="error-message" role="alert">
              {error}
            </div>
          ) : (
            <>
              <div className="table-container">
                <table className="solicitudes-detalle-table" aria-label="Tabla de solicitudes pendientes">
                  <thead>
                    <tr>
                      <th scope="col" id="col-id">ID</th>
                      <th scope="col" id="col-carnet">Carnet</th>
                      <th scope="col" id="col-nombre">Nombre del Estudiante</th>
                      <th scope="col" id="col-fecha">Fecha de Solicitud</th>
                      <th scope="col" id="col-prioridad">Prioridad</th>
                      <th scope="col" id="col-estado">Estado</th>
                      <th scope="col" id="col-acciones">Acciones</th>
                    </tr>
                  </thead>
                  <tbody>
                    {solicitudesFiltradas.length === 0 ? (
                      <tr>
                        <td colSpan="7" className="no-data-message">No hay solicitudes que coincidan con los criterios</td>
                      </tr>
                    ) : (
                      solicitudesFiltradas
                        .slice((currentPage - 1) * ITEMS_PER_PAGE, currentPage * ITEMS_PER_PAGE)
                        .map((solicitud) => (
                          <tr key={solicitud.id}>
                            <td headers="col-id">{String(solicitud.id).padStart(3, '0')}</td>
                            <td headers="col-carnet">{solicitud.carnet}</td>
                            <td headers="col-nombre">{solicitud.nombre}</td>
                            <td headers="col-fecha">{solicitud.fecha}</td>
                            <td headers="col-prioridad">
                              <span className={`badge ${getPrioridadClass(solicitud.prioridad)}`}>
                                {solicitud.prioridad}
                              </span>
                            </td>
                            <td headers="col-estado">
                              <span className="badge pendiente">
                                {solicitud.estado}
                              </span>
                            </td>
                            <td headers="col-acciones">
                              <button 
                                className="ver-detalle-btn"
                                onClick={() => navigate(`/admin/solicitudes-inclusion/${codigo}/${grupo}/${solicitud.id}`)}
                                aria-label={`Ver detalle de solicitud de ${solicitud.nombre}`}
                              >
                                Ver detalle
                              </button>
                            </td>
                          </tr>
                        ))
                    )}
                  </tbody>
                </table>
              </div>
              
              {/* Paginación */}
              {totalPages > 0 && (
                <div className="pagination" role="navigation" aria-label="Paginación de resultados">
                  <button 
                    className={`pagination-btn prev ${currentPage === 1 ? 'disabled' : ''}`}
                    onClick={() => handlePageChange(currentPage - 1)}
                    disabled={currentPage === 1}
                    aria-label="Página anterior"
                  >
                    &lt;
                  </button>
                  
                  {Array.from({ length: totalPages }, (_, index) => (
                    <button 
                      key={index + 1}
                      className={`pagination-btn ${currentPage === index + 1 ? 'active' : ''}`}
                      onClick={() => handlePageChange(index + 1)}
                      aria-label={`Ir a página ${index + 1}`}
                      aria-current={currentPage === index + 1 ? "page" : undefined}
                    >
                      {index + 1}
                    </button>
                  ))}
                  
                  <button 
                    className={`pagination-btn next ${currentPage === totalPages ? 'disabled' : ''}`}
                    onClick={() => handlePageChange(currentPage + 1)}
                    disabled={currentPage === totalPages}
                    aria-label="Página siguiente"
                  >
                    &gt;
                  </button>
                </div>
              )}
            </>
          )}
        </div>
      </div>
      
      <footer className="dashboard-footer">
        <div className="footer-content">
          <span className="footer-contact">Contactos Admisión y Registro</span>
          <img src={logoTec} alt="TEC Logo" className="footer-logo" />
        </div>
      </footer>
    </div>
  );
};

export default DetalleSolicitudesInclusion;