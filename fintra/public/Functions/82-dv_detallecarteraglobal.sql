-- Function: dv_detallecarteraglobal(numeric, character varying, character varying)

-- DROP FUNCTION dv_detallecarteraglobal(numeric, character varying, character varying);

CREATE OR REPLACE FUNCTION dv_detallecarteraglobal(periodoasignacion numeric, unidadnegocio character varying, negocioref character varying)
  RETURNS SETOF record AS
$BODY$

	DECLARE

		CarteraGeneral record;
		ClienteRec record;
		FacturaActual record;

		NegocioAvales record;
		NegocioSegurus record;
		_NegocioGps record;

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

		VerifyDetails varchar;

	BEGIN

		if ( substring(periodoasignacion,5) = '01' ) then
			PeriodoTramo = substring(periodoasignacion,1,4)::numeric-1||'12';
		else
			PeriodoTramo = periodoasignacion::numeric - 1;
		end if;

		--PeriodoTramo = PeriodoAsignacion::numeric - 1;

		select into FechaCortePeriodo to_char(to_timestamp(substring(PeriodoTramo,1,4)::numeric || '-' || to_char(substring(PeriodoTramo,5,2)::numeric,'FM00') || '-01', 'YYYY-MM-DD') + INTERVAL '1 month' - INTERVAL '1 days', 'YYYY-MM-DD');

		FOR CarteraGeneral IN

			select negasoc::varchar as negocio,
			       nit::varchar as cedula,
			       ''::varchar as nombre_cliente,
			       num_doc_fen::varchar as cuota,
			       documento::varchar,
			       fecha_vencimiento::date,
			       (FechaCortePeriodo::date-fecha_vencimiento)::numeric AS dias_vencidos,
			       ''::varchar as vencimiento_mayor,
			       '-'::varchar as status,
			       valor_saldo::numeric,
			       0::numeric as debido_cobrar,
			       0::numeric as interes_mora,
			       0::numeric as gasto_cobranza
			from con.foto_cartera f
			where negasoc = NegocioRef
			and periodo_lote = PeriodoAsignacion
			and reg_status = ''
			--and descripcion != 'CXC AVAL'
			and substring(documento,1,2) not in ('CP','FF','DF')
			and valor_saldo > 0
			--and replace(substring(f.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoAsignacion
			and f.fecha_vencimiento < now()
			order by num_doc_fen::numeric,creation_date

		LOOP
			RAISE NOTICE 'ITERA ';
			SELECT INTO ClienteRec nomcli FROM cliente WHERE nit = CarteraGeneral.cedula;
			CarteraGeneral.nombre_cliente = ClienteRec.nomcli;

			--SELECT INTO FacturaActual valor_saldo FROM con.factura WHERE documento =  CarteraGeneral.documento;
			--esto sirve descomentalo y fuera.
			IF(substring(CarteraGeneral.documento,1,2) IN ('FG','CG'))THEN

				SELECT INTO FacturaActual valor_saldo FROM con.factura WHERE valor_saldo >0 AND reg_status='' and dstrct='FINV'
				and documento = 'FG'||substring(CarteraGeneral.documento,3) OR  documento = 'CG'||substring(CarteraGeneral.documento,3);

			ELSE
				SELECT INTO FacturaActual valor_saldo FROM con.factura WHERE valor_saldo >0 AND reg_status='' and dstrct='FINV'  and documento = CarteraGeneral.documento;
			END IF;

			raise notice 'FacturaActual PASO%',FacturaActual;
			if FacturaActual is not null then

				--lo viejo antes del cambio.
				CarteraGeneral.debido_cobrar = FacturaActual.valor_saldo;
				BolsaSaldo = FacturaActual.valor_saldo;

			else
				CarteraGeneral.debido_cobrar = 0;
				BolsaSaldo = 0;
			end if;

			--cambio hasta aqui...

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
				 --SELECT FechaCortePeriodo::date-fecha_vencimiento as maxdia
				 FROM con.foto_cartera fra
				 WHERE fra.dstrct = 'FINV'
					  AND fra.valor_saldo > 0
					  AND fra.reg_status = ''
					  AND fra.negasoc = NegocioRef
					  --AND fra.documento = CarteraGeneral.documento
					  AND fra.tipo_documento = 'FAC'
					  AND fra.periodo_lote = PeriodoAsignacion
				 GROUP BY negasoc

			) tabla2;

			CarteraGeneral.vencimiento_mayor = VencimientoMayor;

			------- Sancion
			_SumIxM = 0;
			_SumGaC = 0;

			IF (unidadnegocio ='1') THEN

				--Conceptos
				SELECT INTO _ConceptRec * FROM conceptos_recaudo WHERE prefijo = substring(CarteraGeneral.documento,1,2) AND (now()::date - CarteraGeneral.fecha_vencimiento ) BETWEEN dias_rango_ini AND dias_rango_fin and id_unidad_negocio = unidadnegocio;
				--Sanciones

				FOR _Sancion IN SELECT * FROM sanciones_condonaciones
						WHERE id_tipo_acto = 1 AND id_conceptos_recaudo = _ConceptRec.id
						     AND (now()::date - CarteraGeneral.fecha_vencimiento )  BETWEEN dias_rango_ini AND dias_rango_fin
						     AND periodo = periodoasignacion and id_unidad_negocio = unidadnegocio  LOOP

					IF ( _Sancion.categoria = 'IXM' ) THEN

						if (  now()::date> CarteraGeneral.fecha_vencimiento::date ) then --if ( now()::date > CarteraxCuota.fecha_vencimiento::date ) then

							select into _Tasa tasa_usura/100 from convenios where id_convenio = (select id_convenio from negocios where cod_neg=negocioref);

							_IxM = ROUND( FacturaActual.valor_saldo *(_Tasa/30) * (now()::date - CarteraGeneral.fecha_vencimiento)::numeric );
							_SumIxM = _SumIxM + _IxM;
						end if;

					END IF;

					IF ( _Sancion.categoria = 'GAC' ) THEN

						if ( now()::date  > CarteraGeneral.fecha_vencimiento::date ) then --if ( now()::date > CarteraxCuota.fecha_vencimiento::date ) then
							raise notice ' _Sancion.porcentaje: %',_Sancion.porcentaje;
							_GaC = ROUND((FacturaActual.valor_saldo * _Sancion.porcentaje::numeric)/100);
							_SumGaC = _SumGaC + _GaC;
						end if;

					END IF;

				END LOOP;

			ELSE

			        --AQUI VA PARA EL RESTO.
				raise notice 'documento: %', CarteraGeneral.documento;
				FOR _sanciofa IN (SELECT * FROM con.factura_detalle where documento = CarteraGeneral.documento) LOOP

					VerifyDetails = 'N';
					raise notice 'BolsaSaldo: %, valor_unitario: %', BolsaSaldo, _sanciofa.valor_unitario;
					Diferencia = BolsaSaldo - _sanciofa.valor_unitario; --valor_unitario
					raise notice 'Diferencia: %', Diferencia;

					if ( Diferencia <= 0 and BolsaSaldo > 0) then

						VlDetFactura = BolsaSaldo;
						_Base = VlDetFactura;

						BolsaSaldo = BolsaSaldo - _sanciofa.valor_unitario; --valor_unitario
						VerifyDetails = 'S';

					elsif ( Diferencia > 0 and BolsaSaldo > 0 ) then

						VlDetFactura = _sanciofa.valor_unitario;
						_Base = VlDetFactura;

						BolsaSaldo = BolsaSaldo - _sanciofa.valor_unitario; --valor_unitario
						VerifyDetails = 'S';

					end if;

					raise notice 'VerifyDetails  %', VerifyDetails;
					if ( VerifyDetails = 'S' ) then
						-- Sancion
						--Conceptos
						SELECT INTO _ConceptRec * FROM conceptos_recaudo WHERE prefijo = substring(_sanciofa.descripcion,1,10)
						AND (now()::date - CarteraGeneral.fecha_vencimiento ) BETWEEN dias_rango_ini AND dias_rango_fin and id_unidad_negocio = unidadnegocio;
					        raise notice '_ConceptRec: %',_ConceptRec;
						FOR _Sancion IN

							SELECT * FROM sanciones_condonaciones
							WHERE id_conceptos_recaudo = _ConceptRec.id
							AND id_tipo_acto = 1
							AND (now()::date - CarteraGeneral.fecha_vencimiento )  BETWEEN dias_rango_ini AND dias_rango_fin
							AND periodo = periodoasignacion and id_unidad_negocio = unidadnegocio


						LOOP
							raise notice '_Sancion.categoria: %',_Sancion.categoria;
							IF ( _Sancion.categoria = 'IXM' ) THEN
								raise notice 'A';
								if (  now()::date> CarteraGeneral.fecha_vencimiento::date ) then --if ( now()::date > CarteraxCuota.fecha_vencimiento::date ) then

									select into _Tasa tasa_usura/100 from convenios where id_convenio = (select id_convenio from negocios where cod_neg=negocioref);

									_IxM = ROUND( _Base *(_Tasa/30) * (now()::date - CarteraGeneral.fecha_vencimiento)::numeric );
									_SumIxM = _SumIxM + _IxM;
								end if;

							END IF;

							IF ( _Sancion.categoria = 'GAC' ) THEN
								raise notice 'B';

								if ( now()::date > CarteraGeneral.fecha_vencimiento::date ) then --if ( now()::date > CarteraxCuota.fecha_vencimiento::date ) then

									_GaC = ROUND(( _Base * _Sancion.porcentaje::numeric)/100);
									_SumGaC = _SumGaC + _GaC;
								end if;

							END IF;

						END LOOP;
					end if;

				END LOOP;

			END IF;

			CarteraGeneral.interes_mora= _SumIxM;
			CarteraGeneral.gasto_cobranza= _SumGaC;
			--_Sancion

			RETURN NEXT CarteraGeneral;

		END LOOP;

		--NEGOCIO DE AVAL
		---------------------------------------------------------------------------------------------------
		SELECT INTO NegocioAvales cod_neg from negocios where negocio_rel = NegocioRef;
		IF FOUND THEN

			FOR CarteraGeneral IN

				select negasoc::varchar as negocio,
				       nit::varchar as cedula,
				       ''::varchar as nombre_cliente,
				       num_doc_fen::varchar as cuota,
				       documento::varchar,
				       fecha_vencimiento::date,
				       (FechaCortePeriodo::date-fecha_vencimiento)::numeric AS dias_vencidos,
				       ''::varchar as vencimiento_mayor,
				       '-'::varchar as status,
				       valor_saldo::numeric,
				       0::numeric as debido_cobrar,
				       0::numeric as interes_mora,
				       0::numeric as gasto_cobranza
				from con.foto_cartera f
				where negasoc = NegocioAvales.cod_neg
				and periodo_lote = PeriodoAsignacion
				and reg_status = ''
				--and descripcion != 'CXC AVAL'
				and substring(documento,1,2) not in ('CP','FF','DF')
				and valor_saldo > 0
				and replace(substring(f.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoAsignacion
				order by num_doc_fen::numeric,creation_date

			LOOP

				SELECT INTO ClienteRec nomcli FROM cliente WHERE nit = CarteraGeneral.cedula;
				CarteraGeneral.nombre_cliente = ClienteRec.nomcli;

				--SELECT INTO FacturaActual valor_saldo FROM con.factura WHERE documento = CarteraGeneral.documento;
								--esto sirve descomentalo y fuera.
				IF(substring(CarteraGeneral.documento,1,2) IN ('FG','CG'))THEN

					SELECT INTO FacturaActual valor_saldo FROM con.factura WHERE valor_saldo >0 AND reg_status='' and dstrct='FINV'
					and documento = 'FG'||substring(CarteraGeneral.documento,3) OR  documento = 'CG'||substring(CarteraGeneral.documento,3);

				ELSE
					SELECT INTO FacturaActual valor_saldo FROM con.factura WHERE valor_saldo >0 AND reg_status='' and dstrct='FINV'  and documento = CarteraGeneral.documento;
				END IF;

				raise notice 'FacturaActual PASO%',FacturaActual;
				if FacturaActual is not null then

					--lo viejo antes del cambio.
					CarteraGeneral.debido_cobrar = FacturaActual.valor_saldo;
					BolsaSaldo = FacturaActual.valor_saldo;

				else
					CarteraGeneral.debido_cobrar = 0;
					BolsaSaldo = 0;
				end if;

				--cambio hasta aqui...

				CarteraGeneral.vencimiento_mayor = VencimientoMayor;

			        ------- Sancion
				_SumIxM = 0;
				_SumGaC = 0;

				FOR _sanciofa IN (SELECT * FROM con.factura_detalle where documento = CarteraGeneral.documento) LOOP --NegocioAvales.cod_neg

					VerifyDetails = 'N';
					Diferencia = BolsaSaldo - _sanciofa.valor_unitario; --valor_unitario

					if ( Diferencia <= 0 and BolsaSaldo > 0) then

						VlDetFactura = BolsaSaldo;
						_Base = VlDetFactura;

						BolsaSaldo = BolsaSaldo - _sanciofa.valor_unitario; --valor_unitario
						VerifyDetails = 'S';

					elsif ( Diferencia > 0 and BolsaSaldo > 0 ) then

						VlDetFactura = _sanciofa.valor_unitario;
						_Base = VlDetFactura;

						BolsaSaldo = BolsaSaldo - _sanciofa.valor_unitario; --valor_unitario
						VerifyDetails = 'S';

					end if;

					raise notice 'VerifyDetails:, %', VerifyDetails;
					if ( VerifyDetails = 'S' ) then

						-- Sancion
						--Conceptos
						SELECT INTO _ConceptRec * FROM conceptos_recaudo WHERE prefijo = _sanciofa.descripcion AND (now()::date - CarteraGeneral.fecha_vencimiento ) BETWEEN dias_rango_ini AND dias_rango_fin and id_unidad_negocio = unidadnegocio;

						FOR _Sancion IN

							SELECT * FROM sanciones_condonaciones
							WHERE id_tipo_acto = 1 AND id_conceptos_recaudo = _ConceptRec.id
							AND (now()::date - CarteraGeneral.fecha_vencimiento )  BETWEEN dias_rango_ini AND dias_rango_fin
							AND periodo = periodoasignacion and id_unidad_negocio = unidadnegocio

						LOOP

							IF ( _Sancion.categoria = 'IXM' ) THEN

								if (  now()::date > CarteraGeneral.fecha_vencimiento::date ) then --if ( now()::date > CarteraxCuota.fecha_vencimiento::date ) then

									select into _Tasa tasa_usura/100 from convenios where id_convenio = (select id_convenio from negocios where cod_neg=negocioref);

									_IxM = ROUND( _Base *(_Tasa/30) * (now()::date - CarteraGeneral.fecha_vencimiento)::numeric );
									_SumIxM = _SumIxM + _IxM;
								end if;

							END IF;

							IF ( _Sancion.categoria = 'GAC' ) THEN

								if ( now()::date  > CarteraGeneral.fecha_vencimiento::date ) then --if ( now()::date > CarteraxCuota.fecha_vencimiento::date ) then

									_GaC = ROUND(( _Base * _Sancion.porcentaje::numeric)/100);
									_SumGaC = _SumGaC + _GaC;

								end if;

							END IF;

						END LOOP;
					end if;

				END LOOP;

				CarteraGeneral.interes_mora= _SumIxM;
				CarteraGeneral.gasto_cobranza= _SumGaC;
				--_Sancion

				RETURN NEXT CarteraGeneral;

			END LOOP;

		END IF;

		--NEGOCIO DE SEGURO
		---------------------------------------------------------------------------------------------------
		FOR NegocioSegurus IN SELECT cod_neg from negocios where negocio_rel_seguro = NegocioRef LOOP

			--RAISE NOTICE 'Negocios De Seguro: %, PeriodoAsignacion: %, FechaCortePeriodo: %', NegocioSegurus.cod_neg, PeriodoAsignacion, FechaCortePeriodo;
			FOR CarteraGeneral IN

				select negasoc::varchar as negocio,
				       nit::varchar as cedula,
				       ''::varchar as nombre_cliente,
				       num_doc_fen::varchar as cuota,
				       documento::varchar,
				       fecha_vencimiento::date,
				       (FechaCortePeriodo::date-fecha_vencimiento)::numeric AS dias_vencidos,
				       ''::varchar as vencimiento_mayor,
				       '-'::varchar as status,
				       valor_saldo::numeric,
				       0::numeric as debido_cobrar,
				       0::numeric as interes_mora,
				       0::numeric as gasto_cobranza
				from con.foto_cartera fr
				where fr.negasoc = NegocioSegurus.cod_neg
				and fr.periodo_lote = PeriodoAsignacion
				and fr.reg_status = ''
				and substring(fr.documento,1,2) not in ('CP','FF','DF')
				and fr.valor_saldo > 0
				and replace(substring(fr.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoAsignacion
				order by fr.num_doc_fen::numeric,fr.creation_date

			LOOP

				SELECT INTO ClienteRec nomcli FROM cliente WHERE nit = CarteraGeneral.cedula;
				CarteraGeneral.nombre_cliente = ClienteRec.nomcli;

				--SELECT INTO FacturaActual valor_saldo FROM con.factura WHERE documento = CarteraGeneral.documento;
								--esto sirve descomentalo y fuera.
				IF(substring(CarteraGeneral.documento,1,2) IN ('FG','CG'))THEN

					SELECT INTO FacturaActual valor_saldo FROM con.factura WHERE valor_saldo >0 AND reg_status='' and dstrct='FINV'
					and documento = 'FG'||substring(CarteraGeneral.documento,3) OR  documento = 'CG'||substring(CarteraGeneral.documento,3);

				ELSE
					SELECT INTO FacturaActual valor_saldo FROM con.factura WHERE valor_saldo >0 AND reg_status='' and dstrct='FINV'  and documento = CarteraGeneral.documento;
				END IF;

				raise notice 'FacturaActual PASO%',FacturaActual;
				if FacturaActual is not null then

					--lo viejo antes del cambio.
					CarteraGeneral.debido_cobrar = FacturaActual.valor_saldo;
					BolsaSaldo = FacturaActual.valor_saldo;

				else
					CarteraGeneral.debido_cobrar = 0;
					BolsaSaldo = 0;
				end if;

				--cambio hasta aqui...

				CarteraGeneral.vencimiento_mayor = VencimientoMayor;

				_SumIxM = 0;
				_SumGaC = 0;

				FOR _sanciofa IN (SELECT * FROM con.factura_detalle where documento = CarteraGeneral.documento) LOOP

					VerifyDetails = 'N';
					Diferencia = BolsaSaldo - _sanciofa.valor_unitario; --valor_unitario

					if ( Diferencia <= 0 and BolsaSaldo > 0) then

						VlDetFactura = BolsaSaldo;
						_Base = VlDetFactura;

						BolsaSaldo = BolsaSaldo - _sanciofa.valor_unitario; --valor_unitario
						VerifyDetails = 'S';

					elsif ( Diferencia > 0 and BolsaSaldo > 0 ) then

						VlDetFactura = _sanciofa.valor_unitario;
						_Base = VlDetFactura;

						BolsaSaldo = BolsaSaldo - _sanciofa.valor_unitario; --valor_unitario
						VerifyDetails = 'S';

					end if;

					if ( VerifyDetails = 'S' ) then
						-- Sancion
						--Conceptos
						SELECT INTO _ConceptRec * FROM conceptos_recaudo WHERE prefijo = _sanciofa.descripcion AND (now()::date - CarteraGeneral.fecha_vencimiento ) BETWEEN dias_rango_ini AND dias_rango_fin and id_unidad_negocio = unidadnegocio;

						FOR _Sancion IN

							SELECT * FROM sanciones_condonaciones
							WHERE id_tipo_acto = 1 AND id_conceptos_recaudo = _ConceptRec.id
							AND (now()::date - CarteraGeneral.fecha_vencimiento )  BETWEEN dias_rango_ini AND dias_rango_fin
							AND periodo = periodoasignacion and id_unidad_negocio = unidadnegocio

						LOOP

							IF ( _Sancion.categoria = 'IXM' ) THEN

								if (  now()::date> CarteraGeneral.fecha_vencimiento::date ) then --if ( now()::date > CarteraxCuota.fecha_vencimiento::date ) then

									select into _Tasa tasa_usura/100 from convenios where id_convenio = (select id_convenio from negocios where cod_neg=negocioref);

									_IxM = ROUND( _Base *(_Tasa/30) * (now()::date - CarteraGeneral.fecha_vencimiento)::numeric );
									_SumIxM = _SumIxM + _IxM;
								end if;

							END IF;

							IF ( _Sancion.categoria = 'GAC' ) THEN

								if ( now()::date  > CarteraGeneral.fecha_vencimiento::date ) then --if ( now()::date > CarteraxCuota.fecha_vencimiento::date ) then

									_GaC = ROUND(( _Base * _Sancion.porcentaje::numeric)/100);
									_SumGaC = _SumGaC + _GaC;

								end if;

							END IF;

						END LOOP;
					end if;

				END LOOP;

				CarteraGeneral.interes_mora= _SumIxM;
				CarteraGeneral.gasto_cobranza= _SumGaC;
				--_Sancion

				RETURN NEXT CarteraGeneral;

			END LOOP;

		END LOOP;

		--NEGOCIO DE GPS
		---------------------------------------------------------------------------------------------------
		SELECT INTO _NegocioGps cod_neg from negocios where negocio_rel_gps = NegocioRef;

		FOR CarteraGeneral IN

			select
				negasoc::varchar as negocio,
				nit::varchar as cedula,
			        ''::varchar as nombre_cliente,
				num_doc_fen::varchar as cuota,
			        documento::varchar,
			        fecha_vencimiento::date,
			        (FechaCortePeriodo::date-fecha_vencimiento)::numeric AS dias_vencidos,
			        ''::varchar as vencimiento_mayor,
			        '-'::varchar as status,
			        valor_saldo::numeric,
			        0::numeric as debido_cobrar,
			        0::numeric as interes_mora,
			        0::numeric as gasto_cobranza
			from con.foto_cartera f
			where negasoc = _NegocioGps.cod_neg
			and periodo_lote = PeriodoAsignacion
			and reg_status = ''
			--and descripcion != 'CXC AVAL'
			and substring(documento,1,2) not in ('CP','FF','DF')
			and valor_saldo > 0
			and replace(substring(f.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoAsignacion
			order by negasoc --num_doc_fen::numeric,creation_date

		LOOP

			SELECT INTO ClienteRec nomcli FROM cliente WHERE nit = CarteraGeneral.cedula;
			/*CarteraGeneral.nombre_cliente = ClienteRec.nomcli;
			CarteraGeneral.direccion = ClienteRec.direccion;
			CarteraGeneral.ciudad = ClienteRec.ciudad;
			CarteraGeneral.telefono = ClienteRec.telefono;
			CarteraGeneral.telcontacto = ClienteRec.telcontacto;*/



			--SELECT INTO FacturaActual valor_saldo FROM con.factura WHERE documento = CarteraGeneral.documento;
			--esto sirve descomentalo y fuera.
			IF(substring(CarteraGeneral.documento,1,2) IN ('FG','CG'))THEN

				SELECT INTO FacturaActual valor_saldo FROM con.factura WHERE valor_saldo >0 AND reg_status='' and dstrct='FINV'
				and documento = 'FG'||substring(CarteraGeneral.documento,3) OR  documento = 'CG'||substring(CarteraGeneral.documento,3);

			ELSE
				SELECT INTO FacturaActual valor_saldo FROM con.factura WHERE valor_saldo >0 AND reg_status='' and dstrct='FINV'  and documento = CarteraGeneral.documento;
			END IF;

			raise notice 'FacturaActual PASO%',FacturaActual;
			if FacturaActual is not null then

				--lo viejo antes del cambio.
				CarteraGeneral.debido_cobrar = FacturaActual.valor_saldo;
				BolsaSaldo = FacturaActual.valor_saldo;

			else
				CarteraGeneral.debido_cobrar = 0;
				BolsaSaldo = 0;
			end if;

			--cambio hasta aqui...

			CarteraGeneral.vencimiento_mayor = VencimientoMayor;

			_SumIxM = 0;
			_SumGaC = 0;

			FOR _sanciofa IN (SELECT * FROM con.factura_detalle where documento = CarteraGeneral.documento) LOOP

				VerifyDetails = 'N';
				Diferencia = BolsaSaldo - _sanciofa.valor_unitario; --valor_unitario

				if ( Diferencia <= 0 and BolsaSaldo > 0) then

					VlDetFactura = BolsaSaldo;
					_Base = VlDetFactura;

					BolsaSaldo = BolsaSaldo - _sanciofa.valor_unitario; --valor_unitario
					VerifyDetails = 'S';

				elsif ( Diferencia > 0 and BolsaSaldo > 0 ) then

					VlDetFactura = _sanciofa.valor_unitario;
					_Base = VlDetFactura;

					BolsaSaldo = BolsaSaldo - _sanciofa.valor_unitario; --valor_unitario
					VerifyDetails = 'S';

				end if;

				if ( VerifyDetails = 'S' ) then
					-- Sancion
					--Conceptos
					SELECT INTO _ConceptRec * FROM conceptos_recaudo WHERE prefijo = _sanciofa.descripcion AND (now()::date - CarteraGeneral.fecha_vencimiento ) BETWEEN dias_rango_ini AND dias_rango_fin and id_unidad_negocio = unidadnegocio;

					FOR _Sancion IN

						SELECT * FROM sanciones_condonaciones
						WHERE id_tipo_acto = 1 AND id_conceptos_recaudo = _ConceptRec.id
						AND (now()::date - CarteraGeneral.fecha_vencimiento )  BETWEEN dias_rango_ini AND dias_rango_fin
						AND periodo = periodoasignacion and id_unidad_negocio = unidadnegocio

					LOOP

						IF ( _Sancion.categoria = 'IXM' ) THEN

							if (  now()::date> CarteraGeneral.fecha_vencimiento::date ) then --if ( now()::date > CarteraxCuota.fecha_vencimiento::date ) then

								select into _Tasa tasa_usura/100 from convenios where id_convenio = (select id_convenio from negocios where cod_neg=negocioref);

								_IxM = ROUND( _Base *(_Tasa/30) * (now()::date - CarteraGeneral.fecha_vencimiento)::numeric );
								_SumIxM = _SumIxM + _IxM;
							end if;

						END IF;

						IF ( _Sancion.categoria = 'GAC' ) THEN

							if ( now()::date  > CarteraGeneral.fecha_vencimiento::date ) then --if ( now()::date > CarteraxCuota.fecha_vencimiento::date ) then

								_GaC = ROUND(( _Base * _Sancion.porcentaje::numeric)/100);
								_SumGaC = _SumGaC + _GaC;

							end if;

						END IF;

					END LOOP;
				end if;

			END LOOP;

			CarteraGeneral.interes_mora= _SumIxM;
			CarteraGeneral.gasto_cobranza= _SumGaC;
			--_Sancion

			RETURN NEXT CarteraGeneral;

		END LOOP;

	END;

	$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION dv_detallecarteraglobal(numeric, character varying, character varying)
  OWNER TO postgres;
