CREATE TABLE usuario_roles
(
    usuario             varchar(50),
    nombres             varchar(50),
    apellidos           varchar(50),
    tipo_rol           varchar(50),
    valor_rol          varchar(255),
    cuenta_activada     bit,
    fecha_creado        datetime,
    creado_por          varchar(50),
    fecha_ultima_acceso datetime,
    numero_accesos_registrados int
);