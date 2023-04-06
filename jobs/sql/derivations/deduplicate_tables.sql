--
-- ces_pacientes
--
-- update uuids that should be changed because of merging
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
		when 'Monterrey' then 'jaltenango'
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
-- update uuids that should be changed because of merging
drop table if exists #staging_encuentro_consulta;
select * into #staging_encuentro_consulta from encuentro_consulta_staging; 

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
		when 'Monterrey' then 'jaltenango'
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

-- update emr_id based on what was chosen on ces_pacientes 
update x
set x.emrid = (select emr_id from ces_pacientes cp where cp.person_uuid = x.person_uuid  )
from encuentro_consulta x
;

--
-- programas
--
-- update uuids that should be changed because of merging
drop table if exists #staging_programas;
select * into #staging_programas from programas_staging; 

-- add unique identifier column
ALTER TABLE  #staging_programas 
ADD unique_pp_id int IDENTITY(1,1);

update sp
set sp.person_uuid = mh.winner_person_uuid
from #staging_programas sp 
inner join merge_history mh on mh.loser_person_uuid = sp.person_uuid 
; 

-- choose single programas row based on row with latest encounter
-- ordered by last updated, and then prioritizing where the enrollment location equals the site 
drop table if exists programas_tmp;
select * into programas_tmp from #staging_programas sp
where sp.unique_pp_id  =
	(select top 1 sp2.unique_pp_id  from  #staging_programas sp2
	where sp2.patient_program_uuid = sp.patient_program_uuid 
	order by last_updated desc,
	iif(case sp2.emr_instancia
		when 'Soledad' then 'soledad'
		when 'Salvador' then 'salvador'
		when 'Monterrey' then 'jaltenango'
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

-- update emr_id based on what was chosen on ces_pacientes 
update x
set x.emr_id = (select emr_id from ces_pacientes cp where cp.person_uuid = x.person_uuid  )
from programas x
;

--
-- salud_mental_encuentro
--
-- update uuids that should be changed because of merging
drop table if exists #staging_salud_mental_encuentro;
select * into #staging_salud_mental_encuentro from salud_mental_encuentro_staging; 

update s
set s.person_uuid = mh.winner_person_uuid
from #staging_salud_mental_encuentro s
inner join merge_history mh on mh.loser_person_uuid = s.person_uuid 
; 

-- choose single encounter row based on rows where encounter location = site 
drop table if exists salud_mental_encuentro;
select * into salud_mental_encuentro from #staging_salud_mental_encuentro s
where s.encuentro_id  =
	(select top 1 s2.encuentro_id from #staging_salud_mental_encuentro s2
	where s2.encuentro_uuid = s.encuentro_uuid 
	order by iif(case s2.emr_instancia
		when 'Soledad' then 'soledad'
		when 'Salvador' then 'salvador'
		when 'Monterrey' then 'jaltenango'
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

-- update emr_id based on what was chosen on ces_pacientes 
update x
set x.emr_id = (select emr_id from ces_pacientes cp where cp.person_uuid = x.person_uuid  )
from salud_mental_encuentro x
;
--
-- diagnosticos
--
-- update uuids that should be changed because of merging
drop table if exists #staging_diagnosticos;
select * into #staging_diagnosticos from diagnosticos_staging; 

update s
set s.person_uuid = mh.winner_person_uuid
from #staging_diagnosticos s
inner join merge_history mh on mh.loser_person_uuid = s.person_uuid 
; 

-- choose single diagnosis (obs) row based on rows where encounter location = site 
drop table if exists diagnosticos;
select * into diagnosticos from #staging_diagnosticos s
where s.diagnosticos_id  =
	(select top 1 s2.diagnosticos_id from #staging_diagnosticos s2
	where s2.obs_uuid = s.obs_uuid 
	order by iif(case s2.emr_instancia
		when 'Soledad' then 'soledad'
		when 'Salvador' then 'salvador'
		when 'Monterrey' then 'jaltenango'
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
-- update emr_id based on what was chosen on ces_pacientes 
update x
set x.emr_id = (select emr_id from ces_pacientes cp where cp.person_uuid = x.person_uuid  )
from diagnosticos x
;
--
-- salud_mental_paciente
--
-- update uuids that should be changed because of merging
drop table if exists #staging_salud_mental_paciente;
select * into #staging_salud_mental_paciente from salud_mental_paciente_staging cp; 

update sp
set sp.person_uuid = mh.winner_person_uuid
from #staging_salud_mental_paciente sp 
inner join merge_history mh on mh.loser_person_uuid = sp.person_uuid 
; 

-- choose single pacientes row based on row with latest encounter
-- ordered by last updated, and then prioritizing where the patient registration equals the site 
drop table if exists salud_mental_paciente;
select * into salud_mental_paciente from #staging_salud_mental_paciente sp
where emr_id =
	(select top 1 emr_id from  #staging_salud_mental_paciente sp2
	where sp2.person_uuid = sp.person_uuid 
	order by ultimo_visita_salud_mental_fecha desc,
	iif(case sp2.inscripcion_salud_mental_localidad
		when 'Soledad' then 'soledad'
		when 'Salvador' then 'salvador'
		when 'Monterrey' then 'jaltenango'
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
-- update emr_id based on what was chosen on ces_pacientes 
update x
set x.emr_id = (select emr_id from ces_pacientes cp where cp.person_uuid = x.person_uuid  )
from salud_mental_paciente x
;
--
-- encuentro_signos_vitales
--
-- update uuids that should be changed because of merging
drop table if exists #staging_encuentro_signos_vitales;
select * into #staging_encuentro_signos_vitales from encuentro_signos_vitales_staging; 

update sec
set sec.person_uuid = mh.winner_person_uuid
from #staging_encuentro_signos_vitales sec
inner join merge_history mh on mh.loser_person_uuid = sec.person_uuid 
; 

-- choose single encounter row based on rows where encounter location = site 
drop table if exists encuentro_signos_vitales_tmp;
select * into encuentro_signos_vitales_tmp from #staging_encuentro_signos_vitales sec
where sec.encuentro_id  =
	(select top 1 sec2.encuentro_id from #staging_encuentro_signos_vitales sec2
	where sec2.encounter_uuid = sec.encounter_uuid 
	order by iif(case sec2.emr_instancia
		when 'Soledad' then 'soledad'
		when 'Salvador' then 'salvador'
		when 'Monterrey' then 'jaltenango'
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
-- update emr_id based on what was chosen on ces_pacientes 
update x
set x.emr_id = (select emr_id from ces_pacientes cp where cp.person_uuid = x.person_uuid)
from encuentro_signos_vitales_tmp x
;
--
-- salud_mental_estatus
--
-- update uuids that should be changed because of merging
drop table if exists #staging_salud_mental_estatus;
select * into #staging_salud_mental_estatus from salud_mental_estatus_staging; 

-- add unique identifier column
ALTER TABLE  #staging_salud_mental_estatus 
ADD unique_pp_id int IDENTITY(1,1);

update sp
set sp.person_uuid = mh.winner_person_uuid
from #staging_salud_mental_estatus sp 
inner join merge_history mh on mh.loser_person_uuid = sp.person_uuid 
; 

-- choose single salud_mental_estatus row based on row that was changed most recently
-- ordered by last updated, and then prioritizing where the enrollment location equals the site 
-- note it is deduplicated by patient_program_uuid and status since there are multiple rows for each program and status
drop table if exists salud_mental_estatus_tmp;
select * into salud_mental_estatus_tmp from #staging_salud_mental_estatus sp
where sp.unique_pp_id  =
	(select top 1 sp2.unique_pp_id  from  #staging_salud_mental_estatus sp2
	where  sp2.patient_program_uuid+convert(varchar(255), sp2.resultado_salud_mental)=  sp.patient_program_uuid+convert(varchar(255), sp.resultado_salud_mental)
	order by date_changed desc,
	iif(case sp2.emr_instancia
		when 'Soledad' then 'soledad'
		when 'Salvador' then 'salvador'
		when 'Monterrey' then 'jaltenango'
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
-- update emr_id based on what was chosen on ces_pacientes 
update x
set x.emr_id = (select emr_id from ces_pacientes cp where cp.person_uuid = x.person_uuid)
from salud_mental_estatus_tmp x
;
--
-- visitas
--
-- update uuids that should be changed because of merging
drop table if exists #staging_visitas;
select * into #staging_visitas from visitas_staging; 

update sv
set sv.person_uuid = mh.winner_person_uuid
from #staging_visitas sv
inner join merge_history mh on mh.loser_person_uuid = sv.person_uuid 
; 

-- choose single visit row based on rows where visit location = site 
drop table if exists visitas_tmp;
select * into visitas_tmp from #staging_visitas sv
where sv.visita_id =
	(select top 1 sv2.visita_id from #staging_visitas sv2
	where sv2.visit_uuid = sv.visit_uuid 
	order by iif(case sv2.emr_instancia
		when 'Soledad' then 'soledad'
		when 'Salvador' then 'salvador'
		when 'Monterrey' then 'jaltenango'
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

-- update emr_id based on what was chosen on ces_pacientes 
update x
set x.emr_id = (select emr_id from ces_pacientes cp where cp.person_uuid = x.person_uuid  )
from visitas x;
