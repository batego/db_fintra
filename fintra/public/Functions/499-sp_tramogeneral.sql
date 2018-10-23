-- Function: sp_tramogeneral()

-- DROP FUNCTION sp_tramogeneral();

CREATE OR REPLACE FUNCTION sp_tramogeneral()
  RETURNS SETOF record AS
$BODY$

DECLARE

	TramosGenerales record;

BEGIN

	FOR TramosGenerales IN

		--select substring(rango,1,1)::integer as id, rango::varchar as descripcion from (
		select rango::varchar as id, rango::varchar as descripcion from (
		SELECT
			CASE WHEN maxdia >= 365 THEN '8- MAYOR A 1 ANIO'
			     WHEN maxdia >= 181 THEN '7- ENTRE 180 Y 360'
			     WHEN maxdia >= 121 THEN '6- ENTRE 121 Y 180'
			     WHEN maxdia >= 91 THEN '5- ENTRE 91 Y 120'
			     WHEN maxdia >= 61 THEN '4- ENTRE 61 Y 90'
			     WHEN maxdia >= 31 THEN '3- ENTRE 31 Y 60'
			     WHEN maxdia >= 1 THEN '2- 1 A 30'
			     WHEN maxdia <= 0 THEN '1- CORRIENTE'
				ELSE '0' END AS rango
		FROM (
			 SELECT max('2014-05-31'::date-(fecha_vencimiento)) as maxdia
			 FROM con.foto_cartera fra
			 WHERE fra.dstrct = 'FINV'
				  AND fra.valor_saldo > 0
				  AND fra.reg_status = ''
				  AND fra.tipo_documento = 'FAC'
				  AND fra.periodo_lote = 201405
			 GROUP BY negasoc
		) c	 group by rango order by rango
		) z LOOP

		RETURN NEXT TramosGenerales;

	END LOOP;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_tramogeneral()
  OWNER TO postgres;
