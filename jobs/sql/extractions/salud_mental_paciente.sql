SELECT name  INTO @encounter_type_name FROM encounter_type et WHERE et.uuid ='a8584ab8-cc2a-11e5-9956-625662870761';
SELECT encounter_type_id  INTO @encounter_type_id FROM encounter_type et WHERE et.uuid ='a8584ab8-cc2a-11e5-9956-625662870761';
SELECT program_id INTO @program_id FROM program p WHERE uuid='0e69c3ab-1ccb-430b-b0db-b9760319230f';
select patient_identifier_type_id into @identifier_type from patient_identifier_type pit where uuid ='506add39-794f-11e8-9bcd-74e5f916c5ec';
set @dbname = '${partitionNum}';

DROP TABLE IF EXISTS salud_mental_paciente;
CREATE TEMPORARY TABLE salud_mental_paciente (
dbname varchar(30),
Patient_id	int,
emr_id	varchar(50),
age	int,
gender	varchar(30),
dead	bit,
death_Date	date,
mh_enrolled bit,
most_recent_mental_health_enc	date,
number_mental_health_enc	int,
mental_health_enc_enroll_date	date,
reg_location	varchar(30),
recent_mental_status	varchar(30),
recent_mental_status_date	Date,
active	bit,
asthma	bit,
malnutrition	bit,
diabetes	bit,
epilepsy	bit,
hypertension	bit,
Comorbidity	bit,
date_next_appointment	date,
psychosis	bit,
mood_disorder	bit,
anxiety	bit,
adaptive_disorders	bit,
dissociative_disorders	bit,
psychosomatic_disorders	bit,
eating_disorders	bit,
personality_disorders	bit,
conduct_disorders	bit,
suicidal_ideation	bit,
grief	bit,
First_PHQ9_score	int,
Date_first_PHQ9	date,
Date_most_recent_PHQ9	date,
PHQ9_q1	int,
PHQ9_q2	int,
PHQ9_q3	int,
PHQ9_q4	int,
PHQ9_q5	int,
PHQ9_q6	int,
PHQ9_q7	int,
PHQ9_q8	int,
PHQ9_q9	int,
Most_recent_PHQ9	int,
First_GAD7_score	int,
Date_first_GAD7	date,
Date_most_recent_GAD7	date,
GAD7_q1	int,
GAD7_q2	int,
GAD7_q3	int,
GAD7_q4	int,
GAD7_q5	int,
GAD7_q6	int,
GAD7_q7	int,
Most_recent_GAD7	int
);


-- ----------------- Views Defintions --------------------------------------------------------------
SELECT concept_id INTO @phq1 FROM concept WHERE uuid='85bdc2d2-afaa-4d5e-bc6b-ee8277d160f1';
SELECT concept_id INTO @phq2 FROM concept WHERE uuid='01bf95d6-bcd0-44fb-8752-3da72f71ab6d';
SELECT concept_id INTO @phq3 FROM concept WHERE uuid='c85fc943-b747-4d72-a0a8-6ca2dc8fb568';
SELECT concept_id INTO @phq4 FROM concept WHERE uuid='8a034046-5fea-4253-a105-3af86b0679fe';
SELECT concept_id INTO @phq5 FROM concept WHERE uuid='a34eb8de-4272-4da5-b785-6462dfb97cc2';
SELECT concept_id INTO @phq6 FROM concept WHERE uuid='4306e155-d299-46d0-9472-51c88fb196a7';
SELECT concept_id INTO @phq7 FROM concept WHERE uuid='476ec75b-a7d0-4e07-889a-d3700f03acd3';
SELECT concept_id INTO @phq8 FROM concept WHERE uuid='5bc6e1a8-91a6-49ef-b879-715c524abd98';
SELECT concept_id INTO @phq9 FROM concept WHERE uuid='996e915c-ed3a-4c67-834b-a7cb98f8248b';
SELECT concept_id INTO @gdq1 FROM concept WHERE uuid='8f7bc995-9b4a-4c99-9301-3029130c3aae';
SELECT concept_id INTO @gdq2 FROM concept WHERE uuid='bce099ca-d69f-48d0-bb87-d2c7ff4ca5c7';
SELECT concept_id INTO @gdq3 FROM concept WHERE uuid='f808bce8-4c0b-43ce-a187-1c209cb1c830';
SELECT concept_id INTO @gdq4 FROM concept WHERE uuid='2c1bdb4f-c432-4987-aba6-045ed9c53ea5';
SELECT concept_id INTO @gdq5 FROM concept WHERE uuid='fdee3750-0aa7-47c3-8c0b-c86ffe7e9b60';
SELECT concept_id INTO @gdq6 FROM concept WHERE uuid='e4ecb39a-d295-48bb-920c-ef3298b5cd49';
SELECT concept_id INTO @gdq7 FROM concept WHERE uuid='bf6c5967-339a-43c3-ab74-43e14638fe4c';
SELECT concept_id INTO @phqscore FROM concept WHERE uuid='165137AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
SELECT concept_id INTO @gadscore FROM concept WHERE uuid='8b8769a9-a8cc-4166-ba2a-2e61fb081be7';

DROP TABLE IF EXISTS mental_obs_ref;
CREATE TABLE mental_obs_ref (
obs_id int
);
INSERT INTO mental_obs_ref VALUES(@phq1);
INSERT INTO mental_obs_ref VALUES(@phq2);
INSERT INTO mental_obs_ref VALUES(@phq3);
INSERT INTO mental_obs_ref VALUES(@phq4);
INSERT INTO mental_obs_ref VALUES(@phq5);
INSERT INTO mental_obs_ref VALUES(@phq6);
INSERT INTO mental_obs_ref VALUES(@phq7);
INSERT INTO mental_obs_ref VALUES(@phq8);
INSERT INTO mental_obs_ref VALUES(@phq9);
INSERT INTO mental_obs_ref VALUES(@gdq1);
INSERT INTO mental_obs_ref VALUES(@gdq2);
INSERT INTO mental_obs_ref VALUES(@gdq3);
INSERT INTO mental_obs_ref VALUES(@gdq4);
INSERT INTO mental_obs_ref VALUES(@gdq5);
INSERT INTO mental_obs_ref VALUES(@gdq6);
INSERT INTO mental_obs_ref VALUES(@gdq7);
INSERT INTO mental_obs_ref VALUES(@phqscore);
INSERT INTO mental_obs_ref VALUES(@gadscore);


DROP TABLE IF EXISTS mental_encounters;
CREATE TABLE mental_encounters  AS
SELECT DISTINCT person_id, concept_id , encounter_id , obs_datetime 
FROM obs 
WHERE concept_id  IN (SELECT obs_id FROM mental_obs_ref )
;

CREATE OR REPLACE VIEW mental_encounter_details AS 
SELECT DISTINCT  encounter_id, patient_id, encounter_datetime
FROM encounter e2 
WHERE encounter_id  IN (SELECT encounter_id FROM mental_encounters);

DROP TABLE IF EXISTS mental_patients_list;
CREATE TABLE mental_patients_list AS
SELECT DISTINCT patient_id FROM patient_program pp WHERE program_id =@program_id 
;

drop table if exists mh_patient_list;
CREATE table mh_patient_list AS
SELECT DISTINCT  p.patient_id, pi2.identifier emr_id
FROM patient p INNER JOIN patient_identifier pi2 ON p.patient_id =pi2.patient_id
WHERE p.patient_id IN (
	SELECT DISTINCT patient_id FROM mental_patients_list
)
and pi2.identifier_type = @identifier_type
GROUP BY p.patient_id 
UNION
SELECT DISTINCT  p.patient_id, pi2.identifier emr_id
FROM patient p INNER JOIN patient_identifier pi2 ON p.patient_id =pi2.patient_id
WHERE p.patient_id IN (
	SELECT DISTINCT patient_id FROM mental_encounter_details
)
and pi2.identifier_type = @identifier_type
GROUP BY p.patient_id;

-- ----------------- Insert Patinets List --------------------------------------------------------------
INSERT INTO salud_mental_paciente (patient_id, emr_id, age, gender, dead, death_date)
SELECT pl.patient_id,pl.emr_id ,current_age_in_years(p.person_id),  p.gender, p.dead, p.death_date
FROM mh_patient_list pl
INNER JOIN (SELECT person_id,gender, dead, death_date 
						FROM person
						GROUP BY person_id) p ON pl.patient_id=p.person_id;
					
UPDATE salud_mental_paciente t
SET t.dbname=@dbname;

-- --------------- Mental Encounters Columns -------------------------------------
					
UPDATE salud_mental_paciente t
SET t.mh_enrolled = TRUE 
WHERE t.Patient_id IN (SELECT Patient_id FROM mental_patients_list);

UPDATE salud_mental_paciente t
SET t.number_mental_health_enc =(
	SELECT count(*)
	FROM mental_encounter_details
	WHERE Patient_id = t.Patient_id 
	GROUP BY patient_id
);

UPDATE salud_mental_paciente t
SET t.most_recent_mental_health_enc =(
	SELECT encounter_datetime
	FROM mental_encounter_details
	WHERE Patient_id = t.Patient_id 
	ORDER BY encounter_datetime DESC 
	LIMIT 1
);

UPDATE salud_mental_paciente t
SET t.number_mental_health_enc = 0
where t.number_mental_health_enc is null;

-- ------------- Mental Health Enrollment Details -------------------------------------
UPDATE salud_mental_paciente t 
SET t.mental_health_enc_enroll_date =(
	 SELECT date_enrolled 
	 FROM patient_program 
	 WHERE program_id=@program_id
	 AND Patient_id =t.Patient_id 
	 ORDER BY date_enrolled ASC 
	 LIMIT 1
 );

UPDATE salud_mental_paciente t 
SET t.mental_health_enc_enroll_date =(
	 SELECT CAST(encounter_datetime AS date) 
	 FROM mental_encounter_details 
	 WHERE Patient_id =t.Patient_id 
	 ORDER BY CAST(encounter_datetime AS date)  ASC 
	 LIMIT 1
 )
WHERE t.mental_health_enc_enroll_date IS NULL;

UPDATE salud_mental_paciente t 
SET t.reg_location =(
	 SELECT location_name(location_id) 
	 FROM patient_program 
	 WHERE program_id=@program_id
	 AND Patient_id =t.Patient_id 
	 ORDER BY date_enrolled ASC 
	 LIMIT 1
);

CREATE OR REPLACE VIEW first_enc AS
		SELECT patient_id, encounter_datetime -- , min(encounter_datetime) encounter_datetime
		FROM encounter e 
		WHERE encounter_type=2
		GROUP BY patient_id ;

CREATE OR REPLACE VIEW reg_enc_details AS 
	SELECT DISTINCT e.patient_id, e.encounter_datetime  , e.encounter_id,e.encounter_type ,l.name 
        FROM encounter e INNER JOIN first_enc X ON X.patient_id =e.patient_id AND X.encounter_datetime=e.encounter_datetime
		left outer JOIN location l ON l.location_id =e.location_id 
		WHERE encounter_type=2;
	
UPDATE salud_mental_paciente mp 
  INNER JOIN (SELECT patient_id, name FROM reg_enc_details) x
ON mp.patient_id =x.patient_id 
SET mp.reg_location = x.name
where mp.reg_location is null;
	
	

-- ------------- Mental Health Program Status -------------------------------------

DROP TABLE IF EXISTS last_mh_date;
create temporary table last_mh_date as 
select patient_id, max(date_enrolled) date_enrolled
from patient_program pp 
where program_id=@program_id
group by patient_id;

DROP TABLE IF EXISTS last_mh_details;
create temporary table last_mh_details as 
select pp.patient_id, pp.date_completed , pp.outcome_concept_id
from last_mh_date ld 
left outer join patient_program pp on ld.patient_id=pp.patient_id
and cast(ld.date_enrolled as date)=cast(pp.date_enrolled as date)
where pp.program_id =@program_id
group by pp.patient_id 
;

UPDATE salud_mental_paciente t 
SET t.recent_mental_status=(
	select concept_name(outcome_concept_id,'en')
	from last_mh_details ld
	where ld.patient_id=t.patient_id
);


UPDATE salud_mental_paciente t 
SET t.recent_mental_status_date=(
	select date_completed
	from last_mh_details ld
	where ld.patient_id=t.patient_id
);


-- ------------- Mental Health Active -------------------------------------

UPDATE salud_mental_paciente t 
SET t.active =(
	SELECT CASE WHEN TIMESTAMPDIFF(MONTH, t.most_recent_mental_health_enc, now()) <=6 THEN TRUE ELSE FALSE END
);

-- ------------- Indicators - asma -------------------------------------
select program_id into @mh from program p2 where uuid='0e69c3ab-1ccb-430b-b0db-b9760319230f';
select program_id into @asthma from program p2 where uuid='2639449c-8764-4003-be5f-dba522b4b680';
select program_id into @malnutrition from program p2 where uuid='61e38de2-44f2-470e-99da-3e97e93d388f';
select program_id into @Diabetes from program p2 where uuid='3f038507-f4bc-4877-ade0-96ce170fc8eb';
select program_id into @Epilepsy from program p2 where uuid='69e6a46d-674e-4281-99a0-4004f293ee57';
select program_id into @Hypertension from program p2 where uuid='6959057e-9a5c-40ba-a878-292ba4fc35bc';
select program_id into @ANC from program p2 where uuid='d830a5c1-30a2-4943-93a0-f918772496ec';

DROP TABLE IF EXISTS asma_data;
CREATE TEMPORARY TABLE asma_data AS 
	 SELECT patient_id
	 FROM patient_program pp WHERE program_id=@asthma
	 GROUP BY patient_id;

update salud_mental_paciente t 
set t.asthma = true 
where t.Patient_id in (select patient_id from asma_data);
	
UPDATE salud_mental_paciente t 
SET t.asthma = FALSE 
WHERE t.asthma IS NULL;

-- ------------- Indicators - malnutrition -------------------------------------


DROP TABLE IF EXISTS malnutrition_data;
CREATE TEMPORARY TABLE malnutrition_data AS 
	 SELECT patient_id
	 FROM patient_program pp WHERE program_id=@malnutrition
	 GROUP BY patient_id;

update salud_mental_paciente t 
set t.malnutrition = true 
where t.Patient_id in (select patient_id from malnutrition_data);

UPDATE salud_mental_paciente t 
SET t.malnutrition  = FALSE 
WHERE t.malnutrition  IS NULL;

-- ------------- Indicators - diabetes -------------------------------------

DROP TABLE IF EXISTS diabetes_data;
CREATE TEMPORARY TABLE diabetes_data AS 
	 SELECT patient_id
	 FROM patient_program pp WHERE program_id=@Diabetes
	 GROUP BY patient_id;

update salud_mental_paciente t 
set t.diabetes = true 
where t.Patient_id in (select patient_id from diabetes_data);

UPDATE salud_mental_paciente t 
SET t.diabetes  = FALSE 
WHERE t.diabetes  IS NULL;

-- ------------- Indicators - epilepsy -------------------------------------

DROP TABLE IF EXISTS epilepsy_data;
CREATE TEMPORARY TABLE epilepsy_data AS 
	 SELECT patient_id
	 FROM patient_program pp WHERE program_id=@Epilepsy
	 GROUP BY patient_id;

update salud_mental_paciente t 
set t.epilepsy = true 
where t.Patient_id in (select patient_id from epilepsy_data);
	
UPDATE salud_mental_paciente t 
SET t.epilepsy  = FALSE 
WHERE t.epilepsy  IS NULL;

-- ------------- Indicators - hypertension -------------------------------------

DROP TABLE IF EXISTS hypertension_data;
CREATE TEMPORARY TABLE hypertension_data AS 
	 SELECT patient_id
	 FROM patient_program pp WHERE program_id=@Hypertension
	 GROUP BY patient_id;

update salud_mental_paciente t 
set t.hypertension = true 
where t.Patient_id in (select patient_id from hypertension_data);
	
UPDATE salud_mental_paciente t 
SET t.hypertension  = FALSE 
WHERE t.hypertension  IS NULL;

-- ------------- Indicators - Comorbidity -------------------------------------

UPDATE salud_mental_paciente t 
SET t.Comorbidity = CASE WHEN t.asthma OR t.hypertension  OR t.diabetes  OR t.epilepsy OR t.malnutrition 
THEN TRUE ELSE FALSE END;

-- ------------- Next Appointment -------------------------------------

SELECT concept_id INTO @next_appt FROM concept WHERE uuid='3ce94df0-26fe-102b-80cb-0017a47871b2';

UPDATE salud_mental_paciente t 
SET t.date_next_appointment  = (
SELECT cast(value_datetime AS date)
FROM obs o
WHERE concept_id=@next_appt
AND o.person_id=t.patient_id 
ORDER BY o.encounter_id DESC 
LIMIT 1
);


-- ------------- Indicators - psychosis -------------------------------------

DROP TABLE IF EXISTS psychosis_data;
CREATE TEMPORARY TABLE psychosis_data AS 
	 SELECT person_id, COUNT(1) AS num_obs
	 FROM obs WHERE (
	   	value_coded =concept_from_mapping('PIH',467) OR -- Schizophrenia
	   	value_coded =concept_from_mapping('PIH',9519) OR -- Acute psychosis
	   	value_coded =concept_from_mapping('PIH',219) OR -- psychosis
	   	value_coded =concept_from_mapping('PIH',9520) OR -- Mania without psychotic symptoms
	   	value_coded =concept_from_mapping('PIH',9520) -- Mania with psychotic symptoms
	 				)
	 GROUP BY person_id;
	
UPDATE salud_mental_paciente t 
SET t.psychosis  = (
 SELECT CASE WHEN num_obs > 0 THEN TRUE ELSE FALSE END 
 FROM psychosis_data md
 WHERE md.person_id=t.Patient_id 
);

UPDATE salud_mental_paciente t 
SET t.psychosis  = FALSE 
WHERE t.psychosis  IS NULL;

-- ------------- Indicators - mood disorder -------------------------------------

DROP TABLE IF EXISTS mood_disorder_data;
CREATE TEMPORARY TABLE mood_disorder_data AS 
	 SELECT person_id, COUNT(1) AS num_obs
	 FROM obs WHERE (
	   	value_coded =concept_from_mapping('PIH',7947) OR -- bipolar disorder
	   	value_coded =concept_from_mapping('PIH',207) -- OR -- depression
	   	-- concept_id=2388 -- mood changes
	 				)
	 GROUP BY person_id;
	
UPDATE salud_mental_paciente t 
SET t.mood_disorder  = (
 SELECT CASE WHEN num_obs > 0 THEN TRUE ELSE FALSE END 
 FROM mood_disorder_data md
 WHERE md.person_id=t.Patient_id 
);

UPDATE salud_mental_paciente t 
SET t.mood_disorder  = FALSE 
WHERE t.mood_disorder  IS NULL;


-- ------------- Indicators - anxiety -------------------------------------
DROP TABLE IF EXISTS anxiety_data;
CREATE TEMPORARY TABLE anxiety_data AS 
	 SELECT person_id, COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	value_coded=concept_from_mapping('PIH',9330) OR -- panick attack
	   	value_coded=concept_from_mapping('PIH',9517) OR -- generalised anxiety disorder
	   	value_coded=concept_from_mapping('PIH',2719) OR -- anxiety
	   	value_coded=concept_from_mapping('PIH',7513) OR -- obsessive-compulsive disorder
	   	value_coded=concept_from_mapping('PIH',7950) OR  -- acute stress reaction
	   	value_coded=concept_from_mapping('PIH',7197) -- post-traumatic stress disorder
	 				)
	 GROUP BY person_id;
	
UPDATE salud_mental_paciente t 
SET t.anxiety = (
 SELECT CASE WHEN num_obs > 0 THEN TRUE ELSE FALSE END 
 FROM anxiety_data md
 WHERE md.person_id=t.Patient_id 
);

UPDATE salud_mental_paciente t 
SET t.anxiety  = FALSE 
WHERE t.anxiety  IS NULL;


-- ------------- Indicators - adaptive disorders -------------------------------------
SELECT concept_id INTO @grief FROM concept WHERE uuid='139251AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';

drop table if exists adaptive_disorders_data;
CREATE TEMPORARY TABLE adaptive_disorders_data AS 
	 SELECT person_id, COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	value_coded= @grief
	 				)
	 GROUP BY person_id;
	
UPDATE salud_mental_paciente t 
SET t.adaptive_disorders  = (
 SELECT CASE WHEN num_obs > 0 THEN TRUE ELSE FALSE END 
 FROM  adaptive_disorders_data md
 WHERE md.person_id=t.Patient_id 
);

UPDATE salud_mental_paciente t 
SET t.adaptive_disorders  = FALSE 
WHERE t.adaptive_disorders  IS NULL;


-- ------------- Indicators - dissociative disorders -------------------------------------

DROP TABLE IF EXISTS dissociative_disorders_data;
CREATE TEMPORARY TABLE dissociative_disorders_data AS 
	 SELECT person_id, COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	value_coded=concept_from_mapping('PIH',7945)
	 				)
	 GROUP BY person_id;
	
UPDATE salud_mental_paciente t 
SET t.dissociative_disorders  = (
 SELECT CASE WHEN num_obs > 0 THEN TRUE ELSE FALSE END 
 FROM  dissociative_disorders_data md
 WHERE md.person_id=t.Patient_id 
);

UPDATE salud_mental_paciente t 
SET t.dissociative_disorders  = FALSE 
WHERE t.dissociative_disorders  IS NULL;

-- ------------- Indicators - psychosomatic disorders -------------------------------------

DROP TABLE IF EXISTS psychosomatic_disorders_data;
CREATE TEMPORARY TABLE psychosomatic_disorders_data AS 
	 SELECT person_id, COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	value_coded=concept_from_mapping('PIH',7198)
	 				)
	 GROUP BY person_id;

	
UPDATE salud_mental_paciente t 
SET t.psychosomatic_disorders  = (
 SELECT CASE WHEN num_obs > 0 THEN TRUE ELSE FALSE END 
 FROM  psychosomatic_disorders_data md
 WHERE md.person_id=t.Patient_id 
);

UPDATE salud_mental_paciente t 
SET t.psychosomatic_disorders  = FALSE 
WHERE t.psychosomatic_disorders  IS NULL;

-- ------------- Indicators - eating disorders -------------------------------------

DROP TABLE IF EXISTS eating_disorders_data;
CREATE TEMPORARY TABLE eating_disorders_data AS 
	 SELECT person_id, COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	value_coded=concept_from_mapping('PIH',7944)
	 				)
	 GROUP BY person_id;

	
UPDATE salud_mental_paciente t 
SET t.eating_disorders  = (
 SELECT CASE WHEN num_obs > 0 THEN TRUE ELSE FALSE END 
 FROM  eating_disorders_data md
 WHERE md.person_id=t.Patient_id 
);

UPDATE salud_mental_paciente t 
SET t.eating_disorders  = FALSE 
WHERE t.eating_disorders  IS NULL;

-- ------------- Indicators - personality disorders -------------------------------------

DROP TABLE IF EXISTS personality_disorders_data;
CREATE TEMPORARY TABLE personality_disorders_data AS 
	 SELECT person_id, COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	value_coded=concept_from_mapping('PIH',7943)
	 				)
	 GROUP BY person_id;

	
UPDATE salud_mental_paciente t 
SET t.personality_disorders  = (
 SELECT CASE WHEN num_obs > 0 THEN TRUE ELSE FALSE END 
 FROM  personality_disorders_data md
 WHERE md.person_id=t.Patient_id 
);

UPDATE salud_mental_paciente t 
SET t.personality_disorders  = FALSE 
WHERE t.personality_disorders  IS NULL;

-- ------------- Indicators - conduct disorders -------------------------------------
DROP TABLE IF EXISTS conduct_disorders_data;
CREATE TEMPORARY TABLE conduct_disorders_data AS 
	 SELECT person_id, COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	value_coded=concept_from_mapping('PIH',7949) OR -- conduct disorder
	   	value_coded=concept_from_mapping('PIH',11862) -- attention deficit
	   	-- concept_id=2356 -- oppositional deficit
	 				)
	 GROUP BY person_id;

	
UPDATE salud_mental_paciente t 
SET t.conduct_disorders  = (
 SELECT CASE WHEN num_obs > 0 THEN TRUE ELSE FALSE END 
 FROM  personality_disorders_data md
 WHERE md.person_id=t.Patient_id 
);


UPDATE salud_mental_paciente t 
SET t.conduct_disorders  = FALSE 
WHERE t.conduct_disorders  IS NULL;

-- ------------- Indicators - suicidal -------------------------------------
DROP TABLE IF EXISTS suicidal_data;
CREATE TEMPORARY TABLE suicidal_data AS 
	 SELECT person_id, COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	value_coded=concept_from_mapping('PIH',10633) -- suicidal thoughts
	   	OR value_coded=concept_from_mapping('PIH',7514) -- attempted suicide
	 				)
	 GROUP BY person_id;

	
UPDATE salud_mental_paciente t 
SET t.suicidal_ideation  = (
 SELECT CASE WHEN num_obs > 0 THEN TRUE ELSE FALSE END 
 FROM  suicidal_data md
 WHERE md.person_id=t.Patient_id 
);

UPDATE salud_mental_paciente t 
SET t.suicidal_ideation  = FALSE 
WHERE t.suicidal_ideation  IS NULL;

-- ------------- Indicators - grief -------------------------------------
DROP TABLE IF EXISTS grief_data;
CREATE TEMPORARY TABLE grief_data AS 
	 SELECT person_id, COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	value_coded=concept_from_mapping('PIH',6896) -- grief
	 				)
	 GROUP BY person_id;

	
UPDATE salud_mental_paciente t 
SET t.grief  = (
 SELECT CASE WHEN num_obs > 0 THEN TRUE ELSE FALSE END 
 FROM  grief_data md
 WHERE md.person_id=t.Patient_id 
);

UPDATE salud_mental_paciente t 
SET t.grief  = FALSE 
WHERE t.grief  IS NULL;

-- ------------- PHQ-9 Score Data -------------------------------------

UPDATE salud_mental_paciente t 
SET t.First_PHQ9_score  = (
	 SELECT  value_numeric
	 FROM obs WHERE concept_id=concept_from_mapping('PIH',11586) AND person_id=t.Patient_id
	 ORDER BY person_id , obs_datetime ASC
	LIMIT 1
);

UPDATE salud_mental_paciente t 
SET t.Date_first_PHQ9 = (
	 SELECT  CAST(obs_datetime AS date)
	 FROM obs WHERE concept_id=concept_from_mapping('PIH',11586) AND person_id=t.Patient_id
	 ORDER BY person_id , obs_datetime ASC
	LIMIT 1
);

UPDATE salud_mental_paciente t 
SET t.Date_most_recent_PHQ9 = (
	 SELECT  CAST(obs_datetime AS date)
	 FROM obs WHERE concept_id=concept_from_mapping('PIH',11586)  AND person_id=t.Patient_id
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_paciente t 
SET t.Most_recent_PHQ9 = (
	 SELECT  value_numeric
	 FROM obs WHERE concept_id=concept_from_mapping('PIH',11586)  AND person_id=t.Patient_id
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);


-- ------------- GAD-7 Score Data -------------------------------------

UPDATE salud_mental_paciente t 
SET t.First_GAD7_score = (
	 SELECT  value_numeric
	 FROM obs WHERE concept_id=concept_from_mapping('PIH',11733) AND person_id=t.Patient_id
	 ORDER BY person_id , obs_datetime ASC
	LIMIT 1
);

UPDATE salud_mental_paciente t 
SET t.Date_first_GAD7  = (
	 SELECT  CAST(obs_datetime AS date)
	 FROM obs WHERE concept_id=concept_from_mapping('PIH',11733)  AND person_id=t.Patient_id
	 ORDER BY person_id , obs_datetime ASC
	LIMIT 1
);

UPDATE salud_mental_paciente t 
SET t.Date_most_recent_GAD7  = (
	 SELECT  CAST(obs_datetime AS date)
	 FROM obs WHERE concept_id=concept_from_mapping('PIH',11733)  AND person_id=t.Patient_id
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_paciente t 
SET t.Most_recent_GAD7  = (
	 SELECT  value_numeric
	 FROM obs WHERE concept_id=concept_from_mapping('PIH',11733)  AND person_id=t.Patient_id
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

-- ------------- PHQ-9 & GAD-7  Questions -------------------------------------

SELECT concept_id INTO @never FROM concept WHERE uuid='3cd72968-26fe-102b-80cb-0017a47871b2';
SELECT concept_id INTO @somedays FROM concept WHERE uuid='3cdc3fe8-26fe-102b-80cb-0017a47871b2';
SELECT concept_id INTO @morethanhalf FROM concept WHERE uuid='1cf6ebb8-dd57-4d26-87cd-e49c09373aaf';
SELECT concept_id INTO @daily FROM concept WHERE uuid='3cd73912-26fe-102b-80cb-0017a47871b2';
SELECT concept_id INTO @little_interest FROM concept WHERE uuid='85bdc2d2-afaa-4d5e-bc6b-ee8277d160f1';
SELECT concept_id INTO @down_depressed FROM concept WHERE uuid='01bf95d6-bcd0-44fb-8752-3da72f71ab6d';
SELECT concept_id INTO @hard_Failing_sleep FROM concept WHERE uuid='c85fc943-b747-4d72-a0a8-6ca2dc8fb568';
SELECT concept_id INTO @feeling_tired FROM concept WHERE uuid='8a034046-5fea-4253-a105-3af86b0679fe';
SELECT concept_id INTO @eating_less FROM concept WHERE uuid='a34eb8de-4272-4da5-b785-6462dfb97cc2';
SELECT concept_id INTO @failed_someone FROM concept WHERE uuid='4306e155-d299-46d0-9472-51c88fb196a7';
SELECT concept_id INTO @distract_easily FROM concept WHERE uuid='476ec75b-a7d0-4e07-889a-d3700f03acd3';
SELECT concept_id INTO @feels_slower FROM concept WHERE uuid='5bc6e1a8-91a6-49ef-b879-715c524abd98';
SELECT concept_id INTO @suicidal_thoughts FROM concept WHERE uuid='996e915c-ed3a-4c67-834b-a7cb98f8248b';
SELECT concept_id INTO @feel_nervous FROM concept WHERE uuid='8f7bc995-9b4a-4c99-9301-3029130c3aae';
SELECT concept_id INTO @no_stop_worry FROM concept WHERE uuid='bce099ca-d69f-48d0-bb87-d2c7ff4ca5c7';
SELECT concept_id INTO @worry_much FROM concept WHERE uuid='f808bce8-4c0b-43ce-a187-1c209cb1c830';
SELECT concept_id INTO @diff_relaxing FROM concept WHERE uuid='2c1bdb4f-c432-4987-aba6-045ed9c53ea5';
SELECT concept_id INTO @so_restless FROM concept WHERE uuid='fdee3750-0aa7-47c3-8c0b-c86ffe7e9b60';
SELECT concept_id INTO @upset_easily FROM concept WHERE uuid='e4ecb39a-d295-48bb-920c-ef3298b5cd49';
SELECT concept_id INTO @feeling_scared FROM concept WHERE uuid='bf6c5967-339a-43c3-ab74-43e14638fe4c';

UPDATE salud_mental_paciente t 
SET t.PHQ9_q1 = (
	 SELECT  CASE WHEN value_coded=@never THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@little_interest AND person_id=t.Patient_id
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_paciente t 
SET t.PHQ9_q2 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@down_depressed   AND person_id=t.Patient_id
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_paciente t 
SET t.PHQ9_q3 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@hard_Failing_sleep  AND person_id=t.Patient_id
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_paciente t 
SET t.PHQ9_q4 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@feeling_tired AND person_id=t.Patient_id
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_paciente t 
SET t.PHQ9_q5 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@eating_less AND person_id=t.Patient_id
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_paciente t 
SET t.PHQ9_q6 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@failed_someone AND person_id=t.Patient_id
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_paciente t 
SET t.PHQ9_q7 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@distract_easily AND person_id=t.Patient_id
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_paciente t 
SET t.PHQ9_q8 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END
	 FROM obs WHERE concept_id=@feels_slower AND person_id=t.Patient_id
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_paciente t 
SET t.PHQ9_q9 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END
	 FROM obs WHERE concept_id= @suicidal_thoughts  AND person_id=t.Patient_id
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_paciente t 
SET t.GAD7_q1 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@feel_nervous AND person_id=t.Patient_id
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_paciente t 
SET t.GAD7_q2 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@no_stop_worry AND person_id=t.Patient_id
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_paciente t 
SET t.GAD7_q3 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@worry_much  AND person_id=t.Patient_id
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_paciente t 
SET t.GAD7_q4 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END  
	 FROM obs WHERE concept_id=@diff_relaxing  AND person_id=t.Patient_id
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_paciente t 
SET t.GAD7_q5 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END
	 FROM obs WHERE concept_id=@so_restless AND person_id=t.Patient_id
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_paciente t 
SET t.GAD7_q6 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END
	 FROM obs WHERE concept_id=@upset_easily AND person_id=t.Patient_id
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_paciente t 
SET t.GAD7_q7 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@feeling_scared AND person_id=t.Patient_id
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);


SELECT 
dbname,
emr_id	,
age	,
gender	,
dead	,
death_Date	,
mh_enrolled, 
most_recent_mental_health_enc	,
number_mental_health_enc	,
mental_health_enc_enroll_date	,
reg_location	,
recent_mental_status	,
recent_mental_status_date	,
active	,
asthma	,
malnutrition	,
diabetes	,
epilepsy	,
hypertension	,
Comorbidity	,
date_next_appointment	,
psychosis	,
mood_disorder	,
anxiety	,
adaptive_disorders	,
dissociative_disorders	,
psychosomatic_disorders	,
eating_disorders	,
personality_disorders	,
conduct_disorders	,
suicidal_ideation	,
grief	,
First_PHQ9_score	,
Date_first_PHQ9	,
Date_most_recent_PHQ9	,
PHQ9_q1	,
PHQ9_q2	,
PHQ9_q3	,
PHQ9_q4	,
PHQ9_q5	,
PHQ9_q6	,
PHQ9_q7	,
PHQ9_q8	,
PHQ9_q9	,
Most_recent_PHQ9	,
First_GAD7_score	,
Date_first_GAD7	,
Date_most_recent_GAD7	,
GAD7_q1	,
GAD7_q2	,
GAD7_q3	,
GAD7_q4	,
GAD7_q5	,
GAD7_q6	,
GAD7_q7	,
Most_recent_GAD7
FROM salud_mental_paciente smp
where reg_location is not null;
