-- Table: wsdc.tarjeta_credito

-- DROP TABLE wsdc.tarjeta_credito;

CREATE TABLE wsdc.tarjeta_credito
(
  id serial NOT NULL,
  estado character varying, -- Estado basado en hasta 24 meses de comportamiento
  estado48 character varying, -- Estado basado en hasta 48 meses de comportamiento.
  entidad character varying,
  ultima_actualizacion timestamp without time zone,
  numero character varying,
  fecha_apertura timestamp without time zone,
  fecha_vencimiento timestamp without time zone,
  comportamiento character varying, -- Cada caracter corresponde al comporamiento en un mes
  amparada boolean, -- Si tiene garante esta amparada.(amparada="true")
  forma_pago character varying,
  bloqueada boolean, -- true si esta bloqueada por autorregulación, posiblemente por que tiene un reclamo sin respuesta
  cod_suscriptor character varying,
  positivo_negativo character varying, -- P - estado positivo de la cuenta N - estado negativo de la cuenta
  oficina character varying,
  situacion_titular smallint,
  estado_origen character varying,
  prescripcion character varying, -- Si la cuenta fue prescrita irá una P de otra manera irá un espacio en blanco
  tipo_identificacion smallint NOT NULL,
  identificacion character varying NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying NOT NULL,
  creation_user character varying NOT NULL,
  nit_empresa character varying NOT NULL DEFAULT '8020220161'::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT persona_tarjeta_credito_fk FOREIGN KEY (tipo_identificacion, identificacion, nit_empresa)
      REFERENCES wsdc.persona (tipo_identificacion, identificacion, nit_empresa) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.tarjeta_credito
  OWNER TO postgres;
COMMENT ON COLUMN wsdc.tarjeta_credito.estado IS 'Estado basado en hasta 24 meses de comportamiento';
COMMENT ON COLUMN wsdc.tarjeta_credito.estado48 IS 'Estado basado en hasta 48 meses de comportamiento.';
COMMENT ON COLUMN wsdc.tarjeta_credito.comportamiento IS 'Cada caracter corresponde al comporamiento en un mes';
COMMENT ON COLUMN wsdc.tarjeta_credito.amparada IS 'Si tiene garante esta amparada.(amparada="true")';
COMMENT ON COLUMN wsdc.tarjeta_credito.bloqueada IS 'true si esta bloqueada por autorregulación, posiblemente por que tiene un reclamo sin respuesta';
COMMENT ON COLUMN wsdc.tarjeta_credito.positivo_negativo IS 'P - estado positivo de la cuenta N - estado negativo de la cuenta';
COMMENT ON COLUMN wsdc.tarjeta_credito.prescripcion IS 'Si la cuenta fue prescrita irá una P de otra manera irá un espacio en blanco';


