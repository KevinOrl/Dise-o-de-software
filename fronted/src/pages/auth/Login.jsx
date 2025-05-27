import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import './Login.css';
import logoTec from '../../assets/images/logo-tec.png'; 
import campusBg from '../../assets/images/campus-bg.png';

const Login = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(false);
  const [loginError, setLoginError] = useState('');
  const [currentTime, setCurrentTime] = useState(new Date());
  
  const navigate = useNavigate();
  
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

  // Validación mejorada del formulario
  const validateForm = () => {
    const newErrors = {};
    
    // Validar que el correo no esté vacío
    if (!email.trim()) {
      newErrors.email = 'El correo electrónico es requerido';
    } else if (!/\S+@\S+\.\S+/.test(email)) {
      // Validar formato de correo
      newErrors.email = 'Formato de correo electrónico inválido';
    } else if (!email.endsWith('@estudiantec.cr') && !email.endsWith('@itcr.ac.cr')) {
      // Validar dominio institucional
      newErrors.email = 'Debe usar un correo institucional (@estudiantec.cr o @itcr.ac.cr)';
    }
    
    // Validar que la contraseña no esté vacía
    if (!password.trim()) {
      newErrors.password = 'La contraseña es requerida';
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  // Manejar el envío del formulario
  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Limpiar mensaje de error previo
    setLoginError('');
    
    // Validar el formulario
    if (!validateForm()) {
      return;
    }
    
    // Activar estado de carga
    setLoading(true);
    
    try {
      // Enviar solicitud al endpoint de autenticación
      const response = await axios.post('http://localhost:5000/api/auth/login', {
        email,
        password
      });
      
      // Verificar respuesta exitosa
      if (response.data.status === 'success') {
        // Guardar datos del usuario en localStorage
        localStorage.setItem('userType', response.data.userType);
        localStorage.setItem('userData', JSON.stringify(response.data.user));
        
        // Redireccionar según el tipo de usuario
        if (response.data.userType === 'estudiante') {
          navigate('/estudiante');
        } else if (response.data.userType === 'admin') {
          navigate('/admin/dashboard');
        }
      } else {
        // Manejar respuesta de error del servidor
        setLoginError(response.data.message || 'Error en la autenticación');
      }
    } catch (error) {
      console.error('Error al iniciar sesión:', error);
      
      // Manejar diferentes tipos de errores de la API
      if (error.response) {
        // El servidor respondió con un código de error
        switch (error.response.status) {
          case 400:
            setLoginError('Datos de inicio de sesión incompletos');
            break;
          case 401:
            setLoginError('Contraseña incorrecta');
            break;
          case 404:
            setLoginError('Usuario no encontrado');
            break;
          default:
            setLoginError(error.response.data.message || 'Error en el servidor');
        }
      } else if (error.request) {
        // No se recibió respuesta del servidor
        setLoginError('No hay respuesta del servidor. Verifique su conexión.');
      } else {
        // Error al configurar la solicitud
        setLoginError('Error al procesar la solicitud');
      }
    } finally {
      // Desactivar estado de carga al finalizar
      setLoading(false);
    }
  };

  // Alternar visibilidad de la contraseña
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
            
            {/* Mensaje de error general */}
            {loginError && (
              <div className="login-error-message" role="alert">
                {loginError}
              </div>
            )}
            
            <form onSubmit={handleSubmit} className="login-form" aria-labelledby="login-title">
              <div className="form-group">
                <label htmlFor="email">Correo electrónico</label>
                <div className="input-container">
                  <span className="input-icon" aria-hidden="true">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
                      <path d="M8 8a3 3 0 1 0 0-6 3 3 0 0 0 0 6zm2-3a2 2 0 1 1-4 0 2 2 0 0 1 4 0zm4 8c0 1-1 1-1 1H3s-1 0-1-1 1-4 6-4 6 3 6 4zm-1-.004c-.001-.246-.154-.986-.832-1.664C11.516 10.68 10.289 10 8 10c-2.29 0-3.516.68-4.168 1.332-.678.678-.83 1.418-.832 1.664h10z"/>
                    </svg>
                  </span>
                  <input
                    type="email"
                    id="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="correo@estudiantec.cr"
                    aria-required="true"
                    aria-invalid={errors.email ? "true" : "false"}
                    aria-describedby={errors.email ? "email-error" : undefined}
                    disabled={loading}
                  />
                </div>
                {errors.email && (
                  <div className="error-message" id="email-error" role="alert">
                    {errors.email}
                  </div>
                )}
              </div>
              
              <div className="form-group">
                <label htmlFor="password">Contraseña</label>
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
                    disabled={loading}
                  />
                  <button 
                    type="button" 
                    className="password-toggle" 
                    onClick={togglePasswordVisibility}
                    aria-label={showPassword ? "Ocultar contraseña" : "Mostrar contraseña"}
                    disabled={loading}
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
                disabled={loading}
              >
                {loading ? "Procesando..." : "Ingresar"}
              </button>
            </form>
            
            {/* Para el estado de carga */}
            {loading && (
              <div className="loading-indicator" role="status" aria-live="polite">
                Procesando solicitud...
              </div>
            )}
            
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