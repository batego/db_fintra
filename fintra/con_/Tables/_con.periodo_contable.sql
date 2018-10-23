-- Table: con.periodo_contable

-- DROP TABLE con.periodo_contable;

CREATE TABLE con.periodo_contable
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  anio character varying(4) NOT NULL DEFAULT ''::character varying, -- Anio del periodo contable
  mes character varying(2) NOT NULL DEFAULT ''::character varying, -- Mes del periodo contable
  ac character varying(1) NOT NULL DEFAULT ''::character varying, -- Indica si el periodo contable esta Abierto (A) o Cerrado (C)
  iva character varying(1) NOT NULL DEFAULT 'N'::character varying, -- Indica si tiene (S) o no (N) IVA
  fec_pre_iva date NOT NULL DEFAULT '0099-01-01'::date, -- Fecha de presentancion del IVA
  retencion character varying(1) NOT NULL DEFAULT 'N'::character varying, -- Indica si tiene (S) o no (N) Retencion
  fec_pre_retencion date NOT NULL DEFAULT '0099-01-01'::date, -- Fecha de presentancion de la Retencion
  comercio character varying(1) NOT NULL DEFAULT 'N'::character varying, -- Indica si tiene (S) o no (N) Comercio
  fec_pre_comercio date NOT NULL DEFAULT '0099-01-01'::date, -- Fecha de presentancion de Comercio
  renta character varying(1) NOT NULL DEFAULT 'N'::character varying, -- Indica si tiene (S) o no (N) renta
  fec_pre_renta date NOT NULL DEFAULT '0099-01-01'::date, -- Fecha de presentancion de la Renta
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.periodo_contable
  OWNER TO postgres;
GRANT ALL ON TABLE con.periodo_contable TO postgres;
GRANT SELECT ON TABLE con.periodo_contable TO msoto;
COMMENT ON TABLE con.periodo_contable
  IS 'Tabla para almacenar relacion de documentos y codigo de manejo contable.';
COMMENT ON COLUMN con.periodo_contable.anio IS 'Anio del periodo contable';
COMMENT ON COLUMN con.periodo_contable.mes IS 'Mes del periodo contable';
COMMENT ON COLUMN con.periodo_contable.ac IS 'Indica si el periodo contable esta Abierto (A) o Cerrado (C)';
COMMENT ON COLUMN con.periodo_contable.iva IS 'Indica si tiene (S) o no (N) IVA';
COMMENT ON COLUMN con.periodo_contable.fec_pre_iva IS 'Fecha de presentancion del IVA';
COMMENT ON COLUMN con.periodo_contable.retencion IS 'Indica si tiene (S) o no (N) Retencion';
COMMENT ON COLUMN con.periodo_contable.fec_pre_retencion IS 'Fecha de presentancion de la Retencion';
COMMENT ON COLUMN con.periodo_contable.comercio IS 'Indica si tiene (S) o no (N) Comercio';
COMMENT ON COLUMN con.periodo_contable.fec_pre_comercio IS 'Fecha de presentancion de Comercio';
COMMENT ON COLUMN con.periodo_contable.renta IS 'Indica si tiene (S) o no (N) renta';
COMMENT ON COLUMN con.periodo_contable.fec_pre_renta IS 'Fecha de presentancion de la Renta';


