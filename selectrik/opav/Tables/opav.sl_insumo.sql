-- Table: opav.sl_insumo

-- DROP TABLE opav.sl_insumo;

CREATE TABLE opav.sl_insumo
(
  id serial NOT NULL,
  id_subcategoria integer NOT NULL,
  descripcion text,
  codigo_material character varying(20) NOT NULL DEFAULT ''::character varying,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_sl_insumo1 FOREIGN KEY (id_subcategoria)
      REFERENCES opav.sl_subcategoria (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_insumo
  OWNER TO postgres;
