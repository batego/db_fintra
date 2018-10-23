-- Table: veto_historia

-- DROP TABLE veto_historia;

CREATE TABLE veto_historia
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  tipo character varying(1) NOT NULL DEFAULT ''::character varying, -- P si es placa, N si es nit
  documento character varying(15) NOT NULL DEFAULT ''::character varying, -- nit o placa afectada
  causa character varying(25) NOT NULL DEFAULT ''::character varying, -- causa del veto
  observacion text NOT NULL DEFAULT ''::text, -- observacion del veto
  evento character varying(1) NOT NULL DEFAULT ''::character varying, -- S se veto, N se quito el veto
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  serie integer NOT NULL,
  fuente_veto character varying(30) DEFAULT ''::character varying -- fuente del reporte
)
WITH (
  OIDS=FALSE
);
ALTER TABLE veto_historia
  OWNER TO postgres;
GRANT ALL ON TABLE veto_historia TO postgres;
GRANT SELECT ON TABLE veto_historia TO msoto;
COMMENT ON TABLE veto_historia
  IS 'Tabla que almacena los dias festivos del ano';
COMMENT ON COLUMN veto_historia.tipo IS 'P si es placa, N si es nit';
COMMENT ON COLUMN veto_historia.documento IS 'nit o placa afectada';
COMMENT ON COLUMN veto_historia.causa IS 'causa del veto';
COMMENT ON COLUMN veto_historia.observacion IS 'observacion del veto';
COMMENT ON COLUMN veto_historia.evento IS 'S se veto, N se quito el veto';
COMMENT ON COLUMN veto_historia.fuente_veto IS 'fuente del reporte ';


