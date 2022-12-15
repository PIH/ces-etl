CREATE TABLE encuentro_signos_vitales
(
    emr_id          	VARCHAR(25),
    encuentro_id		int,
    emr_instancia		varchar(255),
    encuentro_fecha		datetime,
    proveedor 		 	VARCHAR(255),
    entrada_fecha		date,
    entrada_persona		varchar(255),
    talla				float,
    peso				float,
    imc 				float,
    presion_sistolica	int,
    presion_diastolica	int,
    sat_o2				float,
    ayuno	 			bit,
    glucosa 			float,
    temperatura			float,
    frecuencia_cardiaca	float,
    frecuencia_respiratoria	float,
    phq2				int,
    gad2				int,
    molestia_principal	text,
    index_asc			int,
    index_desc			int
);
