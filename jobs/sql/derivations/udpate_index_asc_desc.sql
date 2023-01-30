-- *********** Update salud_mental_estatus *****************************************
-- ---- Ascending Order ------------------------------------------
drop table if exists int_asc;
create table int_asc
select DISTINCT patient_id,resultado_salud_mental_fecha,int_rank, patient_program_uuid from salud_mental_estatus_tmp s
ORDER BY patient_id asc, resultado_salud_mental_fecha asc, int_rank asc;


set @row_number := 0;

DROP TABLE IF EXISTS asc_order;
CREATE TABLE asc_order
SELECT 
    @row_number:=CASE
        WHEN @patient_id = patient_id 
			THEN @row_number + 1
        ELSE 1
    END AS index_asc,
    @patient_id:=patient_id patient_id,
    resultado_salud_mental_fecha,int_rank, patient_program_uuid
FROM
    int_asc;
    
update salud_mental_estatus_tmp es
set es.index_asc = (
 select DISTINCT index_asc
 from asc_order
 where patient_id= es.patient_id 
 and resultado_salud_mental_fecha=es.resultado_salud_mental_fecha
 and int_rank=es.int_rank
 AND patient_program_uuid=es.patient_program_uuid
);

-- -------- Descending Order --------------------------------------------------    
drop table if exists int_desc;
create table int_desc
select distinct patient_id,resultado_salud_mental_fecha,int_rank, patient_program_uuid 
from salud_mental_estatus_tmp
ORDER BY patient_id asc, resultado_salud_mental_fecha desc, int_rank desc;

DROP TABLE IF EXISTS desc_order;
CREATE TABLE desc_order
SELECT 
    @row_number:=CASE
        WHEN @patient_id = patient_id 
			THEN @row_number + 1
        ELSE 1
    END AS index_desc,
    @patient_id:=patient_id patient_id,
    resultado_salud_mental_fecha,int_rank, patient_program_uuid
FROM
    int_desc;
    
update salud_mental_estatus_tmp es
set es.index_desc = (
 select index_desc
 from desc_order
 where patient_id=es.patient_id 
 and resultado_salud_mental_fecha=es.resultado_salud_mental_fecha
 and int_rank=es.int_rank
 AND patient_program_uuid=es.patient_program_uuid
);

drop table if exists salud_mental_estatus;
select 
distinct 
emr_id,
person_uuid,
patient_program_uuid,
date_changed,
emr_instancia,
resultado_salud_mental,
resultado_salud_mental_fecha,
index_asc,
index_desc
from salud_mental_estatus_tmp
into salud_mental_estatus;


-- *********************************************************************************
-- *********** Update programas ****************************************************

-- ---- Ascending Order ------------------------------------------

drop table if exists int_asc;
create table int_asc
select * from programas vs 
ORDER BY emr_id asc, date_enrolled asc, program_id asc, date_created asc;

set @row_number := 0;
DROP TABLE IF EXISTS asc_order;
CREATE TABLE asc_order
SELECT 
    @row_number:=CASE
        WHEN @emr_id = emr_id  
			THEN @row_number + 1
        ELSE 1
    END AS index_asc,
    @emr_id:=emr_id  emr_id,
    date_enrolled,program_id,date_created
FROM
    int_asc;
   
update programas es
set es.index_asc = (
 select distinct index_asc 
 from asc_order
 where emr_id=es.emr_id 
 and date_enrolled=es.date_enrolled
 and program_id=es.program_id
 and date_created=es.date_created
);
    

-- ---- Descending Order ------------------------------------------

drop table if exists int_desc;
create table int_desc
select * from programas vs 
ORDER BY emr_id asc, date_enrolled desc, program_id desc, date_created desc;

set @row_number := 0;
DROP TABLE IF EXISTS desc_order;
CREATE TABLE desc_order
SELECT 
    @row_number:=CASE
        WHEN @emr_id = emr_id  
			THEN @row_number + 1
        ELSE 1
    END AS index_desc,
    @emr_id:=emr_id  emr_id,
    date_enrolled,program_id,date_created
FROM
    int_desc;
   
update programas es
set es.index_desc = (
 select distinct index_desc 
 from desc_order
 where emr_id= es.emr_id 
 and date_enrolled=es.date_enrolled
 and program_id=es.program_id
 and date_created=es.date_created
);

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

