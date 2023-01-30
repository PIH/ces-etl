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
SELECT emr_id,date_enrolled,program_id,date_created,
rank() over(PARTITION BY emr_id ORDER BY emr_id asc, fecha_inscrito asc, program_id asc, date_created asc) index_asc
FROM programas_tmp) x 
ON tmp.emr_id=x.emr_id 
AND tmp.fecha_inscrito = x.fecha_inscrito 
AND tmp.program_id=x.program_id
AND tmp.date_created=x.date_created;

UPDATE tmp 
SET index_desc = x.index_desc
FROM programas_tmp tmp INNER JOIN (
SELECT emr_id,date_enrolled,program_id,date_created,
rank() over(PARTITION BY emr_id ORDER BY emr_id asc, fecha_inscrito desc, program_id desc, date_created desc) index_desc
FROM programas_tmp) x 
ON tmp.emr_id=x.emr_id 
AND tmp.fecha_inscrito = x.fecha_inscrito 
AND tmp.program_id=x.program_id
AND tmp.date_created=x.date_created;

DROP TABLE IF EXISTS programas;
select 
emr_id,
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
INTO programas_tmp
from programas;

-- *********************************************************************************
-- *********** Update encountero_consluta ****************************************************
--  index ascending
drop temporary table if exists temp_consult_index_asc;
CREATE TEMPORARY TABLE temp_consult_index_asc
(
    SELECT
            patient_id,
            encounter_date,
            encounter_id,
            index_asc
FROM (SELECT
            @r:= IF(@u = patient_id, @r + 1,1) index_asc,
            encounter_date,
            encounter_id,
            patient_id,
            @u:= patient_id
      FROM encuentro_consulta,
                    (SELECT @r:= 1) AS r,
                    (SELECT @u:= 0) AS u
            ORDER BY patient_id, encounter_date ASC, encounter_id ASC
        ) index_ascending );

CREATE INDEX tvia_e ON temp_consult_index_asc(encounter_id);

update encuentro_consulta t
inner join temp_consult_index_asc tvia on tvia.encounter_id = t.encounter_id
set t.index_asc = tvia.index_asc;

drop temporary table if exists temp_consult_index_desc;
CREATE TEMPORARY TABLE temp_consult_index_desc
(
    SELECT
            patient_id,
            encounter_date,
            encounter_id,
            index_desc
FROM (SELECT
            @r:= IF(@u = patient_id, @r + 1,1) index_desc,
            encounter_date,
            encounter_id,
            patient_id,
            @u:= patient_id
      FROM encuentro_consulta,
                    (SELECT @r:= 1) AS r,
                    (SELECT @u:= 0) AS u
            ORDER BY patient_id, encounter_date DESC, encounter_id DESC
        ) index_descending );

CREATE INDEX tvia_e ON temp_consult_index_desc(encounter_id);

update encuentro_consulta t
inner join temp_consult_index_desc tvid on tvid.encounter_id = t.encounter_id
set t.index_desc = tvid.index_desc;

-- *********************************************************************************

-- *********** Update encountero_signos_vitales ****************************************************
-- The indexes are calculated using the ecnounter_date
-- index ascending
DROP TEMPORARY TABLE IF EXISTS temp_vitals_index_asc;
CREATE TEMPORARY TABLE temp_vitals_index_asc
(
    SELECT
            all_vitals_id,
    		emr_id,
            encounter_datetime,
            date_entered,
            index_asc
FROM (SELECT
            @r:= IF(@u = emr_id, @r + 1,1) index_asc,
            encounter_datetime,
            date_entered,
            all_vitals_id,
            emr_id,
            @u:= emr_id
      FROM encuentro_signos_vitales,
                    (SELECT @r:= 1) AS r,
                    (SELECT @u:= 0) AS u
            ORDER BY emr_id, encounter_datetime ASC, date_entered ASC
        ) index_ascending );

create index temp_vitals_index_asc_avi on temp_vitals_index_asc(all_vitals_id);

update encuentro_signos_vitales t
inner join temp_vitals_index_asc tvia on tvia.all_vitals_id = t.all_vitals_id
set t.index_asc = tvia.index_asc;

-- index descending
DROP TEMPORARY TABLE IF EXISTS temp_vitals_index_desc;
CREATE TEMPORARY TABLE temp_vitals_index_desc
(
    SELECT
            all_vitals_id,
    		emr_id,
            encounter_datetime,
            date_entered,
            index_desc
FROM (SELECT
            @r:= IF(@u = emr_id, @r + 1,1) index_desc,
            encounter_datetime,
            date_entered,
            all_vitals_id,
            emr_id,
            @u:= emr_id
      FROM encuentro_signos_vitales,
                    (SELECT @r:= 1) AS r,
                    (SELECT @u:= 0) AS u
            ORDER BY emr_id, encounter_datetime desc, date_entered desc
        ) index_descending );

create index temp_vitals_index_desc_avi on temp_vitals_index_desc(all_vitals_id);

update encuentro_signos_vitales t
inner join temp_vitals_index_desc tvid on tvid.all_vitals_id = t.all_vitals_id
set t.index_desc = tvid.index_desc;

-- *********************************************************************************

