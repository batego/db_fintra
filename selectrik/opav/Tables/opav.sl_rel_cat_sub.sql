-- Table: opav.sl_rel_cat_sub

-- DROP TABLE opav.sl_rel_cat_sub;

CREATE TABLE opav.sl_rel_cat_sub
(
  id serial NOT NULL,
  id_categoria integer NOT NULL DEFAULT 0,
  id_subcategoria integer NOT NULL DEFAULT 0,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_sl_cat_sub_rel1 FOREIGN KEY (id_categoria)
      REFERENCES opav.sl_categoria (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_sl_cat_sub_rel2 FOREIGN KEY (id_subcategoria)
      REFERENCES opav.sl_subcategoria (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_rel_cat_sub
  OWNER TO postgres;
