SELECT name  INTO @encounter_type_name FROM encounter_type et WHERE et.uuid ='a8584ab8-cc2a-11e5-9956-625662870761';
SELECT encounter_type_id  INTO @encounter_type_id FROM encounter_type et WHERE et.uuid ='a8584ab8-cc2a-11e5-9956-625662870761';
SELECT program_id INTO @program_id FROM program p WHERE uuid='0e69c3ab-1ccb-430b-b0db-b9760319230f';

DROP TABLE IF EXISTS salud_mental_encountero;
CREATE TEMPORARY TABLE salud_mental_encountero (
patient_id int,
emr_id varchar(30),
location varchar(30),
age int,
encounter_id int, 
encounter_date date, 
data_entry_date date,
data_entry_person varchar(30),
visit_id int,
mh_visit_date date,
provider_name varchar(30),
visit_Reason varchar(30),
case_notes varchar(255),
prenatal_care bit,
estimated_delivery_date date,
PHQ9_q1	int,
PHQ9_q2	int,
PHQ9_q3	int,
PHQ9_q4	int,
PHQ9_q5	int,
PHQ9_q6	int,
PHQ9_q7	int,
PHQ9_q8	int,
PHQ9_q9	int,
PHQ9_score int,
GAD7_q1	int,
GAD7_q2	int,
GAD7_q3	int,
GAD7_q4	int,
GAD7_q5	int,
GAD7_q6	int,
GAD7_q7	int,
GAD7_score int,
analysis_notes varchar(5000),
visit_end_status varchar(30),
diagnosis varchar(255), 
primary_diagnosis varchar(50),
psychosis bit,
mood_disorder bit,
anxiety bit,
adaptive_disorders bit,
dissociative_disorders bit,
psychosomatic_disorders bit,
eating_disorders bit,
personality_disorders bit,
conduct_disorders bit,
suicidal_ideation bit,
grief bit,
Treatment_plan varchar(5000),
lab_tests_ordered varchar(5000),
medication_1_name varchar(255),
medication_1_units int,
medication_1_instructions varchar(255),
medication_2_name varchar(255),
medication_2_units int,
medication_2_instructions varchar(255),
medication_3_name varchar(255),
medication_3_units int,
medication_3_instructions varchar(255),
medication_4_name varchar(255),
medication_4_units int,
medication_4_instructions varchar(255),
medication_5_name varchar(255),
medication_5_units int,
medication_5_instructions varchar(255),
medication_6_name varchar(255),
medication_6_units int,
medication_6_instructions varchar(255),
medication_7_name varchar(255),
medication_7_units int,
medication_7_instructions varchar(255),
medication_8_name varchar(255),
medication_8_units int,
medication_8_instructions varchar(255),
medication_9_name varchar(255),
medication_9_units int,
medication_9_instructions varchar(255),
medication_10_name varchar(255),
medication_10_units int,
medication_10_instructions varchar(255),
next_appointment date
);


############## Functions Definition ##############################################
-- CREATE FUNCTION age_at_enc(
--     _person_id int,
--     _encounter_id int
-- )
-- 	RETURNS DOUBLE
--     DETERMINISTIC
-- 
-- BEGIN
--     DECLARE ageAtEnc DOUBLE;
-- 
-- 	select  TIMESTAMPDIFF(YEAR, birthdate, encounter_datetime) into ageAtENC
-- 	from    encounter e
-- 	join    person p on p.person_id = e.patient_id
-- 	where   e.encounter_id = _encounter_id
-- 	and     p.person_id = _person_id;
-- 
--     RETURN ageAtEnc;
-- END

################# Views Defintions ##############################################################


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
SELECT DISTINCT person_id, encounter_id , obs_datetime 
FROM obs 
WHERE concept_id  IN (SELECT obs_id FROM mental_obs_ref )
;

CREATE OR REPLACE VIEW mental_encounter_details AS 
SELECT DISTINCT  encounter_id, patient_id, encounter_datetime, location_id , date_created , creator, visit_id  
FROM encounter e2 
WHERE encounter_id  IN (SELECT encounter_id FROM mental_encounters);

DROP TABLE IF EXISTS mental_patients_list;
CREATE TABLE mental_patients_list AS
SELECT DISTINCT patient_id FROM patient_program pp WHERE program_id =@program_id
;

CREATE OR REPLACE VIEW patient_identifier_v2 AS
SELECT DISTINCT patient_id,identifier
FROM  patient_identifier
GROUP BY patient_id;


CREATE OR REPLACE VIEW patient_list AS
SELECT DISTINCT  p.patient_id, pi2.identifier emr_id
FROM patient p LEFT OUTER JOIN patient_identifier_v2 pi2 ON p.patient_id =pi2.patient_id
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

################# Insert Patinets List ##############################################################
INSERT INTO salud_mental_encountero (patient_id, emr_id,location,age,encounter_id,encounter_date , data_entry_date,data_entry_person,visit_id,mh_visit_date ,
provider_name,visit_Reason)
SELECT DISTINCT me.patient_id ,pi2.identifier, l.name , age_at_enc(me.patient_id, me.encounter_id) AS age, 
			  me.encounter_id, cast(me.encounter_datetime AS date) AS encounter_date,
			  CAST(me.date_created AS date) AS data_entry_date, 
			  u.username AS data_entry_person,
			  me.visit_id,
			  CAST(v2.date_started AS date) AS mh_visit_date,
			  u.username  AS provider_name,
			  vt.name 
FROM mental_encounter_details me INNER JOIN patient_identifier pi2 ON me.patient_id = pi2.patient_id 
INNER JOIN location l ON me.location_id =l.location_id 
INNER JOIN users u ON u.user_id =me.creator 
INNER JOIN visit v2 ON v2.visit_id =me.visit_id 
INNER JOIN visit_type vt ON v2.visit_type_id =vt.visit_type_id;


############# PHQ-9 & GAD-7  Questions #####################################

SELECT concept_id INTO @never  FROM concept_name cn WHERE uuid='3e154cc4-26fe-102b-80cb-0017a47871b2';
SELECT concept_id INTO @somedays  FROM concept_name cn WHERE uuid='0b7c1594-15f5-102d-96e4-000c29c2a5d7';
SELECT concept_id INTO @morethanhalf  FROM concept_name cn WHERE uuid='a3194e05-8c29-4796-a990-e6ffe11fbee6';
SELECT concept_id INTO @daily  FROM concept_name cn WHERE uuid='3e1565e2-26fe-102b-80cb-0017a47871b2';
SELECT concept_id INTO @little_interest  FROM concept_name cn WHERE uuid='1c72efc9-ead3-4163-ad81-89f5b2e76f30';

UPDATE salud_mental_encountero t 
SET t.PHQ9_q1 = (
	 SELECT  CASE WHEN value_coded=@never THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@little_interest  AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

SELECT concept_id INTO @down_depressed  FROM concept_name cn WHERE uuid='22c7f8f1-4a6d-4134-9eb9-159b880ee520';
UPDATE salud_mental_encountero t 
SET t.PHQ9_q2 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@down_depressed   AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

SELECT concept_id INTO @hard_Failing_sleep  FROM concept_name cn WHERE uuid='2ee95a31-9252-4e3c-8f4e-4b04c6800b2e';
UPDATE salud_mental_encountero t 
SET t.PHQ9_q3 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@hard_Failing_sleep  AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

SELECT concept_id INTO @feeling_tired  FROM concept_name cn WHERE uuid='b1d55936-4e3a-4937-a43a-f49a4fc79d01';
UPDATE salud_mental_encountero t 
SET t.PHQ9_q4 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@feeling_tired AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

SELECT concept_id INTO @eating_less  FROM concept_name cn WHERE uuid='3ad37078-04ab-4ce0-b57e-0114ac67d909';
UPDATE salud_mental_encountero t 
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
UPDATE salud_mental_encountero t 
SET t.PHQ9_q6 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@failed_someone AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

SELECT concept_id INTO @distract_easily  FROM concept_name cn WHERE uuid='b0a8838b-ad87-46d1-9ed4-ed932fd85464';
UPDATE salud_mental_encountero t 
SET t.PHQ9_q7 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@distract_easily AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

SELECT concept_id INTO @feels_slower  FROM concept_name cn WHERE uuid='4039e3f8-bde7-48bf-b6a8-e988065ddfab';
UPDATE salud_mental_encountero t 
SET t.PHQ9_q8 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END
	 FROM obs WHERE concept_id=@feels_slower AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

SELECT concept_id INTO @suicidal_thoughts  FROM concept_name cn WHERE uuid='8e2ad0bb-f5cc-4426-ab1a-903bc3a7d308';
UPDATE salud_mental_encountero t 
SET t.PHQ9_q9 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END
	 FROM obs WHERE concept_id= @suicidal_thoughts  AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

SELECT concept_id INTO @feel_nervous  FROM concept_name cn WHERE uuid='6429df5e-ecf2-4cd3-b094-c1d2d1f2ba78';
UPDATE salud_mental_encountero t 
SET t.GAD7_q1 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@feel_nervous AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

SELECT concept_id INTO @no_stop_worry  FROM concept_name cn WHERE uuid='40ed4b2e-2e4c-4a03-8e8c-64ea6641aacd';
UPDATE salud_mental_encountero t 
SET t.GAD7_q2 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@no_stop_worry AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

SELECT concept_id INTO @worry_much  FROM concept_name cn WHERE uuid='2bc5d8c6-4dde-4c7c-a005-3440fdce5287';
UPDATE salud_mental_encountero t 
SET t.GAD7_q3 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@worry_much  AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

SELECT concept_id INTO @diff_relaxing  FROM concept_name cn WHERE uuid='fd7b9dc1-9ef8-4471-9524-e42186bee719';
UPDATE salud_mental_encountero t 
SET t.GAD7_q4 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END  
	 FROM obs WHERE concept_id=@diff_relaxing  AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

SELECT concept_id INTO @so_restless  FROM concept_name cn WHERE uuid='a262cb01-9dc5-428b-a42f-6dee85c0ae3a';
UPDATE salud_mental_encountero t 
SET t.GAD7_q5 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END
	 FROM obs WHERE concept_id=@so_restless AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

SELECT concept_id INTO @upset_easily  FROM concept_name cn WHERE uuid='9c2c2976-cb2d-465c-8ce0-6e7591480473';
UPDATE salud_mental_encountero t 
SET t.GAD7_q6 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END
	 FROM obs WHERE concept_id=@upset_easily AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

SELECT concept_id INTO @feeling_scared  FROM concept_name cn WHERE uuid='1cf903a8-d4cf-4cb4-8558-bf1f678d7513';
UPDATE salud_mental_encountero t 
SET t.GAD7_q7 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@feeling_scared 
	 AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_encountero t 
SET t.PHQ9_score  = (
	 SELECT  value_numeric
	 FROM obs WHERE concept_id=@phqscore  AND person_id=t.Patient_id
	AND encounter_id =t.encounter_id 
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);


UPDATE salud_mental_encountero t 
SET t.GAD7_score  = (
	 SELECT  value_numeric
	 FROM obs WHERE concept_id=@gadscore  AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);
-- --------------------------------------- Analysis Notes ----------------------------------------------------------------------------------------------------------------------------------------------
SELECT concept_id  INTO @analysis_notes FROM concept_name WHERE uuid ='3e18bed6-26fe-102b-80cb-0017a47871b2';
UPDATE salud_mental_encountero t 
SET t.analysis_notes = (
	 SELECT  value_text
	 FROM obs WHERE concept_id=@analysis_notes  
	 AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);


-- ----------------------------------- Medications >> Drug Name ----------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE VIEW medical_inst_drug_name AS 
SELECT DISTINCT cn.name,-- cn.uuid ,
								o.person_id, o.encounter_id , obs_group_id, o.value_group_id,
								o.value_coded , o.value_text , o.value_drug , o.value_numeric, d.name AS drug_name
								FROM obs o
INNER JOIN concept_name cn ON o.concept_id =cn.concept_id AND cn.locale ='en'
INNER JOIN drug d ON d.drug_id =o.value_drug 
WHERE  cn.uuid IN ('079cd4ef-815f-4933-a155-ce05821fed73') -- drug name
--  								,'4369a18f-1c8d-483e-a2b0-9b382964afc6' -- drug instructions
--  								,'bc4020d9-fe70-4555-a250-0b8c2b3d9533') -- quantity 
ORDER BY  o.person_id, o.encounter_id , obs_group_id ASC, o.concept_id ASC;

CREATE OR REPLACE VIEW rnk_drug_name AS
SELECT t.*,(
    SELECT COUNT(*)
    FROM medical_inst_drug_name AS x
    WHERE x.person_id = t.person_id
    AND x.encounter_id = t.encounter_id
    AND x.obs_group_id > t.obs_group_id
) + 1 AS erank
FROM medical_inst_drug_name t
-- WHERE t.person_id=2287
ORDER BY t.person_id,t.encounter_id, erank;

UPDATE salud_mental_encountero t 
SET t.medication_1_name = (
SELECT drug_name
FROM rnk_drug_name rdn
WHERE erank=1
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero t 
SET t.medication_2_name = (
SELECT drug_name
FROM rnk_drug_name rdn
WHERE erank=2
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero t 
SET t.medication_3_name = (
SELECT drug_name
FROM rnk_drug_name rdn
WHERE erank=3
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero t 
SET t.medication_4_name = (
SELECT drug_name
FROM rnk_drug_name rdn
WHERE erank=4
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero t 
SET t.medication_5_name = (
SELECT drug_name
FROM rnk_drug_name rdn
WHERE erank=5
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero t 
SET t.medication_6_name = (
SELECT drug_name
FROM rnk_drug_name rdn
WHERE erank=6
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero t 
SET t.medication_7_name = (
SELECT drug_name
FROM rnk_drug_name rdn
WHERE erank=7
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero t 
SET t.medication_8_name = (
SELECT drug_name
FROM rnk_drug_name rdn
WHERE erank=8
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero t 
SET t.medication_9_name = (
SELECT drug_name
FROM rnk_drug_name rdn
WHERE erank=9
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero t 
SET t.medication_10_name = (
SELECT drug_name
FROM rnk_drug_name rdn
WHERE erank=10
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
);


-- ----------------------------------- Medications >> Drug Instructions ----------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE VIEW medical_inst_drug_inst AS 
SELECT DISTINCT cn.name,-- cn.uuid ,
								o.person_id, o.encounter_id , obs_group_id, o.value_group_id,
								o.value_coded , o.value_text , o.value_drug , o.value_text AS drug_instructions
								FROM obs o
INNER JOIN concept_name cn ON o.concept_id =cn.concept_id AND cn.locale ='en'
WHERE  cn.uuid IN ('4369a18f-1c8d-483e-a2b0-9b382964afc6') -- drug instructions
-- ('079cd4ef-815f-4933-a155-ce05821fed73') -- drug name
--  								,'4369a18f-1c8d-483e-a2b0-9b382964afc6' -- drug instructions
--  								,'bc4020d9-fe70-4555-a250-0b8c2b3d9533') -- quantity 
ORDER BY  o.person_id, o.encounter_id , obs_group_id ASC, o.concept_id ASC;

CREATE OR REPLACE VIEW rnk_drug_inst AS
SELECT t.*,(
    SELECT COUNT(*)
    FROM medical_inst_drug_inst AS x
    WHERE x.person_id = t.person_id
    AND x.encounter_id = t.encounter_id
    AND x.obs_group_id > t.obs_group_id
) + 1 AS erank
FROM medical_inst_drug_inst t
-- WHERE t.person_id=2287
ORDER BY t.person_id,t.encounter_id, erank;


UPDATE salud_mental_encountero t 
SET t.medication_1_instructions = (
SELECT drug_instructions
FROM rnk_drug_inst rdn
WHERE erank=1
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero t 
SET t.medication_2_instructions = (
SELECT drug_instructions
FROM rnk_drug_inst rdn
WHERE erank=2
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero t 
SET t.medication_3_instructions = (
SELECT drug_instructions
FROM rnk_drug_inst rdn
WHERE erank=3
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero t 
SET t.medication_4_instructions = (
SELECT drug_instructions
FROM rnk_drug_inst rdn
WHERE erank=4
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero t 
SET t.medication_5_instructions = (
SELECT drug_instructions
FROM rnk_drug_inst rdn
WHERE erank=5
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero t 
SET t.medication_6_instructions = (
SELECT drug_instructions
FROM rnk_drug_inst rdn
WHERE erank=6
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero t 
SET t.medication_7_instructions = (
SELECT drug_instructions
FROM rnk_drug_inst rdn
WHERE erank=7
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero t 
SET t.medication_8_instructions = (
SELECT drug_instructions
FROM rnk_drug_inst rdn
WHERE erank=8
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero t 
SET t.medication_9_instructions  = (
SELECT drug_instructions
FROM rnk_drug_inst rdn
WHERE erank=9
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero t 
SET t.medication_10_instructions = (
SELECT drug_instructions
FROM rnk_drug_inst rdn
WHERE erank=10
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
);

-- ----------------------------------- Medications >> Drug Dose ----------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE VIEW medical_inst_drug_dose AS 
SELECT DISTINCT cn.name,-- cn.uuid ,
								o.person_id, o.encounter_id , obs_group_id, o.value_group_id,
								o.value_coded , o.value_text , o.value_drug , o.value_numeric  AS drug_dose
								FROM obs o
INNER JOIN concept_name cn ON o.concept_id =cn.concept_id AND cn.locale ='en'
WHERE  cn.uuid IN ('bc4020d9-fe70-4555-a250-0b8c2b3d9533') -- drug instructions
-- ('079cd4ef-815f-4933-a155-ce05821fed73') -- drug name
--  								,'4369a18f-1c8d-483e-a2b0-9b382964afc6' -- drug instructions
--  								,'bc4020d9-fe70-4555-a250-0b8c2b3d9533') -- quantity 
ORDER BY  o.person_id, o.encounter_id , obs_group_id ASC, o.concept_id ASC;

CREATE OR REPLACE VIEW rnk_drug_dose AS
SELECT t.*,(
    SELECT COUNT(*)
    FROM medical_inst_drug_dose AS x
    WHERE x.person_id = t.person_id
    AND x.encounter_id = t.encounter_id
    AND x.obs_group_id > t.obs_group_id
) + 1 AS erank
FROM medical_inst_drug_dose t
-- WHERE t.person_id=2287
ORDER BY t.person_id,t.encounter_id, erank;


UPDATE salud_mental_encountero t 
SET t.medication_1_units = (
SELECT drug_dose
FROM rnk_drug_dose rdn
WHERE erank=1
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero t 
SET t.medication_2_units = (
SELECT drug_dose
FROM rnk_drug_dose rdn
WHERE erank=2
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero t 
SET t.medication_3_units = (
SELECT drug_dose
FROM rnk_drug_dose rdn
WHERE erank=3
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero t 
SET t.medication_4_units = (
SELECT drug_dose
FROM rnk_drug_dose rdn
WHERE erank=4
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero t 
SET t.medication_5_units = (
SELECT drug_dose
FROM rnk_drug_dose rdn
WHERE erank=5
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero t 
SET t.medication_6_units = (
SELECT drug_dose
FROM rnk_drug_dose rdn
WHERE erank=6
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero t 
SET t.medication_7_units = (
SELECT drug_dose
FROM rnk_drug_dose rdn
WHERE erank=7
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero t 
SET t.medication_8_units = (
SELECT drug_dose
FROM rnk_drug_dose rdn
WHERE erank=8
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero t 
SET t.medication_9_units  = (
SELECT drug_dose
FROM rnk_drug_dose rdn
WHERE erank=9
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero t 
SET t.medication_10_units = (
SELECT drug_dose
FROM rnk_drug_dose rdn
WHERE erank=10
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
);

-- --------------------------------------- Lab order and Treatement Plan ----------------------------------------------------------------------------------------------------------------------------------------------
SELECT concept_id  INTO @treatment_plan FROM concept_name WHERE uuid ='126604BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB';
SELECT concept_id  INTO @lab_ordered FROM concept_name WHERE uuid ='9dd4673d-e07e-4c74-b190-fb3ff5e8344e';

UPDATE salud_mental_encountero t 
SET t.Treatment_plan  = (
	 SELECT  value_text
	 FROM obs WHERE concept_id=@treatment_plan
	 AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_encountero t 
SET t.lab_tests_ordered = (
	 SELECT  value_text
	 FROM obs WHERE concept_id=@lab_ordered
	 AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

-- ------------------------------------ Case Notes -------------------------------------------------------------------------------------------------
SELECT * FROM concept_name WHERE name LIKE '%note%';

-- ------------------------------- Pregnancy and delivery date --------------------------------------------------------------------------------
SELECT concept_id INTO @parental_care FROM concept_name cn3 WHERE uuid='142496BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB';
UPDATE salud_mental_encountero t 
SET t.prenatal_care = (
	 SELECT  value_text
	 FROM obs WHERE concept_id=@parental_care
	 AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

SELECT concept_id  INTO @delivery_date FROM concept_name cn WHERE uuid ='93f4254a-07d4-102c-b5fa-0017a47871b2';
UPDATE salud_mental_encountero t 
SET t.estimated_delivery_date = (
	 SELECT  value_text
	 FROM obs WHERE concept_id=@delivery_date
	 AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

-- -------------------------------------------- Indicators - psychosis --------------------------------------------------------------------------

SELECT concept_id INTO @Schizophrenia FROM concept_name cn WHERE uuid='3e0ecaca-26fe-102b-80cb-0017a47871b2'; 
-- SELECT concept_id INTO @Acute_psychosis FROM concept_name cn WHERE uuid='3e0ecaca-26fe-102b-80cb-0017a47871b2'; 
SELECT concept_id INTO @psychosis FROM concept_name cn WHERE uuid='20f708a3-be12-49ac-b30b-f9d87b533c33'; 
SELECT concept_id INTO @Mania_wo_psychotic FROM concept_name cn WHERE uuid='125457BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'; 
SELECT concept_id INTO @Mania_w_psychotic FROM concept_name cn WHERE uuid='125455BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'; 

DROP TABLE IF EXISTS psychosis_data;
CREATE TEMPORARY TABLE psychosis_data AS 
	 SELECT person_id,encounter_id, COUNT(1) AS num_obs
	 FROM obs WHERE (
	   	concept_id=@Schizophrenia -- Schizophrenia
	   -- 	OR concept_id=@Acute_psychosis -- Acute psychosis
	   	OR concept_id=@psychosis -- psychosis
	   	OR concept_id=@Mania_wo_psychotic -- Mania without psychotic symptoms
	   	OR concept_id=@Mania_w_psychotic -- Mania with psychotic symptoms
	 				)
	 GROUP BY person_id, encounter_id;

UPDATE salud_mental_encountero  t 
SET t.psychosis  = (
 SELECT CASE WHEN num_obs > 0 THEN TRUE ELSE FALSE END 
 FROM psychosis_data md
 WHERE md.person_id=t.Patient_id 
 AND md.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero t 
SET t.psychosis  = FALSE 
WHERE t.psychosis  IS NULL;

-- -------------------------------------------- Indicators - mood disorder --------------------------------------------------------------------------

SELECT concept_id INTO @bipolar_disorder FROM concept_name cn WHERE uuid='21277BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'; 
SELECT concept_id INTO @depression FROM concept_name cn WHERE uuid='3e0bf55c-26fe-102b-80cb-0017a47871b2'; 
SELECT concept_id INTO @mood_changes FROM concept_name cn WHERE uuid='19158BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'; 

DROP TABLE IF EXISTS mood_disorder_data;
CREATE TEMPORARY TABLE mood_disorder_data AS 
	 SELECT person_id,encounter_id, COUNT(1) AS num_obs
	 FROM obs WHERE (
	   	concept_id=@bipolar_disorder -- bipolar disorder
	   	OR concept_id=@depression -- depression
	   	OR concept_id=@mood_changes -- mood changes
	 				)
	 GROUP BY person_id,encounter_id;
	
UPDATE salud_mental_encountero  t 
SET t.mood_disorder  = (
 SELECT CASE WHEN num_obs > 0 THEN TRUE ELSE FALSE END 
 FROM mood_disorder_data md
 WHERE md.person_id=t.Patient_id 
 AND md.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero t 
SET t.mood_disorder  = FALSE 
WHERE t.mood_disorder  IS NULL;

-- -------------------------------------------------------- Indicators - anxiety ---------------------------------------------------------------------------------------

SELECT concept_id INTO @panick_attack FROM concept_name cn WHERE uuid='30948BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'; 
SELECT concept_id INTO @generalised_anxiety FROM concept_name cn WHERE uuid='39327BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'; 
SELECT concept_id INTO @anxiety FROM concept_name cn WHERE uuid='94db47f0-234a-41b4-9ff5-9a8eca179ce0'; 
SELECT concept_id INTO @obsessive_compulsive_disorder FROM concept_name cn WHERE uuid='32537BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'; 
SELECT concept_id INTO @acute_stress_reaction FROM concept_name cn WHERE uuid='cac16142-4adb-4900-8880-9e1af727b464'; 
SELECT concept_id INTO @post_traumatic_stress FROM concept_name cn WHERE uuid='6b144b55-b9b2-4907-85a8-4e1e8315ee12'; 

DROP TABLE IF EXISTS anxiety_data;
CREATE TEMPORARY TABLE anxiety_data AS 
	 SELECT person_id, encounter_id, COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	concept_id=@panick_attack-- panick attack
	   	OR concept_id=@generalised_anxiety  -- generalised anxiety disorder
	   	OR concept_id=@anxiety -- anxiety
	   	OR concept_id=@obsessive_compulsive_disorder -- obsessive-compulsive disorder
	   	OR concept_id=@acute_stress_reaction -- acute stress reaction
	   	OR concept_id=@post_traumatic_stress -- post-traumatic stress disorder
	 				)
	 GROUP BY person_id, encounter_id ;
	
UPDATE salud_mental_encountero  t 
SET t.anxiety = (
 SELECT CASE WHEN num_obs > 0 THEN TRUE ELSE FALSE END 
 FROM anxiety_data md
 WHERE md.person_id=t.Patient_id 
 AND md.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero  t 
SET t.anxiety  = FALSE 
WHERE t.anxiety  IS NULL;

-- ---------------------------------------------------- Indicators - dissociative disorders ------------------------------------------------------------------------------------
SELECT concept_id INTO @dissociative_disorders FROM concept_name cn WHERE uuid='1533d1b9-db89-4e78-9686-ae5c0c6aa392'; 

DROP TABLE IF EXISTS dissociative_disorders_data;
CREATE TEMPORARY TABLE dissociative_disorders_data AS 
	 SELECT person_id, encounter_id ,COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	concept_id=@dissociative_disorders
	 				)
	 GROUP BY person_id,encounter_id;
	
UPDATE salud_mental_encountero  t 
SET t.dissociative_disorders  = (
 SELECT CASE WHEN num_obs > 0 THEN TRUE ELSE FALSE END 
 FROM  dissociative_disorders_data md
 WHERE md.person_id=t.Patient_id 
 AND md.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero  t 
SET t.dissociative_disorders  = FALSE 
WHERE t.dissociative_disorders  IS NULL;

-- ----------------------------------------------------- Indicators - psychosomatic disorders -------------------------------------------------------------------------
SELECT concept_id INTO @dissociative_disorders FROM concept_name cn WHERE uuid='9397c29e-fe5f-4f89-b7b2-e2294a46ebe2'; 

DROP TABLE IF EXISTS psychosomatic_disorders_data;
CREATE TEMPORARY TABLE psychosomatic_disorders_data AS 
	 SELECT person_id, encounter_id, COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	concept_id=2381
	 				)
	 GROUP BY person_id, encounter_id ;

	
UPDATE salud_mental_encountero  t 
SET t.psychosomatic_disorders  = (
 SELECT CASE WHEN num_obs > 0 THEN TRUE ELSE FALSE END 
 FROM  psychosomatic_disorders_data md
 WHERE md.person_id=t.Patient_id 
 AND md.encounter_id = t.encounter_id 
);

UPDATE salud_mental_encountero  t 
SET t.psychosomatic_disorders  = FALSE 
WHERE t.psychosomatic_disorders  IS NULL;

-- ---------------------------------------------------- Indicators - eating disorders --------------------------------------------------------------------------
SELECT concept_id INTO @eating_disorders FROM concept_name cn WHERE uuid='19051BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB';
DROP TABLE IF EXISTS eating_disorders_data;
CREATE TEMPORARY TABLE eating_disorders_data AS 
	 SELECT person_id,encounter_id,  COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	concept_id=@eating_disorders 
	 				)
	 GROUP BY person_id, encounter_id ;
	
UPDATE salud_mental_encountero  t 
SET t.eating_disorders  = (
 SELECT CASE WHEN num_obs > 0 THEN TRUE ELSE FALSE END 
 FROM  eating_disorders_data md
 WHERE md.person_id=t.Patient_id 
 AND md.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero  t 
SET t.eating_disorders  = FALSE 
WHERE t.eating_disorders  IS NULL;

-- ------------------------------------------------------- Indicators - personality disorders -----------------------------------------------------------------------------------
SELECT concept_id INTO @personality_disorders FROM concept_name cn WHERE uuid='14788BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB';

DROP TABLE IF EXISTS personality_disorders_data;
CREATE TEMPORARY TABLE personality_disorders_data AS 
	 SELECT person_id,encounter_id,  COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	concept_id=@personality_disorders
	 				)
	GROUP BY person_id,encounter_id;
	

	
UPDATE salud_mental_encountero  t 
SET t.personality_disorders  = (
 SELECT CASE WHEN num_obs > 0 THEN TRUE ELSE FALSE END 
 FROM  personality_disorders_data md
 WHERE md.person_id=t.Patient_id 
 AND md.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero  t 
SET t.personality_disorders  = FALSE 
WHERE t.personality_disorders  IS NULL;


-- ----------------------------------------- Indicators - conduct disorders ---------------------------------------------------------------------
SELECT concept_id INTO @conduct_disorder FROM concept_name cn WHERE uuid='efb2cf92-f4eb-46a3-bb63-f1703d12859f';
SELECT concept_id INTO @attention_deficit FROM concept_name cn WHERE uuid='a3e4ff43-1038-4333-864f-fdb863983607';
SELECT concept_id INTO @oppositional_deficit FROM concept_name cn WHERE uuid='5fff7edb-a761-411e-a1ef-ec9b8594d0ad';

DROP TABLE IF EXISTS conduct_disorders_data;
CREATE TEMPORARY TABLE conduct_disorders_data AS 
	 SELECT person_id,encounter_id , COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	concept_id=@conduct_disorder  -- conduct disorder
	   	OR concept_id=@attention_deficit  -- attention deficit
	   	OR concept_id= @oppositional_deficit -- oppositional deficit
	 				)
	 GROUP BY person_id,encounter_id ;

	
UPDATE salud_mental_encountero  t 
SET t.conduct_disorders  = (
 SELECT CASE WHEN num_obs > 0 THEN TRUE ELSE FALSE END 
 FROM  conduct_disorders_data md
 WHERE md.person_id=t.Patient_id 
 AND md.encounter_id= t.encounter_id 
);

UPDATE salud_mental_encountero  t 
SET t.conduct_disorders  = FALSE 
WHERE t.conduct_disorders  IS NULL;

-- ------------------------------------------------- Indicators - suicidal -------------------------------------------------------------------------------------
SELECT concept_id INTO @suicidal_thoughts FROM concept_name cn WHERE uuid='25618BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB';
SELECT concept_id INTO @attempted_suicide FROM concept_name cn WHERE uuid='47767BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB';


DROP TABLE IF EXISTS suicidal_data;
CREATE TEMPORARY TABLE suicidal_data AS 
	 SELECT person_id, encounter_id , COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	concept_id=@suicidal_thoughts -- suicidal thoughts
	   	OR concept_id=@attempted_suicide -- attempted suicide
	 				)
	 GROUP BY person_id, encounter_id ;

	
UPDATE salud_mental_encountero  t 
SET t.suicidal_ideation  = (
 SELECT CASE WHEN num_obs > 0 THEN TRUE ELSE FALSE END 
 FROM  suicidal_data md
 WHERE md.person_id=t.Patient_id 
 AND md.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero  t 
SET t.suicidal_ideation  = FALSE 
WHERE t.suicidal_ideation  IS NULL;


-- ----------------------------------------------  Indicators - grief ----------------------------------------------------
SELECT concept_id INTO @grief FROM concept_name cn WHERE uuid='56ca4d71-2fec-4189-8e12-f2a79a39c3ca';

DROP TABLE IF EXISTS grief_data;
CREATE TEMPORARY TABLE grief_data AS 
	 SELECT person_id,  encounter_id , COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	concept_id=@grief -- grief
	 				)
	 GROUP BY person_id, encounter_id ;

	
UPDATE salud_mental_encountero t 
SET t.grief  = (
 SELECT CASE WHEN num_obs > 0 THEN TRUE ELSE FALSE END 
 FROM  grief_data md
 WHERE md.person_id=t.Patient_id 
 AND md.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero t 
SET t.grief  = FALSE 
WHERE t.grief  IS NULL;

-- ------------------------------------------------------ Next Scheduled Appointment --------------------------------------------------------------------------
SELECT concept_id INTO @next_appt FROM concept_name cn WHERE uuid='66f5aa60-10fb-40a9-bcd3-7940980eddca';

UPDATE salud_mental_encountero t 
SET t.next_appointment  = (
SELECT cast(value_datetime AS date)
FROM obs o
WHERE concept_id=@next_appt
AND o.person_id=t.patient_id 
AND o.encounter_id=t.encounter_id 
);

-- ------------------------------------ Diagnosis -------------------------------------------------------------------------------------------------------------------------------------------
-- SELECT concept_id INTO @diagnosis FROM concept_name cn WHERE uuid='93c47642-07d4-102c-b5fa-0017a47871b2';
-- SELECT * FROM obs
-- WHERE concept_id = @diagnosis
-- SELECT * FROM diagno
-- --------------------------------------- Final Select -----------------------------------------------------------------------------------------------------------------------------------------
SELECT 
DISTINCT
patient_id ,
emr_id ,
location ,
age ,
encounter_id , 
encounter_date , 
data_entry_date ,
data_entry_person ,
visit_id ,
mh_visit_date ,
provider_name ,
visit_Reason ,
case_notes ,
prenatal_care ,
estimated_delivery_date ,
PHQ9_q1	,
PHQ9_q2	,
PHQ9_q3	,
PHQ9_q4	,
PHQ9_q5	,
PHQ9_q6	,
PHQ9_q7	,
PHQ9_q8	,
PHQ9_q9	,
PHQ9_score ,
GAD7_q1	,
GAD7_q2	,
GAD7_q3	,
GAD7_q4	,
GAD7_q5	,
GAD7_q6	,
GAD7_q7	,
GAD7_score ,
analysis_notes ,
visit_end_status ,
diagnosis , 
primary_diagnosis ,
psychosis ,
mood_disorder ,
anxiety ,
adaptive_disorders ,
dissociative_disorders ,
psychosomatic_disorders ,
eating_disorders ,
personality_disorders ,
conduct_disorders ,
suicidal_ideation ,
grief ,
Treatment_plan ,
lab_tests_ordered ,
medication_1_name ,
medication_1_units ,
medication_1_instructions ,
medication_2_name ,
medication_2_units ,
medication_2_instructions ,
medication_3_name ,
medication_3_units ,
medication_3_instructions ,
medication_4_name ,
medication_4_units ,
medication_4_instructions ,
medication_5_name ,
medication_5_units ,
medication_5_instructions ,
medication_6_name ,
medication_6_units ,
medication_6_instructions ,
medication_7_name ,
medication_7_units ,
medication_7_instructions ,
medication_8_name ,
medication_8_units ,
medication_8_instructions ,
medication_9_name ,
medication_9_units ,
medication_9_instructions ,
medication_10_name ,
medication_10_units ,
medication_10_instructions ,
next_appointment
FROM salud_mental_encountero;