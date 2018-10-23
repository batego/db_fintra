-- Table: opav.categoria

-- DROP TABLE opav.categoria;

CREATE TABLE opav.categoria
(
  idcategoria integer NOT NULL DEFAULT nextval('opav.categoria_idcategoria_seq1'::regclass),
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  descripcion text NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  max_dias_inactividad numeric(15,0) DEFAULT 365,
  esquema character varying(20) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.categoria
  OWNER TO postgres;
