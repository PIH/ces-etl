SET @partition = '${partitionNum}';
set @site = '${siteName}';

SELECT program_id INTO @mh_program_id FROM program p WHERE uuid='0e69c3ab-1ccb-430b-b0db-b9760319230f';


SELECT concept_from_mapping('PIH','5240') INTO @lost_followup;
SELECT concept_from_mapping('PIH','1742') INTO @muerte;
SELECT concept_from_mapping('PIH','1744') INTO @transfered;
SELECT concept_from_mapping('PIH','3580') INTO @patient_refused;
SELECT concept_from_mapping('PIH','1574') INTO @patient_refused_2;
SELECT concept_from_mapping('PIH','1714') INTO @completed;


DROP TABLE IF EXISTS salud_mental_estatus;
CREATE TEMPORARY TABLE salud_mental_estatus (
patient_id int,
site varchar(25),
person_uuid char(38),
emr_id varchar(30),
patient_program_uuid char(38),
date_changed date,
emr_instancia varchar(30),
resultado_salud_mental text,
int_rank int,
resultado_salud_mental_fecha datetime,
index_asc int,
index_desc int
);

insert into salud_mental_estatus (site,patient_id, emr_id, person_uuid, emr_instancia, resultado_salud_mental, 
								  int_rank,resultado_salud_mental_fecha, patient_program_uuid, date_changed)
SELECT DISTINCT @site, pp.patient_id, patient_identifier(patient_id, '506add39-794f-11e8-9bcd-74e5f916c5ec') 'emr_id', p.uuid,
               initialProgramLocation(patient_id,@mh_program_id) 'emr_instancia', 'Inscrito' as 'resultado_salud_mental' ,
               1 as int_rank, pp.date_enrolled  'resultado_salud_mental_fecha', 
               pp.uuid AS patient_program_uuid, pp.date_changed
FROM patient_program pp 
INNER JOIN person p ON pp.patient_id =p.person_id 
WHERE program_id =@mh_program_id and pp.voided = 0 and p.voided=0
union all
SELECT DISTINCT @site, pp.patient_id, patient_identifier(patient_id, '506add39-794f-11e8-9bcd-74e5f916c5ec') 'emr_id',  p.uuid,
              initialProgramLocation(patient_id,@mh_program_id) 'emr_instancia',
			  concept_name(pp.outcome_concept_id,'es') as 'resultado_salud_mental' ,
			  case when pp.outcome_concept_id =@lost_followup then 2
			  when pp.outcome_concept_id =@transfered then 3
			  when (pp.outcome_concept_id =@patient_refused or pp.outcome_concept_id =@patient_refused_2) then 4
			  when pp.outcome_concept_id =@completed then 5
			  when pp.outcome_concept_id =@muerte then 6 end as int_rank,
			  date_completed  'resultado_salud_mental_fecha',
			  pp.uuid AS patient_program_uuid, pp.date_changed
FROM patient_program pp 
INNER JOIN person p ON pp.patient_id =p.person_id and pp.voided = 0 and p.voided=0
WHERE program_id =@mh_program_id and outcome_concept_id is not null 
;

update salud_mental_estatus t 
set t.emr_instancia = loc_registered(t.patient_id)
where t.emr_instancia is null;

-- -----------------------------------------

select 
distinct 
patient_id,
CONCAT(@partition,'-',emr_id) "emr_id" ,
person_uuid,
patient_program_uuid,
date_changed,
emr_instancia,
resultado_salud_mental,
resultado_salud_mental_fecha,
int_rank,
index_asc,
index_desc
from salud_mental_estatus
order by patient_id desc,resultado_salud_mental_fecha desc, index_desc asc;
