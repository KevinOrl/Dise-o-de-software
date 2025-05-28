import React, { useState, useEffect } from 'react';
import { format, parse } from 'date-fns';
import NavBar from '../NavBar';
import './HabilitarProcesos.css';
import logoTec from '../../../assets/images/logo-tec-white.png';
import axios from 'axios';

const HabilitarProcesos = () => {
  const [procesos, setProcesos] = useState({
    Inclusion: null,
    Levantamiento: null
  });
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage] = useState(5);
  const [historial, setHistorial] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [modalVisible, setModalVisible] = useState(false);
  const [procesoActual, setProcesoActual] = useState(null);
  const [nuevasFechas, setNuevasFechas] = useState({
    fechaInicio: '',
    fechaFinal: '',
    notificarEstudiantes: false // Nueva propiedad para el checkbox
  });

  // Obtener datos del usuario
  const userData = JSON.parse(localStorage.getItem('userData') || '{}');
  const API_URL = 'http://localhost:5000';

  useEffect(() => {
    const fetchProcesos = async () => {
      try {
        setLoading(true);
        if (!userData.id_sedeXescuela) {
          setError('No se pudo determinar la sede/escuela del usuario');
          setLoading(false);
          return;
        }
        
        const response = await axios.get(`${API_URL}/api/procesos/${userData.id_sedeXescuela}`);
        
        if (response.data.status === 'success') {
          setProcesos(response.data.data.procesos);
          setHistorial(response.data.data.historial);
        } else {
          setError('Error al cargar los datos: ' + response.data.message);
        }
      } catch (err) {
        setError('Error de conexión con el servidor: ' + (err.message || 'Error desconocido'));
        console.error('Error al cargar procesos:', err);
      } finally {
        setLoading(false);
      }
    };

    fetchProcesos();
  }, [userData.id_sedeXescuela]);

  const handleToggleEstado = async (proceso) => {
    try {
      const response = await axios.put(`${API_URL}/api/procesos/${proceso.id}/toggle`, {
        id_admin: userData.id
      });
      
      if (response.data.status === 'success') {
        // Actualizar el estado local
        setProcesos(prevProcesos => ({
          ...prevProcesos,
          [proceso.tipo]: {
            ...proceso,
            estado: response.data.data.estado
          }
        }));
        
        // Recargar el historial
        const historialResponse = await axios.get(`${API_URL}/api/procesos/${userData.id_sedeXescuela}`);
        if (historialResponse.data.status === 'success') {
          setHistorial(historialResponse.data.data.historial);
        }
      } else {
        alert(response.data.message);
      }
    } catch (err) {
      alert('Error al cambiar estado: ' + (err.response?.data?.message || err.message));
    }
  };

  const openFechasModal = (proceso) => {
    setProcesoActual(proceso);
    
    // Convertir formato de fecha DD/MM/YYYY a YYYY-MM-DD para inputs date
    const fechaInicio = proceso.fechaInicio ? 
      format(parse(proceso.fechaInicio, 'dd/MM/yyyy', new Date()), 'yyyy-MM-dd') : '';
    const fechaFinal = proceso.fechaFinal ? 
      format(parse(proceso.fechaFinal, 'dd/MM/yyyy', new Date()), 'yyyy-MM-dd') : '';
      
    setNuevasFechas({
      fechaInicio,
      fechaFinal,
      notificarEstudiantes: false // Iniciar siempre con la opción desmarcada
    });
    
    setModalVisible(true);
  };

  const handleFechaChange = (e) => {
    const { name, value, type, checked } = e.target;
    setNuevasFechas(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));
  };

  const handleCheckboxChange = (e) => {
    const { checked } = e.target;
    setNuevasFechas(prev => ({
      ...prev,
      notificarEstudiantes: checked
    }));
  };

  const handleSubmitFechas = async (e) => {
    e.preventDefault();
    
    if (!nuevasFechas.fechaInicio || !nuevasFechas.fechaFinal) {
      alert('Por favor, complete ambas fechas');
      return;
    }
    
    if (new Date(nuevasFechas.fechaInicio) > new Date(nuevasFechas.fechaFinal)) {
      alert('La fecha de inicio no puede ser posterior a la fecha final');
      return;
    }
    
    try {
      const response = await axios.put(`${API_URL}/api/procesos/${procesoActual.id}/fechas`, {
        fechaInicio: nuevasFechas.fechaInicio,
        fechaFinal: nuevasFechas.fechaFinal,
        notificarEstudiantes: nuevasFechas.notificarEstudiantes, // Enviar la opción al backend
        id_admin: userData.id
      });
      
      if (response.data.status === 'success') {
        // Mensaje personalizado según si se envió notificación o no
        if (nuevasFechas.notificarEstudiantes) {
          alert('Fechas actualizadas y notificación enviada a los estudiantes');
        } else {
          alert('Fechas actualizadas correctamente');
        }
        
        // Cerrar modal
        setModalVisible(false);
        
        // Recargar datos
        const processResponse = await axios.get(`${API_URL}/api/procesos/${userData.id_sedeXescuela}`);
        if (processResponse.data.status === 'success') {
          setProcesos(processResponse.data.data.procesos);
          setHistorial(processResponse.data.data.historial);
        }
      } else {
        alert(response.data.message);
      }
    } catch (err) {
      alert('Error al actualizar fechas: ' + (err.response?.data?.message || err.message));
    }
  };

    const indexOfLastItem = currentPage * itemsPerPage;
    const indexOfFirstItem = indexOfLastItem - itemsPerPage;
    const currentItems = historial.slice(indexOfFirstItem, indexOfLastItem);
    const totalPages = Math.ceil(historial.length / itemsPerPage);

    // Función para cambiar de página
    const paginate = (pageNumber) => setCurrentPage(pageNumber);

  return (
    <div className="dashboard-container">
      <NavBar />
      
      <div className="dashboard-content">
        <h1 className="main-title">Solicitudes de Inclusiones</h1>
        
        <div className="content-area">
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
              <section className="procesos-section" aria-labelledby="gestion-procesos-titulo">
                <h2 id="gestion-procesos-titulo" className="section-title">Gestión de Procesos</h2>
                
                <div className="procesos-grid">
                  {/* Proceso de Inclusiones */}
                  <div className="proceso-card">
                    <h3 className="proceso-title">Proceso de Inclusiones</h3>
                    <div className="proceso-details">
                      <div className="status-row">
                        <span className="label">Estado actual:</span>
                        <span className={`estado-badge ${procesos.Inclusion?.estado ? 'activo' : 'inactivo'}`}>
                          {procesos.Inclusion?.estado ? 'Activo' : 'Inactivo'}
                        </span>
                      </div>
                      
                      <div className="date-row">
                        <span className="label">Fecha de inicio:</span>
                        <span className="date-value">{procesos.Inclusion?.fechaInicio || 'No definida'}</span>
                      </div>
                      
                      <div className="date-row">
                        <span className="label">Fecha de cierre:</span>
                        <span className="date-value">{procesos.Inclusion?.fechaFinal || 'No definida'}</span>
                      </div>
                    </div>
                    
                    <div className="proceso-actions">
                      <button 
                        className="btn-desactivar" 
                        onClick={() => handleToggleEstado(procesos.Inclusion)}
                        disabled={!procesos.Inclusion}
                      >
                        {procesos.Inclusion?.estado ? 'Desactivar' : 'Activar'}
                      </button>
                      
                      <button 
                        className="btn-modificar" 
                        onClick={() => openFechasModal(procesos.Inclusion)}
                        disabled={!procesos.Inclusion}
                      >
                        Modificar fechas
                      </button>
                    </div>
                  </div>
                  
                  {/* Proceso de Levantamiento */}
                  <div className="proceso-card">
                    <h3 className="proceso-title">Proceso de Levantamiento</h3>
                    <div className="proceso-details">
                      <div className="status-row">
                        <span className="label">Estado actual:</span>
                        <span className={`estado-badge ${procesos.Levantamiento?.estado ? 'activo' : 'inactivo'}`}>
                          {procesos.Levantamiento?.estado ? 'Activo' : 'Inactivo'}
                        </span>
                      </div>
                      
                      <div className="date-row">
                        <span className="label">Fecha de inicio:</span>
                        <span className="date-value">{procesos.Levantamiento?.fechaInicio || 'No definida'}</span>
                      </div>
                      
                      <div className="date-row">
                        <span className="label">Fecha de cierre:</span>
                        <span className="date-value">{procesos.Levantamiento?.fechaFinal || 'No definida'}</span>
                      </div>
                    </div>
                    
                    <div className="proceso-actions">
                      <button 
                        className="btn-desactivar" 
                        onClick={() => handleToggleEstado(procesos.Levantamiento)}
                        disabled={!procesos.Levantamiento}
                      >
                        {procesos.Levantamiento?.estado ? 'Desactivar' : 'Activar'}
                      </button>
                      
                      <button 
                        className="btn-modificar" 
                        onClick={() => openFechasModal(procesos.Levantamiento)}
                        disabled={!procesos.Levantamiento}
                      >
                        Modificar fechas
                      </button>
                    </div>
                  </div>
                </div>
              </section>
              
              <section className="historial-section" aria-labelledby="historial-cambios-titulo">
                <h2 id="historial-cambios-titulo" className="section-title">Historial de cambios</h2>
                
                <table className="historial-table" aria-label="Tabla de historial de cambios en procesos">
                  <thead>
                    <tr>
                      <th scope="col">Fecha</th>
                      <th scope="col">Administrador</th>
                      <th scope="col">Rol</th>
                      <th scope="col">Proceso</th>
                      <th scope="col">Acción</th>
                    </tr>
                  </thead>
                  <tbody>
                    {historial.length === 0 ? (
                      <tr>
                        <td colSpan="5" className="no-data-message">No hay registros de cambios</td>
                      </tr>
                    ) : (
                      currentItems.map((item, index) => (
                        <tr key={index}>
                          <td>{item.fecha}</td>
                          <td>{item.usuario}</td>
                          <td>{item.rol}</td>
                          <td>{item.proceso}</td>
                          <td>{item.accion}</td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>

                {/* Paginación */}
                {historial.length > 0 && (
                  <div className="pagination" role="navigation" aria-label="Paginación de resultados">
                    <button 
                      className={`pagination-btn prev ${currentPage === 1 ? 'disabled' : ''}`}
                      onClick={() => paginate(currentPage - 1)}
                      disabled={currentPage === 1}
                      aria-label="Página anterior"
                    >
                      &lt;
                    </button>
                    
                    {Array.from({ length: totalPages }, (_, index) => (
                      <button 
                        key={index + 1}
                        className={`pagination-btn ${currentPage === index + 1 ? 'active' : ''}`}
                        onClick={() => paginate(index + 1)}
                        aria-label={`Ir a página ${index + 1}`}
                        aria-current={currentPage === index + 1 ? "page" : undefined}
                      >
                        {index + 1}
                      </button>
                    ))}
                    
                    <button 
                      className={`pagination-btn next ${currentPage === totalPages ? 'disabled' : ''}`}
                      onClick={() => paginate(currentPage + 1)}
                      disabled={currentPage === totalPages}
                      aria-label="Página siguiente"
                    >
                      &gt;
                    </button>
                  </div>
                )}
              </section>
            </>
          )}
        </div>
      </div>
      
      {/* Modal para modificar fechas */}
      {modalVisible && procesoActual && (
        <div className="modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="modal-titulo">
          <div className="modal-contenido">
            <div className="modal-header">
              <h2 id="modal-titulo" className="modal-titulo">
                Modificar fechas del proceso de {procesoActual.tipo}
              </h2>
              <button 
                className="modal-close" 
                onClick={() => setModalVisible(false)}
                aria-label="Cerrar"
              >
                &times;
              </button>
            </div>
            
            <form onSubmit={handleSubmitFechas} className="modal-body">
              <div className="form-group">
                <label htmlFor="fechaInicio">Fecha de inicio:</label>
                <input 
                  type="date" 
                  id="fechaInicio"
                  name="fechaInicio"
                  value={nuevasFechas.fechaInicio}
                  onChange={handleFechaChange}
                  required
                  aria-required="true"
                />
              </div>
              
              <div className="form-group">
                <label htmlFor="fechaFinal">Fecha de cierre:</label>
                <input 
                  type="date" 
                  id="fechaFinal"
                  name="fechaFinal"
                  value={nuevasFechas.fechaFinal}
                  onChange={handleFechaChange}
                  required
                  aria-required="true"
                />
              </div>
              
              {/* Nuevo checkbox para notificación a estudiantes */}
              <div className="form-group checkbox-container">
                <div className="checkbox-group">
                  <input
                    type="checkbox"
                    id="notificarEstudiantes"
                    name="notificarEstudiantes"
                    checked={nuevasFechas.notificarEstudiantes}
                    onChange={handleFechaChange}
                  />
                  <label htmlFor="notificarEstudiantes">
                    Notificar a estudiantes sobre este cambio
                  </label>
                </div>
                <p className="checkbox-description">
                  Se enviará un correo electrónico a todos los estudiantes informando sobre el cambio en las fechas del proceso.
                </p>
              </div>
              
              <div className="modal-footer">
                <button 
                  type="button" 
                  className="btn-cancelar"
                  onClick={() => setModalVisible(false)}
                >
                  Cancelar
                </button>
                <button 
                  type="submit"
                  className="btn-guardar"
                >
                  Guardar cambios
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
      
      <footer className="dashboard-footer">
        <div className="footer-content">
          <span className="footer-contact">Contactos Admisión y Registro</span>
          <img src={logoTec} alt="TEC Logo" className="footer-logo" />
        </div>
      </footer>
    </div>
  );
};

export default HabilitarProcesos;