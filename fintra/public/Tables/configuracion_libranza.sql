-- Table: configuracion_libranza

-- DROP TABLE configuracion_libranza;

CREATE TABLE configuracion_libranza
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  nombre_convenio_pagaduria character varying(300) NOT NULL DEFAULT ''::character varying,
  id_convenio integer,
  id_pagaduria integer,
  id_ocupacion_laboral integer,
  tasa numeric(10,3) NOT NULL,
  tasa_mensual numeric(10,3) NOT NULL,
  tasa_renovacion numeric(10,3) NOT NULL,
  monto_minimo numeric(11,2) NOT NULL DEFAULT 0,
  monto_maximo numeric(11,2) NOT NULL DEFAULT 0,
  plazo_minimo numeric(11,2) NOT NULL DEFAULT 0,
  plazo_maximo numeric(11,2) NOT NULL DEFAULT 0,
  colchon numeric(11,2) NOT NULL DEFAULT 0,
  factor_seguro numeric(11,9) NOT NULL DEFAULT 0,
  porcentaje_descuento numeric(11,2) NOT NULL DEFAULT 0,
  dia_entrega_novedades character varying(2) NOT NULL DEFAULT ''::character varying,
  dia_pago character varying(2) NOT NULL DEFAULT ''::character varying,
  periodo_gracia integer NOT NULL DEFAULT 0,
  requiere_anexo character(1) NOT NULL DEFAULT 'N'::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE configuracion_libranza
  OWNER TO postgres;
GRANT ALL ON TABLE configuracion_libranza TO postgres;
GRANT SELECT ON TABLE configuracion_libranza TO msoto;

