-- Table: negocios_standby

-- DROP TABLE negocios_standby;

CREATE TABLE negocios_standby
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  actividad character varying(10) NOT NULL DEFAULT ''::character varying,
  usuario character varying(10) NOT NULL DEFAULT ''::character varying,
  fecha timestamp without time zone NOT NULL DEFAULT now(),
  cod_neg character varying(15)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE negocios_standby
  OWNER TO postgres;
GRANT ALL ON TABLE negocios_standby TO postgres;
GRANT SELECT ON TABLE negocios_standby TO msoto;

