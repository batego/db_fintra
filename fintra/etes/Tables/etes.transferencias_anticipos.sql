-- Table: etes.transferencias_anticipos

-- DROP TABLE etes.transferencias_anticipos;

CREATE TABLE etes.transferencias_anticipos
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  periodo character varying(6) NOT NULL DEFAULT ''::character varying,
  id_transportadora integer NOT NULL,
  id_manifiesto_carga integer NOT NULL,
  planilla character varying(20) NOT NULL DEFAULT ''::character varying,
  reanticipo character varying(1) NOT NULL DEFAULT 'N'::character varying,
  comision_bancaria numeric(11,2) NOT NULL DEFAULT 0,
  valor_comision_bancaria numeric(11,2) NOT NULL DEFAULT 0,
  valor_transferencia numeric(11,2) NOT NULL DEFAULT 0,
  transferido character varying(1) NOT NULL DEFAULT 'N'::character varying,
  fecha_transferencia timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  banco_transferencia character varying(50) NOT NULL DEFAULT ''::character varying,
  cuenta_transferencia character varying(100) NOT NULL DEFAULT ''::character varying,
  tipo_cuenta_transferencia character varying(50) NOT NULL DEFAULT ''::character varying,
  banco character varying(100) NOT NULL DEFAULT ''::character varying,
  sucursal character varying(100) NOT NULL DEFAULT ''::character varying,
  cedula_titular_cuenta character varying(100) NOT NULL DEFAULT ''::character varying,
  nombre_titular_cuenta character varying(200) NOT NULL DEFAULT ''::character varying,
  tipo_cuenta character varying(50) NOT NULL DEFAULT ''::character varying,
  no_cuenta character varying(100) NOT NULL DEFAULT ''::character varying,
  numero_egreso character varying(20) NOT NULL DEFAULT ''::character varying,
  valor_egreso numeric(11,2) NOT NULL DEFAULT 0,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_transferenciasanticipos FOREIGN KEY (id_transportadora)
      REFERENCES etes.transportadoras (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE etes.transferencias_anticipos
  OWNER TO postgres;

