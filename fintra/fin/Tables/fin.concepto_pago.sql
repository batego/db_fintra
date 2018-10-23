-- Table: fin.concepto_pago

-- DROP TABLE fin.concepto_pago;

CREATE TABLE fin.concepto_pago
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  codigo integer NOT NULL DEFAULT nextval('fin.concepto_pago_codigo_seq1'::regclass), -- CÃƒÆ’Ã‚Â³digo del concepto
  descripcion text DEFAULT ''::character varying, -- Nombre del concepto
  controlparam text DEFAULT ''::character varying, -- ParÃƒÆ’Ã‚Â¡metros de ejecuciÃƒÆ’Ã‚Â³n utilizados para cargar el objeto
  codpadre character varying(12) NOT NULL DEFAULT ''::character varying, -- CÃƒÆ’Ã‚Â³digo del padre
  orden numeric(4,0) NOT NULL DEFAULT 0, -- Orden de secuencia
  nivel numeric(4,0) NOT NULL DEFAULT 0, -- Nivel en que se encuentra
  idfolder character varying(1) NOT NULL DEFAULT ''::character varying, -- Es folder o no
  referencia1 character varying(45) DEFAULT ''::character varying, -- Referencias
  referencia2 character varying(45) DEFAULT ''::character varying, -- Referencias
  referencia3 character varying(45) DEFAULT ''::character varying, -- Referencias
  referencia4 character varying(45) DEFAULT ''::character varying, -- Referencias
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE fin.concepto_pago
  OWNER TO postgres;
COMMENT ON TABLE fin.concepto_pago
  IS 'Tabla que almacena los conceptos de pago';
COMMENT ON COLUMN fin.concepto_pago.codigo IS 'CÃƒÆ’Ã‚Â³digo del concepto';
COMMENT ON COLUMN fin.concepto_pago.descripcion IS 'Nombre del concepto';
COMMENT ON COLUMN fin.concepto_pago.controlparam IS 'ParÃƒÆ’Ã‚Â¡metros de ejecuciÃƒÆ’Ã‚Â³n utilizados para cargar el objeto';
COMMENT ON COLUMN fin.concepto_pago.codpadre IS 'CÃƒÆ’Ã‚Â³digo del padre';
COMMENT ON COLUMN fin.concepto_pago.orden IS 'Orden de secuencia';
COMMENT ON COLUMN fin.concepto_pago.nivel IS 'Nivel en que se encuentra';
COMMENT ON COLUMN fin.concepto_pago.idfolder IS 'Es folder o no';
COMMENT ON COLUMN fin.concepto_pago.referencia1 IS 'Referencias';
COMMENT ON COLUMN fin.concepto_pago.referencia2 IS 'Referencias';
COMMENT ON COLUMN fin.concepto_pago.referencia3 IS 'Referencias';
COMMENT ON COLUMN fin.concepto_pago.referencia4 IS 'Referencias';


