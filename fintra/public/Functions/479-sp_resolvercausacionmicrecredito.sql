-- Function: sp_resolvercausacionmicrecredito()

-- DROP FUNCTION sp_resolvercausacionmicrecredito();

CREATE OR REPLACE FUNCTION sp_resolvercausacionmicrecredito()
  RETURNS SETOF record AS
$BODY$
--RETURNS text AS $HYS$

DECLARE

	CuotasNegocios record;
	FacturaPadre record;
	FactMICA record;
	QryCasos record;

	CountDocum integer;
	SumaInteresesMI numeric;
	SumaInteresesPeriodoAnterior numeric;
	SumaFacturaCA numeric;

BEGIN

	FOR CuotasNegocios IN

		select dna.*, n.cod_cli, get_codnit(n.cod_cli) as codcli, fecha_ap::date, f_desem::date, replace(substring(dna.fecha,1,7),'-','') as periodo_vencimiento
		from documentos_neg_aceptado dna
		inner join negocios n on (n.cod_neg = dna.cod_neg)
		where dna.cod_neg in (select cod_neg from negocios where id_convenio in (10,11,12,13) and estado_neg = 'T') order by dna.cod_neg, dna.item LOOP

		SumaInteresesMI = 0;
		SumaFacturaCA = 0;
		SumaInteresesPeriodoAnterior = 0;

		FOR FacturaPadre IN

			select *
			from con.factura
			where negasoc = CuotasNegocios.cod_neg
			      and num_doc_fen = CuotasNegocios.item
			      and substring(documento,1,2) in ('MC')
			      and reg_status = '' LOOP

			FOR FactMICA IN

				select * --, replace(substring(fecha_ven,1,7),'-','') as periodo_fact_interes
				from con.factura
				where documento in (select documento from con.factura_detalle where numero_remesa = FacturaPadre.documento )
				      and substring(documento,1,2) in ('MI','CA')
				      and reg_status = '' LOOP

				--SUMA TODOS LOS MI | CA VALIDOS
				IF ( substring(FactMICA.documento,1,2) = 'MI' ) THEN

					if ( CuotasNegocios.periodo_vencimiento = FactMICA.periodo ) then
						SumaInteresesMI := SumaInteresesMI + FactMICA.valor_factura;
					else
						SumaInteresesPeriodoAnterior := SumaInteresesPeriodoAnterior + FactMICA.valor_factura;
					end if;


					--SumaInteresesMI := SumaInteresesMI + FactMICA.valor_factura;




				   ELSIF ( substring(FactMICA.documento,1,2) = 'CA' ) THEN
					SumaFacturaCA := SumaFacturaCA + FactMICA.valor_factura;
				END IF;

			END LOOP;



		END LOOP;

		-------------------------------------------------------------------------------------------------------

		FOR QryCasos IN select cod_neg::varchar, CuotasNegocios.fecha_ap::date, CuotasNegocios.f_desem::date, CuotasNegocios.cod_cli::varchar, CuotasNegocios.codcli::varchar, item::varchar, fecha::date, CuotasNegocios.causar::varchar, capital::numeric, interes::numeric, interes_causado::numeric, cat::numeric, FacturaPadre.documento::varchar, FacturaPadre.valor_saldo::numeric, SumaInteresesMI::numeric, SumaInteresesPeriodoAnterior::numeric, SumaFacturaCA::numeric from documentos_neg_aceptado where cod_neg = CuotasNegocios.cod_neg and item = CuotasNegocios.item LOOP
		    RETURN NEXT QryCasos;
		END LOOP;

	END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_resolvercausacionmicrecredito()
  OWNER TO postgres;
