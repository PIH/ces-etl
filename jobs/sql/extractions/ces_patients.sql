select patient_identifier_type_id into @identifier_type from patient_identifier_type pit where uuid ='506add39-794f-11e8-9bcd-74e5f916c5ec';

DROP TABLE IF EXISTS ces_patients;
CREATE TEMPORARY TABLE ces_patients (
emr_id varchar(30),
reg_location varchar(30),
reg_date date,
dob date,
age_in_years int,
gender char(1),
state varchar(50),
municipilty varchar(50),
migrant bit,
Indigenous bit,
Disability bit,
education bit,
active_case_finding bit,
civil_status varchar(50),
occupation varchar(50),
dead bit,
date_of_death date,
cause_of_Death varchar(50),
PHD_GAD_Score bit,
PHD_GAD_DATE date,
recent_height double,
recent_weight double,
recent_bmi double,
last_enc_date date,
last_enc_type varchar(50)
);

-- ################################# Views Updates ##################################################################

CREATE OR REPLACE VIEW first_enc AS
		SELECT patient_id , min(encounter_datetime) encounter_datetime
		FROM encounter e 
		WHERE encounter_type=2
		GROUP BY patient_id ;
	
CREATE OR REPLACE VIEW reg_enc_details AS 
	SELECT DISTINCT e.patient_id, e.encounter_datetime  , e.encounter_id,e.encounter_type ,l.name 
        FROM encounter e INNER JOIN first_enc X ON X.patient_id =e.patient_id AND X.encounter_datetime=e.encounter_datetime
		INNER JOIN location l ON l.location_id =e.location_id 
		WHERE encounter_type=2;
	
CREATE OR REPLACE VIEW last_enc AS
		SELECT patient_id , max(encounter_id) encounter_id
		FROM encounter e 
		GROUP BY patient_id;
	
CREATE OR REPLACE VIEW last_enc_details AS 
	SELECT DISTINCT e.patient_id, e.encounter_datetime  , e.encounter_type ,et.name  
        FROM encounter e inner join last_enc X ON X.patient_id =e.patient_id AND X.encounter_id=e.encounter_id
		left outer JOIN encounter_type et  ON e.encounter_type  =et.encounter_type_id 
		GROUP BY e.patient_id;


	
select concept_id into @civil_status from concept_name cn where uuid ='0b8ec5fe-15f5-102d-96e4-000c29c2a5d7';
select concept_id into @occupation from concept_name cn where uuid ='0b9562d8-15f5-102d-96e4-000c29c2a5d7';
select concept_id into @case_finding from concept_name cn where uuid ='787da3a9-9c44-4761-92ce-50fa40d70671';
select concept_id into @education from concept_name cn where uuid ='6423202f-4f0a-4e77-8ce1-d5482c8cdd64' and voided =0;
select concept_id into @disability from concept_name cn where uuid ='126165BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB';
select concept_id into @walk_disability from concept_name cn where uuid ='23009BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB';
select concept_id into @Indigenous from concept_name cn where uuid ='96fdcecd-3b55-49ca-a927-e166e44a9de3';
select concept_id into @Immigrant from concept_name cn where uuid ='05896be1-8987-4381-a0ea-de588f550cd4';

select concept_from_mapping('PIH','1065') into @case_finding_value;
select concept_from_mapping('PIH','1065') into @education_value;
select concept_from_mapping('PIH','1065') into @disabilty_value;
select concept_from_mapping('PIH','1065') into @indig_value;
select concept_from_mapping('PIH','1065') into @imm_value;


drop table if exists patient_flag;
CREATE table patient_flag AS 
		SELECT person_id , 
		max(CASE WHEN concept_id =@civil_status THEN concept_name(value_coded,'es')  ELSE NULL END ) civil_status,
		max(CASE WHEN concept_id =@occupation THEN concept_name(value_coded,'es')   ELSE NULL END ) occupation,
		max(CASE WHEN concept_id = @case_finding THEN (CASE WHEN value_coded=concept_from_mapping('PIH','1065') THEN TRUE ELSE FALSE END)  ELSE NULL END) case_finding,
		max(CASE WHEN concept_id =@education THEN (CASE WHEN value_coded=concept_from_mapping('PIH','1065') THEN TRUE ELSE FALSE END)  ELSE NULL END)  education,
		max(CASE WHEN (concept_id =@disability  OR concept_id =@walk_disability)  THEN  (CASE WHEN value_coded=concept_from_mapping('PIH','1065') THEN TRUE ELSE FALSE END)  ELSE NULL END) disability,
		max(CASE WHEN concept_id =@Indigenous THEN  (CASE WHEN value_coded=concept_from_mapping('PIH','1065') THEN TRUE ELSE FALSE END)  ELSE NULL END)  Indigenous,
		max(CASE WHEN concept_id =@Immigrant THEN  (CASE WHEN value_coded=concept_from_mapping('PIH','1065') THEN TRUE ELSE FALSE END)  ELSE NULL END)  Immigrant
		FROM obs o 
		WHERE 
		encounter_id IN (SELECT encounter_id FROM reg_enc_details)
		GROUP BY person_id;

select concept_id into @height from concept_name cn where uuid ='3e3b0a68-26fe-102b-80cb-0017a47871b2';
drop table if exists last_patient_height;
CREATE temporary table last_patient_height AS 
SELECT person_id , obs_id , value_numeric AS height  FROM obs o2 
		WHERE obs_id IN (
			SELECT max(obs_id) obs_id
			FROM obs o 
			WHERE 
			concept_id =@height AND NOT value_numeric IS NULL 
			GROUP BY person_id 
		);
	
select concept_id into @weight from concept_name cn where uuid ='93bf7980-07d4-102c-b5fa-0017a47871b2';
drop table if exists last_patient_weight;
CREATE temporary table last_patient_weight AS 
SELECT person_id , obs_id , value_numeric AS weight   FROM obs o2 
		WHERE obs_id IN (
			SELECT max(obs_id) obs_id
			FROM obs o 
			WHERE  concept_id =@weight AND NOT value_numeric IS NULL 
			GROUP BY person_id 
		);
	
select concept_id into @phq2 from concept_name cn where uuid ='f56a7d0a-0d09-41e6-9ae0-6480b3006624';
select concept_id into @gad2 from concept_name cn where uuid ='d3d4aa40-40cc-42fe-a840-cbb6f8f54fb7';
drop table if exists last_patient_score;
create temporary table last_patient_score AS 
SELECT person_id , obs_id ,encounter_id,  value_numeric AS score   FROM obs o2 
		WHERE obs_id IN (
			SELECT max(obs_id) obs_id
			FROM obs o 
			WHERE  concept_id IN (@phq2,@gad2) AND NOT value_numeric IS NULL 
			GROUP BY person_id 
		);
	
CREATE OR REPLACE VIEW last_patient_score_date AS 
SELECT person_id , obs_id , encounter_id  FROM obs o2 
		WHERE obs_id IN (
			SELECT max(obs_id) obs_id
			FROM obs o 
			GROUP BY person_id 
		);
	
CREATE OR REPLACE VIEW first_enc AS
		SELECT patient_id , min(encounter_datetime) encounter_datetime
		FROM encounter e 
		GROUP BY patient_id;

Drop table if exists first_enc_details;
CREATE TABLE first_enc_details AS 
	SELECT DISTINCT e.patient_id, e.encounter_datetime  , e.encounter_id,e.encounter_type ,l.name 
        FROM encounter e INNER JOIN first_enc X ON X.patient_id =e.patient_id AND X.encounter_datetime=e.encounter_datetime
		INNER JOIN location l ON l.location_id =e.location_id
		WHERE e.patient_id IN (	SELECT patient_id  FROM ces_patients cp WHERE reg_date  IS NULL );

-- ################################# Insert patients data ##############################################################
INSERT INTO ces_patients (patient_id,emr_id)
SELECT DISTINCT p.patient_id, pid.identifier 
FROM patient p INNER JOIN patient_identifier pid ON p.patient_id =pid.patient_id
and pid.identifier_type = @identifier_type
GROUP BY patient_id;

-- ################################# first encounter date and location ##############################################################
	
UPDATE ces_patients cp 
SET cp.reg_location = loc_registered(cp.patient_id),
	   cp.reg_date = registration_date(cp.patient_id); 
	  
UPDATE ces_patients cp 
INNER JOIN (SELECT patient_id, encounter_datetime, name FROM first_enc_details)  x
ON cp.patient_id =x.patient_id 
SET cp.reg_location = x.name,
	   cp.reg_date = cast(x.encounter_datetime AS date);
	  
-- ################################# last encounter date and location ##############################################################
	
UPDATE ces_patients cp 
INNER JOIN (SELECT patient_id, encounter_datetime, name FROM last_enc_details) x
ON cp.patient_id =x.patient_id 
SET cp.last_enc_type  = x.name,
	   cp.last_enc_date = cast(x.encounter_datetime AS date);

-- ######################## personal details ################################################################################
UPDATE ces_patients cp 
INNER JOIN (
	SELECT DISTINCT p2.person_id,
	birthdate, 
	DATE_FORMAT(FROM_DAYS(DATEDIFF(NOW(), birthdate)), "%Y")+0 age_in_years,
	gender,
	pa.county_district municipilty,
	pa.state_province state,
	dead death,
	cause_of_death,death_date 
	FROM person p2 INNER JOIN person_address pa ON p2.person_id = pa.person_id 
) x ON cp.patient_id =x.person_id
SET cp.dob = x.birthdate,
	cp.age_in_years = x.age_in_years,
	cp.gender =x.gender,
	cp.municipilty = x.municipilty,
	cp.state =x.state,
	cp.dead =x.death,
	cp.date_of_death =x.death_date,
	cp.cause_of_Death =x.cause_of_death;

-- ---------------------------- civil_status and other regsteration flags -------------------------------------------

UPDATE ces_patients cp 
SET cp.Indigenous = (
 SELECT Indigenous
 FROM patient_flag 
 WHERE person_id=cp.patient_id);

UPDATE ces_patients cp 
SET cp.Disability = (SELECT disability FROM patient_flag WHERE person_id=cp.patient_id);

UPDATE ces_patients cp 
SET cp.civil_status = (SELECT civil_status FROM patient_flag WHERE person_id=cp.patient_id);

UPDATE ces_patients cp 
SET cp.occupation = (SELECT occupation FROM patient_flag WHERE person_id=cp.patient_id);

UPDATE ces_patients cp 
SET cp.active_case_finding = (SELECT case_finding FROM patient_flag WHERE person_id=cp.patient_id);

UPDATE ces_patients cp 
SET cp.migrant = (SELECT Immigrant FROM patient_flag WHERE person_id=cp.patient_id);

UPDATE ces_patients cp 
SET cp.education = (SELECT education FROM patient_flag WHERE person_id=cp.patient_id);

update ces_patients cp
set cp.migrant = FALSE where cp.migrant is null ;

update ces_patients cp
set cp.Indigenous  = FALSE where cp.Indigenous  is null;

update ces_patients cp
set cp.Disability  = FALSE where cp.Disability  is null ;

update ces_patients cp
set cp.education  = FALSE where cp.education  is null;

update ces_patients cp
set cp.active_case_finding  = FALSE where cp.active_case_finding  is null;

-- ################## update height and wegiht ###############################################################################
UPDATE ces_patients cp
SET cp.recent_height = (
SELECT height
FROM last_patient_height
WHERE person_id =cp.patient_id 
);


UPDATE ces_patients cp
SET cp.recent_weight = (
SELECT weight 
FROM last_patient_weight 
WHERE person_id =cp.patient_id 
);


drop table if exists patient_bmi;
CREATE TEMPORARY TABLE patient_bmi AS 
	SELECT patient_id ,CASE WHEN cp2.recent_height IS NULL THEN NULL ELSE (cp2.recent_weight/((cp2.recent_height/100) * (cp2.recent_height/100)))END AS bmi
	FROM ces_patients cp2;

UPDATE ces_patients cp 
SET cp.recent_bmi = (
	SELECT round(bmi,2)
	FROM patient_bmi
	WHERE patient_id = cp.patient_id 
);

-- ################## score value and date ###############################################################################

UPDATE ces_patients cp
SET cp.PHD_GAD_Score = (
SELECT CASE WHEN score IS NOT NULL THEN TRUE ELSE FALSE END  
FROM last_patient_score 
WHERE person_id =cp.patient_id 
);

UPDATE ces_patients SET PHD_GAD_Score=FALSE  
WHERE PHD_GAD_Score IS NULL;

UPDATE ces_patients cp
SET cp.PHD_GAD_DATE  = (
SELECT  CAST(e.encounter_datetime AS date) encounter_datetime
FROM last_patient_score le INNER JOIN encounter e ON le.person_id =e.patient_id AND le.encounter_id =e.encounter_id 
WHERE person_id =cp.patient_id 
);



-- ######################### Final Select ###################################################################################

SELECT
emr_id,
reg_location,
reg_date,
dob,
age_in_years,
gender,
state,
municipilty,
migrant,
Indigenous,
Disability,
education,
active_case_finding,
civil_status,
occupation,
dead,
date_of_death,
cause_of_Death,
PHD_GAD_Score,
PHD_GAD_DATE,
recent_height,
recent_weight,
recent_bmi,
last_enc_date,
last_enc_type
FROM ces_patients
where reg_date is not null;