import React, { useState } from 'react';

const FormularioInclusionPg2 = ({ formData, onBack, onSubmit }) => {
  const [curso, setCurso] = useState('');
  const [grupo, setGrupo] = useState('');
  const [motivo, setMotivo] = useState('');

  const handleSubmit = () => {
    const datosFinales = {
      ...formData,
      curso,
      grupo,
      motivo
    };

    // Llamar a la función del padre para enviar
    onSubmit(datosFinales);
  };

  return (
    <div className="p-8 max-w-3xl mx-auto">
      <h2 className="text-xl font-bold mb-6">Paso 2 - Detalles del curso</h2>

      <div className="grid grid-cols-1 gap-4">
        <input
          type="text"
          placeholder="Código del curso a incluir"
          value={curso}
          onChange={(e) => setCurso(e.target.value)}
          className="border p-2"
        />
        <input
          type="text"
          placeholder="Número de grupo"
          value={grupo}
          onChange={(e) => setGrupo(e.target.value)}
          className="border p-2"
        />
        <textarea
          placeholder="Explique el motivo de su solicitud"
          value={motivo}
          onChange={(e) => setMotivo(e.target.value)}
          className="border p-2 h-28"
        />
      </div>

      <div className="flex justify-between mt-6">
        <button
          onClick={onBack}
          className="bg-gray-400 text-white px-4 py-2 rounded hover:bg-gray-500"
        >
          ← Regresar
        </button>
        <button
          onClick={handleSubmit}
          className="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700"
        >
          Enviar Solicitud
        </button>
      </div>
    </div>
  );
};

export default FormularioInclusionPg2;
