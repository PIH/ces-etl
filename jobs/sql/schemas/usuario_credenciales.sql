CREATE TABLE usuario_credenciales
(
    id_aceso                char(36),
    usuario                 varchar(50),
    fecha_iniciar_sesion    datetime,
    fecha_cerrar_sesion     datetime,
    fecha_expirar           datetime,
    duracion_minutos_activos    int
);