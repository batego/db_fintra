-- Table: fin.dias_festivos

-- DROP TABLE fin.dias_festivos;

CREATE TABLE fin.dias_festivos
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(15) NOT NULL DEFAULT ''::character varying,
  fecha timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  festivo boolean NOT NULL DEFAULT false
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fin.dias_festivos
  OWNER TO postgres;

