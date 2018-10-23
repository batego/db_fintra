-- Table: opav.app_proveedor_materiales

-- DROP TABLE opav.app_proveedor_materiales;

CREATE TABLE opav.app_proveedor_materiales
(
  id serial NOT NULL,
  nit_proveedor character varying(15) NOT NULL,
  id_material integer NOT NULL,
  certificado character varying(1) NOT NULL DEFAULT ''::character varying,
  ente_certificador character varying(90) NOT NULL DEFAULT ''::character varying,
  costo_base numeric(11,2) DEFAULT 0.0,
  costo_dscto numeric(11,2) DEFAULT 0.0,
  costo_total numeric(11,2) DEFAULT 0.0,
  incremento_fintra numeric(11,2) DEFAULT 0.0,
  precio_oferta numeric(11,2) DEFAULT 0.0,
  creation_user character varying(10),
  creation_date timestamp without time zone DEFAULT now(),
  user_update character varying(10),
  last_update timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  referencia character varying(25),
  CONSTRAINT fk_prov_materiales_material FOREIGN KEY (id_material)
      REFERENCES opav.material (idmaterial) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.app_proveedor_materiales
  OWNER TO postgres;

-- Trigger: h_costos on opav.app_proveedor_materiales

-- DROP TRIGGER h_costos ON opav.app_proveedor_materiales;

CREATE TRIGGER h_costos
  BEFORE INSERT OR UPDATE
  ON opav.app_proveedor_materiales
  FOR EACH ROW
  EXECUTE PROCEDURE opav.historico_costos();
