
SET @partition = '${partitionNum}';
select program_id into @hypertension from program p where uuid='6959057e-9a5c-40ba-a878-292ba4fc35bc';
select patient_identifier_type_id into @identifier_type from patient_identifier_type pit where uuid ='506add39-794f-11e8-9bcd-74e5f916c5ec';
select program_id into @hrts_program_id from program p where uuid = '6cceab45-756f-427b-b2da-0e469d4a87e0';

drop temporary table if exists programas;
create temporary table programas(
patient_id int, 
person_uuid char(38),
patient_program_uuid char(38),
emr_id varchar(50),
emr_instance varchar(50),
program varchar(50),
program_id int,
date_created datetime,
hearts bit,
hearts_date date,
date_enrolled datetime,
date_completed datetime,
status varchar(50),
last_updated datetime,
index_asc int,
index_desc int
);

-- All Programs 
insert into programas(patient_id,patient_program_uuid, emr_instance,program,program_id,date_created,date_enrolled,date_completed,last_updated, status)
select  pp.patient_id,
		pp.uuid,
		location_name(pp.location_id) emr_instance,
		p.name program,
		pp.program_id,
		pp.date_created,
		pp.date_enrolled,
		pp.date_completed,
		if(pp.date_changed > pp.date_created, pp.date_changed, pp.date_created),
		cn.name status
		from patient_program pp
left outer join program p on pp.program_id =p.program_id 
left outer join concept_name cn on pp.outcome_concept_id = cn.concept_id and cn.voided=0 and cn.locale='en' and cn.locale_preferred=1
where pp.voided=0;

update programas t 
inner join person p on p.person_id = t.patient_id
set t.person_uuid = p.uuid;

update programas t 
set emr_id = (
select distinct identifier
from patient_identifier 
where identifier_type = @identifier_type
and voided = 0
and patient_id = t.patient_id
and preferred=1);


update programas p
set hearts = (
select   max(case when o.concept_id=concept_from_mapping('PIH','13705') or o.concept_id=concept_from_mapping('PIH','13703') then true else false end)
from obs o 
left outer join concept_name cn on o.concept_id =cn.concept_id 
where person_id=p.patient_id
and cast(o.obs_datetime as date) between cast(p.date_enrolled as date) and COALESCE(p.date_completed, CURRENT_DATE()) 
and cn.locale='en'
and cn.voided=0
and o.voided=0)
where p.program_id=@hypertension;

update programas p
set hearts_date = (
select  min(cast(o.obs_datetime as date))
from obs o 
left outer join concept_name cn on o.concept_id =cn.concept_id 
where person_id=p.patient_id
and cast(o.obs_datetime as date) between cast(p.date_enrolled as date)  and COALESCE(p.date_completed, CURRENT_DATE()) 
and (o.concept_id=concept_from_mapping('PIH','13705') or o.concept_id=concept_from_mapping('PIH','13703'))
and cn.locale='en'
and cn.voided=0
and o.voided=0)
where p.program_id=@hypertension;
    
select 
CONCAT(@partition,'-',emr_id) "emr_id",
person_uuid,
patient_program_uuid,
emr_instance,
program,
hearts,
hearts_date,
cast(date_enrolled as date) date_enrolled,
cast(date_completed as date)  as date_unenroll,
status,
last_updated,
index_asc,
index_desc,
program_id,
date_created
from programas
where emr_id is not null
and program_id <> @hrts_program_id
order by emr_id, index_asc;
