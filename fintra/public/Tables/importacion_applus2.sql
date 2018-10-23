-- Table: importacion_applus2

-- DROP TABLE importacion_applus2;

CREATE TABLE importacion_applus2
(
  ms text DEFAULT ''::text,
  id_orden text DEFAULT ''::text,
  mes text DEFAULT ''::text,
  forma_pago text DEFAULT ''::text,
  observaciones text DEFAULT ''::text,
  sector text DEFAULT ''::text,
  tipo_orden text DEFAULT ''::text,
  nic text DEFAULT ''::text,
  cliente text DEFAULT ''::text,
  tc text DEFAULT ''::text,
  contacto text DEFAULT ''::text,
  cargo text DEFAULT ''::text,
  id_ciudad text DEFAULT ''::text,
  direccion text DEFAULT ''::text,
  telefono text DEFAULT ''::text,
  contratista text DEFAULT ''::text,
  total_prev1 numeric(15,0),
  oferta numeric(15,0),
  iva_o numeric(15,0),
  valor_venta numeric(15,0),
  id_accion text DEFAULT ''::text,
  estudio_economico text DEFAULT ''::text,
  eca_oferta numeric(15,0),
  eca_iva numeric(15,0),
  eca_valor_venta numeric(15,0),
  total_fac_open numeric(15,0),
  fecha_archivo text DEFAULT ''::text,
  fecha_fac text DEFAULT ''::text,
  no_cuotas numeric(5,0),
  pk serial NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE importacion_applus2
  OWNER TO postgres;
GRANT ALL ON TABLE importacion_applus2 TO postgres;
GRANT SELECT ON TABLE importacion_applus2 TO msoto;

