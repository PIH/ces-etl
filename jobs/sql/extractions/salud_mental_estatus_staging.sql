SET @partition = '${partitionNum}';

SELECT program_id INTO @program_id FROM program p WHERE uuid='0e69c3ab-1ccb-430b-b0db-b9760319230f';
select patient_identifier_type_id into @identifier_type from patient_identifier_type pit where uuid ='506add39-794f-11e8-9bcd-74e5f916c5ec';
select encounter_type_id into @reg_encounter from encounter_type et where uuid='873f968a-73a8-4f9c-ac78-9f4778b751b6';
select encounter_type_id into @consult_encounter from encounter_type et where uuid='aa61d509-6e76-4036-a65d-7813c0c3b752';

SELECT concept_id INTO @lost_followup FROM concept WHERE uuid='3ceb0ed8-26fe-102b-80cb-0017a47871b2';
SELECT concept_id INTO @muerte FROM concept WHERE uuid='3cdd446a-26fe-102b-80cb-0017a47871b2';
SELECT concept_id INTO @transfered FROM concept WHERE uuid='3cdd5c02-26fe-102b-80cb-0017a47871b2';
SELECT concept_id INTO @patient_refused FROM concept WHERE uuid='efab937b-853e-47da-b97e-220f1bdff97d';
SELECT concept_id INTO @completed FROM concept WHERE uuid='3cdcecea-26fe-102b-80cb-0017a47871b2';

SELECT @program_id

DROP TABLE IF EXISTS salud_mental_estatus;
CREATE TEMPORARY TABLE salud_mental_estatus (
patient_id int,
person_uuid char(38),
emr_id varchar(30),
patient_program_uuid char(38),
date_changed date,
emr_instancia varchar(30),
resultado_salud_mental text,
int_rank int,
resultado_salud_mental_fecha datetime,
index_asc int,
index_desc int);

drop table if exists tmp_patient_identifier_v2;
CREATE table tmp_patient_identifier_v2 AS
SELECT DISTINCT patient_id,identifier
FROM  patient_identifier
where voided = 0 
and identifier_type = @identifier_type
GROUP BY patient_id;

truncate table salud_mental_estatus;


insert into salud_mental_estatus (patient_id, emr_id, emr_instancia, resultado_salud_mental, int_rank,resultado_salud_mental_fecha, patient_program_uuid, date_changed)
SELECT distinct pp.patient_id,pi2.identifier 'emr_id', l.name 'emr_instancia',
	  'inscrito' as 'resultado_salud_mental' , 1 as int_rank, date_enrolled  'resultado_salud_mental_fecha',
	  pp.uuid AS patient_program_uuid, pp.date_changed
FROM patient_program pp 
inner join tmp_patient_identifier_v2 pi2 on pi2.patient_id = pp.patient_id  
left outer join location l on pp.location_id =l.location_id 
WHERE program_id =@program_id
union all
SELECT DISTINCT pp.patient_id,pi2.identifier 'emr_id', l.name 'emr_instancia',
	  cn.name as 'resultado_salud_mental' , 
	  case when cn.concept_id =@lost_followup then 2
	  when cn.concept_id =@transfered then 3
	  when cn.concept_id =@patient_refused then 4
	  when cn.concept_id =@completed then 5
	  when cn.concept_id =@muerte then 6 end as int_rank,
	  date_completed  'resultado_salud_mental_fecha',
	  pp.uuid AS patient_program_uuid, pp.date_changed
FROM patient_program pp 
inner join tmp_patient_identifier_v2 pi2 on pi2.patient_id = pp.patient_id  
left outer join location l on pp.location_id =l.location_id 
left outer join concept_name cn on pp.outcome_concept_id =cn.concept_id 
WHERE program_id =@program_id and outcome_concept_id is not null 
and cn.locale ='en'
and cn.voided =0 and cn.concept_name_type='FULLY_SPECIFIED'
;


update salud_mental_estatus t 
set t.emr_instancia = (
	select l.name
	from encounter e inner join location l
	on e.location_id = l.location_id 
	where e.patient_id = t.patient_id
	and cast(e.encounter_datetime as date) = cast(t.resultado_salud_mental_fecha as date)
	and e.encounter_type  in (@reg_encounter,@consult_encounter)
	limit 1
)
where t.emr_instancia is null;

-- ---- Ascending Order ------------------------------------------
drop table if exists int_asc;
create table int_asc
select DISTINCT s.* from salud_mental_estatus s
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
   
--    SELECT * FROM asc_order WHERE patient_id =39
--     GROUP BY patient_id,resultado_salud_mental_fecha,int_rank
--  HAVING count(*) > 1
--  
   
update salud_mental_estatus es
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
select * from salud_mental_estatus
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
    
update salud_mental_estatus es
set es.index_desc = (
 select index_desc
 from desc_order
 where patient_id=es.patient_id 
 and resultado_salud_mental_fecha=es.resultado_salud_mental_fecha
 and int_rank=es.int_rank
 AND patient_program_uuid=es.patient_program_uuid
);

-- -----------------------------------------

UPDATE salud_mental_estatus sm 
INNER JOIN (
	SELECT DISTINCT p2.person_id, 
	uuid
	FROM person p2
) x ON sm.patient_id =x.person_id
SET sm.person_uuid = x.uuid;


-- -----------------------------------------

select 
distinct 
CONCAT(@partition,'-',emr_id) "emr_id" ,
person_uuid,
patient_program_uuid,
date_changed,
emr_instancia,
resultado_salud_mental,
resultado_salud_mental_fecha,
index_asc,
index_desc
from salud_mental_estatus
order by patient_id desc,resultado_salud_mental_fecha desc, index_desc asc;