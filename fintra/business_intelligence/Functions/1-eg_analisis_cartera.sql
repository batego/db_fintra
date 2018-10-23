-- Function: business_intelligence.eg_analisis_cartera(integer)

-- DROP FUNCTION business_intelligence.eg_analisis_cartera(integer);

CREATE OR REPLACE FUNCTION business_intelligence.eg_analisis_cartera(_unidad_negocio integer)
  RETURNS SETOF business_intelligence.rs_datos_cartera AS
$BODY$

DECLARE

 rs business_intelligence.rs_datos_cartera;
 recordNeg record;

 --DECLARAMOS EL CURSOR
 cursor_cartera CURSOR FOR (SELECT     t.descripcion as unidad_negocio
				       ,foto.negasoc  as cod_negocio
				       ,eg_tipo_negocio(foto.negasoc) as tipo_negocio
				       ,foto.nit as identificacion
				       ,get_nombc(foto.nit) as nombre_cliente
				       ,sp.direccion
				       ,sp.telefono
				       ,sp.celular
				       ,sp.barrio
				       ,sa.responsable_cuenta
				       ,CASE WHEN neg.tipo_cuota='CTFCPV' THEN 'CUOTA FIJA' ELSE 'CUOTA VARIABLE' END AS tipo_cuota
				       ,neg.f_desem::date as fecha_desembolso
				       ,max(foto.fecha_vencimiento)::date as ultimo_vencimiento
				       ,min(foto.fecha_vencimiento)::date as vencimiento_mayor
				       ,'0099-01-01'::date AS proximo_vencimiento
				       ,neg.vr_negocio as valor_negocio
				       ,sum(foto.valor_saldo) as valor_saldo_foto
				       ,(now()::date-min(foto.fecha_vencimiento)::date) as dias_mora
				       ,CASE WHEN neg.tipo_cuota='CTFCPV' THEN
							(SELECT valor FROM documentos_neg_aceptado  where cod_neg=foto.negasoc and reg_status='' group by valor having count(0) >1)
					     ELSE 0.00 END as valor_cuota
				       ,0::integer as cuotas_vencidas
				       ,0.00::numeric as saldo_actual
				       ,0.00::numeric as saldo_por_vencer
				FROM con.foto_cartera foto
				INNER JOIN negocios neg on (foto.negasoc=neg.cod_neg)
				INNER JOIN solicitud_aval sa on (sa.cod_neg=neg.cod_neg)
				INNER JOIN solicitud_persona sp on (sp.numero_solicitud=sa.numero_solicitud and sp.tipo='S')
				INNER JOIN (SELECT un.id, un.descripcion,run.id_convenio FROM rel_unidadnegocio_convenios run
					    INNER JOIN unidad_negocio un  on (run.id_unid_negocio=un.id)
					    WHERE un.id in (1,2,3,4,8,9,10,22)) t on (t.id_convenio=neg.id_convenio)
				WHERE periodo_lote=replace(substring(now(),1,7),'-','')
				--AND foto.negasoc='MC06993'
				AND t.id=_unidad_negocio
				AND foto.reg_status=''
				AND foto.dstrct='FINV'
				AND foto.tipo_documento IN ('FAC','NDC')
				AND substring(foto.documento,1,2) not in ('CP','FF','DF')
				AND foto.valor_saldo >0
				AND foto.fecha_vencimiento::DATE  < NOW()::DATE
				AND neg.id_convenio not in (37)
				GROUP BY
				 t.descripcion
				,neg.tipo_cuota
				,neg.f_desem::date
				,vr_negocio
				,foto.nit
				,sp.direccion
				,sp.telefono
				,sp.celular
				,sp.barrio
				,sa.responsable_cuenta
				,foto.negasoc
				ORDER BY foto.negasoc,foto.nit
			);


BEGIN
	--ABRIMOS EL CURSOR SIN PARAMETROS
	OPEN cursor_cartera ;
	<<_loop>>
	LOOP
		-- FETCH FILA EN MY RECORD O TYPE
		FETCH cursor_cartera INTO recordNeg;
		-- EXIT CUANDO NO HAY MAS FILAS
		EXIT WHEN NOT FOUND;

		raise notice 'recordNeg.vencimiento_mayor: %',recordNeg.vencimiento_mayor;

		--saldo actual
		SELECT INTO recordNeg.saldo_actual coalesce(sum(valor_saldo),0.00) as valor_saldo
		FROM con.factura fc
		WHERE
		fc.valor_saldo > 0
		AND fc.reg_status = ''
		AND fc.dstrct = 'FINV'
		AND fc.tipo_documento IN ('FAC','NDC')
		AND SUBSTRING(fc.documento,1,2) NOT IN ('CP','FF','DF')
		AND fc.negasoc =recordNeg.cod_negocio
		AND fc.fecha_vencimiento::DATE  < NOW()::DATE;

		--saldo por vencer
		select into recordNeg.saldo_por_vencer  coalesce(sum(valor),0.00) from documentos_neg_aceptado
		where cod_neg=recordNeg.cod_negocio AND reg_status='' and fecha::date > recordNeg.ultimo_vencimiento::date;

		--cuotas vencidas
		SELECT INTO recordNeg.cuotas_vencidas coalesce(COUNT(0),0) as cuotas_vencidas FROM (
			SELECT num_doc_fen as cuota, count(0) as facturas FROM con.factura
			WHERE negasoc=recordNeg.cod_negocio
			AND reg_status = ''
			AND valor_saldo >0
			AND fecha_vencimiento::DATE  < NOW()::DATE
			AND tipo_documento IN ('FAC','NDC')
			AND substring(documento,1,2) not in ('CP','FF','DF')
			group by  num_doc_fen
			order by num_doc_fen::integer
			) t ;



		--proximo vencimiento

		recordNeg.proximo_vencimiento:=COALESCE((SELECT fecha FROM documentos_neg_aceptado  WHERE cod_neg=recordNeg.cod_negocio AND fecha::DATE > recordNeg.ultimo_vencimiento::DATE ORDER BY fecha LIMIT 1),'0099-01-01');
		--'2017-02-12'


		rs.unidad_negocio :=recordNeg.unidad_negocio;
		rs.cod_negocio :=recordNeg.cod_negocio;
		rs.tipo_negocio :=recordNeg.tipo_negocio;
		rs.identificacion :=recordNeg.identificacion;
		rs.nombre_cliente :=recordNeg.nombre_cliente;
		rs.direccion :=recordNeg.direccion;
		rs.telefono :=recordNeg.telefono;
		rs.celular :=recordNeg.celular;
		rs.barrio :=recordNeg.barrio;
		rs.responsable_cuenta:=recordNeg.responsable_cuenta;
 		rs.tipo_cuota :=recordNeg.tipo_cuota;
 		rs.fecha_desembolso :=recordNeg.fecha_desembolso;
 		rs.vencimiento_mayor :=recordNeg.vencimiento_mayor;
 		rs.ultimo_vencimiento :=recordNeg.ultimo_vencimiento;
 		rs.proximo_vencimiento :=recordNeg.proximo_vencimiento;
 		rs.valor_negocio :=recordNeg.valor_negocio;
 		rs.valor_saldo_foto :=recordNeg.valor_saldo_foto;
 		rs.dias_mora :=	recordNeg.dias_mora;
 		rs.valor_cuota := recordNeg.valor_cuota;
 		rs.cuotas_vencidas :=recordNeg.cuotas_vencidas;
 		rs.saldo_actual := recordNeg.saldo_actual;
 		rs.saldo_por_vencer := recordNeg.saldo_por_vencer;
		rs.saldo_total:=recordNeg.saldo_actual+recordNeg.saldo_por_vencer;

		RETURN NEXT rs;


	END LOOP  _loop ;

	--CERRAMOS EL CURSOR
	CLOSE cursor_cartera;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION business_intelligence.eg_analisis_cartera(integer)
  OWNER TO postgres;
