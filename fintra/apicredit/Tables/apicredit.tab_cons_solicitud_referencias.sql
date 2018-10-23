-- Table: apicredit.tab_cons_solicitud_referencias

-- DROP TABLE apicredit.tab_cons_solicitud_referencias;

CREATE TABLE apicredit.tab_cons_solicitud_referencias
(
  id serial NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  numero_solicitud integer NOT NULL,
  tipo character varying(1) NOT NULL DEFAULT 'S'::character varying,
  tipo_referencia character varying(6) NOT NULL DEFAULT ''::character varying,
  secuencia integer NOT NULL DEFAULT 0,
  primer_apellido character varying(25) NOT NULL DEFAULT ''::character varying,
  segundo_apellido character varying(25) NOT NULL DEFAULT ''::character varying,
  primer_nombre character varying(25) NOT NULL DEFAULT ''::character varying,
  segundo_nombre character varying(25) NOT NULL DEFAULT ''::character varying,
  parentesco character varying(15) NOT NULL DEFAULT ''::character varying,
  telefono1 character varying(15) NOT NULL DEFAULT ''::character varying,
  celular character varying(15) NOT NULL DEFAULT ''::character varying,
  direccion character varying(160) NOT NULL DEFAULT ''::character varying,
  departamento character varying(6) NOT NULL DEFAULT ''::character varying,
  ciudad character varying(6) NOT NULL DEFAULT ''::character varying,
  creation_user character varying(50) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE apicredit.tab_cons_solicitud_referencias
  OWNER TO postgres;

