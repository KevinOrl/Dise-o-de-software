import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { FaCalendarAlt, FaFileAlt, FaSignOutAlt, FaUserCircle, FaChevronDown } from 'react-icons/fa';
import HistorialSolicitudes from './HistorialSolicitudes';
import HistorialRetiros from './HistorialRetiros';
import MatriculasDisponibles from './MatriculasDisponibles';

const MainPage = () => {
  const navigate = useNavigate();
  const [menuOpen, setMenuOpen] = useState(false);
  const [hora, setHora] = useState('');
  const [fecha, setFecha] = useState('');
  const [vistaActual, setVistaActual] = useState('');
  const userData = JSON.parse(localStorage.getItem('userData'));
  const idEstudiante = userData?.id;


  useEffect(() => {
    const actualizarHoraYFecha = () => {
      const ahora = new Date();
      const horaFormateada = ahora.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
      const fechaFormateada = ahora.toLocaleDateString('es-CR', {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      });
      setHora(horaFormateada);
      setFecha(fechaFormateada.charAt(0).toUpperCase() + fechaFormateada.slice(1));
    };

    actualizarHoraYFecha();
    const intervalo = setInterval(actualizarHoraYFecha, 60000);

    return () => clearInterval(intervalo);
  }, []);

  const estudiante = {
    nombre: userData?.nombre || 'Estudiante',
    carnet: userData?.carnet || 'N/A'
  };

  const opciones = [
    { label: 'Matrículas Disponibles', action: () => setVistaActual('matriculas') },
    { label: 'Mi Historial Académico', action: () => setVistaActual('') },
    { label: 'Historial Solicitudes', action: () => setVistaActual('solicitudes') },
    { label: 'Historial Retiro de cursos', action: () => setVistaActual('retiros') },
    <a
      href="mailto:femurillo@estudiantec.cr?subject=Ayuda%20con%20el%20Sistema&body=Describa%20el%20problema%20aqui..."
      onClick={() => alert('Se abrirá tu correo para enviar el mensaje de ayuda')}
      className="block px-4 py-2 hover:bg-gray-100 cursor-pointer rounded-md"
    >
      Ayuda
    </a>
  ];

  const toggleMenu = () => setMenuOpen(!menuOpen);

  return (
    <div className="min-h-screen bg-white text-gray-800 flex flex-col">
      <header className="bg-[#00548f] text-white flex justify-between items-center px-6 py-4">
        <div className="flex items-center space-x-4">
          <FaUserCircle size={48} />
          <div>
            <div className="font-semibold">{estudiante.nombre}</div>
            <div className="text-sm">{estudiante.carnet}</div>
          </div>
          <div className="relative ml-6">
            <button
              className="flex items-center space-x-1 bg-white text-[#00548f] px-4 py-2 rounded-md shadow-sm hover:bg-gray-100 transition-colors"
              onClick={toggleMenu}
            >
              <span className="text-sm font-semibold">☰ Opciones</span>
              <FaChevronDown className="ml-1" />
            </button>

            {menuOpen && (
              <div className="absolute left-0 top-full mt-2 bg-white text-black shadow-lg rounded-md w-64 py-2 z-50">
                {opciones.map((op, index) =>
                  op.label !== 'Ayuda' ? (
                    <div
                      key={index}
                      onClick={() => {
                        op.action();
                        setMenuOpen(false);
                      }}
                      className="px-4 py-2 hover:bg-gray-100 cursor-pointer rounded-md"
                    >
                      {op.label}
                    </div>
                  ) : null
                )}
                <a
                  href="mailto:femurillo@estudiantec.cr?subject=Ayuda%20con%20el%20Sistema&body=Describa%20el%20problema%20aquí..."
                  onClick={() => {
                    alert('📧 Se abrirá tu correo para enviar el mensaje de ayuda');
                    setMenuOpen(false);
                  }}
                  className="block px-4 py-2 hover:bg-gray-100 cursor-pointer rounded-md"
                >
                  Ayuda
                </a>
              </div>
            )}
          </div>
        </div>
        <div className="flex items-center gap-4 text-sm text-white">
          <div>
            Hora: <span className="font-semibold">{hora}</span>
          </div>
          <div>
            Fecha: <span className="font-semibold">{fecha}</span>
          </div>
        </div>
        <div className="flex items-center space-x-6 text-sm">
          <button className="flex items-center space-x-1">
            <FaCalendarAlt />
            <span>Mi horario</span>
          </button>
          <button className="flex items-center space-x-1">
            <FaFileAlt />
            <span>Mi informe</span>
          </button>
          <button
            className="flex items-center space-x-1"
            onClick={() => {
              localStorage.clear(); // Borra los datos del usuario
              navigate('/'); // Redirige al login
            }}
          >
            <FaSignOutAlt />
            <span>Salir</span>
          </button>
        </div>
      </header>

      <main className="flex-1 flex justify-center items-start p-10">
        {vistaActual === 'solicitudes' && userData && (<HistorialSolicitudes idEstudiante={idEstudiante} />)}
        {vistaActual === 'retiros' && userData && (<HistorialRetiros idEstudiante={idEstudiante} />)}
        {vistaActual === 'matriculas' && userData && (<MatriculasDisponibles idEstudiante={idEstudiante} />)}
        {!vistaActual && (
          <h2 className="text-xl font-semibold text-gray-400">Sistema de monitoreo</h2>
        )}
      </main>
      <footer className="border-t border-gray-200 text-sm text-gray-500 p-4 flex justify-between items-center">
        <div className="flex items-center space-x-1">
          <span>✉️</span>
          <span>Contactos Admisión y Registro</span>
        </div>
        <div className="font-light">TEC - Tecnológico de Costa Rica - v1.5.4 - © 2025</div>
      </footer>
    </div>
  );
};

export default MainPage;

