-- Function: sp_resolvercausacion()

-- DROP FUNCTION sp_resolvercausacion();

CREATE OR REPLACE FUNCTION sp_resolvercausacion()
  RETURNS SETOF record AS
$BODY$

DECLARE
	FACcc TEXT;
	FACcg TEXT;
	FACpg TEXT;
	FACfi TEXT;
	FactHija TEXT;
	candidata varchar;
	--ChildFact varchar;

	CadFacturasFi varchar;
	ValorFI numeric;
	statusFI varchar;
	IngFi varchar;
	EstContabilizacionFI varchar;

	CadFacturasCi varchar;
	ValorCI numeric;
	statusCI varchar;
	IngCi varchar;
	EstContabilizacionCI varchar;

	CuotasNegocios record;
	FacturaPadre record;
	FactFI record;
	QryCasos record;
	myrec record;
	IngresoCi record;
	CompCi record;
	CompFi record;
	ChildFact record;

	CountDocum integer;
	CountCI integer;

BEGIN

	FOR CuotasNegocios IN

		select dna.*, n.cod_cli, get_codnit(n.cod_cli) as codcli
		from documentos_neg_aceptado dna
		inner join negocios n on (n.cod_neg = dna.cod_neg)
		where dna.cod_neg in (select cod_neg from negocios where id_convenio = '19' and estado_neg = 'T') order by dna.cod_neg, dna.dias LOOP --= 'FA00020' LOOP

		FactHija = '';
		candidata = '';
		FACcc = '';
		FACcg = '';
		FACpg = '';
		statusFI = '';
		statusCI = '';
		IngFi = '';
		IngCi = '';
		EstContabilizacionFI = '';
		EstContabilizacionCI = '';

		FOR FacturaPadre IN

			select *
			from con.factura
			where negasoc = CuotasNegocios.cod_neg
			      and valor_factura = CuotasNegocios.capital
			      and substring(documento,length(documento)-1, 2) !='00'
			      and substring(documento,1,2) in ('FC','FG') LOOP

			FACcc := 'CC'||substring(FacturaPadre.documento,3);
			FACcg := 'CG'||substring(FacturaPadre.documento,3);
			FACpg := 'PG'||substring(FacturaPadre.documento,3);

			--------------------------------------------------------------------------------------
			--SELECT INTO ChildFact documento::varchar from con.factura where documento in (FACcc,FACcg,FACpg);
			SELECT INTO ChildFact * from con.factura where documento in (FACcc,FACcg,FACpg);

			IF FOUND THEN
				FactHija := ChildFact.documento;
				----------------------------------------------------------------------------------------
				FOR QryCasos IN select cod_neg::varchar, CuotasNegocios.cod_cli::varchar, CuotasNegocios.codcli::varchar, item::varchar, fecha::date, CuotasNegocios.causar::varchar, capital::numeric, interes::numeric, interes_causado::numeric, FacturaPadre.documento::varchar, FactHija::varchar, ChildFact.documento::varchar, ChildFact.valor_factura::numeric, ChildFact.valor_saldo::numeric, ChildFact.fecha_vencimiento::date, 'VIVA'::varchar, 'CONTABILIZADO'::varchar, 'NA'::varchar from documentos_neg_aceptado where cod_neg = CuotasNegocios.cod_neg and item = CuotasNegocios.item LOOP
				    RETURN NEXT QryCasos;
				END LOOP;
				----------------------------------------------------------------------------------------

			ELSE
				FactHija := 'NoFiducia';

			END IF;
			--------------------------------------------------------------------------------------

			FOR FactFI IN

				select *
				,(select num_ingreso||'-'||creation_user from con.ingreso where num_ingreso in (select num_ingreso from con.ingreso_detalle where factura = f.documento and substring(num_ingreso,1,2) in ('IA','IC') ) limit 1) as ingreso
				from con.factura_detalle fd, con.factura f
				where f.documento = fd.documento
				and fd.numero_remesa = FacturaPadre.documento
				and substring(fd.documento,1,2) = 'FI' LOOP

				IF ( FactFI.reg_status = 'A' ) THEN
					statusFI = 'ANULADA';
				ELSE
					statusFI = 'VIVA';
				END IF;

				IF ( FactFI.ingreso is null ) THEN
					IngFi = 'NA';
				ELSE
					IngFi = FactFI.ingreso;
				END IF;

				SELECT count(0)::varchar as myperiod INTO CompFi from con.comprobante where numdoc = FactFI.documento;

				IF ( CompFi.myperiod = 1 ) THEN
					EstContabilizacionFI = 'CONTABILIZADO';
				ELSE
					EstContabilizacionFI = 'CONTABILIZADO Y REVERSADO';
				END IF;

				----------------------------------------------------------------------------------------
				FOR QryCasos IN select cod_neg::varchar, CuotasNegocios.cod_cli::varchar, CuotasNegocios.codcli::varchar, item::varchar, fecha::date, CuotasNegocios.causar::varchar, capital::numeric, interes::numeric, interes_causado::numeric, FacturaPadre.documento::varchar, FactHija::varchar, FactFI.documento::varchar, FactFI.valor_factura::numeric, FactFI.valor_saldo::numeric, FactFI.fecha_vencimiento::date, statusFI::varchar, EstContabilizacionFI::varchar, IngFi::varchar from documentos_neg_aceptado where cod_neg = CuotasNegocios.cod_neg and item = CuotasNegocios.item LOOP
				    RETURN NEXT QryCasos;
				END LOOP;
				----------------------------------------------------------------------------------------

				FACfi := 'CI'||substring(FactFI.documento,3);
				SELECT * INTO myrec from con.factura where documento = FACfi;
				IF FOUND THEN

					IF ( myrec.reg_status = 'A' ) THEN
						statusCI = 'ANULADA';
					ELSE
						statusCI = 'VIVA';
					END IF;

					SELECT num_ingreso||'-'||creation_user as mynum_ingreso INTO IngresoCi from con.ingreso where num_ingreso in (select num_ingreso from con.ingreso_detalle where factura = FACfi and substring(num_ingreso,1,2) in ('IA','IC') ) limit 1;

					IF ( IngresoCi.mynum_ingreso is null ) THEN
						IngCi = 'NA';
					ELSE
						IngCi = IngresoCi.mynum_ingreso;
					END IF;


					SELECT count(0)::varchar as myperiod INTO CompFi from con.comprobante where numdoc = FACfi;

					IF ( CompFi.myperiod = 1 ) THEN
						EstContabilizacionCI = 'CONTABILIZADO';
					ELSE
						EstContabilizacionCI = 'CONTABILIZADO Y REVERSADO';
					END IF;

					----------------------------------------------------------------------------------------
					FOR QryCasos IN select cod_neg::varchar, CuotasNegocios.cod_cli::varchar, CuotasNegocios.codcli::varchar, item::varchar, fecha::date, CuotasNegocios.causar::varchar, capital::numeric, interes::numeric, interes_causado::numeric, FacturaPadre.documento::varchar, FactHija::varchar, myrec.documento::varchar, myrec.valor_factura::numeric, myrec.valor_saldo::numeric, myrec.fecha_vencimiento::date, statusCI::varchar, EstContabilizacionCI::varchar, IngCi::varchar from documentos_neg_aceptado where cod_neg = CuotasNegocios.cod_neg and item = CuotasNegocios.item LOOP
					    RETURN NEXT QryCasos;
					END LOOP;
					----------------------------------------------------------------------------------------

				END IF;


			END LOOP;


		END LOOP;

	END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_resolvercausacion()
  OWNER TO postgres;
