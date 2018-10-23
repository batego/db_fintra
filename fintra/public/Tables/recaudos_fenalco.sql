-- Table: recaudos_fenalco

-- DROP TABLE recaudos_fenalco;

CREATE TABLE recaudos_fenalco
(
  reg_status text DEFAULT ''::text,
  facturas text,
  fecha date NOT NULL,
  valor numeric NOT NULL DEFAULT 0,
  intereses numeric DEFAULT 0,
  banco text NOT NULL,
  account_number text NOT NULL,
  cuenta text NOT NULL,
  procesado text DEFAULT 'NO'::text,
  cod text,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE recaudos_fenalco
  OWNER TO postgres;
GRANT ALL ON TABLE recaudos_fenalco TO postgres;
GRANT SELECT ON TABLE recaudos_fenalco TO msoto;

