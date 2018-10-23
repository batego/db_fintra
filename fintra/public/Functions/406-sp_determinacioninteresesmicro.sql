-- Function: sp_determinacioninteresesmicro()

-- DROP FUNCTION sp_determinacioninteresesmicro();

CREATE OR REPLACE FUNCTION sp_determinacioninteresesmicro()
  RETURNS SETOF record AS
$BODY$
--RETURNS text AS $HYS$

DECLARE
	CuotasNegocios record;
	FacturaPadre record;
	QryCasos record;

	SumaInteresesMI numeric;
	SumaInteresesMIA numeric;
	SumaMiMia numeric;
	saldo_factura_capital numeric;
	candidata varchar;
	pago_nota varchar;
	NoDias numeric;

BEGIN

	FOR CuotasNegocios IN

		select dna.*, n.cod_cli, get_codnit(n.cod_cli) as codcli,
		    CASE WHEN SUBSTR(dna.fecha,6,2)='01' THEN
			SUBSTR(CAST(SUBSTR((dna.fecha+INTERVAL'1 month') ,1,8) || '28' AS TIMESTAMP),1,10) ELSE
			SUBSTR(CAST(SUBSTR((dna.fecha+INTERVAL'1 month') ,1,8) || '30' AS TIMESTAMP),1,10)
		    END as ndias
		from documentos_neg_aceptado dna
		inner join negocios n on (n.cod_neg = dna.cod_neg)
		--where dna.cod_neg = 'MC00209' --'MC01706'
		where dna.cod_neg in (select cod_neg from negocios where id_convenio in (10,11,12,13) and estado_neg = 'T') order by dna.cod_neg, dna.item::numeric LOOP

		SumaInteresesMI = 0;
		SumaInteresesMIA = 0;
		SumaMiMia = 0;
		saldo_factura_capital = 0;
		candidata = '';
		pago_nota = '';
		NoDias = 0;

		FOR FacturaPadre IN

			select *
			,(select num_ingreso from con.ingreso where num_ingreso in (select num_ingreso from con.ingreso_detalle where factura = con.factura.documento and substring(num_ingreso,1,2) in ('IA','IC') ) limit 1) as ingreso
			from con.factura
			where negasoc = CuotasNegocios.cod_neg
			      and num_doc_fen = CuotasNegocios.item
			      and descripcion not in ('CXC_CAT_MC','CXC_INTERES_MC') LOOP

			--SUMA TODOS LOS MI VALIDOS
			SELECT INTO SumaInteresesMI case when sum(valor_unitario)::numeric is null then 0 else sum(valor_unitario) end from con.factura_detalle where numero_remesa = FacturaPadre.documento and reg_status = '' and substring(documento,1,2) = 'MI';

			--SUMA TODOS LOS MI ANULADOS
			SELECT INTO SumaInteresesMIa case when sum(valor_unitario)::numeric is null then 0 else sum(valor_unitario) end from con.factura_detalle where numero_remesa = FacturaPadre.documento and reg_status = 'A' and substring(documento,1,2) = 'MI';

			SumaMiMia = SumaInteresesMI + SumaInteresesMIa;

			saldo_factura_capital = FacturaPadre.valor_saldo;
			pago_nota = FacturaPadre.ingreso;

			--SELECT case when sum(valor_unitario)::numeric is null then 0 else sum(valor_unitario) end from con.factura_detalle where numero_remesa = 'MC0017202' and reg_status = '' and substring(documento,1,2) = 'MI';
			--SELECT case when sum(valor_unitario)::numeric is null then 0 else sum(valor_unitario) end from con.factura_detalle where numero_remesa = 'MC0017202' and reg_status = '' and substring(documento,1,2) = 'MI';
			--SELECT * from con.factura_detalle where documento = 'MI01502'
			--SELECT * from con.factura_detalle where numero_remesa = 'MC0017202' and substring(documento,1,2) = 'MI'

		END LOOP;

		-------------------------------------------------------------------------------------------------------

		IF ( select DATE_PART('day', now() - CuotasNegocios.ndias::date) > 0 ) THEN
			--candidata := DATE_PART('day', now() - CuotasNegocios.fecha);
			candidata := 'GENERAR';
			NoDias := DATE_PART('day', now() - CuotasNegocios.ndias::date);
			--candidata := DATE_PART('day', now() - CuotasNegocios.ndias::date);
		ELSE
			--candidata := DATE_PART('day', now() - CuotasNegocios.fecha);
			candidata := 'NO GENERAR';
			NoDias := DATE_PART('day', now() - CuotasNegocios.ndias::date);
		END IF;

		-------------------------------------------------------------------------------------------------------
		IF ( SumaMiMia = CuotasNegocios.interes ) THEN

			FOR QryCasos IN select cod_neg::varchar, CuotasNegocios.cod_cli::varchar, CuotasNegocios.codcli::varchar, item::varchar, fecha::date, CuotasNegocios.ndias::date, NoDias::numeric, candidata::varchar, CuotasNegocios.causar::varchar, capital::numeric, interes::numeric, interes_causado::numeric, FacturaPadre.documento::varchar, SumaInteresesMI::numeric, SumaInteresesMIa::numeric, SumaMiMia::numeric, saldo_factura_capital::numeric, pago_nota::varchar, 'IGUAL'::varchar as accion from documentos_neg_aceptado where cod_neg = CuotasNegocios.cod_neg and item = CuotasNegocios.item LOOP
			    RETURN NEXT QryCasos;
			END LOOP;

		ELSIF ( SumaMiMia < CuotasNegocios.interes ) THEN

			FOR QryCasos IN select cod_neg::varchar, CuotasNegocios.cod_cli::varchar, CuotasNegocios.codcli::varchar, item::varchar, fecha::date, CuotasNegocios.ndias::date, NoDias::numeric, candidata::varchar, CuotasNegocios.causar::varchar, capital::numeric, interes::numeric, interes_causado::numeric, FacturaPadre.documento::varchar, SumaInteresesMI::numeric, SumaInteresesMIa::numeric, SumaMiMia::numeric, saldo_factura_capital::numeric, pago_nota::varchar, 'MENOR'::varchar as accion from documentos_neg_aceptado where cod_neg = CuotasNegocios.cod_neg and item = CuotasNegocios.item LOOP
			    RETURN NEXT QryCasos;
			END LOOP;

		ELSIF( SumaMiMia > CuotasNegocios.interes ) THEN

			FOR QryCasos IN select cod_neg::varchar, CuotasNegocios.cod_cli::varchar, CuotasNegocios.codcli::varchar, item::varchar, fecha::date, CuotasNegocios.ndias::date, NoDias::numeric, candidata::varchar, CuotasNegocios.causar::varchar, capital::numeric, interes::numeric, interes_causado::numeric, FacturaPadre.documento::varchar, SumaInteresesMI::numeric, SumaInteresesMIa::numeric, SumaMiMia::numeric, saldo_factura_capital::numeric, pago_nota::varchar, 'MAYOR'::varchar as accion from documentos_neg_aceptado where cod_neg = CuotasNegocios.cod_neg and item = CuotasNegocios.item LOOP
			    RETURN NEXT QryCasos;
			END LOOP;

		END IF;


	END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_determinacioninteresesmicro()
  OWNER TO postgres;
