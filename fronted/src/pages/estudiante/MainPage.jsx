import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { FaCalendarAlt, FaFileAlt, FaSignOutAlt, FaUserCircle, FaChevronDown } from 'react-icons/fa';

const MainPage = () => {
  const navigate = useNavigate();
  const [menuOpen, setMenuOpen] = useState(false);

  const estudiante = {
    nombre: 'Nombre del estudiante',
    carnet: 'carnet'
  };

  const opciones = [
    'Matrículas Disponibles',
    'Mi Historial Académico',
    'Requisitos Pendientes',
    'Código de PIN',
    'Solicitudes',
    'Retiro de cursos',
    'Ayuda'
  ];

  const toggleMenu = () => setMenuOpen(!menuOpen);

  return (
    <div className="min-h-screen bg-white text-gray-800 flex flex-col">
      <header className="bg-[#003366] text-white flex justify-between items-center px-6 py-4">
        <div className="flex items-center space-x-4">
          <FaUserCircle size={48} />
          <div>
            <div className="font-semibold">{estudiante.nombre}</div>
            <div className="text-sm">{estudiante.carnet}</div>
          </div>
          <button
            className="ml-6 flex items-center space-x-1 bg-transparent border-none text-white focus:outline-none"
            onClick={toggleMenu}
          >
            <span className="text-lg font-semibold">☰ Opciones</span>
            <FaChevronDown className="ml-1" />
          </button>
          {menuOpen && (
            <div className="absolute mt-16 bg-white text-black shadow-lg rounded-md w-56 p-2 z-10">
              {opciones.map((op, index) => (
                <div
                  key={index}
                  className="px-4 py-2 hover:bg-gray-100 cursor-pointer rounded-md"
                >
                  {op}
                </div>
              ))}
            </div>
          )}
        </div>
        <div className="flex flex-col text-right text-sm">
          <div>Hora <span className="font-semibold">&lt;hora&gt;</span></div>
          <div>Fecha <span className="font-semibold">&lt;fecha&gt;</span></div>
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
          <button className="flex items-center space-x-1">
            <FaSignOutAlt />
            <span>Salir</span>
          </button>
        </div>
      </header>

      <main className="flex-1 flex justify-center items-start p-10">
        <h2 className="text-xl font-semibold text-gray-400">Sistema de monitoreo</h2>
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

