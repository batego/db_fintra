-- Table: tasa

-- DROP TABLE tasa;

CREATE TABLE tasa
(
  cia character varying(4) NOT NULL DEFAULT ''::character varying,
  moneda1 character varying(3) NOT NULL DEFAULT ''::character varying,
  moneda2 character varying(3) NOT NULL DEFAULT ''::character varying,
  fecha date NOT NULL DEFAULT '0099-01-01'::date,
  vlr_conver numeric(18,10) NOT NULL DEFAULT 0.0,
  compra numeric(18,10) NOT NULL DEFAULT 0.0,
  venta numeric(18,10) NOT NULL DEFAULT 0.0,
  estado character varying(1) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT (now())::timestamp without time zone,
  user_update character varying NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT (now())::timestamp without time zone,
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tasa
  OWNER TO postgres;
GRANT ALL ON TABLE tasa TO postgres;
GRANT SELECT ON TABLE tasa TO msoto;

