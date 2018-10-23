-- Table: opav.sl_tipo_insumo

-- DROP TABLE opav.sl_tipo_insumo;

CREATE TABLE opav.sl_tipo_insumo
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  nombre_insumo character varying(20) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  porcentaje_rentab_contratista numeric(19,3) NOT NULL DEFAULT 0,
  iva_con_aiu character varying(1) NOT NULL DEFAULT '0'::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_tipo_insumo
  OWNER TO postgres;
