-- *********** Update salud_mental_estatus *****************************************
-- ---- Ascending Order ------------------------------------------
UPDATE tmp 
SET index_asc = x.index_asc
FROM salud_mental_estatus tmp INNER JOIN (
SELECT patient_id,resultado_salud_mental_fecha, int_rank,
rank() over(PARTITION BY patient_id ORDER BY patient_id asc, resultado_salud_mental_fecha asc, int_rank asc) index_asc
FROM salud_mental_estatus ) x 
ON tmp.patient_id=x.patient_id 
AND tmp.resultado_salud_mental_fecha = x.resultado_salud_mental_fecha 
AND tmp.int_rank=x.int_rank;
-- -------- Descending Order -------------------------------------------------- 
UPDATE tmp 
SET index_desc = x.index_desc
FROM salud_mental_estatus tmp INNER JOIN (
SELECT patient_id,resultado_salud_mental_fecha, int_rank,
rank() over(PARTITION BY patient_id ORDER BY patient_id asc, resultado_salud_mental_fecha desc, int_rank desc) index_desc
FROM salud_mental_estatus ) x 
ON tmp.patient_id=x.patient_id 
AND tmp.resultado_salud_mental_fecha = x.resultado_salud_mental_fecha 
AND tmp.int_rank=x.int_rank;

-- *********************************************************************************
-- *********** Update programas ****************************************************

UPDATE tmp 
SET index_asc = x.index_asc
FROM programas tmp INNER JOIN (
SELECT emr_id,fecha_inscrito,program_id,date_created,
rank() over(PARTITION BY emr_id ORDER BY emr_id asc, fecha_inscrito asc, program_id asc, date_created asc) index_asc
FROM programas) x 
ON tmp.emr_id=x.emr_id 
AND tmp.fecha_inscrito = x.fecha_inscrito 
AND tmp.program_id=x.program_id
AND tmp.date_created=x.date_created;

UPDATE tmp 
SET index_desc = x.index_desc
FROM programas tmp INNER JOIN (
SELECT emr_id,fecha_inscrito,program_id,date_created,
rank() over(PARTITION BY emr_id ORDER BY emr_id asc, fecha_inscrito desc, program_id desc, date_created desc) index_desc
FROM programas) x 
ON tmp.emr_id=x.emr_id 
AND tmp.fecha_inscrito = x.fecha_inscrito 
AND tmp.program_id=x.program_id
AND tmp.date_created=x.date_created;
-- *********************************************************************************
-- *********** Update visitas ******************************************************

UPDATE tmp 
SET index_asc = x.index_asc
FROM visitas tmp INNER JOIN (
SELECT emr_id,visita_fecha_inicio,visita_id,
rank() over(PARTITION BY emr_id ORDER BY emr_id asc, visita_fecha_inicio asc, visita_id asc) index_asc
FROM visitas) x 
ON tmp.emr_id=x.emr_id 
AND tmp.visita_fecha_inicio = x.visita_fecha_inicio 
AND tmp.visita_id=x.visita_id;

UPDATE tmp 
SET index_desc = x.index_desc
FROM visitas tmp INNER JOIN (
SELECT emr_id,visita_fecha_inicio,visita_id,
rank() over(PARTITION BY emr_id ORDER BY emr_id asc, visita_fecha_inicio desc, visita_id desc) index_desc
FROM visitas) x 
ON tmp.emr_id=x.emr_id 
AND tmp.visita_fecha_inicio = x.visita_fecha_inicio 
AND tmp.visita_id=x.visita_id;

-- *********************************************************************************
-- *********** Update encountero_consluta ******************************************

UPDATE tmp 
SET index_asc = x.index_asc
FROM encuentro_consulta tmp INNER JOIN (
SELECT emrid,encuentro_fecha,encuentro_id,
rank() over(PARTITION BY emrid ORDER BY emrid asc, encuentro_fecha asc, encuentro_id asc) index_asc
FROM encuentro_consulta) x 
ON tmp.emrid=x.emrid 
AND tmp.encuentro_fecha = x.encuentro_fecha 
AND tmp.encuentro_id=x.encuentro_id;

UPDATE tmp 
SET index_desc = x.index_desc
FROM encuentro_consulta tmp INNER JOIN (
SELECT emrid,encuentro_fecha,encuentro_id,
rank() over(PARTITION BY emrid ORDER BY emrid asc, encuentro_fecha desc, encuentro_id desc) index_desc
FROM encuentro_consulta) x 
ON tmp.emrid=x.emrid 
AND tmp.encuentro_fecha = x.encuentro_fecha 
AND tmp.encuentro_id=x.encuentro_id;

-- *********************************************************************************
-- *********** Update medicamentos *************************************************

UPDATE tmp 
SET index_asc = x.index_asc
FROM medicamentos tmp INNER JOIN (
SELECT encuentro_id,medicamento_nombre,
rank() over(PARTITION BY encuentro_id ORDER BY encuentro_id asc, medicamento_nombre asc, encuentro_fecha asc) index_asc
FROM medicamentos) x 
ON tmp.encuentro_id=x.encuentro_id
AND tmp.medicamento_nombre = x.medicamento_nombre;

UPDATE tmp 
SET index_desc = x.index_desc
FROM medicamentos tmp INNER JOIN (
SELECT encuentro_id,medicamento_nombre,
rank() over(PARTITION BY encuentro_id ORDER BY encuentro_id desc, medicamento_nombre desc, encuentro_fecha desc) index_desc
FROM medicamentos) x 
ON tmp.encuentro_id=x.encuentro_id
AND tmp.medicamento_nombre = x.medicamento_nombre;

-- *********************************************************************************
-- *********** Update encountero_signos_vitales ************************************
            
UPDATE tmp 
SET index_asc = x.index_asc
FROM encuentro_signos_vitales tmp INNER JOIN (
SELECT emr_id, all_vitals_id, encuentro_fecha, entrada_fecha,
rank() over(PARTITION BY emr_id ORDER BY emr_id asc, encuentro_fecha asc, entrada_fecha asc, all_vitals_id asc) index_asc
FROM encuentro_signos_vitales) x 
ON tmp.emr_id=x.emr_id 
AND tmp.all_vitals_id = x.all_vitals_id 
AND tmp.encuentro_fecha=x.encuentro_fecha
AND tmp.entrada_fecha=x.entrada_fecha;

UPDATE tmp 
SET index_desc = x.index_desc
FROM encuentro_signos_vitales tmp INNER JOIN (
SELECT emr_id, all_vitals_id, encuentro_fecha, entrada_fecha,
rank() over(PARTITION BY emr_id ORDER BY emr_id asc, encuentro_fecha desc, entrada_fecha desc, all_vitals_id desc) index_desc
FROM encuentro_signos_vitales) x 
ON tmp.emr_id=x.emr_id 
AND tmp.all_vitals_id = x.all_vitals_id 
AND tmp.encuentro_fecha=x.encuentro_fecha
AND tmp.entrada_fecha=x.entrada_fecha;
