-- Table: con.cuentas

-- DROP TABLE con.cuentas;

CREATE TABLE con.cuentas
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  cuenta character varying(25) NOT NULL, -- Numero de la cuenta
  nombre_largo character varying(150) NOT NULL, -- Nombre largo de la cuenta
  nombre_corto character varying(121) NOT NULL, -- Nombre corto de la cuenta
  nombre_observacion character varying(200) NOT NULL DEFAULT ''::character varying, -- Observacion de la...
  fin_periodo character(1) NOT NULL DEFAULT ''::character varying, -- Campo en blanco
  auxiliar character(1) NOT NULL DEFAULT 'N'::character varying, -- Nos dice si tiene cuenta auxiliar...
  activa character(1) NOT NULL DEFAULT 'S'::character varying, -- Nos dice si la cuenta esta activa o...
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  modulo1 character(1) NOT NULL DEFAULT 'S'::bpchar, -- Nos dice si tiene modulo1 o no
  modulo2 character(1) NOT NULL DEFAULT 'S'::bpchar, -- Nos dice si tiene modulo2 o no
  modulo3 character(1) NOT NULL DEFAULT 'S'::bpchar, -- Nos dice si tiene modulo3 o no
  modulo4 character(1) NOT NULL DEFAULT 'S'::bpchar, -- Nos dice si tiene modulo4 o no
  modulo5 character(1) NOT NULL DEFAULT 'S'::bpchar, -- Nos dice si tiene modulo5 o no
  modulo6 character(1) NOT NULL DEFAULT 'S'::bpchar, -- Nos dice si tiene modulo6 o no
  modulo7 character(1) NOT NULL DEFAULT 'S'::bpchar, -- Nos dice si tiene modulo7 o no
  modulo8 character(1) NOT NULL DEFAULT 'S'::bpchar, -- Nos dice si tiene modulo8 o no
  modulo9 character(1) NOT NULL DEFAULT 'S'::bpchar, -- Nos dice si tiene modulo9 o no
  modulo10 character(1) NOT NULL DEFAULT 'S'::bpchar, -- Nos dice si tiene modulo10 o no
  cta_dependiente character varying(25) NOT NULL DEFAULT ''::character varying, -- Numero de la cuenta del...
  nivel smallint NOT NULL DEFAULT 0, -- Nivel de la cuenta en valor...
  cta_cierre character varying(25) NOT NULL DEFAULT ''::character varying, -- Numero de la cuenta de cierre
  subledger character(1) NOT NULL DEFAULT 'N'::character varying, -- Nos dice si tiene subledger o...
  tercero character(1) NOT NULL DEFAULT 'N'::character varying, -- Nos dice si permite terceros: M=mandatorio, O=opcional, N=no
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(20) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(20) NOT NULL DEFAULT ''::character varying,
  detalle character(1) NOT NULL DEFAULT 'N'::character varying -- Nos dice si la cuenta es de ...
)
WITH (
  OIDS=TRUE
);
ALTER TABLE con.cuentas
  OWNER TO postgres;
GRANT ALL ON TABLE con.cuentas TO postgres;
GRANT SELECT ON TABLE con.cuentas TO msoto;
COMMENT ON TABLE con.cuentas
  IS 'Tabla de Cuentas';
COMMENT ON COLUMN con.cuentas.cuenta IS 'Numero de la cuenta';
COMMENT ON COLUMN con.cuentas.nombre_largo IS 'Nombre largo de la cuenta';
COMMENT ON COLUMN con.cuentas.nombre_corto IS 'Nombre corto de la cuenta';
COMMENT ON COLUMN con.cuentas.nombre_observacion IS 'Observacion de la
cuenta';
COMMENT ON COLUMN con.cuentas.fin_periodo IS 'Campo en blanco';
COMMENT ON COLUMN con.cuentas.auxiliar IS 'Nos dice si tiene cuenta auxiliar
o no';
COMMENT ON COLUMN con.cuentas.activa IS 'Nos dice si la cuenta esta activa o
no';
COMMENT ON COLUMN con.cuentas.modulo1 IS 'Nos dice si tiene modulo1 o no';
COMMENT ON COLUMN con.cuentas.modulo2 IS 'Nos dice si tiene modulo2 o no';
COMMENT ON COLUMN con.cuentas.modulo3 IS 'Nos dice si tiene modulo3 o no';
COMMENT ON COLUMN con.cuentas.modulo4 IS 'Nos dice si tiene modulo4 o no';
COMMENT ON COLUMN con.cuentas.modulo5 IS 'Nos dice si tiene modulo5 o no';
COMMENT ON COLUMN con.cuentas.modulo6 IS 'Nos dice si tiene modulo6 o no';
COMMENT ON COLUMN con.cuentas.modulo7 IS 'Nos dice si tiene modulo7 o no';
COMMENT ON COLUMN con.cuentas.modulo8 IS 'Nos dice si tiene modulo8 o no';
COMMENT ON COLUMN con.cuentas.modulo9 IS 'Nos dice si tiene modulo9 o no';
COMMENT ON COLUMN con.cuentas.modulo10 IS 'Nos dice si tiene modulo10 o no';
COMMENT ON COLUMN con.cuentas.cta_dependiente IS 'Numero de la cuenta del
padre';
COMMENT ON COLUMN con.cuentas.nivel IS 'Nivel de la cuenta en valor
numerico';
COMMENT ON COLUMN con.cuentas.cta_cierre IS 'Numero de la cuenta de cierre';
COMMENT ON COLUMN con.cuentas.subledger IS 'Nos dice si tiene subledger o
no';
COMMENT ON COLUMN con.cuentas.tercero IS 'Nos dice si permite terceros: M=mandatorio, O=opcional, N=no';
COMMENT ON COLUMN con.cuentas.detalle IS 'Nos dice si la cuenta es de 
detalle o no';


