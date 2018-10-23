-- Table: usuar_72004745

-- DROP TABLE usuar_72004745;

CREATE TABLE usuar_72004745
(
  estado character(1),
  cedula character varying(15),
  id_mims character varying(10),
  nombre character varying(160),
  direccion character varying(160),
  codciu character varying(10),
  coddpto character varying(10),
  codpais character varying(10),
  telefono character varying(70),
  celular character varying(15),
  e_mail character varying(60),
  fechaultact timestamp without time zone,
  usuario character varying(50),
  fechacrea timestamp without time zone,
  usuariocrea character varying(50),
  sexo character varying(1),
  fechanac date,
  base character varying(3),
  telefono1 character varying(20),
  cod_cia character varying(15),
  cargo character varying(30),
  ubicacion character varying(10),
  cia character varying(15),
  ref1 character varying(30),
  tipo_iden character varying(5),
  observacion text,
  nombre1 character varying(25),
  nombre2 character varying(25),
  apellido1 character varying(30),
  apellido2 character varying(30),
  est_civil character varying(2),
  lugarnac character varying(4),
  barrio character varying(50),
  libmilitar character varying(15),
  expced character varying(4),
  senalparti character varying(50),
  t_libmilitar character varying(1),
  t_cedula character varying(1),
  nemotecnico character varying(10),
  veto character varying(1),
  clasificacion character varying(10),
  aprobado character varying,
  usuario_aprobacion character varying(10),
  fecha_aprobacion timestamp without time zone,
  fecha_envio_ws timestamp without time zone,
  fecha_anulacion timestamp without time zone,
  dtsp character varying(1),
  direccion_oficina character varying(160),
  e_mail2 character varying(60),
  observaciones character varying(500)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE usuar_72004745
  OWNER TO postgres;

