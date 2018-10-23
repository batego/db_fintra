-- Table: con.mc_cxp_procesadas_su

-- DROP TABLE con.mc_cxp_procesadas_su;

CREATE TABLE con.mc_cxp_procesadas_su
(
  tipo_documento character varying(5) NOT NULL DEFAULT ''::character varying,
  factura_cxp character varying(50) NOT NULL DEFAULT ''::character varying,
  periodo character varying(6) NOT NULL DEFAULT ''::character varying,
  procesado_cxp character varying(1) NOT NULL DEFAULT 'S'::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.mc_cxp_procesadas_su
  OWNER TO postgres;

