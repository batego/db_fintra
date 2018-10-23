-- Table: convenios_cargos_fijos

-- DROP TABLE convenios_cargos_fijos;

CREATE TABLE convenios_cargos_fijos
(
  id serial NOT NULL,
  dstrct character varying NOT NULL DEFAULT 'FINV'::character varying,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  id_convenio integer NOT NULL,
  nombre_concepto character varying(100) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(100) NOT NULL DEFAULT ''::character varying,
  prefijo character varying(10) NOT NULL DEFAULT ''::character varying,
  tipodoc character varying(10) NOT NULL DEFAULT ''::character varying,
  hc_diferido character varying(10) NOT NULL DEFAULT ''::character varying,
  cuenta_diferido character varying(30) NOT NULL DEFAULT ''::character varying,
  cuenta character varying(30) NOT NULL DEFAULT ''::character varying,
  tipo_calculo character varying(1) NOT NULL DEFAULT ''::character varying,
  valor numeric(11,2),
  activo boolean NOT NULL DEFAULT true,
  aplica_iva character varying(1) NOT NULL DEFAULT 'N'::character varying,
  cuenta_iva character varying(30) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(20) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(20) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_idconvenio FOREIGN KEY (id_convenio)
      REFERENCES convenios (id_convenio) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE convenios_cargos_fijos
  OWNER TO postgres;

