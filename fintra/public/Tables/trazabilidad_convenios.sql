-- Table: trazabilidad_convenios

-- DROP TABLE trazabilidad_convenios;

CREATE TABLE trazabilidad_convenios
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_convenio integer NOT NULL DEFAULT nextval('convenios_id_convenio_seq'::regclass),
  nombre character varying(200) NOT NULL,
  tasa_interes numeric NOT NULL,
  user_update character varying(10) NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  tasa_usura numeric
)
WITH (
  OIDS=FALSE
);
ALTER TABLE trazabilidad_convenios
  OWNER TO postgres;

