/*
	Archivo de montaje para el nuevo módulo de polizas
*/

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

-- Table Tipo_cobro

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

-- Table Tipo_valor_poliza

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

COMMENT ON COLUMN administrativo.tipo_valor_poliza.tipo
IS 'TIPO DEL VALOR DE LA POLIZA: PORCENTAJE(P) O VALOR ABSOLUTO(A)';

CREATE TABLE afiliados (
		id               SERIAL PRIMARY KEY,
		reg_status       CHARACTER(1) NOT NULL       DEFAULT '' :: CHARACTER VARYING,
		dstrct           VARCHAR(4)   NOT NULL       DEFAULT '' :: CHARACTER VARYING,
		nit              VARCHAR(15)  NOT NULL,
		descripcion      VARCHAR(160) NOT NULL,
		creation_date    TIMESTAMP WITHOUT TIME ZONE DEFAULT current_timestamp,
		last_update      TIMESTAMP WITHOUT TIME ZONE DEFAULT current_timestamp,
		creation_user    VARCHAR(10)  NOT NULL,
		last_user_update VARCHAR(10)
);

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

CREATE TABLE sucursales (
		id                 SERIAL PRIMARY KEY,
		reg_status         CHARACTER(1) NOT NULL       DEFAULT '' :: CHARACTER VARYING,
		dstrct             VARCHAR(4)   NOT NULL       DEFAULT '' :: CHARACTER VARYING,
		descripcion        VARCHAR(50)  NOT NULL,
		oficina            VARCHAR(50),
		direccion          VARCHAR(100),
		ciudad             VARCHAR(3)   NOT NULL,
		departamento       VARCHAR(3)   NOT NULL,
		id_unidad_afiliado INTEGER,
		creation_date      TIMESTAMP WITHOUT TIME ZONE DEFAULT current_timestamp,
		last_update        TIMESTAMP WITHOUT TIME ZONE DEFAULT current_timestamp,
		creation_user      VARCHAR(10)  NOT NULL,
		last_user_update   VARCHAR(10),
		CONSTRAINT id_rel_unidad_afiliado_tabla_sucursales_fk FOREIGN KEY (id_unidad_afiliado) REFERENCES rel_unidad_afiliado (id),
		CONSTRAINT id_ciudad_tabla_sucursales_fk FOREIGN KEY (ciudad) REFERENCES ciudad (codciu),
		CONSTRAINT id_departamento_tabla_sucursales_fk FOREIGN KEY (departamento) REFERENCES estado (department_code)
);

-- Table Configuracion_poliza

CREATE TABLE administrativo.nueva_configuracion_poliza (
		id                SERIAL UNIQUE,
		reg_status        CHARACTER(1) NOT NULL         DEFAULT '' :: CHARACTER VARYING,
		dstrct            VARCHAR(4)   NOT NULL         DEFAULT '' :: CHARACTER VARYING,
		id_poliza         INTEGER      NOT NULL,
		id_aseguradora    INTEGER      NOT NULL,
		id_valor_poliza   INTEGER      NOT NULL,
		id_tipo_cobro     INTEGER      NOT NULL,
		id_unidad_negocio INTEGER      NOT NULL,
		id_sucursal       INTEGER      NOT NULL,
		creation_date     TIMESTAMP WITHOUT TIME ZONE   DEFAULT current_timestamp,
		last_update       TIMESTAMP WITHOUT TIME ZONE   DEFAULT current_timestamp,
		creation_user     VARCHAR(10)  NOT NULL,
		last_user_update  VARCHAR(10),
		CONSTRAINT poliza_fk FOREIGN KEY (id_poliza) REFERENCES administrativo.nuevas_polizas (id),
		CONSTRAINT aseguradora_fk FOREIGN KEY (id_aseguradora) REFERENCES administrativo.aseguradoras (id),
		CONSTRAINT valor_plazo_fk FOREIGN KEY (id_valor_poliza) REFERENCES administrativo.tipo_valor_poliza (id),
		CONSTRAINT tipo_cobro_fk FOREIGN KEY (id_tipo_cobro) REFERENCES administrativo.tipo_cobro (id),
		CONSTRAINT unidad_negocio_fk FOREIGN KEY (id_unidad_negocio) REFERENCES unidad_negocio (id),
		CONSTRAINT sucursal_fk FOREIGN KEY (id_sucursal) REFERENCES sucursales (id),
		CONSTRAINT configuracion_poliza_fk PRIMARY KEY (id_poliza, id_aseguradora, id_unidad_negocio, id_sucursal)
);


CREATE TABLE tasas (
		id               SERIAL PRIMARY KEY,
		reg_status       CHARACTER(1) NOT NULL       DEFAULT '' :: CHARACTER VARYING,
		dstrct           VARCHAR(4)   NOT NULL       DEFAULT '' :: CHARACTER VARYING,
		descripcion      VARCHAR(20)  NOT NULL,
		valor            NUMERIC(4, 2),
		creation_date    TIMESTAMP WITHOUT TIME ZONE DEFAULT current_timestamp,
		last_update      TIMESTAMP WITHOUT TIME ZONE DEFAULT current_timestamp,
		creation_user    VARCHAR(10)  NOT NULL,
		last_user_update VARCHAR(10)
);

CREATE TABLE tasa_sucursal (
		id_tasa     INTEGER,
		id_sucursal INTEGER,
		CONSTRAINT id_tasa_tabla_tasa_sucursal_fk FOREIGN KEY (id_tasa) REFERENCES tasas (id),
		CONSTRAINT id_sucursal_tabla_tasa_sucursal_fk FOREIGN KEY (id_tasa) REFERENCES sucursales (id),
		CONSTRAINT tasa_sucursal_pk PRIMARY KEY (id_tasa, id_sucursal)
);

CREATE TABLE detalle_poliza_negocio (
		id                      SERIAL,
		cod_neg                 VARCHAR(15) NOT NULL,
		id_configuracion_poliza INTEGER     NOT NULL,
		fecha_vencimiento       TIMESTAMP WITHOUT TIME ZONE,
		item                    VARCHAR(15) NOT NULL,
		valor                   NUMERIC(11, 2) NOT NULL,
		CONSTRAINT detalle_poliza_negocio_pk PRIMARY KEY (cod_neg, id_configuracion_poliza, item),
		CONSTRAINT id_configuracion_poliza_detalle_poliza_negocio_fk FOREIGN KEY (id_configuracion_poliza) REFERENCES administrativo.nueva_configuracion_poliza (id)
);