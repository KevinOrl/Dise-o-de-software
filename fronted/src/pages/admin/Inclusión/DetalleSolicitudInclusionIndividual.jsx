import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import NavBar from '../NavBar';
import './DetalleSolicitudInclusionIndividual.css';
import logoTec from '../../../assets/images/logo-tec-white.png';
import axios from 'axios';

const DetalleSolicitudInclusionIndividual = () => {
  const { codigo, grupo, id } = useParams();
  const navigate = useNavigate();

  // Estados
  const [solicitud, setSolicitud] = useState(null);
  const [estudiante, setEstudiante] = useState(null);
  const [curso, setCurso] = useState(null);
  const [comentario, setComentario] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [mensaje, setMensaje] = useState({ texto: '', tipo: '' });
  const [procesando, setProcesando] = useState(false);

  // Estados para los diálogos de confirmación
  const [mostrarDialogoDenegar, setMostrarDialogoDenegar] = useState(false);
  const [mostrarDialogoAprobar, setMostrarDialogoAprobar] = useState(false);
  const [mostrarConfirmacionDenegar, setMostrarConfirmacionDenegar] = useState(false);
  const [mostrarConfirmacionAprobar, setMostrarConfirmacionAprobar] = useState(false);

  // Obtener rol del usuario desde localStorage o estado global
  const [rolUsuario, setRolUsuario] = useState('');

  const API_URL = 'http://localhost:5000';

  useEffect(() => {
    // Recuperar información del usuario del localStorage
    const userData = JSON.parse(localStorage.getItem('userData') || '{}');
    setRolUsuario(userData.role || 'ASISTENTE'); // Valor por defecto: ASISTENTE
    
    const fetchDetalleSolicitud = async () => {
      try {
        setLoading(true);
        const response = await axios.get(`${API_URL}/api/solicitudes/inclusion/${codigo}/${grupo}/${id}`);
        
        if (response.data.status === 'success') {
          setSolicitud(response.data.data.solicitud);
          setEstudiante(response.data.data.estudiante);
          setCurso(response.data.data.curso);
          setComentario(response.data.data.solicitud.comentarioAdmin || '');
        } else {
          setError('Error al cargar datos: ' + response.data.message);
        }
      } catch (err) {
        setError('Error de conexión: ' + (err.message || 'Error desconocido'));
        console.error('Error al cargar detalles:', err);
      } finally {
        setLoading(false);
      }
    };

    fetchDetalleSolicitud();
  }, [codigo, grupo, id]);

  const handleComentarioChange = (e) => {
    setComentario(e.target.value);
  };

  const handleRevisar = async () => {
    if (!comentario.trim()) {
      setMensaje({ texto: 'Debe ingresar un comentario antes de revisar', tipo: 'error' });
      return;
    }

    try {
      setProcesando(true);
      const response = await axios.put(`${API_URL}/api/solicitudes/inclusion/${id}/revisar`, { 
        comentario 
      });
      
      if (response.data.status === 'success') {
        setSolicitud({
          ...solicitud,
          revisado: true,
          estado: 'Pendiente'
        });
        setMensaje({ texto: 'Solicitud marcada como revisada', tipo: 'success' });
      } else {
        setMensaje({ texto: 'Error: ' + response.data.message, tipo: 'error' });
      }
    } catch (err) {
      setMensaje({ texto: 'Error al procesar la solicitud', tipo: 'error' });
    } finally {
      setProcesando(false);
    }
  };

  // Funciones para mostrar los diálogos iniciales
  const mostrarConfirmacionDenegarSolicitud = () => {
    setMostrarDialogoDenegar(true);
  };

  const mostrarConfirmacionAprobarSolicitud = () => {
    setMostrarDialogoAprobar(true);
  };

  // Funciones para cancelar los diálogos
  const cancelarDenegar = () => {
    setMostrarDialogoDenegar(false);
  };

  const cancelarAprobar = () => {
    setMostrarDialogoAprobar(false);
  };

  // Función para aprobar la solicitud después de la confirmación
  const confirmarAprobar = async () => {
    setMostrarDialogoAprobar(false);
    setProcesando(true);
    
    try {
      const response = await axios.put(`${API_URL}/api/solicitudes/inclusion/${id}/aprobar`, { 
        comentario 
      });
      
      if (response.data.status === 'success') {
        setSolicitud({
          ...solicitud,
          estado: 'Aprobada'
        });
        setMostrarConfirmacionAprobar(true);
      } else {
        setMensaje({ texto: 'Error: ' + response.data.message, tipo: 'error' });
      }
    } catch (err) {
      setMensaje({ texto: 'Error al aprobar la solicitud', tipo: 'error' });
    } finally {
      setProcesando(false);
    }
  };

  // Función para denegar la solicitud después de la confirmación
  const confirmarDenegar = async () => {
    setMostrarDialogoDenegar(false);
    setProcesando(true);
    
    try {
      const response = await axios.put(`${API_URL}/api/solicitudes/inclusion/${id}/denegar`, { 
        comentario 
      });
      
      if (response.data.status === 'success') {
        setSolicitud({
          ...solicitud,
          estado: 'Denegada'
        });
        setMostrarConfirmacionDenegar(true);
      } else {
        setMensaje({ texto: 'Error: ' + response.data.message, tipo: 'error' });
      }
    } catch (err) {
      setMensaje({ texto: 'Error al denegar la solicitud', tipo: 'error' });
    } finally {
      setProcesando(false);
    }
  };

  // Cerrar diálogos de confirmación final
  const cerrarConfirmacionDenegar = () => {
    setMostrarConfirmacionDenegar(false);
  };

  const cerrarConfirmacionAprobar = () => {
    setMostrarConfirmacionAprobar(false);
  };

  if (loading) {
    return (
      <div className="dashboard-container">
        <NavBar />
        <div className="dashboard-content">
          <div className="loading-spinner" role="status">
            <span className="sr-only">Cargando detalles de la solicitud...</span>
          </div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="dashboard-container">
        <NavBar />
        <div className="dashboard-content">
          <div className="error-message" role="alert">
            {error}
          </div>
        </div>
      </div>
    );
  }

  if (!solicitud || !estudiante || !curso) {
    return (
      <div className="dashboard-container">
        <NavBar />
        <div className="dashboard-content">
          <div className="error-message" role="alert">
            No se encontraron datos de la solicitud
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="dashboard-container">
      <NavBar />
      
      <div className="dashboard-content">
        {/* Barra superior con "Volver al listado" */}
        <div className="breadcrumb-container">
          <button 
            className="volver-btn" 
            onClick={() => navigate(`/admin/solicitudes-inclusion/${codigo}/${grupo}`)}
            aria-label="Volver al listado de solicitudes"
          >
            <span className="volver-icono" aria-hidden="true">&lt;</span> 
            Volver al listado de solicitudes
          </button>
        </div>

        <div className="solicitud-layout">
          {/* Panel lateral izquierdo */}
          <div className="panel-izquierdo">
            <h2 className="solicitud-titulo">
              Solicitud de Inclusion #{String(solicitud.id).padStart(3, '0')}
            </h2>
          </div>

          {/* Panel principal */}
          <div className="panel-principal">
            {/* Mensaje de éxito o error */}
            {mensaje.texto && (
              <div className={`mensaje-alerta ${mensaje.tipo}`} role="alert">
                {mensaje.texto}
              </div>
            )}

            {/* Información del estudiante */}
            <section className="seccion-info" aria-labelledby="info-estudiante-titulo">
              <h3 id="info-estudiante-titulo">Información del estudiante</h3>
              
              <div className="info-grid">
                <div className="info-grupo">
                  <div className="info-row">
                    <div className="info-label">Nombre:</div>
                    <div className="info-valor">{estudiante.nombre}</div>
                  </div>
                  <div className="info-row">
                    <div className="info-label">Carnet:</div>
                    <div className="info-valor">{solicitud.carnet}</div>
                  </div>
                </div>
                
                <div className="info-grupo">
                  <div className="info-row">
                    <div className="info-label">Correo:</div>
                    <div className="info-valor">{estudiante.correo}</div>
                  </div>
                  <div className="info-row">
                    <div className="info-label">Teléfono:</div>
                    <div className="info-valor">{estudiante.telefono || 'No disponible'}</div>
                  </div>
                </div>
              </div>
            </section>
            
            {/* Detalle del curso */}
            <section className="seccion-info" aria-labelledby="info-curso-titulo">
              <h3 id="info-curso-titulo">Detalle del curso</h3>
              
              <div className="info-grid">
                <div className="info-grupo">
                  <div className="info-row">
                    <div className="info-label">Código:</div>
                    <div className="info-valor">{curso.codigo}</div>
                  </div>
                  <div className="info-row">
                    <div className="info-label">Nombre:</div>
                    <div className="info-valor">{curso.nombre}</div>
                  </div>
                </div>
                
                <div className="info-grupo">
                  <div className="info-row">
                    <div className="info-label">Grupo:</div>
                    <div className="info-valor">{curso.grupo}</div>
                  </div>
                  <div className="info-row">
                    <div className="info-label">Créditos:</div>
                    <div className="info-valor">{curso.creditos}</div>
                  </div>
                </div>
                
                <div className="info-row-full">
                  <div className="info-label">Fecha de solicitud:</div>
                  <div className="info-valor">{solicitud.fecha}</div>
                </div>
              </div>

              {/* Requisitos */}
              {curso.requisitos && curso.requisitos.length > 0 && (
                <div className="requisitos-container">
                  <h4>Requisitos</h4>
                  <ul className="requisitos-lista">
                    {curso.requisitos.map((requisito, index) => (
                      <li key={index}>{requisito.codigo} - {requisito.nombre}</li>
                    ))}
                  </ul>
                </div>
              )}
            </section>
            
            {/* Detalle de la solicitud */}
            <section className="seccion-info" aria-labelledby="info-solicitud-titulo">
              <h3 id="info-solicitud-titulo">Detalle de la solicitud</h3>
              
              <div className="motivo-container">
                <div className="info-label">Motivo:</div>
                <div className="motivo-texto">Solicitud de inclusion</div>
              </div>
              
              <div className="descripcion-container">
                <div className="info-label">Descripción:</div>
                <div className="descripcion-texto">{solicitud.motivo}</div>
              </div>
              
              {/* Documentos adjuntos */}
              <div className="documentos-container">
                <h4>Documentos adjuntos</h4>
                <div className="documentos-lista">
                  {solicitud.documentos.map((doc, index) => (
                    <div key={index} className="documento-item">
                      <span className="icono-documento" aria-hidden="true">📄</span>
                      <span className="nombre-documento">{doc.nombre}</span>
                    </div>
                  ))}
                </div>
              </div>
              
              {/* Comentarios y botones de acción según rol */}
              {rolUsuario === 'ASISTENTE' && !solicitud.revisado && (
                <div className="comentarios-container">
                  <div className="info-label">
                    <label htmlFor="comentario-admin">Comentario:</label>
                  </div>
                  <textarea 
                    id="comentario-admin"
                    className="comentario-textarea"
                    value={comentario}
                    onChange={handleComentarioChange}
                    placeholder="Ingrese sus comentarios aquí..."
                    rows="4"
                    aria-required="true"
                  ></textarea>
                  
                  <div className="botones-accion">
                    <button 
                      className="btn-revisar"
                      onClick={handleRevisar}
                      disabled={procesando}
                    >
                      Marcar como revisada
                    </button>
                  </div>
                </div>
              )}
              
              {/* Si es asistente pero ya está revisada, solo muestra el comentario */}
              {rolUsuario === 'ASISTENTE' && solicitud.revisado && (
                <div className="comentarios-container">
                  <div className="info-label">Comentario del asistente:</div>
                  <div className="comentario-readonly">{solicitud.comentarioAdmin || 'No hay comentarios'}</div>
                  <div className="estado-revisado">
                    <span className="badge revisado">Revisado</span>
                  </div>
                </div>
              )}
              
              {/* Coordinador solo ve comentarios y puede aprobar/denegar si está revisada */}
              {rolUsuario === 'COORDINADOR' && (
                <div className="comentarios-container">
                  <div className="info-label">Comentario del asistente:</div>
                  <div className="comentario-readonly">{solicitud.comentarioAdmin || 'No hay comentarios'}</div>
                  
                  {solicitud.revisado && solicitud.estado === 'Pendiente' && (
                    <div className="botones-accion">
                      <button 
                        className="btn-denegar"
                        onClick={mostrarConfirmacionDenegarSolicitud}
                        disabled={procesando}
                      >
                        Denegar
                      </button>
                      <button 
                        className="btn-aprobar"
                        onClick={mostrarConfirmacionAprobarSolicitud}
                        disabled={procesando}
                      >
                        Aprobar
                      </button>
                    </div>
                  )}
                  
                  {!solicitud.revisado && (
                    <div className="estado-no-revisado">
                      <span className="badge no-revisado">No revisado</span>
                      <p className="mensaje-espera">Esta solicitud debe ser revisada por un asistente antes de aprobarla o denegarla.</p>
                    </div>
                  )}
                  
                  {solicitud.revisado && solicitud.estado !== 'Pendiente' && (
                    <div className="estado-procesado">
                      <span className={`badge estado-${solicitud.estado.toLowerCase()}`}>
                        {solicitud.estado}
                      </span>
                    </div>
                  )}
                </div>
              )}
            </section>
          </div>
        </div>
      </div>
      
      {/* Diálogo de confirmación para denegar */}
      {mostrarDialogoDenegar && (
        <div className="modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="dialog-denegar-titulo">
          <div className="modal-contenido">
            <div className="modal-header rechazado">
              <h2 id="dialog-denegar-titulo" className="modal-titulo">
                <span aria-hidden="true">✕</span> Denegación De Solicitud
              </h2>
            </div>
            <div className="modal-body">
              <p>¿Está seguro que desea denegar esta solicitud?</p>
            </div>
            <div className="modal-footer">
              <button 
                className="btn-cancelar"
                onClick={cancelarDenegar}
                aria-label="Cancelar denegación"
              >
                Cancelar
              </button>
              <button 
                className="btn-confirmar-denegar"
                onClick={confirmarDenegar}
                aria-label="Confirmar denegación"
              >
                Denegar
              </button>
            </div>
          </div>
        </div>
      )}
      
      {/* Diálogo de confirmación para aprobar */}
      {mostrarDialogoAprobar && (
        <div className="modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="dialog-aprobar-titulo">
          <div className="modal-contenido">
            <div className="modal-header aprobado">
              <h2 id="dialog-aprobar-titulo" className="modal-titulo">
                <span aria-hidden="true">✓</span> Aprobación De Solicitud
              </h2>
            </div>
            <div className="modal-body">
              <p>¿Está seguro que desea aprobar esta solicitud?</p>
            </div>
            <div className="modal-footer">
              <button 
                className="btn-cancelar"
                onClick={cancelarAprobar}
                aria-label="Cancelar aprobación"
              >
                Cancelar
              </button>
              <button 
                className="btn-confirmar-aprobar"
                onClick={confirmarAprobar}
                aria-label="Confirmar aprobación"
              >
                Aprobar
              </button>
            </div>
          </div>
        </div>
      )}
      
      {/* Diálogo de confirmación final para denegación */}
      {mostrarConfirmacionDenegar && (
        <div className="modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="confirmacion-denegar-titulo">
          <div className="modal-contenido">
            <div className="modal-header confirmacion-rechazo">
              <h2 id="confirmacion-denegar-titulo" className="modal-titulo">
                Confirmación de rechazo
              </h2>
            </div>
            <div className="modal-body confirmacion">
              <p className="texto-centrado">Solicitud {String(solicitud.id).padStart(3, '0')} Denegada</p>
            </div>
            <div className="modal-footer confirmacion">
              <button 
                className="btn-aceptar"
                onClick={cerrarConfirmacionDenegar}
                aria-label="Aceptar confirmación de denegación"
              >
                Aceptar
              </button>
            </div>
          </div>
        </div>
      )}
      
      {/* Diálogo de confirmación final para aprobación */}
      {mostrarConfirmacionAprobar && (
        <div className="modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="confirmacion-aprobar-titulo">
          <div className="modal-contenido">
            <div className="modal-header confirmacion-aprobacion">
              <h2 id="confirmacion-aprobar-titulo" className="modal-titulo">
                Confirmación de aprobación
              </h2>
            </div>
            <div className="modal-body confirmacion">
              <p className="texto-centrado">Solicitud {String(solicitud.id).padStart(3, '0')} Aprobada</p>
            </div>
            <div className="modal-footer confirmacion">
              <button 
                className="btn-aceptar"
                onClick={cerrarConfirmacionAprobar}
                aria-label="Aceptar confirmación de aprobación"
              >
                Aceptar
              </button>
            </div>
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

export default DetalleSolicitudInclusionIndividual;