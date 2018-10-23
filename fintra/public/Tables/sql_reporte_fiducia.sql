-- Table: sql_reporte_fiducia

-- DROP TABLE sql_reporte_fiducia;

CREATE TABLE sql_reporte_fiducia
(
  id_reporte serial NOT NULL,
  reporte character varying NOT NULL,
  sql_totales text NOT NULL,
  sql_gtxt text NOT NULL,
  sql_detalles text NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  last_update timestamp without time zone NOT NULL,
  creation_user character varying NOT NULL,
  user_update character varying NOT NULL,
  reg_status character varying NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE sql_reporte_fiducia
  OWNER TO postgres;
GRANT ALL ON TABLE sql_reporte_fiducia TO postgres;
GRANT SELECT ON TABLE sql_reporte_fiducia TO msoto;

