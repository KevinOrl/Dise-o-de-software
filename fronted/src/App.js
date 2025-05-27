import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import './App.css';

import Login from './pages/auth/Login';
import EstudianteDashboard from './pages/estudiante/Dashboard';
import AdminDashboard from './pages/admin/Dashboard';
import SolicitudesLevantamiento from './pages/admin/Levantamientos/SolicitudesLevantamiento';
import DetalleSolicitudesLevantamiento from './pages/admin/Levantamientos/DetalleSolicitudesLevantamiento';
import DetalleSolicitudLevantamientoIndividual from './pages/admin/Levantamientos/DetalleSolicitudLevantamientoIndividual';
import MainPage from './pages/estudiante/MainPage';
import SolicitudesInclusion from './pages/admin/Inclusión/SolicitudesInclusion';


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
        <Route path="/admin/solicitudes-levantamiento/:codigo/:grupo" element={<DetalleSolicitudesLevantamiento />} />
        <Route path="/admin/solicitudes-levantamiento/:codigo/:grupo/:id" element={<DetalleSolicitudLevantamientoIndividual />} />

        <Route path="/admin/solicitudes-inclusiones" element={<SolicitudesInclusion />} />


        <Route path="/admin/horario" element={<div>Página de Horario</div>} />
        <Route path="/admin/informe" element={<div>Página de Informe</div>} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;