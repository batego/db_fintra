-- Table: ciudad

-- DROP TABLE ciudad;

CREATE TABLE ciudad
(
  estado character(1) DEFAULT 'A'::bpchar,
  codciu character varying(10) NOT NULL DEFAULT ''::character varying, -- Codigo Ciudad
  nomciu character varying(40),
  pais character varying(2),
  aplica character(1) DEFAULT 'N'::bpchar,
  codica character varying(4),
  zona character varying(5),
  frontera character(1) DEFAULT 'N'::bpchar,
  agasoc character varying(10),
  lastupdate date DEFAULT now(),
  coddpt character varying(10) NOT NULL DEFAULT ''::character varying, -- Codigo Departamento
  reg_status character(1) NOT NULL DEFAULT ''::bpchar, -- Estado del Registro
  creation_date timestamp without time zone NOT NULL DEFAULT now(), -- Fecha de Creacion
  last_update timestamp without time zone NOT NULL DEFAULT now(), -- Fecha de Actualizacion
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  tipociu character varying(2) NOT NULL DEFAULT ''::character varying, -- Tipo de Ciudad
  frontera_asoc character varying(10) NOT NULL DEFAULT ''::character varying, -- Codigo Frontera asociada a la ciudad
  tiene_rep_urbano character varying(1) NOT NULL DEFAULT 'N'::character varying, -- SE PUEDE GENERAR REPORTE DE TRAFICO URBANO
  indicativo numeric NOT NULL DEFAULT 0,
  creation_user character varying(10) DEFAULT ''::character varying,
  user_update character varying(10) DEFAULT ''::character varying,
  frontasoc character varying(10) NOT NULL DEFAULT ''::character varying, -- Codigo de ciudad de la frontera asociada.
  zona_urb character varying(1) NOT NULL DEFAULT ''::character varying,
  codigo_dane numeric(8,0) NOT NULL DEFAULT 0, -- el codigo de la ciudad segun el dane
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  codigo_dane2 character varying(10) DEFAULT ''::character varying, -- el codigo de la ciudad utilizado para homologar en apoteosys
  aplica_micro character varying(1) NOT NULL DEFAULT ''::character varying,
  cobertura_micro character varying(1) NOT NULL DEFAULT 'N'::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE ciudad
  OWNER TO postgres;
GRANT ALL ON TABLE ciudad TO postgres;
GRANT SELECT ON TABLE ciudad TO msoto;
COMMENT ON COLUMN ciudad.codciu IS 'Codigo Ciudad';
COMMENT ON COLUMN ciudad.coddpt IS 'Codigo Departamento';
COMMENT ON COLUMN ciudad.reg_status IS 'Estado del Registro';
COMMENT ON COLUMN ciudad.creation_date IS 'Fecha de Creacion';
COMMENT ON COLUMN ciudad.last_update IS 'Fecha de Actualizacion';
COMMENT ON COLUMN ciudad.tipociu IS 'Tipo de Ciudad';
COMMENT ON COLUMN ciudad.frontera_asoc IS 'Codigo Frontera asociada a la ciudad';
COMMENT ON COLUMN ciudad.tiene_rep_urbano IS 'SE PUEDE GENERAR REPORTE DE TRAFICO URBANO';
COMMENT ON COLUMN ciudad.frontasoc IS 'Codigo de ciudad de la frontera asociada.';
COMMENT ON COLUMN ciudad.codigo_dane IS 'el codigo de la ciudad segun el dane';
COMMENT ON COLUMN ciudad.codigo_dane2 IS 'el codigo de la ciudad utilizado para homologar en apoteosys';


