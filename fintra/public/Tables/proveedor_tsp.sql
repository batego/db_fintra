-- Table: proveedor_tsp

-- DROP TABLE proveedor_tsp;

CREATE TABLE proveedor_tsp
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  nit character varying(15) NOT NULL DEFAULT ''::character varying,
  id_mims character varying(10) NOT NULL DEFAULT ''::character varying,
  payment_name character varying(60) NOT NULL DEFAULT ''::character varying,
  branch_code character varying(15) NOT NULL DEFAULT ''::character varying,
  bank_account_no character varying(60) NOT NULL DEFAULT ''::character varying,
  agency_id character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  tipo_doc character varying(3) NOT NULL DEFAULT ''::character varying,
  banco_transfer character varying(15) NOT NULL DEFAULT ''::character varying,
  suc_transfer character varying(15) NOT NULL DEFAULT ''::character varying,
  tipo_cuenta character varying(15) NOT NULL DEFAULT ''::character varying,
  no_cuenta character varying(20) NOT NULL DEFAULT ''::character varying,
  codciu_cuenta character varying(10) NOT NULL DEFAULT ''::character varying,
  clasificacion character varying(10) NOT NULL DEFAULT ''::character varying,
  gran_contribuyente character varying(2) NOT NULL DEFAULT 'N'::character varying,
  agente_retenedor character varying(2) NOT NULL DEFAULT 'N'::character varying,
  autoret_rfte character varying(2) NOT NULL DEFAULT 'N'::character varying,
  autoret_iva character varying(2) NOT NULL DEFAULT 'N'::character varying,
  autoret_ica character varying(2) NOT NULL DEFAULT 'N'::character varying,
  hc character varying(2) NOT NULL DEFAULT ''::character varying,
  plazo numeric(3,0) NOT NULL DEFAULT 1,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  cedula_cuenta character varying(15) NOT NULL DEFAULT ''::character varying,
  nombre_cuenta character varying(60) NOT NULL DEFAULT ''::character varying,
  concept_code character varying(6) NOT NULL DEFAULT ''::character varying,
  cmc character varying(6) NOT NULL DEFAULT '00'::character varying,
  tipo_pago character varying(1) NOT NULL DEFAULT 'B'::character varying,
  nit_beneficiario character varying(15) NOT NULL DEFAULT ''::character varying,
  aprobado character varying(1) NOT NULL DEFAULT 'N'::character varying,
  fecha_aprobacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  usuario_aprobacion character varying(10) NOT NULL DEFAULT ''::character varying,
  ret_pago character varying(1) NOT NULL DEFAULT 'N'::character varying,
  envia_mail character varying(1) NOT NULL DEFAULT ''::character varying,
  fecha_envio_ws timestamp without time zone,
  fecha_anulacion timestamp without time zone,
  creation_date_real timestamp without time zone DEFAULT now(),
  pk_novedad integer NOT NULL DEFAULT (-1)
)
WITH (
  OIDS=TRUE
);
ALTER TABLE proveedor_tsp
  OWNER TO postgres;
GRANT ALL ON TABLE proveedor_tsp TO postgres;
GRANT SELECT ON TABLE proveedor_tsp TO msoto;

-- Trigger: proveedortspafinvt on proveedor_tsp

-- DROP TRIGGER proveedortspafinvt ON proveedor_tsp;

CREATE TRIGGER proveedortspafinvt
  AFTER INSERT OR UPDATE
  ON proveedor_tsp
  FOR EACH ROW
  EXECUTE PROCEDURE proveedortspafinv();


