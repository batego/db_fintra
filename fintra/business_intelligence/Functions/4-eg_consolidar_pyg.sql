-- Function: business_intelligence.eg_consolidar_pyg()

-- DROP FUNCTION business_intelligence.eg_consolidar_pyg();

CREATE OR REPLACE FUNCTION business_intelligence.eg_consolidar_pyg()
  RETURNS SETOF business_intelligence.rs_datos_pyg AS
$BODY$

DECLARE

 rs business_intelligence.rs_datos_pyg;
 record_pyg record ;
 suma numeric:=0;
 auxi integer:=0;
 _start_year varchar := '2015';
 _end_year varchar:=substring(current_date,1,4) ;
 _periodo varchar:='';
 _i integer;

 --DECLARAMOS EL CURSOR
 cursor_pyg CURSOR(_anio varchar,_periodo varchar) FOR ( SELECT master_orden,
							orden,
							coalesce(anio,_anio) as anio,
							coalesce(periodo,_periodo) as periodo,
							nivel_1,
							nivel_2,
							nivel_3,
							nivel_4,
							nom_ceco_cebe,
							producto,
							clasificacion,
							unidad,
							case when tipo in ('C','G') OR cuenta_contable in ('I010120064221','I010080034221') then tercero else '' end as nit_tercero,
							case when tipo in ('C','G') OR cuenta_contable in ('I010120064221','I010080034221') then nombre_tercero else '' end as tercero,
							cuenta_contable,
							coalesce(sum(valor_debito),0) as valor_debito,
							coalesce(sum(valor_credito),0) as valor_debito,
							coalesce(sum(diferencia),0) as saldo
							FROM business_intelligence.centro_costo_beneficios ccbe
							LEFT JOIN  business_intelligence.consolidado_pyg_fintra  aux  ON (aux.cuenta=ccbe.cuenta_contable  and periodo=_periodo and anio=_anio)
						--WHERE  periodo=_periodo
						GROUP BY
							master_orden,
							orden,
							anio,
							periodo,
							nivel_1,
							nivel_2,
							nivel_3,
							nivel_4,
							nom_ceco_cebe,
							producto,
							clasificacion,
							unidad,
							cuenta_contable ,
							tercero,
							nombre_tercero,
							tipo
						order by periodo,master_orden,orden
					);


BEGIN
	FOR YearSec IN _start_year::integer .. _end_year::integer LOOP
		FOR i IN 1..12 LOOP

			_periodo:=YearSec||lpad(i, 2, '0');

			--ABRIMOS EL CURSOR SIN PARAMETROS
			OPEN cursor_pyg(YearSec,_periodo) ;
			<<_loop>>
			LOOP
				-- FETCH FILA EN MY RECORD O TYPE
				FETCH cursor_pyg INTO record_pyg;
				-- EXIT CUANDO NO HAY MAS FILAS
				EXIT WHEN NOT FOUND;

				raise notice 'periodo: %',record_pyg.periodo;
				IF(auxi=0)THEN
					suma:=0;
					auxi:=record_pyg.master_orden;
					_periodo:=record_pyg.periodo;

				ELSIF(auxi=record_pyg.master_orden AND _periodo=record_pyg.periodo)THEN
					auxi:=record_pyg.master_orden;
					_periodo:=record_pyg.periodo;

				ELSIF(auxi!=record_pyg.master_orden OR _periodo!=record_pyg.periodo)THEN
					suma:=0;
					auxi:=record_pyg.master_orden;
					_periodo:=record_pyg.periodo;
				END IF;

				IF(record_pyg.nivel_1='Ingresos Operacionales')THEN
					suma:=suma+record_pyg.saldo;
					raise notice 'suma: %',suma;
				END IF;

				IF(record_pyg.nivel_1='Costos Operacionales')THEN
					raise notice 'suma: % record_pyg.saldo: %',suma,record_pyg.saldo;
					suma:= suma-record_pyg.saldo;
					raise notice 'suma :%',suma;
				END IF;

				IF(record_pyg.nivel_1='Utilidad Bruta')THEN
					record_pyg.saldo:=suma;
				END IF;

				IF(record_pyg.nivel_1='Gastos de Admon y Ventas')THEN
					suma:=suma-record_pyg.saldo;
				END IF;

				IF(record_pyg.nivel_1='Utilidad Operacional')THEN
					record_pyg.saldo:=suma;
				END IF;

				IF(record_pyg.nivel_1='Ingresos No Operacionales')THEN
					suma:=suma+record_pyg.saldo;
				END IF;

				IF(record_pyg.nivel_1='Gastos No Operacionales')THEN
					suma:=suma-record_pyg.saldo;
				END IF;

				IF(record_pyg.nivel_1='Utilidad antes de impuestos')THEN
					record_pyg.saldo:=suma;
				END IF;



				raise notice 'record_pyg %',record_pyg;
				rs:=record_pyg;
				RETURN NEXT rs;

			END LOOP  _loop ;

			--CERRAMOS EL CURSOR
			CLOSE cursor_pyg;

			suma :=0;
			auxi :=0;
		END LOOP;

	END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION business_intelligence.eg_consolidar_pyg()
  OWNER TO postgres;
