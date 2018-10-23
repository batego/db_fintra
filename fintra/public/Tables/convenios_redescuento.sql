-- Table: convenios_redescuento

-- DROP TABLE convenios_redescuento;

CREATE TABLE convenios_redescuento
(
  id serial NOT NULL,
  id_convenio integer NOT NULL,
  id_redescuento integer NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE convenios_redescuento
  OWNER TO postgres;
GRANT ALL ON TABLE convenios_redescuento TO postgres;
GRANT SELECT ON TABLE convenios_redescuento TO msoto;

