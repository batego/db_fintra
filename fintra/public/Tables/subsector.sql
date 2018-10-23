-- Table: subsector

-- DROP TABLE subsector;

CREATE TABLE subsector
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  cod_sector character varying(6) NOT NULL,
  cod_subsector character varying(6) NOT NULL DEFAULT ''::character varying,
  nombre character varying(200) NOT NULL,
  descripcion text NOT NULL,
  creation_user character varying(10) NOT NULL,
  user_update character varying(10) NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  nombre_alterno character varying(100) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT "subsectorFK" FOREIGN KEY (cod_sector)
      REFERENCES sector (cod_sector) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE subsector
  OWNER TO postgres;
GRANT ALL ON TABLE subsector TO postgres;
GRANT SELECT ON TABLE subsector TO msoto;
COMMENT ON TABLE subsector
  IS 'Codificación estándar de los subsectores económicos';

