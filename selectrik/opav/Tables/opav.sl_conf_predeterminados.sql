-- Table: opav.sl_conf_predeterminados

-- DROP TABLE opav.sl_conf_predeterminados;

CREATE TABLE opav.sl_conf_predeterminados
(
  id serial NOT NULL,
  id_especificacion integer NOT NULL,
  id_valores_predeterminados integer NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_sl_conf_predeterminados1 FOREIGN KEY (id_especificacion)
      REFERENCES opav.sl_especificacion (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_sl_conf_predeterminados2 FOREIGN KEY (id_valores_predeterminados)
      REFERENCES opav.sl_valores_predeterminados (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_conf_predeterminados
  OWNER TO postgres;
