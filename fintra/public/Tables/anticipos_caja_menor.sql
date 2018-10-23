-- Table: anticipos_caja_menor

-- DROP TABLE anticipos_caja_menor;

CREATE TABLE anticipos_caja_menor
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT 'FINV'::character varying,
  empleado character varying(15) NOT NULL DEFAULT ''::character varying,
  cod_anticipo character varying(11) NOT NULL DEFAULT ''::character varying,
  concepto text NOT NULL DEFAULT ''::text,
  banco character varying(15) NOT NULL DEFAULT ''::character varying,
  sucursal character varying(30) NOT NULL DEFAULT ''::character varying,
  valor_anticipo numeric(11,2) NOT NULL DEFAULT 0,
  num_factura character varying(10) NOT NULL DEFAULT ''::character varying,
  num_cxp character varying(10) NOT NULL DEFAULT ''::character varying,
  valor_legalizado numeric(11,2) NOT NULL DEFAULT 0,
  legalizado character varying(1) NOT NULL DEFAULT 'N'::character varying,
  tipo_num_doc_leg character varying(10) NOT NULL DEFAULT ''::character varying,
  num_doc_legalizado character varying(10) NOT NULL DEFAULT ''::character varying,
  nota_ajuste character varying NOT NULL DEFAULT ''::character varying,
  cxp_gasto character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  tipo_anticipo character varying NOT NULL DEFAULT ''::character varying,
  nc_gasto character(10) NOT NULL DEFAULT ''::bpchar
)
WITH (
  OIDS=FALSE
);
ALTER TABLE anticipos_caja_menor
  OWNER TO postgres;
GRANT ALL ON TABLE anticipos_caja_menor TO postgres;
GRANT SELECT ON TABLE anticipos_caja_menor TO msoto;

