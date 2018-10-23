-- Table: administrativo.estado_cuenta

-- DROP TABLE administrativo.estado_cuenta;

CREATE TABLE administrativo.estado_cuenta
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT 'FINV'::character varying,
  cod_estado_cuenta character varying NOT NULL DEFAULT ''::character varying,
  cliente character varying NOT NULL DEFAULT ''::character varying,
  negocio character varying NOT NULL DEFAULT ''::character varying,
  valorcapital numeric,
  interes numeric,
  totalseguro numeric,
  totalgastocobranza numeric,
  totalixm numeric,
  totalmipyme numeric,
  cuotasvencidas numeric,
  valorcuotaactual numeric,
  capitalfuturo numeric,
  interescuotafutura numeric,
  cuotaadminfuturo numeric,
  cuotaspendientes character varying NOT NULL DEFAULT ''::character varying,
  diasmora numeric,
  catfuturo numeric,
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.estado_cuenta
  OWNER TO postgres;

