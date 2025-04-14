SET sql_safe_updates = 0;

set @locale = 'es';
set @partition = '${partitionNum}';

SET @consultEncTypeId = (select encounter_type_id from encounter_type et where uuid = 'aa61d509-6e76-4036-a65d-7813c0c3b752');
set @yes = concept_from_mapping('PIH','1065');
set @no = concept_from_mapping('PIH','1066');
set @symptom_present = concept_from_mapping('PIH','1293');
set @symptom_absent = concept_from_mapping('PIH','1734');


DROP TEMPORARY TABLE IF EXISTS temp_consult;
CREATE TEMPORARY TABLE temp_consult
(
patient_id                            int(11),       
person_uuid                           char(38),      
emr_id                                varchar(50),   
encounter_id                          int(11),       
encounter_uuid                        char(38),      
encounter_type                        varchar(255),  
encounter_date                        datetime,      
encounter_location                    varchar(255),  
date_entered                          datetime,      
user_entered                          varchar(255),  
date_changed                          datetime,      
provider                              varchar(255),  
visit_id                              int(11),       
age_at_encounter                      double,
diabetes                              bit,           
asthma                                bit,           
malnutrition                          bit,           
epilepsy                              bit,           
hypertension                          bit,           
prenatal_care                         bit,           
mental_health                         bit,           
asthma_cough                          bit,           
asthma_waking                         bit,           
asthma_medicate                       bit,           
asthma_activity                       bit,           
glucose                               double,        
fasting                               bit,           
hba1c                                 double,        
proteinuria_diabetes                  int,           
abdominal_circumference               double,        
foot_exam                             varchar(255),  
hypoglycemia_symptoms                 bit,            
alcohol                               varchar(255),  
tobacco                               varchar(255),  
total_cholesterol                     double,        
hdl                                   double,        
ldl                                   double,        
hearts                                bit,           
hearts_change_treatment               bit,           
hearts_cardiovascular_risk            double,        
epilepsy_attacks_before               double,        
epilepsy_attacks_last_4weeks          double,        
planned_pregnancy                     bit,           
unplanned_cause_contraceptive_failure bit,           
unplanned_cause_violence              bit,           
pregnancy_wanted                      bit,           
lmp                                   date,          
gestational_age                       double,        
delivery_date_estimated               date,          
pregnancies                           int,           
births                                int,           
cesarians                             int,           
miscarriages                          int,           
stillbirths                           int,           
ultrasound_report                     text,          
hiv_test_prenatal                     varchar(255),  
vdrl_test                             varchar(255),  
hemoglobin                            double,        
proteinuria_prenatal                  double,        
blood_type                            varchar(255),  
vaccine_dtp                           bit,           
glucose_tolerance_curve               varchar(255),  
delivery_plan                         text,          
phq9                                  int,           
gad7                                  int,           
physical_exam                         text,          
tb_suspected                          bit,           
tb_test                               varchar(255),  
hiv_suspected                         bit,           
hiv_test                              varchar(255),  
covid_suspected                       bit,           
covid_test                            varchar(255),  
analysis                              text,    
diagnoses                             text,
primary_dx_obs_group_id               int(11),       
primary_diagnosis                     varchar(255),  
secondary_diagnosis                   varchar(1200), 
clinical_indication                   text,           
ultrasound_type                       varchar(255),  
ultrasound_measurement_used           varchar(255),  
ultrasound_gestational_age            double,        
delivery_date_ultrasound              date,          
fetal_weight                          double,        
diagnosis_change_ultrasound           bit,           
birth_control_pills                   bit,           
1month_injection                      bit,           
2month_injection                      bit,           
3month_injection                      bit,           
implant                               bit,           
birth_control_patch                   bit,           
emergency_birth_control               bit,           
iud_copper                            bit,           
iud_mirena                            bit,           
condoms                               bit,           
mifepristone                          bit,           
misoprostol                           bit,           
iron_dextran                          bit,           
next_visit_date                       date,          
prueba_sifilis                        varchar(20),   
prueba_hepb                           varchar(20),   
prueba_clamidia                       varchar(20),   
prueba_gonorrea                       varchar(20),   
prueba_hepc                           varchar(20),   
comentario_ultrasonido                text,          
PHQ9_q1                               int,           
PHQ9_q2                               int,           
PHQ9_q3                               int,           
PHQ9_q4                               int,           
PHQ9_q5                               int,           
PHQ9_q6                               int,           
PHQ9_q7                               int,           
PHQ9_q8                               int,           
PHQ9_q9                               int,           
PHQ9_score                            int,           
GAD7_q1                               int,           
GAD7_q2                               int,           
GAD7_q3                               int,           
GAD7_q4                               int,           
GAD7_q5                               int,           
GAD7_q6                               int,           
GAD7_q7                               int,           
GAD7_score                            int,           
analysis_notes                        varchar(2000), 
mh_program_outcome_group_obs_id       int(11),
mh_program_outcome                    varchar(30),   
psychosis                             boolean,       
mood_disorder                         boolean,       
anxiety                               boolean,       
adaptive_disorders                    boolean,       
dissociative_disorders                boolean,       
psychosomatic_disorders               boolean,       
eating_disorders                      boolean,       
personality_disorders                 boolean,       
conduct_disorders                     boolean,       
suicidal_ideation                     boolean,       
grief                                 boolean,       
Treatment_plan                        varchar(5000), 
lab_tests_ordered                     text,          
visit_reason                          varchar(255),  
visit_date                            datetime,      
index_asc                             int(11),       
index_desc                            int(11)        
);

INSERT INTO temp_consult(patient_id, emr_id,encounter_id, encounter_uuid, encounter_date, date_entered,date_changed, user_entered, encounter_location, encounter_type, visit_id)
SELECT patient_id, patient_identifier(patient_id,'506add39-794f-11e8-9bcd-74e5f916c5ec'), encounter_id,  uuid, encounter_datetime, date_created, date_changed ,person_name_of_user(creator), location_name(location_id), encounter_type_name_from_id(encounter_type), visit_id
FROM encounter  WHERE voided = 0 AND encounter_type IN (@consultEncTypeId)
;

create index tc_ci1 on temp_consult(patient_id);
create index tc_ci2 on temp_consult(encounter_id);
create index tc_ci3 on temp_consult(patient_id, encounter_id);

update temp_consult t
inner join person p on p.person_id = t.patient_id
set t.person_uuid = p.uuid ;

update temp_consult set age_at_encounter = age_at_enc(patient_id, encounter_id);


update temp_consult t
set provider = provider(t.encounter_id);

drop temporary table if exists temp_obs;
create temporary table temp_obs 
select o.obs_id, o.voided ,o.obs_group_id , o.encounter_id, o.person_id, o.concept_id, o.value_coded, o.value_numeric, o.value_text,o.value_datetime, o.value_drug , o.comments, o.date_created ,o.obs_datetime  
from obs o
inner join temp_consult t on t.encounter_id = o.encounter_id
where o.voided = 0;

-- create index to_encounter_id on temp_obs(encounter_id);
-- create index to_concept_id on temp_obs(concept_id);
create index to_ci1 on temp_obs(encounter_id, concept_id);
create index to_ci2 on temp_obs(encounter_id, value_coded);
create index to_ci3 on temp_obs(encounter_id, concept_id,value_coded);
create index to_ci4 on temp_obs(obs_group_id, concept_id,value_coded);

update temp_consult set visit_date = visit_date(encounter_id);

-- program indicators
select p.program_id into @diabetesProgId from program p where uuid = '3f038507-f4bc-4877-ade0-96ce170fc8eb';
select p.program_id into @hypertensionProgId from program p where uuid = '6959057e-9a5c-40ba-a878-292ba4fc35bc';
select p.program_id into @mentalHealthProgId from program p where uuid = '0e69c3ab-1ccb-430b-b0db-b9760319230f';
select p.program_id into @asthmaProgId from program p where uuid = '2639449c-8764-4003-be5f-dba522b4b680';
select p.program_id into @malnutritionProgId from program p where uuid = '61e38de2-44f2-470e-99da-3e97e93d388f';
select p.program_id into @epilepsyProgId from program p where uuid = '69e6a46d-674e-4281-99a0-4004f293ee57';
select p.program_id into @ancProgId from program p where uuid = 'd830a5c1-30a2-4943-93a0-f918772496ec';
select p.program_id into @heartsProgId from program p where uuid = '6cceab45-756f-427b-b2da-0e469d4a87e0';

update temp_consult t
inner join patient_program pp on pp.patient_id  = t.patient_id
	and date(t.encounter_date) >= date(pp.date_enrolled) and (date(t.encounter_date) <= date(pp.date_completed) or pp.date_completed is null) and pp.voided = 0 
	and pp.program_id = @diabetesProgId 
set diabetes = if(pp.patient_program_id is null, 0,1);

update temp_consult t
inner join patient_program pp on pp.patient_id  = t.patient_id
	and date(t.encounter_date) >= date(pp.date_enrolled) and (date(t.encounter_date) <= date(pp.date_completed) or pp.date_completed is null) and pp.voided = 0 
	and pp.program_id = @hypertensionProgId 
set hypertension = if(pp.patient_program_id is null, 0,1);

update temp_consult t
inner join patient_program pp on pp.patient_id  = t.patient_id
	and date(t.encounter_date) >= date(pp.date_enrolled) and (date(t.encounter_date) <= date(pp.date_completed) or pp.date_completed is null) and pp.voided = 0 
	and pp.program_id = @asthmaProgId 
set asthma = if(pp.patient_program_id is null, 0,1);

update temp_consult t
inner join patient_program pp on pp.patient_id  = t.patient_id
	and date(t.encounter_date) >= date(pp.date_enrolled) and (date(t.encounter_date) <= date(pp.date_completed) or pp.date_completed is null) and pp.voided = 0 
	and pp.program_id = @mentalHealthProgId 
set mental_health = if(pp.patient_program_id is null, 0,1);

update temp_consult t
inner join patient_program pp on pp.patient_id  = t.patient_id
	and date(t.encounter_date) >= date(pp.date_enrolled) and (date(t.encounter_date) <= date(pp.date_completed) or pp.date_completed is null) and pp.voided = 0 
	and pp.program_id = @epilepsyProgId 
set epilepsy = if(pp.patient_program_id is null, 0,1);

update temp_consult t
inner join patient_program pp on pp.patient_id  = t.patient_id
	and date(t.encounter_date) >= date(pp.date_enrolled) and (date(t.encounter_date) <= date(pp.date_completed) or pp.date_completed is null) and pp.voided = 0 
	and pp.program_id = @ancProgId 
set prenatal_care = if(pp.patient_program_id is null, 0,1);

update temp_consult t
inner join patient_program pp on pp.patient_id  = t.patient_id
	and date(t.encounter_date) >= date(pp.date_enrolled) and (date(t.encounter_date) <= date(pp.date_completed) or pp.date_completed is null) and pp.voided = 0 
	and pp.program_id = @malnutritionProgId 
set malnutrition = if(pp.patient_program_id is null, 0,1);

-- asthma symptoms
update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id and o.value_coded = concept_from_mapping('PIH','11731') 
set asthma_waking = if(o.concept_id = @symptom_present,1,if(o.concept_id = @symptom_absent,0,null));

-- this cough question is captured by either of these concepts but not both, 
-- depending on whether the patient is <5 yrs or older
update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id and 
	o.concept_id in (concept_from_mapping('PIH','11803'),  concept_from_mapping('PIH','11804'))
set asthma_cough = if(o.value_coded = @yes,1,if(o.value_coded = @no,0,null));

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','11724') 
set asthma_medicate = if(o.value_coded = @yes,1,if(o.value_coded = @no,0,null));

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','11925') 
set asthma_activity = if(o.value_coded = @yes,1,if(o.value_coded = @no,0,null));

-- diabetes symptoms

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','887')
set glucose = o.value_numeric;

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','7460')
set hba1c = o.value_numeric;

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','10542')
set abdominal_circumference = o.value_numeric;

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','849')
set proteinuria_diabetes = o.value_numeric;

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id
	and concept_id = concept_from_mapping('PIH','6689') 
set t.fasting = if(o.value_coded = @yes,1,if(o.value_coded = @no,0,null)); 

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','11732')
set foot_exam = concept_name(o.value_coded,@locale);

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id
	and concept_id = concept_from_mapping('PIH','7412') 
	and value_coded = concept_from_mapping('PIH','1065')
set t.hypoglycemia_symptoms = if(o.obs_id is null, 0,1);

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','1552')
set alcohol = concept_name(o.value_coded,@locale);

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','2545')
set tobacco = concept_name(o.value_coded,@locale);

-- hypertension fields
update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','1006')
set total_cholesterol =o.value_numeric;

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','1007')
set hdl =o.value_numeric;

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','1008')
set ldl =o.value_numeric;

-- hearts fields
update temp_consult t
inner join patient_program pp on pp.patient_id  = t.patient_id
	and date(t.encounter_date) >= date(pp.date_enrolled) and (date(t.encounter_date) <= date(pp.date_completed) or pp.date_completed is null) and pp.voided = 0 
	and pp.program_id = @heartsProgId 
set hearts = if(pp.patient_program_id is null, 0,1);

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','13705') 
set hearts_change_treatment = if(o.value_coded = @yes,1,if(o.value_coded = @no,0,null)); 

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','13703')
set hearts_cardiovascular_risk =o.value_numeric;

-- epilepsy fields
update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','6798')
set epilepsy_attacks_before =o.value_numeric;

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','6797')
set epilepsy_attacks_last_4weeks =o.value_numeric;

-- prenatal care
update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','13732') 
set planned_pregnancy = if(o.value_coded = @yes,1,if(o.value_coded = @no,0,null));

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','13730') 
set unplanned_cause_contraceptive_failure = if(o.value_coded = @yes,1,if(o.value_coded = @no,0,null));

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','11049') 
set unplanned_cause_violence = if(o.value_coded = @yes,1,if(o.value_coded = @no,0,null));

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','13732') 
set planned_pregnancy = if(o.value_coded = @yes,1,if(o.value_coded = @no,0,null));

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','13731') 
set pregnancy_wanted = if(o.value_coded = @yes,1,if(o.value_coded = @no,0,null));

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','968')
set lmp =o.value_datetime;

update temp_consult t 
set delivery_date_estimated = DATE_ADD(t.lmp, INTERVAL 280 DAY);

update temp_consult t 
set gestational_age = DATEDIFF(encounter_date,lmp)/7; 

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','5624')
set pregnancies =o.value_numeric;

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','1053')
set births =o.value_numeric;

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','7011')
set cesarians =o.value_numeric;

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','13733')
set miscarriages =o.value_numeric;

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','13734')
set stillbirths =o.value_numeric;

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','7018')
set ultrasound_report =o.value_text;

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','1040')
set hiv_test_prenatal = concept_name(o.value_coded,@locale);

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','299')
set vdrl_test = concept_name(o.value_coded,@locale);

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','21')
set hemoglobin =o.value_numeric;

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','849')
set proteinuria_prenatal =o.value_numeric;

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','300')
set blood_type = concept_name(o.value_coded,@locale);

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id
	and concept_id = concept_from_mapping('PIH','10156') 
	and value_coded = concept_from_mapping('PIH','781')
set t.vaccine_dtp = if(o.obs_id is null, 0,1);

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','12051')
set glucose_tolerance_curve = concept_name(o.value_coded,@locale);

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','11968')
set delivery_plan =o.value_text;

-- mental health
update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','11586')
set phq9 =o.value_numeric;

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','11733')
set gad7 =o.value_numeric;

-- physical exam
update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','1336')
set physical_exam =o.value_text;

-- infectious disease
update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','13519') 
set tb_suspected = if(o.value_coded = @yes,1,if(o.value_coded = @no,0,null));

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','3046')
set tb_test = concept_name(o.value_coded,@locale);

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','13518') 
set hiv_suspected = if(o.value_coded = @yes,1,if(o.value_coded = @no,0,null));

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','2169')
set hiv_test = concept_name(o.value_coded,@locale);

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','13520') 
set covid_suspected = if(o.value_coded = @yes,1,if(o.value_coded = @no,0,null));

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id 
	and o.concept_id in (concept_from_mapping('PIH','12824'),
		concept_from_mapping('PIH','12829'),
		concept_from_mapping('PIH','12821'))
set covid_test = concept_name(o.value_coded,@locale);
	
	-- analysis section
update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','1364')
set analysis =o.value_text;

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','10534')
set clinical_indication =o.value_text;

update temp_consult t set diagnoses = obs_value_coded_list_from_temp(encounter_id, 'PIH','3064',@locale);

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id AND 
	o.concept_id = concept_from_mapping('PIH','7537') AND 
	o.value_coded = concept_from_mapping('PIH','7534')
set primary_dx_obs_group_id = o.obs_group_id;

update temp_consult t
inner join temp_obs o on o.obs_group_id = primary_dx_obs_group_id and o.concept_id = concept_from_mapping('PIH','3064')
set primary_diagnosis = concept_name(o.value_coded,@locale);

update temp_consult t
set secondary_diagnosis = 
(select GROUP_CONCAT(concept_name(o2.value_coded,@locale))
from temp_obs o2 
	where o2.encounter_id = t.encounter_id AND 
	o2.concept_id = concept_from_mapping('PIH','3064') AND
	o2.obs_group_id <> primary_dx_obs_group_id
);

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','5096')
set next_visit_date =o.value_datetime;

-- obstetric
update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','14068')
set ultrasound_type = concept_name(o.value_coded,@locale);

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','14085')
set ultrasound_measurement_used = concept_name(o.value_coded,@locale);

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','14086')
set ultrasound_gestational_age =o.value_numeric;

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','14084')
set fetal_weight =o.value_numeric;

update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','5596')
set delivery_date_ultrasound =o.value_datetime;

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','14091') 
set diagnosis_change_ultrasound = if(o.value_coded = @yes,1,if(o.value_coded = @no,0,null));

-- medication columns

select drug_id into @ces_levonorgestrel_etinilestradiol from drug  where uuid = 'e24bfc91-043e-4bc7-81df-64af00ee8193';
select drug_id into @ssa_levonorgestrel03mg  from drug  where uuid = '2f97e964-3fbc-4da6-a619-d7ad5c95e391';
select drug_id into @ssa_levonorgestrel_etinilestradiol01 from drug  where uuid = '1f003a43-d738-4c7d-ab87-8239db9e50fe';
select drug_id into @ssa_levonorgestrel_etinilestradiol02 from drug  where uuid = '81a9ed8d-6ae8-408f-a96d-a4a295d20e15';
select drug_id into @desogestrel_etinilestradiol01 from drug  where uuid = '54f1a7c3-a18f-469c-8172-f630cb1d3ba1';
select drug_id into @desogestrel_etinilestradiol02 from drug  where uuid = '172f7d64-c03c-452a-b1c4-8f6da5696cec';

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id AND 
	o.concept_id = concept_from_mapping('PIH','1282') AND 
	value_drug in (@ces_levonorgestrel_etinilestradiol,
					@ssa_levonorgestrel03mg,
					@ssa_levonorgestrel_etinilestradiol01,
					@ssa_levonorgestrel_etinilestradiol02,
					@desogestrel_etinilestradiol01,
					@desogestrel_etinilestradiol02)
set birth_control_pills = if(o.obs_id is null,0,1);					

select drug_id into @ces_algestona_estradiol  from drug  where uuid = '5b429d13-1296-40e6-a309-09387935eb0d';

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id AND 
	o.concept_id = concept_from_mapping('PIH','1282') AND 
	value_drug = @ces_algestona_estradiol
set 1month_injection = if(o.obs_id is null,0,1);	

select drug_id into @ces_noretisterona  from drug  where uuid = '64c2da40-ce90-4574-aab4-dfd1d189e797';

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id AND 
	o.concept_id = concept_from_mapping('PIH','1282') AND 
	value_drug = @ces_noretisterona
set 2month_injection = if(o.obs_id is null,0,1);	

select drug_id into @ces_medroxyprogesterona   from drug  where uuid = '82e2b78d-4418-4a13-be61-f3152276cd74';
select drug_id into @ssa_medroxyprogesterona   from drug  where uuid = '9c80b0cb-72ea-40be-a896-b20d579c509c';

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id AND 
	o.concept_id = concept_from_mapping('PIH','1282') AND 
	value_drug in (@ces_medroxyprogesterona,
					@ssa_medroxyprogesterona)
set 3month_injection = if(o.obs_id is null,0,1);	

select drug_id into @ces_implante_anticonceptivo   from drug  where uuid = 'b2311114-eed2-4c66-aea7-a3658e8c1dd0';
select drug_id into @ssa_etonogestrel   from drug  where uuid = '77db3a71-f333-4122-82b0-46af04d379b9';

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id AND 
	o.concept_id = concept_from_mapping('PIH','1282') AND 
	value_drug in (@ces_implante_anticonceptivo,
					@ssa_etonogestrel)
set implant = if(o.obs_id is null,0,1);	

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id AND 
	o.concept_id = concept_from_mapping('PIH','12265')
set prueba_sifilis = CASE WHEN value_coded=concept_from_mapping('PIH',703) THEN 'positivo' 
						  WHEN value_coded=concept_from_mapping('PIH',664) THEN 'negativo'
						 ELSE NULL END;	
update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id AND 
	o.concept_id = concept_from_mapping('PIH','7451')
set prueba_hepb = CASE WHEN value_coded=concept_from_mapping('PIH',703) THEN 'positivo' 
						  WHEN value_coded=concept_from_mapping('PIH',664) THEN 'negativo'
						 ELSE NULL END;	
update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id AND 
	o.concept_id = concept_from_mapping('PIH','12335')
set prueba_clamidia = CASE WHEN value_coded=concept_from_mapping('PIH',703) THEN 'positivo' 
						  WHEN value_coded=concept_from_mapping('PIH',664) THEN 'negativo'
						 ELSE NULL END;							
update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id AND 
	o.concept_id = concept_from_mapping('PIH','12334')
set prueba_gonorrea = CASE WHEN value_coded=concept_from_mapping('PIH',703) THEN 'positivo' 
						  WHEN value_coded=concept_from_mapping('PIH',664) THEN 'negativo'
						 ELSE NULL END;	
update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id AND 
	o.concept_id = concept_from_mapping('PIH','7452')
set prueba_hepc = CASE WHEN value_coded=concept_from_mapping('PIH',703) THEN 'positivo' 
						  WHEN value_coded=concept_from_mapping('PIH',664) THEN 'negativo'
						 ELSE NULL END;	
update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id AND 
	o.concept_id = concept_from_mapping('PIH','7018')
set comentario_ultrasonido = value_text;								
	
select drug_id into @ssa_norelgestromina from drug  where uuid = '953f26a9-56a3-472e-9e16-68785aec6076';

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id AND 
	o.concept_id = concept_from_mapping('PIH','1282') AND 
	value_drug = @ssa_norelgestromina
set birth_control_patch = if(o.obs_id is null,0,1);	

select drug_id into @ssa_levonorgestrel_75  from drug  where uuid = 'c72e7ed6-c179-481e-9873-812e20aee1fa';
select drug_id into @ces_levonorgestrel from drug  where uuid = '9ebb0696-073c-47d6-835d-fc3b2a19b02a';

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id AND 
	o.concept_id = concept_from_mapping('PIH','1282') AND 
	value_drug in (@ssa_levonorgestrel_75,
					@ces_levonorgestrel)
set emergency_birth_control = if(o.obs_id is null,0,1);	

select drug_id into @ces_diu_de_cobre from drug where uuid = '86dd0423-28a5-4752-996f-f3921b59cc18';

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id AND 
	o.concept_id = concept_from_mapping('PIH','1282') AND 
	value_drug = @ces_diu_de_cobre
set iud_copper = if(o.obs_id is null,0,1);	

select drug_id into @ces_diu_de_hormona from drug  where uuid = 'f80bf96f-6291-4227-949a-f8b2cc3c773a';

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id AND 
	o.concept_id = concept_from_mapping('PIH','1282') AND 
	value_drug = @ces_diu_de_hormona
set iud_mirena = if(o.obs_id is null,0,1);	

select drug_id into @ssa_condon_masculino from drug  where uuid = 'cf154c4a-632a-4a6b-abac-55216d046aed';

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id AND 
	o.concept_id = concept_from_mapping('PIH','1282') AND 
	value_drug = @ssa_condon_masculino
set condoms = if(o.obs_id is null,0,1);

select drug_id into @ces_mifepristona from drug  where uuid = '90369966-65a8-433d-8daf-791faf0593db';

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id AND 
	o.concept_id = concept_from_mapping('PIH','1282') AND 
	value_drug = @ces_mifepristona
set mifepristone = if(o.obs_id is null,0,1);

select drug_id into @ssa_misoprostol from drug  where uuid = '0b4c8973-7c6a-4096-b315-fa9878df17c6';
select drug_id into @ces_misoprostol from drug  where uuid = '2199a10e-5f56-44a4-87cb-38159f268dda';

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id AND 
	o.concept_id = concept_from_mapping('PIH','1282') AND 
	value_drug in (@ssa_misoprostol,
					@ces_misoprostol)
set misoprostol = if(o.obs_id is null,0,1);	

select drug_id into @ssa_hierro_dextran from drug  where uuid = '41cc9856-98a8-40f5-be89-0d129f5040b1';

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id AND 
	o.concept_id = concept_from_mapping('PIH','1282') AND 
	value_drug = @ssa_hierro_dextran
set iron_dextran = if(o.obs_id is null,0,1);

-- ############# PHQ-9 & GAD-7  Questions #####################################

select concept_from_mapping('PIH','1090') into @never;
select concept_from_mapping('PIH','1603') into @somedays;
select concept_from_mapping('PIH','13660') into @morethanhalf;
select concept_from_mapping('PIH','1100') into @daily;

update temp_obs set value_numeric = 0 where value_coded = @never;
update temp_obs set value_numeric = 1 where value_coded = @somedays;
update temp_obs set value_numeric = 2 where value_coded = @morethanhalf;
update temp_obs set value_numeric = 3 where value_coded = @daily;

update temp_consult set PHQ9_q1 = obs_value_numeric_from_temp(encounter_id, 'PIH', '13661');
update temp_consult set PHQ9_q2 = obs_value_numeric_from_temp(encounter_id, 'PIH', '13662');
update temp_consult set PHQ9_q3 = obs_value_numeric_from_temp(encounter_id, 'PIH', '13663');
update temp_consult set PHQ9_q4 = obs_value_numeric_from_temp(encounter_id, 'PIH', '13664');
update temp_consult set PHQ9_q5 = obs_value_numeric_from_temp(encounter_id, 'PIH', '13665');
update temp_consult set PHQ9_q6 = obs_value_numeric_from_temp(encounter_id, 'PIH', '13666');
update temp_consult set PHQ9_q7 = obs_value_numeric_from_temp(encounter_id, 'PIH', '13667');
update temp_consult set PHQ9_q8 = obs_value_numeric_from_temp(encounter_id, 'PIH', '13668');
update temp_consult set PHQ9_q9 = obs_value_numeric_from_temp(encounter_id, 'PIH', '13669');

update temp_consult set GAD7_q1 = obs_value_numeric_from_temp(encounter_id, 'PIH', '13671');
update temp_consult set GAD7_q2 = obs_value_numeric_from_temp(encounter_id, 'PIH', '13672');
update temp_consult set GAD7_q3 = obs_value_numeric_from_temp(encounter_id, 'PIH', '13673');
update temp_consult set GAD7_q4 = obs_value_numeric_from_temp(encounter_id, 'PIH', '13674');
update temp_consult set GAD7_q5 = obs_value_numeric_from_temp(encounter_id, 'PIH', '13675');
update temp_consult set GAD7_q6 = obs_value_numeric_from_temp(encounter_id, 'PIH', '13676');
update temp_consult set GAD7_q7 = obs_value_numeric_from_temp(encounter_id, 'PIH', '13677');

update temp_consult set PHQ9_score = obs_value_numeric_from_temp(encounter_id, 'PIH', '11586');
update temp_consult set GAD7_score = obs_value_numeric_from_temp(encounter_id, 'PIH', '11733');

-- ------------- Indicators - psychosis -------------------------------------
set @dx = concept_from_mapping('PIH','3064');
set @schizophrenia = concept_from_mapping('PIH','467');
set @acutePsychosis = concept_from_mapping('PIH','9519');
set @psychosis = concept_from_mapping('PIH','219');
set @maniaNoPsychosis = concept_from_mapping('PIH','9520');
set @maniaWithPsychosis = concept_from_mapping('PIH','9518');

update temp_consult t
inner join temp_obs o on o.person_id = t.patient_id
	and o.concept_id = @dx
	and o.value_coded IN 
	(@schizophrenia,
	@acutePsychosis,
	@psychosis,
	@maniaNoPsychosis,
	@maniaWithPsychosis)
set t.psychosis =1;	

-- ------------- Indicators - mood disorder -------------------------------------
set @bipolar = concept_from_mapping('PIH','7947');
set @depression = concept_from_mapping('PIH','207');

update temp_consult t
inner join temp_obs o on o.person_id = t.patient_id
	and o.concept_id = @dx
	and o.value_coded IN 
	(@bipolar,
	@depression)
set t.mood_disorder =1;	

-- ------------- Indicators - anxiety -------------------------------------
set @panic = concept_from_mapping('PIH','9330');
set @anxietyDisorder = concept_from_mapping('PIH','9517');
set @anxiety = concept_from_mapping('PIH','2719');
set @ocd = concept_from_mapping('PIH','7513');
set @stress = concept_from_mapping('PIH','7950');
set @ptsd = concept_from_mapping('PIH','7197');

update temp_consult t
inner join temp_obs o on o.person_id = t.patient_id
	and o.concept_id = @dx
	and o.value_coded IN 
	(@panic,
	@anxietyDisorder,
	@anxiety,
	@ocd,
	@stress,
	@ptsd)
set t.anxiety =1;	

-- ------------- Indicators - adaptive disorders -------------------------------------
set @adaptive_disorders = concept_from_mapping('PIH','14367');

update temp_consult t
inner join temp_obs o on o.person_id = t.patient_id
	and o.concept_id = @dx
	and o.value_coded = @adaptive_disorders
set t.adaptive_disorders =1;	

-- ------------- Indicators - dissociative disorders -------------------------------------
set @dissociative_disorders = concept_from_mapping('PIH','7945');

update temp_consult t
inner join temp_obs o on o.person_id = t.patient_id
	and o.concept_id = @dx
	and o.value_coded = @dissociative_disorders
set t.dissociative_disorders =1;	

-- ------------- Indicators - psychosomatic disorders -------------------------------------
set @psychosomatic_disorders = concept_from_mapping('PIH','7198');

update temp_consult t
inner join temp_obs o on o.person_id = t.patient_id
	and o.concept_id = @dx
	and o.value_coded = @psychosomatic_disorders
set t.psychosomatic_disorders =1;

-- ------------- Indicators - eating disorders -------------------------------------
set @eating_disorders = concept_from_mapping('PIH','7944');

update temp_consult t
inner join temp_obs o on o.person_id = t.patient_id
	and o.concept_id = @dx
	and o.value_coded = @eating_disorders
set t.eating_disorders =1;

-- ------------- Indicators - personality disorders -------------------------------------
set @personality_disorders = concept_from_mapping('PIH','7943');

update temp_consult t
inner join temp_obs o on o.person_id = t.patient_id
	and o.concept_id = @dx
	and o.value_coded = @personality_disorders
set t.personality_disorders =1;

-- ------------- Indicators - conduct disorders -------------------------------------
set @conductDisorder = concept_from_mapping('PIH','7949');
set @attentionDeficit = concept_from_mapping('PIH','11862');

update temp_consult t
inner join temp_obs o on o.person_id = t.patient_id
	and o.concept_id = @dx
	and o.value_coded IN 
	(@conductDisorder,
	@attentionDeficit)
set t.conduct_disorders =1;	

-- ------------- Indicators - suicidal -------------------------------------
set @suicidalThoughts = concept_from_mapping('PIH','10633');
set @attemptedSuicide = concept_from_mapping('PIH','7514');

update temp_consult t
inner join temp_obs o on o.person_id = t.patient_id
	and o.concept_id = @dx
	and o.value_coded IN 
	(@suicidalThoughts,
	@attemptedSuicide)
set t.suicidal_ideation =1;

-- ------------- Indicators - grief -------------------------------------
set @grief = concept_from_mapping('PIH','6896');

update temp_consult t
inner join temp_obs o on o.person_id = t.patient_id
	and o.concept_id = @dx
	and o.value_coded = @grief
set t.grief =1;

-- mh program outcome
set @program = concept_from_mapping('PIH','13177');
set @mh = concept_from_mapping('PIH','11574');
update temp_consult t
inner join temp_obs o on o.encounter_id = t.encounter_id
	and o.concept_id = @program 
	and o.value_coded = @mh
set mh_program_outcome_group_obs_id = obs_group_id;

set @program_outcome = concept_from_mapping('PIH','14310');

update temp_consult t
inner join temp_obs o on o.obs_group_id = mh_program_outcome_group_obs_id
	and o.concept_id = @program_outcome 
set	mh_program_outcome = concept_name(o.value_coded, @locale);

-- lab tests ordered 
update temp_consult set lab_tests_ordered = obs_value_text_from_temp(encounter_id, 'PIH', '11762');

-- visit reason
update temp_consult set visit_Reason = obs_value_coded_list_from_temp(encounter_id, 'PIH', '6189', 'en');

-- The ascending/descending indexes are calculated ordering on the dispense date
-- new temp tables are used to build them and then joined into the main temp table.

select 
	CONCAT(@partition,'-',emr_id) "emr_id",
	person_uuid,
	CONCAT(@partition,'-',visit_id) "visit_id",
	CONCAT(@partition,'-',encounter_id) "encounter_id",
	encounter_uuid,
	encounter_type,
	encounter_date,
	encounter_location,
	date_entered,
	user_entered,
	date_changed,
	visit_date,
	provider,
	visit_reason,
	age_at_encounter,
	diabetes,
	asthma,
	malnutrition,
	epilepsy,
	hypertension,
	prenatal_care,
	mental_health,
	asthma_cough,
	asthma_waking,
	asthma_medicate,
	asthma_activity,
	glucose,
	fasting,
	hba1c,
	proteinuria_diabetes,
	abdominal_circumference,
	foot_exam,
	hypoglycemia_symptoms,
	alcohol,
	tobacco,
	total_cholesterol,
	hdl,
	ldl,
	hearts,
	hearts_change_treatment,
	hearts_cardiovascular_risk,
	epilepsy_attacks_before,
	epilepsy_attacks_last_4weeks,
	planned_pregnancy,
	unplanned_cause_contraceptive_failure,
	unplanned_cause_violence,
	pregnancy_wanted,
	lmp,
	gestational_age,
	delivery_date_estimated,
	pregnancies,
	births,
	cesarians,
	miscarriages,
	stillbirths,
	ultrasound_report,
	hiv_test_prenatal,
	vdrl_test,
	hemoglobin,
	proteinuria_prenatal,
	blood_type,
	vaccine_dtp,
	glucose_tolerance_curve,
	delivery_plan,
	phq9,
	gad7,
	physical_exam,
	tb_suspected,
	tb_test,
	hiv_suspected,
	hiv_test,
	covid_suspected,
	covid_test,
	analysis,
	diagnoses,
	primary_diagnosis,
	secondary_diagnosis,
	clinical_indication,					
	ultrasound_type,
	ultrasound_measurement_used,
	ultrasound_gestational_age,
	delivery_date_ultrasound,
	fetal_weight,
	diagnosis_change_ultrasound,
	birth_control_pills,
	1month_injection,
	2month_injection,
	3month_injection,
	implant,
	birth_control_patch,
	emergency_birth_control,
	iud_copper,
	iud_mirena,
	condoms,
	mifepristone,
	misoprostol,
	iron_dextran,
	next_visit_date,
	prueba_sifilis,
	prueba_hepb,
	prueba_clamidia,
	prueba_gonorrea,
	prueba_hepc,
	comentario_ultrasonido,
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
	mh_program_outcome,
	lab_tests_ordered ,
	index_asc,
	index_desc
from temp_consult
;
