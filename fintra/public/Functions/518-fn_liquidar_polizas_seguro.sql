-- Function: fn_liquidar_polizas_seguro(character varying, character varying, numeric, integer, date, character varying, character varying, date, character varying, character varying)

-- DROP FUNCTION fn_liquidar_polizas_seguro(character varying, character varying, numeric, integer, date, character varying, character varying, date, character varying, character varying);

CREATE OR REPLACE FUNCTION fn_liquidar_polizas_seguro(
    _id_convenio character varying,
    _id_suscursal character varying,
    _valor_negocio numeric,
    _num_cuotas integer,
    _fecha_primera_cuota date,
    _tipo_cuota character varying,
    _agencia character varying,
    _fecha_renovacion date,
    _renovacion character varying,
    _codigo character varying)
  RETURNS text AS
$BODY$

DECLARE

	_config_poliza RECORD;
	_resp varchar;
	_valor_poliza numeric;
	_valor_total_polizas numeric=0;
	_valor_polizas_cuota_cuota numeric=0;
	_ciudad varchar;
	_valorbase numeric;
	_fecha date;
	_v_i int;
	_fecha_vencimiento date;
	_compra_cartera varchar;

BEGIN
				
	
				delete from detalle_poliza_negocio where cod_neg=_codigo;			
				
				select into _compra_cartera case when count(soc.numero_solicitud) >0  
				then 'S' 
				else 'N' end as compra_cartera  
				from solicitud_aval sa 
				inner join solicitud_obligaciones_comprar soc on soc.numero_solicitud=sa.numero_solicitud
				where sa.numero_solicitud=_codigo;
				
				for _config_poliza in
				select cp.id,np.descripcion,cp.id_unidad_negocio,cp.id_sucursal,tc.tipo as tipo_cobro,tc.financiacion,
				tvp.tipo as tipo_vp,tvp.calcular_sobre,tvp.valor_absoluto,tvp.valor_porcentaje
				from administrativo.nueva_configuracion_poliza cp
				inner join administrativo.nuevas_polizas np on cp.id_poliza=np.id
				inner join administrativo.tipo_cobro tc on cp.id_tipo_cobro=tc.id 
				inner join administrativo.tipo_valor_poliza tvp on cp.id_valor_poliza=tvp.id
				inner join rel_unidadnegocio_convenios un on un.id_unid_negocio=cp.id_unidad_negocio
				where un.id_convenio=_id_convenio and  cp.id_sucursal=_id_suscursal and cp.reg_status='' --and tc.financiacion='N' 
				
				loop
				
				if _config_poliza.tipo_vp='A' then 
					raise notice '_config_poliza.tvp.tipo: %', _config_poliza.tipo_vp;
					_valor_poliza = _config_poliza.valor_absoluto;
					raise notice '_config_poliza.valor_absoluto: %',_valor_poliza;
				
				elsif _config_poliza.tipo_vp='P' and  _config_poliza.calcular_sobre='K' then
				
					raise notice '_config_poliza.tvp.tipo + K: %', _config_poliza.tipo_vp;				
					_valor_poliza = _valor_negocio * (_config_poliza.valor_porcentaje/100);
					raise notice '_config_poliza.valor_porcentaje K: %',_valor_poliza;
				
				elsif _config_poliza.tipo_vp='P' and  _config_poliza.calcular_sobre='KI' then
					raise notice '_config_poliza.tvp.tipo + KI: %', _config_poliza.tipo_vp;	
					
						if _agencia='ATL' then 
						_ciudad='BQ';
						elsif _agencia='COR' then 
						_CIUDAD='MT';
						elseif _agencia='SUC' then
						_ciudad='SI';					
						end if;
						raise notice 'ciudad: %', _ciudad;
					
					if _renovacion='S' then
					_fecha=_fecha_renovacion;
					else
					_fecha=now();
					end if;
					
					SELECT into _valorbase sum(capital)+sum(interes) as valorBase FROM  apicredit.eg_simulador_liquidacion_micro_fecha
	            	(_valor_negocio::numeric, _num_cuotas::integer,_fecha_primera_cuota::date,_tipo_cuota::varchar,_ciudad::varchar,_fecha::date,_compra_cartera::varchar) as retorno;
	            	
	            	_valor_poliza = _valorbase * (_config_poliza.valor_porcentaje/100);

	            	raise notice '_config_poliza.valor_porcentaje KI: %',_valor_poliza;
					
				end if;
				
				_fecha_vencimiento=CURRENT_TIMESTAMP;
			
				FOR v_i IN 1.._num_cuotas
				
				loop
				
				_fecha_vencimiento=_fecha_vencimiento + CAST('1 MONTH' AS INTERVAL);
				
				
				
				INSERT INTO detalle_poliza_negocio
				(cod_neg, id_configuracion_poliza, fecha_vencimiento, item, valor)
				VALUES(_codigo, _config_poliza.id, _fecha_vencimiento, v_i, _valor_poliza); 
				
				_valor_total_polizas=_valor_total_polizas + _valor_poliza;							
				
				end loop;
				
				if _config_poliza.tipo_cobro='C' then
				
				_valor_polizas_cuota_cuota=_valor_polizas_cuota_cuota+_valor_poliza;
				
				end if;
				
				
				end loop;
				
				update negocios set valor_total_poliza=_valor_total_polizas where cod_neg=_codigo;
				raise notice '_valor_total_polizas: %',_valor_total_polizas;
				
	RETURN _valor_polizas_cuota_cuota;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION fn_liquidar_polizas_seguro(character varying, character varying, numeric, integer, date, character varying, character varying, date, character varying, character varying)
  OWNER TO postgres;

