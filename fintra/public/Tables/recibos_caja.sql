-- Table: recibos_caja

-- DROP TABLE recibos_caja;

CREATE TABLE recibos_caja
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  num_recibo character varying(20) NOT NULL,
  fecha_entrega date NOT NULL,
  asesor character varying(160) NOT NULL DEFAULT ''::character varying,
  area character varying(50) NOT NULL DEFAULT ''::character varying,
  id_estado_recibo character varying(50) NOT NULL,
  fecha_recibido date NOT NULL DEFAULT '0099-01-01'::date,
  id_cliente character varying(15) NOT NULL DEFAULT ''::character varying,
  nombre_cliente character varying(160) NOT NULL DEFAULT ''::character varying,
  id_tipo_recaudo integer,
  valor_recaudo numeric(12,2),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  comment text NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE recibos_caja
  OWNER TO postgres;
GRANT ALL ON TABLE recibos_caja TO postgres;
GRANT SELECT ON TABLE recibos_caja TO msoto;

