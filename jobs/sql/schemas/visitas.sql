create table visitas (
emr_id                varchar(50),
visita_id			        int,
visita_fecha_inicio	  datetime,
visita_fecha_termina  datetime,
visita_fecha_entrada  datetime,
entrada_persona       varchar(255),
visita_tipo           varchar(255),
emr_instancia         varchar(255),
index_asc             int,
index_desc            int);
