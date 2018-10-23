-- Table: fin.credito_bancario

-- DROP TABLE fin.credito_bancario;

CREATE TABLE fin.credito_bancario
(
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  nit_banco character varying(15) NOT NULL, -- Nit del banco que otorga el crédito
  documento character varying(30) NOT NULL, -- Numero de documento que asigna el banco
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  ref_credito character varying(30) NOT NULL, -- Referencia del crédito. ORDINARIO, TESORERIA o FACTORING
  linea_credito character varying NOT NULL, -- Linea de crédito del banco con la que se realiza el crédito
  dtf numeric NOT NULL, -- DTF del dia en que se crea el crédito
  puntos_basicos numeric NOT NULL, -- Puntos basicos
  periodicidad smallint, -- mensual, bimensual, etc. Tablagen CB_PERIODI
  vlr_credito double precision NOT NULL, -- Valor del crédito
  fecha_inicial date NOT NULL, -- Fecha de inicio del crédito
  fecha_vencimiento date NOT NULL, -- Fecha de vencimiento del crédito
  cupo character varying(30) NOT NULL, -- Linea de crédito: cupo de negocio
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  tasa_cobrada numeric, -- Tasa que cobró el banco en caso de que sea un credito por factoring
  vlr_interes double precision, -- Valor de los intereses cobrados por el banco en caso de ser un credito por factoring
  tipo_dtf character varying(5) NOT NULL DEFAULT ''::character varying,
  hc character varying(6),
  cuenta character varying(25),
  procesado_apo character varying(1) NOT NULL DEFAULT 'N'::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fin.credito_bancario
  OWNER TO postgres;
COMMENT ON COLUMN fin.credito_bancario.nit_banco IS 'Nit del banco que otorga el crédito';
COMMENT ON COLUMN fin.credito_bancario.documento IS 'Numero de documento que asigna el banco';
COMMENT ON COLUMN fin.credito_bancario.ref_credito IS 'Referencia del crédito. ORDINARIO, TESORERIA o FACTORING';
COMMENT ON COLUMN fin.credito_bancario.linea_credito IS 'Linea de crédito del banco con la que se realiza el crédito';
COMMENT ON COLUMN fin.credito_bancario.dtf IS 'DTF del dia en que se crea el crédito';
COMMENT ON COLUMN fin.credito_bancario.puntos_basicos IS 'Puntos basicos';
COMMENT ON COLUMN fin.credito_bancario.periodicidad IS 'mensual, bimensual, etc. Tablagen CB_PERIODI';
COMMENT ON COLUMN fin.credito_bancario.vlr_credito IS 'Valor del crédito';
COMMENT ON COLUMN fin.credito_bancario.fecha_inicial IS 'Fecha de inicio del crédito';
COMMENT ON COLUMN fin.credito_bancario.fecha_vencimiento IS 'Fecha de vencimiento del crédito';
COMMENT ON COLUMN fin.credito_bancario.cupo IS 'Linea de crédito: cupo de negocio';
COMMENT ON COLUMN fin.credito_bancario.tasa_cobrada IS 'Tasa que cobró el banco en caso de que sea un credito por factoring';
COMMENT ON COLUMN fin.credito_bancario.vlr_interes IS 'Valor de los intereses cobrados por el banco en caso de ser un credito por factoring';


