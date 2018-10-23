-- Table: ex_historico_acciones

-- DROP TABLE ex_historico_acciones;

CREATE TABLE ex_historico_acciones
(
  id_accion character varying(12),
  id_solicitud character varying(15),
  estado character varying(5),
  contratista character varying(5),
  material moneda,
  mano_obra moneda,
  transporte moneda,
  administracion moneda,
  imprevisto moneda,
  utilidad moneda,
  porc_administracion numeric(5,2),
  porc_imprevisto numeric(5,2),
  porc_utilidad numeric(5,2),
  descripcion text,
  user_update character varying(10),
  creation_user character varying(10),
  reg_status character varying(1),
  observaciones text,
  tipo_trabajo character varying(20),
  creation_date timestamp without time zone,
  last_update timestamp without time zone,
  alcances text,
  adicionales text,
  trabajo text,
  id_h integer NOT NULL DEFAULT nextval('historico_acciones_id_h_seq'::regclass),
  hcreation_date timestamp without time zone,
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
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE ex_historico_acciones
  OWNER TO postgres;
GRANT ALL ON TABLE ex_historico_acciones TO postgres;
GRANT SELECT ON TABLE ex_historico_acciones TO msoto;
COMMENT ON COLUMN ex_historico_acciones.exestado IS 'columna temporal';


