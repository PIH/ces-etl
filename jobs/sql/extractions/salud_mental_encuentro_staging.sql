SET @partition = '${partitionNum}';

drop temporary table if exists salud_mental_encountero;
create temporary table salud_mental_encountero (
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
data_entry_user_id int,
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
analysis_notes varchar(2000),
visit_end_status varchar(30),
diagnosis varchar(1000),
diagnosis_en varchar(1000),
primary_diagnosis varchar(1000),
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
medication_1_obs_group_id int,
medication_1_name varchar(255),
medication_1_units int,
medication_1_instructions varchar(255),
medication_2_obs_group_id int,
medication_2_name varchar(255),
medication_2_units int,
medication_2_instructions varchar(255),
medication_3_obs_group_id int,
medication_3_name varchar(255),
medication_3_units int,
medication_3_instructions varchar(255),
medication_4_obs_group_id int,
medication_4_name varchar(255),
medication_4_units int,
medication_4_instructions varchar(255),
medication_5_obs_group_id int,
medication_5_name varchar(255),
medication_5_units int,
medication_5_instructions varchar(255),
medication_6_obs_group_id int,
medication_6_name varchar(255),
medication_6_units int,
medication_6_instructions varchar(255),
medication_7_obs_group_id int,
medication_7_name varchar(255),
medication_7_units int,
medication_7_instructions varchar(255),
medication_8_obs_group_id int,
medication_8_name varchar(255),
medication_8_units int,
medication_8_instructions varchar(255),
medication_9_obs_group_id int,
medication_9_name varchar(255),
medication_9_units int,
medication_9_instructions varchar(255),
medication_10_obs_group_id int,
medication_10_name varchar(255),
medication_10_units int,
medication_10_instructions varchar(255),
next_appointment date
);

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

-- Mental health encounters are defined as any encounters that contain obs for specific questions (phq and gdq)
-- Load up the mental health encounter table with the non-voided encounters that match this

insert into salud_mental_encountero (patient_id, person_uuid, encounter_id, encounter_uuid, encounter_date, visit_id, data_entry_user_id, data_entry_date, date_changed)
select distinct p.patient_id, n.uuid, e.encounter_id, e.uuid, date(e.encounter_datetime), e.visit_id, e.creator, date(e.date_created), date(e.date_changed)
from obs o
inner join encounter e on o.encounter_id = e.encounter_id
inner join patient p on e.patient_id = p.patient_id
inner join person n on p.patient_id = n.person_id
where o.voided = 0 and e.voided = 0 and p.voided = 0 and n.voided = 0
and o.concept_id in (
  @phq1, @phq2, @phq3, @phq4, @phq5, @phq6, @phq7, @phq8, @phq9, @phqscore,
  @gdq1, @gdq2, @gdq3, @gdq4, @gdq5, @gdq6, @gdq7, @gadscore
)
;
create index salud_mental_encountero_ci1 on salud_mental_encountero(encounter_id);
create index salud_mental_encountero_ci2 on salud_mental_encountero(patient_id);
create index salud_mental_encountero_ci3 on salud_mental_encountero(data_entry_user_id);

update salud_mental_encountero set emr_id = patient_identifier(patient_id, '506add39-794f-11e8-9bcd-74e5f916c5ec');
update salud_mental_encountero set location = encounter_location_name(encounter_id);
update salud_mental_encountero set age = age_at_enc(patient_id, encounter_id);
update salud_mental_encountero set data_entry_person = username(data_entry_user_id);
update salud_mental_encountero set mh_visit_date = visit_date(encounter_id);
update salud_mental_encountero set provider_name = username(data_entry_user_id);  # TODO: Seems wrong

-- Observation values.  We use a temporary table to first collect the obs relevant for these encounters for performance reasons

drop temporary table if exists temp_obs;
create temporary table temp_obs
select o.obs_id, o.voided, o.obs_group_id, o.encounter_id, o.person_id, o.concept_id, o.value_coded, o.value_numeric, o.value_text, o.value_datetime, o.value_drug, o.comments, o.date_created, o.obs_datetime
from obs o inner join salud_mental_encountero t on o.encounter_id = t.encounter_id
where o.voided = 0;

create index temp_obs_ci1 on temp_obs(encounter_id, concept_id);
create index temp_obs_ci2 on temp_obs(person_id, concept_id);
create index temp_obs_ci3 on temp_obs(date_created, obs_id);
create index temp_obs_ci4 on temp_obs(obs_group_id, concept_id);
create index temp_obs_ci5 on temp_obs(person_id, concept_id, obs_datetime);
create index temp_obs_oi on temp_obs(obs_id);

-- ############# PHQ-9 & GAD-7  Questions #####################################

select concept_from_mapping('PIH','1090') into @never;
select concept_from_mapping('PIH','1603') into @somedays;
select concept_from_mapping('PIH','13660') into @morethanhalf;
select concept_from_mapping('PIH','1100') into @daily;

update temp_obs set value_numeric = 0 where value_coded = @never;
update temp_obs set value_numeric = 1 where value_coded = @somedays;
update temp_obs set value_numeric = 2 where value_coded = @morethanhalf;
update temp_obs set value_numeric = 3 where value_coded = @daily;

update salud_mental_encountero set PHQ9_q1 = obs_value_numeric_from_temp(encounter_id, 'PIH', '13661');
update salud_mental_encountero set PHQ9_q2 = obs_value_numeric_from_temp(encounter_id, 'PIH', '13662');
update salud_mental_encountero set PHQ9_q3 = obs_value_numeric_from_temp(encounter_id, 'PIH', '13663');
update salud_mental_encountero set PHQ9_q4 = obs_value_numeric_from_temp(encounter_id, 'PIH', '13664');
update salud_mental_encountero set PHQ9_q5 = obs_value_numeric_from_temp(encounter_id, 'PIH', '13665');
update salud_mental_encountero set PHQ9_q6 = obs_value_numeric_from_temp(encounter_id, 'PIH', '13666');
update salud_mental_encountero set PHQ9_q7 = obs_value_numeric_from_temp(encounter_id, 'PIH', '13667');
update salud_mental_encountero set PHQ9_q8 = obs_value_numeric_from_temp(encounter_id, 'PIH', '13668');
update salud_mental_encountero set PHQ9_q9 = obs_value_numeric_from_temp(encounter_id, 'PIH', '13669');

update salud_mental_encountero set GAD7_q1 = obs_value_numeric_from_temp(encounter_id, 'PIH', '13671');
update salud_mental_encountero set GAD7_q2 = obs_value_numeric_from_temp(encounter_id, 'PIH', '13672');
update salud_mental_encountero set GAD7_q3 = obs_value_numeric_from_temp(encounter_id, 'PIH', '13673');
update salud_mental_encountero set GAD7_q4 = obs_value_numeric_from_temp(encounter_id, 'PIH', '13674');
update salud_mental_encountero set GAD7_q5 = obs_value_numeric_from_temp(encounter_id, 'PIH', '13675');
update salud_mental_encountero set GAD7_q6 = obs_value_numeric_from_temp(encounter_id, 'PIH', '13676');
update salud_mental_encountero set GAD7_q7 = obs_value_numeric_from_temp(encounter_id, 'PIH', '13677');

update salud_mental_encountero set PHQ9_score = obs_value_numeric_from_temp(encounter_id, 'PIH', '11586');
update salud_mental_encountero set GAD7_score = obs_value_numeric_from_temp(encounter_id, 'PIH', '11733');

-- ############## Observations ###################################

update salud_mental_encountero set visit_Reason = obs_value_coded_list_from_temp(encounter_id, 'PIH', '6189', 'en');
update salud_mental_encountero set analysis_notes = obs_value_text_from_temp(encounter_id, 'PIH', '1364');
update salud_mental_encountero set case_notes = obs_value_text_from_temp(encounter_id, 'PIH', '1336');
update salud_mental_encountero set Treatment_plan = obs_value_text_from_temp(encounter_id, 'PIH', '10534');
update salud_mental_encountero set lab_tests_ordered = obs_value_text_from_temp(encounter_id, 'PIH', '11762');
update salud_mental_encountero set next_appointment = date(obs_value_datetime_from_temp(encounter_id, 'PIH', '5096'));

-- ############# Medications #####################################

-- First thing is to get all medication obs name obs in order.

select concept_from_mapping('PIH','1282') into @medName;

drop table if exists temp_mh_medication_name_obs;
create temporary table temp_mh_medication_name_obs
select encounter_id,
       obs_id,
       value_drug,
       @obs_group_id:=obs_group_id obs_group_id,
       @row_number:=if(@obs_group_id = obs_group_id, @row_number + 1, 1) obs_group_order
from   temp_obs
where  concept_id = @medName
order by encounter_id, obs_group_id, date_created asc;
create index temp_mh_medication_name_obs_idx1 on temp_mh_medication_name_obs(encounter_id, obs_group_order);

update salud_mental_encountero e
inner join temp_mh_medication_name_obs o on e.encounter_id = o.encounter_id
set e.medication_1_obs_group_id = o.obs_group_id, e.medication_1_name = drugName(o.value_drug)
where o.obs_group_order = 1;

update salud_mental_encountero e
inner join temp_mh_medication_name_obs o on e.encounter_id = o.encounter_id
set e.medication_2_obs_group_id = o.obs_group_id, e.medication_2_name = drugName(o.value_drug)
where o.obs_group_order = 2;

update salud_mental_encountero e
inner join temp_mh_medication_name_obs o on e.encounter_id = o.encounter_id
set e.medication_3_obs_group_id = o.obs_group_id, e.medication_3_name = drugName(o.value_drug)
where o.obs_group_order = 3;

update salud_mental_encountero e
inner join temp_mh_medication_name_obs o on e.encounter_id = o.encounter_id
set e.medication_4_obs_group_id = o.obs_group_id, e.medication_4_name = drugName(o.value_drug)
where o.obs_group_order = 4;

update salud_mental_encountero e
inner join temp_mh_medication_name_obs o on e.encounter_id = o.encounter_id
set e.medication_5_obs_group_id = o.obs_group_id, e.medication_5_name = drugName(o.value_drug)
where o.obs_group_order = 5;

update salud_mental_encountero e
inner join temp_mh_medication_name_obs o on e.encounter_id = o.encounter_id
set e.medication_6_obs_group_id = o.obs_group_id, e.medication_6_name = drugName(o.value_drug)
where o.obs_group_order = 6;

update salud_mental_encountero e
inner join temp_mh_medication_name_obs o on e.encounter_id = o.encounter_id
set e.medication_7_obs_group_id = o.obs_group_id, e.medication_7_name = drugName(o.value_drug)
where o.obs_group_order = 7;

update salud_mental_encountero e
inner join temp_mh_medication_name_obs o on e.encounter_id = o.encounter_id
set e.medication_8_obs_group_id = o.obs_group_id, e.medication_8_name = drugName(o.value_drug)
where o.obs_group_order = 8;

update salud_mental_encountero e
inner join temp_mh_medication_name_obs o on e.encounter_id = o.encounter_id
set e.medication_9_obs_group_id = o.obs_group_id, e.medication_9_name = drugName(o.value_drug)
where o.obs_group_order = 9;

update salud_mental_encountero e
inner join temp_mh_medication_name_obs o on e.encounter_id = o.encounter_id
set e.medication_10_obs_group_id = o.obs_group_id, e.medication_10_name = drugName(o.value_drug)
where o.obs_group_order = 10;

-- Once the medication names are established with the relevent groups, other group members can be added

update salud_mental_encountero set medication_1_instructions = obs_from_group_id_value_text_from_temp(medication_1_obs_group_id, 'PIH', '9072');
update salud_mental_encountero set medication_2_instructions = obs_from_group_id_value_text_from_temp(medication_2_obs_group_id, 'PIH', '9072');
update salud_mental_encountero set medication_3_instructions = obs_from_group_id_value_text_from_temp(medication_3_obs_group_id, 'PIH', '9072');
update salud_mental_encountero set medication_4_instructions = obs_from_group_id_value_text_from_temp(medication_4_obs_group_id, 'PIH', '9072');
update salud_mental_encountero set medication_5_instructions = obs_from_group_id_value_text_from_temp(medication_5_obs_group_id, 'PIH', '9072');
update salud_mental_encountero set medication_6_instructions = obs_from_group_id_value_text_from_temp(medication_6_obs_group_id, 'PIH', '9072');
update salud_mental_encountero set medication_7_instructions = obs_from_group_id_value_text_from_temp(medication_7_obs_group_id, 'PIH', '9072');
update salud_mental_encountero set medication_8_instructions = obs_from_group_id_value_text_from_temp(medication_8_obs_group_id, 'PIH', '9072');
update salud_mental_encountero set medication_9_instructions = obs_from_group_id_value_text_from_temp(medication_9_obs_group_id, 'PIH', '9072');
update salud_mental_encountero set medication_10_instructions = obs_from_group_id_value_text_from_temp(medication_10_obs_group_id, 'PIH', '9072');

update salud_mental_encountero set medication_1_units = obs_from_group_id_value_text_from_temp(medication_1_obs_group_id, 'PIH', '9071');
update salud_mental_encountero set medication_2_units = obs_from_group_id_value_text_from_temp(medication_2_obs_group_id, 'PIH', '9071');
update salud_mental_encountero set medication_3_units = obs_from_group_id_value_text_from_temp(medication_3_obs_group_id, 'PIH', '9071');
update salud_mental_encountero set medication_4_units = obs_from_group_id_value_text_from_temp(medication_4_obs_group_id, 'PIH', '9071');
update salud_mental_encountero set medication_5_units = obs_from_group_id_value_text_from_temp(medication_5_obs_group_id, 'PIH', '9071');
update salud_mental_encountero set medication_6_units = obs_from_group_id_value_text_from_temp(medication_6_obs_group_id, 'PIH', '9071');
update salud_mental_encountero set medication_7_units = obs_from_group_id_value_text_from_temp(medication_7_obs_group_id, 'PIH', '9071');
update salud_mental_encountero set medication_8_units = obs_from_group_id_value_text_from_temp(medication_8_obs_group_id, 'PIH', '9071');
update salud_mental_encountero set medication_9_units = obs_from_group_id_value_text_from_temp(medication_9_obs_group_id, 'PIH', '9071');
update salud_mental_encountero set medication_10_units = obs_from_group_id_value_text_from_temp(medication_10_obs_group_id, 'PIH', '9071');

-- ---------------------------------------- Prenatal ---------------------------------------------------

select program_id into @anc_program_id from program where uuid='d830a5c1-30a2-4943-93a0-f918772496ec';
update salud_mental_encountero set prenatal_care = if(mostRecentPatientProgramId(patient_id, @anc_program_id) is null, FALSE, TRUE);

update salud_mental_encountero set estimated_delivery_date = date(date_add(obs_value_datetime_from_temp(encounter_id, 'PIH', '968'), interval 280 day))
where prenatal_care = TRUE;

-- -------------------------------------------- Indicators - psychosis ----------------------------------

select concept_from_mapping('PIH','467') into @Schizophrenia;
select concept_from_mapping('PIH','219') into @psychosis;
select concept_from_mapping('PIH','9518') into @Mania_wo_psychotic;
select concept_from_mapping('PIH','9520') into @Mania_w_psychotic;

update salud_mental_encountero set psychosis = FALSE;
update salud_mental_encountero e inner join temp_obs o on e.encounter_id = o.encounter_id set e.psychosis = TRUE
where o.value_coded in (@Schizophrenia, @psychosis, @Mania_wo_psychotic, @Mania_w_psychotic);

-- -------------------------------------------- Indicators - mood disorder -------------------------------

select concept_from_mapping('PIH','7947') into @bipolar_disorder;
select concept_from_mapping('PIH','207') into @depression;
select concept_from_mapping('PIH','9527') into @mood_changes;

update salud_mental_encountero set mood_disorder = FALSE;
update salud_mental_encountero e inner join temp_obs o on e.encounter_id = o.encounter_id set e.mood_disorder = TRUE
where o.value_coded in (@bipolar_disorder, @depression, @mood_changes);

-- -------------------------------------------------------- Indicators - anxiety --------------------------

SELECT concept_id INTO @panick_attack FROM concept WHERE uuid='130967AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
SELECT concept_id INTO @generalised_anxiety FROM concept WHERE uuid='139545AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
SELECT concept_id INTO @anxiety FROM concept WHERE uuid='3ce6b1ee-26fe-102b-80cb-0017a47871b2';
SELECT concept_id INTO @obsessive_compulsive_disorder FROM concept WHERE uuid='132611AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
SELECT concept_id INTO @acute_stress_reaction FROM concept WHERE uuid='149514AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
SELECT concept_id INTO @post_traumatic_stress FROM concept WHERE uuid='a31bbcf1-0374-4160-8cfe-8271e096762d';

update salud_mental_encountero set anxiety = FALSE;
update salud_mental_encountero e inner join temp_obs o on e.encounter_id = o.encounter_id set e.anxiety = TRUE
where o.value_coded in (@panick_attack, @generalised_anxiety, @anxiety, @obsessive_compulsive_disorder, @acute_stress_reaction, @post_traumatic_stress);

-- ---------------------------------------------------- Indicators - dissociative disorders ------------------

SELECT concept_id INTO @dissociative_disorders FROM concept WHERE uuid='118883AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
update salud_mental_encountero set dissociative_disorders = FALSE;
update salud_mental_encountero e inner join temp_obs o on e.encounter_id = o.encounter_id set e.dissociative_disorders = TRUE
where o.value_coded in (@dissociative_disorders);

-- ----------------------------------------------------- Indicators - psychosomatic disorders -----------------

SELECT concept_id INTO @psychosomatic_disorders FROM concept WHERE uuid='489db96c-ef65-40d2-a96b-a2f0c59645fb';
update salud_mental_encountero set psychosomatic_disorders = FALSE;
update salud_mental_encountero e inner join temp_obs o on e.encounter_id = o.encounter_id set e.psychosomatic_disorders = TRUE
where o.value_coded in (@psychosomatic_disorders);

-- ---------------------------------------------------- Indicators - eating disorders ---------------------------

SELECT concept_id INTO @eating_disorders FROM concept WHERE uuid='118764AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
update salud_mental_encountero set eating_disorders = FALSE;
update salud_mental_encountero e inner join temp_obs o on e.encounter_id = o.encounter_id set e.eating_disorders = TRUE
where o.value_coded in (@eating_disorders);

-- ------------------------------------------------------- Indicators - personality disorders -------------------

SELECT concept_id INTO @personality_disorders FROM concept WHERE uuid='114193AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
update salud_mental_encountero set personality_disorders = FALSE;
update salud_mental_encountero e inner join temp_obs o on e.encounter_id = o.encounter_id set e.personality_disorders = TRUE
where o.value_coded in (@personality_disorders);

-- ----------------------------------------- Indicators - conduct disorders ----------------------------------------

SELECT concept_id INTO @conduct_disorder FROM concept WHERE uuid='142513AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
SELECT concept_id INTO @attention_deficit FROM concept WHERE uuid='13cc6ea1-8379-4ec3-ab01-fce1deed31e3';
SELECT concept_from_mapping('PIH','10607') into @autism;
SELECT concept_id INTO @oppositional_deficit FROM concept WHERE uuid='142513AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';

update salud_mental_encountero set conduct_disorders = FALSE;
update salud_mental_encountero e inner join temp_obs o on e.encounter_id = o.encounter_id set e.conduct_disorders = TRUE
where o.value_coded in (@conduct_disorder, @attention_deficit, @autism, @oppositional_deficit);

-- ------------------------------------------------- Indicators - suicidal -------------------------------------

SELECT concept_id INTO @suicidal_thoughts FROM concept WHERE uuid='125562AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
SELECT concept_id INTO @attempted_suicide FROM concept WHERE uuid='148143AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';

update salud_mental_encountero set suicidal_ideation = FALSE;
update salud_mental_encountero e inner join temp_obs o on e.encounter_id = o.encounter_id set e.suicidal_ideation = TRUE
where o.value_coded in (@suicidal_thoughts, @attempted_suicide);

-- ----------------------------------------------  Indicators - grief & Adaptive_disorder ----------------------

SELECT concept_id INTO @grief FROM concept WHERE uuid='121792AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';

update salud_mental_encountero set grief = FALSE, adaptive_disorders = FALSE;
update salud_mental_encountero e inner join temp_obs o on e.encounter_id = o.encounter_id set e.grief = TRUE, adaptive_disorders = TRUE
where o.value_coded in (@grief);

-- ------------------------------------ Diagnosis -------------------------------------------------------------------------------------------------------------------------------------------

update salud_mental_encountero set diagnosis = obs_value_coded_list_from_temp(encounter_id, 'PIH', '3064', 'es');
update salud_mental_encountero set diagnosis_en = obs_value_coded_list_from_temp(encounter_id, 'PIH', '3064', 'en');

update salud_mental_encountero e inner join temp_obs o on e.encounter_id = o.encounter_id
set e.primary_diagnosis = value_coded_name(o.obs_id, 'en')
where o.concept_id = concept_from_mapping('PIH', '3064');

-- --------------------------------------- Final Select -----------------------------------------------------------------------------------------------------------------------------------------
SELECT 
DISTINCT
CONCAT(@partition,'-',emr_id) as emr_id,
person_uuid,
location ,
age ,
CONCAT(@partition,'-',encounter_id) as encounter_id,
encounter_uuid,
index_asc,
index_desc,
encounter_date , 
date_changed ,
data_entry_date ,
data_entry_person ,
CONCAT(@partition,'-',visit_id) as visit_id,
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
diagnosis, 
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
order by CONCAT(@partition,'-',emr_id), encounter_date;