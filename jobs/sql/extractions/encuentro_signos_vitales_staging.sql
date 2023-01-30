SET sql_safe_updates = 0;
SET @partition = '${partitionNum}';

select patient_identifier_type_id into @identifier_type from patient_identifier_type pit where uuid ='506add39-794f-11e8-9bcd-74e5f916c5ec';

SET @vitals_encounter = (SELECT encounter_type_id FROM encounter_type WHERE uuid = '4fb47712-34a6-40d2-8ed3-e153abbd25b7');

DROP TEMPORARY TABLE IF EXISTS temp_vitals;
CREATE TEMPORARY TABLE temp_vitals
(
    all_vitals_id		int(11) PRIMARY KEY AUTO_INCREMENT,
	patient_id			int(11),
	person_uuid			char(38),
	emr_id          	VARCHAR(25),
    encounter_id		int(11),
    encounter_uuid			char(38),
    encounter_location_id	int(11),
    encounter_location	varchar(255),
    encounter_datetime	datetime,
    encounter_provider_id	int(11),
    provider_id int,
    encounter_provider 	VARCHAR(255),
    date_entered		datetime,
    creator				int(11),
    user_entered		varchar(255),
    height				double,
    weight				double,
    bmi 				double,
    systolic_bp			int,
    diastolic_bp		int,
    o2_saturation		double,
    fasting 			boolean,
    glucose 			double,
    temperature			double,
    heart_rate			double,
    respiratory_rate	double,
    phq2				int,
    gad2				int,
    chief_complaint		text,
    index_asc			int,
    index_desc			int
    );
   
insert into temp_vitals(patient_id, encounter_id, encounter_uuid, encounter_datetime, date_entered, creator, encounter_location_id)   
select e.patient_id,  e.encounter_id, e.uuid , e.encounter_datetime, e.date_created, e.creator, e.location_id  from encounter e
where e.encounter_type = @vitals_encounter
and e.voided = 0;

create index temp_vitals_ei on temp_vitals(encounter_id);

-- emr_id
DROP TEMPORARY TABLE IF EXISTS temp_identifiers;
CREATE TEMPORARY TABLE temp_identifiers
(
patient_id						INT(11),
emr_id							VARCHAR(25)
);

INSERT INTO temp_identifiers(patient_id)
select distinct patient_id from temp_vitals;

update temp_identifiers t set emr_id =(
		select distinct identifier
		from patient_identifier 
		where identifier_type = @identifier_type
		and voided = 0
		and patient_id = t.patient_id
		and preferred=1
);	


CREATE INDEX temp_identifiers_p ON temp_identifiers (patient_id);

update temp_vitals tv 
inner join temp_identifiers ti on ti.patient_id = tv.patient_id
set tv.emr_id = ti.emr_id;

-- provider name
update temp_vitals tv 
inner join encounter_provider ep on ep.encounter_id  = tv.encounter_id and ep.voided = 0
set tv.encounter_provider_id = ep.encounter_provider_id,
tv.provider_id=ep.provider_id ;

DROP TEMPORARY TABLE IF EXISTS temp_providers;
CREATE TEMPORARY TABLE temp_providers
(
provider_id						INT(11),
provider_name					VARCHAR(255)
);

INSERT INTO temp_providers(provider_id)
select distinct ep.provider_id from encounter_provider ep
left outer join temp_vitals tv on ep.encounter_id = tv.encounter_id
where ep.voided = 0;

update temp_providers t set provider_name  = person_name_of_user(provider_id);	

CREATE INDEX temp_providers_p ON temp_providers (provider_id);

update temp_vitals tv 
inner join temp_providers tp on tp.provider_id = tv.provider_id
set tv.encounter_provider = tp.provider_name;

-- location name
DROP TEMPORARY TABLE IF EXISTS temp_locations;
CREATE TEMPORARY TABLE temp_locations
(
location_id						INT(11),
location_name					VARCHAR(255)
);

INSERT INTO temp_locations(location_id)
select distinct encounter_location_id from temp_vitals tv;

update temp_locations t set location_name  = location_name(location_id);	

CREATE INDEX temp_locations_l ON temp_locations (location_id);

update temp_vitals tv 
inner join temp_locations tl on tl.location_id = tv.encounter_location_id
set tv.encounter_location = tl.location_name;

-- user entered
DROP TEMPORARY TABLE IF EXISTS temp_creators;
CREATE TEMPORARY TABLE temp_creators
(
creator						INT(11),
user_entered				VARCHAR(255)
);

INSERT INTO temp_creators(creator)
select distinct creator from temp_vitals tv;

update temp_creators t set user_entered  = person_name_of_user(creator);	

CREATE INDEX temp_creators_c ON temp_creators (creator);

update temp_vitals tv 
inner join temp_creators tc on tc.creator = tv.creator
set tv.user_entered = tc.user_entered;
-- ---------------------------
set @weight =  CONCEPT_FROM_MAPPING('PIH', '5089');
set @height =  CONCEPT_FROM_MAPPING('PIH', '5090');
set @temp =  CONCEPT_FROM_MAPPING('PIH', '5088');
set @sbp = concept_from_mapping('PIH','5085');
set @dbp = concept_from_mapping('PIH','5086');
set @o2 =  CONCEPT_FROM_MAPPING('PIH', '5092');
set @fast = concept_from_mapping('PIH','6689');
set @glcs = concept_from_mapping('PIH','887');
set @hr =  CONCEPT_FROM_MAPPING('PIH', '5087');
set @rr =  CONCEPT_FROM_MAPPING('PIH', '5242');
set @phq2 = concept_from_mapping('PIH','13652');
set @gad2 = concept_from_mapping('PIH','13653');
set @cc =  CONCEPT_FROM_MAPPING('PIH', '10137');


DROP TEMPORARY TABLE IF EXISTS temp_obs;
create temporary table temp_obs 
select o.obs_id, o.voided ,o.obs_group_id , o.encounter_id, o.person_id, o.concept_id, o.value_coded, o.value_numeric, o.value_text,o.value_datetime, o.comments 
from obs o
inner join temp_vitals t on t.encounter_id = o.encounter_id
where o.voided = 0
and o.concept_id in (
@height,
@weight,
@temp,
@sbp,
@dbp,
@o2,
@fast,
@glcs,
@hr,
@rr,
@phq2,
@gad2,
@cc);

create index temp_obs_concept_id on temp_obs(encounter_id,concept_id);
   
-- weight   
UPDATE temp_vitals t
inner join temp_obs o ON t.encounter_id = o.encounter_id
        AND o.concept_id =@weight
SET weight = o.value_numeric;

-- height   
UPDATE temp_vitals t
inner join temp_obs o ON t.encounter_id = o.encounter_id
        AND o.concept_id = @height
SET height = o.value_numeric;

-- BMI
drop table if exists patient_bmi;
CREATE TEMPORARY TABLE patient_bmi AS 
	SELECT patient_id ,encounter_id, CASE WHEN (cp2.height IS NOT NULL and  cp2.weight is not null) THEN  
						 (cp2.weight/((cp2.height/100) * (cp2.height/100)))END AS bmi
	FROM temp_vitals cp2;

UPDATE temp_vitals cp 
inner join patient_bmi tmp on tmp.patient_id=cp.patient_id and tmp.encounter_id=cp.encounter_id
SET cp.bmi = round(tmp.bmi,1);

-- temp   
UPDATE temp_vitals t
inner join temp_obs o ON t.encounter_id = o.encounter_id
        AND o.concept_id = @temp
SET temperature = o.value_numeric;

-- blood preasure   

UPDATE temp_vitals t
inner join temp_obs o ON t.encounter_id = o.encounter_id
        AND o.concept_id = @sbp
SET systolic_bp = o.value_numeric;

UPDATE temp_vitals t
inner join temp_obs o ON t.encounter_id = o.encounter_id
        AND o.concept_id = @dbp
SET diastolic_bp = o.value_numeric;

-- o2_saturation   
UPDATE temp_vitals t
inner join temp_obs o ON t.encounter_id = o.encounter_id
        AND o.concept_id = @o2
SET o2_saturation = o.value_numeric;

-- fast   
UPDATE temp_vitals t
inner join temp_obs o ON t.encounter_id = o.encounter_id
        AND o.concept_id = @fast
SET fasting = case when o.value_coded=1 then true else false end;

-- glcouse   
UPDATE temp_vitals t
inner join temp_obs o ON t.encounter_id = o.encounter_id
        AND o.concept_id = @glcs
SET glucose = o.value_numeric;

-- hr   
UPDATE temp_vitals t
inner join temp_obs o ON t.encounter_id = o.encounter_id
        AND o.concept_id = @hr
SET heart_rate = o.value_numeric;

-- respiratory_rate   
UPDATE temp_vitals t
inner join temp_obs o ON t.encounter_id = o.encounter_id
        AND o.concept_id = @rr
SET respiratory_rate = o.value_numeric;

-- PHQ2   
UPDATE temp_vitals t
inner join temp_obs o ON t.encounter_id = o.encounter_id
        AND o.concept_id = @phq2
SET phq2 = o.value_numeric;

-- GAD2   
UPDATE temp_vitals t
inner join temp_obs o ON t.encounter_id = o.encounter_id
        AND o.concept_id = @gad2
SET gad2 = o.value_numeric;

-- chief_complaint   

UPDATE temp_vitals t
inner join temp_obs o ON t.encounter_id = o.encounter_id
        AND o.concept_id = @cc 
SET chief_complaint = o.value_text;

-- person UUID
update temp_vitals t 
inner join person p on p.person_id = t.patient_id
set t.person_uuid = p.uuid;

select 
	CONCAT(@partition,'-',emr_id) "emr_id",
	person_uuid,
	CONCAT(@partition,'-',encounter_id) "encounter_id",
	encounter_uuid,
	encounter_location,
	encounter_datetime,
	encounter_provider,
	cast(date_entered as date) date_entered,
	user_entered,
    height,
    weight,
    bmi,
    systolic_bp,
    diastolic_bp,
    o2_saturation,
    fasting,
    glucose,
    temperature,
    heart_rate,
    respiratory_rate,
    phq2,
    gad2,
    chief_complaint,
    index_asc,
    index_desc
from temp_vitals; 
