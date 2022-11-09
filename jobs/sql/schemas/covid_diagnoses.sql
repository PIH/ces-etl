CREATE TABLE covid_diagnoses
(
  paciente_id             INT,
  encuentro_id            INT,
  tipo_encuentro          VARCHAR(255),
  ubicacion               TEXT,
  encuentro_fecha         DATE,
  orden_diagnóstico       TEXT,
  diagnostico             TEXT,
  diagnosis_confirmacion  TEXT,
  covid19_diagnostico     VARCHAR(255)
);
