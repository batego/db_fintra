-- Table: opav.sl_conf_sub_esp

-- DROP TABLE opav.sl_conf_sub_esp;

CREATE TABLE opav.sl_conf_sub_esp
(
  id serial NOT NULL,
  id_subcategoria integer NOT NULL DEFAULT 0,
  id_especificacion integer NOT NULL DEFAULT 0,
  obligatorio character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_sl_conf_sub_esp1 FOREIGN KEY (id_subcategoria)
      REFERENCES opav.sl_subcategoria (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_sl_conf_sub_esp2 FOREIGN KEY (id_especificacion)
      REFERENCES opav.sl_especificacion (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_conf_sub_esp
  OWNER TO postgres;
