CREATE TABLE administrativo.nuevas_polizas (
		id               SERIAL PRIMARY KEY,
		reg_status       CHARACTER(1) NOT NULL       DEFAULT '' :: CHARACTER VARYING,
		dstrct           VARCHAR(4)   NOT NULL       DEFAULT '' :: CHARACTER VARYING,
		descripcion      VARCHAR(50)  NOT NULL,
		creation_date    TIMESTAMP WITHOUT TIME ZONE DEFAULT current_timestamp,
		last_update      TIMESTAMP WITHOUT TIME ZONE DEFAULT current_timestamp,
		creation_user    VARCHAR(10)  NOT NULL,
		last_user_update VARCHAR(10)
);