-- Table: administrativo.estado_cuenta_detalle

-- DROP TABLE administrativo.estado_cuenta_detalle;

CREATE TABLE administrativo.estado_cuenta_detalle
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT 'FINV'::character varying,
  cod_estado_cuenta character varying NOT NULL DEFAULT ''::character varying,
  factura character varying NOT NULL DEFAULT ''::character varying,
  fecha timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  convenio character varying NOT NULL DEFAULT ''::character varying,
  item character varying NOT NULL DEFAULT ''::character varying,
  dias_mora integer,
  saldo_inicial numeric,
  valor_cuota numeric,
  valor_saldo_cuota numeric,
  capital numeric,
  interes numeric,
  seguro numeric,
  mipyme numeric,
  cuota_manejo numeric,
  interes_mora numeric,
  gac numeric,
  valor_saldo_global_cuota numeric,
  estado character varying NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.estado_cuenta_detalle
  OWNER TO postgres;

