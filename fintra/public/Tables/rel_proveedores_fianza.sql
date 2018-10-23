-- Table: rel_proveedores_fianza

-- DROP TABLE rel_proveedores_fianza;

CREATE TABLE rel_proveedores_fianza
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  nit character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE rel_proveedores_fianza
  OWNER TO postgres;
GRANT ALL ON TABLE rel_proveedores_fianza TO postgres;
GRANT SELECT ON TABLE rel_proveedores_fianza TO msoto;

