-- Table: opav.sl_riesgo

-- DROP TABLE opav.sl_riesgo;

CREATE TABLE opav.sl_riesgo
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_solicitud integer NOT NULL DEFAULT 0,
  id_tipo_categoria integer NOT NULL DEFAULT 0,
  descripcion text NOT NULL DEFAULT ''::character varying,
  id_impacto integer NOT NULL DEFAULT 0,
  id_probabilidad integer,
  puntaje integer NOT NULL DEFAULT 0,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_sl_riesgo1 FOREIGN KEY (id_tipo_categoria)
      REFERENCES opav.sl_tipo_categoria (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_sl_riesgo2 FOREIGN KEY (id_impacto)
      REFERENCES opav.sl_impacto (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_riesgo
  OWNER TO postgres;
