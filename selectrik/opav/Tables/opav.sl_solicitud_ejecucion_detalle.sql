-- Table: opav.sl_solicitud_ejecucion_detalle

-- DROP TABLE opav.sl_solicitud_ejecucion_detalle;

CREATE TABLE opav.sl_solicitud_ejecucion_detalle
(
  id serial NOT NULL,
  id_solicitud_ejecucion integer NOT NULL,
  codigo_insumo character varying(20) NOT NULL DEFAULT ''::character varying,
  descripcion_insumo text NOT NULL DEFAULT ''::character varying,
  referencia_externa character varying(200) NOT NULL DEFAULT ''::character varying,
  observacion_xinsumo text DEFAULT ''::character varying,
  id_unidad_medida integer NOT NULL DEFAULT 0,
  nombre_unidad_insumo character varying(20) NOT NULL DEFAULT ''::character varying,
  cantidad_solicitada numeric(15,4) NOT NULL DEFAULT 0,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_solicitud_ejecucion FOREIGN KEY (id_solicitud_ejecucion)
      REFERENCES opav.sl_solicitud_ejecucion (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_solicitud_ejecucion_detalle
  OWNER TO postgres;