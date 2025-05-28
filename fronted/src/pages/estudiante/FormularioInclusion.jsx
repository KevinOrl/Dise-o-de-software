import React, { useState } from 'react';
import FormularioInclusionPg1 from './FormularioInclusionPg1';
import FormularioInclusionPg2 from './FormularioInclusionPg2';

const FormularioInclusion = ({ curso, onBack }) => {
  const [pagina, setPagina] = useState(1);
  const [formData, setFormData] = useState({
    curso: curso?.codigo || '',
    grupo: curso?.grupo || ''
  });

  const handleNext = () => setPagina(2);
  const handleBack = () => {
    if (pagina === 1) {
      onBack(); // vuelve al listado
    } else {
      setPagina(1);
    }
  };

  const handleSubmit = (datosFinales) => {
    console.log('Datos a enviar:', datosFinales);
  };

  return (
    <div className="bg-white rounded shadow-md p-6">
      {pagina === 1 ? (
        <FormularioInclusionPg1
          onNext={handleNext}
          formData={formData}
          setFormData={setFormData}
        />
      ) : (
        <FormularioInclusionPg2
          formData={formData}
          onBack={handleBack}
          onSubmit={handleSubmit}
        />
      )}
    </div>
  );
};

export default FormularioInclusion;


