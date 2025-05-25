import React, { useState, useEffect } from 'react';
import './Login.css';
import logoTec from '../../assets/images/logo-tec.png'; 
import campusBg from '../../assets/images/campus-bg.png'; // Asegúrate de tener esta imagen

const Login = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [errors, setErrors] = useState({});
  const [currentTime, setCurrentTime] = useState(new Date());
  
  // Actualizar la hora cada minuto
  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentTime(new Date());
    }, 60000);
    
    return () => clearInterval(timer);
  }, []);

  // Formatear la hora
  const formattedTime = currentTime.toLocaleTimeString('es-CR', {
    hour: '2-digit',
    minute: '2-digit'
  });

  // Formatear la fecha
  const formattedDate = currentTime.toLocaleDateString('es-CR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric'
  });

  const validateForm = () => {
    const newErrors = {};
    
    if (!email) {
      newErrors.email = 'El correo electrónico es requerido';
    } else if (!/\S+@\S+\.\S+/.test(email)) {
      newErrors.email = 'Formato de correo electrónico inválido';
    }
    
    if (!password) {
      newErrors.password = 'La contraseña es requerida';
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (validateForm()) {
      console.log('Formulario enviado:', { email, password });
      alert('Inicio de sesión exitoso (simulado)');
    }
  };

  const togglePasswordVisibility = () => {
    setShowPassword(!showPassword);
  };

  return (
    <div className="login-container">
      <header className="login-header">
        <img 
          src={logoTec} 
          alt="Logo del Instituto Tecnológico de Costa Rica" 
          className="tec-logo"
        />
        <div className="datetime-info">
          <div className="time-display" aria-live="polite">
            Hora: <span>{formattedTime}</span>
          </div>
          <div className="date-display">
            Fecha: <span>{formattedDate}</span>
          </div>
        </div>
      </header>
      
      <main className="login-main">
        <div className="login-box">
          <div className="campus-image">
            <img src={campusBg} alt="" aria-hidden="true" />
          </div>
          
          <div className="login-form-container">
            <h1 id="login-title">Sistema de Matrícula</h1>
            
            <form onSubmit={handleSubmit} className="login-form" aria-labelledby="login-title">
              <div className="form-group">
                <label htmlFor="email" className="visually-hidden">Correo electrónico</label>
                <div className="input-container">
                  <span className="input-icon" aria-hidden="true">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
                      <path d="M8 8a3 3 0 1 0 0-6 3 3 0 0 0 0 6zm2-3a2 2 0 1 1-4 0 2 2 0 0 1 4 0zm4 8c0 1-1 1-1 1H3s-1 0-1-1 1-4 6-4 6 3 6 4zm-1-.004c-.001-.246-.154-.986-.832-1.664C11.516 10.68 10.289 10 8 10c-2.29 0-3.516.68-4.168 1.332-.678.678-.83 1.418-.832 1.664h10z"/>
                    </svg>
                  </span>
                  <input
                    type="email"
                    id="email"
                    name="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="correo@estudiantec.cr"
                    aria-required="true"
                    aria-invalid={errors.email ? "true" : "false"}
                    aria-describedby={errors.email ? "email-error" : undefined}
                  />
                </div>
                {errors.email && (
                  <div className="error-message" id="email-error" role="alert">
                    {errors.email}
                  </div>
                )}
              </div>
              
              <div className="form-group">
                <label htmlFor="password" className="visually-hidden">Contraseña</label>
                <div className="input-container">
                  <span className="input-icon" aria-hidden="true">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
                      <path d="M8 1a2 2 0 0 1 2 2v4H6V3a2 2 0 0 1 2-2zm3 6V3a3 3 0 0 0-6 0v4a2 2 0 0 0-2 2v5a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2zM5 8h6a1 1 0 0 1 1 1v5a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V9a1 1 0 0 1 1-1z"/>
                    </svg>
                  </span>
                  <input
                    type={showPassword ? "text" : "password"}
                    id="password"
                    name="password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="contraseña"
                    aria-required="true"
                    aria-invalid={errors.password ? "true" : "false"}
                    aria-describedby={errors.password ? "password-error" : undefined}
                  />
                  <button 
                    type="button" 
                    className="password-toggle" 
                    onClick={togglePasswordVisibility}
                    aria-label={showPassword ? "Ocultar contraseña" : "Mostrar contraseña"}
                  >
                    {showPassword ? "Ocultar" : "Mostrar"}
                  </button>
                </div>
                {errors.password && (
                  <div className="error-message" id="password-error" role="alert">
                    {errors.password}
                  </div>
                )}
              </div>
              
              <button 
                type="submit" 
                className="login-button"
                aria-label="Iniciar sesión en el sistema"
              >
                Ingresar
              </button>
            </form>
            
            <div className="login-options">
              <a 
                href="https://aplics.tec.ac.cr/MiCuentaTEC/Home/OlvidoPassEstudiante" 
                className="forgot-password"
                aria-label="Recuperar contraseña olvidada"
              >
                ¿Olvidaste tu contraseña?
              </a>
              <a 
                href="#admin" 
                className="admin-link"
                aria-label="Acceso para administradores"
              >
                Admin
              </a>
            </div>
            
            <div className="create-account">
              <a 
                href="https://aplics.tec.ac.cr/MiCuentaTEC/Home/CrearCuentaEstudiante" 
                className="create-account-link"
                aria-label="Crear una nueva cuenta de estudiante"
              >
                Crear tu cuenta @estudiantTEC.cr
              </a>
            </div>
          </div>
        </div>
      </main>
      
      <footer className="login-footer">
        <div className="footer-content">
          <a href="https://tec-appsext.itcr.ac.cr/Matricula/frmAutenticacion.aspx?ReturnUrl=%2fmatricula" className="contact-link">
            Contactos Admisión y Registro
          </a>
          <p className="copyright">
            DATIC - Tecnológico de Costa Rica - v1.5.4 - © 2025
          </p>
        </div>
      </footer>
    </div>
  );
};

export default Login;