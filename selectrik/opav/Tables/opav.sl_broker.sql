-- Table: opav.sl_broker

-- DROP TABLE opav.sl_broker;

CREATE TABLE opav.sl_broker
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  tipo_documento character varying(4) NOT NULL,
  documento character varying(15) NOT NULL,
  nombre character varying(160) NOT NULL,
  codciu character varying(6) NOT NULL,
  coddpto character varying(3) NOT NULL,
  codpais character varying(3) NOT NULL,
  telcontacto character varying(100) NOT NULL,
  celular_contacto character varying(15) NOT NULL,
  email_contacto character varying(100) NOT NULL,
  direccion character varying(160) NOT NULL DEFAULT ''::character varying,
  idusuario character varying(100) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  nombre_contacto character varying(160) NOT NULL DEFAULT ''::character varying,
  enviar_correo_contacto character varying(1) NOT NULL DEFAULT 'N'::character varying,
  nombre_asistente character varying(160) NOT NULL DEFAULT ''::character varying,
  telasistente character varying(100) NOT NULL DEFAULT ''::character varying,
  celular_asistente character varying(15) NOT NULL DEFAULT ''::character varying,
  email_asistente character varying(100) NOT NULL DEFAULT ''::character varying,
  enviar_correo_asistente character varying(1) NOT NULL DEFAULT 'N'::character varying,
  CONSTRAINT sl_broker_codciu_fkey FOREIGN KEY (codciu)
      REFERENCES ciudad (codciu) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT sl_broker_coddpto_fkey FOREIGN KEY (coddpto)
      REFERENCES estado (department_code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_broker
  OWNER TO postgres;

-- Trigger: insertusuariobroker on opav.sl_broker

-- DROP TRIGGER insertusuariobroker ON opav.sl_broker;

CREATE TRIGGER insertusuariobroker
  AFTER INSERT
  ON opav.sl_broker
  FOR EACH ROW
  EXECUTE PROCEDURE insertusuariobroker();
