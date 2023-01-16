SET @partition = '${partitionNum}';

SELECT name  INTO @encounter_type_name FROM encounter_type et WHERE et.uuid ='a8584ab8-cc2a-11e5-9956-625662870761';
SELECT encounter_type_id  INTO @encounter_type_id FROM encounter_type et WHERE et.uuid ='a8584ab8-cc2a-11e5-9956-625662870761';
SELECT program_id INTO @program_id FROM program p WHERE uuid='0e69c3ab-1ccb-430b-b0db-b9760319230f';
select concept_id into @lastperioddate from concept_name where concept_id =2908 and locale='en' and voided=0 and concept_name_type='FULLY_SPECIFIED';
select patient_identifier_type_id into @identifier_type from patient_identifier_type pit where uuid ='506add39-794f-11e8-9bcd-74e5f916c5ec';

DROP TABLE IF EXISTS salud_mental_encountero;
CREATE TABLE salud_mental_encountero (
patient_id int,
person_uuid char(38),
emr_id varchar(30),
location varchar(30),
age int,
encounter_id int, 
encounter_uuid char(38),
index_asc int,
index_desc int,
encounter_date date, 
date_changed date,
data_entry_date date,
data_entry_person varchar(30),
visit_id int,
mh_visit_date date,
provider_name varchar(30),
visit_Reason varchar(500),
case_notes text,
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
primary_diagnosis varchar(100),
psychosis boolean,
mood_disorder boolean,
anxiety boolean,
adaptive_disorders boolean,
dissociative_disorders boolean,
psychosomatic_disorders boolean,
eating_disorders boolean,
personality_disorders boolean,
conduct_disorders boolean,
suicidal_ideation boolean,
grief boolean,
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


-- ------------- Functions Definition --------------
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


-- DROP FUNCTION IF EXISTS concept_name;
-- #
-- CREATE FUNCTION concept_name(
--     _conceptID INT,
--     _locale varchar(50)
-- )
-- 	RETURNS VARCHAR(255)
--     DETERMINISTIC
-- 
-- BEGIN
--     DECLARE conceptName varchar(255);
-- 
-- 	SELECT name INTO conceptName
-- 	FROM concept_name
-- 	WHERE voided = 0
-- 	  AND concept_id = _conceptID
-- 	order by if(_locale = locale, 0, 1), if(locale = 'en', 0, 1),
-- 	  locale_preferred desc, ISNULL(concept_name_type) asc, 
-- 	  field(concept_name_type,'FULLY_SPECIFIED','SHORT')
-- 	limit 1;
-- 
--     RETURN conceptName;
-- END

################# Views Defintions ##############################################################


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
SELECT DISTINCT person_id, encounter_id , obs_datetime 
FROM obs 
WHERE concept_id  IN (SELECT obs_id FROM mental_obs_ref )
;

CREATE OR REPLACE VIEW mental_encounter_details AS 
SELECT DISTINCT  encounter_id, e2.uuid "encounter_uuid", patient_id, encounter_datetime, location_id , date_created , 
				 e2.date_changed , creator, visit_id 
FROM encounter e2 
WHERE encounter_id  IN (SELECT encounter_id FROM mental_encounters)
and e2.voided=0;

DROP TABLE IF EXISTS mental_patients_list;
CREATE TABLE mental_patients_list AS
SELECT DISTINCT patient_id FROM patient_program pp WHERE program_id =@program_id
;

drop table if exists tmp_patient_identifier_v2;
CREATE TABLE tmp_patient_identifier_v2 AS
SELECT DISTINCT patient_id,identifier
FROM  patient_identifier
where voided = 0 
and identifier_type=@identifier_type 
GROUP BY patient_id;


CREATE OR REPLACE VIEW patient_list AS
SELECT DISTINCT  p.patient_id, pi2.identifier emr_id
FROM patient p LEFT OUTER JOIN tmp_patient_identifier_v2 pi2 ON p.patient_id =pi2.patient_id
WHERE p.patient_id IN (
	SELECT DISTINCT patient_id FROM mental_patients_list
)
GROUP BY p.patient_id 
UNION
SELECT DISTINCT  p.patient_id, pi2.identifier emr_id
FROM patient p INNER JOIN tmp_patient_identifier_v2 pi2 ON p.patient_id =pi2.patient_id
WHERE p.patient_id IN (
	SELECT DISTINCT patient_id FROM mental_encounter_details
)
GROUP BY p.patient_id;

################# Insert Patinets List ##############################################################

INSERT INTO salud_mental_encountero (patient_id, emr_id,location,age,encounter_id,encounter_uuid, encounter_date , date_changed,
					data_entry_date,data_entry_person,visit_id,mh_visit_date ,provider_name)
SELECT DISTINCT me.patient_id ,pi2.identifier, l.name , age_at_enc(me.patient_id, me.encounter_id) AS age, 
			  me.encounter_id, me.encounter_uuid, cast(me.encounter_datetime AS date) AS encounter_date,
			  me.date_changed,
			  CAST(me.date_created AS date) AS data_entry_date, 
			  u.username AS data_entry_person,
			  me.visit_id,
			  CAST(v2.date_started AS date) AS mh_visit_date,
			  u.username  AS provider_name
FROM mental_encounter_details me INNER JOIN tmp_patient_identifier_v2 pi2 ON me.patient_id = pi2.patient_id 
INNER JOIN location l ON me.location_id =l.location_id 
INNER JOIN users u ON u.user_id =me.creator
INNER JOIN visit v2 ON v2.visit_id =me.visit_id 
INNER JOIN visit_type vt ON v2.visit_type_id =vt.visit_type_id;

SELECT concept_id INTO @visit_reason_cn FROM concept WHERE uuid='86a2cf11-1ea5-4b8a-9e4b-08f4cdbe1346';
UPDATE salud_mental_encountero t 
SET t.visit_Reason = (
	 SELECT  concept_name(value_coded,'en')
	 FROM obs WHERE concept_id=@visit_reason_cn  
	 AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);


-- ############# PHQ-9 & GAD-7  Questions #####################################

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

UPDATE salud_mental_encountero t 
SET t.PHQ9_q1 = (
	 SELECT  CASE WHEN value_coded=@never THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@little_interest  AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 and voided=0
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_encountero t 
SET t.PHQ9_q2 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@down_depressed   AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 and voided=0
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_encountero t 
SET t.PHQ9_q3 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@hard_Failing_sleep  AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 and voided=0
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_encountero t 
SET t.PHQ9_q4 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@feeling_tired AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 and voided=0
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_encountero t 
SET t.PHQ9_q5 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@eating_less AND person_id=t.Patient_id
	 and voided=0
	 and encounter_id =t.encounter_id 
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);


UPDATE salud_mental_encountero t 
SET t.PHQ9_q6 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@failed_someone AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 and voided=0
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_encountero t 
SET t.PHQ9_q7 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@distract_easily AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 and voided=0
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_encountero t 
SET t.PHQ9_q8 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END
	 FROM obs WHERE concept_id=@feels_slower AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 and voided=0
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_encountero t 
SET t.PHQ9_q9 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END
	 FROM obs WHERE concept_id= @suicidal_thoughts  AND person_id=t.Patient_id
	 and voided=0
	 and encounter_id =t.encounter_id 
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_encountero t 
SET t.GAD7_q1 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@feel_nervous AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 and voided=0
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_encountero t 
SET t.GAD7_q2 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@no_stop_worry AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 and voided=0
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_encountero t 
SET t.GAD7_q3 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@worry_much  AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 and voided=0
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_encountero t 
SET t.GAD7_q4 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END  
	 FROM obs WHERE concept_id=@diff_relaxing  AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 and voided=0
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_encountero t 
SET t.GAD7_q5 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END
	 FROM obs WHERE concept_id=@so_restless AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 and voided=0
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_encountero t 
SET t.GAD7_q6 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END
	 FROM obs WHERE concept_id=@upset_easily AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 and voided=0
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_encountero t 
SET t.GAD7_q7 = (
	 SELECT  CASE WHEN value_coded=@never  THEN 0
	 						 WHEN value_coded=@somedays THEN 1
	 						 WHEN value_coded=@morethanhalf  THEN 2
	 						 WHEN value_coded=@daily THEN 3 END 
	 FROM obs WHERE concept_id=@feeling_scared 
	 AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 and voided=0
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

UPDATE salud_mental_encountero t 
SET t.PHQ9_score  = (
	 SELECT  value_numeric
	 FROM obs WHERE concept_id=@phqscore  AND person_id=t.Patient_id
	AND encounter_id =t.encounter_id 
	and voided=0
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);


UPDATE salud_mental_encountero t 
SET t.GAD7_score  = (
	 SELECT  value_numeric
	 FROM obs WHERE concept_id=@gadscore  AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 and voided=0
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);
-- --------------------------------------- Analysis Notes ----------------------------------------------------------------------------------------------------------------------------------------------
SELECT concept_id INTO @analysis_notes FROM concept WHERE uuid='3cd9d956-26fe-102b-80cb-0017a47871b2';
UPDATE salud_mental_encountero t 
SET t.analysis_notes = (
	 SELECT  value_text
	 FROM obs WHERE concept_id=@analysis_notes  
	 AND person_id=t.Patient_id
	 AND encounter_id =t.encounter_id 
	 ORDER BY person_id , obs_datetime DESC
	LIMIT 1
);

-- --------------------------------------- Case Notes ----------------------------------------------------------------------------------------------------------------------------------------------
SELECT concept_id INTO @case_notes FROM concept WHERE uuid='3cd9ae0e-26fe-102b-80cb-0017a47871b2';
UPDATE salud_mental_encountero t 
SET t.case_notes = (
	 SELECT  value_text
	 FROM obs WHERE concept_id=@case_notes  
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
limit 1
);


UPDATE salud_mental_encountero t 
SET t.medication_2_name = (
SELECT drug_name
FROM rnk_drug_name rdn
WHERE erank=2
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
limit 1
);

UPDATE salud_mental_encountero t 
SET t.medication_3_name = (
SELECT drug_name
FROM rnk_drug_name rdn
WHERE erank=3
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
limit 1
);

UPDATE salud_mental_encountero t 
SET t.medication_4_name = (
SELECT drug_name
FROM rnk_drug_name rdn
WHERE erank=4
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
limit 1
);

UPDATE salud_mental_encountero t 
SET t.medication_5_name = (
SELECT drug_name
FROM rnk_drug_name rdn
WHERE erank=5
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
limit 1
);

UPDATE salud_mental_encountero t 
SET t.medication_6_name = (
SELECT drug_name
FROM rnk_drug_name rdn
WHERE erank=6
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
limit 1
);

UPDATE salud_mental_encountero t 
SET t.medication_7_name = (
SELECT drug_name
FROM rnk_drug_name rdn
WHERE erank=7
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
limit 1
);

UPDATE salud_mental_encountero t 
SET t.medication_8_name = (
SELECT drug_name
FROM rnk_drug_name rdn
WHERE erank=8
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
limit 1
);

UPDATE salud_mental_encountero t 
SET t.medication_9_name = (
SELECT drug_name
FROM rnk_drug_name rdn
WHERE erank=9
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
limit 1
);

UPDATE salud_mental_encountero t 
SET t.medication_10_name = (
SELECT drug_name
FROM rnk_drug_name rdn
WHERE erank=10
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
limit 1
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
limit 1
);

UPDATE salud_mental_encountero t 
SET t.medication_2_instructions = (
SELECT drug_instructions
FROM rnk_drug_inst rdn
WHERE erank=2
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
limit 1
);

UPDATE salud_mental_encountero t 
SET t.medication_3_instructions = (
SELECT drug_instructions
FROM rnk_drug_inst rdn
WHERE erank=3
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
limit 1
);

UPDATE salud_mental_encountero t 
SET t.medication_4_instructions = (
SELECT drug_instructions
FROM rnk_drug_inst rdn
WHERE erank=4
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
limit 1
);

UPDATE salud_mental_encountero t 
SET t.medication_5_instructions = (
SELECT drug_instructions
FROM rnk_drug_inst rdn
WHERE erank=5
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
limit 1
);

UPDATE salud_mental_encountero t 
SET t.medication_6_instructions = (
SELECT drug_instructions
FROM rnk_drug_inst rdn
WHERE erank=6
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
limit 1
);

UPDATE salud_mental_encountero t 
SET t.medication_7_instructions = (
SELECT drug_instructions
FROM rnk_drug_inst rdn
WHERE erank=7
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
limit 1
);

UPDATE salud_mental_encountero t 
SET t.medication_8_instructions = (
SELECT drug_instructions
FROM rnk_drug_inst rdn
WHERE erank=8
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
limit 1
);

UPDATE salud_mental_encountero t 
SET t.medication_9_instructions  = (
SELECT drug_instructions
FROM rnk_drug_inst rdn
WHERE erank=9
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
limit 1
);

UPDATE salud_mental_encountero t 
SET t.medication_10_instructions = (
SELECT drug_instructions
FROM rnk_drug_inst rdn
WHERE erank=10
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
limit 1
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
limit 1
);

UPDATE salud_mental_encountero t 
SET t.medication_2_units = (
SELECT drug_dose
FROM rnk_drug_dose rdn
WHERE erank=2
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
limit 1
);

UPDATE salud_mental_encountero t 
SET t.medication_3_units = (
SELECT drug_dose
FROM rnk_drug_dose rdn
WHERE erank=3
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
limit 1
);

UPDATE salud_mental_encountero t 
SET t.medication_4_units = (
SELECT drug_dose
FROM rnk_drug_dose rdn
WHERE erank=4
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
limit 1
);

UPDATE salud_mental_encountero t 
SET t.medication_5_units = (
SELECT drug_dose
FROM rnk_drug_dose rdn
WHERE erank=5
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
limit 1
);

UPDATE salud_mental_encountero t 
SET t.medication_6_units = (
SELECT drug_dose
FROM rnk_drug_dose rdn
WHERE erank=6
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
limit 1
);

UPDATE salud_mental_encountero t 
SET t.medication_7_units = (
SELECT drug_dose
FROM rnk_drug_dose rdn
WHERE erank=7
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
limit 1
);

UPDATE salud_mental_encountero t 
SET t.medication_8_units = (
SELECT drug_dose
FROM rnk_drug_dose rdn
WHERE erank=8
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
limit 1
);

UPDATE salud_mental_encountero t 
SET t.medication_9_units  = (
SELECT drug_dose
FROM rnk_drug_dose rdn
WHERE erank=9
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
limit 1
);

UPDATE salud_mental_encountero t 
SET t.medication_10_units = (
SELECT drug_dose
FROM rnk_drug_dose rdn
WHERE erank=10
AND rdn.person_id=t.patient_id 
AND rdn.encounter_id=t.encounter_id 
limit 1
);

-- --------------------------------------- Lab order and Treatement Plan ----------------------------------------------------------------------------------------------------------------------------------------------
SELECT concept_id INTO @treatment_plan FROM concept WHERE uuid='162749AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
SELECT concept_id INTO @lab_ordered FROM concept WHERE uuid='24102c5d-b199-406f-b49d-83ddd7ce83d5';

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

-- ------------------------------- Pregnancy and delivery date --------------------------------------------------------------------------------
SELECT concept_id INTO @parental_care FROM concept WHERE uuid='165475AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
SELECT concept_id INTO @planned_pregnancy FROM concept WHERE uuid='1426AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
select concept_from_mapping('PIH','13731') into @wanted_pregnancy;

select program_id into @ANC from program p2 where uuid='d830a5c1-30a2-4943-93a0-f918772496ec';

UPDATE salud_mental_encountero t 
SET t.prenatal_care = (
	select TRUE 
	from patient_program 
	where patient_id=t.patient_id 
	and program_id=@ANC
	limit 1
);

-- -------------------------------------------- Indicators - psychosis --------------------------------------------------------------------------
SELECT concept_id INTO @Schizophrenia FROM concept WHERE uuid='3cd134f4-26fe-102b-80cb-0017a47871b2';
-- SELECT concept_id INTO @Acute_psychosis FROM concept WHERE uuid='3cd134f4-26fe-102b-80cb-0017a47871b2';
SELECT concept_id INTO @psychosis FROM concept WHERE uuid='3ccea7fc-26fe-102b-80cb-0017a47871b2';
SELECT concept_id INTO @Mania_wo_psychotic FROM concept WHERE uuid='162314AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
SELECT concept_id INTO @Mania_w_psychotic FROM concept WHERE uuid='162313AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';

DROP TABLE IF EXISTS psychosis_data;
CREATE TEMPORARY TABLE psychosis_data AS 
	 SELECT person_id,encounter_id, COUNT(1) AS num_obs
	 FROM obs WHERE (
	   	value_coded =@Schizophrenia -- Schizophrenia
	   -- 	OR concept_id=@Acute_psychosis -- Acute psychosis
	   	OR value_coded=@psychosis -- psychosis
	   	OR value_coded=@Mania_wo_psychotic -- Mania without psychotic symptoms
	   	OR value_coded=@Mania_w_psychotic -- Mania with psychotic symptoms
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

SELECT concept_id INTO @bipolar_disorder FROM concept WHERE uuid='121131AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
SELECT concept_id INTO @depression FROM concept WHERE uuid='3cce9514-26fe-102b-80cb-0017a47871b2';
SELECT concept_id INTO @mood_changes FROM concept WHERE uuid='118879AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';

DROP TABLE IF EXISTS mood_disorder_data;
CREATE TEMPORARY TABLE mood_disorder_data AS 
	 SELECT person_id,encounter_id, COUNT(1) AS num_obs
	 FROM obs WHERE (
	   	value_coded=@bipolar_disorder -- bipolar disorder
	   	OR value_coded=@depression -- depression
	   	OR value_coded=@mood_changes -- mood changes
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

SELECT concept_id INTO @panick_attack FROM concept WHERE uuid='130967AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
SELECT concept_id INTO @generalised_anxiety FROM concept WHERE uuid='139545AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
SELECT concept_id INTO @anxiety FROM concept WHERE uuid='3ce6b1ee-26fe-102b-80cb-0017a47871b2';
SELECT concept_id INTO @obsessive_compulsive_disorder FROM concept WHERE uuid='132611AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
SELECT concept_id INTO @acute_stress_reaction FROM concept WHERE uuid='149514AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
SELECT concept_id INTO @post_traumatic_stress FROM concept WHERE uuid='a31bbcf1-0374-4160-8cfe-8271e096762d';

DROP TABLE IF EXISTS anxiety_data;
CREATE TEMPORARY TABLE anxiety_data AS 
	 SELECT person_id, encounter_id, COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	value_coded=@panick_attack-- panick attack
	   	OR value_coded=@generalised_anxiety  -- generalised anxiety disorder
	   	OR value_coded=@anxiety -- anxiety
	   	OR value_coded=@obsessive_compulsive_disorder -- obsessive-compulsive disorder
	   	OR value_coded=@acute_stress_reaction -- acute stress reaction
	   	OR value_coded=@post_traumatic_stress -- post-traumatic stress disorder
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
SELECT concept_id INTO @dissociative_disorders FROM concept WHERE uuid='118883AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';

DROP TABLE IF EXISTS dissociative_disorders_data;
CREATE TEMPORARY TABLE dissociative_disorders_data AS 
	 SELECT person_id, encounter_id ,COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	value_coded=@dissociative_disorders
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
SELECT concept_id INTO @dissociative_disorders FROM concept WHERE uuid='489db96c-ef65-40d2-a96b-a2f0c59645fb';

DROP TABLE IF EXISTS psychosomatic_disorders_data;
CREATE TEMPORARY TABLE psychosomatic_disorders_data AS 
	 SELECT person_id, encounter_id, COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	value_coded =@dissociative_disorders
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
SELECT concept_id INTO @eating_disorders FROM concept WHERE uuid='118764AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
DROP TABLE IF EXISTS eating_disorders_data;
CREATE TEMPORARY TABLE eating_disorders_data AS 
	 SELECT person_id,encounter_id,  COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	value_coded=@eating_disorders 
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
SELECT concept_id INTO @personality_disorders FROM concept WHERE uuid='114193AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';

DROP TABLE IF EXISTS personality_disorders_data;
CREATE TEMPORARY TABLE personality_disorders_data AS 
	 SELECT person_id,encounter_id,  COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	value_coded=@personality_disorders
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
SELECT concept_id INTO @conduct_disorder FROM concept WHERE uuid='142513AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
SELECT concept_id INTO @attention_deficit FROM concept WHERE uuid='13cc6ea1-8379-4ec3-ab01-fce1deed31e3';
SELECT concept_id INTO @oppositional_deficit FROM concept WHERE uuid='142513AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';

DROP TABLE IF EXISTS conduct_disorders_data;
CREATE TEMPORARY TABLE conduct_disorders_data AS 
	 SELECT person_id,encounter_id , COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	value_coded=@conduct_disorder  -- conduct disorder
	   	OR value_coded = concept_from_mapping('PIH','10607') -- autism
	   	OR value_coded=@attention_deficit  -- attention deficit
	   	OR value_coded= @oppositional_deficit -- oppositional deficit
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
SELECT concept_id INTO @suicidal_thoughts FROM concept WHERE uuid='125562AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
SELECT concept_id INTO @attempted_suicide FROM concept WHERE uuid='148143AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';

DROP TABLE IF EXISTS suicidal_data;
CREATE TEMPORARY TABLE suicidal_data AS 
	 SELECT person_id, encounter_id , COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	value_coded=@suicidal_thoughts -- suicidal thoughts
	   	OR value_coded=@attempted_suicide -- attempted suicide
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


-- ----------------------------------------------  Indicators - grief & Adaptive_disorder ----------------------------------------------------
SELECT concept_id INTO @grief FROM concept WHERE uuid='121792AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';

DROP TABLE IF EXISTS grief_data;
CREATE TEMPORARY TABLE grief_data AS 
	 SELECT person_id,  encounter_id , COUNT(*) AS num_obs
	 FROM obs WHERE (
	   	value_coded=@grief
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

	
UPDATE salud_mental_encountero t 
SET t.adaptive_disorders  = (
 SELECT CASE WHEN num_obs > 0 THEN TRUE ELSE FALSE END 
 FROM  grief_data md
 WHERE md.person_id=t.Patient_id 
 AND md.encounter_id=t.encounter_id 
);

UPDATE salud_mental_encountero t 
SET t.adaptive_disorders  = FALSE 
WHERE t.adaptive_disorders  IS NULL;


-- --------------------------- Next Scheduled Appointment --------------------------------------------------------------------------
SELECT concept_id INTO @next_appt FROM concept WHERE uuid='3ce94df0-26fe-102b-80cb-0017a47871b2';

UPDATE salud_mental_encountero t 
SET t.next_appointment  = (
SELECT cast(value_datetime AS date)
FROM obs o
WHERE concept_id=@next_appt
and o.voided =0
AND o.person_id=t.patient_id 
AND o.encounter_id=t.encounter_id 
limit 1
);

-- --------------------------- estimated delivery date ----------------------------------------------------

UPDATE salud_mental_encountero t 
SET t.estimated_delivery_date  = (
SELECT cast(DATE_ADD(value_datetime, interval 280 day) as date)
FROM obs o
WHERE concept_id=@lastperioddate
and o.voided =0
AND o.person_id=t.patient_id 
-- AND o.encounter_id=t.encounter_id 
order by encounter_id desc
limit 1
)
WHERE t.prenatal_care is true;

-- ------------------------------------ Diagnosis -------------------------------------------------------------------------------------------------------------------------------------------
create or replace view diagnosis_pre_data as 
        select  
		distinct person_id, encounter_id,
		case when concept_name(value_coded,'en') is not null then concept_name(value_coded,'en') else value_text end as diagnosis
		from obs o 
		left outer join concept_name cn 
		on o.concept_id = cn.concept_id 
		where locale='en'
        and o.encounter_id in (select encounter_id from mental_encounter_details)
        and obs_group_id in (select obs_group_id from obs where concept_id in (1309, 1305, 1314))
        and (value_coded_name_id is not null or value_text is not null)
        order by obs_group_id asc;

CREATE OR REPLACE VIEW diagnosis_data as 
select person_id, encounter_id, 
		group_concat(diagnosis) as diagnosis
		from diagnosis_pre_data
group by person_id, encounter_id;

UPDATE salud_mental_encountero t 
SET t.diagnosis = (
SELECT diagnosis
FROM diagnosis_data dd
WHERE dd.person_id=t.patient_id 
AND dd.encounter_id=t.encounter_id 
limit 1
);

UPDATE salud_mental_encountero t 
SET t.primary_diagnosis  = (
SELECT diagnosis
FROM diagnosis_pre_data dp
WHERE dp.person_id=t.patient_id 
AND dp.encounter_id=t.encounter_id 
limit 1
);

-- ---- Ascending Order ------------------------------------------
drop table if exists int_asc;
create table int_asc
select * from salud_mental_encountero sme 
ORDER BY emr_id asc, encounter_date  asc, encounter_id asc;


set @row_number := 0;

DROP TABLE IF EXISTS asc_order;
CREATE TABLE asc_order
SELECT 
    @row_number:=CASE
        WHEN @emr_id = emr_id  
			THEN @row_number + 1
        ELSE 1
    END AS index_asc,
    @emr_id:=emr_id  emr_id,
    encounter_date,encounter_id
FROM
    int_asc;
   
update salud_mental_encountero es
set es.index_asc = (
 select index_asc 
 from asc_order
 where emr_id=es.emr_id 
 and encounter_date=es.encounter_date
 and encounter_id=es.encounter_id
);
    

-- ----------- Descending Order ---------------------------------------

drop table if exists int_desc;
create table int_desc
select * from salud_mental_encountero sme 
ORDER BY emr_id asc, encounter_date desc, encounter_id desc;

DROP TABLE IF EXISTS desc_order;
CREATE TABLE desc_order
SELECT 
    @row_number:=CASE
        WHEN @emr_id = emr_id 
			THEN @row_number + 1
        ELSE 1
    END AS index_desc,
    @emr_id:=emr_id patient_id,
    encounter_date,encounter_id
FROM
    int_desc; 
    
update salud_mental_encountero es
set es.index_desc = (
 select index_desc
 from desc_order
 where emr_id=es.emr_id 
 and encounter_date=es.encounter_date
 and encounter_id=es.encounter_id
);

UPDATE salud_mental_encountero sm 
INNER JOIN (
	SELECT DISTINCT p2.person_id, 
	uuid
	FROM person p2
) x ON sm.patient_id =x.person_id
SET sm.person_uuid = x.uuid;

-- --------------------------------------- Final Select -----------------------------------------------------------------------------------------------------------------------------------------
SELECT 
DISTINCT
CONCAT(@partition,'-',emr_id) "emr_id" ,
person_uuid,
location ,
age ,
encounter_id , 
encounter_uuid,
index_asc,
index_desc,
encounter_date , 
date_changed ,
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
FROM salud_mental_encountero
order by emr_id, encounter_date asc;