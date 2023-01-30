SET @locale = GLOBAL_PROPERTY_VALUE('default_locale', 'en');
SET @partition = '${partitionNum}';

DROP TEMPORARY TABLE IF EXISTS temp_diagnoses;
CREATE TEMPORARY TABLE temp_diagnoses
(
    patient_id				int(11),
	emr_id 					varchar(50),
	visit_id				int(11),
 	encounter_id			int(11),
 	obs_uuid 		 		char(38),
 	person_uuid				char(38),
	obs_id					int(11),
	encounter_location	 	varchar(255),
	encounter_datetime		datetime,
	encounter_type 			varchar(255),
	date_created			datetime,
	user_entered			varchar(255),
	coded_dx_concept_id		int(11),
	coded_diagnosis			varchar(255),
	icd_10_code				varchar(255),
	non_coded_diagnosis		varchar(255),
	primary_diagnosis		bit,
	first_time				bit
);	

insert into temp_diagnoses (
	patient_id,
	emr_id,
	encounter_id,
	obs_id,
	obs_uuid,
	date_created
)
select 
	o.person_id,
	patient_identifier(o.person_id,'506add39-794f-11e8-9bcd-74e5f916c5ec'),
	o.encounter_id,
	o.obs_id,
	o.uuid,
	o.date_created 
from obs o 
where concept_id = concept_from_mapping('PIH','Visit Diagnoses')
AND o.voided = 0
;

create index temp_diagnoses_e on temp_diagnoses(encounter_id);
create index temp_diagnoses_p on temp_diagnoses(patient_id);

-- encounter level information
DROP TEMPORARY TABLE IF EXISTS temp_dx_encounter;
CREATE TEMPORARY TABLE temp_dx_encounter
(
   	patient_id					int(11),
   	visit_id					int(11),
	encounter_id				int(11),
	obs_uuid					char(38),
	encounter_location			varchar(255),
	encounter_datetime			datetime,
	user_entered				varchar(255),
	encounter_type 				varchar(255)
    );
   
insert into temp_dx_encounter(patient_id,encounter_id)
select distinct patient_id, encounter_id from temp_diagnoses;

create index temp_dx_encounter_e on temp_dx_encounter(encounter_id);

update temp_dx_encounter t
inner join encounter e on e.encounter_id = t.encounter_id
set t.user_entered = person_name_of_user(e.creator),
	t.encounter_type = encounter_type_name_from_id(e.encounter_type),
	t.encounter_datetime = e.encounter_datetime,
	t.encounter_location = location_name(location_id),
	t.visit_id = e.visit_id 
	;
	
update temp_diagnoses td
inner join temp_dx_encounter tde on tde.encounter_id = td.encounter_id
set td.encounter_datetime = tde.encounter_datetime,
	td.encounter_type = tde.encounter_type,
	td.user_entered = tde.user_entered,
	td.encounter_location = tde.encounter_location,
	td.visit_id = tde.visit_id
	;

 -- diagnosis info
DROP TEMPORARY TABLE IF EXISTS temp_obs;
create temporary table temp_obs 
select o.obs_id, o.obs_datetime ,o.obs_group_id , o.encounter_id, o.person_id, o.concept_id, o.value_coded, o.value_text, o.value_coded_name_id 
from obs o
inner join temp_diagnoses t on t.obs_id = o.obs_group_id
where o.voided = 0;

create index temp_obs_concept_id on temp_obs(concept_id);
create index temp_obs_ci1 on temp_obs(obs_group_id, concept_id);
       
 update temp_diagnoses t
 inner join temp_obs o on o.obs_group_id = t.obs_id and o.concept_id = concept_from_mapping('PIH','DIAGNOSIS')
 set coded_diagnosis = concept_name(o.value_coded,@locale),
	coded_dx_concept_id = o.value_coded;

 update temp_diagnoses t
 inner join temp_obs o on o.obs_group_id = t.obs_id and o.concept_id = concept_from_mapping('PIH','Diagnosis or problem, non-coded')
 set non_coded_diagnosis = o.value_text,
	coded_diagnosis = 'Diagnóstico sin codificación';

update temp_diagnoses t
inner join temp_obs o on o.obs_group_id = t.obs_id and o.concept_id = concept_from_mapping( 'PIH','7537') and o.value_coded = concept_from_mapping( 'PIH','7534')
set t.primary_diagnosis = 1;

update temp_diagnoses t
inner join temp_obs o on o.obs_group_id = t.obs_id and o.concept_id = concept_from_mapping( 'PIH','1379') and o.value_coded = concept_from_mapping( 'PIH','1345')
set t.first_time = 1;

update temp_diagnoses set icd_10_code = retrieveICD10(coded_dx_concept_id);

update temp_diagnoses t 
inner join person p on p.person_id = t.patient_id
set t.person_uuid = p.uuid;

select 
CONCAT(@partition,'-',emr_id) "emr_id",
person_uuid,
CONCAT(@partition,'-',visit_id) "visit_id",
CONCAT(@partition,'-',encounter_id) "encounter_id",
obs_uuid,
CONCAT(@partition,'-',obs_id) "obs_id",
encounter_location,
encounter_datetime,
encounter_type,
date_created,
user_entered,
coded_diagnosis,
icd_10_code,
non_coded_diagnosis,
primary_diagnosis,
first_time
from temp_diagnoses;
