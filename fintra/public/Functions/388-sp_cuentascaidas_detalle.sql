-- Function: sp_cuentascaidas_detalle(character varying, numeric, character varying)

-- DROP FUNCTION sp_cuentascaidas_detalle(character varying, numeric, character varying);

CREATE OR REPLACE FUNCTION sp_cuentascaidas_detalle(periodoasignacion character varying, unidadnegocio numeric, venc_mayor character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE
PeriodoTramo varchar;
TramoAnterior varchar;
Cuentas record;
_ConceptRec record;
_Sancion record;
CarteraxCabeceraCta record;
CarteraxCuota record;
Recaudos record;

venc_mayor_anterior varchar;
venc_mayor_actual varchar;
Cuentas_caidas record;
FechaCortePeriodo varchar;
FechaCortePeriodoAnt varchar;
VerifyDetails varchar;
undNegocio varchar;

BolsaSaldo numeric;
Diferencia numeric;
_Base numeric;
_IxM numeric;
_GaC numeric;
_Tasa numeric;
_SumIxM numeric;
_SumGaC numeric;
_SumBase numeric;
_cuota numeric;


BEGIN

	if ( substring(PeriodoAsignacion,5) = '01' ) then
		PeriodoTramo = substring(PeriodoAsignacion,1,4)::numeric-1||'12';
		TramoAnterior = substring(PeriodoAsignacion,1,4)::numeric-1||'11';
	elsif ( substring(PeriodoAsignacion,5) = '02' ) then
		PeriodoTramo = PeriodoAsignacion::numeric - 1;
		TramoAnterior = substring(PeriodoAsignacion,1,4)::numeric-1||'12';
	else
		PeriodoTramo = PeriodoAsignacion::numeric - 1;
		TramoAnterior = PeriodoAsignacion::numeric - 1;
	end if;

	RAISE NOTICE 'PeriodoTramo: % TramoAnterior: %',PeriodoTramo,TramoAnterior;

	select into FechaCortePeriodo to_char(to_timestamp(substring(PeriodoTramo,1,4)::numeric || '-' || to_char(substring(PeriodoTramo,5,2)::numeric,'FM00') || '-01', 'YYYY-MM-DD') + INTERVAL '1 month' - INTERVAL '1 days', 'YYYY-MM-DD');
	select into FechaCortePeriodoAnt to_char(to_timestamp(substring(TramoAnterior,1,4)::numeric || '-' || to_char(substring(TramoAnterior,5,2)::numeric,'FM00') || '-01', 'YYYY-MM-DD') + INTERVAL '1 month' - INTERVAL '1 days', 'YYYY-MM-DD');

	raise notice 'FechaCortePeriodo: % FechaCortePeriodoAnt: % und_neg: %',FechaCortePeriodo,FechaCortePeriodoAnt,unidadnegocio;

	FOR Cuentas IN
		SELECT
			fc.nit::varchar as cedula,
			nit.nombre::varchar,
			cc.negocio::varchar,
			''::varchar as und_negocio,
			n.id_convenio::numeric,
			''::varchar as venc_mayor_ant,
			0::numeric as cartera_sancion,
			sum(fc.valor_saldo)::numeric as valor_debido,
			fc.valor_factura::numeric as valor_cuota,
			cc.valor_recaudo::numeric,
			cc.recaudo_aplicado::numeric
		FROM tem.cuentas_caidas_temp cc, con.foto_cartera fc, negocios n, nit
		WHERE cc.negocio = fc.negasoc and fc.negasoc = n.cod_neg  and fc.dstrct = n.dist and nit.cedula = fc.nit
			and fc.reg_status = ''
			and fc.valor_saldo > 0
			and fc.dstrct = 'FINV'
			and fc.tipo_documento in ('FAC','NDC')
			and substring(fc.documento,1,2) not in ('CP','FF','DF')
			and fc.periodo_lote = periodoasignacion
			and cc.periodo= periodoasignacion
			and cc.vencimiento_mayor = venc_mayor
			--and fc.negasoc in ('FA12939','FA13131','FA06251','FA12640')
			and n.id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio = unidadnegocio)
			and replace(substring(fc.fecha_vencimiento,1,7),'-','')::numeric <= periodoasignacion::numeric
		GROUP BY cc.negocio, fc.nit, nit.nombre, n.id_convenio,fc.valor_factura,cc.valor_recaudo,cc.recaudo_aplicado


	LOOP
		_SumBase = 0;
		_SumIxM = 0;
		_SumGaC = 0;

		SELECT INTO undNegocio descripcion FROM unidad_negocio WHERE id = unidadnegocio;
		Cuentas.und_negocio = undNegocio;

		SELECT INTO venc_mayor_anterior (
					SELECT
						CASE WHEN maxdia > 365 THEN '8- MAYOR A 1 AÑO'
						     WHEN maxdia >= 180 THEN '7- ENTRE 181 Y 365'
						     WHEN maxdia >= 121 THEN '6- ENTRE 121 Y 180'
						     WHEN maxdia >= 91 THEN '5- ENTRE 91 Y 120'
						     WHEN maxdia >= 61 THEN '4- ENTRE 61 Y 90'
						     WHEN maxdia >= 31 THEN '3- ENTRE 31 Y 60'
						     WHEN maxdia >= 1 THEN '2- 1 A 30'
						     WHEN maxdia <= 0 THEN '1- CORRIENTE'
							ELSE '0' END AS rango
					FROM (
						 SELECT max(FechaCortePeriodo::date-(fecha_vencimiento)) as maxdia
						 FROM con.foto_cartera fra
						 WHERE fra.dstrct = 'FINV'
							  AND fra.valor_saldo > 0
							  AND fra.reg_status = ''
							  AND fra.negasoc = Cuentas.negocio
							  AND fra.tipo_documento in ('FAC','NDC')
							  AND fra.periodo_lote = PeriodoTramo
						 GROUP BY negasoc

					) tabla2
					) as vencimiento_mayor;

		Cuentas.venc_mayor_ant = venc_mayor_anterior;
		raise notice 'negocio: %',Cuentas.negocio;
		FOR CarteraxCabeceraCta IN

			SELECT DISTINCT ON (f.num_doc_fen)
				f.negasoc as negocio,
				f.documento,
				f.num_doc_fen as cuota,
				f.valor_factura,
				f.valor_abono,
				f.valor_saldo,
				f.fecha_factura,
				f.fecha_vencimiento
			FROM con.foto_cartera f
			WHERE   f.reg_status = ''
				and f.dstrct = 'FINV'
				and f.tipo_documento in ('FAC','NDC')
				and f.valor_saldo > 0
				and f.negasoc = Cuentas.negocio
				and f.id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio = unidadnegocio)
				and substring(f.documento,1,2) not in ('CP','FF')
				and replace(substring(f.fecha_vencimiento,1,7),'-','')::numeric <= periodoasignacion
				and f.periodo_lote = periodoasignacion::numeric
				order by f.num_doc_fen

		LOOP
			BolsaSaldo = CarteraxCabeceraCta.valor_abono;

			FOR CarteraxCuota IN

				--NEGOCIO PRINCIPAL
				SELECT negocio, cedula, prefijo, cuota, fecha_factura, fecha_vencimiento, sum(valor_saldo) as valor_saldo, (FechaCortePeriodoAnt::DATE-fecha_vencimiento::DATE) AS dias_vencidos FROM (

					SELECT
						f.negasoc as negocio,
						f.nit AS cedula,
						f.documento,
						fr.descripcion as prefijo,
						f.num_doc_fen as cuota,
						f.fecha_factura,
						f.fecha_vencimiento,
						fr.valor_unitario as valor_saldo
					FROM con.foto_cartera f, con.factura_detalle fr
					WHERE   f.documento = fr.documento
						and f.reg_status = ''
						and f.dstrct = 'FINV'
						and f.tipo_documento in ('FAC','NDC')
						and fr.reg_status = ''
						and fr.dstrct = 'FINV'
						and fr.tipo_documento in ('FAC','NDC')
						and f.valor_saldo > 0
						and f.negasoc = CarteraxCabeceraCta.negocio
						and f.num_doc_fen = CarteraxCabeceraCta.cuota
						and substring(f.documento,1,2) not in ('CP','FF')
						and f.codcli != 'CL00201'
						and replace(substring(f.fecha_vencimiento,1,7),'-','')::numeric <= periodoasignacion
						and substring(f.documento,1,2) not in ('CP','FF')
						and f.periodo_lote = periodoasignacion::numeric
					) as c
				GROUP BY negocio, cedula, prefijo, cuota, fecha_vencimiento, fecha_factura, dias_vencidos
				ORDER BY prefijo DESC
			LOOP

				_IxM = 0;
				_Base = 0;
				_GaC = 0;

				-----------------------------------------------------------------------------------------------------------------------
				VerifyDetails = 'N';
				Diferencia = BolsaSaldo - CarteraxCuota.valor_saldo;

				raise notice 'Negocio: %, Cuota: %, BolsaSaldo: %, valor_saldo: %',CarteraxCuota.negocio, CarteraxCuota.cuota, BolsaSaldo, CarteraxCuota.valor_saldo;

				if ( Diferencia <= 0 and BolsaSaldo > 0) then

					_Base = CarteraxCuota.valor_saldo - BolsaSaldo;

					BolsaSaldo = 0;


				elsif ( Diferencia > 0 and BolsaSaldo > 0 ) then

					_Base = 0;

					BolsaSaldo = BolsaSaldo - CarteraxCuota.valor_saldo;

				elsif ( BolsaSaldo <= 0 ) then
					_Base = CarteraxCuota.valor_saldo;
				end if;
				--

				-----------------------------------------------------------------------------------------------------------------------

				if ( _Base > 0 ) then
					raise notice 'Negocio: % Cuota: % _Base: % Dias: % Prefijo: %',CarteraxCuota.negocio, CarteraxCuota.cuota,_Base,CarteraxCuota.dias_vencidos,CarteraxCuota.prefijo;
					--SUMA DE BASES
					_SumBase = _SumBase + _Base;

					--Conceptos
					SELECT INTO _ConceptRec * FROM conceptos_recaudo WHERE prefijo = CarteraxCuota.prefijo AND CarteraxCuota.dias_vencidos BETWEEN dias_rango_ini AND dias_rango_fin and id_unidad_negocio = unidadnegocio;
					if found then

						--Sanciones
						FOR _Sancion IN SELECT * FROM sanciones_condonaciones WHERE id_tipo_acto = 1 AND id_conceptos_recaudo = _ConceptRec.id AND CarteraxCuota.dias_vencidos BETWEEN dias_rango_ini AND dias_rango_fin AND periodo = periodoasignacion and id_unidad_negocio = unidadnegocio LOOP

							IF ( _Sancion.categoria = 'IXM' ) THEN

								if ( FechaCortePeriodo::date > CarteraxCuota.fecha_vencimiento::date ) then

									select into _Tasa tasa_interes/100 from convenios where id_convenio = Cuentas.id_convenio;

									_IxM = ROUND( _Base*(_Tasa/30) * (FechaCortePeriodo::date - CarteraxCuota.fecha_vencimiento::date)::numeric );
									_SumIxM = _SumIxM + _IxM;

								end if;

							END IF;

							IF ( _Sancion.categoria = 'GAC' ) THEN

								if ( FechaCortePeriodo::date > CarteraxCuota.fecha_vencimiento::date ) then
									_GaC = ROUND((_Base * _Sancion.porcentaje::numeric)/100);
									_SumGaC = _SumGaC + _GaC;
								end if;

							END IF;
							RAISE NOTICE '_SumGaC: % _SumIxM: %',_SumGaC,_SumIxM;
						END LOOP; --_Sancion
						Cuentas.cartera_sancion = _SumBase + _SumGaC + _SumIxM;
					end if;
				end if;
			END LOOP;
		END LOOP;

		/*SELECT INTO Recaudos * FROM sp_recaudototalnegocio (Cuentas.negocio,periodoasignacion) as pg (valor_pagos numeric, valor_sanciones numeric);

		Cuentas.valor_recaudo = Recaudos.valor_pagos;
		Cuentas.recaudo_aplicado = Recaudos.valor_sanciones + Recaudos.valor_pagos;
		RAISE NOTICE 'RECAUDO: % DEBIDO: %',Cuentas.valor_recaudo * 0.95,Cuentas.valor_debido;
		IF(Cuentas.valor_recaudo >= (Cuentas.valor_debido * 0.95)) THEN
			Cuentas.caida='N';
		END IF;*/

		RETURN NEXT Cuentas;

	END LOOP;


END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_cuentascaidas_detalle(character varying, numeric, character varying)
  OWNER TO postgres;
