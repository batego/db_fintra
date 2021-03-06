-- Table: opav.sl_rel_acciones_apu

-- DROP TABLE opav.sl_rel_acciones_apu;

CREATE TABLE opav.sl_rel_acciones_apu
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_accion character varying(12) NOT NULL,
  id_apu integer NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_sl_rel_acciones_apu1 FOREIGN KEY (id_accion)
      REFERENCES opav.acciones (id_accion) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_sl_rel_acciones_apu2 FOREIGN KEY (id_apu)
      REFERENCES opav.sl_apu (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_rel_acciones_apu
  OWNER TO postgres;
