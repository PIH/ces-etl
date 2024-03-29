CREATE TABLE encuentro_consulta_staging
(
emrid                                  varchar(50),
person_uuid                            char(38),  
visita_id                              varchar(50),  
encuentro_id                           varchar(50),
encounter_uuid                         char(38),
encuentro_tipo                         varchar(255),  
encuentro_fecha                        datetime,
emr_instancia                          varchar(50),
entrada_fecha                          datetime,  
entrada_persona                        varchar(255),
proveedor                              varchar(255),
referido_por                           varchar(255),
diabetes                               bit,
asma                                   bit,
desnutrición                           bit,
epilepsia                              bit,
hipertensión                           bit,
cuidado_prenatal                       bit,
salud_mental                           bit,
asma_tos                               bit,
asma_despertado                        bit,
asma_medicamento                       bit,
asma_actividad                         bit,
glucosa                                float,
ayuno                                  bit,
hba1c                                  float,
proteinuria_diabetes                   int,
circunferencia_abdominal               float,
examen_del_pie                         varchar(255),
sintomas_hiperglucemia                 bit, 
alcohol                                varchar(255),
tabaco                                 varchar(255),
colesterol_total                       float,
hdl                                    float,
ldl                                    float,
hearts                                 bit,
hearts_cambio_tratamiento              bit,
hearts_riesgo_cardiovascular           float,
epilepsia_ataques_antes                float,
epilepsia_ataques_ultimas_4semanas     float,
embarazo_planeado                      bit,
causa_no_planeado_fallo_anticonceptivo bit,
causa_no_planeado_fallo_violencia      bit,
embarazo_deseado                       bit,
fum                                    date,
edad_gestacional                       float,
fecha_parto_estimada                   date,
gesto                                  int,
parto                                  int,
cesaria                                int,
perdida_menores_20sdg                  int,
perdida_mayores_20sdg                  int,
reporte_ultrasonido                    text,
prueba_vih_prenatal                    varchar(255),
prueba_vdrl                            varchar(255),
hemoglobin                             float,
proteinuria_prenatal                   float,
tipo_sangre                            varchar(255),
vacuna_dtp                             bit,
curva_tolerancia_glucosa               varchar(255),
plan_parto                             text,
phq9                                   int,
gad7                                   int,
exploracion_fisica                     text,
sospecha_tb                            bit,
prueba_tb                              varchar(255),
sospecha_vih                           bit,
prueba_vih                             varchar(255),
sospecha_covid                         bit,
prueba_covid                           varchar(255),
analisis                               text,
diagnostico_primario                   varchar(255),
diagnostico_secundario                 varchar(1200),
indicaciones_medicas                   text,
tipo_ultrasonido                       varchar(255),
ultrasonido_medida                     varchar(255),
sdg_utrasonido                         float,
fecha_parto_ultrasonido                date,
peso_fetal                             float,
cambio_diagnostico_ultrasonido         bit,
pastilla_anticonceptivas               bit,
inyeccion_1mes                         bit,
inyeccion_2mes                         bit,
inyeccion_3mes                         bit,
implante                               bit,
parche_anticonceptivo                  bit,
pastilla_emergencia                    bit,
diu_cobre                              bit,
diu_mirena                             bit,
condones                               bit,
mifepristona                           bit,
misoprostol                            bit,
hierro_dextran                         bit,
proxima_cita                           date,
prueba_sifilis						varchar(20),
prueba_hepb							varchar(20),
prueba_clamidia						varchar(20),
prueba_gonorrea						varchar(20),
prueba_hepc							varchar(20),
comentario_ultrasonido				text,
index_asc                              int,
index_desc                             int
);
