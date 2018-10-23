-- Table: ex_acciones

-- DROP TABLE ex_acciones;

CREATE TABLE ex_acciones
(
  id_accion character varying(12) NOT NULL DEFAULT ''::character varying,
  id_solicitud character varying(15) DEFAULT ''::character varying,
  estado character varying(5) DEFAULT ''::character varying,
  contratista character varying(5) DEFAULT ''::character varying,
  material moneda DEFAULT 0, -- costo contratista
  mano_obra moneda DEFAULT 0,
  transporte moneda DEFAULT 0,
  administracion moneda DEFAULT 0, -- costo contratista
  imprevisto moneda DEFAULT 0,
  utilidad moneda DEFAULT 0,
  porc_administracion numeric(5,2) DEFAULT 0,
  porc_imprevisto numeric(5,2) DEFAULT 0,
  porc_utilidad numeric(5,2) DEFAULT 0,
  descripcion text DEFAULT ''::text,
  user_update character varying(10) DEFAULT ''::character varying,
  creation_user character varying(10) DEFAULT ''::character varying,
  reg_status character varying(1) DEFAULT ''::character varying,
  observaciones text DEFAULT ''::text,
  tipo_trabajo character varying(20) DEFAULT ''::character varying, -- parece ser solo informativo
  creation_date timestamp without time zone DEFAULT now(),
  last_update timestamp without time zone DEFAULT now(),
  alcances text DEFAULT ''::text,
  adicionales text DEFAULT ''::text,
  trabajo text DEFAULT ''::text,
  fec_visita_planeada timestamp without time zone,
  fec_visita_hecha timestamp without time zone,
  user_visita_hecha character varying(10) DEFAULT ''::character varying,
  creation_fec_visita_hecha timestamp without time zone,
  aviso character varying(50) DEFAULT ''::character varying,
  factura_cliente character varying(15) NOT NULL DEFAULT ''::character varying,
  parcial integer NOT NULL DEFAULT 1,
  bonificacion moneda NOT NULL DEFAULT 0,
  opav moneda NOT NULL DEFAULT 0,
  fintra moneda NOT NULL DEFAULT 0,
  interventoria moneda NOT NULL DEFAULT 0,
  provintegral moneda NOT NULL DEFAULT 0,
  eca moneda NOT NULL DEFAULT 0,
  base_iva_contratista moneda NOT NULL DEFAULT 0,
  iva_contratista moneda NOT NULL DEFAULT 0,
  iva_bonificacion moneda NOT NULL DEFAULT 0,
  iva_opav moneda NOT NULL DEFAULT 0,
  iva_fintra moneda NOT NULL DEFAULT 0,
  iva_interventoria moneda NOT NULL DEFAULT 0,
  iva_provintegral moneda NOT NULL DEFAULT 0,
  iva_eca moneda NOT NULL DEFAULT 0,
  financiar_sin_iva moneda NOT NULL DEFAULT 0,
  iva moneda NOT NULL DEFAULT 0,
  financiar_con_iva moneda NOT NULL DEFAULT 0,
  prefacturar character varying(1) NOT NULL DEFAULT 'N'::character varying,
  exestado character varying(5) NOT NULL DEFAULT ''::character varying, -- columna temporal
  fecha_finalizacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  fecha_interventoria timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  observacion_recepcion text NOT NULL DEFAULT ''::text,
  fec_creacion_recepcion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_recepcion character varying(10) NOT NULL DEFAULT ''::character varying,
  prefacturar_contratista character varying(1) NOT NULL DEFAULT 'N'::character varying,
  prefactura_contratista character varying(30) NOT NULL DEFAULT ''::character varying,
  usuario_prefactura_contratista character varying(10) NOT NULL DEFAULT ''::character varying,
  factura_contratista character varying(30) NOT NULL DEFAULT ''::character varying,
  usuario_factura_contratista character varying(10) NOT NULL DEFAULT ''::character varying,
  factura_contratista_fintra character varying(30) NOT NULL DEFAULT ''::character varying,
  cod_iva_contratista character varying(6) NOT NULL DEFAULT ''::character varying,
  por_iva_contratista numeric(5,2) NOT NULL DEFAULT 0,
  val_base_iva_contratista moneda NOT NULL DEFAULT 0,
  val_iva_contratista moneda NOT NULL DEFAULT 0,
  cod_ret_material_contratista character varying(6) NOT NULL DEFAULT ''::character varying,
  por_ret_material_contratista numeric(5,2) NOT NULL DEFAULT 0,
  val_ret_mano_obra_contratista moneda NOT NULL DEFAULT 0,
  val_ret_material_contratista moneda NOT NULL DEFAULT 0,
  cod_ret_mano_obra_contratista character varying(6) NOT NULL DEFAULT ''::character varying,
  por_ret_mano_obra_contratista numeric(5,2) NOT NULL DEFAULT 0,
  cod_ret_otros_contratista character(6) NOT NULL DEFAULT ''::bpchar,
  por_ret_otros_contratista numeric(5,2) NOT NULL DEFAULT 0,
  val_ret_otros_contratista moneda NOT NULL DEFAULT 0,
  por_factoring_contratista numeric(5,2) NOT NULL DEFAULT 0,
  val_formula_contratista moneda NOT NULL DEFAULT 0,
  val_factoring_contratista moneda NOT NULL DEFAULT 0,
  por_formula_contratista numeric(5,2) NOT NULL DEFAULT 0,
  cod_ret_ica_contratista character varying(6) NOT NULL DEFAULT ''::character varying,
  por_ret_ica_contratista numeric(5,2) NOT NULL DEFAULT 0,
  val_ret_ica_contratista moneda NOT NULL DEFAULT 0,
  cod_ret_iva_contratista character varying(6) NOT NULL DEFAULT ''::character varying,
  por_ret_iva_contratista numeric(5,2) NOT NULL DEFAULT 0,
  val_ret_iva_contratista moneda NOT NULL DEFAULT 0,
  cod_ret_aiu_contratista character varying(6) NOT NULL DEFAULT ''::character varying,
  por_ret_aiu_contratista numeric(5,2) NOT NULL DEFAULT 0.00,
  val_ret_aiu_contratista moneda NOT NULL DEFAULT 0.00,
  fact_conformada character varying(40) NOT NULL DEFAULT ''::character varying,
  fecha_factura_contratista timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  nota_credito_contratista character varying(30) NOT NULL DEFAULT ''::character varying,
  fecha_nota_credito_contratista timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  fecha_factura_contratista_final timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  fi_provintegral character varying(30) NOT NULL DEFAULT ''::character varying, -- Numero de factura inerna para Provintegral
  liquidacion character varying(1) DEFAULT ''::character varying,
  informe character varying(1) DEFAULT ''::character varying,
  acta character varying(1) DEFAULT ''::character varying,
  fecha_documentacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  fecha_informe timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  fecha_liquidacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  fecha_acta timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  creation_fecha_factura_contratista timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  fc_provintegral character varying(30) NOT NULL DEFAULT ''::character varying, -- Numero de factura conformada para Provintegral
  ff_provintegral timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha factura conformada para Provintegral
  nc_provintegral character varying(30) NOT NULL DEFAULT ''::character varying, -- Nota credito que cancela la factura interna de provintegral para trasladarla a Fintra
  ft_provintegral timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha traslado de la factura conformada a Fintra
  fc_fintra character varying(30) DEFAULT ''::character varying, -- Numero de factura conformada para Fintra
  fc_opav character varying(30) NOT NULL DEFAULT ''::character varying, -- Numero de factura conformada para Opav
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE ex_acciones
  OWNER TO postgres;
GRANT ALL ON TABLE ex_acciones TO postgres;
GRANT SELECT ON TABLE ex_acciones TO msoto;
COMMENT ON COLUMN ex_acciones.material IS 'costo contratista';
COMMENT ON COLUMN ex_acciones.administracion IS 'costo contratista';
COMMENT ON COLUMN ex_acciones.tipo_trabajo IS 'parece ser solo informativo';
COMMENT ON COLUMN ex_acciones.exestado IS 'columna temporal';
COMMENT ON COLUMN ex_acciones.fi_provintegral IS 'Numero de factura inerna para Provintegral';
COMMENT ON COLUMN ex_acciones.fc_provintegral IS 'Numero de factura conformada para Provintegral';
COMMENT ON COLUMN ex_acciones.ff_provintegral IS 'Fecha factura conformada para Provintegral';
COMMENT ON COLUMN ex_acciones.nc_provintegral IS 'Nota credito que cancela la factura interna de provintegral para trasladarla a Fintra';
COMMENT ON COLUMN ex_acciones.ft_provintegral IS 'Fecha traslado de la factura conformada a Fintra';
COMMENT ON COLUMN ex_acciones.fc_fintra IS 'Numero de factura conformada para Fintra';
COMMENT ON COLUMN ex_acciones.fc_opav IS 'Numero de factura conformada para Opav';


