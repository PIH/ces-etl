SET @partition = '${partitionNum}';

SELECT encounter_type_id  INTO @consult_etype_id FROM encounter_type et WHERE et.uuid ='aa61d509-6e76-4036-a65d-7813c0c3b752';
SELECT program_id INTO @mh_program_id FROM program p WHERE uuid='0e69c3ab-1ccb-430b-b0db-b9760319230f';


DROP TABLE IF EXISTS salud_mental_paciente;
CREATE TEMPORARY TABLE salud_mental_paciente (
Patient_id	int,
emr_id	varchar(50),
person_uuid   char(38),
date_changed date,
age	int,
gender	varchar(30),
dead	bit,
death_Date	date,
mh_enrolled bit,
most_recent_mhealth_enc_id	int,
most_recent_mhealth_enc_date	datetime,
most_recent_consult_enc_id	int,
most_recent_consult_enc_date	datetime,
number_mental_health_enc	int,
mh_program_id int,
mental_health_enc_enroll_date	date,
reg_location	varchar(30),
recent_mental_status	varchar(50),
recent_mental_status_date	Date,
active	bit,
asthma	bit,
malnutrition	bit,
diabetes	bit,
epilepsy	bit,
hypertension	bit,
Comorbidity	bit,
next_visit_obs_id int,
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
Most_recent_PHQ9	int,
Date_most_recent_PHQ9	date,
PHQ9_q1_value_coded int, 
PHQ9_q1	int,
PHQ9_q2_value_coded int, 
PHQ9_q2	int,
PHQ9_q3_value_coded int, 
PHQ9_q3	int,
PHQ9_q4_value_coded int, 
PHQ9_q4	int,
PHQ9_q5_value_coded int, 
PHQ9_q5	int,
PHQ9_q6_value_coded int, 
PHQ9_q6	int,
PHQ9_q7_value_coded int, 
PHQ9_q7	int,
PHQ9_q8_value_coded int, 
PHQ9_q8	int,
PHQ9_q9_value_coded int, 
PHQ9_q9	int,
First_GAD7_score	int,
Date_first_GAD7	date,
Most_recent_GAD7	int,
Date_most_recent_GAD7	date,
GAD7_q1_value_coded int, 
GAD7_q1	int,
GAD7_q2_value_coded int, 
GAD7_q2	int,
GAD7_q3_value_coded int, 
GAD7_q3	int,
GAD7_q4_value_coded int, 
GAD7_q4	int,
GAD7_q5_value_coded int, 
GAD7_q5	int,
GAD7_q6_value_coded int, 
GAD7_q6	int,
GAD7_q7_value_coded int, 
GAD7_q7	int
);


-- ----------------- Views Defintions --------------------------------------------------------------

select concept_from_mapping('PIH','13661') into @phq1;
select concept_from_mapping('PIH','13662') into @phq2;
select concept_from_mapping('PIH','13663') into @phq3;
select concept_from_mapping('PIH','13664') into @phq4;
select concept_from_mapping('PIH','13665') into @phq5;
select concept_from_mapping('PIH','13666') into @phq6;
select concept_from_mapping('PIH','13667') into @phq7;
select concept_from_mapping('PIH','13668') into @phq8;
select concept_from_mapping('PIH','13669') into @phq9;
select concept_from_mapping('PIH','13671') into @gdq1;
select concept_from_mapping('PIH','13672') into @gdq2;
select concept_from_mapping('PIH','13673') into @gdq3;
select concept_from_mapping('PIH','13674') into @gdq4;
select concept_from_mapping('PIH','13675') into @gdq5;
select concept_from_mapping('PIH','13676') into @gdq6;
select concept_from_mapping('PIH','13677') into @gdq7;
select concept_from_mapping('PIH','11586') into @phqscore;
select concept_from_mapping('PIH','11733') into @gadscore;

DROP TABLE IF EXISTS temp_encounter;
CREATE TEMPORARY TABLE temp_encounter
SELECT encounter_id, patient_id, date(encounter_datetime) encounter_datetime, encounter_type 
FROM encounter e WHERE e.encounter_type = @consult_etype_id
AND e.voided = 0;

create index temp_encounter_i1 on temp_encounter(patient_id,encounter_id);

drop temporary table if exists temp_obs;
create temporary table temp_obs
select o.obs_id, o.voided, o.obs_group_id, o.encounter_id, o.person_id, o.concept_id, o.value_coded, o.value_numeric, o.value_text, o.value_datetime, o.value_drug, o.comments, o.date_created, o.obs_datetime
from obs o inner join temp_encounter t on o.encounter_id = t.encounter_id
where o.voided = 0;

create index temp_obs_i1 on temp_obs(person_id, concept_id);
create index temp_obs_i2 on temp_obs(obs_id);

-- ----------------- Insert Patinets List --------------------------------------------------------------

INSERT INTO salud_mental_paciente(patient_id,person_uuid,date_changed)
select distinct p.patient_id, n.uuid person_uuid ,n.date_changed --  e.encounter_id, date(e.encounter_datetime) encounter_date
from obs o
         inner join encounter e on o.encounter_id = e.encounter_id
         inner join patient p on e.patient_id = p.patient_id
         inner join person n on p.patient_id = n.person_id
where o.voided = 0 and e.voided = 0 and p.voided = 0 and n.voided = 0
  and o.concept_id in (
                       @phq1, @phq2, @phq3, @phq4, @phq5, @phq6, @phq7, @phq8, @phq9, @phqscore,
                       @gdq1, @gdq2, @gdq3, @gdq4, @gdq5, @gdq6, @gdq7, @gadscore
    )
UNION 
SELECT DISTINCT patient_id,n.uuid person_uuid ,n.date_changed 
FROM patient_program pp 
inner join person n on pp.patient_id = n.person_id
WHERE program_id =@mh_program_id     
;


create index salud_mental_paciente_i1 on salud_mental_paciente(patient_id);

UPDATE salud_mental_paciente set emr_id = patient_identifier(patient_id, '506add39-794f-11e8-9bcd-74e5f916c5ec');
UPDATE salud_mental_paciente set most_recent_mhealth_enc_id=latestEnc(patient_id,'Mental Health Consult' ,null);
UPDATE salud_mental_paciente set most_recent_mhealth_enc_date=encounter_date(most_recent_mhealth_enc_id);
UPDATE salud_mental_paciente set most_recent_consult_enc_id=latestEnc(patient_id,'Consult' ,null);
UPDATE salud_mental_paciente set most_recent_consult_enc_date=encounter_date(most_recent_consult_enc_id);
UPDATE salud_mental_paciente set age = age_at_enc(patient_id,COALESCE(most_recent_mhealth_enc_id,most_recent_consult_enc_id));
UPDATE salud_mental_paciente set gender = gender(patient_id);
UPDATE salud_mental_paciente set dead = dead(patient_id);
UPDATE salud_mental_paciente set death_date = death_date(patient_id);

-- --------------- Mental Encounters Columns -------------------------------------
UPDATE salud_mental_paciente SET mh_program_id=mostRecentPatientProgramId(patient_id, @mh_program_id);
UPDATE salud_mental_paciente SET mh_enrolled=if(mh_program_id is null, FALSE, TRUE);
				

UPDATE salud_mental_paciente t
SET t.number_mental_health_enc =(
	SELECT count(*)
	FROM temp_encounter
	WHERE patient_id = t.Patient_id 
	GROUP BY patient_id
);


-- ------------- Mental Health Enrollment Details -------------------------------------

UPDATE salud_mental_paciente t 
SET t.mental_health_enc_enroll_date=programStartDate(mh_program_id);


UPDATE salud_mental_paciente t 
SET t.mental_health_enc_enroll_date=date(encounter_date(firstEnc(patient_id,'Consult' ,null)))
WHERE t.mental_health_enc_enroll_date IS NULL;

UPDATE salud_mental_paciente t SET t.reg_location =loc_registered(patient_id);


-- ------------- Mental Health Program Status -------------------------------------

UPDATE salud_mental_paciente t 
SET t.recent_mental_status = (
	select concept_name(pp.outcome_concept_id,'es')
	from patient_program pp
	where pp.patient_id=t.patient_id
	AND pp.patient_program_id = t.mh_program_id
);


UPDATE salud_mental_paciente t 
SET t.recent_mental_status_date = (
	select date_completed
	from patient_program pp
	where pp.patient_id=t.patient_id
	AND pp.patient_program_id = t.mh_program_id
);


-- ------------- Mental Health Active -------------------------------------

UPDATE salud_mental_paciente t 
SET t.active =(
	SELECT CASE WHEN TIMESTAMPDIFF(MONTH, COALESCE(t.most_recent_mhealth_enc_date,t.most_recent_consult_enc_date), now()) <=6 THEN TRUE ELSE FALSE END
);

-- ------------- Indicators - asma -------------------------------------
select program_id into @asthma from program p2 where concept_id = concept_From_mapping('PIH','12211'); 
select program_id into @malnutrition from program p2 where concept_id = concept_From_mapping('PIH','2234'); 
select program_id into @Diabetes from program p2 where concept_id = concept_From_mapping('PIH','6748'); 
select program_id into @Epilepsy from program p2 where concept_id = concept_From_mapping('PIH','6851');
select program_id into @Hypertension from program p2 where concept_id = concept_From_mapping('PIH','6846'); 
select program_id into @ANC from program p2 where concept_id = concept_From_mapping('PIH','12002'); 

UPDATE salud_mental_paciente t SET t.asthma=FALSE;
UPDATE salud_mental_paciente t SET t.asthma=IF(mostRecentPatientProgramId(patient_id, @asthma) IS NOT NULL, TRUE, FALSE);


-- ------------- Indicators - malnutrition -------------------------------------

UPDATE salud_mental_paciente t SET t.malnutrition=FALSE;
UPDATE salud_mental_paciente t SET t.malnutrition=IF(mostRecentPatientProgramId(patient_id, @malnutrition) IS NOT NULL, TRUE, FALSE);


-- ------------- Indicators - diabetes -------------------------------------

UPDATE salud_mental_paciente t SET t.diabetes=FALSE;
UPDATE salud_mental_paciente t SET t.diabetes=IF(mostRecentPatientProgramId(patient_id, @Diabetes) IS NOT NULL, TRUE, FALSE);


-- ------------- Indicators - epilepsy -------------------------------------

UPDATE salud_mental_paciente t SET t.epilepsy=FALSE;
UPDATE salud_mental_paciente t SET t.epilepsy=IF(mostRecentPatientProgramId(patient_id, @Epilepsy) IS NOT NULL, TRUE, FALSE);

-- ------------- Indicators - hypertension -------------------------------------

UPDATE salud_mental_paciente t SET t.hypertension=FALSE;
UPDATE salud_mental_paciente t SET t.hypertension=IF(mostRecentPatientProgramId(patient_id, @Hypertension) IS NOT NULL, TRUE, FALSE);


-- ------------- Indicators - Comorbidity -------------------------------------

UPDATE salud_mental_paciente t 
SET t.Comorbidity = CASE WHEN t.asthma OR t.hypertension  OR t.diabetes  OR t.epilepsy OR t.malnutrition 
THEN TRUE ELSE FALSE END;

-- ------------- Next Appointment -------------------------------------

SELECT concept_from_mapping('PIH','5096') INTO @next_visit; -- FROM concept WHERE uuid='3ce94df0-26fe-102b-80cb-0017a47871b2';

UPDATE salud_mental_paciente t SET t.next_visit_obs_id=latest_obs_from_temp(patient_id,'PIH','5096');
UPDATE salud_mental_paciente t SET t.date_next_appointment=value_datetime_from_temp(next_visit_obs_id);

-- ------------- Indicators - psychosis -------------------------------------
UPDATE salud_mental_paciente t SET t.psychosis  = FALSE;
UPDATE salud_mental_paciente t SET t.psychosis  = 
				answerEverExists_from_temp(patient_id,'PIH','3064','PIH','467',null) -- Schizophrenia
                OR answerEverExists_from_temp(patient_id,'PIH','3064','PIH','9519',null) -- Acute psychosis
                OR answerEverExists_from_temp(patient_id,'PIH','3064','PIH','219',null) -- psychosis
                OR answerEverExists_from_temp(patient_id,'PIH','3064','PIH','9520',null) -- Mania without psychotic symptoms
                OR answerEverExists_from_temp(patient_id,'PIH','3064','PIH','9518',null) -- Mania with psychotic symptoms
               ;

-- ------------- Indicators - mood disorder -------------------------------------
UPDATE salud_mental_paciente t SET t.mood_disorder  = FALSE;
UPDATE salud_mental_paciente t SET t.mood_disorder  = 
				answerEverExists_from_temp(patient_id,'PIH','3064','PIH','7947',null) -- bipolar disorder
                OR answerEverExists_from_temp(patient_id,'PIH','3064','PIH','207',null) -- depression
               ;

-- ------------- Indicators - anxiety -------------------------------------
UPDATE salud_mental_paciente t SET t.anxiety  = FALSE;
UPDATE salud_mental_paciente t SET t.anxiety  = 
				answerEverExists_from_temp(patient_id,'PIH','3064','PIH','9330',null) -- panick attack
                OR answerEverExists_from_temp(patient_id,'PIH','3064','PIH','9517',null) -- generalised anxiety disorder
                OR answerEverExists_from_temp(patient_id,'PIH','3064','PIH','2719',null) -- anxiety
                OR answerEverExists_from_temp(patient_id,'PIH','3064','PIH','7513',null) -- obsessive-compulsive disorder
                OR answerEverExists_from_temp(patient_id,'PIH','3064','PIH','7950',null) -- acute stress reaction
                OR answerEverExists_from_temp(patient_id,'PIH','3064','PIH','7197',null)  -- post-traumatic stress disorder
               ;



-- ------------- Indicators - adaptive disorders -------------------------------------
UPDATE salud_mental_paciente t SET t.adaptive_disorders  = FALSE;
UPDATE salud_mental_paciente t SET t.adaptive_disorders  = 
				answerEverExists_from_temp(patient_id,'PIH','3064','PIH','14367',null)
               ;

-- ------------- Indicators - dissociative disorders -------------------------------------
UPDATE salud_mental_paciente t SET t.dissociative_disorders  = FALSE;
UPDATE salud_mental_paciente t SET t.dissociative_disorders  = 
				answerEverExists_from_temp(patient_id,'PIH','3064','PIH','7945',null)
               ;

-- ------------- Indicators - psychosomatic disorders -------------------------------------
UPDATE salud_mental_paciente t SET t.psychosomatic_disorders  = FALSE;
UPDATE salud_mental_paciente t SET t.psychosomatic_disorders  = 
				answerEverExists_from_temp(patient_id,'PIH','3064','PIH','7198',null)
               ;
              
-- ------------- Indicators - eating disorders -------------------------------------
UPDATE salud_mental_paciente t SET t.eating_disorders  = FALSE;
UPDATE salud_mental_paciente t SET t.eating_disorders  = 
				answerEverExists_from_temp(patient_id,'PIH','3064','PIH','7944',null)
               ;

-- ------------- Indicators - personality disorders -------------------------------------
UPDATE salud_mental_paciente t SET t.personality_disorders  = FALSE;
UPDATE salud_mental_paciente t SET t.personality_disorders  = 
				answerEverExists_from_temp(patient_id,'PIH','3064','PIH','7943',null)
               ;

-- ------------- Indicators - conduct disorders -------------------------------------
UPDATE salud_mental_paciente t SET t.conduct_disorders  = FALSE;
UPDATE salud_mental_paciente t SET t.conduct_disorders  = 
				answerEverExists_from_temp(patient_id,'PIH','3064','PIH','7949',null) OR  -- conduct disorder
				answerEverExists_from_temp(patient_id,'PIH','3064','PIH','11862',null) -- attention deficit
               ;
-- ------------- Indicators - suicidal -------------------------------------
UPDATE salud_mental_paciente t SET t.suicidal_ideation  = FALSE;
UPDATE salud_mental_paciente t SET t.suicidal_ideation  = 
				answerEverExists_from_temp(patient_id,'PIH','3064','PIH','10633',null) OR  -- suicidal thoughts
				answerEverExists_from_temp(patient_id,'PIH','3064','PIH','7514',null) -- attempted suicide
               ;

-- ------------- Indicators - grief -------------------------------------
UPDATE salud_mental_paciente t SET t.grief  = FALSE;
UPDATE salud_mental_paciente t SET t.grief  = 
				answerEverExists_from_temp(patient_id,'PIH','3064','PIH','6896',null) 
               ;

-- ------------- PHQ-9 Score Data -------------------------------------
              
UPDATE salud_mental_paciente t 
SET t.First_PHQ9_score = first_value_numeric_from_temp(t.patient_id,'PIH','11586');

UPDATE salud_mental_paciente t 
SET t.Date_first_PHQ9 = first_obs_datetime_from_temp(t.patient_id,'PIH','11586');



UPDATE salud_mental_paciente t 
SET t.Date_most_recent_PHQ9 = last_obs_datetime_from_temp(t.patient_id,'PIH','11586');


UPDATE salud_mental_paciente t 
SET t.Most_recent_PHQ9 = first_value_numeric_from_temp(t.patient_id,'PIH','11586');


-- ------------- GAD-7 Score Data -------------------------------------

UPDATE salud_mental_paciente t 
SET t.First_GAD7_score = first_value_numeric_from_temp(t.patient_id,'PIH','11733');


UPDATE salud_mental_paciente t 
SET t.Date_first_GAD7 = first_obs_datetime_from_temp(t.patient_id,'PIH','11733');



UPDATE salud_mental_paciente t 
SET t.Date_most_recent_GAD7 = last_obs_datetime_from_temp(t.patient_id,'PIH','11733');



UPDATE salud_mental_paciente t 
SET t.Most_recent_GAD7 = first_value_numeric_from_temp(t.patient_id,'PIH','11733');

-- ------------- PHQ-9 & GAD-7  Questions -------------------------------------

select concept_from_mapping('PIH','1090') into @never;
select concept_from_mapping('PIH','1603') into @somedays;
select concept_from_mapping('PIH','13660') into @morethanhalf;
select concept_from_mapping('PIH','1100') into @daily;
select concept_from_mapping('PIH','13661') into @little_interest;
select concept_from_mapping('PIH','13662') into @down_depressed;
select concept_from_mapping('PIH','13663') into @hard_Failing_sleep;
select concept_from_mapping('PIH','13664') into @feeling_tired;
select concept_from_mapping('PIH','13665') into @eating_less;
select concept_from_mapping('PIH','13666') into @failed_someone;
select concept_from_mapping('PIH','13667') into @distract_easily;
select concept_from_mapping('PIH','13668') into @feels_slower;
select concept_from_mapping('PIH','13669') into @suicidal_thoughts;
select concept_from_mapping('PIH','13671') into @feel_nervous;
select concept_from_mapping('PIH','13672') into @no_stop_worry;
select concept_from_mapping('PIH','13673') into @worry_much;
select concept_from_mapping('PIH','13674') into @diff_relaxing;
select concept_from_mapping('PIH','13675') into @so_restless;
select concept_from_mapping('PIH','13676') into @upset_easily;
select concept_from_mapping('PIH','13677') into @feeling_scared;

UPDATE salud_mental_paciente t 
SET t.PHQ9_q1_value_coded = latest_value_coded_from_temp_of_concept_id(t.patient_id,@little_interest);
UPDATE salud_mental_paciente t 
SET t.PHQ9_q1 = CASE WHEN PHQ9_q1_value_coded=@never THEN 0
 	 						 WHEN PHQ9_q1_value_coded=@somedays THEN 1
 	 						 WHEN PHQ9_q1_value_coded=@morethanhalf  THEN 2
	 						 WHEN PHQ9_q1_value_coded=@daily THEN 3 END;
	 						

UPDATE salud_mental_paciente t 
SET t.PHQ9_q2_value_coded = latest_value_coded_from_temp_of_concept_id(t.patient_id,@down_depressed);
UPDATE salud_mental_paciente t 
SET t.PHQ9_q2 =         CASE WHEN PHQ9_q2_value_coded=@never THEN 0
 	 						 WHEN PHQ9_q2_value_coded=@somedays THEN 1
 	 						 WHEN PHQ9_q2_value_coded=@morethanhalf  THEN 2
	 						 WHEN PHQ9_q2_value_coded=@daily THEN 3 END;
	 						
	 						
UPDATE salud_mental_paciente t 
SET t.PHQ9_q3_value_coded = latest_value_coded_from_temp_of_concept_id(t.patient_id,@hard_Failing_sleep);
UPDATE salud_mental_paciente t 
SET t.PHQ9_q3 =         CASE WHEN PHQ9_q3_value_coded=@never THEN 0
 	 						 WHEN PHQ9_q3_value_coded=@somedays THEN 1
 	 						 WHEN PHQ9_q3_value_coded=@morethanhalf  THEN 2
	 						 WHEN PHQ9_q3_value_coded=@daily THEN 3 END;

	 						
UPDATE salud_mental_paciente t 
SET t.PHQ9_q4_value_coded = latest_value_coded_from_temp_of_concept_id(t.patient_id,@feeling_tired);
UPDATE salud_mental_paciente t 
SET t.PHQ9_q4 =         CASE WHEN PHQ9_q4_value_coded=@never THEN 0
 	 						 WHEN PHQ9_q4_value_coded=@somedays THEN 1
 	 						 WHEN PHQ9_q4_value_coded=@morethanhalf  THEN 2
	 						 WHEN PHQ9_q4_value_coded=@daily THEN 3 END;
					
UPDATE salud_mental_paciente t 
SET t.PHQ9_q5_value_coded = latest_value_coded_from_temp_of_concept_id(t.patient_id,@eating_less);
UPDATE salud_mental_paciente t 
SET t.PHQ9_q5 =         CASE WHEN PHQ9_q5_value_coded=@never THEN 0
 	 						 WHEN PHQ9_q5_value_coded=@somedays THEN 1
 	 						 WHEN PHQ9_q5_value_coded=@morethanhalf  THEN 2
	 						 WHEN PHQ9_q5_value_coded=@daily THEN 3 END;

	 						
UPDATE salud_mental_paciente t 
SET t.PHQ9_q6_value_coded = latest_value_coded_from_temp_of_concept_id(t.patient_id,@failed_someone);
UPDATE salud_mental_paciente t 
SET t.PHQ9_q6 =         CASE WHEN PHQ9_q6_value_coded=@never THEN 0
 	 						 WHEN PHQ9_q6_value_coded=@somedays THEN 1
 	 						 WHEN PHQ9_q6_value_coded=@morethanhalf  THEN 2
	 						 WHEN PHQ9_q6_value_coded=@daily THEN 3 END;
					
UPDATE salud_mental_paciente t 
SET t.PHQ9_q7_value_coded = latest_value_coded_from_temp_of_concept_id(t.patient_id,@distract_easily);
UPDATE salud_mental_paciente t 
SET t.PHQ9_q7 =         CASE WHEN PHQ9_q7_value_coded=@never THEN 0
 	 						 WHEN PHQ9_q7_value_coded=@somedays THEN 1
 	 						 WHEN PHQ9_q7_value_coded=@morethanhalf  THEN 2
	 						 WHEN PHQ9_q7_value_coded=@daily THEN 3 END;

UPDATE salud_mental_paciente t 
SET t.PHQ9_q8_value_coded = latest_value_coded_from_temp_of_concept_id(t.patient_id,@feels_slower);
UPDATE salud_mental_paciente t 
SET t.PHQ9_q8 =         CASE WHEN PHQ9_q8_value_coded=@never THEN 0
 	 						 WHEN PHQ9_q8_value_coded=@somedays THEN 1
 	 						 WHEN PHQ9_q8_value_coded=@morethanhalf  THEN 2
	 						 WHEN PHQ9_q8_value_coded=@daily THEN 3 END;
	 						

UPDATE salud_mental_paciente t 
SET t.PHQ9_q9_value_coded = latest_value_coded_from_temp_of_concept_id(t.patient_id,@suicidal_thoughts);
UPDATE salud_mental_paciente t 
SET t.PHQ9_q9 =         CASE WHEN PHQ9_q9_value_coded=@never THEN 0
 	 						 WHEN PHQ9_q9_value_coded=@somedays THEN 1
 	 						 WHEN PHQ9_q9_value_coded=@morethanhalf  THEN 2
	 						 WHEN PHQ9_q9_value_coded=@daily THEN 3 END;
	 						
	 						
UPDATE salud_mental_paciente t 
SET t.GAD7_q1_value_coded = latest_value_coded_from_temp_of_concept_id(t.patient_id,@feel_nervous);
UPDATE salud_mental_paciente t 
SET t.GAD7_q1 =         CASE WHEN GAD7_q1_value_coded=@never THEN 0
 	 						 WHEN GAD7_q1_value_coded=@somedays THEN 1
 	 						 WHEN GAD7_q1_value_coded=@morethanhalf  THEN 2
	 						 WHEN GAD7_q1_value_coded=@daily THEN 3 END;

UPDATE salud_mental_paciente t 
SET t.GAD7_q2_value_coded = latest_value_coded_from_temp_of_concept_id(t.patient_id,@no_stop_worry);
UPDATE salud_mental_paciente t 
SET t.GAD7_q2 =         CASE WHEN GAD7_q2_value_coded=@never THEN 0
 	 						 WHEN GAD7_q2_value_coded=@somedays THEN 1
 	 						 WHEN GAD7_q2_value_coded=@morethanhalf  THEN 2
	 						 WHEN GAD7_q2_value_coded=@daily THEN 3 END;
	 						
			
UPDATE salud_mental_paciente t 
SET t.GAD7_q3_value_coded = latest_value_coded_from_temp_of_concept_id(t.patient_id,@worry_much);
UPDATE salud_mental_paciente t 
SET t.GAD7_q3 =         CASE WHEN GAD7_q3_value_coded=@never THEN 0
 	 						 WHEN GAD7_q3_value_coded=@somedays THEN 1
 	 						 WHEN GAD7_q3_value_coded=@morethanhalf  THEN 2
	 						 WHEN GAD7_q3_value_coded=@daily THEN 3 END;

	 						
UPDATE salud_mental_paciente t 
SET t.GAD7_q4_value_coded = latest_value_coded_from_temp_of_concept_id(t.patient_id,@diff_relaxing);
UPDATE salud_mental_paciente t 
SET t.GAD7_q4 =         CASE WHEN GAD7_q4_value_coded=@never THEN 0
 	 						 WHEN GAD7_q4_value_coded=@somedays THEN 1
 	 						 WHEN GAD7_q4_value_coded=@morethanhalf  THEN 2
	 						 WHEN GAD7_q4_value_coded=@daily THEN 3 END;

	 						
UPDATE salud_mental_paciente t 
SET t.GAD7_q5_value_coded = latest_value_coded_from_temp_of_concept_id(t.patient_id,@so_restless);
UPDATE salud_mental_paciente t 
SET t.GAD7_q5 =         CASE WHEN GAD7_q5_value_coded=@never THEN 0
 	 						 WHEN GAD7_q5_value_coded=@somedays THEN 1
 	 						 WHEN GAD7_q5_value_coded=@morethanhalf  THEN 2
	 						 WHEN GAD7_q5_value_coded=@daily THEN 3 END;

UPDATE salud_mental_paciente t 
SET t.GAD7_q6_value_coded = latest_value_coded_from_temp_of_concept_id(t.patient_id,@upset_easily);
UPDATE salud_mental_paciente t 
SET t.GAD7_q6 =         CASE WHEN GAD7_q6_value_coded=@never THEN 0
 	 						 WHEN GAD7_q6_value_coded=@somedays THEN 1
 	 						 WHEN GAD7_q6_value_coded=@morethanhalf  THEN 2
	 						 WHEN GAD7_q6_value_coded=@daily THEN 3 END;
	 						
	 						
UPDATE salud_mental_paciente t 
SET t.GAD7_q7_value_coded = latest_value_coded_from_temp_of_concept_id(t.patient_id,@feeling_scared);
UPDATE salud_mental_paciente t 
SET t.GAD7_q7 =         CASE WHEN GAD7_q7_value_coded=@never THEN 0
 	 						 WHEN GAD7_q7_value_coded=@somedays THEN 1
 	 						 WHEN GAD7_q7_value_coded=@morethanhalf  THEN 2
	 						 WHEN GAD7_q7_value_coded=@daily THEN 3 END;

SELECT 
CONCAT(@partition,'-',emr_id) "emr_id",
person_uuid,
date_changed,
age,
gender,
dead,
death_Date,
mh_enrolled, 
COALESCE (most_recent_mhealth_enc_date,most_recent_consult_enc_date) AS most_recent_mental_health_enc,
number_mental_health_enc,
mental_health_enc_enroll_date,
reg_location,
recent_mental_status,
recent_mental_status_date,
active,
asthma,
malnutrition,
diabetes,
epilepsy,
hypertension,
Comorbidity,
date_next_appointment,
psychosis,
mood_disorder,
anxiety,
adaptive_disorders,
dissociative_disorders,
psychosomatic_disorders,
eating_disorders,
personality_disorders,
conduct_disorders,
suicidal_ideation,
grief,
First_PHQ9_score,
Date_first_PHQ9,
Date_most_recent_PHQ9,
PHQ9_q1,
PHQ9_q2,
PHQ9_q3,
PHQ9_q4,
PHQ9_q5,
PHQ9_q6,
PHQ9_q7,
PHQ9_q8,
PHQ9_q9,
Most_recent_PHQ9,
First_GAD7_score,
Date_first_GAD7,
Date_most_recent_GAD7,
GAD7_q1,
GAD7_q2,
GAD7_q3,
GAD7_q4,
GAD7_q5,
GAD7_q6,
GAD7_q7,
Most_recent_GAD7
FROM salud_mental_paciente smp;
