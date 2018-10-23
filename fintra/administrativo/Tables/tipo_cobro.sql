CREATE TABLE administrativo.tipo_cobro (
		id               SERIAL PRIMARY KEY,
		reg_status       CHARACTER(1) NOT NULL       DEFAULT '' :: CHARACTER VARYING,
		dstrct           VARCHAR(4)   NOT NULL       DEFAULT '' :: CHARACTER VARYING,
		descripcion      VARCHAR(50)  NOT NULL,
		tipo             CHARACTER(1) NOT NULL CHECK (tipo = 'C' OR tipo = 'A'),
		financiacion     CHARACTER(1) NOT NULL CHECK (financiacion = 'S' OR financiacion = 'N'),
		creation_date    TIMESTAMP WITHOUT TIME ZONE DEFAULT current_timestamp,
		last_update      TIMESTAMP WITHOUT TIME ZONE DEFAULT current_timestamp,
		creation_user    VARCHAR(10)  NOT NULL,
		last_user_update VARCHAR(10)
);