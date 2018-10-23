-- Function: sp_colocacion_gerencia(character varying, character varying)

-- DROP FUNCTION sp_colocacion_gerencia(character varying, character varying);

CREATE OR REPLACE FUNCTION sp_colocacion_gerencia(fecha_inicial character varying, fecha_final character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE
   resultado RECORD;
   recaux    RECORD;
BEGIN
   FOR resultado IN (
	SELECT DISTINCT

	    n.cod_neg AS NEGOCIO,
	    n.num_aval AS NUMERO_AVAL,
	    CASE
		WHEN n.tneg='01' THEN 'CHEQUE'
		WHEN n.tneg='02' THEN 'LETRA'
		WHEN n.tneg='03' THEN 'PAGARE'
	    END AS TIPO_NEGOCIO,
	    n.cod_cli AS CODIGO_CLIENTE,
            COALESCE(get_nombc(n.cod_cli),(SELECT nombre FROM solicitud_persona p WHERE p.numero_solicitud=sa.numero_solicitud and tipo='S')) AS  NOMBRE_CLIENTE,
	    COALESCE (sp1.identificacion,sp2.identificacion,'')  AS CODIGO_CODEUDOR,
            COALESCE (sp1.nombre,sp2.nombre,'') AS  nomcod,
            COALESCE (se.codigo,'') AS CODIGO_ESTUDIANTE,
            COALESCE (se.programa,'') AS programa,
	    get_nombp(n.nit_tercero) AS AFILIADO,
            n.nit_tercero AS NIT_AFILIADO,
	    n.vr_negocio,
            n.vr_desembolso,
            n.f_desem AS FECHA_DESEMBOLSO,
            n.vr_aval AS TASA,
            n.valor_aval AS VALOR_AVAL,
            n.vr_custodia,
            n.porc_remesa,
            nro_docs AS CUOTAS,
            get_est(n.estado_neg) AS ESTADO_NEGOCIO,
            n.fecha_negocio,
            n.observaciones AS OBSERVACIONES,
            n.tot_pagado AS VALOR_CARTERA,
            get_nombrebanco(n.banco_cheque) AS  BANCO_CHEQUE,
            COALESCE (conv.nombre,'') AS  CONVENIO,
            conv.id_convenio AS CODIGO_CONVENIO,
            conv.tipo AS  TIPO_CONVENIO,
            s.nombre AS  SECTOR,
            sb.nombre AS  SUBSECTOR,
            COALESCE (sa.numero_solicitud,0) AS  NUMERO_FORMULARIO,
            n.fecha_ap AS FECHA_APROBACION,
            n.fecha_liquidacion,
            coalesce ((SELECT ciclo FROM anexos_negocios nx WHERE nx.codneg=n.cod_neg)::text,'') AS ciclo,
            coalesce ((SELECT  no_solicitud FROM anexos_negocios nx WHERE nx.codneg=n.cod_neg)::text,'') AS no_solicitud,
            ana.analista,
            sa.creation_date AS fecha_solicitud,
            '0099-01-01'::timestamp without time zone AS liquidacion_tra,
            '0099-01-01'::timestamp without time zone AS referenciacion_tra,
	    '0099-01-01'::timestamp without time zone AS analisis_tra,
	    '0099-01-01'::timestamp without time zone AS desicion_tra,
	    '0099-01-01'::timestamp without time zone AS desembolso_tra,
	    '0099-01-01'::timestamp without time zone AS formalizacion_tra,
	    '0099-01-01'::timestamp without time zone AS radicacion_tra,
            (SELECT f.fecha_vencimiento FROM con.factura f WHERE f.negASoc = n.cod_neg and f.valor_saldo >0.00 order by f.fecha_vencimiento ASc limit 1 ) AS vencimiento_mayor,
            (SELECT sum(f.valor_saldo) FROM con.factura f WHERE f.negASoc = n.cod_neg ) AS saldo_cartera,
            n.create_user AS USUARIO_CREACION

            FROM
            Negocios n
            inner join convenios conv on(conv.id_convenio=n.id_convenio)
            left join sector    s on (s. cod_sector=n. cod_sector)
            left join subsector    sb on (sb.cod_subsector=n.cod_subsector and sb.cod_sector=n.cod_sector)
            left join negocios_analista ana on (ana.cod_neg=n.cod_neg)

	    left join solicitud_aval sa on sa.cod_neg=n.cod_neg
	    left join solicitud_persona sp1 on sp1.tipo='C' and sp1.numero_solicitud=sa.numero_solicitud
	    left join solicitud_persona sp2 on sp2.tipo='E' and sp2.numero_solicitud=sa.numero_solicitud
	    left join solicitud_estudiante se on se.numero_solicitud=sa.numero_solicitud

            WHERE n.creation_date  between fecha_inicial and fecha_final
            --WHERE n.creation_date  between '2015-01-01' and '2015-01-03'
            order by n.fecha_negocio desc,n.f_desem desc
   ) LOOP
	FOR recaux IN (SELECT distinct actividad, max(fecha) as fecha FROM negocios_trazabilidad WHERE numero_solicitud=resultado.numero_formulario group by 1) LOOP
	    IF    recaux.actividad='LIQ' THEN resultado.liquidacion_tra = recaux.fecha;
	    ELSIF recaux.actividad='REF' THEN resultado.referenciacion_tra = recaux.fecha;
	    ELSIF recaux.actividad='ANA' THEN resultado.analisis_tra = recaux.fecha;
	    ELSIF recaux.actividad='DEC' THEN resultado.desicion_tra = recaux.fecha;
	    ELSIF recaux.actividad='DES' THEN resultado.desembolso_tra = recaux.fecha;
	    ELSIF recaux.actividad='FOR' THEN resultado.formalizacion_tra = recaux.fecha;
	    ELSIF recaux.actividad='RAD' THEN resultado.radicacion_tra = recaux.fecha;
	    END IF;
	END LOOP;
	return next resultado;
   END LOOP;
END
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_colocacion_gerencia(character varying, character varying)
  OWNER TO postgres;
