CREATE TABLE rel_unidad_afiliado (
		id                SERIAL UNIQUE,
		reg_status        CHARACTER(1) NOT NULL       DEFAULT '',
		dstrct            VARCHAR(5)   NOT NULL,
		id_unidad_negocio INTEGER,
		id_afiliado       INTEGER,
		creation_user     VARCHAR(10)  NOT NULL,
		last_user_update  VARCHAR(10),
		creation_date     TIMESTAMP WITHOUT TIME ZONE DEFAULT current_timestamp,
		last_update       TIMESTAMP WITHOUT TIME ZONE DEFAULT current_timestamp,
		PRIMARY KEY (id_unidad_negocio, id_afiliado),
		CONSTRAINT rel_unidad_afiliado_id_unidad_negocio_fk FOREIGN KEY (id_unidad_negocio) REFERENCES unidad_negocio (id),
		CONSTRAINT rel_unidad_afiliado_id_afiliado_fk FOREIGN KEY (id_afiliado) REFERENCES afiliados (id)
);