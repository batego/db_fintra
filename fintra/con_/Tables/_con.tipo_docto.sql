-- Table: con.tipo_docto

-- DROP TABLE con.tipo_docto;

CREATE TABLE con.tipo_docto
(
  reg_status character(1) NOT NULL DEFAULT ''::bpchar, -- Estado del Registro
  codigo character varying(5) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(30) NOT NULL DEFAULT ''::character varying,
  codigo_interno character varying(5) NOT NULL DEFAULT ''::character varying, -- Codigo Interno de del documento
  tercero character(1) NOT NULL DEFAULT 'N'::bpchar, -- Id que indica si el comprobante es diario o no
  maneja_serie character(1) NOT NULL DEFAULT 'N'::bpchar, -- Id . que indica si este tipo de documento debe manejar serie o se debe digitar manualmente
  prefijo character varying(3) NOT NULL DEFAULT ''::character varying, -- Prefijo General
  prefijo_anio character varying(4) NOT NULL DEFAULT ''::character varying, -- Prefijo anio. Puede ser A, AA o AAAA
  prefijo_mes character varying(2) NOT NULL DEFAULT ''::character varying, -- Prefijo Mes. MM
  last_update timestamp without time zone NOT NULL DEFAULT now(), -- Fecha de Actualizacion
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(), -- Fecha de Creacion
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  serie_ini numeric(4,0) NOT NULL DEFAULT 0, -- En caso que maneje serie, se debe indicar la serie inicial
  serie_fin numeric(4,0) NOT NULL DEFAULT 0, -- En caso que maneje serie, se debe indicar la serie final
  serie_act numeric(4,0) NOT NULL DEFAULT 0, -- En caso que maneje serie, indica el ultimo valor en uso de la serie
  long_serie numeric(2,0) NOT NULL DEFAULT 0, -- En caso que maneje serie, se debe indicar la longitud de la serie
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  comprodiario character(1) NOT NULL DEFAULT 'N'::bpchar
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.tipo_docto
  OWNER TO postgres;
GRANT ALL ON TABLE con.tipo_docto TO postgres;
GRANT SELECT ON TABLE con.tipo_docto TO msoto;
COMMENT ON COLUMN con.tipo_docto.reg_status IS 'Estado del Registro';
COMMENT ON COLUMN con.tipo_docto.codigo_interno IS 'Codigo Interno de del documento';
COMMENT ON COLUMN con.tipo_docto.tercero IS 'Id que indica si el comprobante es diario o no';
COMMENT ON COLUMN con.tipo_docto.maneja_serie IS 'Id . que indica si este tipo de documento debe manejar serie o se debe digitar manualmente';
COMMENT ON COLUMN con.tipo_docto.prefijo IS 'Prefijo General';
COMMENT ON COLUMN con.tipo_docto.prefijo_anio IS 'Prefijo anio. Puede ser A, AA o AAAA';
COMMENT ON COLUMN con.tipo_docto.prefijo_mes IS 'Prefijo Mes. MM';
COMMENT ON COLUMN con.tipo_docto.last_update IS 'Fecha de Actualizacion';
COMMENT ON COLUMN con.tipo_docto.creation_date IS 'Fecha de Creacion';
COMMENT ON COLUMN con.tipo_docto.serie_ini IS 'En caso que maneje serie, se debe indicar la serie inicial';
COMMENT ON COLUMN con.tipo_docto.serie_fin IS 'En caso que maneje serie, se debe indicar la serie final';
COMMENT ON COLUMN con.tipo_docto.serie_act IS 'En caso que maneje serie, indica el ultimo valor en uso de la serie';
COMMENT ON COLUMN con.tipo_docto.long_serie IS 'En caso que maneje serie, se debe indicar la longitud de la serie';


