SELECT program_id INTO @program_id FROM program p WHERE uuid='0e69c3ab-1ccb-430b-b0db-b9760319230f';
set @dbname = '${partitionNum}';

DROP TABLE IF EXISTS salud_mental_estatus;
CREATE TEMPORARY TABLE salud_mental_estatus (
dbname varchar(30),
patient_id int,
emr_id varchar(30),
emr_instancia varchar(30),
resultado_salud_mental varchar(30),
resultado_salud_mental_fecha date);

CREATE OR REPLACE VIEW patient_identifier_v2 AS
SELECT DISTINCT patient_id,identifier
FROM  patient_identifier
where voided = 0 
and identifier_type = 4
GROUP BY patient_id;

truncate table salud_mental_estatus;

insert into salud_mental_estatus (patient_id, emr_id, emr_instancia, resultado_salud_mental, resultado_salud_mental_fecha)
SELECT distinct pp.patient_id,pi2.identifier 'emr_id', l.name 'emr_instancia',
	  'inscrito' as 'resultado_salud_mental' , cast(date_enrolled as date)  'resultado_salud_mental_fecha'
FROM patient_program pp 
left outer join patient_identifier_v2 pi2 on pi2.patient_id = pp.patient_id  
left outer join location l on pp.location_id =l.location_id 
WHERE program_id =@program_id and outcome_concept_id is null 
union all
SELECT DISTINCT pp.patient_id,pi2.identifier 'emr_id', l.name 'emr_instancia',
	  cn.name as 'resultado_salud_mental' , cast(date_enrolled as date)  'resultado_salud_mental_fecha'
FROM patient_program pp 
left outer join patient_identifier_v2 pi2 on pi2.patient_id = pp.patient_id  
left outer join location l on pp.location_id =l.location_id 
left outer join concept_name cn on pp.outcome_concept_id =cn.concept_id 
WHERE program_id =@program_id and outcome_concept_id is not null 
and cn.locale ='en'
and cn.voided =0 and cn.concept_name_type='FULLY_SPECIFIED'
;


update salud_mental_estatus t
set t.dbname=@dbname;


select 
distinct 
dbname,
patient_id,
emr_id,
emr_instancia,
resultado_salud_mental,
resultado_salud_mental_fecha
from salud_mental_estatus;
	
	