--
-- ces_pacientes
--
-- update uuids that should be changes because of merging
drop table if exists #staging_pacientes;
select * into #staging_pacientes from ces_pacientes_staging cp; 

update sp
set sp.person_uuid = mh.winner_person_uuid
from #staging_pacientes sp 
inner join merge_history mh on mh.loser_person_uuid = sp.person_uuid 
; 

-- choose single pacientes row based on row with latest encounter
drop table if exists ces_pacientes;
select * into ces_pacientes from #staging_pacientes sp
where emr_id =
	(select top 1 emr_id from  #staging_pacientes sp2
	where sp2.person_uuid = sp.person_uuid 
	order by ultimo_encuentro_fecha desc)
;
