-- Function: opav.eg_calcular_costo_contratista_aiu2(numeric, numeric, numeric, numeric, numeric)

-- DROP FUNCTION opav.eg_calcular_costo_contratista_aiu2(numeric, numeric, numeric, numeric, numeric);

CREATE OR REPLACE FUNCTION opav.eg_calcular_costo_contratista_aiu2(_costodirecto numeric, _porc_a numeric, _porc_i numeric, _porc_u numeric, _totalcomision numeric)
  RETURNS SETOF opav.rs_aiu_proyectos AS
$BODY$
DECLARE

_costoContratista numeric;
_a_valor numeric;
_i_valor numeric;
_u_valor numeric;
_valor_antes_iva numeric;
_iva numeric;
_porc_iva numeric:=19;
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

rs opav.rs_aiu_proyectos;

i integer:=0;

BEGIN
	_costoContratista:=_costoDirecto;

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


		ELSE
			--LLenamos el typo con los valores de la iteracion
			rs._costoContratista:=0;
			rs._valor_aiu:=0;
			rs._retabilidad:=0;
			rs._valor_antes_iva :=0;
			rs._iva := 0;
			rs._valorTotal := 0 ;
			rs._totalComisionesSinAiu := 0;
			rs._valorAiuComisiones := 0;
			rs._valorUtilidad := 0 ;
			rs._ivaSobreUtilidad :=  0;
			rs._ivaRealComisiones :=  0;
			rs._ivaCompensar := 0;
			rs._lineaCompensacion :=  0;
			rs._totalOferta := 0 ;
		END IF;

			--LLenamos el typo con los valores de la iteracion
			rs._costoContratista:=_costoContratista;
			rs._valor_aiu:=(_porc_a+_porc_i+_porc_u);
			rs._retabilidad:=_totalComision;
			rs._valor_antes_iva := _valor_antes_iva;
			rs._iva := _iva;
			rs._valorTotal := _valorTotal;
			rs._totalComisionesSinAiu := _totalComisionesSinAiu;
			rs._valorAiuComisiones := _valorAiuComisiones;
			rs._valorUtilidad := _valorUtilidad;
			rs._ivaSobreUtilidad :=  _ivaSobreUtilidad;
			rs._ivaRealComisiones :=  _ivaRealComisiones;
			rs._ivaCompensar := _ivaCompensar;
			rs._lineaCompensacion :=  _lineaCompensacion;
			rs._totalOferta := _totalOferta;


	return next rs;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.eg_calcular_costo_contratista_aiu2(numeric, numeric, numeric, numeric, numeric)
  OWNER TO postgres;
