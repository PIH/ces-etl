select concept_id into @oldGriefConceptId from concept where uuid = '139251AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
select concept_id into @newGriefConceptId from concept where uuid = '121792AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';

-- load all obs with old diagnoses
drop temporary table if exists temp_grief_dxs;
create temporary table temp_grief_dxs
select * from obs where value_coded  = @oldGriefConceptId
;

-- void old diagnoses
update obs o 
inner join temp_grief_dxs t on t.obs_id = o.obs_id 
set o.voided = 1,
	o.date_voided = NOW(),
	o.void_reason = 'migrate to new adjustment disorder diagnosis'
;

-- update temp table to new diagnosis
update temp_grief_dxs t 
set t.value_coded = @newGriefConceptId
; 

-- insert new diagnoses in table
-- allow obs_id to auto increment
-- generate new uuid
-- otherwise, replicate the old entry obs but with updated value_coded
insert into obs
(person_id,
concept_id,
encounter_id,
order_id,
obs_datetime,
location_id,
obs_group_id,
accession_number,
value_group_id,
value_coded,
value_coded_name_id,
value_drug,
value_datetime,
value_numeric,
value_modifier,
value_text,
value_complex,
comments,
creator,
date_created,
voided,
uuid,
previous_version,
form_namespace_and_path,
status,
interpretation
)
select 
person_id,
concept_id,
encounter_id,
order_id,
obs_datetime,
location_id,
obs_group_id,
accession_number,
value_group_id,
value_coded,
value_coded_name_id,
value_drug,
value_datetime,
value_numeric,
value_modifier,
value_text,
value_complex,
comments,
creator,
date_created,
0, -- voided
uuid(), -- generate new uuid
t.obs_id, -- previous version
form_namespace_and_path,
'AMENDED', -- status
interpretation
from temp_grief_dxs t
;
