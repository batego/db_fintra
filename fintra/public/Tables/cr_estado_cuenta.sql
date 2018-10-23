-- Table: cr_estado_cuenta

-- DROP TABLE cr_estado_cuenta;

CREATE TABLE cr_estado_cuenta
(
  id serial NOT NULL,
  id_central_riesgo character varying(30) NOT NULL DEFAULT ''::character varying,
  cod character varying(2) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(60) NOT NULL DEFAULT ''::character varying,
  aplica character varying(1) NOT NULL DEFAULT 'S'::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cr_estado_cuenta
  OWNER TO postgres;
GRANT ALL ON TABLE cr_estado_cuenta TO postgres;
GRANT SELECT ON TABLE cr_estado_cuenta TO msoto;

