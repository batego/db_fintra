-- Table: con.ciclos_facturacion

-- DROP TABLE con.ciclos_facturacion;

CREATE TABLE con.ciclos_facturacion
(
  id serial NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  num_ciclo integer,
  periodo character varying(6) NOT NULL DEFAULT ''::character varying,
  fecha_pago date,
  fecha_ini date,
  fecha_fin date,
  fecha_preparacion date,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.ciclos_facturacion
  OWNER TO postgres;
GRANT ALL ON TABLE con.ciclos_facturacion TO postgres;
GRANT SELECT ON TABLE con.ciclos_facturacion TO msoto;

