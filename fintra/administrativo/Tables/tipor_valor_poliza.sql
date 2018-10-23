CREATE TABLE administrativo.tipo_valor_poliza (
		id               SERIAL PRIMARY KEY,
		reg_status       CHARACTER(1) NOT NULL                                                                              DEFAULT '' :: CHARACTER VARYING,
		dstrct           VARCHAR(4)   NOT NULL                                                                              DEFAULT '' :: CHARACTER VARYING,
		descripcion      VARCHAR(50)  NOT NULL,
		tipo             CHARACTER(1) NOT NULL CHECK (tipo = 'A' OR tipo = 'P'),
		calcular_sobre   VARCHAR(5) CONSTRAINT check_calcular_sobre CHECK ((calcular_sobre IN ('K', 'KI', 'NLL')) AND tipo IN('P', 'A')) DEFAULT 'NLL',
		valor_absoluto   NUMERIC(11, 2) CONSTRAINT check_valor_absoluto CHECK ((tipo = 'P' AND valor_absoluto = 0) OR (tipo = 'A' AND valor_absoluto != 0)),
		valor_porc_iva   NUMERIC(4, 2),
		valor_porcentaje NUMERIC(6, 4) CONSTRAINT check_valor_porcentaje CHECK ((tipo = 'A' AND valor_porcentaje = 0) OR (tipo = 'P' AND valor_porcentaje != 0)),
		creation_date    TIMESTAMP WITHOUT TIME ZONE                                                                        DEFAULT current_timestamp,
		last_update      TIMESTAMP WITHOUT TIME ZONE                                                                        DEFAULT current_timestamp,
		creation_user    VARCHAR(10)  NOT NULL,
		last_user_update VARCHAR(10)
);