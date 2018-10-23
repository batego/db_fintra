-- Table: apicredit.tipificacion_archivos_app

-- DROP TABLE apicredit.tipificacion_archivos_app;

CREATE TABLE apicredit.tipificacion_archivos_app
(
  id serial NOT NULL,
  reg_status character(1) NOT NULL DEFAULT ''::bpchar,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_unid_negocio integer NOT NULL,
  codigo character varying(4) NOT NULL DEFAULT ''::character varying,
  nombre_categoria character varying(200) NOT NULL DEFAULT ''::character varying,
  nombre_archivo character varying(200) NOT NULL DEFAULT ''::character varying,
  ordenado integer,
  request_id character varying(50) NOT NULL DEFAULT ''::character varying,
  creation_user character varying(50) NOT NULL DEFAULT ''::character varying,
  user_update character varying(50) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  target_width integer NOT NULL DEFAULT 1700,
  target_height integer NOT NULL DEFAULT 1700,
  quality integer NOT NULL DEFAULT 50,
  CONSTRAINT fk_api_unidad_negocio FOREIGN KEY (id_unid_negocio)
      REFERENCES unidad_negocio (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE apicredit.tipificacion_archivos_app
  OWNER TO postgres;
GRANT ALL ON TABLE apicredit.tipificacion_archivos_app TO postgres;

