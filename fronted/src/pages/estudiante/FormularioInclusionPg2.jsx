import React, { useState } from 'react';

const FormularioInclusionPg2 = ({ formData, onBack, onSubmit }) => {
  const [datos, setDatos] = useState({
    cursos_logrados: '',
    intentos: '',
    estado_rn: '',
    detalle_rn: '',
    correquisitos_aprobados: '',
    motivo: ''
  });

  const handleChange = (e) => {
    const { name, value } = e.target;
    setDatos(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = () => {
    onSubmit({ ...formData, ...datos });
  };

  return (
    <div className="p-6 max-w-5xl mx-auto bg-gray-100 rounded">
      <h2 className="text-xl font-bold mb-6 text-[#003366]">Formulario de Inclusión</h2>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label>¿Cuáles cursos logró matricular?</label>
          <input
            name="cursos_logrados"
            value={datos.cursos_logrados}
            onChange={handleChange}
            className="w-full border rounded p-2"
          />
        </div>

        <div>
          <label>Explique brevemente su razón de la solicitud</label>
          <textarea
            name="motivo"
            value={datos.motivo}
            onChange={handleChange}
            className="w-full border rounded p-2 h-28"
          />
        </div>

        <div>
          <label>¿Cuántas veces ha intentado matricular el curso?</label>
          <input
            name="intentos"
            value={datos.intentos}
            onChange={handleChange}
            className="w-full border rounded p-2"
          />
        </div>

        <div>
          <label>¿Ha aprobado los correquisitos del Curso?</label>
          <select
            name="correquisitos_aprobados"
            value={datos.correquisitos_aprobados}
            onChange={handleChange}
            className="w-full border rounded p-2"
          >
            <option value="">Seleccione una opción</option>
            <option value="sí">Sí</option>
            <option value="no">No</option>
          </select>
        </div>

        <div>
          <label>¿Presenta estado RN en el curso?</label>
          <select
            name="estado_rn"
            value={datos.estado_rn}
            onChange={handleChange}
            className="w-full border rounded p-2"
          >
            <option value="">Seleccione una opción</option>
            <option value="sí">Sí</option>
            <option value="no">No</option>
          </select>
        </div>

        <div>
          <label>Si marcó sí, indique el estado RN que presenta</label>
          <input
            name="detalle_rn"
            value={datos.detalle_rn}
            onChange={handleChange}
            className="w-full border rounded p-2"
          />
        </div>
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
          className="bg-green-600 text-white px-6 py-2 rounded hover:bg-green-700"
        >
          Finalizar solicitud →
        </button>
      </div>
    </div>
  );
};

export default FormularioInclusionPg2;
