SELECT program_id INTO @program_id FROM program p WHERE uuid='0e69c3ab-1ccb-430b-b0db-b9760319230f';
select patient_identifier_type_id into @identifier_type from patient_identifier_type pit where uuid ='506add39-794f-11e8-9bcd-74e5f916c5ec';
select encounter_type_id into @reg_encounter from encounter_type et where uuid='873f968a-73a8-4f9c-ac78-9f4778b751b6';
select encounter_type_id into @consult_encounter from encounter_type et where uuid='aa61d509-6e76-4036-a65d-7813c0c3b752';
set @dbname = '${partitionNum}';

DROP TABLE IF EXISTS salud_mental_estatus;
CREATE TEMPORARY TABLE salud_mental_estatus (
dbname varchar(30),
patient_id int,
emr_id varchar(30),
emr_instancia varchar(30),
resultado_salud_mental varchar(30),
resultado_salud_mental_fecha datetime,
index_asc int,
index_desc int);

drop table if exists tmp_patient_identifier_v2;
CREATE table tmp_patient_identifier_v2 AS
SELECT DISTINCT patient_id,identifier
FROM  patient_identifier
where voided = 0 
and identifier_type = @identifier_type
GROUP BY patient_id;

truncate table salud_mental_estatus;

insert into salud_mental_estatus (patient_id, emr_id, emr_instancia, resultado_salud_mental, resultado_salud_mental_fecha)
SELECT distinct pp.patient_id,pi2.identifier 'emr_id', l.name 'emr_instancia',
	  'inscrito' as 'resultado_salud_mental' , date_enrolled  'resultado_salud_mental_fecha'
FROM patient_program pp 
inner join tmp_patient_identifier_v2 pi2 on pi2.patient_id = pp.patient_id  
left outer join location l on pp.location_id =l.location_id 
WHERE program_id =@program_id
union all
SELECT DISTINCT pp.patient_id,pi2.identifier 'emr_id', l.name 'emr_instancia',
	  cn.name as 'resultado_salud_mental' , date_completed  'resultado_salud_mental_fecha'
FROM patient_program pp 
inner join tmp_patient_identifier_v2 pi2 on pi2.patient_id = pp.patient_id  
left outer join location l on pp.location_id =l.location_id 
left outer join concept_name cn on pp.outcome_concept_id =cn.concept_id 
WHERE program_id =@program_id and outcome_concept_id is not null 
and cn.locale ='en'
and cn.voided =0 and cn.concept_name_type='FULLY_SPECIFIED'
;


update salud_mental_estatus t
set t.dbname=@dbname;

update salud_mental_estatus t 
set t.emr_instancia = (
	select l.name
	from encounter e inner join location l
	on e.location_id = l.location_id 
	where e.patient_id = t.patient_id
	and cast(e.encounter_datetime as date) = cast(t.resultado_salud_mental_fecha as date)
	and e.encounter_type  in (@reg_encounter,@consult_encounter)
	limit 1
)
where t.emr_instancia is null;


drop table if exists mental_estatus_tbl;
CREATE table mental_estatus_tbl as 
select patient_id, resultado_salud_mental_fecha
from salud_mental_estatus;


CREATE OR REPLACE VIEW v_estatus_rnk_asc AS 
SELECT t.patient_id,t.resultado_salud_mental_fecha ,(
    SELECT COUNT(*)
    FROM mental_estatus_tbl AS x
    WHERE x.patient_id = t.patient_id
    AND x.resultado_salud_mental_fecha < t.resultado_salud_mental_fecha
) + 1 AS erank_asc
FROM mental_estatus_tbl t
ORDER BY t.patient_id, erank_asc;


CREATE OR REPLACE VIEW v_estatus_rnk_desc AS 
SELECT t.patient_id,t.resultado_salud_mental_fecha,(
    SELECT COUNT(*)
    FROM mental_estatus_tbl AS x
    WHERE x.patient_id = t.patient_id
    AND x.resultado_salud_mental_fecha > t.resultado_salud_mental_fecha
) + 1 AS erank_desc
FROM mental_estatus_tbl t
ORDER BY t.patient_id, erank_desc;


update salud_mental_estatus t 
set t.index_asc = (
 select erank_asc
 from v_estatus_rnk_asc r
 where r.patient_id=t.patient_id 
 and r.resultado_salud_mental_fecha=t.resultado_salud_mental_fecha
 limit 1
);

update salud_mental_estatus t 
set t.index_desc = (
 select erank_desc
 from v_estatus_rnk_desc r
 where r.patient_id=t.patient_id 
 and r.resultado_salud_mental_fecha=t.resultado_salud_mental_fecha
 limit 1
);


select 
distinct 
dbname,
patient_id,
emr_id,
emr_instancia,
resultado_salud_mental,
resultado_salud_mental_fecha,
index_asc,
index_desc
from salud_mental_estatus
order by patient_id,resultado_salud_mental_fecha desc, resultado_salud_mental desc;