CREATE TABLE encuentro_signos_vitales_staging
(
    all_vitals_id            varchar(50),
    emr_id                   varchar(25),
    person_uuid              char(38),
    visita_id                varchar(50),
    encuentro_id             varchar(50),
    encounter_uuid           char(38),
    emr_instancia            varchar(255),
    encuentro_fecha          datetime,
    proveedor                VARCHAR(255),
    entrada_fecha            date,
    entrada_persona          varchar(255),
    talla                    float,
    peso                     float,
    imc                      float,
    presion_sistolica        int,
    presion_diastolica       int,
    sat_o2                   float,
    ayuno                    bit,
    glucosa                  float,
    temperatura              float,
    frecuencia_cardiaca      float,
    frecuencia_respiratoria  float,
    phq2                     int,
    gad2                     int,
    molestia_principal       text,
    index_asc                int,
    index_desc               int
);
