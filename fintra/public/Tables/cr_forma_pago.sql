-- Table: cr_forma_pago

-- DROP TABLE cr_forma_pago;

CREATE TABLE cr_forma_pago
(
  id serial NOT NULL,
  id_central_riesgo character varying(30) NOT NULL DEFAULT ''::character varying,
  cod character varying(2) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(60) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cr_forma_pago
  OWNER TO postgres;
GRANT ALL ON TABLE cr_forma_pago TO postgres;
GRANT SELECT ON TABLE cr_forma_pago TO msoto;

