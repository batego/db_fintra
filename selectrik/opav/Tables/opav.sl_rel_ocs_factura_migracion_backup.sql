-- Table: opav.sl_rel_ocs_factura_migracion_backup

-- DROP TABLE opav.sl_rel_ocs_factura_migracion_backup;

CREATE TABLE opav.sl_rel_ocs_factura_migracion_backup
(
  id integer,
  reg_status character varying(1),
  ocs character varying(20),
  sub_ocs character varying(20),
  despacho character varying(20),
  factura character varying(100),
  periodo character varying(6),
  creation_date timestamp without time zone,
  creation_user character varying(10),
  last_update timestamp without time zone,
  user_update character varying(10)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_rel_ocs_factura_migracion_backup
  OWNER TO postgres;
