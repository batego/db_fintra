-- Table: negocios

-- DROP TABLE negocios;

CREATE TABLE negocios
(
  cod_cli character varying(20) NOT NULL DEFAULT ''::character varying,
  fecha_negocio timestamp without time zone NOT NULL,
  cod_tabla character varying(50) NOT NULL DEFAULT ''::character varying, -- En el liquidador master el porcentaje asociado al nit  y a si es cheque o letra a 30 o a 45 dias varia por lo que ...
  nro_docs character varying(10) NOT NULL DEFAULT ''::character varying,
  vr_desembolso moneda,
  vr_aval moneda, -- para el liquidador master tasa del proveedor  y para el de cartera antes 0 pero ahora tasa del proveedor (verificar)
  vr_custodia moneda,
  mod_aval character varying(10) NOT NULL DEFAULT ''::character varying,
  mod_custodia character varying(10) NOT NULL DEFAULT ''::character varying, -- para liquidador master 1 es con custodia de cliente y 0 de establecimiento mientras que para el de cartera igual ahora(ojo con el pasado)
  porc_remesa numeric(5,5) NOT NULL DEFAULT 0,
  mod_remesa character varying(10) NOT NULL DEFAULT ''::character varying,
  esta character varying(10) NOT NULL DEFAULT ''::character varying,
  dist character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  uptade_date timestamp without time zone,
  create_user character varying(50) NOT NULL DEFAULT ''::character varying,
  update_user character varying(50) NOT NULL DEFAULT ''::character varying,
  aprobado_por character varying(20) NOT NULL DEFAULT ''::character varying,
  fecha_ap timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  observaciones text NOT NULL DEFAULT 'NINGUNA'::text,
  estado_neg character varying(10) NOT NULL DEFAULT 'P'::character varying,
  fecha_cont timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_cont character varying(10) NOT NULL DEFAULT ''::character varying,
  no_transacion character varying(10) NOT NULL DEFAULT ''::character varying,
  fecha_anulacion timestamp without time zone,
  user_anul character varying(10) NOT NULL DEFAULT ''::character varying,
  no_transacion_anul character varying(10) NOT NULL DEFAULT ''::character varying,
  nit_tercero character varying(15) NOT NULL DEFAULT ''::character varying,
  cod_neg character varying(15) NOT NULL DEFAULT ''::character varying,
  vr_negocio moneda,
  fpago character varying(10) NOT NULL DEFAULT ''::character varying,
  tneg character varying(10) NOT NULL DEFAULT ''::character varying,
  bcocode character varying(20) DEFAULT ''::character varying,
  bcod character varying(20),
  periodo character varying(10) DEFAULT ''::character varying,
  tot_pagado moneda,
  comision numeric(7,2) NOT NULL DEFAULT 0,
  vr_girado moneda DEFAULT 0,
  f_desem timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  nit_fen character varying(15) NOT NULL DEFAULT '8901009858'::character varying,
  cletras character varying(10) NOT NULL DEFAULT '0'::character varying,
  cpagare character varying(20) NOT NULL DEFAULT '0'::character varying,
  cmc character varying(2) NOT NULL DEFAULT '01'::character varying, -- 01 liquidador master ...
  porterem moneda, -- para el liquidador master 0 y para el liquidador de cartera “total remesa + porte”
  tdescuento moneda, -- para el liquidador de cartera es total descuento y para el master 0
  num_aval character varying(20) NOT NULL DEFAULT '0'::character varying,
  banco_cheque character varying(10) DEFAULT '00'::character varying,
  cuenta_cheque character varying(16) DEFAULT ''::character varying,
  valor_aval moneda DEFAULT 0, -- valor del aval
  valor_remesa moneda DEFAULT 0, -- valor de la remesa
  tasa character varying(8) DEFAULT '0'::character varying,
  id_codeudor character varying NOT NULL DEFAULT ''::character varying,
  idendoso character varying NOT NULL DEFAULT ''::character varying,
  cp_pagare character varying NOT NULL DEFAULT ''::character varying,
  co_pagare character varying NOT NULL DEFAULT ''::character varying,
  d_afiliado character varying NOT NULL DEFAULT ''::character varying,
  a_favor character varying NOT NULL DEFAULT ''::character varying,
  cnd_aval character varying(2),
  f_ultimo_reporte timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  tipo_titulo_valor character varying(6) NOT NULL DEFAULT 'CH'::character varying,
  nueva_tasa character varying(1),
  id_convenio integer NOT NULL, -- ID del convenio
  id_remesa integer, -- ID de la remesa
  cod_sector character varying(6),
  cod_subsector character varying(6),
  aval_manual character varying(1) NOT NULL DEFAULT 'N'::character varying,
  actividad character varying(4) NOT NULL DEFAULT 'LIQ'::character varying,
  valor_central numeric NOT NULL DEFAULT 0,
  porcentaje_cat numeric NOT NULL DEFAULT 0,
  valor_capacitacion numeric NOT NULL DEFAULT 0,
  valor_seguro numeric NOT NULL DEFAULT 0,
  fecha_liquidacion timestamp without time zone NOT NULL DEFAULT now(),
  tipo_proceso character varying(3) DEFAULT 'PCR'::character varying,
  tipo_cuota character varying(15) NOT NULL DEFAULT ''::character varying,
  negocio_rel character varying(20) DEFAULT ''::character varying,
  financia_aval boolean DEFAULT false,
  num_pagare character varying(20),
  num_fac_venta_aval character varying(20),
  concepto_neg_rel character varying(20) DEFAULT ''::character varying,
  fecha_actividad timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  pend_perfeccionamiento character varying(1) DEFAULT ''::character varying,
  fecha_factura_aval date,
  negocio_rel_seguro character varying(20) NOT NULL DEFAULT ''::character varying,
  negocio_rel_gps character varying(20) NOT NULL DEFAULT ''::character varying,
  num_ciclo integer,
  estado_cartera character varying(10) NOT NULL DEFAULT ''::character varying,
  etapa_proc_ejec character varying(10) NOT NULL DEFAULT ''::character varying,
  fecha_marcacion_cartera timestamp without time zone,
  fecha_inicio_etapa timestamp without time zone,
  indemnizar character varying(1) DEFAULT 'S'::character varying,
  valor_deducciones numeric(11,2) NOT NULL DEFAULT 0,
  valor_fianza numeric(15,2) NOT NULL DEFAULT 0,
  visto_bueno_fianza character varying(1) NOT NULL DEFAULT 'N'::character varying,
  usuario_visto_bueno character varying(10) NOT NULL DEFAULT ''::character varying,
  responsable_cuenta character varying(100) NOT NULL DEFAULT ''::character varying,
  fecha_reasignacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  fecha_pago_saldo_libranza timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  procesado_mc character varying(1) NOT NULL DEFAULT 'N'::character varying, -- indica si fue enviado para la tabla de traslacion a apoteosys
  procesado_egreso character varying(1) NOT NULL DEFAULT 'N'::character varying, -- indica si fue enviado para la tabla de traslacion a apoteosys
  procesado_lib character varying(1) DEFAULT 'N'::character varying,
  CONSTRAINT fk_convenios FOREIGN KEY (dist, id_convenio)
      REFERENCES convenios (dstrct, id_convenio) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_convenios_remesas FOREIGN KEY (id_remesa)
      REFERENCES convenios_remesas (id_remesa) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_sector FOREIGN KEY (cod_sector)
      REFERENCES sector (cod_sector) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_subsector FOREIGN KEY (cod_sector, cod_subsector)
      REFERENCES subsector (cod_sector, cod_subsector) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE negocios
  OWNER TO postgres;
GRANT ALL ON TABLE negocios TO postgres;
GRANT SELECT ON TABLE negocios TO msoto;
COMMENT ON COLUMN negocios.cod_tabla IS 'En el liquidador master el porcentaje asociado al nit  y a si es cheque o letra a 30 o a 45 dias varia por lo que 
hay que tener un historico para saber cual era la tasa vigente en un momento dado. Este campo permite saber eso. 
Para el liqudador de cartera es vacio.';
COMMENT ON COLUMN negocios.vr_aval IS 'para el liquidador master tasa del proveedor  y para el de cartera antes 0 pero ahora tasa del proveedor (verificar)';
COMMENT ON COLUMN negocios.mod_custodia IS 'para liquidador master 1 es con custodia de cliente y 0 de establecimiento mientras que para el de cartera igual ahora(ojo con el pasado)';
COMMENT ON COLUMN negocios.cmc IS '01 liquidador master 
02 liquidador de cartera';
COMMENT ON COLUMN negocios.porterem IS 'para el liquidador master 0 y para el liquidador de cartera “total remesa + porte”';
COMMENT ON COLUMN negocios.tdescuento IS 'para el liquidador de cartera es total descuento y para el master 0';
COMMENT ON COLUMN negocios.valor_aval IS 'valor del aval';
COMMENT ON COLUMN negocios.valor_remesa IS 'valor de la remesa';
COMMENT ON COLUMN negocios.id_convenio IS 'ID del convenio';
COMMENT ON COLUMN negocios.id_remesa IS 'ID de la remesa';
COMMENT ON COLUMN negocios.procesado_mc IS 'indica si fue enviado para la tabla de traslacion a apoteosys';
COMMENT ON COLUMN negocios.procesado_egreso IS 'indica si fue enviado para la tabla de traslacion a apoteosys';


-- Trigger: actividad_negocio_aval on negocios

-- DROP TRIGGER actividad_negocio_aval ON negocios;

CREATE TRIGGER actividad_negocio_aval
  AFTER UPDATE
  ON negocios
  FOR EACH ROW
  EXECUTE PROCEDURE actividad_negocio_aval();

-- Trigger: cambio_cuenta_reesructuracion on negocios

-- DROP TRIGGER cambio_cuenta_reesructuracion ON negocios;

CREATE TRIGGER cambio_cuenta_reesructuracion
  AFTER UPDATE
  ON negocios
  FOR EACH ROW
  EXECUTE PROCEDURE cambiar_cuentas_reestructuracion_micro();

-- Trigger: dv_negocios_standby on negocios

-- DROP TRIGGER dv_negocios_standby ON negocios;

CREATE TRIGGER dv_negocios_standby
  BEFORE UPDATE
  ON negocios
  FOR EACH ROW
  EXECUTE PROCEDURE dv_negocios_standby();

-- Trigger: etapa_presolicitud on negocios

-- DROP TRIGGER etapa_presolicitud ON negocios;

CREATE TRIGGER etapa_presolicitud
  AFTER UPDATE
  ON negocios
  FOR EACH ROW
  EXECUTE PROCEDURE apicredit.etapa_solicitud();

-- Trigger: inserthistoricopagaresfintracredit on negocios

-- DROP TRIGGER inserthistoricopagaresfintracredit ON negocios;

CREATE TRIGGER inserthistoricopagaresfintracredit
  AFTER UPDATE
  ON negocios
  FOR EACH ROW
  EXECUTE PROCEDURE inserthistoricopagaresfintracredit();
ALTER TABLE negocios DISABLE TRIGGER inserthistoricopagaresfintracredit;

-- Trigger: traza_pagaduria on negocios

-- DROP TRIGGER traza_pagaduria ON negocios;

CREATE TRIGGER traza_pagaduria
  AFTER INSERT
  ON negocios
  FOR EACH ROW
  EXECUTE PROCEDURE traza_pagaduria();

  
--Se agrega campo para guaradar el valor total de las polizas
ALTER TABLE negocios ADD COLUMN valor_total_poliza numeric(15,2) NOT NULL DEFAULT 0;

