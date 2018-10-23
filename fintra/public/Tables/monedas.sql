-- Table: monedas

-- DROP TABLE monedas;

CREATE TABLE monedas
(
  codmoneda character varying(3) NOT NULL DEFAULT 'PES'::character varying,
  nommoneda character varying(15) NOT NULL DEFAULT 'PESOS'::character varying,
  inicialesmoneda character varying(2) DEFAULT 'P'::character varying, -- Iniciales de la moneda.
  rec_status character varying(1) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date character varying NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  simbolo character varying(10) NOT NULL DEFAULT ''::character varying, -- Simbolo de la moneda
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE monedas
  OWNER TO postgres;
GRANT ALL ON TABLE monedas TO postgres;
GRANT SELECT ON TABLE monedas TO msoto;
COMMENT ON TABLE monedas
  IS 'Monedas que se manejan.';
COMMENT ON COLUMN monedas.inicialesmoneda IS 'Iniciales de la moneda.';
COMMENT ON COLUMN monedas.simbolo IS 'Simbolo de la moneda';


