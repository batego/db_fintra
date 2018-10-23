-- Table: con.periodos_foto

-- DROP TABLE con.periodos_foto;

CREATE TABLE con.periodos_foto
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  valor character varying(10) NOT NULL,
  descripcion character varying(150) NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.periodos_foto
  OWNER TO postgres;
GRANT ALL ON TABLE con.periodos_foto TO postgres;
GRANT SELECT ON TABLE con.periodos_foto TO msoto;

