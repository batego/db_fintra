-- Table: sector

-- DROP TABLE sector;

CREATE TABLE sector
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  cod_sector character varying(6) NOT NULL DEFAULT ''::character varying,
  nombre character varying(110) NOT NULL,
  descripcion text NOT NULL,
  reliquida character varying(1) NOT NULL DEFAULT 'N'::character varying,
  codigo_alterno character varying(3) NOT NULL DEFAULT ''::character varying,
  creation_user character varying(10) NOT NULL,
  user_update character varying(10) NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  nombre_alterno character varying(100) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE sector
  OWNER TO postgres;
GRANT ALL ON TABLE sector TO postgres;
GRANT SELECT ON TABLE sector TO msoto;
COMMENT ON TABLE sector
  IS 'Codificación estándar de sectores económicos';

-- Trigger: tu_inactivar_subsectores on sector

-- DROP TRIGGER tu_inactivar_subsectores ON sector;

CREATE TRIGGER tu_inactivar_subsectores
  BEFORE UPDATE
  ON sector
  FOR EACH ROW
  EXECUTE PROCEDURE tu_inactivar_subsectores();


