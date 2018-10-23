-- Function: eg_altura_mora_periodo(character varying, integer, integer, integer)

-- DROP FUNCTION eg_altura_mora_periodo(character varying, integer, integer, integer);

CREATE OR REPLACE FUNCTION eg_altura_mora_periodo(negocio character varying, _periodo integer, _modo integer, dias integer)
  RETURNS text AS
$BODY$

DECLARE

  moraMaxima varchar:='';
  --_periodo integer:=(REPLACE(substring((now()- (_meses||' month')::interval)::date,1,7),'-',''))::INTEGER;


BEGIN
	--Modo de consulta..1: texto , 2: entero
	if(_modo=1) then
		moraMaxima:= (SELECT
				CASE WHEN maxdia >= 365 THEN '8- MAYOR A 1 AÑO'
				     WHEN maxdia >= 181 THEN '7- ENTRE 180 Y 360'
				     WHEN maxdia >= 121 THEN '6- ENTRE 121 Y 180'
				     WHEN maxdia >= 91 THEN '5- ENTRE 91 Y 120'
				     WHEN maxdia >= 61 THEN '4- ENTRE 61 Y 90'
				     WHEN maxdia >= 31 THEN '3- ENTRE 31 Y 60'
				     WHEN maxdia >= 1 THEN '2- 1 A 30'
				     WHEN maxdia <= 0 THEN '1- CORRIENTE'
				     WHEN maxdia is null  THEN '1- CORRIENTE'
				     ELSE '0' END AS rango
				FROM (  SELECT
						max(sp_fecha_corte_foto(substring(periodo_lote,1,4),substring(periodo_lote,5)::integer)::date-(fecha_vencimiento)) as maxdia
					FROM con.foto_cartera fra
					WHERE fra.dstrct = 'FINV'   and fra.reg_status=''
					and periodo_lote = _periodo
					and fra.valor_saldo > 0
					AND fra.negasoc = negocio
					AND fra.tipo_documento in ('FAC','NDC')
					AND substring(fra.documento,1,2) not in ('CP','FF','DF')) as t);

	elsif (_modo=2) then

		moraMaxima:=  (  SELECT
				max(sp_fecha_corte_foto(substring(periodo_lote,1,4),substring(periodo_lote,5)::integer)::date-(fecha_vencimiento)) as maxdia
				FROM con.foto_cartera fra
				WHERE fra.dstrct = 'FINV'   and fra.reg_status=''
				and fra.valor_saldo > 0
				AND fra.negasoc = negocio
				AND fra.tipo_documento in ('FAC','NDC')
				AND substring(fra.documento,1,2) not in ('CP','FF','DF')) as t;

	elsif (_modo=3)then

		moraMaxima:=(SELECT
				CASE WHEN dias >= 365 THEN '8- MAYOR A 1 AÑO'
				     WHEN dias >= 181 THEN '7- ENTRE 180 Y 360'
				     WHEN dias >= 121 THEN '6- ENTRE 121 Y 180'
				     WHEN dias >= 91 THEN '5- ENTRE 91 Y 120'
				     WHEN dias >= 61 THEN '4- ENTRE 61 Y 90'
				     WHEN dias >= 31 THEN '3- ENTRE 31 Y 60'
				     WHEN dias >= 1 THEN '2- 1 A 30'
				     WHEN dias <= 0 THEN '1- CORRIENTE'
				     WHEN dias is null  THEN '1- CORRIENTE'
				     ELSE '0' END AS rango);

	elsif (_modo=4)then

		moraMaxima:=(SELECT  max(sp_fecha_corte_foto(substring(periodo_lote,1,4),substring(periodo_lote,5)::integer)::date-(fecha_vencimiento)) as maxdia
				FROM con.foto_cartera fra
				WHERE fra.dstrct = 'FINV'   and fra.reg_status=''
				and fra.valor_saldo > 5000
				AND fra.negasoc != ''
				AND fra.nit = negocio
				AND fra.tipo_documento in ('FAC','NDC')
				AND substring(fra.documento,1,2) not in ('CP','FF','DF'));

	elseif(_modo=5)then

		moraMaxima:=(SELECT  max(sp_fecha_corte_foto(substring(periodo_lote,1,4),substring(periodo_lote,5)::integer)::date-(fecha_vencimiento)) as maxdia
				FROM con.foto_cartera fra
				WHERE fra.dstrct = 'FINV'   and fra.reg_status=''
				and fra.valor_saldo > 0
				AND fra.negasoc != ''
				AND fra.nit = negocio
				AND fra.tipo_documento in ('FAC','NDC')
				AND substring(fra.documento,1,2) not in ('CP','FF','DF'));

	elseif(_modo=6)then

	moraMaxima:=(SELECT  max(sp_fecha_corte_foto(substring(periodo_lote,1,4),substring(periodo_lote,5)::integer)::date-(fecha_vencimiento)) as maxdia
				FROM con.foto_cartera fra
				WHERE fra.dstrct = 'FINV'   and fra.reg_status=''
				and fra.valor_saldo > 5000
				AND fra.negasoc != ''
				AND fra.tipo_documento in ('FAC','NDC')
				AND substring(fra.documento,1,2) not in ('CP','FF','DF')
				AND fra.negasoc = (SELECT cod_neg
							from negocios neg
							where creation_date::date = (select max(creation_date)::date from negocios where cod_cli = negocio and estado_neg = 'T')
							and neg.cod_cli = negocio limit 1) );


	elseif(_modo=7)then

	moraMaxima:=(SELECT
				CASE WHEN maxdia >= 365 THEN '8- MAYOR A 1 AÑO'
				     WHEN maxdia >= 181 THEN '7- ENTRE 180 Y 360'
				     WHEN maxdia >= 121 THEN '6- ENTRE 121 Y 180'
				     WHEN maxdia >= 91 THEN '5- ENTRE 91 Y 120'
				     WHEN maxdia >= 61 THEN '4- ENTRE 61 Y 90'
				     WHEN maxdia >= 31 THEN '3- ENTRE 31 Y 60'
				     WHEN maxdia >= 1 THEN '2- 1 A 30'
				     WHEN maxdia <= 0 THEN '1- CORRIENTE'
				     WHEN maxdia is null  THEN '0- AUN NO VENCE LA ULTIMA CUOTA'
				     ELSE '0' END AS rango
				FROM (SELECT  max(sp_fecha_corte_foto(substring(periodo_lote,1,4),substring(periodo_lote,5)::integer)::date-(fecha_vencimiento)) as maxdia
				FROM con.foto_cartera fra
				WHERE fra.dstrct = 'FINV'
				and fra.reg_status=''
				and fra.valor_saldo > 5000 and fra.fecha_vencimiento < now()
				AND fra.negasoc != ''
				AND fra.tipo_documento in ('FAC','NDC')
				AND substring(fra.documento,1,2) not in ('CP','FF','DF')
				AND fra.num_doc_fen = (select max(num_doc_fen::integer) from con.factura where negasoc = fra.negasoc)
				AND fra.negasoc = negocio limit 1) as t);
				--raise notice 'negocio: %',negocio;


	end if;



	return moraMaxima;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_altura_mora_periodo(character varying, integer, integer, integer)
  OWNER TO postgres;
