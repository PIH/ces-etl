CREATE TABLE ces_pacientes_staging (
emr_id                      varchar(30),
nombres                     varchar(511),
apellidos                   varchar(255), 
person_uuid                 char(38),
registracion_localidad      varchar(30),
registracion_fecha          date,
nacimiento_fecha            date,
edad_hoy                    int,
genero                      char(1),
entidad                     varchar(50),
municipio                   varchar(50),
localidad                   varchar(50),
migrante                    bit,
indigena                    bit,
discapacidad                bit,
educacion                   bit,
busqueda_activa             bit,
estado_civil                varchar(50),
ocupacion                   varchar(50),
fallecido                   bit,
muerte_fecha                date,
causa_de_deceso             varchar(50),
tamizado_phq2_gad2          bit,
tamizado_phq2_gad2_fecha    date,
talla                       float,
peso                        float,
imc                         float,
ultimo_encuentro_fecha      date,
ultimo_encuentro_tipo       varchar(50)
);
