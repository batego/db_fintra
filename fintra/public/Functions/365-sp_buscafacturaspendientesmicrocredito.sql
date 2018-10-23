-- Function: sp_buscafacturaspendientesmicrocredito()

-- DROP FUNCTION sp_buscafacturaspendientesmicrocredito();

CREATE OR REPLACE FUNCTION sp_buscafacturaspendientesmicrocredito()
  RETURNS SETOF record AS
$BODY$
--RETURNS text AS $HYS$

DECLARE
	CuotasNegocios record;
	FacturaPadre record;
	QryCasos record;

	SumaInteresesMI numeric;
	SumaComisionCA numeric;
	ValorCapital numeric;

	saldo_factura_capital numeric;
	--NoDias numeric;

BEGIN

	FOR CuotasNegocios IN

		select dna.*, fecha_negocio::date, replace(substring(fecha_negocio,1,7),'-','') as periodo_negocio, vr_negocio, vr_desembolso, n.cod_cli, get_codnit(n.cod_cli) as codcli, (select payment_name from proveedor where nit = n.cod_cli) as payment_name,
		    CASE WHEN SUBSTR(dna.fecha,6,2)='01' THEN
			SUBSTR(CAST(SUBSTR((dna.fecha+INTERVAL'1 month') ,1,8) || '28' AS TIMESTAMP),1,10) ELSE
			SUBSTR(CAST(SUBSTR((dna.fecha+INTERVAL'1 month') ,1,8) || '30' AS TIMESTAMP),1,10)
		    END as ndias,
		(CURRENT_DATE-dna.fecha::DATE) AS NoDias
		from documentos_neg_aceptado dna
		inner join negocios n on (n.cod_neg = dna.cod_neg)
		--where dna.cod_neg = 'MC00209' --'MC01706'
		--where dna.cod_neg in (select cod_neg from negocios where id_convenio in (10,11,12,13) and estado_neg = 'T' and cod_neg not in ('MC01609','MC00231','MC00599','MC01712','MC01165','MC01599','MC01707','MC00102','MC01728','MC02023','MC01721','MC02025','MC01159','MC00596','MC00598','MC00600','MC00602','MC01725','MC02028','MC02021','MC02019','MC03435','MC02670','MC01704','MC00595','MC02024','MC00601') )
		where dna.cod_neg in (select cod_neg from negocios where id_convenio in (10,11,12,13) and estado_neg = 'T' )
		--and descripcion = 'CXC_MICROCRED'
		order by dna.cod_neg, dna.item::numeric LOOP

		SumaInteresesMI = 0;
		SumaComisionCA = 0;
		ValorCapital = 0;

		saldo_factura_capital = 0;
		--NoDias = 0;

		FOR FacturaPadre IN

			select *,replace(substring(periodo,1,7),'-','') as periodo_vencimiento
			--,(select num_ingreso from con.ingreso where num_ingreso in (select num_ingreso from con.ingreso_detalle where factura = con.factura.documento and substring(num_ingreso,1,2) in ('IA','IC') ) limit 1) as ingreso
			from con.factura
			where negasoc = CuotasNegocios.cod_neg
			      and num_doc_fen = CuotasNegocios.item
			      --and valor_saldo > 0
			      and descripcion not in ('CXC_CAT_MC','CXC_INTERES_MC') and reg_status = '' LOOP

			--VALOR FACTURA CAPITAL
			ValorCapital = FacturaPadre.valor_factura;

			--SUMA TODOS LOS MI VALIDOS
			SELECT INTO SumaInteresesMI case when sum(valor_unitario)::numeric is null then 0 else sum(valor_unitario) end from con.factura_detalle where numero_remesa = FacturaPadre.documento and reg_status = '' and substring(documento,1,2) = 'MI' and (select reg_status from con.factura where documento = con.factura_detalle.documento) = '';

			--SUMA TODOS LOS CA VALIDOS
			SELECT INTO SumaComisionCA case when sum(valor_unitario)::numeric is null then 0 else sum(valor_unitario) end from con.factura_detalle where numero_remesa = FacturaPadre.documento and reg_status = '' and substring(documento,1,2) = 'CA' and (select reg_status from con.factura where documento = con.factura_detalle.documento) = '';

			--VALOR SALDO CAPITAL
			saldo_factura_capital = FacturaPadre.valor_saldo;

		END LOOP;

		-------------------------------------------------------------------------------------------------------
		--NoDias := DATE_PART('day', now() - CuotasNegocios.ndias::date);
		--NoDias := CuotasNegocios.ndias;

		FOR QryCasos IN select cod_neg::varchar, CuotasNegocios.fecha_negocio::date, CuotasNegocios.periodo_negocio::varchar, CuotasNegocios.vr_negocio::numeric, CuotasNegocios.vr_desembolso::numeric, CuotasNegocios.cod_cli::varchar, CuotasNegocios.codcli::varchar, CuotasNegocios.payment_name::varchar, item::varchar, fecha::date, CuotasNegocios.ndias::date, CuotasNegocios.NoDias::numeric, CuotasNegocios.causar::varchar, capital::numeric, interes::numeric, interes_causado::numeric, cat::numeric, documento_cat::varchar, seguro::numeric, FacturaPadre.documento::varchar, FacturaPadre.periodo::varchar, FacturaPadre.periodo_vencimiento::varchar, FacturaPadre.reg_status::varchar, ValorCapital::numeric, saldo_factura_capital::numeric, SumaInteresesMI::numeric, SumaComisionCA::numeric from documentos_neg_aceptado where cod_neg = CuotasNegocios.cod_neg and item = CuotasNegocios.item LOOP
		    RETURN NEXT QryCasos;
		END LOOP;

	END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_buscafacturaspendientesmicrocredito()
  OWNER TO postgres;
