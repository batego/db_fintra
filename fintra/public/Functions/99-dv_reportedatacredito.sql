-- Function: dv_reportedatacredito(date, numeric, character varying, numeric, numeric, character varying)

-- DROP FUNCTION dv_reportedatacredito(date, numeric, character varying, numeric, numeric, character varying);

CREATE OR REPLACE FUNCTION dv_reportedatacredito(fecha_hoy date, periodo_corriente numeric, unidadnegocio character varying, rangoini numeric, rangofin numeric, accion character varying)
  RETURNS SETOF record AS
$BODY$
  --$Id: foo.sql,v 1.6 2008/12/23 00:06:52 gpavlov Exp $
DECLARE

	CarteraGeneral record;
	RecSolicitud record;
	RecLiquidador record;
	RecNegocios record;
	RecSaldos record;
	RecSaldoMora record;
	FchLastPay record;
	FchPagoLimit record;
	FchPagoLimit2 record;
	NovedadCredito record;
	NegociOnHistory record;

	MaxVel integer := 0;

	_TotalCuotasCanceladas numeric;
	_TotalCuotasEnMora numeric;
	_TotalCuotasVigentes numeric;
	_TotalCuotasxVencer numeric;

	_TramoAnterior numeric;
	_TramoLessTwoMonth numeric;

	PermiteGenerar varchar;

	SQL TEXT;
	SQLSOL TEXT;

	miHoy date;

BEGIN

	miHoy = now()::date;

	if ( substring(periodo_corriente,5) = '01' ) then
		_TramoAnterior = substring(periodo_corriente,1,4)::numeric-1||'12';
		_TramoLessTwoMonth = substring(periodo_corriente,1,4)::numeric-1||'11';
	else
		_TramoAnterior = periodo_corriente::numeric - 1;
		_TramoLessTwoMonth = periodo_corriente::numeric - 2;

		if ( _TramoLessTwoMonth = 201600 ) then
			_TramoLessTwoMonth = 201512;
		end if;


		if ( _TramoLessTwoMonth = 201700 ) then
			_TramoLessTwoMonth = 201612;
		end if;

		if ( _TramoLessTwoMonth = 201800 ) then
			_TramoLessTwoMonth = 201712;
		end if;
	end if;

	select into MaxVel min(id)
	from con.foto_cartera
	where periodo_lote = periodo_corriente
		and reg_status = ''
		and dstrct = 'FINV'
		and tipo_documento in ('FAC','NDC')
		and substring(documento,1,2) not in ('CP','FF','DF');

	--La unidadnegocio para datacredito siempre serán los que se llevan al proceso DATACREDITO.
	IF ( (Accion = 'Generar' OR Accion = 'Visualizar') and ( unidadnegocio in (16,17,20,21,22) ) ) THEN

		SQL = 'SELECT
			fac.nit,
			''''::varchar as tipo_identificacion,
			''''::varchar as identificacion,
			fac.negasoc::varchar as negocio,
			''''::varchar as nombre,
			''''::varchar as situacion_titular,
			''''::varchar as fecha_apertura,
			''''::varchar as fecha_vencimiento,
			'''||fecha_hoy||'''::date as fecha_corte_proceso,

			(SELECT max('''||fecha_hoy||'''-(fecha_vencimiento))
			 FROM con.foto_cartera fra
			 WHERE fra.dstrct = ''FINV''
				  AND fra.reg_status = ''''
				  AND fra.negasoc = fac.negasoc
				  AND fra.tipo_documento in (''FAC'',''NDC'')
				  AND fra.periodo_lote = '||periodo_corriente|| '
				  AND fra.valor_saldo > 0
				  AND substring(fra.documento,1,2) not in (''CP'',''FF'',''DF'')
				  AND replace(substring(fra.fecha_vencimiento,1,7),''-'','''') <= '||_TramoAnterior||'
				  AND id >= '||MaxVel||'
			 GROUP BY negasoc)::numeric as dias_mora,

			 ''''::varchar as novedad,

			(SELECT min('''||fecha_hoy||'''-(fecha_vencimiento))
			 FROM con.foto_cartera fra
			 WHERE fra.dstrct = ''FINV''
				  AND fra.reg_status = ''''
				  AND fra.negasoc = fac.negasoc
				  AND fra.tipo_documento in (''FAC'',''NDC'')
				  AND fra.periodo_lote = '||periodo_corriente||'
				  AND substring(fra.documento,1,2) not in (''CP'',''FF'',''DF'')
				  AND replace(substring(fra.fecha_vencimiento,1,7),''-'','''') <= '||_TramoAnterior||'
				  AND id >= '||MaxVel||'
			 GROUP BY negasoc)::numeric as min_dias_mora,

			''''::varchar as desembolso,
			0::numeric as saldo_deuda,
			0::numeric as saldo_en_mora,
			''''::varchar as cuota_mensual,
			''''::varchar as numero_cuotas,
			0::numeric as cuotas_canceladas,
			0::numeric as cuotas_en_mora,
			''0099-01-01''::date as fecha_limite_pago,
			''0099-01-01''::date as ultimo_pago,
			nomciu::varchar as ciudad_radicacion,
			(cdne.cod_dep||cdne.cod_mun)::varchar as cod_dane_radicacion,
			''''::varchar as ciudad_residencia,
			''''::varchar as cod_dane_residencia,
			''''::varchar as departamento_residencia,
			''''::varchar as direccion_residencia,
			''''::varchar as telefono_residencia,
			''''::varchar as ciudad_laboral,
			''''::varchar as cod_dane_laboral,
			''''::varchar as departamento_laboral ,
			''''::varchar as direccion_laboral,
			''''::varchar as telefono_laboral,
			''''::varchar as ciudad_correspondencia,
			''''::varchar as cod_dane_correspondencia,
			''''::varchar as direccion_correspondencia,
			''''::varchar as correo_electronico,
			''''::varchar as celular_solicitante,
			''''::varchar as tipo
		FROM con.foto_cartera as fac
		INNER JOIN cliente as cli ON cli.codcli = fac.codcli
		INNER JOIN ciudad as ci ON ci.codciu = fac.agencia_cobro
		INNER JOIN codigos_ciudad_dane as cdne ON cdne.nom_mun = ci.nomciu
		WHERE fac.id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio in (select id from unidad_negocio where id = '||UnidadNegocio||'))
		    and fac.nit= ''19067475''
		    AND fac.reg_status = ''''
		    and fac.id >= '||MaxVel||'
		    AND fac.dstrct = ''FINV''
		    AND fac.tipo_documento in (''FAC'',''NDC'')
		    AND fac.agencia_cobro in (''BQ'',''OP'')
		    AND fac.periodo_lote = '||periodo_corriente||'
		    AND substring(documento,1,2) not in (''CP'',''FF'',''DF'')
		    AND	(SELECT max('''||fecha_hoy||'''-(fecha_vencimiento))
			 FROM con.foto_cartera fra
			 WHERE fra.dstrct = ''FINV''
				  AND fra.reg_status = ''''
				  AND fra.negasoc = fac.negasoc
				  AND fra.tipo_documento in (''FAC'',''NDC'')
				  AND fra.periodo_lote = '||periodo_corriente||'
				  AND substring(fra.documento,1,2) not in (''CP'',''FF'',''DF'')
				  AND id >= '||MaxVel||'
			 GROUP BY negasoc) BETWEEN '||RangoIni||' AND '||RangoFin||'';

		if ( Accion = 'Generar' ) then
		    SQL := SQL || ' AND fac.negasoc in (select negocio_reportado from cr_obligaciones_areportar_criesgo where id_unidad_negocio = '||UnidadNegocio||' and reportado = ''N'' and reg_status = '''' and periodo_lote = '||_TramoAnterior||')';
		end if;

		SQL := SQL || '
		    AND (SELECT count(0) from negocios where cod_neg = fac.negasoc and negocio_rel = '''') > 0
		    AND (SELECT count(0) FROM tem.seguros_vehiculos WHERE ciclo_fecha = ''2014-07-29'' AND negocio_seguro = fac.negasoc) = 0
		    AND replace(substring(fac.fecha_vencimiento,1,7),''-'','''') <= '||_TramoAnterior||'
		    --AND fac.negasoc not in (''FA02017'',''NG20437'',''FA05895'',''FA05989'',''FA07963'') --CLIENTE CON CUOTA CON VENCIMIENTO ERRADO Y NEGOCIO JORGE SANDOVAL
		    AND fac.nit != ''8901009858'' --SE EXCLUYE A LOS FENALCOS - pq GENERA ERRORES!
		    --AND fac.negasoc = ''CD00048'' --in (select negocio_reportado from cr_obligaciones_areportar_criesgo where periodo_lote = ''201611'' and id_unidad_negocio = 21)
		GROUP BY fac.nit,negasoc, nomcli, cli.nit, nomciu, ultimo_pago, cod_mun, cod_dep
		ORDER BY nomcli';

		raise notice 'SQL PPAL: %',SQL;
		FOR CarteraGeneral IN EXECUTE SQL LOOP

			--FECHA ULTIMO PAGOS
			/*
			select into FchLastPay max(i.fecha_consignacion) as fecha_consignacion
			from con.ingreso_detalle id, con.ingreso i
			where id.num_ingreso = i.num_ingreso
			and id.dstrct = i.dstrct
			and id.tipo_documento = i.tipo_documento
			and id.dstrct = 'FINV'
			and id.tipo_documento in ('ING','ICA')
			and i.reg_status = ''
			and id.documento in (SELECT documento from con.foto_cartera where negasoc = CarteraGeneral.negocio and tipo_documento in ('FAC','NDC') and reg_status = '' and substring(documento,1,2) not in ('CP','FF','DF') )
			and i.fecha_consignacion <= fecha_hoy;

			IF FOUND THEN
				CarteraGeneral.ultimo_pago = COALESCE(FchLastPay.fecha_consignacion::date,'0099-01-01'::date);
			ELSE
				CarteraGeneral.ultimo_pago = '0099-01-01';
			END IF;	*/

			SELECT into FchLastPay max(i.fecha_consignacion) as fecha_consignacion
			FROM con.ingreso_detalle id
			INNER JOIN con.ingreso i ON (id.num_ingreso = i.num_ingreso and id.dstrct = i.dstrct and i.nitcli=id.nitcli )
			WHERE id.dstrct = 'FINV'
				and id.tipo_documento in ('ING','ICA')
				and i.reg_status = ''
				and i.branch_code != ''
				and i.bank_account_no != ''
				and i.nitcli= CarteraGeneral.nit
				and id.reg_status = ''
				and i.fecha_consignacion <= fecha_hoy
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
						     );
			IF FOUND THEN
				CarteraGeneral.ultimo_pago = COALESCE(FchLastPay.fecha_consignacion::date,'0099-01-01'::date);
			ELSE
				CarteraGeneral.ultimo_pago = '0099-01-01';
			END IF;

			raise notice 'Negocio: %',CarteraGeneral.negocio;

			SQLSOL='SELECT DISTINCT ON (sp.numero_solicitud, sp.identificacion)
					sp.identificacion,
					sp.nombre,
					sp.tipo_id,
					sp.ciudad,
					sp.departamento,
					sp.direccion,
					sp.telefono,
					sp.direccion as direccion_correspondencia,
					sp.email,
					sp.celular,
					sp.tipo,
					sl.ciudad as ciudad_laboral,
					sl.departamento as departamento_laboral,
					sl.direccion as direccion_laboral,
					sl.telefono as telefono_laboral
				FROM solicitud_persona as sp
				LEFT JOIN solicitud_laboral as sl on (sp.dstrct=sl.dstrct and sp.numero_solicitud=sl.numero_solicitud and sp.tipo=sl.tipo)
				WHERE sp.numero_solicitud = (select numero_solicitud from solicitud_aval where cod_neg = '''||CarteraGeneral.negocio||''')';
			        --AND sp.tipo IN (''S'',''C'') --Microcredito.
			        --AND sp.tipo IN (''S'',''E'',''C'') --Consumo.
				if ( unidadnegocio = 16 ) then
				    SQLSOL := SQLSOL || ' AND sp.tipo IN (''S'',''C'')';
				elsif ( unidadnegocio in (17,20) ) then
				    SQLSOL := SQLSOL || ' AND sp.tipo IN (''S'',''E'',''C'')';
				end if;

			raise notice 'SQLSOL: %',SQLSOL;

			FOR RecSolicitud IN EXECUTE SQLSOL LOOP

				PermiteGenerar = 'N';
				CarteraGeneral.dias_mora = (case when CarteraGeneral.dias_mora > 0 then CarteraGeneral.dias_mora else 0 end);

				--LIQUIDADOR
				SELECT INTO RecLiquidador max(valor) as cta_mensual, count(0) as total_cuotas FROM documentos_neg_aceptado WHERE cod_neg = CarteraGeneral.negocio and item != '0';
				CarteraGeneral.cuota_mensual = RecLiquidador.cta_mensual;
				CarteraGeneral.numero_cuotas = RecLiquidador.total_cuotas;

				--NEGOCIO
				SELECT INTO RecNegocios cod_neg, id_convenio, fecha_ap::date, vr_desembolso from negocios WHERE cod_neg = CarteraGeneral.negocio;
				CarteraGeneral.fecha_apertura = RecNegocios.fecha_ap;
				CarteraGeneral.fecha_vencimiento = (RecNegocios.fecha_ap + ( ('' || CarteraGeneral.numero_cuotas || 'month')::interval));
				CarteraGeneral.desembolso = RecNegocios.vr_desembolso;

				--TOTAL CUOTAS
				--SELECT INTO _TotalCuotasCanceladas count(0) as CtasCanceladas from con.foto_cartera where reg_status = '' and dstrct = 'FINV' and tipo_documento in ('FAC','NDC') and negasoc = CarteraGeneral.negocio and id_convenio = RecNegocios.id_convenio and valor_saldo = 0 and periodo_lote = periodo_corriente::numeric and substring(documento,1,2) not in ('CP','FF','DF');
				SELECT INTO _TotalCuotasEnMora count(0) as CtasEnMora from con.foto_cartera where reg_status = '' and dstrct = 'FINV' and tipo_documento in ('FAC','NDC') and id >= MaxVel and negasoc = CarteraGeneral.negocio and id_convenio = RecNegocios.id_convenio and valor_saldo > 0 and periodo_lote = periodo_corriente::numeric and fecha_vencimiento <= fecha_hoy and substring(documento,1,2) not in ('CP','FF','DF') and descripcion not in ('CXC AVAL','CXC_INTERES_FA','CXC_CAT_MC','CXC_INTERES_MC');
				SELECT INTO _TotalCuotasVigentes count(0) as CtasVigentes from con.foto_cartera where reg_status = '' and dstrct = 'FINV' and tipo_documento in ('FAC','NDC') and id >= MaxVel and negasoc = CarteraGeneral.negocio and id_convenio = RecNegocios.id_convenio and valor_saldo > 0 and periodo_lote = periodo_corriente::numeric and substring(documento,1,2) not in ('CP','FF','DF') and descripcion not in ('CXC AVAL','CXC_INTERES_FA','CXC_CAT_MC','CXC_INTERES_MC');

				SELECT INTO _TotalCuotasxVencer count(0) as CtasxVencer from con.foto_cartera where reg_status = '' and dstrct = 'FINV' and tipo_documento in ('FAC','NDC') and id >= MaxVel and negasoc = CarteraGeneral.negocio and id_convenio = RecNegocios.id_convenio and valor_saldo > 0 and periodo_lote = periodo_corriente::numeric and fecha_vencimiento > fecha_hoy and substring(documento,1,2) not in ('CP','FF','DF') and descripcion not in ('CXC AVAL','CXC_INTERES_FA','CXC_CAT_MC','CXC_INTERES_MC');
				CarteraGeneral.min_dias_mora = _TotalCuotasxVencer;


				--SALDO MORA
				SELECT INTO RecSaldoMora COALESCE(sum(fac.valor_saldo),0) as saldo_factura, COALESCE(min(fecha_vencimiento),'0099-01-01') as fecha_limitepago
				FROM con.foto_cartera as fac
				WHERE fac.id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio in (select id from unidad_negocio where id = UnidadNegocio))
				    AND fac.reg_status = ''
				    AND fac.dstrct = 'FINV'
				    AND fac.tipo_documento in ('FAC','NDC')
				    AND fac.valor_saldo > 0
				    AND fac.agencia_cobro = 'BQ'
				    AND fac.periodo_lote = periodo_corriente
				    AND fac.negasoc = CarteraGeneral.negocio
				    AND substring(documento,1,2) not in ('CP','FF','DF')
				    AND fac.fecha_vencimiento::date <= fecha_hoy
				    AND id >= MaxVel;

				IF ( RecSaldoMora.saldo_factura != 0 ) THEN

					CarteraGeneral.saldo_en_mora = RecSaldoMora.saldo_factura;
					CarteraGeneral.fecha_limite_pago = RecSaldoMora.fecha_limitepago;
				ELSE

					SELECT INTO FchPagoLimit max(fecha_vencimiento) as fecha_limitepago
					FROM con.foto_cartera as fac
					WHERE fac.reg_status = ''
					    AND fac.dstrct = 'FINV'
					    AND fac.tipo_documento in ('FAC','NDC')
					    --AND fac.valor_saldo > 0 --DUDAS
					    AND fac.agencia_cobro = 'BQ'
					    AND fac.periodo_lote = periodo_corriente
					    AND fac.negasoc = CarteraGeneral.negocio
					    AND substring(documento,1,2) not in ('CP','FF','DF')
					    AND replace(substring(fac.fecha_vencimiento,1,7),'-','')::numeric = periodo_corriente::numeric
					    AND id >= MaxVel;

					IF (FchPagoLimit.fecha_limitepago is null ) THEN

						SELECT INTO FchPagoLimit2 min(fecha_vencimiento) as limitepago
						FROM con.foto_cartera as fac
						WHERE fac.reg_status = ''
						    AND fac.dstrct = 'FINV'
						    AND fac.tipo_documento in ('FAC','NDC')
						    AND fac.valor_saldo > 0
						    AND fac.agencia_cobro = 'BQ'
						    AND fac.periodo_lote = periodo_corriente
						    AND fac.negasoc = CarteraGeneral.negocio
						    AND substring(documento,1,2) not in ('CP','FF','DF')
						    AND id >= MaxVel;
						    --AND replace(substring(fac.fecha_vencimiento,1,7),'-','')::numeric <= periodo_corriente::numeric+1;

						CarteraGeneral.fecha_limite_pago = FchPagoLimit2.limitepago;
					ELSE
						CarteraGeneral.fecha_limite_pago = FchPagoLimit.fecha_limitepago;
					END IF;

				END IF;

				raise notice 'dias_mora es: %',CarteraGeneral.dias_mora;

				-----NOVEDADES------
				SELECT INTO NovedadCredito * from cr_novedad_mora where id_central_riesgo = 2 and id_unidad_negocio = unidadnegocio and CarteraGeneral.dias_mora between dias_rango_ini and dias_rango_fin;
				IF FOUND THEN
					raise notice 'NovedadCredito es: %',NovedadCredito.id;

					select into NegociOnHistory *
					,(select peso_novedad from cr_novedad_mora where id_central_riesgo = 2 and id_unidad_negocio = unidadnegocio and cod_novedad_mora = cr_historico_reportes.novedad) as peso_novedad
					from cr_historico_reportes
					where negocio = CarteraGeneral.negocio
					      --and identificacion = RecSolicitud.identificacion
					      and reg_status = ''
					      and periodo_lote = _TramoLessTwoMonth;

					IF FOUND THEN --Fue reportado anteriormente

						raise notice 'Reportado Anteriormente';

						--VALOR SALDO DEUDA
						SELECT INTO RecSaldos case when (sum(valor_saldo) <= 10000) then 0 else sum(valor_saldo) end as SaldoDeuda --sum(valor_saldo) as SaldoDeuda
						FROM con.foto_cartera cf
						WHERE cf.negasoc = CarteraGeneral.negocio
						    AND cf.reg_status = ''
						    AND cf.dstrct = 'FINV'
						    AND cf.tipo_documento in ('FAC','NDC')
						    AND cf.valor_saldo > 0
						    AND cf.agencia_cobro = 'BQ'
						    AND cf.periodo_lote = periodo_corriente
						    --AND replace(substring(cf.fecha_vencimiento,1,7),'-','') <= _TramoAnterior
						    AND substring(documento,1,2) not in ('CP','FF','DF')
						    AND id >= MaxVel;

						    raise notice 'SaldoDeuda1 es: %',RecSaldos.SaldoDeuda;

						if ( RecSaldos.SaldoDeuda > 0 ) then
							raise notice 'Incognita1';
							PermiteGenerar = 'S';

							raise notice 'NovedadActual es: %; NovedadAnterior es: %',NovedadCredito.peso_novedad,NegociOnHistory.peso_novedad;

							if ( NovedadCredito.peso_novedad <= NegociOnHistory.peso_novedad ) then

								raise notice 'PASA1!';
								CarteraGeneral.novedad = NovedadCredito.cod_novedad_mora;

							elsif ( (NovedadCredito.peso_novedad - NegociOnHistory.peso_novedad) = 1 ) then

								raise notice 'PASA2!';
								CarteraGeneral.novedad = NovedadCredito.cod_novedad_mora;

							elsif ( (NovedadCredito.peso_novedad - NegociOnHistory.peso_novedad) > 1 ) then

								raise notice 'PASA3!';
								CarteraGeneral.novedad = NovedadCredito.cod_novedad_mora;

								if ( Accion = 'Generar' ) then
									insert into cr_negocios_errores (negocio,identificacion,periodo_lote,creation_date) values (CarteraGeneral.negocio,RecSolicitud.identificacion,_TramoAnterior,now());
								end if;

							end if;

							--------------------------------------------------------------------------------------------

							if ( CarteraGeneral.dias_mora <= 30 ) then --pasa de igual cero a menor o igual 30

								--CarteraGeneral.saldo_deuda = 0;
								CarteraGeneral.saldo_en_mora = 0;
								CarteraGeneral.cuotas_en_mora = 0;
								CarteraGeneral.saldo_deuda = RecSaldos.SaldoDeuda;

							elsif ( CarteraGeneral.dias_mora > 30 ) then

								--**--
								CarteraGeneral.cuotas_en_mora = _TotalCuotasEnMora;

								--**--
								--VALOR SALDO DEUDA
								CarteraGeneral.saldo_deuda = RecSaldos.SaldoDeuda;

							end if;

							CarteraGeneral.cuotas_canceladas = RecLiquidador.total_cuotas - _TotalCuotasVigentes;


						else
							raise notice 'Incognita2: %', RecSaldos.SaldoDeuda;
							--DEBO CONSIDERAR SI TIENE SALDO EN MORA...
							--CarteraGeneral.novedad = NovedadCredito.cod_novedad_mora;
							PermiteGenerar = 'S';

							if ( _TotalCuotasxVencer > 0) then

								CarteraGeneral.novedad = '01';
								CarteraGeneral.cuotas_canceladas = RecLiquidador.total_cuotas - _TotalCuotasVigentes;
							else
								CarteraGeneral.novedad = '05';
								CarteraGeneral.cuotas_canceladas = RecLiquidador.total_cuotas;

							end if;

							--CarteraGeneral.novedad = '05';
							--CarteraGeneral.cuotas_canceladas = RecLiquidador.total_cuotas;

							CarteraGeneral.cuotas_en_mora = 0;
							CarteraGeneral.saldo_en_mora = 0;
							--CarteraGeneral.min_dias_mora = 0;
							CarteraGeneral.dias_mora = 0;

						end if;

					ELSE --Se reporta por primera vez

						raise notice 'Reportado por primera vez';

						--VALOR SALDO DEUDA
						SELECT INTO RecSaldos case when (sum(valor_saldo) <= 10000) then 0 else sum(valor_saldo) end as SaldoDeuda --sum(valor_saldo) as SaldoDeuda
						FROM con.foto_cartera cf
						WHERE cf.negasoc = CarteraGeneral.negocio
						    AND cf.reg_status = ''
						    AND cf.dstrct = 'FINV'
						    AND cf.tipo_documento in ('FAC','NDC')
						    --AND cf.valor_saldo > 0
						    AND cf.agencia_cobro = 'BQ'
						    AND cf.periodo_lote = periodo_corriente
						    --AND replace(substring(cf.fecha_vencimiento,1,7),'-','') <= _TramoAnterior
						    AND substring(documento,1,2) not in ('CP','FF','DF')
						    AND id >= MaxVel;
						    raise notice 'SaldoDeuda2 es: %',RecSaldos.SaldoDeuda;

						if ( RecSaldos.SaldoDeuda > 0 ) then

							PermiteGenerar = 'S';

							CarteraGeneral.novedad = NovedadCredito.cod_novedad_mora;

							if ( CarteraGeneral.dias_mora <= 30 ) then --pasa de igual cero a menor o igual 30

								--CarteraGeneral.saldo_deuda = 0;
								CarteraGeneral.saldo_en_mora = 0;
								CarteraGeneral.cuotas_en_mora = 0;
								CarteraGeneral.saldo_deuda = RecSaldos.SaldoDeuda;

							elsif ( CarteraGeneral.dias_mora > 30 ) then

								--**--
								CarteraGeneral.cuotas_en_mora = _TotalCuotasEnMora;

								--**--
								--VALOR SALDO DEUDA
								CarteraGeneral.saldo_deuda = RecSaldos.SaldoDeuda;

							end if;

							CarteraGeneral.cuotas_canceladas = RecLiquidador.total_cuotas - _TotalCuotasVigentes;


						else
							PermiteGenerar = 'N';
						end if;
					END IF;

					Raise notice 'Este Negocio: %, Tiene estado: %',CarteraGeneral.negocio,PermiteGenerar;

					IF ( PermiteGenerar != 'N' ) THEN
						raise notice 'ENTRA! %', RecSolicitud.identificacion;

						CarteraGeneral.identificacion = RecSolicitud.identificacion;--****
						CarteraGeneral.nombre = (REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(RecSolicitud.nombre::varchar(40),'Ñ','N'),'ñ','n'),'á','a'),'é','e'),'í','i'),'ó','o'),'ú','u'),'Á','A'),'É','E'),'Í','I'),'Ó','O'),'Ú','U'),'Nº','No'));

						CarteraGeneral.tipo_identificacion = (CASE WHEN RecSolicitud.tipo_id = 'CED' THEN '1'  WHEN RecSolicitud.tipo_id = 'CEX' THEN '4' WHEN RecSolicitud.tipo_id = 'NIT' THEN '2' ELSE '0' END);
						CarteraGeneral.situacion_titular = '0'; --(CASE WHEN RecSolicitud.tipo_id = 'CED' then '0' ELSE '7' END);

						CarteraGeneral.ciudad_residencia = COALESCE((Select cast(nomciu as char(20))::varchar from ciudad Where codciu = RecSolicitud.ciudad limit 1),'BARRANQUILLA');
						CarteraGeneral.cod_dane_residencia = COALESCE((select cod_dep||cod_mun from codigos_ciudad_dane where nom_mun = (Select nomciu from ciudad Where codciu = RecSolicitud.ciudad) limit 1),'8001');
						CarteraGeneral.departamento_residencia = COALESCE(RecSolicitud.departamento,'ATL');
						CarteraGeneral.direccion_residencia = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(COALESCE(cast(RecSolicitud.direccion as char(59))::varchar,'N/A'),'Ñ','N'),'ñ','n'),'á','a'),'é','e'),'í','i'),'ó','o'),'ú','u'),'Á','A'),'É','E'),'Í','I'),'Ó','O'),'Ú','U'),'à','a'),'è','e'),'ì','i'),'ò','o'),'ù','u'),'À','A'),'È','E'),'Ì','I'),'Ò','O'),'Ù','U'),'Nº','No '),'º',''),'N°','No'),'°',''),'Nª','No'),'ª',''); --COALESCE(RecSolicitud.direccion,'N/A');
						CarteraGeneral.telefono_residencia = COALESCE(RecSolicitud.telefono,'0');

						CarteraGeneral.ciudad_laboral = COALESCE((Select cast(nomciu as char(20))::varchar from ciudad Where codciu = RecSolicitud.ciudad_laboral limit 1),'BARRANQUILLA');
						CarteraGeneral.cod_dane_laboral = COALESCE((select cod_dep||cod_mun from codigos_ciudad_dane where nom_mun = (Select nomciu from ciudad Where codciu = RecSolicitud.ciudad_laboral) limit 1),'8001');
						CarteraGeneral.departamento_laboral = (CASE WHEN (RecSolicitud.departamento_laboral is null or RecSolicitud.departamento_laboral = null or RecSolicitud.departamento_laboral = '') then 'ATL' ELSE RecSolicitud.departamento_laboral END); --COALESCE(RecSolicitud.departamento_laboral,'N/A');
						CarteraGeneral.direccion_laboral = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE((CASE WHEN (RecSolicitud.direccion_laboral is null or RecSolicitud.direccion_laboral = null or RecSolicitud.direccion_laboral = '') then CarteraGeneral.direccion_residencia ELSE cast(RecSolicitud.direccion_laboral as char(59))::varchar END),'Ñ','N'),'ñ','n'),'á','a'),'é','e'),'í','i'),'ó','o'),'ú','u'),'Á','A'),'É','E'),'Í','I'),'Ó','O'),'Ú','U'),'à','a'),'è','e'),'ì','i'),'ò','o'),'ù','u'),'À','A'),'È','E'),'Ì','I'),'Ò','O'),'Ù','U'),'Nº','No '),'º',''),'N°','No'),'°',''),'Nª','No'),'ª',''); --(CASE WHEN (RecSolicitud.direccion_laboral is null or RecSolicitud.direccion_laboral = null or RecSolicitud.direccion_laboral = '') then 'N/A' ELSE RecSolicitud.direccion_laboral END); --COALESCE(RecSolicitud.direccion_laboral,'N/A');
						CarteraGeneral.telefono_laboral = (CASE WHEN (RecSolicitud.telefono_laboral is null or RecSolicitud.telefono_laboral = null or RecSolicitud.telefono_laboral = '') then CarteraGeneral.telefono_residencia ELSE RecSolicitud.telefono_laboral END); --COALESCE(RecSolicitud.telefono_laboral,'N/A');

						CarteraGeneral.ciudad_correspondencia = COALESCE(CarteraGeneral.ciudad_residencia,'BARRANQUILLA');
						CarteraGeneral.cod_dane_correspondencia = COALESCE(CarteraGeneral.cod_dane_residencia,'8001');
						CarteraGeneral.direccion_correspondencia = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(COALESCE(RecSolicitud.direccion::varchar(60),'N/A'),'Ñ','N'),'ñ','n'),'á','a'),'é','e'),'í','i'),'ó','o'),'ú','u'),'Á','A'),'É','E'),'Í','I'),'Ó','O'),'Ú','U'),'à','a'),'è','e'),'ì','i'),'ò','o'),'ù','u'),'À','A'),'È','E'),'Ì','I'),'Ò','O'),'Ù','U'),'Nº','No '),'º',''),'N°','No'),'°',''),'Nª','No'),'ª',''); --COALESCE(cast(RecSolicitud.direccion as char(60))::varchar,'N/A');

						--CarteraGeneral.correo_electronico = (CASE WHEN (RecSolicitud.email is null or RecSolicitud.email = null or RecSolicitud.email = '') then 'info@fintra.co' ELSE RecSolicitud.email END); --COALESCE(RecSolicitud.email,'0');
						CarteraGeneral.correo_electronico = (CASE WHEN (RecSolicitud.email is null or RecSolicitud.email = null or RecSolicitud.email = '') then '' ELSE RecSolicitud.email END); --COALESCE(RecSolicitud.email,'0');
						CarteraGeneral.celular_solicitante = (CASE WHEN (RecSolicitud.celular is null or RecSolicitud.celular = null or RecSolicitud.celular = '') then '0' ELSE RecSolicitud.celular END); --COALESCE(RecSolicitud.celular,'0');
						CarteraGeneral.tipo = COALESCE(RecSolicitud.tipo,'0');

						if ( Accion = 'Generar' ) then

							--ACTUALIZA LAS OBLIGACIONES EN: 'S' PARA QUE NO SEAN REPORTADOS NNUEVAMENTE
							UPDATE cr_obligaciones_areportar_criesgo SET reportado = 'S' WHERE negocio_reportado = CarteraGeneral.negocio and reportado = 'N' and reg_status = '' and periodo_lote = _TramoAnterior and id_unidad_negocio = unidadnegocio;


						end if;

						RETURN NEXT CarteraGeneral;
						raise notice 'xxxxxxxxxxxx';
					END IF;

				END IF;

			END LOOP; --RecSolicitud

		END LOOP;

	END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION dv_reportedatacredito(date, numeric, character varying, numeric, numeric, character varying)
  OWNER TO postgres;
