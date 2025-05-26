import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import './Dashboard.css';

const AdminDashboard = () => {
  const [userData, setUserData] = useState(null);
  const navigate = useNavigate();

  useEffect(() => {
    // Recuperar datos del usuario del localStorage
    const storedUserData = localStorage.getItem('userData');
    const userType = localStorage.getItem('userType');
    
    // Verificar que existan datos y que el usuario sea administrador
    if (!storedUserData || userType !== 'admin') {
      navigate('/login');
      return;
    }
    
    try {
      const parsedUserData = JSON.parse(storedUserData);
      setUserData(parsedUserData);
    } catch (error) {
      console.error('Error al parsear datos del usuario:', error);
      navigate('/login');
    }
  }, [navigate]);

  const handleLogout = () => {
    // Limpiar localStorage
    localStorage.removeItem('userData');
    localStorage.removeItem('userType');
    
    // Redirigir al login
    navigate('/login');
  };

  if (!userData) {
    return <div className="loading">Cargando...</div>;
  }

  return (
    <div className="dashboard-container">
      <header className="dashboard-header">
        <div className="user-welcome">
          <h1>Panel de Administración</h1>
          <p>
            Bienvenido, {userData.nombre} {userData.apellido} | 
            Rol: {userData.role || 'Administrador'}
          </p>
        </div>
        <button className="logout-button" onClick={handleLogout}>
          Cerrar sesión
        </button>
      </header>
      
      <div className="dashboard-content">
        <aside className="dashboard-sidebar">
          <nav>
            <ul>
              <li className="active"><a href="#inicio">Inicio</a></li>
              <li><a href="#estudiantes">Estudiantes</a></li>
              <li><a href="#cursos">Cursos</a></li>
              <li><a href="#profesores">Profesores</a></li>
              <li><a href="#reportes">Reportes</a></li>
              <li><a href="#configuracion">Configuración</a></li>
            </ul>
          </nav>
        </aside>
        
        <main className="dashboard-main">
          <section className="welcome-section">
            <h2>Sistema de Administración TEC</h2>
            <p>Bienvenido al panel de administración del Instituto Tecnológico de Costa Rica.</p>
            
            <div className="info-cards">
              <div className="info-card">
                <h3>Estado del sistema</h3>
                <p>El sistema de matrícula está funcionando correctamente.</p>
              </div>
              
              <div className="info-card">
                <h3>Próximos eventos</h3>
                <p>Apertura de matrícula: 15 de julio de 2025</p>
              </div>
              
              <div className="info-card">
                <h3>Estadísticas</h3>
                <p>3,540 estudiantes matriculados en el semestre actual.</p>
              </div>
              
              <div className="info-card">
                <h3>Acciones rápidas</h3>
                <div className="action-buttons">
                  <button>Administrar estudiantes</button>
                  <button>Gestionar cursos</button>
                  <button>Generar reportes</button>
                </div>
              </div>
            </div>
          </section>
        </main>
      </div>
      
      <footer className="dashboard-footer">
        <p>DATIC - Tecnológico de Costa Rica - v1.5.4 - © 2025</p>
      </footer>
    </div>
  );
};

export default AdminDashboard;