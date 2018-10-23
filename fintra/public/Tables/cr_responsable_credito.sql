-- Table: cr_responsable_credito

-- DROP TABLE cr_responsable_credito;

CREATE TABLE cr_responsable_credito
(
  id serial NOT NULL,
  id_central_riesgo integer NOT NULL,
  cod character varying(2) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(60) NOT NULL DEFAULT ''::character varying,
  enmi_cartera character varying(2) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cr_responsable_credito
  OWNER TO postgres;
GRANT ALL ON TABLE cr_responsable_credito TO postgres;
GRANT SELECT ON TABLE cr_responsable_credito TO msoto;

