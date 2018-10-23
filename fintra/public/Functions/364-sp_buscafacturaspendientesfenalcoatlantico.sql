-- Function: sp_buscafacturaspendientesfenalcoatlantico()

-- DROP FUNCTION sp_buscafacturaspendientesfenalcoatlantico();

CREATE OR REPLACE FUNCTION sp_buscafacturaspendientesfenalcoatlantico()
  RETURNS SETOF record AS
$BODY$
--RETURNS text AS $HYS$

DECLARE
	CuotasNegocios record;
	FacturaPadre record;
	IngresoDiferido record;
	QryCasos record;

	SumaInteresesMI numeric;
	SumaComisionCA numeric;
	ValorCapital numeric;

	saldo_factura_capital numeric;
	CodIngFen varchar;
	CtaIngFen varchar;
	VlrIngFen numeric;

BEGIN

	FOR CuotasNegocios IN

		select dna.*,fecha_negocio::date, replace(substring(fecha_negocio,1,7),'-','') as periodo_negocio, vr_negocio, vr_desembolso, n.cod_cli, get_codnit(n.cod_cli) as codcli, (select nomcli from cliente where nit = n.cod_cli limit 1) as payment_name,
		n.id_convenio,
		(select nombre from convenios where id_convenio = n.id_convenio) as nombre_convenio,
		    CASE WHEN SUBSTR(dna.fecha,6,2)='01' THEN
			SUBSTR(CAST(SUBSTR((dna.fecha+INTERVAL'1 month') ,1,8) || '28' AS TIMESTAMP),1,10) ELSE
			SUBSTR(CAST(SUBSTR((dna.fecha+INTERVAL'1 month') ,1,8) || '30' AS TIMESTAMP),1,10)
		    END as ndias,
		(CURRENT_DATE-dna.fecha::DATE) AS NoDias
		from documentos_neg_aceptado dna
		inner join negocios n on (n.cod_neg = dna.cod_neg)
		--where dna.cod_neg in (select cod_neg from negocios where id_convenio in (16,17,18,19,20,26) and estado_neg = 'T' )
		where dna.cod_neg in (select negasoc from con.factura group by negasoc )
		and n.id_convenio in (16,17,18,20,26,30,31,32,35) --19
		--and dna.cod_neg = 'FA00265'
		order by dna.cod_neg LOOP

		SumaInteresesMI = 0;
		SumaComisionCA = 0;
		ValorCapital = 0;

		saldo_factura_capital = 0;
		CodIngFen = '';
		CtaIngFen = '';
		VlrIngFen = 0;

		FOR FacturaPadre IN

			select f.*,replace(substring(f.fecha_vencimiento,1,7),'-','') as periodo_vencimiento, fd.valor_unitario
			from con.factura f, con.factura_detalle fd
			where f.documento = fd.documento
			      and f.negasoc = CuotasNegocios.cod_neg
			      and fd.descripcion = 'CAPITAL'
			      and fd.valor_unitario = CuotasNegocios.capital
			      --and f.descripcion = ('REDPAGARE')
			      and f.reg_status = ''
			      and substring(f.documento,1,2) in ('FC','FG') LOOP

			--VALOR FACTURA CAPITAL
			ValorCapital = FacturaPadre.valor_unitario;

			--SUMA TODOS LOS MI VALIDOS
			SELECT INTO SumaInteresesMI case when sum(valor_unitario)::numeric is null then 0 else sum(valor_unitario) end from con.factura_detalle where documento = FacturaPadre.documento and reg_status = '' and descripcion = 'INTERESES' and (select reg_status from con.factura where documento = con.factura_detalle.documento) = '';

			--VALOR SALDO CAPITAL
			saldo_factura_capital = FacturaPadre.valor_saldo;

			FOR IngresoDiferido IN

				select *
				,(select cuenta from con.comprodet where grupo_transaccion = ing_fenalco.transaccion and valor_credito > 0) as cta_ingreso_fenalco
				from ing_fenalco
				where codneg = CuotasNegocios.cod_neg
					and reg_status = ''
					and transaccion_anulacion = 0
					and (select count(0) from con.comprodet where numdoc = ing_fenalco.cod) > 0
					and (substring(cod,10)::numeric+1) = FacturaPadre.num_doc_fen
				order by cod LOOP

				CodIngFen = IngresoDiferido.cod;
				CtaIngFen = IngresoDiferido.cta_ingreso_fenalco;
				VlrIngFen = IngresoDiferido.valor;

			END LOOP;



		END LOOP;

		FOR QryCasos IN select cod_neg::varchar, CuotasNegocios.id_convenio::numeric, CuotasNegocios.nombre_convenio::varchar, CuotasNegocios.fecha_negocio::date, CuotasNegocios.periodo_negocio::varchar, CuotasNegocios.vr_negocio::numeric, CuotasNegocios.vr_desembolso::numeric, CuotasNegocios.cod_cli::varchar, CuotasNegocios.codcli::varchar, CuotasNegocios.payment_name::varchar, item::varchar, fecha::date, CuotasNegocios.ndias::date, CuotasNegocios.NoDias::numeric, CuotasNegocios.causar::varchar, capital::numeric, interes::numeric, interes_causado::numeric, cat::numeric, seguro::numeric, FacturaPadre.documento::varchar, FacturaPadre.periodo::varchar, FacturaPadre.periodo_vencimiento::varchar, FacturaPadre.reg_status::varchar, ValorCapital::numeric, saldo_factura_capital::numeric, SumaInteresesMI::numeric, SumaComisionCA::numeric, CodIngFen::varchar, CtaIngFen::varchar, VlrIngFen::numeric from documentos_neg_aceptado where cod_neg = CuotasNegocios.cod_neg and item = CuotasNegocios.item LOOP
		    RETURN NEXT QryCasos;
		END LOOP;

	END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_buscafacturaspendientesfenalcoatlantico()
  OWNER TO postgres;
