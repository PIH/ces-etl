CREATE TABLE salud_mental_estatus_staging
(
emr_id varchar(30),
person_uuid char(38),
patient_program_uuid char(38),
date_changed date,
emr_instancia varchar(30),
resultado_salud_mental text,
resultado_salud_mental_fecha datetime,
index_asc int,
index_desc int
);