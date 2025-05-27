import React, { useState } from 'react';
import FormularioInclusionPg1 from './FormularioInclusionPg1';
import FormularioInclusionPg2 from './FormularioInclusionPg2';

const FormularioInclusiono = ({ onBack }) => {
  const [step, setStep] = useState(1);
  const [formData, setFormData] = useState({});

  const handleNext = () => setStep(2);
  const handleBack = () => setStep(1);

  const handleSubmit = (finalData) => {
    console.log('Solicitud completa:', finalData);
    // Aquí puedes enviar el formData + finalData al backend
  };

  return (
    <div className="p-6 max-w-5xl mx-auto">
      {step === 1 && (
        <FormularioInclusionPg1
          formData={formData}
          setFormData={setFormData}
          onNext={handleNext}
        />
      )}
      {step === 2 && (
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

