-- Function: eg_corregir_cartera_microcredito(character varying, numeric, integer, date, character varying, character varying, date)

-- DROP FUNCTION eg_corregir_cartera_microcredito(character varying, numeric, integer, date, character varying, character varying, date);

CREATE OR REPLACE FUNCTION eg_corregir_cartera_microcredito(negocio character varying, valor_negocio numeric, num_cuotas integer, fecha_pr_cuota date, tipo_liquidacion character varying, id_convenio character varying, fecha_liquidacion date)
  RETURNS text AS
$BODY$
DECLARE
 retorno TEXT:='OK' ;
 valorAbono numeric:=0;

BEGIN
	/******************************************************************************************************************************************
	* Parametros: 																 *
	* negocio: Numero de negocio a procesar.												 *
	* valor_negocio: valor de negocio ingresado en el formulario de credito									 *
	* num_cuotas: numero de cuotas o plazo a finaciar el negocio										 *
	* fecha_pr_cuota: fecha de la primera cuota de acuerdo al ciclo de pago (2,12,17,22)							 *
	* tipo_liquidacion : CPFCTV::capital fijo cuota variable ::tipo_liquidacion o CTFCPV::cuata fija capital variable ::tipo_liquidacion	 *
	* id_convenio : identificador del convenio de microcredito (10,11,12,13)								 *
	* fecha_liquidacion: fecha en que se realiza la liquidacion del negocio.								 *
        *																	 *
        * Autor: Ing. Edgar Gonzalez Mendoza , fecha :2016-01-06										 *
	******************************************************************************************************************************************/


	select into valorAbono SUM(valor_abono) from con.factura where  negasoc=negocio  and reg_status='';

	if(valorAbono=0)then

		--1.)ACTUALIZAMOS LA TABLA DE LIQUIDACION CON LA NUEVA LIQUIDACION..

		update documentos_neg_aceptado set
			saldo_inicial=mi_liqudiador.saldo_inicial
			,valor=mi_liqudiador.valor_cuota
			,capital=mi_liqudiador.capital
			,interes=mi_liqudiador.interes
			,capacitacion=mi_liqudiador.capacitacion
			,cat=mi_liqudiador.cat
			,seguro=mi_liqudiador.seguro
			,saldo_final=mi_liqudiador.saldo_final
		from (
			select
				negocio as cod_neg,
				fecha::date,
				item as cuota,
				saldo_inicial,
				round(valor) as valor_cuota,
				capital,
				interes,
				capacitacion,
				cat ,
				seguro,
				saldo_final
			from eg_simulador_liquidacion_micro_fecha(valor_negocio::numeric, num_cuotas::integer, fecha_pr_cuota::date, tipo_liquidacion::character varying, id_convenio::character varying, fecha_liquidacion::date)
		      )as mi_liqudiador
		where documentos_neg_aceptado.cod_neg=mi_liqudiador.cod_neg
		and documentos_neg_aceptado.fecha=mi_liqudiador.fecha
		and documentos_neg_aceptado.item=mi_liqudiador.cuota;


		--2.)ACTUALIZA CAPITAL FACTURA DETALLE MICRO CREDITO---
		update  con.factura_detalle
		set
		valor_unitario=mi_tabla_tem.capital,
		valor_unitariome=mi_tabla_tem.capital,
		valor_item=mi_tabla_tem.capital,
		valor_itemme=mi_tabla_tem.capital
		FROM (
			SELECT
			fac.negasoc ,
			dnas.fecha::date,
			dnas.item as cuota,
			dnas.saldo_inicial,
			dnas.valor as valor_cuota,
			dnas.capital,
			dnas.interes,
			dnas.capacitacion,
			dnas.cat ,
			dnas.seguro,
			dnas.saldo_final,
			facdt.documento,
			facdt.descripcion
			FROM con.factura_detalle facdt
			inner join con.factura fac on (fac.documento=facdt.documento)
			inner join documentos_neg_aceptado dnas on (dnas.cod_neg=fac.negasoc and dnas.item=fac.num_doc_fen)
			where fac.negasoc =negocio  and facdt.descripcion='CAPITAL' and substring(fac.documento,1,2)='MC'   and fac.reg_status=''
			order by dnas.item::integer
		     ) as mi_tabla_tem
		where con.factura_detalle.documento=mi_tabla_tem.documento
		and con.factura_detalle.descripcion=mi_tabla_tem.descripcion;


		--3.)ACTUALIZA INTERES FACTURA DETALLE MICRO CREDITO---
		update  con.factura_detalle
		set
		valor_unitario=mi_tabla_tem.interes,
		valor_unitariome=mi_tabla_tem.interes,
		valor_item=mi_tabla_tem.interes,
		valor_itemme=mi_tabla_tem.interes
		FROM (
			SELECT
			fac.negasoc ,
			dnas.fecha::date,
			dnas.item as cuota,
			dnas.saldo_inicial,
			dnas.valor as valor_cuota,
			dnas.capital,
			dnas.interes,
			dnas.capacitacion,
			dnas.cat ,
			dnas.seguro,
			dnas.saldo_final,
			facdt.documento,
			facdt.descripcion
			FROM con.factura_detalle facdt
			inner join con.factura fac on (fac.documento=facdt.documento)
			inner join documentos_neg_aceptado dnas on (dnas.cod_neg=fac.negasoc and dnas.item=fac.num_doc_fen)
			where fac.negasoc =negocio and facdt.descripcion='BQ-013-FENALCO-OTROS  INTERESES' and substring(fac.documento,1,2)='MI'  and fac.reg_status=''
			order by dnas.item::integer

		  ) as mi_tabla_tem
		where con.factura_detalle.documento=mi_tabla_tem.documento
		and  con.factura_detalle.descripcion=mi_tabla_tem.descripcion;


		---4.)ACTUALIZA CAT FACTURA DETALLE MICRO CREDITO---
		update  con.factura_detalle
		set
		valor_unitario=mi_tabla_tem.cat_detalle,
		valor_unitariome=mi_tabla_tem.cat_detalle,
		valor_item=mi_tabla_tem.cat_detalle,
		valor_itemme=mi_tabla_tem.cat_detalle
		FROM (
			SELECT
				fac.negasoc ,
				dnas.fecha::date,
				dnas.item as cuota,
				dnas.saldo_inicial,
				dnas.valor as valor_cuota,
				dnas.capital,
				dnas.interes,
				dnas.capacitacion,
				dnas.cat ,
				dnas.seguro,
				dnas.saldo_final,
				facdt.documento,
				facdt.item,
				codigo_cuenta_contable,
				case when codigo_cuenta_contable like 'I%' THEN
					round((cat/1.16))
				else
					round(cat-round((cat/1.16)))
				END as cat_detalle,
				facdt.descripcion
				FROM con.factura_detalle facdt
				inner join con.factura fac on (fac.documento=facdt.documento)
				inner join documentos_neg_aceptado dnas on (dnas.cod_neg=fac.negasoc and dnas.item=fac.num_doc_fen)
				where fac.negasoc =negocio  and facdt.descripcion='BQ-013-FENALCO-COMISION CAT' and substring(fac.documento,1,2)='CA'  and fac.reg_status=''
				group by
				fac.negasoc,
				dnas.fecha,
				dnas.item ,
				dnas.saldo_inicial,
				dnas.valor,
				dnas.capital,
				dnas.interes,
				dnas.capacitacion,
				dnas.cat ,
				dnas.seguro,
				dnas.saldo_final,
				facdt.documento,
				facdt.item,
				facdt.descripcion,
				codigo_cuenta_contable
			order by dnas.item::integer

		  ) as mi_tabla_tem
		where con.factura_detalle.documento=mi_tabla_tem.documento
		and  con.factura_detalle.descripcion=mi_tabla_tem.descripcion
		AND  con.factura_detalle.codigo_cuenta_contable=mi_tabla_tem.codigo_cuenta_contable
		and  con.factura_detalle.item=mi_tabla_tem.item ;



		--5.)ACTUALIZAR CABECERA FACTURA---
		update con.factura
		set
		valor_factura=(select sum(valor_unitario) from con.factura_detalle where documento = con.factura.documento),
		valor_facturame=(select sum(valor_unitario) from con.factura_detalle where documento = con.factura.documento),
		valor_abono=0.00,
		valor_abonome=0.00,
		valor_saldo=(select sum(valor_unitario) from con.factura_detalle where documento = con.factura.documento),
		valor_saldome=(select sum(valor_unitario) from con.factura_detalle where documento = con.factura.documento)
		where negasoc =negocio ;

	else
		retorno='LA CARTERA DEL NEGOCIO '||negocio||' TIENE PAGOS APLICADO LOS CUALES DEBEN SER REVERSADOS ANTES DE CORREGIR LA FACTURAS';
	end if;

       return retorno;

 EXCEPTION

	WHEN foreign_key_violation THEN
		RAISE EXCEPTION 'NO EXISTEN DEPENDENCIAS FORANEAS PARA ALGUNOS REGISTROS.';
	WHEN unique_violation THEN
		RAISE EXCEPTION'ERROR ACTUALIZANDO EN LA BD';
        WHEN  null_value_not_allowed  THEN
		RAISE EXCEPTION 'VALOR NULO NO PERMITIDO';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_corregir_cartera_microcredito(character varying, numeric, integer, date, character varying, character varying, date)
  OWNER TO postgres;
