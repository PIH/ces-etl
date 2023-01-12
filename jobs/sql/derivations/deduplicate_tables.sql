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
-- ordered by last updated, and then prioritizing where the patient registration equals the site 
drop table if exists ces_pacientes;
select * into ces_pacientes from #staging_pacientes sp
where emr_id =
	(select top 1 emr_id from  #staging_pacientes sp2
	where sp2.person_uuid = sp.person_uuid 
	order by ultimo_encuentro_fecha desc,
	iif(case sp2.registracion_localidad
		when 'Soledad' then 'soledad'
		when 'Salvador' then 'salvador'
		when 'Monterrey' then 'monterrey'
		when 'Matazano' then 'matazano'
		when 'Letrero' then 'letrero'
		when 'Laguna del Cofre' then 'laguna'
		when 'Capitan' then 'capitan'
		when 'Honduras' then 'honduras'
		when 'Casa Materna' then 'jaltenango'
		when 'CER' then 'jaltenango'
		when 'CES Oficina' then 'jaltenango'
		when 'Hospital' then 'jaltenango'	
		when 'Pediatría' then 'jaltenango'
		when 'Reforma' then 'jaltenango'
		when 'CER' then 'jaltenango'
		when 'CES Oficina' then 'jaltenango'
		when 'Hospital' then 'jaltenango'		
	   end = site, 1, 0) desc)
;
