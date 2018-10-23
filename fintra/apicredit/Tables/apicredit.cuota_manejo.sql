-- Table: apicredit.cuota_manejo

-- DROP TABLE apicredit.cuota_manejo;

CREATE TABLE apicredit.cuota_manejo
(
  id serial NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  id_convenio character varying(10) NOT NULL DEFAULT ''::character varying,
  tipo_calculo character varying(1) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(300) NOT NULL DEFAULT ''::character varying,
  valor numeric(11,2) NOT NULL DEFAULT 0,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE apicredit.cuota_manejo
  OWNER TO postgres;

