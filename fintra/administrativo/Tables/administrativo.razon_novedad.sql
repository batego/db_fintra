-- Table: administrativo.razon_novedad

-- DROP TABLE administrativo.razon_novedad;

CREATE TABLE administrativo.razon_novedad
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(50) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  id_tipo integer NOT NULL,
  origen character varying(1)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.razon_novedad
  OWNER TO postgres;

