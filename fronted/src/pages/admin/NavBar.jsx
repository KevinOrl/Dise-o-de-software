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
  
  // Formatear hora y fecha
  const formattedTime = currentTime.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  const formattedDate = currentTime.toLocaleDateString('es-ES', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  });
  
  const handleLogout = () => {
    localStorage.removeItem('userData');
    navigate('/');
  };
  
  return (
    <nav className="navbar">
      <div className="navbar-left">
        <button 
          className="menu-button"
          onClick={() => setShowMenu(!showMenu)}
          aria-expanded={showMenu}
          aria-controls="menu-opciones"
        >
          ☰
        </button>
        <div className="user-info">
          <img 
            src={userData.avatar || defaultAvatar} 
            alt="Avatar" 
            className="user-avatar"
          />
          <div className="user-details">
            <span className="user-name">{userData.nombre || 'Usuario'}</span>
            <span className="user-role">{userData.rol || 'Administrador'}</span>
          </div>
        </div>
      </div>
      
      <div className="navbar-right">
        <div className="datetime-info">
          <span className="time">Hora: {formattedTime}</span>
          <span className="date">Fecha: {formattedDate}</span>
        </div>
        <button className="logout-button" onClick={handleLogout}>
          Cerrar Sesión
        </button>
      </div>
      
      {showMenu && (
        <nav id="menu-opciones" className="menu-opciones">
          <Link to="/admin/solicitudes-levantamiento">Solicitudes de levantamiento</Link>
          <Link to="/admin/solicitudes-inclusiones">Solicitudes de inclusiones</Link>
          <Link to="/admin/habilitar-procesos">Habilitar Procesos</Link>
          {/* Enlace de ayuda exactamente como solicitado */}
          <a
            href="mailto:kevnunez@estudiantec.cr?subject=Ayuda%20con%20el%20Sistema&body=Describa%20el%20problema%20aqui..."
            onClick={() => alert('Se abrirá tu correo para enviar el mensaje de ayuda')}
            className="block px-4 py-2 hover:bg-gray-100 cursor-pointer rounded-md"
          >
            Ayuda
          </a>
        </nav>
      )}
    </nav>
  );
};

export default NavBar;