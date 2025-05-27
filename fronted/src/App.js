import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import './App.css';

import Login from './pages/auth/Login';
import EstudianteDashboard from './pages/estudiante/Dashboard';
import AdminDashboard from './pages/admin/Dashboard';
import SolicitudesLevantamiento from './pages/admin/Levantamientos/SolicitudesLevantamiento';
import DetalleSolicitudes from './pages/admin/Levantamientos/DetalleSolicitudes';
import DetalleSolicitudIndividual from './pages/admin/Levantamientos/DetalleSolicitudIndividual';
import MainPage from './pages/estudiante/MainPage';


function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Login />} />
        <Route path="/login" element={<Login />} />
        <Route path="/estudiante/dashboard" element={<EstudianteDashboard />} />
        <Route path="/estudiante" element={<MainPage />} />
        <Route path="/admin/dashboard" element={<AdminDashboard />} />
        
        {/* Rutas de administración */}
        <Route path="/admin/solicitudes-levantamiento" element={<SolicitudesLevantamiento />} />
        <Route path="/admin/solicitudes-levantamiento/:codigo/:grupo" element={<DetalleSolicitudes />} />
        <Route path="/admin/solicitudes-levantamiento/:codigo/:grupo/:id" element={<DetalleSolicitudIndividual />} />
        <Route path="/admin/horario" element={<div>Página de Horario</div>} />
        <Route path="/admin/informe" element={<div>Página de Informe</div>} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;