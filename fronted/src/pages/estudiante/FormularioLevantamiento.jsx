import React, { useState } from 'react';
import FormularioLevantamientoPg1 from './FormularioLevantamientoPg1';
import FormularioLevantamientoPg2 from './FormularioLevantamientoPg2';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';

const FormularioLevantamiento = ({ curso, onBack }) => {
  const [pagina, setPagina] = useState(1);
  const [formData, setFormData] = useState({
    curso: curso?.codigo || '',
    grupo: curso?.grupo || ''
  });

  const navigate = useNavigate();

  const handleNext = () => setPagina(2);
  const handleBack = () => {
    if (pagina === 1) {
      onBack();
    } else {
      setPagina(1);
    }
  };

  const handleSubmit = async (datosFinales) => {
    try {
      const estudiante = JSON.parse(localStorage.getItem('userData'));
      if (!estudiante?.id) {
        alert('No se pudo obtener el ID del estudiante.');
        return;
      }

      const payload = {
        ...formData,
        ...datosFinales,
        id_estudiante: estudiante.id,
        tipo_solicitud: 'levantamiento'
      };

      const response = await axios.post('http://localhost:5000/api/solicitudes/levantamiento', payload);

      if (response.data.status === 'success') {
        alert('Solicitud de levantamiento enviada exitosamente');
        navigate('/estudiante/solicitudes');
      } else {
        alert('Error al enviar la solicitud');
      }
    } catch (err) {
      console.error(err);
      alert('Error al conectar con el servidor');
    }
  };

  return (
    <div className="bg-white rounded shadow-md p-6">
      {pagina === 1 ? (
        <FormularioLevantamientoPg1
          onNext={handleNext}
          formData={formData}
          setFormData={setFormData}
        />
      ) : (
        <FormularioLevantamientoPg2
          formData={formData}
          onBack={handleBack}
          onSubmit={handleSubmit}
        />
      )}
    </div>
  );
};

export default FormularioLevantamiento;
