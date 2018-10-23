-- Table: opav.sl_kardex

-- DROP TABLE opav.sl_kardex;

CREATE TABLE opav.sl_kardex
(
  id serial NOT NULL,
  id_bodega integer NOT NULL DEFAULT 0,
  cod_material character varying NOT NULL DEFAULT 0,
  unidad character varying NOT NULL DEFAULT 0,
  cantidad numeric NOT NULL DEFAULT 0,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  descripcion_material character varying,
  id_solicitud character varying(50)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_kardex
  OWNER TO postgres;
