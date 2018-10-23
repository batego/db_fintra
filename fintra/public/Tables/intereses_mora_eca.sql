-- Table: intereses_mora_eca

-- DROP TABLE intereses_mora_eca;

CREATE TABLE intereses_mora_eca
(
  documento character varying(10) DEFAULT ''::character varying,
  tipo character varying(2) NOT NULL DEFAULT ''::character varying,
  dias_vencidos integer,
  valor numeric(18,2) NOT NULL DEFAULT 0,
  interes_mora numeric(18,2) NOT NULL DEFAULT 0,
  num_ingreso character varying NOT NULL,
  factura_generada character varying NOT NULL DEFAULT ''::character varying,
  pagada character varying NOT NULL DEFAULT 'NO'::character varying,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  id_int serial NOT NULL,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE intereses_mora_eca
  OWNER TO postgres;
GRANT ALL ON TABLE intereses_mora_eca TO postgres;
GRANT SELECT ON TABLE intereses_mora_eca TO msoto;

