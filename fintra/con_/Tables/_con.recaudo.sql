-- Table: con.recaudo

-- DROP TABLE con.recaudo;

CREATE TABLE con.recaudo
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  periodo_recaudo character varying(6) NOT NULL DEFAULT ''::character varying,
  nom_empresa character varying(100) NOT NULL DEFAULT ''::character varying,
  nom_unicom character varying(100) NOT NULL DEFAULT ''::character varying,
  cod_unicom character varying(4) NOT NULL DEFAULT ''::character varying,
  gestor character varying(100) NOT NULL DEFAULT ''::character varying,
  nom_cli character varying(100) NOT NULL DEFAULT ''::character varying,
  nic character varying(7) NOT NULL DEFAULT ''::character varying,
  nis_rad character varying(7) NOT NULL DEFAULT ''::character varying,
  num_acu integer NOT NULL DEFAULT 0,
  simbolo_var character varying(10) NOT NULL DEFAULT ''::character varying,
  f_fact character varying(10) NOT NULL DEFAULT ''::character varying,
  f_puesta character varying(10) NOT NULL DEFAULT ''::character varying,
  co_concepto character varying(10) NOT NULL DEFAULT ''::character varying,
  desc_concepto character varying(100) NOT NULL DEFAULT ''::character varying,
  imp_facturado_concepto moneda,
  imp_pagado_concepto moneda,
  imp_recaudo moneda,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE con.recaudo
  OWNER TO postgres;
GRANT ALL ON TABLE con.recaudo TO postgres;

