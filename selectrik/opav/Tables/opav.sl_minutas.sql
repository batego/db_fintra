-- Table: opav.sl_minutas

-- DROP TABLE opav.sl_minutas;

CREATE TABLE opav.sl_minutas
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  id_solicitud character varying(15) NOT NULL,
  numero_contrato character varying(20) NOT NULL DEFAULT ''::character varying,
  valor_antes_iva numeric(19,3) NOT NULL DEFAULT 0,
  perc_administracion numeric(19,3) NOT NULL DEFAULT 0,
  administracion numeric(19,3) NOT NULL DEFAULT 0,
  perc_imprevisto numeric(19,3) NOT NULL DEFAULT 0,
  imprevisto numeric(19,3) NOT NULL DEFAULT 0,
  perc_utilidad numeric(19,3) NOT NULL DEFAULT 0,
  utilidad numeric(19,3) NOT NULL DEFAULT 0,
  perc_aiu numeric(19,3) NOT NULL DEFAULT 0,
  valor_aiu numeric(19,3) NOT NULL DEFAULT 0,
  perc_iva numeric(19,3) NOT NULL DEFAULT 0,
  valor_iva numeric(19,3) NOT NULL DEFAULT 0,
  total numeric(19,3) NOT NULL DEFAULT 0,
  perc_anticipo numeric(19,3) NOT NULL DEFAULT 0,
  valor_anticipo numeric(19,3) NOT NULL DEFAULT 0,
  docs_generados character varying(1) NOT NULL DEFAULT 'N'::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  tipo_contrato character varying(10) NOT NULL DEFAULT ''::character varying,
  cotizado_broker character varying(1) NOT NULL DEFAULT 'N'::character varying,
  cxp_aseguradora character varying(30) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_minutas
  OWNER TO postgres;
