--
-- ces_pacientes
--
drop table if exists #staging_pacientes;
select * into #staging_pacientes from ces_pacientes_staging cp; 

-- update uuids that should be changed because of merging
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
--
-- encuentro_consulta
--
drop table if exists #staging_encuentro_consulta;
select * into #staging_encuentro_consulta from encuentro_consulta_staging; 

-- update uuids that should be changed because of merging
update sec
set sec.person_uuid = mh.winner_person_uuid
from #staging_encuentro_consulta sec
inner join merge_history mh on mh.loser_person_uuid = sec.person_uuid 
; 

-- choose single encounter row based on rows where encounter location = site 
drop table if exists encuentro_consulta;
select * into encuentro_consulta from #staging_encuentro_consulta sec
where sec.encuentro_id  =
	(select top 1 sec2.encuentro_id from #staging_encuentro_consulta sec2
	where sec2.encounter_uuid = sec.encounter_uuid 
	order by iif(case sec2.emr_instancia
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

--
-- programas
--
drop table if exists #staging_programas;
select * into #staging_programas from programas_staging; 

-- update uuids that should be changed because of merging
update sp
set sp.person_uuid = mh.winner_person_uuid
from #staging_programas sp 
inner join merge_history mh on mh.loser_person_uuid = sp.person_uuid 
; 

-- choose single pacientes row based on row with latest encounter
-- ordered by last updated, and then prioritizing where the enrollment location equals the site 
drop table if exists programas;
select * into programas from #staging_programas sp
where emr_id =
	(select top 1 emr_id from  #staging_programas sp2
	where sp2.person_uuid = sp.person_uuid 
	order by last_updated desc,
	iif(case sp2.emr_instancia
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
