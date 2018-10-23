-- Table: fin.bancostransferencias_tsp_erased

-- DROP TABLE fin.bancostransferencias_tsp_erased;

CREATE TABLE fin.bancostransferencias_tsp_erased
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
  e_mail character varying(45) NOT NULL DEFAULT ''::character varying, -- Correo Electronico Del Cliente de FINTRA
  estado_aprobacion character varying(1) DEFAULT 'N'::character varying, -- navi
  fecha_envio_ws timestamp without time zone,
  creation_date_real timestamp without time zone DEFAULT now(), -- fecha de creacion real de este registro
  pk_novedad integer NOT NULL, -- llave primaria de esta tabla
  fecha_anulacion timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone -- fecha en la que se borra el registro original
)
WITH (
  OIDS=TRUE
);
ALTER TABLE fin.bancostransferencias_tsp_erased
  OWNER TO postgres;
COMMENT ON COLUMN fin.bancostransferencias_tsp_erased.dstrct IS 'El distrito';
COMMENT ON COLUMN fin.bancostransferencias_tsp_erased.idmims IS 'Codigo en mims del beneficiario';
COMMENT ON COLUMN fin.bancostransferencias_tsp_erased.nit IS 'Nit del beneficiario';
COMMENT ON COLUMN fin.bancostransferencias_tsp_erased.banco IS 'Banco de la transferencia';
COMMENT ON COLUMN fin.bancostransferencias_tsp_erased.sucursal IS 'Sucursal del banco de la transferencia';
COMMENT ON COLUMN fin.bancostransferencias_tsp_erased.cuenta IS 'Cuenta de la transferencia';
COMMENT ON COLUMN fin.bancostransferencias_tsp_erased.tipo_cuenta IS 'Tipo de cuenta';
COMMENT ON COLUMN fin.bancostransferencias_tsp_erased.nombre_cuenta IS 'Nombre de la cuenta';
COMMENT ON COLUMN fin.bancostransferencias_tsp_erased.cedula_cuenta IS 'Cedula de la cuenta';
COMMENT ON COLUMN fin.bancostransferencias_tsp_erased.secuencia IS 'La secuencia de la cuenta para el propietario';
COMMENT ON COLUMN fin.bancostransferencias_tsp_erased.primaria IS 'Establece la cuenta primaria del propietario';
COMMENT ON COLUMN fin.bancostransferencias_tsp_erased.e_mail IS 'Correo Electronico Del Cliente de FINTRA';
COMMENT ON COLUMN fin.bancostransferencias_tsp_erased.estado_aprobacion IS 'navi';
COMMENT ON COLUMN fin.bancostransferencias_tsp_erased.creation_date_real IS 'fecha de creacion real de este registro';
COMMENT ON COLUMN fin.bancostransferencias_tsp_erased.pk_novedad IS 'llave primaria de esta tabla';
COMMENT ON COLUMN fin.bancostransferencias_tsp_erased.fecha_anulacion IS 'fecha en la que se borra el registro original';


