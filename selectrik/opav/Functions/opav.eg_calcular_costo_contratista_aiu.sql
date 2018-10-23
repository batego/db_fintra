-- Function: opav.eg_calcular_costo_contratista_aiu(numeric, numeric, numeric, numeric, numeric)

-- DROP FUNCTION opav.eg_calcular_costo_contratista_aiu(numeric, numeric, numeric, numeric, numeric);

CREATE OR REPLACE FUNCTION opav.eg_calcular_costo_contratista_aiu(_varlor_venta numeric, _porc_a numeric, _porc_i numeric, _porc_u numeric, _totalcomision numeric)
  RETURNS numeric AS
$BODY$
DECLARE

_costoContratista numeric;
_a_valor numeric;
_i_valor numeric;
_u_valor numeric;
_valor_antes_iva numeric;
_iva numeric;
_porc_iva numeric:=16;
_valorTotal numeric;
_totalComisionesSinAiu numeric;
_valorAiuComisiones numeric;
_valorUtilidad numeric;
_ivaSobreUtilidad numeric;
_ivaRealComisiones numeric;
_ivaCompensar numeric;
_totalOferta numeric;
_lineaCompensacion numeric;
_dif numeric;
_dividendo numeric:=10;
_costosContratistaAux numeric:=0;

i integer:=0;

BEGIN
	_costoContratista:=2548.4;
	WHILE TRUE loop

		raise notice 'Iteraciones : %',i;
		--raise notice '_costoContratista: %',_costoContratista;

		--calculamos el iva validando si tiene aiu o no
		IF((_porc_a+_porc_i+_porc_u)>0)THEN --TIENE AIU

			_valor_antes_iva:=round(_costoContratista*(((_porc_a+_porc_i+_porc_u)/100)+1));
			raise notice '1.) valor_antes_iva : %',_valor_antes_iva;

			_iva:=round(_costoContratista*(_porc_u/100)*(_porc_iva/100));
			raise notice '2.) IVA  : %',_iva;

			_valorTotal:=_valor_antes_iva+_iva;
			raise notice '3.) valor total  : %',_valorTotal;

			raise notice '4.) total comision  : %',_totalComision-1;

			_totalComisionesSinAiu:=round(_costoContratista*(_totalComision-1),0);
			raise notice '5.) valor total comisiones sin aiu  : %',_totalComisionesSinAiu;

			_valorAiuComisiones:=round(_totalComisionesSinAiu*(((_porc_a+_porc_i+_porc_u)/100)),0);
			raise notice '6.) valor aiu comisiones : %',_valorAiuComisiones;

			_valorUtilidad:=round(_totalComisionesSinAiu*(_porc_u/100),0);
			raise notice '7.) valor utilidad: %',_valorUtilidad;

			_ivaSobreUtilidad:=round(_valorUtilidad*(_porc_iva/100),0);
			raise notice '8.) iva utilidad : %', _ivaSobreUtilidad;

			_ivaRealComisiones:=round((_totalComisionesSinAiu+_valorAiuComisiones)*(_porc_iva/100),0);
			raise notice '9.) iva real comisiones : %', _ivaRealComisiones;

			_ivaCompensar:=_ivaRealComisiones-_ivaSobreUtilidad;
			raise notice '10.) iva a compensar : %', _ivaCompensar;

			_lineaCompensacion:=round(_ivaCompensar*_totalComision*((_porc_iva/100)+1));
			raise notice '11.)linea compensacion %',_lineaCompensacion;

			_totalOferta:=_valorTotal+_totalComisionesSinAiu+_valorAiuComisiones+_ivaSobreUtilidad+_lineaCompensacion;

		--	raise notice 'Total Oferta : %',_totalOferta;

		ELSE
			exit;
		END IF;

		IF (ROUND(_totalOferta)=ROUND(_varlor_venta))THEN EXIT; END IF;

		_dif:=_varlor_venta-_totalOferta;
		raise notice 'dif : %',_dif;
		if(_dif>0)then
			_costosContratistaAux:=_costoContratista;
			_costoContratista:=_costoContratista+_dif/_dividendo;
			--raise notice 'costo contratista: %',_costoContratista;
		else
			_costoContratista:=_costosContratistaAux;
			_costoContratista:=_costoContratista+(_dif/_dividendo+10);
		end if;

		i:=i+1;

	END LOOP;

	return round(_costoContratista);

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.eg_calcular_costo_contratista_aiu(numeric, numeric, numeric, numeric, numeric)
  OWNER TO postgres;
