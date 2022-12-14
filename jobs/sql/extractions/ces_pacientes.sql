select patient_identifier_type_id into @identifier_type from patient_identifier_type pit where uuid ='506add39-794f-11e8-9bcd-74e5f916c5ec';

DROP TABLE IF EXISTS ces_patients;
CREATE TEMPORARY TABLE ces_patients (
patient_id int, 
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
drop table if exists first_enc;
CREATE temporary table first_enc AS
		SELECT patient_id, encounter_datetime -- , min(encounter_datetime) encounter_datetime
		FROM encounter e 
		WHERE encounter_type=2
		GROUP BY patient_id ;
	
drop table if exists reg_enc_details;
CREATE  temporary table reg_enc_details AS 
	SELECT DISTINCT e.patient_id, e.encounter_datetime  , e.encounter_id,e.encounter_type ,l.name 
        FROM encounter e INNER JOIN first_enc X ON X.patient_id =e.patient_id AND X.encounter_datetime=e.encounter_datetime
		left outer JOIN location l ON l.location_id =e.location_id 
		WHERE encounter_type=2;

drop table if exists last_enc;
CREATE temporary table last_enc AS
		SELECT patient_id , max(encounter_id) encounter_id
		FROM encounter e 
		GROUP BY patient_id;

drop table if exists last_enc_details;
CREATE temporary table last_enc_details AS 
	SELECT DISTINCT e.patient_id, e.encounter_datetime  , e.encounter_type ,et.name  
        FROM encounter e inner join last_enc X ON X.patient_id =e.patient_id AND X.encounter_id=e.encounter_id
		left outer JOIN encounter_type et  ON e.encounter_type  =et.encounter_type_id 
		GROUP BY e.patient_id;

drop table if exists first_enc_wo_reg;
CREATE temporary table first_enc_wo_reg AS
		SELECT patient_id , min(encounter_datetime) encounter_datetime
		FROM encounter e 
		WHERE encounter_type <> 2
		GROUP BY patient_id ;
	
	
SELECT concept_id INTO @civil_status FROM concept WHERE uuid='3cd6df26-26fe-102b-80cb-0017a47871b2';
SELECT concept_id INTO @occupation FROM concept WHERE uuid='3cd97286-26fe-102b-80cb-0017a47871b2';
SELECT concept_id INTO @case_finding FROM concept WHERE uuid='2011a523-43c8-4b3f-a99b-1bee1ca7b4d5';
SELECT concept_id INTO @education FROM concept WHERE uuid='159400AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
SELECT concept_id INTO @disability FROM concept WHERE uuid='162558AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
SELECT concept_id INTO @walk_disability FROM concept WHERE uuid='122936AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
SELECT concept_id INTO @Indigenous FROM concept WHERE uuid='106bdbef-3d87-4349-86d0-70dacc9c1d7b';
SELECT concept_id INTO @Immigrant FROM concept WHERE uuid='6f526898-070c-442b-8873-94806e19821a';

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
		max(CASE WHEN concept_id = @case_finding THEN (CASE WHEN value_coded=concept_from_mapping('PIH','1065') THEN TRUE WHEN value_coded=concept_from_mapping('PIH','1066') THEN FALSE END)  ELSE NULL END) case_finding,
		max(CASE WHEN concept_id =@education THEN 
		              (CASE WHEN value_coded=concept_from_mapping('PIH','1065') THEN TRUE
		              		WHEN value_coded=concept_from_mapping('PIH','1066') THEN FALSE END) 
		         else null end) as education,
		max(CASE WHEN (concept_id =@disability  OR concept_id =@walk_disability) THEN  
					(CASE WHEN value_coded=concept_from_mapping('PIH','1065') THEN TRUE  
						  WHEN value_coded=concept_from_mapping('PIH','1066') THEN FALSE END)
		     else null end) as disability,
		max(CASE WHEN concept_id =@Indigenous THEN 
		       (CASE WHEN value_coded=concept_from_mapping('PIH','1065') THEN TRUE 
		             WHEN value_coded=concept_from_mapping('PIH','1066') THEN FALSE END) 
		     ELSE NULL END) as  Indigenous,
		max(CASE WHEN concept_id =@Immigrant THEN  
		          (CASE WHEN value_coded=concept_from_mapping('PIH','1065') THEN TRUE 
		          		WHEN value_coded=concept_from_mapping('PIH','1066') THEN FALSE END)  ELSE NULL END) as Immigrant

		FROM obs o 
		WHERE -- person_id =33476 AND encounter_id =261665
		encounter_id IN (SELECT encounter_id FROM reg_enc_details)
		GROUP BY person_id;


SELECT concept_id INTO @height FROM concept WHERE uuid='3ce93cf2-26fe-102b-80cb-0017a47871b2';
drop table if exists last_patient_height;
CREATE temporary table last_patient_height AS 
SELECT person_id , obs_id , value_numeric AS height  FROM obs o2 
		WHERE obs_id IN (
			SELECT max(obs_id) obs_id
			FROM obs o 
			WHERE-- person_id =33517 AND  
			concept_id =@height AND NOT value_numeric IS NULL 
			GROUP BY person_id 
		);
	
SELECT concept_id INTO @weight FROM concept WHERE uuid='3ce93b62-26fe-102b-80cb-0017a47871b2';
drop table if exists last_patient_weight;
CREATE temporary table last_patient_weight AS 
SELECT person_id , obs_id , value_numeric AS weight   FROM obs o2 
		WHERE obs_id IN (
			SELECT max(obs_id) obs_id
			FROM obs o 
			WHERE  concept_id =@weight AND NOT value_numeric IS NULL 
			GROUP BY person_id 
		);
	
SELECT concept_id INTO @phq2 FROM concept WHERE uuid='29e259af-6db2-4a16-abd9-86c55e2b9036';
SELECT concept_id INTO @gad2 FROM concept WHERE uuid='bb6c715b-0efb-4f18-97c4-6a12cba13374';
drop table if exists last_patient_score;
create temporary table last_patient_score AS 
SELECT person_id , obs_id ,encounter_id,  value_numeric AS score   FROM obs o2 
		WHERE obs_id IN (
			SELECT max(obs_id) obs_id
			FROM obs o 
			WHERE  concept_id IN (@phq2,@gad2) -- AND NOT value_numeric IS NULL 
			-- and person_id = 2295
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
		-- WHERE patient_id =15861
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
and pid.voided = 0 
GROUP BY patient_id;

create index ces_patients_vi on ces_patients(patient_id);


-- ################################# first encounter date and location ##############################################################
	
UPDATE ces_patients cp 
  INNER JOIN (SELECT patient_id, encounter_datetime, name FROM reg_enc_details) x
ON cp.patient_id =x.patient_id 
SET cp.reg_location = x.name,-- loc_registered(cp.patient_id),
   cp.reg_date = cast(x.encounter_datetime AS date); --  registration_date(cp.patient_id) ;

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
	dead death,
	cause_of_death,death_date 
	FROM person p2
) x ON cp.patient_id =x.person_id
SET cp.dob = x.birthdate,
	cp.age_in_years = x.age_in_years,
	cp.gender =x.gender,
	cp.dead =x.death,
	cp.date_of_death =x.death_date,
	cp.cause_of_Death =concept_name(x.cause_of_death,'en');


UPDATE ces_patients cp
SET cp.municipilty = (
	SELECT county_district
	FROM person_address
	WHERE voided=0
	AND person_id = cp.patient_id
	order by preferred desc, date_created desc limit 1
);


UPDATE ces_patients cp
SET cp.state = (
	SELECT state_province
	FROM person_address
	WHERE voided=0
	AND person_id = cp.patient_id
	order by preferred desc, date_created desc limit 1
);

-- ---------------------------- civil_status and other regsteration flags -------------------------------------------

-- UPDATE ces_patients cp 
-- SET cp.Indigenous = (
--  SELECT Indigenous
--  FROM patient_flag_ind 
--  WHERE person_id=cp.patient_id);

UPDATE ces_patients cp 
inner join patient_flag tmp on tmp.person_id=cp.patient_id
SET cp.Indigenous = tmp.Indigenous,
cp.Disability=tmp.disability,
cp.civil_status=tmp.civil_status,
cp.occupation=tmp.occupation,
cp.active_case_finding=tmp.case_finding,
cp.migrant=tmp.Immigrant,
cp.education=tmp.education;

-- UPDATE ces_patients cp 
-- SET cp.Disability = (SELECT disability FROM patient_flag WHERE person_id=cp.patient_id);
-- 
-- UPDATE ces_patients cp 
-- SET cp.civil_status = (SELECT civil_status FROM patient_flag WHERE person_id=cp.patient_id);


-- UPDATE ces_patients cp 
-- SET cp.occupation = (SELECT occupation FROM patient_flag WHERE person_id=cp.patient_id);

-- UPDATE ces_patients cp 
-- SET cp.active_case_finding = (SELECT case_finding FROM patient_flag WHERE person_id=cp.patient_id);

-- UPDATE ces_patients cp 
-- SET cp.migrant = (SELECT Immigrant FROM patient_flag WHERE person_id=cp.patient_id);

-- UPDATE ces_patients cp 
-- SET cp.education = (SELECT education FROM patient_flag WHERE person_id=cp.patient_id);

-- ################## update height and wegiht ###############################################################################
-- UPDATE ces_patients cp
-- SET cp.recent_height = (
-- SELECT height
-- FROM last_patient_height
-- WHERE person_id =cp.patient_id 
-- );

UPDATE ces_patients cp 
inner join last_patient_height tmp on tmp.person_id=cp.patient_id
SET cp.recent_height = tmp.height;


-- UPDATE ces_patients cp
-- SET cp.recent_weight = (
-- SELECT weight 
-- FROM last_patient_weight 
-- WHERE person_id =cp.patient_id 
-- );

UPDATE ces_patients cp 
inner join last_patient_weight tmp on tmp.person_id=cp.patient_id
SET cp.recent_weight = tmp.weight;

drop table if exists patient_bmi;
CREATE TEMPORARY TABLE patient_bmi AS 
	SELECT patient_id ,CASE WHEN cp2.recent_height IS NULL THEN NULL ELSE (cp2.recent_weight/((cp2.recent_height/100) * (cp2.recent_height/100)))END AS bmi
	FROM ces_patients cp2;

-- UPDATE ces_patients cp 
-- SET cp.recent_bmi = (
-- 	SELECT round(bmi,2)
-- 	FROM patient_bmi
-- 	WHERE patient_id = cp.patient_id 
-- );

UPDATE ces_patients cp 
inner join patient_bmi tmp on tmp.patient_id=cp.patient_id
SET cp.recent_bmi = round(tmp.bmi,2);

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