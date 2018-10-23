-- Table: opav.sl_rel_ocs_factura_migracion

-- DROP TABLE opav.sl_rel_ocs_factura_migracion;

CREATE TABLE opav.sl_rel_ocs_factura_migracion
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  ocs character varying(20) NOT NULL DEFAULT ''::character varying,
  sub_ocs character varying(20) NOT NULL DEFAULT ''::character varying,
  despacho character varying(20) NOT NULL DEFAULT ''::character varying,
  factura character varying(100) NOT NULL DEFAULT ''::character varying,
  periodo character varying(6) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_rel_ocs_factura_migracion
  OWNER TO postgres;
