-- Function: mc_reliquidar_libranza(numeric, integer, character varying, date, date, character varying, character varying, numeric)

-- DROP FUNCTION mc_reliquidar_libranza(numeric, integer, character varying, date, date, character varying, character varying, numeric);

CREATE OR REPLACE FUNCTION mc_reliquidar_libranza(_valor_desembolso numeric, _numero_cuotas integer, _tipo_cuota character varying, _fecha_calculo date, _fecha_primera_cuota date, formulario character varying, usuario_ character varying, valor_fianza_ numeric)
  RETURNS boolean AS
$BODY$
DECLARE

resultado boolean := false;
total_pagar_ numeric := 0;
negocio varchar;
cuotas varchar;
liquidador record;
estadoActNeg record;	

BEGIN
		--se busca el negocio
		select into negocio cod_neg from solicitud_aval where numero_solicitud = formulario;
		raise notice 'negocio %',negocio;

		--se borra los registros existentes en el liquidador
		delete from documentos_neg_aceptado where cod_neg = negocio;
		
		--se liquida el negocio y se inserta
		for  liquidador in
			select  * from fn_liquidacion_libranza('PRINCIPAL', _valor_desembolso, _numero_cuotas , '38', _tipo_cuota, _fecha_calculo, _fecha_primera_cuota)
		loop
			total_pagar_ := total_pagar_ + liquidador.valor;
			
			raise notice 'total_pagar_ %',total_pagar_;

			INSERT INTO documentos_neg_aceptado(
				cod_neg, item, fecha, dias, saldo_inicial, capital, interes, 
				valor, saldo_final,creation_date, no_aval, capacitacion, 
				cat, seguro,   
				custodia, remesa, tipo, cuota_manejo 
				)
			VALUES (negocio, liquidador.item, liquidador.fecha, liquidador.dias, liquidador.saldo_inicial, liquidador.capital, liquidador.interes, 
				liquidador.valor, liquidador.saldo_final, now(), liquidador.no_aval, liquidador.capacitacion, 
				liquidador.cat,liquidador.seguro,  
				liquidador.custodia, liquidador.remesa,  liquidador.tipo, liquidador.cuota_manejo
				);

		end loop;

		select into cuotas item::numeric  from documentos_neg_aceptado where cod_neg = negocio order by item::numeric desc limit 1;

		--se busca el estado y actividad anterior y se actualiza el negocio
		select into estadoActNeg 
			case when actividad in ( 'ANA' ,'REF' ,'RAD')then 'P'
			     when actividad in ('LIQ') then 'P' 
			     when actividad in ('DEC') then 'V' 
			     when actividad in ('FOR') then 'A' 
			     when actividad in ('PFCC') then 'L' end as estado,
			actividad,cod_neg 
		from negocios_trazabilidad 
		where  numero_solicitud = formulario
		and concepto not in ( 'ZONGRILI','RELIQUIDAR')  
		order by fecha desc limit 1;
		
		update negocios set 
			nro_docs = cuotas, vr_desembolso = _valor_desembolso, vr_negocio = _valor_desembolso, uptade_date = now(), update_user = usuario_, estado_neg = estadoActNeg.estado,
			actividad = estadoActNeg.actividad , fecha_negocio = now(), valor_fianza = valor_fianza_, tot_pagado = total_pagar_, fecha_liquidacion = now()
		where cod_neg = negocio;

		--se actualiza la libranza
		update solicitud_aval set 
			valor_solicitado = total_pagar_ ,plazo = cuotas, last_update = now() ,user_update = usuario_, estado_sol = estadoActNeg.estado, fecha_primera_cuota = _fecha_primera_cuota
		where cod_neg = negocio;

		--se inserta la trazabilidad
		INSERT INTO negocios_trazabilidad
                   (numero_solicitud,  actividad,
                   usuario,  fecha,  cod_neg, comentarios)
                VALUES (
                   formulario::integer, 'LIQ', usuario_, now(), negocio, 'Fue reliquidado por un valor de: '||_valor_desembolso
			);

		
		resultado:= TRUE;


return resultado;

END
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION mc_reliquidar_libranza(numeric, integer, character varying, date, date, character varying, character varying, numeric)
  OWNER TO postgres;

