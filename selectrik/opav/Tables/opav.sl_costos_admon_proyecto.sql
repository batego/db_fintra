-- Table: opav.sl_costos_admon_proyecto

-- DROP TABLE opav.sl_costos_admon_proyecto;

CREATE TABLE opav.sl_costos_admon_proyecto
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  num_solicitud character varying(15) NOT NULL,
  id_categoria integer NOT NULL,
  id_item integer NOT NULL,
  cantidad numeric(19,3) NOT NULL DEFAULT 0,
  id_unidad integer NOT NULL,
  duracion numeric(19,3) NOT NULL DEFAULT 0,
  porcentaje_aplicacion numeric(19,3) NOT NULL DEFAULT 0,
  valor_unitario numeric(19,3) NOT NULL DEFAULT 0,
  valor_total numeric(19,3) NOT NULL DEFAULT 0,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT sl_costos_admon_id_categoria_fkey FOREIGN KEY (id_categoria)
      REFERENCES opav.sl_categorias_admon (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT sl_costos_admon_id_item_fkey FOREIGN KEY (id_item)
      REFERENCES opav.sl_items_admon (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT sl_costos_admon_id_unidad_fkey FOREIGN KEY (id_unidad)
      REFERENCES opav.sl_unidades_admon (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_costos_admon_proyecto
  OWNER TO postgres;
