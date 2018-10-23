-- Function: generar_eg_globales(text, text, text, text)

-- DROP FUNCTION generar_eg_globales(text, text, text, text);

CREATE OR REPLACE FUNCTION generar_eg_globales(text, text, text, text)
  RETURNS text AS
$BODY$



DECLARE
    _documento ALIAS FOR   $1; 		/* Numero del documento para la EG con nomenclatura EGaaaamm-sss, ano, mes, secuencia */
    _periodo_documento ALIAS FOR $2;  	/* Periodo del documento que selecciona las NC, debe ser igual al aaaamm de la nomenclatura del */
                                        /* documento  pero con formato AAAA-MM, donde AAAA = aaaa y MM = mm */

    _fecha_creacion ALIAS FOR   $3;	/* Fecha creacion del registro en la BD, con formato AAAA-MM-DD HH:MM:SS */
    _fecha_seleccion  ALIAS FOR  $4;  	/* Fecha de creacion de las NC que seran seleccionadas para la creacion de la EG. Formato AAAA-MM-DD */

    _resultado TEXT;


BEGIN


	select into _resultado SETVAL('SecuenciaItem', 0) ;

	drop table tem.eg_detalle;


	create table tem.eg_detalle as
	   select
	       a.reg_status, a.dstrct, a.proveedor, 'FAP'::character varying(15) as tipo_documento,
	       _documento::character varying(30) as documento ,
	       substr( (nextval('SecuenciaItem')+10000 )::character varying(30), 2,4) as item,
	       a.descripcion, a.vlr, a.vlr_me, '23050907'::character varying(30) as codigo_cuenta, a.codigo_abc, a.planilla,
	       now()::timestamp without time zone as last_update ,
	       a.user_update,

	       _fecha_creacion::timestamp without time zone as creation_date,
	       a.creation_user, a.base,
	       a.codcliarea, a.tipcliarea, a.concepto, a.auxiliar, a.tipo_referencia_1,
	       a.referencia_1, a.tipo_referencia_2, a.referencia_2, 'NC'::character varying(5) as tipo_referencia_3,
	       a.documento as referencia_3
	   from
	     fin.cxp_doc b,
	     fin.cxp_items_doc a
	   where
	     b.dstrct = 'FINV' and
	     b.tipo_documento = 'NC' and
	    (b.documento like 'CE%' or b.documento like 'EC%') and
            (b.documento like '%IA%' or b.documento like '%IC%') and
	     b.creation_date >= _fecha_seleccion and
	     substr(b.fecha_documento::character varying,1,7) = _periodo_documento and
	     a.dstrct = b.dstrct and
	     a.proveedor = b.proveedor and
	     a.tipo_documento = b.tipo_documento and
	     a.documento = b.documento
	   order by
	     b.documento;



	drop table tem.eg_cabecera;

	create table tem.eg_cabecera as


	select
	  ''::character varying(1) as reg_status,
	  'FINV'::character varying(15) as dstrct,
	  '8020076706'::character varying(15) as proveedor,
	  'FAP'::character varying(15) as tipo_documento,
	  a.documento,
	  'Factura global de comision eca '||a.documento::text as descripcion ,
	  'BQ'::character varying(15) as agencia,
	  'FC'::character varying(15) as handle_code,
	  ''::character varying(15) as id_mims,
	  ''::character varying(15) as tipo_documento_rel,
	  ''::text as documento_relacionado,
	  '0099-01-01 00:00:00'::timestamp without time zone as fecha_aprobacion,
	  'JGOMEZ'::character varying(15) as aprobador, ''::character varying(15) as usuario_aprobacion,

	  'ABONO PRESTAMOS'::character varying(30) as banco, 'CC'::character varying(30) as sucursal,
	  'PES'::character varying(15) as moneda,
	  a.vlr::moneda as vlr_neto,
	  0.00::moneda as vlr_total_abonos,
	  a.vlr::moneda  as vlr_saldo,
	  a.vlr::moneda  as vlr_neto_me,
	  0.00::moneda  as vlr_total_abonos_me,
	  a.vlr::moneda  as vlr_saldo_me,
	  1.0::numeric(18,10) as tasa,
	  ''::character varying(15) as usuario_contabilizo,
	  '0099-01-01 00:00:00'::timestamp without time zone as fecha_contabilizacion,
	  ''::character varying(15) as usuario_anulo,
	  '0099-01-01 00:00:00'::timestamp without time zone as fecha_anulacion,
	  '0099-01-01 00:00:00'::timestamp without time zone as fecha_contabilizacion_anulacion,

	  ''::text as observacion, 0::numeric(5,0) as num_obs_autorizador,
	  0::numeric(5,0) as num_obs_pagador,
	  0::numeric(5,0) as num_obs_registra,
	  '0099-01-01 00:00:00'::timestamp without time zone as last_update,
	  'APABON':: character varying as user_update,
	  _fecha_creacion::timestamp without time zone as creation_date,
	  'APABON':: character varying(15) as creation_user,
	  'COL'::character varying(3) as base,
	  ''::character varying(10) as corrida, ''::character varying(30) as cheque,
	  ''::character varying(6) as periodo,
	  '0099-01-01 00:00:00'::timestamp without time zone as fecha_procesado,
	  '0099-01-01 00:00:00'::timestamp without time zone as fecha_contabilizacion_ajc,
	  '0099-01-01 00:00:00'::timestamp without time zone as fecha_contabilizacion_ajv,
	  ''::character varying(6) as periodo_ajc,
	  ''::character varying(6) as periodo_ajv, ''::character varying(15) as usuario_contabilizo_ajc,
	  ''::character varying(15) as usuario_contabilizo_ajv, 0::integer as transaccion_ajc,
	  0::integer as transaccion_ajv, '4'::character varying(1) as clase_documento,
	  0::integer as transaccion,
	  'PES'::character varying(3) as moneda_banco,
	  (substr(a.documento,3,4)||'-'||substr(a.documento,7,2)||'-28')::date  as fecha_documento,
	  (substr(a.documento,3,4)||'-'||substr(a.documento,7,2)||'-28')::date  as  fecha_vencimiento,
	  '0099-01-01'::date as  ultima_fecha_pago,
	  'N'::character varying(1) as flujo, 0::integer as transaccion_anulacion,
	  'N'::character varying(1) as ret_pago, ''::character varying(3) as clase_documento_rel,
	  ''::character varying(5) as tipo_referencia_1, ''::character varying(30)  as referencia_1,
	  ''::character varying(5) as tipo_referencia_2, ''::character varying(30)  as referencia_2,
	  ''::character varying(5) as tipo_referencia_3, ''::character varying(30)  as referencia_3,
	  ''::character varying(1) as indicador_traslado_fintra,
	  'N'::character varying(1) as factoring_formula_aplicada

	from

	  (select
	     documento,
	     sum(vlr) as vlr
	   from
	     tem.eg_detalle
	   group by
	     documento
	   order by
	     documento ) a ;

	INSERT INTO fin.cxp_doc
	select * from tem.eg_cabecera;

	INSERT INTO fin.cxp_items_doc
	select * from tem.eg_detalle;


    RETURN 'Proceso ejecutado.';


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION generar_eg_globales(text, text, text, text)
  OWNER TO web;
