-- Function: sp_resolvercausacionmicrocredito()

-- DROP FUNCTION sp_resolvercausacionmicrocredito();

CREATE OR REPLACE FUNCTION sp_resolvercausacionmicrocredito()
  RETURNS SETOF record AS
$BODY$
--RETURNS text AS $HYS$

DECLARE

	CuotasNegocios record;
	FacturaPadre record;
	FactMICA record;
	QryCasos record;
	_IngresoRenovacion record;
	_ContabilizacionMI record;
	_ContabilizacionCA record;

	Renovacion varchar;
	ValorRenovacion varchar;
	FechaRenovacion varchar;

	CountDocum integer;
	SumaInteresesMI numeric;
	SumaInteresesMIAnuladas numeric;
	SumaInteresesCAAnuladas numeric;

	SumaInteresesPeriodoAnterior numeric;
	SumaInteresesPeriodoAnteriorAnuladas numeric;
	SumaFacturaCA numeric;
	_SumaContabilizacionMI numeric;
	_SumaContabilizacionCAT numeric;

BEGIN

	FOR CuotasNegocios IN

		select dna.*, n.cod_cli, get_codnit(n.cod_cli) as codcli, fecha_ap::date, f_desem::date, replace(substring(dna.fecha,1,7),'-','') as periodo_vencimiento
		from documentos_neg_aceptado dna
		inner join negocios n on (n.cod_neg = dna.cod_neg)
		where dna.cod_neg in (select cod_neg from negocios where id_convenio in (10,11,12,13,37) and estado_neg = 'T') order by dna.cod_neg, dna.item LOOP

		SumaInteresesMI = 0;
		SumaInteresesMIAnuladas = 0;
		SumaFacturaCA = 0;
		SumaInteresesPeriodoAnterior = 0;
		SumaInteresesPeriodoAnteriorAnuladas = 0;

		_SumaContabilizacionMI = 0;
		_SumaContabilizacionCAT = 0;

		Renovacion = '';

		FOR FacturaPadre IN

			select *
			from con.factura
			where negasoc = CuotasNegocios.cod_neg
			      and num_doc_fen = CuotasNegocios.item
			      and substring(documento,1,2) in ('MC') /*and reg_status = ''*/ LOOP

			select into _IngresoRenovacion * from con.ingreso where num_ingreso = (select num_ingreso from con.ingreso_detalle where factura = FacturaPadre.documento and dstrct = 'FINV' and tipo_documento = 'ICA' limit 1) and cuenta = '23051103' and dstrct = 'FINV' and tipo_documento = 'ICA';
			Renovacion = _IngresoRenovacion.num_ingreso;
			ValorRenovacion = _IngresoRenovacion.vlr_ingreso;
			FechaRenovacion = _IngresoRenovacion.creation_date;

			FOR FactMICA IN

				select * --, replace(substring(fecha_ven,1,7),'-','') as periodo_fact_interes
				from con.factura
				where documento in (select documento from con.factura_detalle where numero_remesa = FacturaPadre.documento )
				      and substring(documento,1,2) in ('MI','CA') /*and reg_status = ''*/ LOOP

				--SUMA TODOS LOS MI | CA VALIDOS
				IF ( substring(FactMICA.documento,1,2) = 'MI' ) THEN

					if ( FactMICA.reg_status = '' ) then

						SumaInteresesMI := SumaInteresesMI + FactMICA.valor_factura;

					elsif ( FactMICA.reg_status = 'A' ) then

						SumaInteresesMIAnuladas := SumaInteresesMIAnuladas + FactMICA.valor_factura;

					end if;

					--CONTABILIZACION MI
					select into _ContabilizacionMI count(grupo_transaccion) as CntGpoTrscn, sum(valor_debito) as SumCmprbnt from con.comprodet where numdoc = FactMICA.documento;

					if ( _ContabilizacionMI.CntGpoTrscn = 2 ) then

						_SumaContabilizacionMI = _SumaContabilizacionMI + _ContabilizacionMI.SumCmprbnt;

					end if;


				   ELSIF ( substring(FactMICA.documento,1,2) = 'CA' ) THEN

					if ( FactMICA.reg_status = '' ) then

						SumaFacturaCA := SumaFacturaCA + FactMICA.valor_factura;

					elsif ( FactMICA.reg_status = 'A' ) then

						SumaInteresesCAAnuladas := SumaInteresesCAAnuladas + FactMICA.valor_factura;

					end if;


					--CONTABILIZACION CAT
					select into _ContabilizacionCA count(grupo_transaccion) as CntGpoTrscn, sum(valor_debito) as SumCmprbnt from con.comprodet where numdoc = FactMICA.documento;

					if ( _ContabilizacionCA.CntGpoTrscn = 3 ) then

						_SumaContabilizacionCAT = _SumaContabilizacionCAT + _ContabilizacionCA.SumCmprbnt;

					end if;


				END IF;

			END LOOP;

		END LOOP;

		-------------------------------------------------------------------------------------------------------

		FOR QryCasos IN
			select cod_neg::varchar, CuotasNegocios.fecha_ap::date, CuotasNegocios.f_desem::date, CuotasNegocios.cod_cli::varchar, CuotasNegocios.codcli::varchar, item::varchar, fecha::date, CuotasNegocios.causar::varchar, capital::numeric, interes::numeric, seguro::numeric, interes_causado::numeric, cat::numeric, FacturaPadre.documento::varchar, Renovacion::varchar, ValorRenovacion::varchar, FechaRenovacion::date, FacturaPadre.valor_saldo::numeric, SumaInteresesMI::numeric, SumaInteresesMIAnuladas::numeric, _SumaContabilizacionMI::numeric, SumaFacturaCA::numeric, SumaInteresesCAAnuladas::numeric, _SumaContabilizacionCAT::numeric
			from documentos_neg_aceptado
			where cod_neg = CuotasNegocios.cod_neg and item = CuotasNegocios.item
		LOOP
		    RETURN NEXT QryCasos;
		END LOOP;

	END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_resolvercausacionmicrocredito()
  OWNER TO postgres;
