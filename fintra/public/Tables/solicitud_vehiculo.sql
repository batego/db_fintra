-- Table: solicitud_vehiculo

-- DROP TABLE solicitud_vehiculo;

CREATE TABLE solicitud_vehiculo
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT ''::character varying,
  numero_solicitud integer NOT NULL DEFAULT 0,
  tipo character varying(1) NOT NULL DEFAULT 'S'::character varying,
  secuencia integer NOT NULL DEFAULT 0,
  marca character varying(60) NOT NULL DEFAULT ''::character varying,
  tipo_vehiculo character varying(15) NOT NULL DEFAULT ''::character varying,
  placa character varying(9) NOT NULL DEFAULT ''::character varying,
  modelo character varying(12) NOT NULL DEFAULT ''::character varying,
  valor_comercial numeric(15,2) NOT NULL DEFAULT 0.0,
  cuota_mensual numeric(15,2) NOT NULL DEFAULT 0.0,
  pignorado_a_favor_de character varying(60) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(50) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(50) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_solicitud_aval FOREIGN KEY (numero_solicitud)
      REFERENCES solicitud_aval (numero_solicitud) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE solicitud_vehiculo
  OWNER TO postgres;
GRANT ALL ON TABLE solicitud_vehiculo TO postgres;
GRANT SELECT ON TABLE solicitud_vehiculo TO msoto;

