-- Table: conceptos_facturacion

-- DROP TABLE conceptos_facturacion;

CREATE TABLE conceptos_facturacion
(
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  id serial NOT NULL,
  id_unidad_negocio integer NOT NULL,
  descripcion character varying(50) NOT NULL DEFAULT ''::character varying,
  prioridad_pago integer NOT NULL,
  prefijo character varying(10) NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE conceptos_facturacion
  OWNER TO postgres;

