-- Table: opav.sl_cuentas_inventario

-- DROP TABLE opav.sl_cuentas_inventario;

CREATE TABLE opav.sl_cuentas_inventario
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  cuenta character varying NOT NULL,
  descripcion character varying(100) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone,
  user_update character varying(10)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_cuentas_inventario
  OWNER TO postgres;
