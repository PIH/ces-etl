CREATE TABLE usuarios
(
    usuario             varchar(50),
    nombres             varchar(50),
    apellidos           varchar(50),
    correo_electronico  varchar(500),
    cuenta_activada     bit,
    fecha_creado        datetime,
    creado_por          varchar(50),
    tipo_proveedor      varchar(50),
    fecha_última_acceso     datetime,
    número_accesos_registrados int,
    mfa_status          varchar(50)
)
;




