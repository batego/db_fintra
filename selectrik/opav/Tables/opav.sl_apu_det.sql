-- Table: opav.sl_apu_det

-- DROP TABLE opav.sl_apu_det;

CREATE TABLE opav.sl_apu_det
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_apu integer NOT NULL DEFAULT 0,
  id_insumo integer NOT NULL DEFAULT 0,
  id_unidad_medida integer NOT NULL DEFAULT 0,
  id_tipo_insumo integer NOT NULL DEFAULT 0,
  cantidad numeric NOT NULL DEFAULT 0,
  rendimiento numeric NOT NULL DEFAULT 0.00,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_sl_apu_det1 FOREIGN KEY (id_apu)
      REFERENCES opav.sl_apu (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_sl_apu_det2 FOREIGN KEY (id_insumo)
      REFERENCES opav.sl_insumo (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_sl_apu_det4 FOREIGN KEY (id_tipo_insumo)
      REFERENCES opav.sl_tipo_insumo (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_apu_det
  OWNER TO postgres;
