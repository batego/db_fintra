-- Table: opav.sl_categoria

-- DROP TABLE opav.sl_categoria;

CREATE TABLE opav.sl_categoria
(
  id integer NOT NULL DEFAULT nextval('opav.sl_categoria_id_seq1'::regclass),
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  nombre text NOT NULL DEFAULT ''::character varying,
  descripcion text NOT NULL DEFAULT ''::character varying,
  id_tipo_insumo integer NOT NULL DEFAULT 0,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  esquema character varying(20) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_sl_categoria1 FOREIGN KEY (id_tipo_insumo)
      REFERENCES opav.sl_tipo_insumo (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_categoria
  OWNER TO postgres;
