-- Table: recaudo_eca2

-- DROP TABLE recaudo_eca2;

CREATE TABLE recaudo_eca2
(
  id serial NOT NULL,
  mes character varying(50) DEFAULT ''::character varying,
  periodo_recaudo character varying(10) DEFAULT ''::character varying,
  nom_empresa character varying(50) DEFAULT ''::character varying,
  nom_unicom character varying(50) DEFAULT ''::character varying,
  cod_unicom character varying(5) DEFAULT ''::character varying,
  gestor_cta character varying(100) DEFAULT ''::character varying,
  nom_cli character varying(100) DEFAULT ''::character varying,
  nic character varying(10) DEFAULT ''::character varying,
  nis_rad character varying(10) DEFAULT ''::character varying,
  num_acu character varying(3) DEFAULT ''::character varying,
  simbolo_variable text DEFAULT ''::text,
  f_fact character varying(8) DEFAULT ''::character varying,
  f_puesta character varying(8) DEFAULT ''::character varying,
  concepto character varying(6) DEFAULT ''::character varying,
  desc_concepto character varying(50) DEFAULT ''::character varying,
  imp_facturado_concepto numeric(18,2) DEFAULT 0,
  imp_pagado_concepto numeric(18,2) DEFAULT 0,
  valor numeric(18,2) DEFAULT 0,
  last_update timestamp without time zone DEFAULT now(),
  user_update character varying(10) DEFAULT ''::character varying,
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10) DEFAULT ''::character varying,
  reg_status character varying(1) DEFAULT ''::character varying,
  dstrct character varying(4) DEFAULT ''::character varying,
  saldo numeric(18,2) DEFAULT 0,
  fecha_cruce timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  factura character varying(10) DEFAULT ''::character varying,
  fecha timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  revision text DEFAULT ''::text,
  id_cliente_excel character varying(10),
  cxc_excel character varying(10) DEFAULT ''::character varying,
  ms_excel character varying(15) DEFAULT ''::character varying,
  saldo_fac_excel moneda DEFAULT 0,
  observacion_excel text DEFAULT ''::text,
  comentario character varying(10) DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE recaudo_eca2
  OWNER TO postgres;
GRANT ALL ON TABLE recaudo_eca2 TO postgres;
GRANT SELECT ON TABLE recaudo_eca2 TO msoto;

