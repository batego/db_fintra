-- Table: opav.rel_distribuciones_ofertas

-- DROP TABLE opav.rel_distribuciones_ofertas;

CREATE TABLE opav.rel_distribuciones_ofertas
(
  id_solicitud character varying(15),
  tipo_solicitud character varying(50)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.rel_distribuciones_ofertas
  OWNER TO postgres;
