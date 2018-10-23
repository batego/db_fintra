-- Table: solicitud_negocio

-- DROP TABLE solicitud_negocio;

CREATE TABLE solicitud_negocio
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT ''::character varying,
  numero_solicitud integer NOT NULL DEFAULT 0,
  cod_sector character varying,
  cod_subsector character varying,
  nombre character varying(100) NOT NULL DEFAULT ''::character varying,
  direccion character varying(160) NOT NULL DEFAULT ''::character varying,
  departamento character varying(10) NOT NULL DEFAULT ''::character varying,
  ciudad character varying(30) NOT NULL DEFAULT ''::character varying,
  barrio character varying(100) NOT NULL DEFAULT ''::character varying,
  telefono character varying(15) NOT NULL DEFAULT ''::character varying,
  tiempo_local integer NOT NULL DEFAULT 0,
  num_exp_negocio integer NOT NULL DEFAULT 0,
  tiempo_microempresario integer NOT NULL DEFAULT 0,
  num_trabajadores integer NOT NULL DEFAULT 0,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(50) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(50) NOT NULL DEFAULT ''::character varying,
  lat character varying(80) NOT NULL DEFAULT ''::character varying,
  lng character varying(80) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_solicitud_aval FOREIGN KEY (numero_solicitud)
      REFERENCES solicitud_aval (numero_solicitud) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_subsector FOREIGN KEY (cod_sector, cod_subsector)
      REFERENCES subsector (cod_sector, cod_subsector) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE solicitud_negocio
  OWNER TO postgres;
GRANT ALL ON TABLE solicitud_negocio TO postgres;
GRANT SELECT ON TABLE solicitud_negocio TO msoto;

-- Trigger: dv_insert_coordenadas on solicitud_negocio

-- DROP TRIGGER dv_insert_coordenadas ON solicitud_negocio;

CREATE TRIGGER dv_insert_coordenadas
  AFTER INSERT
  ON solicitud_negocio
  FOR EACH ROW
  EXECUTE PROCEDURE dv_insert_coordenadas();


