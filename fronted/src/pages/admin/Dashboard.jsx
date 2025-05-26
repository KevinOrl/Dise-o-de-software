import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import './Dashboard.css';
import logoTec from '../../assets/images/logo-tec-white.png'
import NavBar from './NavBar';

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

  if (!userData) {
    return <div className="loading">Cargando...</div>;
  }

  return (
    <div className="dashboard-container">
      <NavBar />
      
      {/* Añadir skip link al inicio del componente */}
      <a href="#main-content" className="skip-link">
        Saltar al contenido principal
      </a>
      
      <div className="dashboard-content">
        <h1 className="main-title" color='#D3E0EB'>Sistema de monitoreo</h1>
        
        {/* En el contenido principal */}
        <main id="main-content" className="dashboard-content">
          <div className="content-area"></div>
        </main>
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

export default AdminDashboard;

