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

ALTER TABLE detalle_poliza_negocio ALTER COLUMN item TYPE integer USING item::integer;
