-- Table: etes.tipo_descuentos

-- DROP TABLE etes.tipo_descuentos;

CREATE TABLE etes.tipo_descuentos
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  descripcion character varying(60) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE etes.tipo_descuentos
  OWNER TO postgres;

