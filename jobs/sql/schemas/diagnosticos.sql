CREATE TABLE diagnosticos
(
  emr_id                      varchar(50),
 	encuentro_id                int,
	diagnosticos_id             int,
	emr_instancia               varchar(255),		
	encuentro_fecha             datetime,
	tipo_encuentro              varchar(255),
	entrada_fecha               datetime,
	entrada_persona             varchar(255),
	diagnostico                 varchar(255),
	codigo_icd_10				varchar(255),
	diagnostico_sin_codificacion varchar(255),
	diagnostico_primario         bit,
	primera_vez                  bit
  );
