select patient_identifier_type_id into @identifier_type from patient_identifier_type pit where uuid ='506add39-794f-11e8-9bcd-74e5f916c5ec';

drop temporary table if exists visitas;
create temporary table visitas (
emrid varchar(50),
emr_instance varchar(50),
visit_id int,
visit_date_start datetime, 
visit_date_end datetime, 
visit_date_entered datetime,
index_asc int,
index_desc int);

insert into visitas(emrid,emr_instance,visit_id,visit_date_start,visit_date_end,visit_date_entered )
select 
	 pi2.identifier,
	 l.name as emr_instance,
	 visit_id, 
	 v.date_started as visit_date_start, 
	 v.date_stopped as visit_date_end,
	 v.date_created as visit_date_entered
from visit v
left outer join location l on v.location_id =l.location_id
left outer join patient_identifier pi2 on pi2.patient_id =v.patient_id and pi2.identifier_type=@identifier_type 
where v.voided =0;


-- ---- Ascending Order ------------------------------------------

drop table if exists int_asc;
create table int_asc
select * from visitas vs 
ORDER BY emrid asc, visit_date_start  asc, visit_id asc;


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
    visit_date_start,visit_id
FROM
    int_asc;
   
update visitas es
set es.index_asc = (
 select index_asc 
 from asc_order
 where emrid=es.emrid 
 and visit_date_start=es.visit_date_start
 and visit_id=es.visit_id
);
    

-- ---- Descending Order ------------------------------------------

drop table if exists int_desc;
create table int_desc
select * from visitas vs 
ORDER BY emrid asc, visit_date_start  desc, visit_id desc;


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
    visit_date_start,visit_id
FROM
    int_desc;
   
update visitas es
set es.index_desc = (
 select index_desc 
 from desc_order
 where emrid=es.emrid 
 and visit_date_start=es.visit_date_start
 and visit_id=es.visit_id
);

select 
emrid,
index_asc,
index_desc,
emr_instance,
visit_id ,
visit_date_start , 
visit_date_end , 
visit_date_entered
from visitas
order by emrid, index_asc;