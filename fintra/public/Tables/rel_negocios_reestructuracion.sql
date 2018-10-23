-- Table: rel_negocios_reestructuracion

-- DROP TABLE rel_negocios_reestructuracion;

CREATE TABLE rel_negocios_reestructuracion
(
  id serial NOT NULL,
  negocio_base character varying(20),
  negocio_reestructuracion character varying(20),
  saldo_capital numeric(11,0) NOT NULL DEFAULT 0,
  saldo_interes numeric(11,0) NOT NULL DEFAULT 0,
  saldo_cat numeric(11,0) NOT NULL DEFAULT 0,
  saldo_seguro numeric(11,0) NOT NULL DEFAULT 0,
  intxmora numeric(11,0) NOT NULL DEFAULT 0,
  gac numeric(11,0) NOT NULL DEFAULT 0,
  creation_user character varying(15),
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE rel_negocios_reestructuracion
  OWNER TO postgres;
GRANT ALL ON TABLE rel_negocios_reestructuracion TO postgres;
GRANT SELECT ON TABLE rel_negocios_reestructuracion TO msoto;

