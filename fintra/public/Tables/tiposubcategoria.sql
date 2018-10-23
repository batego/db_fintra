-- Table: tiposubcategoria

-- DROP TABLE tiposubcategoria;

CREATE TABLE tiposubcategoria
(
  idcategoria integer NOT NULL DEFAULT 0,
  idsubcategoria integer NOT NULL DEFAULT 0,
  idtiposubcategoria serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  descripcion text NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tiposubcategoria
  OWNER TO postgres;
GRANT ALL ON TABLE tiposubcategoria TO postgres;
GRANT SELECT ON TABLE tiposubcategoria TO msoto;

