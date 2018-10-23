-- Table: fin.bancostransferencias

-- DROP TABLE fin.bancostransferencias;

CREATE TABLE fin.bancostransferencias
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying, -- El distrito
  idmims character varying(6) NOT NULL DEFAULT ''::character varying, -- Codigo en mims del beneficiario
  nit character varying(15) NOT NULL DEFAULT ''::character varying, -- Nit del beneficiario
  banco character varying(30) NOT NULL DEFAULT ''::character varying, -- Banco de la transferencia
  sucursal character varying(30) NOT NULL DEFAULT ''::character varying, -- Sucursal del banco de la transferencia
  cuenta character varying(20) NOT NULL DEFAULT ''::character varying, -- Cuenta de la transferencia
  tipo_cuenta character varying(15) NOT NULL DEFAULT ''::character varying, -- Tipo de cuenta
  nombre_cuenta character varying(100) NOT NULL DEFAULT ''::character varying, -- Nombre de la cuenta
  cedula_cuenta character varying(15) NOT NULL DEFAULT ''::character varying, -- Cedula de la cuenta
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  secuencia smallint NOT NULL DEFAULT 1, -- La secuencia de la cuenta para el propietario
  primaria character varying(1) NOT NULL DEFAULT 'N'::character varying, -- Establece la cuenta primaria del propietario
  e_mail character varying(45) NOT NULL DEFAULT ''::character varying, -- Correo Electronico Del ...
  estado_aprobacion character varying(1) DEFAULT 'N'::character varying, -- navi
  creation_date_real timestamp without time zone,
  pk_novedad integer,
  fecha_anulacion timestamp without time zone,
  fecha_envio_ws timestamp without time zone
)
WITH (
  OIDS=TRUE
);
ALTER TABLE fin.bancostransferencias
  OWNER TO postgres;
COMMENT ON COLUMN fin.bancostransferencias.dstrct IS 'El distrito';
COMMENT ON COLUMN fin.bancostransferencias.idmims IS 'Codigo en mims del beneficiario';
COMMENT ON COLUMN fin.bancostransferencias.nit IS 'Nit del beneficiario';
COMMENT ON COLUMN fin.bancostransferencias.banco IS 'Banco de la transferencia';
COMMENT ON COLUMN fin.bancostransferencias.sucursal IS 'Sucursal del banco de la transferencia';
COMMENT ON COLUMN fin.bancostransferencias.cuenta IS 'Cuenta de la transferencia';
COMMENT ON COLUMN fin.bancostransferencias.tipo_cuenta IS 'Tipo de cuenta';
COMMENT ON COLUMN fin.bancostransferencias.nombre_cuenta IS 'Nombre de la cuenta';
COMMENT ON COLUMN fin.bancostransferencias.cedula_cuenta IS 'Cedula de la cuenta';
COMMENT ON COLUMN fin.bancostransferencias.secuencia IS 'La secuencia de la cuenta para el propietario';
COMMENT ON COLUMN fin.bancostransferencias.primaria IS 'Establece la cuenta primaria del propietario';
COMMENT ON COLUMN fin.bancostransferencias.e_mail IS 'Correo Electronico Del 
Cliente de FINTRA';
COMMENT ON COLUMN fin.bancostransferencias.estado_aprobacion IS 'navi';


