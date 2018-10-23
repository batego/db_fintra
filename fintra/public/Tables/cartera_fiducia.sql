-- Table: cartera_fiducia

-- DROP TABLE cartera_fiducia;

CREATE TABLE cartera_fiducia
(
  conmov character varying(20) NOT NULL DEFAULT ''::character varying,
  ctamov character varying(20) NOT NULL DEFAULT ''::character varying,
  dbamov character varying(20) NOT NULL DEFAULT ''::character varying,
  nbamov character varying(20) NOT NULL DEFAULT ''::character varying,
  termov character varying(20) NOT NULL DEFAULT ''::character varying,
  nomter character varying(160) NOT NULL DEFAULT ''::character varying,
  fecmov03 character varying(20) NOT NULL DEFAULT ''::character varying,
  fecmov04 character varying(20) NOT NULL DEFAULT ''::character varying,
  fecmov05 character varying(20) NOT NULL DEFAULT ''::character varying,
  saldo_dc01 moneda NOT NULL DEFAULT 0,
  debmov01 moneda NOT NULL DEFAULT 0,
  cremov01 moneda NOT NULL DEFAULT 0,
  id serial NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cartera_fiducia
  OWNER TO postgres;
GRANT ALL ON TABLE cartera_fiducia TO postgres;
GRANT SELECT ON TABLE cartera_fiducia TO msoto;

