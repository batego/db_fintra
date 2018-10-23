-- Table: convenios

-- DROP TABLE convenios;

CREATE TABLE convenios
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_convenio integer NOT NULL DEFAULT nextval('convenios_id_convenio_seq'::regclass),
  nombre character varying(200) NOT NULL,
  descripcion text NOT NULL,
  nit_convenio character varying(15) NOT NULL DEFAULT ''::character varying,
  factura_tercero boolean NOT NULL DEFAULT false,
  nit_tercero character varying(15) NOT NULL DEFAULT ''::character varying,
  tasa_interes numeric NOT NULL,
  cuenta_interes character varying(30) NOT NULL,
  valor_custodia numeric NOT NULL,
  cuenta_custodia character varying(30) NOT NULL,
  prefijo_negocio character varying(15) NOT NULL,
  prefijo_cxp character varying(15) NOT NULL,
  cuenta_cxp character varying(30) NOT NULL,
  hc_cxp character varying(6) NOT NULL,
  descuenta_gmf boolean NOT NULL DEFAULT false,
  cuota_gmf numeric NOT NULL,
  prefijo_nc_gmf character varying(15) NOT NULL,
  cuenta_gmf character varying(30) NOT NULL,
  descuenta_aval boolean NOT NULL DEFAULT false,
  prefijo_nc_aval character varying(15) NOT NULL,
  cuenta_aval character varying(30) NOT NULL,
  prefijo_diferidos character varying(15) NOT NULL,
  cuenta_diferidos character varying(30) NOT NULL,
  hc_diferidos character varying(6) NOT NULL,
  porcentaje_gmf numeric NOT NULL DEFAULT 0, -- Porcentaje para calcular el gravamen al movimiento financiero
  impuesto character varying(6) NOT NULL DEFAULT ''::character varying, -- codigo del impuesto a aplicar
  cuenta_ajuste character varying(30) NOT NULL DEFAULT ''::character varying, -- cuenta para realizar el ahuste al peso
  porcentaje_gmf2 numeric NOT NULL DEFAULT 0,
  cuenta_gmf2 character varying(30) NOT NULL DEFAULT ''::character varying,
  prefijo_endoso character varying(15) NOT NULL,
  hc_endoso character varying(6) NOT NULL,
  intermediario_aval boolean NOT NULL DEFAULT false,
  nit_mediador character varying(15) NOT NULL DEFAULT ''::character varying,
  creation_user character varying(10) NOT NULL,
  user_update character varying(10) NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  tipo character varying(15) NOT NULL DEFAULT 'Consumo'::character varying,
  central boolean NOT NULL DEFAULT false,
  capacitacion boolean NOT NULL DEFAULT false,
  seguro boolean NOT NULL DEFAULT false,
  nit_central character varying(15) NOT NULL DEFAULT ''::character varying,
  nit_capacitador character varying(15) NOT NULL DEFAULT ''::character varying,
  nit_asegurador character varying(15) NOT NULL DEFAULT ''::character varying,
  prefijo_cxc_interes character varying(15) NOT NULL DEFAULT ''::character varying,
  prefijo_cxp_central character varying(15) NOT NULL DEFAULT ''::character varying,
  prefijo_cxc_cat character varying(15) NOT NULL DEFAULT ''::character varying,
  cuenta_central character varying(30) NOT NULL DEFAULT ''::character varying,
  cuenta_com_central character varying(30) NOT NULL DEFAULT ''::character varying,
  cuenta_cat character varying(30) NOT NULL DEFAULT ''::character varying,
  cuenta_capacitacion character varying(30) NOT NULL DEFAULT ''::character varying,
  cuenta_seguro character varying(30) NOT NULL DEFAULT ''::character varying,
  cuenta_com_seguro character varying(30) NOT NULL DEFAULT ''::character varying,
  valor_central numeric NOT NULL DEFAULT 0,
  valor_com_central numeric NOT NULL DEFAULT 0,
  porcentaje_cat numeric NOT NULL DEFAULT 0,
  valor_capacitacion numeric NOT NULL DEFAULT 0,
  valor_seguro numeric NOT NULL DEFAULT 0,
  porcentaje_com_seguro numeric NOT NULL DEFAULT 0,
  monto_minimo numeric NOT NULL DEFAULT 0,
  monto_maximo numeric NOT NULL DEFAULT 0,
  plazo_maximo numeric NOT NULL DEFAULT 0,
  aval_tercero boolean NOT NULL DEFAULT false,
  redescuento boolean NOT NULL DEFAULT true,
  aval_anombre boolean NOT NULL DEFAULT false,
  cxp_avalista boolean NOT NULL DEFAULT false,
  nit_anombre character varying(15) NOT NULL DEFAULT ''::character varying,
  prefijo_cxc_aval character varying(15) NOT NULL DEFAULT ''::character varying,
  hc_cxc_aval character varying(6) NOT NULL DEFAULT ''::character varying,
  cuenta_cxc_aval character varying(30) NOT NULL DEFAULT ''::character varying,
  cctrl_db_cxc_aval character varying(30) NOT NULL DEFAULT ''::character varying,
  cctrl_cr_cxc_aval character varying(30) NOT NULL DEFAULT ''::character varying,
  cctrl_iva_cxc_aval character varying(30) NOT NULL DEFAULT ''::character varying,
  prefijo_cxp_avalista character varying(15) NOT NULL DEFAULT ''::character varying,
  hc_cxp_avalista character varying(6) NOT NULL DEFAULT ''::character varying,
  cuenta_cxp_avalista character varying(30) NOT NULL DEFAULT ''::character varying,
  cuenta_prov_cxp character varying(30) NOT NULL DEFAULT ''::character varying,
  cat boolean NOT NULL DEFAULT false,
  prefijo_end_fiducia character varying(15) NOT NULL DEFAULT ''::character varying,
  hc_end_fiducia character varying(6) NOT NULL DEFAULT ''::character varying,
  prefijo_dif_fiducia character varying(15) NOT NULL DEFAULT ''::character varying,
  hc_dif_fiducia character varying(6) NOT NULL DEFAULT ''::character varying,
  cuenta_dif_fiducia character varying(30) NOT NULL DEFAULT ''::character varying,
  ruta character(100),
  cuota_manejo boolean DEFAULT false,
  cuenta_cuota_manejo character varying(30) DEFAULT ''::character varying,
  valor_cuota_manejo numeric DEFAULT 0,
  hc_cuota_manejo character varying(6) NOT NULL DEFAULT ''::character varying,
  prefijo_cxp_fianza character varying(15) NOT NULL DEFAULT ''::character varying,
  hc_cxp_fianza character varying(6) NOT NULL DEFAULT ''::character varying,
  cuenta_cuota_administracion character varying(30) NOT NULL DEFAULT ''::character varying,
  agencia character varying(15) NOT NULL DEFAULT ''::character varying,
  prefijo_cuota_administracion_diferido character varying(15) NOT NULL DEFAULT ''::character varying,
  hc_cuota_admin character varying(6) NOT NULL DEFAULT ''::character varying,
  cta_cuota_admin_diferido character varying(30) NOT NULL DEFAULT ''::character varying,
  tasa_usura numeric NOT NULL DEFAULT 0
)
WITH (
  OIDS=FALSE
);
ALTER TABLE convenios
  OWNER TO postgres;
GRANT ALL ON TABLE convenios TO postgres;
GRANT SELECT ON TABLE convenios TO msoto;
COMMENT ON TABLE convenios
  IS 'Parametrización de convenidos y sus condiciones';
COMMENT ON COLUMN convenios.porcentaje_gmf IS 'Porcentaje para calcular el gravamen al movimiento financiero';
COMMENT ON COLUMN convenios.impuesto IS 'codigo del impuesto a aplicar';
COMMENT ON COLUMN convenios.cuenta_ajuste IS 'cuenta para realizar el ahuste al peso';


-- Trigger: tu_prov_convenio on convenios

-- DROP TRIGGER tu_prov_convenio ON convenios;

CREATE TRIGGER tu_prov_convenio
  BEFORE UPDATE
  ON convenios
  FOR EACH ROW
  EXECUTE PROCEDURE tu_prov_convenio();
COMMENT ON TRIGGER tu_prov_convenio ON convenios IS 'Actualiza la tasa y/o la custodia de la asignacion de convenios de los afiliados tomando los nuevos  valores definidos en el convenio  ';

--Se agrega campo id_sucursal 
ALTER TABLE convenios ADD COLUMN id_sucursal INTEGER NOT NULL DEFAULT 0;

-- Se agrega campo tasa_compra_cartera
ALTER TABLE convenios ADD COLUMN tasa_compra_cartera numeric NOT NULL DEFAULT 0;

