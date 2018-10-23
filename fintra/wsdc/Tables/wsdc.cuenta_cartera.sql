-- Table: wsdc.cuenta_cartera

-- DROP TABLE wsdc.cuenta_cartera;

CREATE TABLE wsdc.cuenta_cartera
(
  id serial NOT NULL,
  bloqueada boolean, -- true si esta bloqueada por autorregulación, posiblemente por que tiene un reclamo sin respuesta
  periodicidad character varying,
  comportamiento character varying, -- Cada caracter corresponde al comporamiento en un mes.
  fecha_apertura timestamp without time zone,
  fecha_vencimiento timestamp without time zone,
  numero_obligacion character varying,
  ultima_actualizacion timestamp without time zone,
  entidad character varying,
  estado character varying, -- estado basado en 48 meses de comportamiento
  estado48 character varying, -- Estado basado en hasta 48 meses de comportamiento
  tipo_obligacion character varying,
  tipo_cuenta character varying,
  garante character varying,
  forma_pago character varying,
  cod_suscriptor character varying,
  positivo_negativo character varying, -- P - cuenta en estado positivo N - cuenta en estado negativo
  oficina character varying,
  meses_permanencia smallint, -- Número de meses de la clausula de permanencia
  situacion_titular character varying,
  estado_origen character varying,
  tipo_contrato character varying,
  ejecucion_contrato smallint, -- Cantidad de meses que lleva en ejecucion el contrato, si es de termino definido
  prescripcion character varying, -- Si la cuenta fue prescrita irá una P de otra manera irá un espacio en blanco
  tipo_identificacion smallint NOT NULL,
  identificacion character varying NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying NOT NULL,
  creation_user character varying NOT NULL,
  nit_empresa character varying NOT NULL DEFAULT '8020220161'::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  estado_pago character varying(30) NOT NULL DEFAULT ''::character varying,
  estado_cuenta character varying(30) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT persona_cuenta_cartera_fk FOREIGN KEY (tipo_identificacion, identificacion, nit_empresa)
      REFERENCES wsdc.persona (tipo_identificacion, identificacion, nit_empresa) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.cuenta_cartera
  OWNER TO postgres;
COMMENT ON COLUMN wsdc.cuenta_cartera.bloqueada IS 'true si esta bloqueada por autorregulación, posiblemente por que tiene un reclamo sin respuesta';
COMMENT ON COLUMN wsdc.cuenta_cartera.comportamiento IS 'Cada caracter corresponde al comporamiento en un mes.';
COMMENT ON COLUMN wsdc.cuenta_cartera.estado IS 'estado basado en 48 meses de comportamiento';
COMMENT ON COLUMN wsdc.cuenta_cartera.estado48 IS 'Estado basado en hasta 48 meses de comportamiento';
COMMENT ON COLUMN wsdc.cuenta_cartera.positivo_negativo IS 'P - cuenta en estado positivo N - cuenta en estado negativo';
COMMENT ON COLUMN wsdc.cuenta_cartera.meses_permanencia IS 'Número de meses de la clausula de permanencia';
COMMENT ON COLUMN wsdc.cuenta_cartera.ejecucion_contrato IS 'Cantidad de meses que lleva en ejecucion el contrato, si es de termino definido';
COMMENT ON COLUMN wsdc.cuenta_cartera.prescripcion IS 'Si la cuenta fue prescrita irá una P de otra manera irá un espacio en blanco';


