-- Table: titulos_fenalco

-- DROP TABLE titulos_fenalco;

CREATE TABLE titulos_fenalco
(
  item integer NOT NULL,
  empresa character varying(45) NOT NULL,
  nit character varying(20) NOT NULL,
  cedula_girador character varying(20) NOT NULL,
  nombre_girador character varying(45) NOT NULL,
  numero_banco character varying(3) NOT NULL,
  numero_cheque character varying(20) NOT NULL,
  numero_cuenta character varying(20) NOT NULL,
  fecha_consignacion character varying NOT NULL,
  valor numeric NOT NULL,
  ciudad_remesa character varying(25) NOT NULL,
  numero_aprobacion character varying(20) NOT NULL,
  fecha_visado character varying NOT NULL,
  num_mes numeric NOT NULL,
  p_fenalco character varying(20) NOT NULL,
  fecha character varying(10) NOT NULL,
  fecha_factura date,
  no_factura character varying(10),
  fecha_vencimiento_factura date,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE titulos_fenalco
  OWNER TO postgres;
GRANT ALL ON TABLE titulos_fenalco TO postgres;
GRANT SELECT ON TABLE titulos_fenalco TO msoto;

