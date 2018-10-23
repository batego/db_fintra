-- Table: etes.estacion_servicio

-- DROP TABLE etes.estacion_servicio;

CREATE TABLE etes.estacion_servicio
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_bandera_es integer NOT NULL,
  id_propietario_estacion integer NOT NULL,
  cod_eds character varying(8) NOT NULL,
  nombre_eds character varying(300) NOT NULL DEFAULT ''::character varying,
  nit_estacion character varying(15) NOT NULL DEFAULT ''::character varying,
  municipio character varying(300) NOT NULL DEFAULT ''::character varying,
  direccion character varying(100) NOT NULL DEFAULT ''::character varying,
  telefono character varying(150) NOT NULL DEFAULT ''::character varying,
  correo character varying(70) NOT NULL DEFAULT ''::character varying,
  estado_user_eds character(1) NOT NULL DEFAULT ''::bpchar,
  idusuario character varying(10) NOT NULL DEFAULT ''::character varying,
  token character varying(50) NOT NULL DEFAULT ''::character varying,
  geo_x numeric(11,6) NOT NULL DEFAULT 0,
  geo_y numeric(11,6) NOT NULL DEFAULT 0,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_eds_bandera FOREIGN KEY (id_bandera_es)
      REFERENCES etes.bandera_es (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_eds_propietarioestacion FOREIGN KEY (id_propietario_estacion)
      REFERENCES etes.propietario_estacion (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE etes.estacion_servicio
  OWNER TO postgres;

-- Trigger: actualizar_fecha_sesion on etes.estacion_servicio

-- DROP TRIGGER actualizar_fecha_sesion ON etes.estacion_servicio;

CREATE TRIGGER actualizar_fecha_sesion
  BEFORE UPDATE
  ON etes.estacion_servicio
  FOR EACH ROW
  EXECUTE PROCEDURE etes.actualizar_fecha_sesion();


