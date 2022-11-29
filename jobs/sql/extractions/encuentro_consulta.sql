SET sql_safe_updates = 0;

set @locale = 'es';
set @partition = '${partitionNum}';
SET @consultEncTypeId = (select encounter_type_id from encounter_type et where uuid = 'aa61d509-6e76-4036-a65d-7813c0c3b752');


DROP TEMPORARY TABLE IF EXISTS temp_consult;
CREATE TEMPORARY TABLE temp_consult
(
patient_id                            int(11),
emr_id                                varchar(50),
encounter_id                          int(11),
encounter_type                        varchar(255),
encounter_date                        datetime,
encounter_location                    varchar(255),
date_entered                          datetime,
user_entered                          varchar(255),
provider                              varchar(255),
visit_id                              int(11),
consult_reason                        varchar(255),
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
lmp                                   datetime,
gestational_age                       double,
delivery_date_estimated               datetime,
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
primary_dx_obs_group_id               int(11),
primary_diagnosis                     varchar(255),
secondary_diagnosis                   varchar(1200),
clinical_indication                   text, 
ultrasound_type                       varchar(255),
ultrasound_measurement_used           varchar(255),
ultrasound_gestational_age            double,
delivery_date_ultrasound              datetime,
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
next_visit_date                       datetime,
index_asc                             int(11),
index_desc                            int(11)
);

INSERT INTO temp_consult(patient_id, emr_id,encounter_id, encounter_date, date_entered, user_entered, encounter_location, encounter_type, visit_id)
SELECT patient_id, patient_identifier(patient_id,'506add39-794f-11e8-9bcd-74e5f916c5ec'), encounter_id,  encounter_datetime, date_created, person_name_of_user(creator), location_name(location_id), encounter_type_name_from_id(encounter_type), visit_id
FROM encounter  WHERE voided = 0 AND encounter_type IN (@consultEncTypeId)
;

update temp_consult t
set provider = provider(t.encounter_id);

drop temporary table if exists temp_obs;
create temporary table temp_obs 
select o.obs_id, o.voided ,o.obs_group_id , o.encounter_id, o.person_id, o.concept_id, o.value_coded, o.value_numeric, o.value_text,o.value_datetime, o.value_drug , o.comments, o.date_created ,o.obs_datetime  
from obs o
inner join temp_consult t on t.encounter_id = o.encounter_id
where o.voided = 0;

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id and o.concept_id = concept_from_mapping('PIH','6189') 
set t.consult_reason = concept_name(o.value_coded, @locale);

-- program indicators
select p.program_id into @diabetesProgId from program p where uuid = '3f038507-f4bc-4877-ade0-96ce170fc8eb';
select p.program_id into @hypertensionProgId from program p where uuid = '6959057e-9a5c-40ba-a878-292ba4fc35bc';
select p.program_id into @mentalHealthProgId from program p where uuid = '0e69c3ab-1ccb-430b-b0db-b9760319230f';
select p.program_id into @asthmaProgId from program p where uuid = '2639449c-8764-4003-be5f-dba522b4b680';
select p.program_id into @malnutritionProgId from program p where uuid = '61e38de2-44f2-470e-99da-3e97e93d388f';
select p.program_id into @epilepsyProgId from program p where uuid = '69e6a46d-674e-4281-99a0-4004f293ee57';
select p.program_id into @ancProgId from program p where uuid = 'd830a5c1-30a2-4943-93a0-f918772496ec';

update temp_consult t
inner join patient_program pp on pp.patient_id  = t.patient_id
	and date(t.encounter_date) >= pp.date_enrolled and (date(t.encounter_date) <= pp.date_completed or pp.date_completed is null) and pp.voided = 0 
	and pp.program_id = @diabetesProgId 
set diabetes = if(pp.patient_program_id is null, 0,1);

update temp_consult t
inner join patient_program pp on pp.patient_id  = t.patient_id
	and date(t.encounter_date) >= pp.date_enrolled and (date(t.encounter_date) <= pp.date_completed or pp.date_completed is null) and pp.voided = 0 
	and pp.program_id = @hypertensionProgId 
set hypertension = if(pp.patient_program_id is null, 0,1);

update temp_consult t
inner join patient_program pp on pp.patient_id  = t.patient_id
	and date(t.encounter_date) >= pp.date_enrolled and (date(t.encounter_date) <= pp.date_completed or pp.date_completed is null) and pp.voided = 0 
	and pp.program_id = @asthmaProgId 
set asthma = if(pp.patient_program_id is null, 0,1);

update temp_consult t
inner join patient_program pp on pp.patient_id  = t.patient_id
	and date(t.encounter_date) >= pp.date_enrolled and (date(t.encounter_date) <= pp.date_completed or pp.date_completed is null) and pp.voided = 0 
	and pp.program_id = @diabetesProgId 
set mental_health = if(pp.patient_program_id is null, 0,1);

update temp_consult t
inner join patient_program pp on pp.patient_id  = t.patient_id
	and date(t.encounter_date) >= pp.date_enrolled and (date(t.encounter_date) <= pp.date_completed or pp.date_completed is null) and pp.voided = 0 
	and pp.program_id = @epilepsyProgId 
set epilepsy = if(pp.patient_program_id is null, 0,1);

update temp_consult t
inner join patient_program pp on pp.patient_id  = t.patient_id
	and date(t.encounter_date) >= pp.date_enrolled and (date(t.encounter_date) <= pp.date_completed or pp.date_completed is null) and pp.voided = 0 
	and pp.program_id = @ancProgId 
set prenatal_care = if(pp.patient_program_id is null, 0,1);

-- asthma symptoms
update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id
	and concept_id = concept_from_mapping('PIH','1293') 
	and value_coded = concept_from_mapping('PIH','11731')
set t.asthma_cough = if(o.obs_id is null, 0,1);

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id
	and concept_id = concept_from_mapping('PIH','11803') 
	and value_coded = concept_from_mapping('PIH','1065')
set t.asthma_waking = if(o.obs_id is null, 0,1);

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id
	and concept_id = concept_from_mapping('PIH','11724') 
	and value_coded = concept_from_mapping('PIH','1065')
set t.asthma_medicate = if(o.obs_id is null, 0,1);

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id
	and concept_id = concept_from_mapping('PIH','11925') 
	and value_coded = concept_from_mapping('PIH','1065')
set t.asthma_activity = if(o.obs_id is null, 0,1);

-- diabetes symptoms
update temp_consult t
set glucose = obs_value_numeric_from_temp(t.encounter_id, 'PIH','887');

update temp_consult t
set hba1c = obs_value_numeric_from_temp(t.encounter_id, 'PIH','7460');

update temp_consult t
set abdominal_circumference = obs_value_numeric_from_temp(t.encounter_id, 'PIH','10542');

update temp_consult t
set proteinuria_diabetes = obs_value_numeric_from_temp(t.encounter_id, 'PIH','849');

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id
	and concept_id = concept_from_mapping('PIH','6689') 
	and value_coded = concept_from_mapping('PIH','1065')
set t.fasting = if(o.obs_id is null, 0,1);

update temp_consult t 
set foot_exam = obs_value_coded_list_from_temp(t.encounter_id, 'PIH','11732',@locale);

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id
	and concept_id = concept_from_mapping('PIH','7412') 
	and value_coded = concept_from_mapping('PIH','1065')
set t.hypoglycemia_symptoms = if(o.obs_id is null, 0,1);

update temp_consult t 
set alcohol = obs_value_coded_list_from_temp(t.encounter_id, 'PIH','1552',@locale);

update temp_consult t 
set tobacco = obs_value_coded_list_from_temp(t.encounter_id, 'PIH','2545',@locale);

-- hypertension fields
update temp_consult t
set total_cholesterol = obs_value_numeric_from_temp(t.encounter_id, 'PIH','1006');

update temp_consult t
set hdl = obs_value_numeric_from_temp(t.encounter_id, 'PIH','1007');

update temp_consult t
set ldl = obs_value_numeric_from_temp(t.encounter_id, 'PIH','1008');

-- hearts fields
update temp_consult t 
set hearts_change_treatment = value_coded_as_boolean(obs_id_from_temp(t.encounter_id, 'PIH','13705',0));

update temp_consult t
set hearts_cardiovascular_risk = obs_value_numeric_from_temp(t.encounter_id, 'PIH','13703');

-- epilepsy fields
update temp_consult t
set epilepsy_attacks_before = obs_value_numeric_from_temp(t.encounter_id, 'PIH','6798');

update temp_consult t
set epilepsy_attacks_last_4weeks = obs_value_numeric_from_temp(t.encounter_id, 'PIH','6797');

-- prenatal care
update temp_consult t 
set planned_pregnancy = value_coded_as_boolean(obs_id_from_temp(t.encounter_id, 'PIH','13732',0));

update temp_consult t 
set unplanned_cause_contraceptive_failure = value_coded_as_boolean(obs_id_from_temp(t.encounter_id, 'PIH','13730',0));

update temp_consult t 
set unplanned_cause_violence = value_coded_as_boolean(obs_id_from_temp(t.encounter_id, 'PIH','11049',0));

update temp_consult t 
set planned_pregnancy = value_coded_as_boolean(obs_id_from_temp(t.encounter_id, 'PIH','13732',0));

update temp_consult t 
set pregnancy_wanted = value_coded_as_boolean(obs_id_from_temp(t.encounter_id, 'PIH','13731',0));

update temp_consult t 
set lmp = obs_value_datetime_from_temp(t.encounter_id, 'PIH','968');

update temp_consult t 
set delivery_date_estimated = DATE_ADD(t.lmp, INTERVAL 280 DAY);

update temp_consult t 
set gestational_age = DATEDIFF(encounter_date,lmp)/7; 

update temp_consult t
set pregnancies = obs_value_numeric_from_temp(t.encounter_id, 'PIH','5624');

update temp_consult t
set births = obs_value_numeric_from_temp(t.encounter_id, 'PIH','1053');

update temp_consult t
set cesarians = obs_value_numeric_from_temp(t.encounter_id, 'PIH','7011');

update temp_consult t
set miscarriages = obs_value_numeric_from_temp(t.encounter_id, 'PIH','13733');

update temp_consult t
set stillbirths = obs_value_numeric_from_temp(t.encounter_id, 'PIH','13734');

update temp_consult t
set stillbirths = obs_value_numeric_from_temp(t.encounter_id, 'PIH','13734');

update temp_consult t
set ultrasound_report = obs_value_text_from_temp(t.encounter_id, 'PIH','7018');

update temp_consult t 
set hiv_test_prenatal = obs_value_coded_list_from_temp(t.encounter_id, 'PIH','1040',@locale);

update temp_consult t 
set vdrl_test = obs_value_coded_list_from_temp(t.encounter_id, 'PIH','299',@locale);

update temp_consult t
set hemoglobin = obs_value_numeric_from_temp(t.encounter_id, 'PIH','21');

update temp_consult t
set proteinuria_prenatal = obs_value_numeric_from_temp(t.encounter_id, 'PIH','849');

update temp_consult t 
set blood_type = obs_value_coded_list_from_temp(t.encounter_id, 'PIH','300',@locale);

update temp_consult t 
set vaccine_dtp = value_coded_as_boolean(obs_id_from_temp(t.encounter_id, 'PIH','1056',0));

update temp_consult t 
set glucose_tolerance_curve = obs_value_coded_list_from_temp(t.encounter_id, 'PIH','12051',@locale);

update temp_consult t
set delivery_plan = obs_value_text_from_temp(t.encounter_id, 'PIH','11968');

-- mental health
update temp_consult t
set phq9 = obs_value_numeric_from_temp(t.encounter_id, 'PIH','11586');

update temp_consult t
set gad7 = obs_value_numeric_from_temp(t.encounter_id, 'PIH','11733');

-- physical exam
update temp_consult t
set physical_exam = obs_value_text_from_temp(t.encounter_id, 'PIH','1336');

-- infectious disease
update temp_consult t 
set tb_suspected = value_coded_as_boolean(obs_id_from_temp(t.encounter_id, 'PIH','13519',0));

update temp_consult t 
set tb_test = obs_value_coded_list_from_temp(t.encounter_id, 'PIH','3046',@locale);

update temp_consult t 
set hiv_suspected = value_coded_as_boolean(obs_id_from_temp(t.encounter_id, 'PIH','13518',0));

update temp_consult t 
set hiv_test = obs_value_coded_list_from_temp(t.encounter_id, 'PIH','2169',@locale);

update temp_consult t 
set covid_suspected = value_coded_as_boolean(obs_id_from_temp(t.encounter_id, 'PIH','13520',0));

update temp_consult t 
set covid_test = COALESCE(
	obs_value_coded_list_from_temp(t.encounter_id, 'PIH','12824',@locale),  -- pcr test
	obs_value_coded_list_from_temp(t.encounter_id, 'PIH','12829',@locale),	-- antigen test
	obs_value_coded_list_from_temp(t.encounter_id, 'PIH','12821',@locale)); -- antibody test

-- analysis section
update temp_consult t
set analysis = obs_value_text_from_temp(t.encounter_id, 'PIH','1364');

update temp_consult t
set primary_diagnosis = value_coded_name(obs_id(t.encounter_id,'PIH',3064,0),@locale);

update temp_consult t
set secondary_diagnosis = value_coded_name(obs_id(t.encounter_id,'PIH',3064,1),@locale);

update temp_consult t
set clinical_indication  = obs_value_text_from_temp(t.encounter_id, 'PIH','10534');

update temp_consult t 
inner join temp_obs o on o.encounter_id = t.encounter_id AND 
	o.concept_id = concept_from_mapping('PIH','7537') AND 
	o.value_coded = concept_from_mapping('PIH','7534')
set primary_dx_obs_group_id = o.obs_group_id;

update temp_consult t
set primary_diagnosis = obs_from_group_id_value_coded_list_from_temp(primary_dx_obs_group_id,'PIH','3064',@locale); 

update temp_consult t
set secondary_diagnosis = 
(select GROUP_CONCAT(concept_name(o2.value_coded,@locale))
from temp_obs o2 
	where o2.encounter_id = t.encounter_id AND 
	o2.concept_id = concept_from_mapping('PIH','3064') AND
	o2.obs_group_id <> primary_dx_obs_group_id
);

update temp_consult t
set next_visit_date = obs_value_datetime_from_temp(t.encounter_id, 'PIH','5096');

-- obstetric
update temp_consult t 
set ultrasound_type = obs_value_coded_list_from_temp(t.encounter_id, 'PIH','14068',@locale);

update temp_consult t 
set ultrasound_measurement_used = obs_value_coded_list_from_temp(t.encounter_id, 'PIH','14085',@locale);

update temp_consult t
set ultrasound_gestational_age = obs_value_numeric_from_temp(t.encounter_id, 'PIH','14086');

update temp_consult t
set fetal_weight = obs_value_numeric_from_temp(t.encounter_id, 'PIH','14084');

update temp_consult t
set delivery_date_ultrasound = obs_value_datetime_from_temp(t.encounter_id, 'PIH','5596');

update temp_consult t 
set diagnosis_change_ultrasound = value_coded_as_boolean(obs_id_from_temp(t.encounter_id, 'PIH','14091',0));

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

-- The ascending/descending indexes are calculated ordering on the dispense date
-- new temp tables are used to build them and then joined into the main temp table.
### index ascending
drop temporary table if exists temp_consult_index_asc;
CREATE TEMPORARY TABLE temp_consult_index_asc
(
    SELECT
            patient_id,
            encounter_date,
            encounter_id,
            index_asc
FROM (SELECT
            @r:= IF(@u = patient_id, @r + 1,1) index_asc,
            encounter_date,
            encounter_id,
            patient_id,
            @u:= patient_id
      FROM temp_consult,
                    (SELECT @r:= 1) AS r,
                    (SELECT @u:= 0) AS u
            ORDER BY patient_id, encounter_date ASC, encounter_id ASC
        ) index_ascending );

CREATE INDEX tvia_e ON temp_consult_index_asc(encounter_id);

update temp_consult t
inner join temp_consult_index_asc tvia on tvia.encounter_id = t.encounter_id
set t.index_asc = tvia.index_asc;

drop temporary table if exists temp_consult_index_desc;
CREATE TEMPORARY TABLE temp_consult_index_desc
(
    SELECT
            patient_id,
            encounter_date,
            encounter_id,
            index_desc
FROM (SELECT
            @r:= IF(@u = patient_id, @r + 1,1) index_desc,
            encounter_date,
            encounter_id,
            patient_id,
            @u:= patient_id
      FROM temp_consult,
                    (SELECT @r:= 1) AS r,
                    (SELECT @u:= 0) AS u
            ORDER BY patient_id, encounter_date DESC, encounter_id DESC
        ) index_descending );

CREATE INDEX tvia_e ON temp_consult_index_desc(encounter_id);

update temp_consult t
inner join temp_consult_index_desc tvid on tvid.encounter_id = t.encounter_id
set t.index_desc = tvid.index_desc;

select 
patient_id,
emr_id,
CONCAT(@partition,'-',encounter_id) "encounter_id",
encounter_type,
encounter_date,
encounter_location,
date_entered,
user_entered,
provider,
visit_id,
consult_reason,
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
index_asc,
index_desc
from temp_consult
;
