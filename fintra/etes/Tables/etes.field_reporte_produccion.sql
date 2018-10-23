-- Table: etes.field_reporte_produccion

-- DROP TABLE etes.field_reporte_produccion;

CREATE TABLE etes.field_reporte_produccion
(
  id serial NOT NULL,
  name_field character varying(50) NOT NULL DEFAULT ''::character varying,
  type_field character varying(50) NOT NULL DEFAULT 'TEXT'::character varying,
  parse_anticipo text NOT NULL DEFAULT ''::text,
  parse_reanticipo text NOT NULL DEFAULT ''::text,
  dinamico text NOT NULL DEFAULT 'N'::text,
  tabla text NOT NULL DEFAULT ''::text,
  secuencia_field text NOT NULL DEFAULT ''::text
)
WITH (
  OIDS=FALSE
);
ALTER TABLE etes.field_reporte_produccion
  OWNER TO postgres;

