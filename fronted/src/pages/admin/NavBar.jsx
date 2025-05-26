import React, { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import './NavBar.css';
import defaultAvatar from '../../assets/images/default-avatar.png';

const NavBar = () => {
  const [currentTime, setCurrentTime] = useState(new Date());
  const [showMenu, setShowMenu] = useState(false);
  const navigate = useNavigate();
  
  // Recuperar datos del usuario
  const userData = JSON.parse(localStorage.getItem('userData') || '{}');
  
  // Actualizar la hora cada minuto
  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentTime(new Date());
    }, 60000);
    
    return () => clearInterval(timer);
  }, []);

  const handleLogout = () => {
    localStorage.removeItem('userData');
    localStorage.removeItem('userType');
    navigate('/login');
  };

  // Formatear hora y fecha
  const formattedTime = currentTime.toLocaleTimeString('es-CR', {
    hour: '2-digit',
    minute: '2-digit'
  });

  const formattedDate = currentTime.toLocaleDateString('es-CR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric'
  });

  const toggleMenu = () => {
    setShowMenu(!showMenu);
  };

  // Agregar manejo de teclado al menú
  const handleKeyDown = (e) => {
    if (e.key === 'Escape' && showMenu) {
      toggleMenu();
    }
  };

  // Añadir en useEffect
  useEffect(() => {
    if (showMenu) {
      document.addEventListener('keydown', handleKeyDown);
      return () => document.removeEventListener('keydown', handleKeyDown);
    }
  }, [showMenu]);

  return (
    <header className="barra-superior">
      <div className="perfil-seccion">
        <div className="foto-contenedor">
          <img 
            src={defaultAvatar} 
            alt="Foto del administrador" 
            className="foto-perfil"
          />
        </div>
        
        <div className="info-opciones">
          <div className="info-usuario">
            <strong className="nombre-usuario">
              {userData.nombre || 'María Fernanda'} {userData.apellido || 'Jiménez'}
            </strong>
            <span className="rol-usuario">
              {userData.role || 'COORDINADOR'}
            </span>
          </div>
          
          <div className="opciones-dropdown">
            <button 
              className="opciones-btn"
              onClick={toggleMenu}
              aria-expanded={showMenu}
              aria-controls="menu-opciones"
            >
              <span className="icono-opciones">≡</span>
              Opciones
            </button>
            
            {showMenu && (
              <nav id="menu-opciones" className="menu-opciones">
                <Link to="/admin/solicitudes-levantamiento">Solicitudes de levantamiento</Link>
                <Link to="/admin/solicitudes-inclusiones">Solicitudes de inclusiones</Link>
                <Link to="/admin/modificar-fechas">Modificar Fechas</Link>
                <Link to="/admin/habilitar-procesos">Habilitar Procesos</Link>
                <Link to="/admin/ayuda">Ayuda</Link>
              </nav>
            )}
          </div>
        </div>
      </div>
      
      <div className="tiempo-seccion">
        Hora: {formattedTime} | Fecha: {formattedDate}
      </div>
      
      <div className="logout-seccion">
        <div className="logout-container">
          <button 
            className="logout-btn"
            onClick={handleLogout}
            aria-label="Cerrar sesión"
          >
            <span className="logout-icono">→</span>
          </button>
          <span className="logout-text">Salir</span>
        </div>
      </div>
    </header>
  );
};

export default NavBar;