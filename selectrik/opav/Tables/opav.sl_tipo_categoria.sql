-- Table: opav.sl_tipo_categoria

-- DROP TABLE opav.sl_tipo_categoria;

CREATE TABLE opav.sl_tipo_categoria
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  nombre_categoria character varying(20) NOT NULL DEFAULT ''::character varying,
  puntaje integer NOT NULL DEFAULT 0,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_tipo_categoria
  OWNER TO postgres;
