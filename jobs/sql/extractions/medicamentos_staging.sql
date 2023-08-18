SET @locale = GLOBAL_PROPERTY_VALUE('default_locale', 'en');
SET @partition = '${partitionNum}';

DROP TEMPORARY TABLE IF EXISTS temp_medications;
CREATE TEMPORARY TABLE temp_medications
(
 patient_id           int(11), 
 person_uuid          char(38),
 emr_id               varchar(50),  
 obs_group_id         int(11),       
 encounter_id         int(11),    
 encounter_uuid       char(38),
 encounter_date       datetime,
 encounter_location   varchar(255),
 medication           varchar(255), 
 duration             double,       
 duration_units       varchar(255), 
 admin_inxs           text,         
 dose1_dose           double,       
 dose1_dose_units     varchar(255), 
 dose1_morning        boolean,      
 dose1_morning_text   varchar(255), 
 dose1_noon           boolean,      
 dose1_noon_text      varchar(255), 
 dose1_afternoon      boolean,      
 dose1_afternoon_text varchar(255),  
 dose1_evening        boolean,      
 dose1_evening_text   varchar(255), 
 dose2_dose           double,       
 dose2_dose_units     varchar(255), 
 dose2_morning        boolean,      
 dose2_morning_text   varchar(255), 
 dose2_noon           boolean,      
 dose2_noon_text      varchar(255), 
 dose2_afternoon      boolean,      
 dose2_afternoon_text varchar(255),  
 dose2_evening        boolean,      
 dose2_evening_text   varchar(255)  
);	

set @prescription_construct = concept_from_mapping('PIH','14822');

insert into temp_medications
	(patient_id,
	encounter_id,
	obs_group_id)
select 
	o.person_id,
	o.encounter_id ,
	o.obs_id
from obs o 
where concept_id = @prescription_construct
and o.voided = 0
;

update temp_medications t
inner join encounter e on t.encounter_id = e.encounter_id 
set encounter_location = location_name(e.location_id),
	encounter_uuid = uuid,
	encounter_date = e.encounter_datetime ;

update temp_medications t
inner join person p on t.patient_id = p.person_id 
set person_uuid = p.uuid;

update temp_medications
set emr_id = patient_identifier(patient_id,'506add39-794f-11e8-9bcd-74e5f916c5ec');

update temp_medications t
set medication = obs_from_group_id_value_drug(t.obs_group_id, 'PIH','1282');

update temp_medications t
set duration = obs_from_group_id_value_numeric(t.obs_group_id, 'PIH','9075');

update temp_medications t
set duration_units = obs_from_group_id_value_coded(t.obs_group_id, 'PIH','6412',@locale);

update temp_medications t
set admin_inxs = obs_from_group_id_value_text(t.obs_group_id, 'PIH','9072');

update temp_medications t
set dose1_dose = obs_from_group_id_value_numeric(t.obs_group_id, 'PIH','9073');

update temp_medications t
set dose1_dose_units = obs_from_group_id_value_coded(t.obs_group_id, 'PIH','10744',@locale);

update temp_medications t
set dose2_dose = obs_from_group_id_value_numeric(t.obs_group_id, 'PIH','14824');

update temp_medications t
set dose2_dose_units = obs_from_group_id_value_coded(t.obs_group_id, 'PIH','14825',@locale);


set @part_of_day = concept_from_mapping('PIH','7392');
set @part_of_day2 = concept_from_mapping('PIH','14823');
set @morning = concept_from_mapping('PIH','6105');
set @noon = concept_from_mapping('PIH','3425');
set @afternoon = concept_from_mapping('PIH','7393');
set @evening = concept_from_mapping('PIH','6106');

update temp_medications t
inner join obs o on o.obs_group_id = t.obs_group_id
	and o.concept_id = @part_of_day
	and o.value_coded = @morning
	and o.voided = 0
set dose1_morning = if(o.obs_id is null,null,1),
	dose1_morning_text = o.comments;

update temp_medications t
inner join obs o on o.obs_group_id = t.obs_group_id
	and o.concept_id = @part_of_day
	and o.value_coded = @noon
	and o.voided = 0
set dose1_noon = if(o.obs_id is null,null,1),
	dose1_noon_text = o.comments;

update temp_medications t
inner join obs o on o.obs_group_id = t.obs_group_id
	and o.concept_id = @part_of_day
	and o.value_coded = @afternoon
	and o.voided = 0
set dose1_afternoon = if(o.obs_id is null,null,1),
	dose1_afternoon_text = o.comments;

update temp_medications t
inner join obs o on o.obs_group_id = t.obs_group_id
	and o.concept_id = @part_of_day
	and o.value_coded = @evening
	and o.voided = 0
set dose1_evening = if(o.obs_id is null,null,1),
	dose1_evening_text = o.comments;

update temp_medications t
inner join obs o on o.obs_group_id = t.obs_group_id
	and o.concept_id = @part_of_day2
	and o.value_coded = @morning
	and o.voided = 0
set dose2_morning = if(o.obs_id is null,null,1),
	dose2_morning_text = o.comments;

update temp_medications t
inner join obs o on o.obs_group_id = t.obs_group_id
	and o.concept_id = @part_of_day2
	and o.value_coded = @noon
	and o.voided = 0
set dose2_noon = if(o.obs_id is null,null,1),
	dose2_noon_text = o.comments;

update temp_medications t
inner join obs o on o.obs_group_id = t.obs_group_id
	and o.concept_id = @part_of_day2
	and o.value_coded = @afternoon
	and o.voided = 0
set dose2_afternoon = if(o.obs_id is null,null,1),
	dose2_afternoon_text = o.comments;

update temp_medications t
inner join obs o on o.obs_group_id = t.obs_group_id
	and o.concept_id = @part_of_day2
	and o.value_coded = @evening
	and o.voided = 0
set dose2_evening = if(o.obs_id is null,null,1),a
	dose2_evening_text = o.comments;

select
	person_uuid,
	emr_id,
	CONCAT(@partition,'-',encounter_id) "encounter_id",
	encounter_uuid,
	encounter_date,
	encounter_location,
	medication,
	duration,
	duration_units,
	admin_inxs,
	dose1_dose,
	dose1_dose_units,
	dose1_morning,
	dose1_morning_text,
	dose1_noon,
	dose1_noon_text,
	dose1_afternoon,
	dose1_afternoon_text,
	dose1_evening,
	dose1_evening_text,
	dose2_dose,
	dose2_dose_units,
	dose2_morning,
	dose2_morning_text,
	dose2_noon,
	dose2_noon_text,
	dose2_afternoon,
	dose2_afternoon_text,
	dose2_evening,
	dose2_evening_text
from temp_medications;
