drop table if exists mh_encuentro;
create table mh_encuentro
(
emr_id                      varchar(30),
person_uuid                 varchar(38),
emr_instancia               varchar(30),
edad_encuentro              float,
encuentro_id                varchar(30),
encuentro_uuid              char(38),
index_asc                   int,
index_desc                  int,
encuentro_fecha             date,
date_changed                date,
entrada_fecha               date,
entrada_persona             varchar(30),
visita_id                   varchar(50),
visita_fecha                date,
proveedor                   varchar(30),
referido_por                varchar(500),
subjetivo                   text,
control_prenatal            bit,
parto_estimado_fecha        date,
phq9_p1                     int,
phq9_p2                     int,
phq9_p3                     int,
phq9_p4                     int,
phq9_p5                     int,
phq9_p6                     int,
phq9_p7                     int,
phq9_p8                     int,
phq9_p9                     int,
phq9_total                  int,
gad7_p1                     int,
gad7_p2                     int,
gad7_p3                     int,
gad7_p4                     int,
gad7_p5                     int,
gad7_p6                     int,
gad7_p7                     int,
gad7_total                  int,
analisis                    varchar(2000),
estatus_paciente            varchar(30),
diagnosticos                text,
diagnostico_primario        varchar(255),
psicosis                    bit,
trastorno_estado_de_animo   bit,
trastornos_ansiedad         bit,
trastornos_adaptativos      bit,
trastornos_disociativos     bit,
trastornos_psicosomaticos   bit,
trastornos_alimentacion     bit,
trastornos_personalidad     bit,
trastornos_conducta         bit,
ideacion_suicida            bit,
duelo_y_perdida             bit,
orden_laboratorio           varchar(5000),
proxima_cita                date
);

insert into mh_encuentro
(mh.emr_id,
mh.person_uuid,
mh.emr_instancia,
mh.edad_encuentro,
mh.encuentro_id,
mh.encuentro_uuid,
mh.index_asc,
mh.index_desc,
mh.encuentro_fecha,
mh.date_changed,
mh.entrada_fecha,
mh.entrada_persona,
mh.visita_id,
mh.visita_fecha,
mh.proveedor,
mh.referido_por,
mh.subjetivo,
mh.control_prenatal,
mh.parto_estimado_fecha,
mh.phq9_p1,
mh.phq9_p2,
mh.phq9_p3,
mh.phq9_p4,
mh.phq9_p5,
mh.phq9_p6,
mh.phq9_p7,
mh.phq9_p8,
mh.phq9_p9,
mh.phq9_total,
mh.gad7_p1,
mh.gad7_p2,
mh.gad7_p3,
mh.gad7_p4,
mh.gad7_p5,
mh.gad7_p6,
mh.gad7_p7,
mh.gad7_total,
mh.analisis,
mh.diagnosticos,
mh.diagnostico_primario,
mh.psicosis,
mh.trastorno_estado_de_animo,
mh.trastornos_ansiedad,
mh.trastornos_adaptativos,
mh.trastornos_disociativos,
mh.trastornos_psicosomaticos,
mh.trastornos_alimentacion,
mh.trastornos_personalidad,
mh.trastornos_conducta,
mh.ideacion_suicida,
mh.duelo_y_perdida,
mh.orden_laboratorio,
mh.proxima_cita)
select 
ec.emrid,
ec.person_uuid,
ec.emr_instancia,
ec.edad_encuentro,
ec.encuentro_id,
ec.encounter_uuid,
ec.index_asc,
ec.index_desc,
ec.encuentro_fecha,
ec.fecha_cambiada,
ec.entrada_fecha,
ec.entrada_persona,
ec.visita_id,
ec.visita_fecha,
ec.proveedor,
ec.referido_por,
ec.exploracion_fisica,
ec.cuidado_prenatal,
ec.fecha_parto_estimada,
ec.phq9_p1,
ec.phq9_p2,
ec.phq9_p3,
ec.phq9_p4,
ec.phq9_p5,
ec.phq9_p6,
ec.phq9_p7,
ec.phq9_p8,
ec.phq9_p9,
ec.phq9_total,
ec.gad7_p1,
ec.gad7_p2,
ec.gad7_p3,
ec.gad7_p4,
ec.gad7_p5,
ec.gad7_p6,
ec.gad7_p7,
ec.gad7_total,
ec.analisis,
ec.diagnosticos
ec.diagnostico_primario,
ec.psicosis,
ec.trastorno_estado_de_animo,
ec.trastornos_ansiedad,
ec.trastornos_adaptativos,
ec.trastornos_disociativos,
ec.trastornos_psicosomaticos,
ec.trastornos_alimentacion,
ec.trastornos_personalidad,
ec.trastornos_conducta,
ec.ideacion_suicida,
ec.duelo_y_perdida,
ec.orden_laboratorio,
ec.proxima_cita
from encuentro_consulta ec
inner join salud_mental_paciente smp on ec.emrid = smp.emr_id
; 

DROP TABLE IF EXISTS salud_mental_encuentro;
EXEC sp_rename 'mh_encuentro', 'salud_mental_encuentro';
