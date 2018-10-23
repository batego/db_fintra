-- Table: opav.sl_condiciones_comerciales

-- DROP TABLE opav.sl_condiciones_comerciales;

CREATE TABLE opav.sl_condiciones_comerciales
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT 'FINV'::character varying,
  id_solicitud character varying(15) DEFAULT ''::character varying,
  iva_anticipo character varying(1) NOT NULL DEFAULT 'N'::character varying,
  iva_retegarantia character varying(1) NOT NULL DEFAULT 'N'::character varying,
  administracion_anticipo character varying(1) NOT NULL DEFAULT 'N'::character varying,
  administracion_retegarantia character varying(1) NOT NULL DEFAULT 'N'::character varying,
  imprevisto_anticipo character varying(1) NOT NULL DEFAULT 'N'::character varying,
  imprevisto_retegarantia character varying(1) NOT NULL DEFAULT 'N'::character varying,
  utilidad_anticipo character varying(1) NOT NULL DEFAULT 'N'::character varying,
  utilidad_retegarantia character varying(1) NOT NULL DEFAULT 'N'::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_condiciones_comerciales
  OWNER TO postgres;
