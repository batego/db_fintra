-- Table: administrativo.tipo_servicio

-- DROP TABLE administrativo.tipo_servicio;

CREATE TABLE administrativo.tipo_servicio
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  lote_carga character varying(10) NOT NULL,
  descripcion character varying(30) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(20) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_tipo_servicio_lote FOREIGN KEY (lote_carga)
      REFERENCES administrativo.control_lote_fasecolda (lote_carga) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.tipo_servicio
  OWNER TO postgres;

