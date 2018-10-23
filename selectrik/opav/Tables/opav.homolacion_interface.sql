-- Table: opav.homolacion_interface

-- DROP TABLE opav.homolacion_interface;

CREATE TABLE opav.homolacion_interface
(
  proceso character varying(15) NOT NULL,
  tipo_doc_fintra character varying(3) NOT NULL,
  cuenta_fintra character varying(30) NOT NULL,
  agencia_fintra character varying(15) NOT NULL,
  cuenta_apo character varying(8) NOT NULL,
  centro_costo_apo character varying(11) NOT NULL,
  documento_sop character varying(10),
  numero_doc_sop character varying(1),
  numero_venc character varying(1),
  fecha_emision character varying(1),
  fecha_vencimiento character varying(1)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.homolacion_interface
  OWNER TO postgres;
COMMENT ON TABLE opav.homolacion_interface
  IS 'Homologacion de cuentas. Interface Apoteosys';
