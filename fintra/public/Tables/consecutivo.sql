-- Table: consecutivo

-- DROP TABLE consecutivo;

CREATE TABLE consecutivo
(
  estado character varying(10) NOT NULL DEFAULT ''::character varying,
  tipodoc character varying(5) NOT NULL DEFAULT ''::character varying, -- tipo archivo
  anio character varying(4) NOT NULL DEFAULT ''::character varying,
  mes character varying(2) NOT NULL DEFAULT ''::character varying,
  dia character varying(2) NOT NULL DEFAULT ''::character varying,
  numero numeric(7,0) DEFAULT 0, -- consecutivo asociado al dia
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE consecutivo
  OWNER TO postgres;
GRANT ALL ON TABLE consecutivo TO postgres;
GRANT SELECT ON TABLE consecutivo TO msoto;
COMMENT ON TABLE consecutivo
  IS 'tabla que maneja los consecutivos de los archivos enviados a Corficolombiana';
COMMENT ON COLUMN consecutivo.tipodoc IS 'tipo archivo';
COMMENT ON COLUMN consecutivo.numero IS 'consecutivo asociado al dia';


