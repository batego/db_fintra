-- Function: mc_ajuste_al_peso()

-- DROP FUNCTION mc_ajuste_al_peso();

CREATE OR REPLACE FUNCTION mc_ajuste_al_peso()
  RETURNS boolean AS
$BODY$

DECLARE 
resultado RECORD;
infofactura record;
serie record;

valor_abono_factura numeric;
valor_saldo_factura numeric;
info_cmc record;
respuesta boolean :=false;


BEGIN

	for resultado in 
			SELECT 
			factura::varchar
			,codcli::varchar as codigo_cliente
			,descripcion::varchar
			,concepto::varchar
			,valor::numeric
			,cuenta_ajuste::varchar
			,banco::varchar
			,sucursal::varchar
			,generado::varchar
			,creation_user::varchar
			,nota_ajuste::varchar
			,fecha_consignacion::date
			FROM tem.historico_ajuste_peso 
			where generado ='N'
			and reg_status = ''
	loop

		for infofactura in 
			select 
			documento::varchar
			,nit::numeric
			,codcli::varchar
			,fecha_factura::varchar
			,fac.cmc::varchar
			,''::varchar as consecutivo
			,valor_factura::numeric
			,valor_abono::numeric
			,valor_saldo::numeric
			,valor_facturame::numeric
			,valor_abonome::numeric
			,valor_saldome::numeric 
			,cmc.cuenta::varchar
			from con.factura fac
			inner join con.cmc_doc cmc on (fac.cmc = cmc.cmc and  fac.tipo_documento =cmc.tipodoc )
			where documento = resultado.factura 
			and fac.reg_status =''
			and tipo_documento ='FAC'
		loop
	
			select into serie
			get_lcod('ICAC') as ultimo_prefijo_numero;
			
			raise notice 'serie: %',serie.ultimo_prefijo_numero;
			infofactura.consecutivo= serie.ultimo_prefijo_numero;
			
			raise notice 'valor_factura: %',infofactura.valor_factura;
			raise notice 'valor_abono: %',infofactura.valor_abono;
			raise notice 'valor_saldo: %',infofactura.valor_saldo;

			
			valor_saldo_factura := infofactura.valor_saldo -  resultado.valor;
			valor_abono_factura := infofactura.valor_abono + resultado.valor;
			raise notice 'valor_abono_factura: %',valor_abono_factura;
			raise notice 'valor_saldo_factura: %',valor_saldo_factura;

			
			INSERT INTO con.ingreso(
				dstrct, tipo_documento, num_ingreso, codcli, nitcli, 
				concepto, tipo_ingreso, fecha_consignacion, fecha_ingreso, branch_code, 
				bank_account_no, codmoneda, agencia_ingreso, descripcion_ingreso, 
				vlr_ingreso, vlr_ingreso_me, vlr_tasa, fecha_tasa, cant_item, 
				creation_user, creation_date,base,cuenta, cmc)
			VALUES (
				'FINV', 'ICA', serie.ultimo_prefijo_numero, resultado.codigo_cliente, infofactura.nit,
				'FE', 'C', resultado.fecha_consignacion, NOW()::DATE, resultado.banco,
				resultado.sucursal,'PES', 'OP', 'AJUSTE AL PESO',
				resultado.valor,resultado.valor, 1, NOW()::DATE, 1,
				resultado.creation_user, NOW(),'COL', resultado.cuenta_ajuste, infofactura.cmc);

			INSERT INTO con.ingreso_detalle(
				dstrct, tipo_documento, num_ingreso, item, nitcli, 
				valor_ingreso, valor_ingreso_me, fecha_factura,  creation_user, 
				creation_date,  base, cuenta, 
				descripcion, valor_tasa, saldo_factura,tipo_doc,documento,factura)
			VALUES (
				'FINV', 'ICA', serie.ultimo_prefijo_numero, 1, infofactura.nit,
				 resultado.valor,resultado.valor, now()::date, resultado.creation_user,
				 NOW(),'COL', infofactura.cuenta , resultado.descripcion,1, resultado.valor,'FAC',resultado.factura,resultado.factura);

			update con.factura set 
				valor_saldo = valor_saldo_factura,
				valor_saldome = valor_saldo_factura,
				valor_abono = valor_abono_factura,
				valor_abonome = valor_abono_factura,
				last_update = now()
			where documento  = infofactura.documento  and documento = resultado.factura and tipo_documento = 'FAC';
			
			update tem.historico_ajuste_peso set generado ='S',nota_ajuste = serie.ultimo_prefijo_numero  where factura = infofactura.documento and codcli = infofactura.codcli;
			
			
			
		end loop;
		respuesta:= true;
		
	end loop;
	return  respuesta;
	EXCEPTION
	WHEN NO_DATA_FOUND THEN 
	RAISE EXCEPTION 'No data found';
	resultado.cambio:= 'error';
	return  resultado;
	
	WHEN unique_violation THEN 
	RAISE EXCEPTION 'UNIQUE VIOLATION';
	resultado.cambio:= 'violacion llave';
	return  resultado;
END;
		
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION mc_ajuste_al_peso()
  OWNER TO postgres;

