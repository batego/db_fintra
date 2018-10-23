CREATE TABLE administrativo.aseguradoras (
		id                         SERIAL PRIMARY KEY,
		reg_status                 CHARACTER(1)  NOT NULL       DEFAULT '' :: CHARACTER VARYING,
		dstrct                     VARCHAR(4)    NOT NULL       DEFAULT '' :: CHARACTER VARYING,
		descripcion                VARCHAR(50)   NOT NULL,
		nit                        BIGINT        NOT NULL       CHECK (nit > 999999999),
		retorno                    NUMERIC(6, 3) NOT NULL,
		plazo_pago                 INTEGER       NOT NULL,
		plazo_recuperacion_retorno INTEGER       NOT NULL,
		creation_date              TIMESTAMP WITHOUT TIME ZONE  DEFAULT current_timestamp,
		last_update                TIMESTAMP WITHOUT TIME ZONE  DEFAULT current_timestamp,
		creation_user              VARCHAR(10)   NOT NULL,
		last_user_update           VARCHAR(10)
);