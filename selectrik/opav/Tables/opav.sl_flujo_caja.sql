-- Table: opav.sl_flujo_caja

-- DROP TABLE opav.sl_flujo_caja;

CREATE TABLE opav.sl_flujo_caja
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_solicitud integer,
  periodo date NOT NULL DEFAULT now(),
  valor numeric(14,2) NOT NULL,
  id_concepto integer NOT NULL DEFAULT 0,
  descripcion text,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_sl_flujo_caja1 FOREIGN KEY (id_concepto)
      REFERENCES opav.sl_conceptos (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_flujo_caja
  OWNER TO postgres;
