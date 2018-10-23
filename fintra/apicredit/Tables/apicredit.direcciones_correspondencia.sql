-- Table: apicredit.direcciones_correspondencia

-- DROP TABLE apicredit.direcciones_correspondencia;

CREATE TABLE apicredit.direcciones_correspondencia
(
  id serial NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  numero_solicitud integer NOT NULL,
  nombre_direccion character varying(100) NOT NULL DEFAULT ''::character varying,
  direccion character varying(100) NOT NULL DEFAULT ''::character varying,
  barrio character varying(50) NOT NULL DEFAULT ''::character varying,
  departamento character varying(50) NOT NULL DEFAULT ''::character varying,
  ciudad character varying(50) NOT NULL DEFAULT ''::character varying,
  complemento character varying(100) NOT NULL DEFAULT ''::character varying,
  creation_user character varying(50) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT fk_id_solicitud FOREIGN KEY (numero_solicitud)
      REFERENCES solicitud_aval (numero_solicitud) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE apicredit.direcciones_correspondencia
  OWNER TO postgres;

-- Trigger: updatesolicitud_laboral on apicredit.direcciones_correspondencia

-- DROP TRIGGER updatesolicitud_laboral ON apicredit.direcciones_correspondencia;

CREATE TRIGGER updatesolicitud_laboral
  AFTER INSERT
  ON apicredit.direcciones_correspondencia
  FOR EACH ROW
  EXECUTE PROCEDURE apicredit.update_solicitud_laboral();


