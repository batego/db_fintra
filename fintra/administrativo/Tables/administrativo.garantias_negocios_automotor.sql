-- Table: administrativo.garantias_negocios_automotor

-- DROP TABLE administrativo.garantias_negocios_automotor;

CREATE TABLE administrativo.garantias_negocios_automotor
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  cod_neg character varying(50) NOT NULL DEFAULT ''::character varying,
  nit_cliente character varying(50) NOT NULL DEFAULT ''::character varying,
  nombre_cliente character varying(150) NOT NULL DEFAULT ''::character varying,
  tarjeta_propiedad character varying(50) NOT NULL DEFAULT ''::character varying,
  nro_chasis character varying(50) NOT NULL DEFAULT ''::character varying,
  nro_motor character varying(50) NOT NULL DEFAULT ''::character varying,
  nro_poliza character varying(50) NOT NULL DEFAULT ''::character varying,
  fecha_expedicion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  fecha_vencimineto timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  negocio_poliza character varying(50) NOT NULL DEFAULT ''::character varying,
  codigo_fasecolda character varying(30) NOT NULL DEFAULT ''::character varying,
  placa character varying(6) NOT NULL DEFAULT ''::character varying,
  marca character varying(50) NOT NULL DEFAULT ''::character varying,
  clase character varying(30) NOT NULL DEFAULT ''::character varying,
  servicio character varying(50) NOT NULL DEFAULT ''::character varying,
  referencia1 character varying(50) NOT NULL DEFAULT ''::character varying,
  referencia2 character varying(50) NOT NULL DEFAULT ''::character varying,
  referencia3 character varying(50) NOT NULL DEFAULT ''::character varying,
  pais character varying(50) NOT NULL DEFAULT ''::character varying,
  modelo character varying(50) NOT NULL DEFAULT ''::character varying,
  aseguradora character varying(50) NOT NULL DEFAULT ''::character varying,
  valor_fasecolda numeric(11,2) NOT NULL DEFAULT 0,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(20) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.garantias_negocios_automotor
  OWNER TO postgres;

