-- Function: sp_detallecarteraxsancionxconsolidadomicro(numeric, character varying, character varying)

-- DROP FUNCTION sp_detallecarteraxsancionxconsolidadomicro(numeric, character varying, character varying);

CREATE OR REPLACE FUNCTION sp_detallecarteraxsancionxconsolidadomicro(periodoasignacion numeric, unidadnegocio character varying, negocioref character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE

	CarteraGeneral record;
	cuentasRecord record;
	cuentasRecordTotal record;
	ClienteRec record;
	FacturaActual record;
	NegocioAvales record;
	_ConceptRec record;
	_Sancion record;
	_sanciofa record;

	FechaCortePeriodo varchar;
	VencimientoMayor varchar;

	PeriodoTramo numeric;
	_Tasa numeric;
	_IxM numeric;
	_SumIxM numeric;
	_GaC numeric;
	_SumGaC numeric;
	BolsaSaldo numeric;
	Diferencia numeric;
	VlDetFactura numeric;
	_Base numeric;

	vlor_ingreso numeric :=0;
	vlr_gac_ingreso numeric;
	vlr_ixm_ingreso numeric;
	vlr_cxc numeric;
	contador numeric :=0;

	VerifyDetails varchar;
	numero_ingreso varchar :='';
	numero_ingreso_aux varchar :='';
	numero_negocio_aux  varchar :='';
	fecha_ultimo_pago varchar:='';

	_GI010130014205 numeric = 0;
	_GI010010014205 numeric = 0;
	_I010130024170 numeric = 0;
	_I010010014170 numeric = 0;

	resta numeric :=0;
	fechaCorte varchar :='';

	BEGIN

		if ( substring(periodoasignacion,5) = '01' ) then
			PeriodoTramo = substring(periodoasignacion,1,4)::numeric-1||'12';
		else
			PeriodoTramo = periodoasignacion::numeric - 1;
		end if;

		--PeriodoTramo = PeriodoAsignacion::numeric - 1;
		select into FechaCortePeriodo to_char(to_timestamp(substring(PeriodoTramo,1,4)::numeric || '-' || to_char(substring(PeriodoTramo,5,2)::numeric,'FM00') || '-01', 'YYYY-MM-DD') + INTERVAL '1 month' - INTERVAL '1 days', 'YYYY-MM-DD');

		FOR CarteraGeneral IN

			SELECT
			       negasoc::varchar as negocio,
			       nit::varchar as cedula,
			       ''::varchar as nombre_cliente,
			       num_doc_fen::varchar as cuota,
			       fecha_vencimiento::date,
			       documento::varchar,
			       (FechaCortePeriodo::date-fecha_vencimiento)::numeric AS dias_vencidos,
			       ''::varchar as vencimiento_mayor,
			       '-'::varchar as status,
			       valor_saldo::numeric,
			       0::numeric as debido_cobrar,
			       0::numeric as interes_mora,
			       0::numeric as gasto_cobranza,
			       0::numeric as valor_ingreso,
			       ''::varchar as num_ingreso,
			       ''::varchar as fecha_pago_ingreso,
			       0::numeric as valor_cxc_ingreso,
			       0::numeric as GI010130014205,
			       0::numeric as GI010010014205,
			       0::numeric as I010130024170,
			       0::numeric as I010010014170,
			       0::numeric as valor_gac_ingreso,
			       0::numeric as valor_ixm_ingreso
			FROM con.foto_cartera f
			WHERE periodo_lote = periodoasignacion
				AND reg_status = ''
				AND id_convenio in (SELECT id_convenio FROM rel_unidadnegocio_convenios WHERE id_unid_negocio IN  (SELECT id FROM unidad_negocio WHERE id = unidadnegocio))
				AND substring(documento,1,2) not in ('CP','FF','DF') AND replace(substring(f.fecha_vencimiento,1,7),'-','')::numeric <= periodoasignacion
				AND valor_saldo > 0
				--AND negasoc = 'MC01944'
			GROUP BY negasoc,cedula,nombre_cliente,cuota,fecha_vencimiento,dias_vencidos,vencimiento_mayor,status,debido_cobrar,interes_mora,gasto_cobranza,valor_gac_ingreso,valor_ixm_ingreso,creation_date,documento,valor_saldo
			ORDER BY negasoc,num_doc_fen::numeric,creation_date

		LOOP
			contador :=contador+1;
			raise notice 'Item : %  negocio : %', contador, CarteraGeneral.negocio;

			SELECT INTO ClienteRec nomcli FROM cliente WHERE nit = CarteraGeneral.cedula;
			CarteraGeneral.nombre_cliente = ClienteRec.nomcli;

			CarteraGeneral.debido_cobrar = CarteraGeneral.valor_saldo;
			BolsaSaldo = CarteraGeneral.valor_saldo;

			SELECT INTO VencimientoMayor
				CASE WHEN maxdia >= 365 THEN '8- MAYOR A 1 AÑO'
				     WHEN maxdia >= 181 THEN '7- ENTRE 180 Y 360'
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
					  AND fra.negasoc =CarteraGeneral.negocio
					  AND fra.tipo_documento = 'FAC'
					  AND fra.periodo_lote = PeriodoAsignacion
				 GROUP BY negasoc

			) tabla2;

			CarteraGeneral.vencimiento_mayor = VencimientoMayor;

			--SANCIONES
			_SumIxM = 0;
			_SumGaC = 0;

			--VALORES CxC
			vlr_cxc = 0;
			vlr_gac_ingreso = 0;
			vlr_ixm_ingreso = 0;

			CarteraGeneral.interes_mora= _SumIxM;
			CarteraGeneral.gasto_cobranza= _SumGaC;

			_GI010130014205 = 0;
			_GI010010014205 = 0;
			_I010130024170 = 0;
			_I010010014170 = 0;

		        --_Sancion
			--VALIDACION PARA CONSULTAR SOLO UNA VEZ POR NEGOCIO.
			IF (numero_negocio_aux = '') THEN

			        raise notice 'SE EJECUTA SOLO UNA VEZ';
				numero_negocio_aux := CarteraGeneral.negocio ;

				FOR cuentasRecord in

					SELECT
						i.num_ingreso,
						i.fecha_consignacion::varchar,
						i.vlr_ingreso as valor_ingreso_cabe,
						id.cuenta,
						sum(id.valor_ingreso) as valor_ingreso_det
					FROM con.ingreso_detalle id
					INNER JOIN con.ingreso i ON (id.num_ingreso = i.num_ingreso and id.dstrct = i.dstrct and i.nitcli=id.nitcli )
					WHERE id.dstrct = 'FINV'
						and id.tipo_documento in ('ING','ICA')
						and i.reg_status = ''
						and i.nitcli= CarteraGeneral.cedula
						and id.reg_status = ''
						and replace(substring(i.fecha_consignacion,1,7),'-','') = PeriodoAsignacion
						and id.num_ingreso in (
									select distinct num_ingreso
									from con.ingreso_detalle id, con.factura f
									where id.factura = f.documento
									and f.negasoc = CarteraGeneral.negocio
									and f.tipo_documento in ('FAC','NDC')
									and f.reg_status = ''
									and f.devuelta != 'S'
									and f.corficolombiana != 'S'
									and f.endoso_fenalco !='S'
									and id.documento != ''
								      )
					group by i.num_ingreso,i.fecha_consignacion,i.vlr_ingreso,id.cuenta
					order by fecha_consignacion::date desc, num_ingreso

				LOOP

					RAISE NOTICE 'ENTRO';
					RAISE NOTICE 'CUENTA: %',cuentasRecord.cuenta;

					IF ( cuentasRecord.cuenta in ('I010130014205','I010010014205') ) THEN
						vlr_gac_ingreso :=vlr_gac_ingreso+cuentasRecord.valor_ingreso_det;

						IF(cuentasRecord.cuenta = 'I010130014205') THEN
						  _GI010130014205 = _GI010130014205 + cuentasRecord.valor_ingreso_det;
						ELSIF(cuentasRecord.cuenta = 'I010010014205') THEN
						  _GI010010014205 = _GI010010014205 + cuentasRecord.valor_ingreso_det;
						END IF;

					ELSIF ( cuentasRecord.cuenta in ('I010130024170','I010010014170') ) THEN
						vlr_ixm_ingreso :=vlr_ixm_ingreso+cuentasRecord.valor_ingreso_det;

						IF(cuentasRecord.cuenta = 'I010130024170') THEN
						  _I010130024170 = _I010130024170 + cuentasRecord.valor_ingreso_det;
						ELSIF(cuentasRecord.cuenta = 'I010010014170') THEN
						  _I010010014170 = _I010010014170 + cuentasRecord.valor_ingreso_det;
						END IF;

					ELSE
						vlr_cxc = vlr_cxc + cuentasRecord.valor_ingreso_det;
					END IF;

					if ( numero_ingreso_aux = '' ) then

						numero_ingreso:= cuentasRecord.num_ingreso;
						vlor_ingreso:=cuentasRecord.valor_ingreso_cabe;
						numero_ingreso_aux:=cuentasRecord.num_ingreso;

					elsif (numero_ingreso_aux != cuentasRecord.num_ingreso ) then

						numero_ingreso:=numero_ingreso||','||cuentasRecord.num_ingreso ;
						vlor_ingreso:=vlor_ingreso+cuentasRecord.valor_ingreso_cabe;
						numero_ingreso_aux:=cuentasRecord.num_ingreso ;
					end if;

					--vlor_ingreso:=cuentasRecord.valor_ingreso_cabe;
					fecha_ultimo_pago := cuentasRecord.fecha_consignacion;

				END LOOP;

			ELSIF ( numero_negocio_aux != CarteraGeneral.negocio ) THEN

				raise notice 'SE EJECUTA CUANDO SE CAMBIA DE NEGOCIO';

				vlor_ingreso:= 0;
			        numero_ingreso:='';
				numero_ingreso_aux :='';
				--vlr_gac_ingreso :=0;
				--vlr_ixm_ingreso :=0;
				fecha_ultimo_pago :='';
				numero_negocio_aux:= CarteraGeneral.negocio;

				FOR cuentasRecord in

					SELECT
						i.num_ingreso,
						i.fecha_consignacion::varchar,
						i.vlr_ingreso as valor_ingreso_cabe,
						id.cuenta,
						sum(id.valor_ingreso) as valor_ingreso_det
					FROM con.ingreso_detalle id
					INNER JOIN con.ingreso i ON (id.num_ingreso = i.num_ingreso and id.dstrct = i.dstrct and i.nitcli=id.nitcli )
					WHERE id.dstrct = 'FINV'
						and id.tipo_documento in ('ING','ICA')
						and i.reg_status = ''
						and i.nitcli= CarteraGeneral.cedula
						and id.reg_status = ''
						and replace(substring(i.fecha_consignacion,1,7),'-','') = PeriodoAsignacion
						and id.num_ingreso in (
									select distinct num_ingreso
									from con.ingreso_detalle id, con.factura f
									where id.factura = f.documento
									and f.negasoc = CarteraGeneral.negocio
									and f.tipo_documento in ('FAC','NDC')
									and f.reg_status = ''
									and f.devuelta != 'S'
									and f.corficolombiana != 'S'
									and f.endoso_fenalco !='S'
									and id.documento != ''
								      )
					group by i.num_ingreso,i.fecha_consignacion,i.vlr_ingreso,id.cuenta
					order by fecha_consignacion::date desc, num_ingreso

				LOOP

					RAISE NOTICE 'ENTRO';

					IF ( cuentasRecord.cuenta in ('I010130014205','I010010014205') ) THEN
						vlr_gac_ingreso :=vlr_gac_ingreso+cuentasRecord.valor_ingreso_det;

						IF(cuentasRecord.cuenta = 'I010130014205') THEN
						  _GI010130014205 = _GI010130014205 + cuentasRecord.valor_ingreso_det;
						ELSIF(cuentasRecord.cuenta = 'I010010014205') THEN
						  _GI010010014205 = _GI010010014205 + cuentasRecord.valor_ingreso_det;
						END IF;

					ELSIF ( cuentasRecord.cuenta in ('I010130024170','I010010014170') ) THEN
						vlr_ixm_ingreso :=vlr_ixm_ingreso+cuentasRecord.valor_ingreso_det;

						IF(cuentasRecord.cuenta = 'I010130024170') THEN
						  _I010130024170 = _I010130024170 + cuentasRecord.valor_ingreso_det;
						ELSIF(cuentasRecord.cuenta = 'I010010014170') THEN
						  _I010010014170 = _I010010014170 + cuentasRecord.valor_ingreso_det;
						END IF;

					ELSE
						vlr_cxc = vlr_cxc + cuentasRecord.valor_ingreso_det;

					END IF;

					if ( numero_ingreso_aux = '' ) then

						numero_ingreso:= cuentasRecord.num_ingreso;
						vlor_ingreso:=cuentasRecord.valor_ingreso_cabe;
						numero_ingreso_aux:=cuentasRecord.num_ingreso;

					elsif (numero_ingreso_aux != cuentasRecord.num_ingreso ) then

						numero_ingreso:=numero_ingreso||','||cuentasRecord.num_ingreso ;
						vlor_ingreso:=vlor_ingreso+cuentasRecord.valor_ingreso_cabe;
						numero_ingreso_aux:=cuentasRecord.num_ingreso ;
					end if;

					--vlor_ingreso:=cuentasRecord.valor_ingreso_cabe;
					fecha_ultimo_pago := cuentasRecord.fecha_consignacion;

				END LOOP;

			END IF;

			--RAISE NOTICE 'DESPUES  DEL INGRESO: %', numero_ingreso;

			CarteraGeneral.valor_ingreso := vlor_ingreso;
			CarteraGeneral.num_ingreso := numero_ingreso;
			CarteraGeneral.fecha_pago_ingreso := fecha_ultimo_pago;
			CarteraGeneral.valor_gac_ingreso := vlr_gac_ingreso;
			CarteraGeneral.valor_ixm_ingreso := vlr_ixm_ingreso;
			CarteraGeneral.valor_cxc_ingreso = vlr_cxc;

			CarteraGeneral.GI010130014205 = _GI010130014205;
			CarteraGeneral.GI010010014205 = _GI010010014205;
			CarteraGeneral.I010130024170 = _I010130024170;
			CarteraGeneral.I010010014170 = _I010010014170;

			--calculamos otra vez los gastos de cobranza si el pago es mayor que la fecha vencimiento.
			IF(fecha_ultimo_pago != '') THEN
				resta := fecha_ultimo_pago::date - CarteraGeneral.fecha_vencimiento::date;
				fechaCorte := fecha_ultimo_pago;
			ELSE
				resta :=-1;
				--fechaCorte := FechaCortePeriodo::date +  INTERVAL '1 month';
			END IF;

			IF(resta > 0)THEN

				raise notice 'El man pago despues de pitos: %', resta;

				_SumGaC :=0;
				_SumIxM :=0;
				--Conceptos
				SELECT INTO _ConceptRec * FROM conceptos_recaudo WHERE prefijo = substring(CarteraGeneral.documento,1,2) AND (fechaCorte::date - CarteraGeneral.fecha_vencimiento ) BETWEEN dias_rango_ini AND dias_rango_fin and id_unidad_negocio = unidadnegocio;

				--Sanciones
				FOR _Sancion IN

					SELECT * FROM sanciones_condonaciones
					WHERE id_tipo_acto = 1 AND id_conceptos_recaudo = _ConceptRec.id
					AND (fechaCorte::date - CarteraGeneral.fecha_vencimiento )  BETWEEN dias_rango_ini AND dias_rango_fin
					AND periodo = periodoasignacion and id_unidad_negocio = unidadnegocio
				LOOP

					IF ( _Sancion.categoria = 'IXM' ) THEN

						if (  fechaCorte::date> CarteraGeneral.fecha_vencimiento::date ) then

						        select into _Tasa tasa_usura/100 from convenios where id_convenio = (select id_convenio from negocios where cod_neg=CarteraGeneral.negocio);
							_IxM = ROUND( CarteraGeneral.valor_saldo *(_Tasa/30) * ( fechaCorte::date - CarteraGeneral.fecha_vencimiento)::numeric );
							_SumIxM = _SumIxM + _IxM;

						end if;

					END IF;

					IF ( _Sancion.categoria = 'GAC' ) THEN

						if (fechaCorte::date  > CarteraGeneral.fecha_vencimiento::date ) then --if ( now()::date > CarteraxCuota.fecha_vencimiento::date ) then

							_GaC = ROUND((CarteraGeneral.valor_saldo * _Sancion.porcentaje::numeric)/100);
							_SumGaC = _SumGaC + _GaC;
						end if;

					END IF;

				END LOOP;

				CarteraGeneral.interes_mora= _SumIxM;
				CarteraGeneral.gasto_cobranza= _SumGaC;

			END IF;

			--fin pagos despues de pito
			RETURN NEXT CarteraGeneral;

		END LOOP;


	END;

	$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_detallecarteraxsancionxconsolidadomicro(numeric, character varying, character varying)
  OWNER TO postgres;
