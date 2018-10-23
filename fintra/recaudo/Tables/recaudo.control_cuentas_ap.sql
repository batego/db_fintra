-- Table: recaudo.control_cuentas_ap

-- DROP TABLE recaudo.control_cuentas_ap;

CREATE TABLE recaudo.control_cuentas_ap
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  cod_controlcuentas character varying(8) NOT NULL DEFAULT ''::character varying,
  unidad_negocio integer NOT NULL DEFAULT 0,
  cuentaixm character varying NOT NULL DEFAULT ''::character varying,
  cuentagac character varying NOT NULL DEFAULT ''::character varying,
  cuentacabingreso character varying NOT NULL DEFAULT ''::character varying,
  cuentadetingreso character varying NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE recaudo.control_cuentas_ap
  OWNER TO postgres;
COMMENT ON TABLE recaudo.control_cuentas_ap
  IS 'relacion de cuentas segun la unidad de negocio';

