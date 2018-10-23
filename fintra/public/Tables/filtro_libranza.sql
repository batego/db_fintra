-- Table: filtro_libranza

-- DROP TABLE filtro_libranza;

CREATE TABLE filtro_libranza
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  identificacion character varying(15),
  primer_apellido character varying(25),
  segundo_apellido character varying(25),
  primer_nombre character varying(25),
  segundo_nombre character varying(25),
  telefono character varying(15),
  celular character varying(15),
  estado_civil character varying(1),
  fecha_nacimiento timestamp without time zone,
  id_ocupacion_laboral integer,
  fecha_ocup_laboral timestamp without time zone,
  id_configuracion_libranza integer,
  factor_seguro numeric(8,6),
  salario numeric(16,2),
  descuento_ley numeric(8,5),
  extraprima numeric(8,5),
  otros_ingresos numeric(16,2),
  valor_solicitado numeric(16,2),
  plazo integer,
  numero_solicitud integer NOT NULL DEFAULT 0,
  last_update timestamp without time zone,
  user_update character varying(10),
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10),
  valor_cuota numeric(16,2) NOT NULL DEFAULT 0,
  id_empresa_pagaduria integer,
  viable character varying(1) NOT NULL DEFAULT 'N'::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE filtro_libranza
  OWNER TO postgres;
GRANT ALL ON TABLE filtro_libranza TO postgres;
GRANT SELECT ON TABLE filtro_libranza TO msoto;



-- DROP TRIGGER insertar_pre_solicitud_libranza ON filtro_libranza;

CREATE TRIGGER insertar_pre_solicitud_libranza
		BEFORE INSERT OR UPDATE
		ON fintra.public.filtro_libranza
		FOR EACH ROW
EXECUTE PROCEDURE insertar_pre_solicitud_libranza();

