-- Table: administrativo.funcio_apot

-- DROP TABLE administrativo.funcio_apot;

CREATE TABLE administrativo.funcio_apot
(
  funcio_identific_b integer NOT NULL,
  funcio_digicheq__b numeric(1,0),
  funcio_codigo____tit____b character varying(4),
  funcio_nombcort__b character varying(32),
  funcio_apellidos_b character varying(32),
  funcio_nombexte__b character varying(64),
  funcio_codigo____tt_____b character varying(4),
  funcio_direccion_b character varying(64),
  funcio_codigo____ciudad_b character varying(8),
  funcio_telefono1_b character varying(16),
  funcio_codigo____cargo__b character varying(16),
  funcio_fechorcre_b timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  funcio_autocrea__b character varying(16),
  funcio_fehoulmo__b timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  funcio_autultmod_b character varying(16),
  funcio_codigo____usuari_b character varying(16),
  funcio_codigo____cu_____b character varying(16),
  funcio_indicont__b character varying(1) DEFAULT 'N'::character varying,
  funcio_usupromak_b character varying(30),
  funcio_email_____b character varying(64),
  funcio_codigo____cu_____pad_b character varying(16),
  procesado character varying(1) DEFAULT 'N'::character varying,
  num_proceso character varying(50) DEFAULT ''::character varying,
  creation_date timestamp without time zone DEFAULT (now())::timestamp without time zone
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.funcio_apot
  OWNER TO postgres;

