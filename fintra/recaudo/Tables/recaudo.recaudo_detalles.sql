-- Table: recaudo.recaudo_detalles

-- DROP TABLE recaudo.recaudo_detalles;

CREATE TABLE recaudo.recaudo_detalles
(
  id serial NOT NULL,
  id_rec integer,
  cod_servicio_lote character varying(13),
  numero_lote integer,
  referencia_factura character varying(48),
  valor_recaudado numeric(12,2),
  procedencia_pago character varying(2),
  medio_pago character varying(2),
  num_operacion character varying(6),
  num_autorizacion character varying(6),
  cod_entidad_debitada integer,
  nit_entidad_debitada character varying(30),
  cod_sucursal character varying(4),
  numero_fila integer,
  causal_devolucion character varying(3),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  encontrado boolean DEFAULT false,
  procesado_cartera boolean DEFAULT false,
  causal_dev_procesamiento character varying(3) DEFAULT ''::character varying,
  negocio character varying(15) DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT recaudo_detalles_id_rec_fkey FOREIGN KEY (id_rec)
      REFERENCES recaudo.recaudos (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE recaudo.recaudo_detalles
  OWNER TO postgres;

