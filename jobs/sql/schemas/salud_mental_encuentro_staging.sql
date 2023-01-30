CREATE TABLE salud_mental_encuentro_staging
(
emr_id                      varchar(30),
person_uuid                 char(38),
emr_instancia               varchar(30),
edad_encuentro              int,
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
analisis                    varchar(5000),
estatus_paciente            varchar(30),
diagnostico                 varchar(255),
diagnostico_primario        varchar(100),
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
indicaciones_medicas        varchar(5000),
orden_laboratorio           varchar(5000),
medicamento1                varchar(255),
med1_frascos_cajas          int,
med1_instrucciones          varchar(255),
medicamento2                varchar(255),
med2_frascos_cajas          int,
med2_instrucciones          varchar(255),
medicamento3                varchar(255),
med3_frascos_cajas          int,
med3_instrucciones          varchar(255),
medicamento4                varchar(255),
med4_frascos_cajas          int,
med4_instrucciones          varchar(255),
medicamento5                varchar(255),
med5_frascos_cajas          int,
med5_instrucciones          varchar(255),
medicamento6                varchar(255),
med6_frascos_cajas          int,
med6_instrucciones          varchar(255),
medicamento7                varchar(255),
med7_frascos_cajas          int,
med7_instrucciones          varchar(255),
medicamento8                varchar(255),
med8_frascos_cajas          int,
med8_instrucciones          varchar(255),
medicamento9                varchar(255),
med9_frascos_cajas          int,
med9_instrucciones          varchar(255),
medicamento10               varchar(255),
med10_frascos_cajas         int,
med10_instrucciones         varchar(255),
proxima_cita                date
);
