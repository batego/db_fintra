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