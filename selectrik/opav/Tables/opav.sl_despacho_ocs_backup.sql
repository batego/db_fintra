-- Table: opav.sl_despacho_ocs_backup

-- DROP TABLE opav.sl_despacho_ocs_backup;

CREATE TABLE opav.sl_despacho_ocs_backup
(
  id integer,
  reg_status character varying(1),
  solicitud_compra character varying(20),
  ocs character varying(20),
  factura_provint character varying(20),
  fecha_factura timestamp without time zone,
  periodo character varying(6),
  descripcion text,
  creation_date timestamp without time zone,
  creation_user character varying(10),
  last_update timestamp without time zone,
  user_update character varying(10)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_despacho_ocs_backup
  OWNER TO postgres;
