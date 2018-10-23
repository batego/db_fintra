-- Table: nomenclaturas

-- DROP TABLE nomenclaturas;

CREATE TABLE nomenclaturas
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  nombre character varying(50) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(160) NOT NULL DEFAULT ''::character varying,
  is_default character varying(1) NOT NULL DEFAULT 'N'::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE nomenclaturas
  OWNER TO postgres;
GRANT ALL ON TABLE nomenclaturas TO postgres;
GRANT SELECT ON TABLE nomenclaturas TO msoto;

