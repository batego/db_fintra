-- Table: con.foto_cartera_apoteosys

-- DROP TABLE con.foto_cartera_apoteosys;

CREATE TABLE con.foto_cartera_apoteosys
(
  tipo_documento character varying(15),
  factura_geotech character varying(6),
  factura_apoteosys integer,
  centro_costo character varying(50),
  nombre_centro_costo character varying(200),
  tercero character varying(200),
  nombre_tercero character varying(200),
  estado character varying(10),
  codcli character varying(10),
  fechacrea timestamp without time zone,
  fechaact timestamp without time zone,
  nit character varying(200),
  dstrct character varying(6),
  moneda character varying(10),
  plazo integer,
  nomcontacto character varying(300),
  telcontacto character varying(20),
  email_contacto character varying(300),
  dir_factura character varying(300),
  direccion_contacto character varying(300),
  cmc character varying(6),
  ciudad character varying(30),
  ciudad_factura character varying(30),
  pais character varying(30),
  usuariocrea character varying(30),
  usuarioact character varying(30),
  email_factura character varying(300),
  observacion text,
  periodo_creacion character varying(6),
  fecha_foto_pg timestamp without time zone,
  fecha_creacion_pg timestamp without time zone,
  fecha_facturacion_pg timestamp without time zone,
  fecha_vencimiento_pg timestamp without time zone,
  fecha_corte_pg timestamp without time zone,
  diasvencidos_corte integer,
  vencimiento_corte character varying(200),
  valor_base numeric(17,2),
  valor_iva numeric(17,2),
  valor_retefuente numeric(17,2),
  valor_reteica numeric(17,2),
  valor_reteiva numeric(17,2),
  valor_factura numeric,
  abono numeric,
  saldo numeric,
  transferido character varying(1) NOT NULL DEFAULT 'N'::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.foto_cartera_apoteosys
  OWNER TO postgres;
GRANT ALL ON TABLE con.foto_cartera_apoteosys TO postgres;

