import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import './Dashboard.css';

const EstudianteDashboard = () => {
  const [userData, setUserData] = useState(null);
  const navigate = useNavigate();

  useEffect(() => {
    // Recuperar datos del usuario del localStorage
    const storedUserData = localStorage.getItem('userData');
    const userType = localStorage.getItem('userType');
    
    // Verificar que existan datos y que el usuario sea estudiante
    if (!storedUserData || userType !== 'estudiante') {
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
          <h1>Bienvenido, {userData.nombre} {userData.apellido}</h1>
          <p>Carnet: {userData.carnet}</p>
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
              <li><a href="#matricula">Matrícula</a></li>
              <li><a href="#horario">Horario</a></li>
              <li><a href="#expediente">Expediente</a></li>
              <li><a href="#configuracion">Configuración</a></li>
            </ul>
          </nav>
        </aside>
        
        <main className="dashboard-main">
          <section className="welcome-section">
            <h2>Sistema de Matrícula TEC</h2>
            <p>Bienvenido al sistema de matrícula del Instituto Tecnológico de Costa Rica.</p>
            
            <div className="info-cards">
              <div className="info-card">
                <h3>Próxima matrícula</h3>
                <p>La matrícula para el próximo semestre inicia el 15 de julio de 2025.</p>
              </div>
              
              <div className="info-card">
                <h3>Cursos matriculados</h3>
                <p>Actualmente tienes 5 cursos matriculados este semestre.</p>
              </div>
              
              <div className="info-card">
                <h3>Anuncios</h3>
                <p>No hay anuncios nuevos.</p>
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

export default EstudianteDashboard;