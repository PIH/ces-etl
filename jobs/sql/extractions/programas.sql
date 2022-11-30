select program_id into @hypertension from program p where uuid='6959057e-9a5c-40ba-a878-292ba4fc35bc';
select patient_identifier_type_id into @identifier_type from patient_identifier_type pit where uuid ='506add39-794f-11e8-9bcd-74e5f916c5ec';


drop temporary table if exists programas;
create temporary table programas(
patient_id int, 
emrid varchar(50),
emr_instance varchar(50),
program varchar(50),
program_id int,
date_created datetime,
hearts bit,
hearts_date date,
date_enrolled datetime,
date_completed datetime,
status varchar(50),
index_asc int,
index_desc int
);

-- All Programs 
insert into programas(patient_id,emr_instance,program,program_id,date_created,date_enrolled,date_completed,status)
select  pp.patient_id,
		location_name(pp.location_id) emr_instance,
		p.name program,
		pp.program_id,
		pp.date_created,
		pp.date_enrolled,
		pp.date_completed,
		cn.name status
		from patient_program pp
left outer join program p on pp.program_id =p.program_id 
left outer join concept_name cn on pp.outcome_concept_id = cn.concept_id and cn.voided=0 and cn.locale='en' and cn.locale_preferred=1
where pp.voided=0;

update programas t 
set emrid = (
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


-- ---- Ascending Order ------------------------------------------

drop table if exists int_asc;
create table int_asc
select * from programas vs 
ORDER BY emrid asc, date_enrolled asc, program_id asc, date_created asc;

set @row_number := 0;
DROP TABLE IF EXISTS asc_order;
CREATE TABLE asc_order
SELECT 
    @row_number:=CASE
        WHEN @emrid = emrid  
			THEN @row_number + 1
        ELSE 1
    END AS index_asc,
    @emrid:=emrid  emrid,
    date_enrolled,program_id,date_created
FROM
    int_asc;
   
update programas es
set es.index_asc = (
 select distinct index_asc 
 from asc_order
 where emrid=es.emrid 
 and date_enrolled=es.date_enrolled
 and program_id=es.program_id
 and date_created=es.date_created
);
    

-- ---- Descending Order ------------------------------------------

drop table if exists int_desc;
create table int_desc
select * from programas vs 
ORDER BY emrid asc, date_enrolled desc, program_id desc, date_created desc;

set @row_number := 0;
DROP TABLE IF EXISTS desc_order;
CREATE TABLE desc_order
SELECT 
    @row_number:=CASE
        WHEN @emrid = emrid  
			THEN @row_number + 1
        ELSE 1
    END AS index_desc,
    @emrid:=emrid  emrid,
    date_enrolled,program_id,date_created
FROM
    int_desc;
   
update programas es
set es.index_desc = (
 select distinct index_desc 
 from desc_order
 where emrid= es.emrid 
 and date_enrolled=es.date_enrolled
 and program_id=es.program_id
 and date_created=es.date_created
);
    
select 
emrid,
emr_instance,
program,
hearts,
hearts_date,
cast(date_enrolled as date) date_enrolled,
cast(date_completed as date)  as date_unenroll,
status,
index_asc,
index_desc
from programas
where emrid is not null
order by emrid, index_asc;
