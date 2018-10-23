CREATE TABLE tasa_sucursal (
		id_tasa     INTEGER,
		id_sucursal INTEGER,
		CONSTRAINT id_tasa_tabla_tasa_sucursal_fk FOREIGN KEY (id_tasa) REFERENCES tasas (id),
		CONSTRAINT id_sucursal_tabla_tasa_sucursal_fk FOREIGN KEY (id_tasa) REFERENCES sucursales (id),
		CONSTRAINT tasa_sucursal_pk PRIMARY KEY (id_tasa, id_sucursal)
);