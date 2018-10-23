-- Table: opav.sl_conceptos

-- DROP TABLE opav.sl_conceptos;

CREATE TABLE opav.sl_conceptos
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  nombre text NOT NULL DEFAULT ''::character varying,
  descripcion text NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  factura character varying(1) DEFAULT 0
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_conceptos
  OWNER TO postgres;
