-- Table: etes.productos_servicios_transp

-- DROP TABLE etes.productos_servicios_transp;

CREATE TABLE etes.productos_servicios_transp
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  codigo_proserv character varying(10) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(60) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE etes.productos_servicios_transp
  OWNER TO postgres;

