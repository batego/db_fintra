-- Table: opav.sl_items_admon

-- DROP TABLE opav.sl_items_admon;

CREATE TABLE opav.sl_items_admon
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  id_categoria integer NOT NULL,
  descripcion text NOT NULL DEFAULT ''::character varying,
  valor numeric(19,2) NOT NULL DEFAULT 0,
  is_default character varying(1) NOT NULL DEFAULT 'N'::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT sl_items_admon_id_categoria_fkey FOREIGN KEY (id_categoria)
      REFERENCES opav.sl_categorias_admon (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_items_admon
  OWNER TO postgres;
