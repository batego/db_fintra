-- Table: nit

-- DROP TABLE nit;

CREATE TABLE nit
(
  estado character(1) NOT NULL DEFAULT 'A'::bpchar,
  cedula character varying(15) NOT NULL,
  id_mims character varying(10) NOT NULL DEFAULT ''::character varying,
  nombre character varying(160) NOT NULL DEFAULT ''::character varying,
  direccion character varying(160) NOT NULL DEFAULT ''::character varying,
  codciu character varying(10) NOT NULL DEFAULT ''::character varying,
  coddpto character varying(10) NOT NULL DEFAULT 'ATL'::character varying,
  codpais character varying(10) NOT NULL DEFAULT ''::character varying,
  telefono character varying(70) NOT NULL DEFAULT ''::character varying,
  celular character varying(15) NOT NULL DEFAULT ''::character varying,
  e_mail character varying(60) NOT NULL DEFAULT ''::character varying,
  fechaultact timestamp without time zone DEFAULT now(),
  usuario character varying(50) NOT NULL DEFAULT ''::character varying,
  fechacrea timestamp without time zone DEFAULT now(),
  usuariocrea character varying(50) NOT NULL DEFAULT ''::character varying,
  sexo character varying(1) NOT NULL DEFAULT ''::character varying, -- Genero del nit
  fechanac date NOT NULL DEFAULT '0099-01-01'::date, -- Fecha de Nacimiento
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  telefono1 character varying(20) NOT NULL DEFAULT ''::character varying,
  cod_cia character varying(15) NOT NULL DEFAULT ''::character varying,
  cargo character varying(30) NOT NULL DEFAULT ''::character varying,
  ubicacion character varying(10) NOT NULL DEFAULT ''::character varying,
  cia character varying(15) NOT NULL DEFAULT ''::character varying,
  ref1 character varying(30) NOT NULL DEFAULT ''::character varying,
  tipo_iden character varying(5) NOT NULL DEFAULT ''::character varying,
  observacion text NOT NULL DEFAULT ''::text,
  nombre1 character varying(25) NOT NULL DEFAULT ''::character varying,
  nombre2 character varying(25) NOT NULL DEFAULT ''::character varying,
  apellido1 character varying(30) NOT NULL DEFAULT ''::character varying,
  apellido2 character varying(30) NOT NULL DEFAULT ''::character varying,
  est_civil character varying(2) NOT NULL DEFAULT ''::character varying,
  lugarnac character varying(4) NOT NULL DEFAULT ''::character varying,
  barrio character varying(50) NOT NULL DEFAULT ''::character varying,
  libmilitar character varying(15) NOT NULL DEFAULT ''::character varying,
  expced character varying(4) NOT NULL DEFAULT ''::character varying,
  senalparti character varying(50) NOT NULL DEFAULT ''::character varying,
  t_libmilitar character varying(1) NOT NULL DEFAULT ''::character varying,
  t_cedula character varying(1) NOT NULL DEFAULT ''::character varying,
  nemotecnico character varying(10) DEFAULT ''::character varying,
  veto character varying(1) NOT NULL DEFAULT ''::character varying, -- Id. de vetos
  clasificacion character varying(10) NOT NULL DEFAULT '0000000000'::character varying,
  aprobado character varying NOT NULL DEFAULT 'N'::character varying, -- Indica si el registro esta aprobado o no.
  usuario_aprobacion character varying(10) NOT NULL DEFAULT ''::character varying, -- Registra el usuario que aprobo el registro.
  fecha_aprobacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Registra la fecha en que se aprobo el registro.
  fecha_envio_ws timestamp without time zone, -- fecha en la que se envio por ultima vez el registro del servidor al cliente  a traves del web service
  fecha_anulacion timestamp without time zone, -- fecha en la que se anula el registro
  dtsp character varying(1) DEFAULT ''::character varying,
  direccion_oficina character varying(160) NOT NULL DEFAULT ''::character varying, -- Direccion de la oficina. Agregado para el programa de captaciones.
  e_mail2 character varying(60) NOT NULL DEFAULT ''::character varying, -- email secundario. Agregado para el programa de captaciones.
  observaciones character varying(500)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE nit
  OWNER TO postgres;
GRANT ALL ON TABLE nit TO postgres;
GRANT SELECT ON TABLE nit TO consulta2;
GRANT SELECT ON TABLE nit TO consulta;
GRANT ALL ON TABLE nit TO fintravaloressa;
GRANT SELECT ON TABLE nit TO msoto;
COMMENT ON COLUMN nit.sexo IS 'Genero del nit';
COMMENT ON COLUMN nit.fechanac IS 'Fecha de Nacimiento';
COMMENT ON COLUMN nit.veto IS 'Id. de vetos';
COMMENT ON COLUMN nit.aprobado IS 'Indica si el registro esta aprobado o no.';
COMMENT ON COLUMN nit.usuario_aprobacion IS 'Registra el usuario que aprobo el registro.';
COMMENT ON COLUMN nit.fecha_aprobacion IS 'Registra la fecha en que se aprobo el registro.';
COMMENT ON COLUMN nit.fecha_envio_ws IS 'fecha en la que se envio por ultima vez el registro del servidor al cliente  a traves del web service';
COMMENT ON COLUMN nit.fecha_anulacion IS 'fecha en la que se anula el registro';
COMMENT ON COLUMN nit.direccion_oficina IS 'Direccion de la oficina. Agregado para el programa de captaciones.';
COMMENT ON COLUMN nit.e_mail2 IS 'email secundario. Agregado para el programa de captaciones.';


-- Trigger: h_cambios_dir_clientes on nit

-- DROP TRIGGER h_cambios_dir_clientes ON nit;

CREATE TRIGGER h_cambios_dir_clientes
  AFTER UPDATE
  ON nit
  FOR EACH ROW
  EXECUTE PROCEDURE insert_h_cambios_dir_cliente();


