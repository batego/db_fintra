-- Table: ciclos_metrotel

-- DROP TABLE ciclos_metrotel;

CREATE TABLE ciclos_metrotel
(
  anio numeric NOT NULL DEFAULT 0,
  ciclo numeric NOT NULL DEFAULT 0,
  mes numeric NOT NULL DEFAULT 0,
  lectura date NOT NULL,
  liquidacion date NOT NULL,
  facturacion date NOT NULL,
  impresion date NOT NULL,
  distribucion date NOT NULL,
  primer_vencimiento date NOT NULL,
  suspension date NOT NULL,
  segundo_vencimiento date NOT NULL,
  periodo character varying,
  dias numeric NOT NULL DEFAULT 0,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE ciclos_metrotel
  OWNER TO postgres;
GRANT ALL ON TABLE ciclos_metrotel TO postgres;
GRANT SELECT ON TABLE ciclos_metrotel TO msoto;

