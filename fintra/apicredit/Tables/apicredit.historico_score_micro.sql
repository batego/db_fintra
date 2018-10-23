-- Table: apicredit.historico_score_micro

-- DROP TABLE apicredit.historico_score_micro;

CREATE TABLE apicredit.historico_score_micro
(
  id serial NOT NULL,
  reg_status character(1) NOT NULL DEFAULT ''::bpchar,
  s_numero_solicitud integer NOT NULL DEFAULT 0,
  s_identificacion character varying(15) NOT NULL DEFAULT ''::character varying,
  s_exclusion character varying(20) NOT NULL DEFAULT ''::character varying,
  s_base_score numeric(11,2) NOT NULL DEFAULT 0,
  s_diasmoramicro_cal numeric(11,2) NOT NULL DEFAULT 0,
  s_utilizacion_cuenta_cartera_a_fecha_cal numeric(11,2) NOT NULL DEFAULT 0,
  s_creditosactulesnegativos_cal numeric(11,2) NOT NULL DEFAULT 0,
  s_creditoscerrados_cal numeric(11,2) NOT NULL DEFAULT 0,
  s_maxexpmic_cal numeric(11,2) NOT NULL DEFAULT 0,
  s_edad_cal numeric(11,2) NOT NULL DEFAULT 0,
  s_saldototal_cal numeric(11,2) NOT NULL DEFAULT 0,
  s_ncuentasmicro_cal numeric(11,2) NOT NULL DEFAULT 0,
  s_score_total numeric(11,2) NOT NULL DEFAULT 0,
  s_creation_date timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE apicredit.historico_score_micro
  OWNER TO postgres;

