-- Table: avales_fenalco

-- DROP TABLE avales_fenalco;

CREATE TABLE avales_fenalco
(
  scc_afi character varying(2) NOT NULL DEFAULT ''::character varying, -- Seccional Afiliado
  con_afi character varying(6) NOT NULL DEFAULT ''::character varying, -- Consecutivo Afiliado
  suc_afi character varying(3) NOT NULL DEFAULT ''::character varying, -- Sucursal Afiliado
  fin_nit character varying(11) NOT NULL DEFAULT ''::character varying, -- Nit Financiera
  ser_cod character varying(2) NOT NULL DEFAULT ''::character varying, -- Código Servicio
  no_aval character varying(8) NOT NULL DEFAULT ''::character varying, -- Número Aval
  tit_val character varying(10) NOT NULL DEFAULT ''::character varying, -- Título Valor
  fec_aut character varying(8) NOT NULL DEFAULT ''::character varying, -- Fecha Autorización
  hor_aut character varying(8) NOT NULL DEFAULT ''::character varying, -- Hora Autorización
  nit_afi character varying(11) NOT NULL DEFAULT ''::character varying, -- Nit Afiliado
  tip_doc character varying(2) NOT NULL DEFAULT ''::character varying, -- Tipo Documento
  num_doc character varying(11) NOT NULL DEFAULT ''::character varying, -- Número Documento
  nom_gir character varying(30) NOT NULL DEFAULT ''::character varying, -- Nombre Girador
  tel_gir character varying(11) NOT NULL DEFAULT ''::character varying, -- Telefono Girador
  cod_bco character varying(2) NOT NULL DEFAULT ''::character varying, -- Código Banco
  cod_suc character varying(4) NOT NULL DEFAULT ''::character varying, -- Código Sucursal
  nro_cta character varying(13) NOT NULL DEFAULT ''::character varying, -- Número Cuenta
  vlr_tit character varying(9) NOT NULL DEFAULT ''::character varying, -- Valor Título
  fec_con character varying(8) NOT NULL DEFAULT ''::character varying, -- Fecha Consignación
  cob_con character varying(15) NOT NULL DEFAULT ''::character varying, -- Cobertura en la consulta
  cod_dpt character varying(2) NOT NULL DEFAULT ''::character varying, -- Código Departamento
  cod_ciu character varying(3) NOT NULL DEFAULT ''::character varying, -- Código Ciudad
  fec_ini character varying(8) NOT NULL DEFAULT ''::character varying, -- Fecha Rango Inicial
  fec_fin character varying(8) NOT NULL DEFAULT ''::character varying, -- Fecha Rango Final
  fec_pro character varying(8) NOT NULL DEFAULT ''::character varying, -- Fecha Proceso Envio
  hor_pro character varying(8) NOT NULL DEFAULT ''::character varying, -- Hora Proceso
  ind_rat character varying(1) NOT NULL DEFAULT ''::character varying, -- Indicador Ratificado
  cod_iata character varying(8) NOT NULL DEFAULT ''::character varying, -- Código IATA
  cod_cia character varying(2) NOT NULL DEFAULT ''::character varying, -- Compañía Vende
  cod_vta character varying(1) NOT NULL DEFAULT ''::character varying, -- Tipo Venta
  nro_lin character varying(2) NOT NULL DEFAULT ''::character varying, -- Número Línea
  last_update timestamp without time zone,
  creation_date timestamp without time zone,
  user_update character varying(10) DEFAULT ''::character varying,
  creation_user character varying(10) DEFAULT ''::character varying,
  reg_status character varying(1) DEFAULT ''::character varying,
  archivo character varying(10) DEFAULT ''::character varying,
  creation_date_2 date,
  num serial NOT NULL,
  fecha_anulacion timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  aprobado character varying(1) DEFAULT 'N'::character varying,
  fecha_aprobacion timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_aprobacion character varying(10) DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE avales_fenalco
  OWNER TO postgres;
GRANT ALL ON TABLE avales_fenalco TO postgres;
GRANT SELECT ON TABLE avales_fenalco TO msoto;
COMMENT ON COLUMN avales_fenalco.scc_afi IS 'Seccional Afiliado';
COMMENT ON COLUMN avales_fenalco.con_afi IS 'Consecutivo Afiliado';
COMMENT ON COLUMN avales_fenalco.suc_afi IS 'Sucursal Afiliado';
COMMENT ON COLUMN avales_fenalco.fin_nit IS 'Nit Financiera';
COMMENT ON COLUMN avales_fenalco.ser_cod IS 'Código Servicio';
COMMENT ON COLUMN avales_fenalco.no_aval IS 'Número Aval';
COMMENT ON COLUMN avales_fenalco.tit_val IS 'Título Valor';
COMMENT ON COLUMN avales_fenalco.fec_aut IS 'Fecha Autorización';
COMMENT ON COLUMN avales_fenalco.hor_aut IS 'Hora Autorización';
COMMENT ON COLUMN avales_fenalco.nit_afi IS 'Nit Afiliado';
COMMENT ON COLUMN avales_fenalco.tip_doc IS 'Tipo Documento';
COMMENT ON COLUMN avales_fenalco.num_doc IS 'Número Documento';
COMMENT ON COLUMN avales_fenalco.nom_gir IS 'Nombre Girador';
COMMENT ON COLUMN avales_fenalco.tel_gir IS 'Telefono Girador';
COMMENT ON COLUMN avales_fenalco.cod_bco IS 'Código Banco';
COMMENT ON COLUMN avales_fenalco.cod_suc IS 'Código Sucursal';
COMMENT ON COLUMN avales_fenalco.nro_cta IS 'Número Cuenta';
COMMENT ON COLUMN avales_fenalco.vlr_tit IS 'Valor Título';
COMMENT ON COLUMN avales_fenalco.fec_con IS 'Fecha Consignación';
COMMENT ON COLUMN avales_fenalco.cob_con IS 'Cobertura en la consulta';
COMMENT ON COLUMN avales_fenalco.cod_dpt IS 'Código Departamento';
COMMENT ON COLUMN avales_fenalco.cod_ciu IS 'Código Ciudad';
COMMENT ON COLUMN avales_fenalco.fec_ini IS 'Fecha Rango Inicial';
COMMENT ON COLUMN avales_fenalco.fec_fin IS 'Fecha Rango Final';
COMMENT ON COLUMN avales_fenalco.fec_pro IS 'Fecha Proceso Envio';
COMMENT ON COLUMN avales_fenalco.hor_pro IS 'Hora Proceso';
COMMENT ON COLUMN avales_fenalco.ind_rat IS 'Indicador Ratificado';
COMMENT ON COLUMN avales_fenalco.cod_iata IS 'Código IATA';
COMMENT ON COLUMN avales_fenalco.cod_cia IS 'Compañía Vende';
COMMENT ON COLUMN avales_fenalco.cod_vta IS 'Tipo Venta';
COMMENT ON COLUMN avales_fenalco.nro_lin IS 'Número Línea';


-- Trigger: ti_avalar_negocio on avales_fenalco

-- DROP TRIGGER ti_avalar_negocio ON avales_fenalco;

CREATE TRIGGER ti_avalar_negocio
  BEFORE INSERT
  ON avales_fenalco
  FOR EACH ROW
  EXECUTE PROCEDURE ti_avalar_negocio();


