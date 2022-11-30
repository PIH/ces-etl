create table programas (
  emr_id            varchar(50),
  emr_instancia     varchar(50),
  programa          varchar(50),
  hearts            bit,
  hearts_fecha      date,
  fecha_inscrito    date,
  fecha_salida      date,
  estatus           varchar(50),
  index_asc         int,
  index_desc        int
);
