import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
// Corregir la importación del NavBar
import NavBar from '../NavBar';
import './SolicitudesLevantamiento.css';
import logoTec from '../../../assets/images/logo-tec-white.png';

const SolicitudesLevantamiento = () => {
  // Estados para manejar los datos y la paginación
  const [cursos, setCursos] = useState([]);
  const [currentPage, setCurrentPage] = useState(1);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const ITEMS_PER_PAGE = 5; // Número de cursos por página

  // Datos de prueba - En producción vendrían de una API
  useEffect(() => {
    // Simular carga de datos
    setLoading(true);
    
    setTimeout(() => {
      // Datos de ejemplo basados en la imagen
      const datosEjemplo = [
        { codigo: 'IC2101', nombre: 'Programación Orientada a Objetos', creditos: 4, grupo: 1, solicitudes: 3 },
        { codigo: 'IC2001', nombre: 'Estructuras de Datos', creditos: 4, grupo: 2, solicitudes: 5 },
        { codigo: 'IC3002', nombre: 'Análisis de Algoritmos', creditos: 4, grupo: 1, solicitudes: 2 },
        { codigo: 'IC4301', nombre: 'Bases de Datos I', creditos: 4, grupo: 3, solicitudes: 8 },
        { codigo: 'IC7602', nombre: 'Redes', creditos: 3, grupo: 1, solicitudes: 4 },
      ];
      setCursos(datosEjemplo);
      setLoading(false);
    }, 600);
  }, []);

  // Función para cambiar de página
  const handlePageChange = (pageNumber) => {
    setCurrentPage(pageNumber);
  };

  const totalPages = Math.ceil(cursos.length / ITEMS_PER_PAGE);

  return (
    <div className="dashboard-container">
      {/* Mantener la barra de navegación */}
      <NavBar />
      
      <div className="dashboard-content">
        <h1 className="main-title">Solicitudes de Levantamientos</h1>
        
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
              <div className="table-container">
                <table className="solicitudes-table" aria-label="Tabla de solicitudes de levantamientos">
                  <thead>
                    <tr>
                      <th scope="col" id="col-codigo">Código</th>
                      <th scope="col" id="col-nombre">Nombre del curso</th>
                      <th scope="col" id="col-creditos">Créditos</th>
                      <th scope="col" id="col-grupo">Grupo</th>
                      <th scope="col" id="col-solicitudes">Solicitudes</th>
                      <th scope="col" id="col-acciones">Acciones</th>
                    </tr>
                  </thead>
                  <tbody>
                    {cursos.length === 0 ? (
                      <tr>
                        <td colSpan="6" className="no-data-message">No hay solicitudes de levantamiento disponibles</td>
                      </tr>
                    ) : (
                      // Filtrar cursos según la página actual
                      cursos
                        .slice((currentPage - 1) * ITEMS_PER_PAGE, currentPage * ITEMS_PER_PAGE)
                        .map((curso) => (
                          <tr key={`${curso.codigo}-${curso.grupo}`}>
                            <td headers="col-codigo">{curso.codigo}</td>
                            <td headers="col-nombre">{curso.nombre}</td>
                            <td headers="col-creditos">{curso.creditos}</td>
                            <td headers="col-grupo">{curso.grupo}</td>
                            <td headers="col-solicitudes">{curso.solicitudes}</td>
                            <td headers="col-acciones">
                              <button 
                                className="ver-solicitudes-btn"
                                onClick={() => {/* Implementar navegación a detalle */}}
                                aria-label={`Ver solicitudes para ${curso.nombre} grupo ${curso.grupo}`}
                              >
                                Ver solicitudes
                              </button>
                            </td>
                          </tr>
                        ))
                    )}
                  </tbody>
                </table>
              </div>
              
              {/* Paginación */}
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

export default SolicitudesLevantamiento;