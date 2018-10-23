-- Function: sp_reportepyg(character varying, integer, integer)

-- DROP FUNCTION sp_reportepyg(character varying, integer, integer);

CREATE OR REPLACE FUNCTION sp_reportepyg(cadpucfintra character varying, periodoinicial integer, periodofinal integer)
  RETURNS SETOF record AS
$BODY$

DECLARE

	ElementosDelGasto record;
	CentrosDeCosto record;

BEGIN

	FOR ElementosDelGasto IN
		/*
		SELECT * FROM tablagen WHERE table_type = 'TELEMENTOS' AND table_code IN (
			'5105','5106','5107','5110','5111','5112','5113','5114','5115','5117','5118','5119','5120','5121','5122','5123','5124','5125','5612','5613','5126',
			'5127','5128','5152','5185','5199','5201','5202','5506','5510','5511','5512','5513','5514','5516','5606','5610','5611','5614','5615','5706'
		)*/

		SELECT * FROM tablagen WHERE table_type = 'TELEMENTOS' AND table_code = '5106'

	LOOP

		FOR PeriodClck in PeriodoInicial..PeriodoFinal LOOP

			raise notice 'Pasa: %', PeriodClck;

			FOR CentrosDeCosto IN

				SELECT cuenta::varchar,tercero::varchar,
				(select payment_name from proveedor where nit = con.comprodet.tercero)::varchar as nombre,
				valor_debito::numeric, --sum(valor_debito)::numeric as valor_debito,
				0::numeric as enero,
				0::numeric as febrero,
				0::numeric as marzo,
				0::numeric as abril,
				0::numeric as mayo,
				0::numeric as junio,
				0::numeric as julio,
				0::numeric as agosto,
				0::numeric as septiembre,
				0::numeric as octubre,
				0::numeric as noviembre,
				0::numeric as diciembre
				FROM con.comprodet
				WHERE cuenta ilike 'G01002002%'
					AND periodo = PeriodClck
					AND substring(cuenta,10) = ElementosDelGasto.table_code
				--GROUP BY tercero,cuenta

			LOOP

				RETURN NEXT CentrosDeCosto;

			END LOOP;


		END LOOP;

	END LOOP;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_reportepyg(character varying, integer, integer)
  OWNER TO postgres;
