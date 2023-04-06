-- *********** Update salud_mental_estatus *****************************************
-- ---- Ascending Order ------------------------------------------
UPDATE tmp 
SET index_asc = x.index_asc
FROM salud_mental_estatus_tmp tmp INNER JOIN (
SELECT patient_id,resultado_salud_mental_fecha, int_rank,
rank() over(PARTITION BY patient_id ORDER BY patient_id asc, resultado_salud_mental_fecha asc, int_rank asc) index_asc
FROM salud_mental_estatus_tmp ) x 
ON tmp.patient_id=x.patient_id 
AND tmp.resultado_salud_mental_fecha = x.resultado_salud_mental_fecha 
AND tmp.int_rank=x.int_rank;
-- -------- Descending Order -------------------------------------------------- 
UPDATE tmp 
SET index_desc = x.index_desc
FROM salud_mental_estatus_tmp tmp INNER JOIN (
SELECT patient_id,resultado_salud_mental_fecha, int_rank,
rank() over(PARTITION BY patient_id ORDER BY patient_id asc, resultado_salud_mental_fecha desc, int_rank desc) index_desc
FROM salud_mental_estatus_tmp ) x 
ON tmp.patient_id=x.patient_id 
AND tmp.resultado_salud_mental_fecha = x.resultado_salud_mental_fecha 
AND tmp.int_rank=x.int_rank;

DROP TABLE IF EXISTS salud_mental_estatus;
select  
emr_id ,
site,
person_uuid,
patient_program_uuid,
date_changed,
emr_instancia,
resultado_salud_mental,
resultado_salud_mental_fecha,
index_asc,
index_desc
into salud_mental_estatus
from salud_mental_estatus_tmp;
-- *********************************************************************************
-- *********** Update programas ****************************************************

UPDATE tmp 
SET index_asc = x.index_asc
FROM programas_tmp tmp INNER JOIN (
SELECT emr_id,fecha_inscrito,program_id,date_created,
rank() over(PARTITION BY emr_id ORDER BY emr_id asc, fecha_inscrito asc, program_id asc, date_created asc) index_asc
FROM programas_tmp) x 
ON tmp.emr_id=x.emr_id 
AND tmp.fecha_inscrito = x.fecha_inscrito 
AND tmp.program_id=x.program_id
AND tmp.date_created=x.date_created;

UPDATE tmp 
SET index_desc = x.index_desc
FROM programas_tmp tmp INNER JOIN (
SELECT emr_id,fecha_inscrito,program_id,date_created,
rank() over(PARTITION BY emr_id ORDER BY emr_id asc, fecha_inscrito desc, program_id desc, date_created desc) index_desc
FROM programas_tmp) x 
ON tmp.emr_id=x.emr_id 
AND tmp.fecha_inscrito = x.fecha_inscrito 
AND tmp.program_id=x.program_id
AND tmp.date_created=x.date_created;

DROP TABLE IF EXISTS programas;
select 
emr_id,
site,
person_uuid,
patient_program_uuid,
emr_instancia,
programa,
hearts,
hearts_fecha,
fecha_inscrito,
fecha_salida,
estatus,
last_updated,
index_asc,
index_desc,
program_id,
date_created
INTO programas
from programas_tmp;

-- *********************************************************************************
-- *********** Update visitas ****************************************************
UPDATE tmp 
SET index_asc = x.index_asc
FROM visitas_tmp tmp INNER JOIN (
SELECT emr_id,visita_fecha_inicio,visita_id,
rank() over(PARTITION BY emr_id ORDER BY emr_id asc, visita_fecha_inicio asc, visita_id asc) index_asc
FROM visitas_tmp) x 
ON tmp.emr_id=x.emr_id 
AND tmp.visita_fecha_inicio = x.visita_fecha_inicio 
AND tmp.visita_id=x.visita_id;

UPDATE tmp 
SET index_desc = x.index_desc
FROM visitas_tmp tmp INNER JOIN (
SELECT emr_id,visita_fecha_inicio,visita_id,
rank() over(PARTITION BY emr_id ORDER BY emr_id asc, visita_fecha_inicio desc, visita_id desc) index_desc
FROM visitas_tmp) x 
ON tmp.emr_id=x.emr_id 
AND tmp.visita_fecha_inicio = x.visita_fecha_inicio 
AND tmp.visita_id=x.visita_id;

DROP TABLE IF EXISTS visitas;
select 
emr_id,
person_uuid,
visit_id,
visit_uuid,
visit_date_started,
visit_date_stopped,
visit_date_entered,
visit_user_entered,
visit_type,
visit_location,
index_asc,
index_desc
INTO visitas
from visitas_tmp;


-- *********************************************************************************
-- *********** Update encountero_consluta ****************************************************

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

-- *********** Update encountero_signos_vitales ****************************************************


            
UPDATE tmp 
SET index_asc = x.index_asc
FROM encuentro_signos_vitales_tmp tmp INNER JOIN (
SELECT emr_id, all_vitals_id, encuentro_fecha, entrada_fecha,
rank() over(PARTITION BY emr_id ORDER BY emr_id asc, all_vitals_id ASC, encuentro_fecha asc, entrada_fecha asc) index_asc
FROM encuentro_signos_vitales_tmp) x 
ON tmp.emr_id=x.emr_id 
AND tmp.all_vitals_id = x.all_vitals_id 
AND tmp.encuentro_fecha=x.encuentro_fecha
AND tmp.entrada_fecha=x.entrada_fecha;

UPDATE tmp 
SET index_desc = x.index_desc
FROM encuentro_signos_vitales_tmp tmp INNER JOIN (
SELECT emr_id, all_vitals_id, encuentro_fecha, entrada_fecha,
rank() over(PARTITION BY emr_id ORDER BY emr_id asc, all_vitals_id desc, encuentro_fecha desc, entrada_fecha desc) index_desc
FROM encuentro_signos_vitales_tmp) x 
ON tmp.emr_id=x.emr_id 
AND tmp.all_vitals_id = x.all_vitals_id 
AND tmp.encuentro_fecha=x.encuentro_fecha
AND tmp.entrada_fecha=x.entrada_fecha;


DROP TABLE IF EXISTS encuentro_signos_vitales;
select 
	emr_id,
    site,
	person_uuid,
	visita_id,
	encuentro_id,
	encounter_uuid,
	emr_instancia,
	encuentro_fecha,
	proveedor,
	entrada_fecha,
	entrada_persona,
    talla,
    peso,
    imc,
    presion_sistolica,
    presion_diastolica,
    sat_o2,
    ayuno,
    glucosa,
    temperatura,
    frecuencia_cardiaca,
    frecuencia_respiratoria,
    phq2,
    gad2,
    molestia_principal,
    index_asc,
    index_desc
    INTO encuentro_signos_vitales
    FROM encuentro_signos_vitales_tmp;

-- *********************************************************************************

