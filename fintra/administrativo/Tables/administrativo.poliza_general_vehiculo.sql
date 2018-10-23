-- Table: administrativo.poliza_general_vehiculo

-- DROP TABLE administrativo.poliza_general_vehiculo;

CREATE TABLE administrativo.poliza_general_vehiculo
(
  id serial NOT NULL,
  id_config_poliza integer,
  negocio_vehiculo character varying(15) NOT NULL DEFAULT ''::character varying,
  nombre_cliente character varying(100) NOT NULL DEFAULT ''::character varying,
  cedula character varying(15) NOT NULL DEFAULT ''::character varying,
  afiliado character varying(100) NOT NULL DEFAULT ''::character varying,
  placa character varying(6) NOT NULL DEFAULT ''::character varying,
  servicio character varying(20) NOT NULL DEFAULT ''::character varying,
  vlr_credito numeric(11,2) NOT NULL DEFAULT 0,
  vlr_vehiculo_fasecolda numeric(11,2) NOT NULL DEFAULT 0,
  fecha_actualizacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  negocio_seguro character varying(50) NOT NULL DEFAULT ''::character varying,
  vlr_negocio_seguro numeric(11,2) NOT NULL DEFAULT 0,
  fecha_inicio timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  fecha_fin timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  codigo_fasecolda character varying(30) NOT NULL DEFAULT ''::character varying,
  tipo character varying(20) NOT NULL DEFAULT ''::character varying,
  marc_proc_juridic character varying(1) NOT NULL DEFAULT 'N'::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.poliza_general_vehiculo
  OWNER TO postgres;

