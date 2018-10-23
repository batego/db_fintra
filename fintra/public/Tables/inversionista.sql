-- Table: inversionista

-- DROP TABLE inversionista;

CREATE TABLE inversionista
(
  nit character varying(15) NOT NULL, -- nit del inversionista
  subcuenta integer NOT NULL, -- Consecutivo de la subcuenta. Si es cero es el inversionista principal.
  dstrct character varying(4) NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  nombre_subcuenta character varying NOT NULL, -- Nombre para la subcuenta del inversionista
  tasa numeric DEFAULT 0, -- tasa para la subcuenta
  ano_base integer, -- Numero de días que se toman como base para un año
  rendimiento character varying, -- rendimiento tasa días
  tipo_interes character varying, -- C si es compuesto o S si es simple
  retefuente character varying(10) DEFAULT ''::character varying, -- porcentaje de retefuente
  reteica character varying(10) DEFAULT ''::character varying, -- porcentaje de reteica
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  tasa_diaria numeric DEFAULT 0.0,
  tasa_ea numeric DEFAULT 0.0,
  tasa_nominal numeric DEFAULT 0.0,
  dias_calendario integer,
  nit_parentesco character varying(20) DEFAULT ''::character varying,
  tipo_parentesco character varying(30) DEFAULT ''::character varying,
  tipo_inversionista character varying(50) DEFAULT ''::character varying,
  pago_automatico character varying(2) DEFAULT 'N'::character varying,
  periodicidad_pago character varying(3) DEFAULT '0'::character varying,
  fecha_autorizacion_pagos timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  ano_base_tasa_diaria integer NOT NULL DEFAULT 360,
  genera_documentos character varying(2) DEFAULT 'S'::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE inversionista
  OWNER TO postgres;
GRANT ALL ON TABLE inversionista TO postgres;
GRANT SELECT ON TABLE inversionista TO msoto;
COMMENT ON TABLE inversionista
  IS 'Guarda la informacion de los inversionistas y subcuentas';
COMMENT ON COLUMN inversionista.nit IS 'nit del inversionista';
COMMENT ON COLUMN inversionista.subcuenta IS 'Consecutivo de la subcuenta. Si es cero es el inversionista principal.';
COMMENT ON COLUMN inversionista.nombre_subcuenta IS 'Nombre para la subcuenta del inversionista';
COMMENT ON COLUMN inversionista.tasa IS 'tasa para la subcuenta';
COMMENT ON COLUMN inversionista.ano_base IS 'Numero de días que se toman como base para un año';
COMMENT ON COLUMN inversionista.rendimiento IS 'rendimiento tasa días';
COMMENT ON COLUMN inversionista.tipo_interes IS 'C si es compuesto o S si es simple';
COMMENT ON COLUMN inversionista.retefuente IS 'porcentaje de retefuente';
COMMENT ON COLUMN inversionista.reteica IS 'porcentaje de reteica';


