SELECT name  INTO @encounter_type_name FROM encounter_type et WHERE et.uuid ='a8584ab8-cc2a-11e5-9956-625662870761';
SELECT encounter_type_id  INTO @encounter_type_id FROM encounter_type et WHERE et.uuid ='a8584ab8-cc2a-11e5-9956-625662870761';
SELECT program_id INTO @program_id FROM program p WHERE uuid='0e69c3ab-1ccb-430b-b0db-b9760319230f';
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
change_in_PHQ9 decimal(4,2),
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
change_in_GAD7	decimal,
GAD7_q1	int,
GAD7_q2	int,
GAD7_q3	int,
GAD7_q4	int,
GAD7_q5	int,
GAD7_q6	int,
GAD7_q7	int,
Most_recent_GAD7	int
);


-- ############### Views Defintions ##############################################################

SELECT concept_id INTO @phq1 FROM concept_name WHERE uuid='1c72efc9-ead3-4163-ad81-89f5b2e76f30';
SELECT concept_id INTO @phq2 FROM concept_name WHERE uuid='22c7f8f1-4a6d-4134-9eb9-159b880ee520';
SELECT concept_id INTO @phq3 FROM concept_name WHERE uuid='2ee95a31-9252-4e3c-8f4e-4b04c6800b2e';
SELECT concept_id INTO @phq4 FROM concept_name WHERE uuid='b1d55936-4e3a-4937-a43a-f49a4fc79d01';
SELECT concept_id INTO @phq5 FROM concept_name WHERE uuid='3ad37078-04ab-4ce0-b57e-0114ac67d909';
SELECT concept_id INTO @phq6 FROM concept_name WHERE uuid='c2fda6f0-662b-4b18-9ae6-7964ece54076';
SELECT concept_id INTO @phq7 FROM concept_name WHERE uuid='b0a8838b-ad87-46d1-9ed4-ed932fd85464';
SELECT concept_id INTO @phq8 FROM concept_name WHERE uuid='4039e3f8-bde7-48bf-b6a8-e988065ddfab';
SELECT concept_id INTO @phq9 FROM concept_name WHERE uuid='8e2ad0bb-f5cc-4426-ab1a-903bc3a7d308';
SELECT concept_id INTO @gdq1 FROM concept_name WHERE uuid='6429df5e-ecf2-4cd3-b094-c1d2d1f2ba78';
SELECT concept_id INTO @gdq2 FROM concept_name WHERE uuid='40ed4b2e-2e4c-4a03-8e8c-64ea6641aacd';
SELECT concept_id INTO @gdq3 FROM concept_name WHERE uuid='2bc5d8c6-4dde-4c7c-a005-3440fdce5287';
SELECT concept_id INTO @gdq4 FROM concept_name WHERE uuid='fd7b9dc1-9ef8-4471-9524-e42186bee719';
SELECT concept_id INTO @gdq5 FROM concept_name WHERE uuid='a262cb01-9dc5-428b-a42f-6dee85c0ae3a';
SELECT concept_id INTO @gdq6 FROM concept_name WHERE uuid='9c2c2976-cb2d-465c-8ce0-6e7591480473';
SELECT concept_id INTO @gdq7 FROM concept_name WHERE uuid='1cf903a8-d4cf-4cb4-8558-bf1f678d7513';
SELECT concept_id INTO @phqscore FROM concept_name WHERE uuid='19313bdf-fa55-4201-a644-2543756d2b0c';
SELECT concept_id INTO @gadscore FROM concept_name WHERE uuid='2b829a3b-fd04-4989-b7d1-40c9d25dbdfc';

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

CREATE OR REPLACE VIEW patient_list AS
SELECT DISTINCT  p.patient_id, pi2.identifier emr_id
FROM patient p INNER JOIN patient_identifier pi2 ON p.patient_id =pi2.patient_id
WHERE p.patient_id IN (
	SELECT DISTINCT patient_id FROM mental_patients_list
)
GROUP BY p.patient_id 
UNION
SELECT DISTINCT  p.patient_id, pi2.identifier emr_id
FROM patient p INNER JOIN patient_identifier pi2 ON p.patient_id =pi2.patient_id
WHERE p.patient_id IN (
	SELECT DISTINCT patient_id FROM mental_encounter_details
)
GROUP BY p.patient_id;


-- ################# Insert Patinets List ##############################################################
INSERT INTO salud_mental_paciente (patient_id, emr_id, age, gender, dead, death_date)
SELECT pl.patient_id,pl.emr_id ,current_age_in_years(p.person_id),  p.gender, p.dead, p.death_date
FROM patient_list pl
INNER JOIN (SELECT person_id,gender, dead, death_date 
						FROM person
						GROUP BY person_id) p ON pl.patient_id=p.person_id;
					
UPDATE salud_mental_paciente t
SET t.dbname=@dbname;

-- ############### Mental Encounters Columns #####################################
					
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

-- ############# Mental Health Enrollment Details #####################################
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
SET t.reg_location =loc_registered(Patient_id);

-- ############# Mental Health Program Status #####################################
UPDATE salud_mental_paciente t 
SET t.recent_mental_status = (
	SELECT concept_name(pws.concept_id , 'en') AS ncd_status -- ,  ps.start_date
	from patient_state ps
	INNER JOIN patient_program pp ON pp.patient_program_id =ps.patient_program_id 
	inner join program_workflow_state pws on pws.program_workflow_state_id = ps.state 
	WHERE  pp.program_id =@program_id
	AND pp.patient_id = t.patient_id 
	ORDER BY ps.start_date DESC , concept_name(pws.concept_id , 'en')   ASC 
	LIMIT 1
);

UPDATE salud_mental_paciente t 
SET t.recent_mental_status_date = (
	SELECT ps.start_date
	from patient_state ps
	INNER JOIN patient_program pp ON pp.patient_program_id =ps.patient_program_id 
	inner join program_workflow_state pws on pws.program_workflow_state_id = ps.state 
	WHERE  pp.program_id =@program_id
	AND pp.patient_id = t.patient_id 
	ORDER BY ps.start_date DESC , concept_name(pws.concept_id , 'en')   ASC 
	LIMIT 1
);


-- ############# Mental Health Active #####################################

UPDATE salud_mental_paciente t 
SET t.active =(
	SELECT CASE WHEN TIMESTAMPDIFF(MONTH, t.most_recent_mental_health_enc, now()) <=6 THEN TRUE ELSE FALSE END
);

-- ############# Indicators - asma #####################################

DROP TABLE IF EXISTS asma_data;
CREATE TEMPORARY TABLE asma_data AS 
	 SELECT person_id, COUNT(1) AS num_obs
	 FROM obs WHERE concept_id=concept_from_mapping('PIH',5)
	 GROUP BY person_id;
	
UPDATE salud_mental_paciente t 
SET t.asthma = (
 SELECT CASE WHEN num_obs > 0 THEN TRUE ELSE FALSE END 
 FROM asma_data ad
 WHERE ad.person_id=t.Patient_id 
);

UPDATE salud_mental_paciente t 
SET t.asthma = FALSE 
WHERE t.asthma IS NULL;

-- ############# Indicators - malnutrition #####################################


DROP TABLE IF EXISTS malnutrition_data;
CREATE TEMPORARY TABLE malnutrition_data AS 
	 SELECT person_id, COUNT(1) AS num_obs
	 FROM obs WHERE concept_id=concept_from_mapping('PIH',68)
	 GROUP BY person_id;

UPDATE salud_mental_paciente t 
SET t.malnutrition  = (
 SELECT CASE WHEN num_obs > 0 THEN TRUE ELSE FALSE END 
 FROM malnutrition_data md
 WHERE md.person_id=t.Patient_id 
);

UPDATE salud_mental_paciente t 
SET t.malnutrition  = FALSE 
WHERE t.malnutrition  IS NULL;

-- ############# Indicators - diabetes #####################################

DROP TABLE IF EXISTS diabetes_data;
CREATE TEMPORARY TABLE diabetes_data AS 
	 SELECT person_id, COUNT(1) AS num_obs
	 FROM obs WHERE concept_id=concept_from_mapping('PIH',3720) -- asma IN es locale
	 GROUP BY person_id;
	
UPDATE salud_mental_paciente t 
SET t.diabetes  = (
 SELECT CASE WHEN num_obs > 0 THEN TRUE ELSE FALSE END 
 FROM diabetes_data md
 WHERE md.person_id=t.Patient_id 
);

UPDATE salud_mental_paciente t 
SET t.diabetes  = FALSE 
WHERE t.diabetes  IS NULL;

-- ############# Indicators - epilepsy #####################################

DROP TABLE IF EXISTS epilepsy_data;
CREATE TEMPORARY TABLE epilepsy_data AS 
	 SELECT person_id, COUNT(1) AS num_obs
	 FROM obs WHERE concept_id=concept_from_mapping('PIH',155)
	 GROUP BY person_id;
	
UPDATE salud_mental_paciente t 
SET t.epilepsy  = (
 SELECT CASE WHEN num_obs > 0 THEN TRUE ELSE FALSE END 
 FROM epilepsy_data md
 WHERE md.person_id=t.Patient_id 
);

UPDATE salud_mental_paciente t 
SET t.epilepsy  = FALSE 
WHERE t.epilepsy  IS NULL;

-- ############# Indicators - hypertension #####################################

DROP TABLE IF EXISTS hypertension_data;
CREATE TEMPORARY TABLE hypertension_data AS 
	 SELECT person_id, COUNT(1) AS num_obs
	 FROM obs WHERE concept_id=concept_from_mapping('PIH',903)
	 GROUP BY person_id;
	
UPDATE salud_mental_paciente t 
SET t.hypertension  = (
 SELECT CASE WHEN num_obs > 0 THEN TRUE ELSE FALSE END 
 FROM hypertension_data md
 WHERE md.person_id=t.Patient_id 
);

UPDATE salud_mental_paciente t 
SET t.hypertension  = FALSE 
WHERE t.hypertension  IS NULL;

-- ############# Indicators - Comorbidity #####################################

UPDATE salud_mental_paciente t 
SET t.Comorbidity = CASE WHEN t.asthma OR t.hypertension  OR t.diabetes  OR t.epilepsy OR t.malnutrition 
THEN TRUE ELSE FALSE END;

-- ############# Next Appointment #####################################

SELECT concept_id INTO @next_appt FROM concept_name cn WHERE uuid='66f5aa60-10fb-40a9-bcd3-7940980eddca';

UPDATE salud_mental_paciente t 
SET t.date_next_appointment  = (
SELECT cast(value_datetime AS date)
FROM obs o
WHERE concept_id=@next_appt
AND o.person_id=t.patient_id 
ORDER BY o.encounter_id DESC 
LIMIT 1
);


-- ############# Indicators - psychosis #####################################

DROP TABLE IF EXISTS psychosis_data;
CREATE TEMPORARY TABLE psychosis_data AS 
	 SELECT person_id, COUNT(1) AS num_obs
	 FROM obs WHERE (
	   	concept_id=concept_from_mapping('PIH',467) OR -- Schizophrenia
	   	concept_id=concept_from_mapping('PIH',9519) OR -- Acute psychosis
	   	concept_id=concept_from_mapping('PIH',219) OR -- psychosis
	   	concept_id=concept_from_mapping('PIH',9520) OR -- Mania without psychotic symptoms
	   	concept_id=concept_from_mapping('PIH',9520) -- Mania with psychotic symptoms
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

-- ############# Indicators - mood disorder #####################################

DROP TABLE IF EXISTS mood_disorder_data;
CREATE TEMPORARY TABLE mood_disorder_data AS 
	 SELECT person_id, COUNT(1) AS num_obs
	 FROM obs WHERE (
	   	concept_id=concept_from_mapping('PIH',7947) OR -- bipolar disorder
	   	concept_id=concept_from_mapping('PIH',207) -- OR -- depression
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


-- ############# Indicators - anxiety #####################################
DROP TABLE IF EXISTS anxiety_data;
CREATE TEMPORARY TABLE anxiety_data AS 
	 SELECT person_id, COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	concept_id=concept_from_mapping('PIH',9330) OR -- panick attack
	   	concept_id=concept_from_mapping('PIH',9517) OR -- generalised anxiety disorder
	   	concept_id=concept_from_mapping('PIH',2719) OR -- anxiety
	   	concept_id=concept_from_mapping('PIH',7513) OR -- obsessive-compulsive disorder
	   	concept_id=concept_from_mapping('PIH',7950) OR  -- acute stress reaction
	   	concept_id=concept_from_mapping('PIH',7197) -- post-traumatic stress disorder
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


-- ############# Indicators - adaptive disorders #####################################

-- CREATE TEMPORARY TABLE adaptive_disorders_data AS 
-- 	 SELECT person_id, COUNT(*) AS num_obs
-- 	 FROM obs WHERE (
-- 	   	concept_id=
-- 	 				)
-- 	 GROUP BY person_id;
-- 	
-- UPDATE salud_mental_paciente t 
-- SET t.adaptive_disorders  nx  = (
--  SELECT CASE WHEN num_obs > 0 THEN TRUE ELSE FALSE END 
--  FROM  adaptive_disorders_data md
--  WHERE md.person_id=t.Patient_id 
-- );
-- 
-- UPDATE salud_mental_paciente t 
-- SET t.adaptive_disorders  = FALSE 
-- WHERE t.adaptive_disorders  IS NULL;


-- ############# Indicators - dissociative disorders #####################################

DROP TABLE IF EXISTS dissociative_disorders_data;
CREATE TEMPORARY TABLE dissociative_disorders_data AS 
	 SELECT person_id, COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	concept_id=concept_from_mapping('PIH',7945)
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

-- ############# Indicators - psychosomatic disorders #####################################

DROP TABLE IF EXISTS psychosomatic_disorders_data;
CREATE TEMPORARY TABLE psychosomatic_disorders_data AS 
	 SELECT person_id, COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	concept_id=concept_from_mapping('PIH',7198)
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

-- ############# Indicators - eating disorders #####################################

DROP TABLE IF EXISTS eating_disorders_data;
CREATE TEMPORARY TABLE eating_disorders_data AS 
	 SELECT person_id, COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	concept_id=concept_from_mapping('PIH',7944)
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

-- ############# Indicators - personality disorders #####################################

DROP TABLE IF EXISTS personality_disorders_data;
CREATE TEMPORARY TABLE personality_disorders_data AS 
	 SELECT person_id, COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	concept_id=concept_from_mapping('PIH',7943)
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

-- ############# Indicators - conduct disorders #####################################
DROP TABLE IF EXISTS conduct_disorders_data;
CREATE TEMPORARY TABLE conduct_disorders_data AS 
	 SELECT person_id, COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	concept_id=concept_from_mapping('PIH',7949) OR -- conduct disorder
	   	concept_id=concept_from_mapping('PIH',11862) -- attention deficit
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

-- ############# Indicators - suicidal #####################################
DROP TABLE IF EXISTS suicidal_data;
CREATE TEMPORARY TABLE suicidal_data AS 
	 SELECT person_id, COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	concept_id=concept_from_mapping('PIH',10633) -- suicidal thoughts
	   	OR concept_id=concept_from_mapping('PIH',7514) -- attempted suicide
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

-- ############# Indicators - grief #####################################
DROP TABLE IF EXISTS grief_data;
CREATE TEMPORARY TABLE grief_data AS 
	 SELECT person_id, COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	concept_id=concept_from_mapping('PIH',6896) -- grief
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

-- ############# PHQ-9 Score Data #####################################

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

UPDATE salud_mental_paciente t 
SET t.change_in_PHQ9 = (Most_recent_PHQ9 - First_PHQ9_score) / First_PHQ9_score 
WHERE Date_first_PHQ9 IS NOT NULL
AND Date_first_PHQ9 <> Date_most_recent_PHQ9 
;

-- ############# GAD-7 Score Data #####################################

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

UPDATE salud_mental_paciente t 
SET t.change_in_GAD7  = (Most_recent_GAD7  - First_GAD7_score) / First_GAD7_score  
WHERE Date_first_GAD7  IS NOT NULL
AND Date_first_GAD7  <> Date_most_recent_GAD7 
;

-- ############# PHQ-9 & GAD-7  Questions #####################################

SELECT concept_id INTO @never  FROM concept_name cn WHERE uuid='3e154cc4-26fe-102b-80cb-0017a47871b2';
SELECT concept_id INTO @somedays  FROM concept_name cn WHERE uuid='0b7c1594-15f5-102d-96e4-000c29c2a5d7';
SELECT concept_id INTO @morethanhalf  FROM concept_name cn WHERE uuid='a3194e05-8c29-4796-a990-e6ffe11fbee6';
SELECT concept_id INTO @daily  FROM concept_name cn WHERE uuid='3e1565e2-26fe-102b-80cb-0017a47871b2';
SELECT concept_id INTO @little_interest  FROM concept_name cn WHERE uuid='1c72efc9-ead3-4163-ad81-89f5b2e76f30';

UPDATE salud_mental_paciente t 
SET t.PHQ9_q1 = (
	 SELECT  CASE WHEN value_coded=@never THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@little_interest -- AND person_id=t.Patient_id
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

SELECT concept_id INTO @down_depressed  FROM concept_name cn WHERE uuid='22c7f8f1-4a6d-4134-9eb9-159b880ee520';
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

SELECT concept_id INTO @hard_Failing_sleep  FROM concept_name cn WHERE uuid='2ee95a31-9252-4e3c-8f4e-4b04c6800b2e';
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

SELECT concept_id INTO @feeling_tired  FROM concept_name cn WHERE uuid='b1d55936-4e3a-4937-a43a-f49a4fc79d01';
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

SELECT concept_id INTO @eating_less  FROM concept_name cn WHERE uuid='3ad37078-04ab-4ce0-b57e-0114ac67d909';
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

SELECT concept_id INTO @failed_someone  FROM concept_name cn WHERE uuid='c2fda6f0-662b-4b18-9ae6-7964ece54076';
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

SELECT concept_id INTO @distract_easily  FROM concept_name cn WHERE uuid='b0a8838b-ad87-46d1-9ed4-ed932fd85464';
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

SELECT concept_id INTO @feels_slower  FROM concept_name cn WHERE uuid='4039e3f8-bde7-48bf-b6a8-e988065ddfab';
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

SELECT concept_id INTO @suicidal_thoughts  FROM concept_name cn WHERE uuid='8e2ad0bb-f5cc-4426-ab1a-903bc3a7d308';
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

SELECT concept_id INTO @feel_nervous  FROM concept_name cn WHERE uuid='6429df5e-ecf2-4cd3-b094-c1d2d1f2ba78';
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

SELECT concept_id INTO @no_stop_worry  FROM concept_name cn WHERE uuid='40ed4b2e-2e4c-4a03-8e8c-64ea6641aacd';
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

SELECT concept_id INTO @worry_much  FROM concept_name cn WHERE uuid='2bc5d8c6-4dde-4c7c-a005-3440fdce5287';
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

SELECT concept_id INTO @diff_relaxing  FROM concept_name cn WHERE uuid='fd7b9dc1-9ef8-4471-9524-e42186bee719';
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

SELECT concept_id INTO @so_restless  FROM concept_name cn WHERE uuid='a262cb01-9dc5-428b-a42f-6dee85c0ae3a';
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

SELECT concept_id INTO @upset_easily  FROM concept_name cn WHERE uuid='9c2c2976-cb2d-465c-8ce0-6e7591480473';
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

SELECT concept_id INTO @feeling_scared  FROM concept_name cn WHERE uuid='1cf903a8-d4cf-4cb4-8558-bf1f678d7513';
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
Patient_id	,
emr_id	,
age	,
gender	,
dead	,
death_Date	,
mh_enrolled , 
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
change_in_PHQ9 ,
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
change_in_GAD7	,
GAD7_q1	,
GAD7_q2	,
GAD7_q3	,
GAD7_q4	,
GAD7_q5	,
GAD7_q6	,
GAD7_q7	,
Most_recent_GAD7
FROM salud_mental_paciente smp;