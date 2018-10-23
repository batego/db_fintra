-- Table: recaudo.recaudos

-- DROP TABLE recaudo.recaudos;

CREATE TABLE recaudo.recaudos
(
  id serial NOT NULL,
  facturadora_nit character varying(15) NOT NULL,
  fecha_recaudo date NOT NULL,
  recaudadora_nit character varying(30),
  cuenta_cliente character varying(17),
  fecha_archivo timestamp without time zone,
  modificador character varying(1),
  tipo_cuenta character varying(2),
  numero_lotes integer,
  numero_filas integer,
  valor_total numeric(16,2),
  estado integer,
  porcentaje_procesado integer,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  recaudadora_cod integer,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE recaudo.recaudos
  OWNER TO postgres;

