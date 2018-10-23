-- Table: con.log_carga_apoteosys

-- DROP TABLE con.log_carga_apoteosys;

CREATE TABLE con.log_carga_apoteosys
(
  reg_status character(1) NOT NULL DEFAULT ''::bpchar,
  tipo_doc character varying(20) NOT NULL DEFAULT ''::character varying,
  clase_doc character varying(20) NOT NULL DEFAULT ''::character varying,
  orden_servicio character varying(20) NOT NULL DEFAULT ''::character varying,
  mensaje_error text,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.log_carga_apoteosys
  OWNER TO postgres;

