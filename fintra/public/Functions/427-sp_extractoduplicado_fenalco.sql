-- Function: sp_extractoduplicado_fenalco(character varying, character varying)

-- DROP FUNCTION sp_extractoduplicado_fenalco(character varying, character varying);

CREATE OR REPLACE FUNCTION sp_extractoduplicado_fenalco(usuario character varying, coduplicado character varying)
  RETURNS text AS
$BODY$

DECLARE

	Mensaje TEXT;
	MsgPagueseAntes TEXT;
        MsgEstadoCredito TEXT;
        SQL TEXT;
        retorno TEXT;

        und_neg varchar;
        accion varchar := 'Generar'; -- Visualizar | Generar

	CarteraxCliente record;
	CarteraxCuota record;
	NegocioAvales record;
	NegocioSeguros record;
	NegocioGps record;
	ClienteRec record;
	_nomCiudad varchar;
	_Dpto varchar;
	_ConceptRec record;
	_Sancion record;
	_DetalleRopCondonar record;
	_Condonacion record;
	FchLastPay record;
	causarCM varchar;
	_TotalCuotasPendientes record;

	ReglasDuplicado record;

	und_negocio numeric;
	_TotalCuotasVencidas numeric;
	_SumCapital numeric;
	_SumIntCte numeric;
	_SumIntVencido numeric;
	_SumCapitanVenc numeric;
	_SumCapitalCte numeric;
	_SumDsctoCap numeric;
	_SumDsctoIxM numeric;
	_SumDsctoGxC numeric;
	_SumDsctoInt numeric;
	_SumDsctoSeguro numeric;
	_CuotaManejo numeric := 0;
	_SumCuotaManejo numeric := 0;
	_BaseCtaManejo numeric;

	CarteraxCuotaAval record;
	CarteraxCuotaSeguro record;
	CarteraxCuotaGps record;

	CarteraxCabeceraCta record;
	CarteraxCabeceraCtaAval record;
	CarteraxCabeceraCtaSeg record;
	CarteraxCabeceraCtaGps record;

	--IngresoxCuota numeric;
	_cod_temp numeric;
	_cod_rop numeric;
	_Base numeric;
	_IxM numeric;
	_GaC numeric;
	_CxCta numeric;
	_Tasa numeric;
	_ValidarExistencia numeric;
	BolsaSaldo numeric;
	Diferencia numeric;
	VlDetFactura numeric;

	_TotalCuotas numeric;
	_TotalCuotasFaltantes numeric;
	_CtasPentesFaltantes numeric;
	_ConsolidarConcepto numeric;

	SumTotalIxM numeric;
	SumTotalGaC numeric;
	_SumIxM numeric;
	_SumGaC numeric;
	_SumBase numeric;
	_SumCxCta numeric;
	_SumDebidoCobrar numeric;
	_TotalSumBase numeric;
	_TotalSumIxM numeric;
	_TotalSumGaC numeric;
	_TotalSumCxCta numeric;

	CodRop varchar;
	VerifyDetails varchar;
	id_concep_ixm numeric;
	id_concep_gac numeric;

	FechaCalculoInteres date;
	fecha_corte date;
	vencimiento_mayor varchar;
	est_comercio varchar;
	agencia varchar;
	Ciclo record;
	UltimoDia varchar;
	FechaUltimoPago varchar;
	periodo_corriente varchar;

BEGIN
        CodRop = '';

	DELETE FROM tem.extracto_temp;
	--select * from tem.extracto_temp;

	SELECT INTO UltimoDia * FROM sp_diasmes(now()::date);
	FechaUltimoPago = substring(now()::date,1,8)||UltimoDia;

	raise notice 'ultimo pago: %',FechaUltimoPago;

	fecha_corte = now()::date;
	periodo_corriente = replace(substring(now(),1,7),'-','');

	SQL = 'select
		'''||FechaUltimoPago||'''::date as vencimiento_rop,
		''''::varchar as venc_mayor,
		negocios.id_convenio::numeric, unidad.id_unid_negocio::integer, unidad.nombre_unid_negocio::varchar,
		negasoc::varchar, f.nit::varchar,
		negocios.num_ciclo::integer,
		''''::varchar as nom_cli,
		''''::varchar as direccion,
		''''::varchar as barrio,
		''''::varchar as ciudad,
		''''::varchar as departamento,
		''''::varchar as agencia,
		''''::varchar as linea_producto,
		count(0)-1::numeric as total_cuotas_vencidas,
		''''::varchar as cuotas_pendientes,
		('''||fecha_corte||'''-min(fecha_vencimiento)::DATE)::numeric as min_dias_ven,
		null::date as fecha_ultimo_pago,
		0::numeric as subtotal_det,
		0::numeric as total_sanciones,
		0::numeric as total_descuento,
		0::numeric as total_det,
		0::numeric as total_abonos,
		''''::varchar as observaciones,
		''''::varchar as msg_paguese_antes,
		''''::varchar as msg_estado,
		0::numeric as capital,
		0::numeric as int_cte,
		0::numeric as seguros,
		0::numeric as int_mora,
		0::numeric as gxc,
		0::numeric as dscto_cap,
		0::numeric as dscto_seguro,
		0::numeric as dscto_int_cte,
		0::numeric as dscto_int_mora,
		0::numeric as dscto_gxc,
		0::numeric as subtotal_corriente,
		0::numeric as subtotal_vencido,
		0::numeric as subtotalneto,
		0::numeric as descuentos,
		0::numeric as total,
		''''::varchar as est_comercio,		negocios.financia_aval
		FROM con.factura f
		inner join negocios on  (f.negasoc = negocios.cod_neg)
		inner join (select * from SP_NombreUnidadNegocio_all() as un(id_unid_negocio integer, nombre_unid_negocio varchar, id_convenio integer,ref_4 varchar)) unidad on (unidad.id_convenio=negocios.id_convenio)
		WHERE  f.reg_status = ''''
			and f.dstrct = ''FINV''
			and f.tipo_documento in (''FAC'',''NDC'')
			and f.valor_saldo > 0
			--Se comenta porque no muestra los negocios avales
			--and ( (select financia_aval from negocios where cod_neg = f.negasoc) = ''t'' or ( (select financia_aval from negocios where cod_neg = f.negasoc) = ''f'' and (select negocio_rel from negocios where cod_neg = f.negasoc) = '''' ) )
			and (select negocio_rel_seguro from negocios where cod_neg = f.negasoc) = ''''
			and (select negocio_rel_gps from negocios where cod_neg = f.negasoc) = ''''			and negocios.negocio_rel=''''
			and substring(f.documento,1,2) not in (''CP'',''FF'')
			and negasoc in (select negocio from recaudo.facturas_rop_duplicado where codigo_duplicado = '''||CoDuplicado||''' and rop_generado = ''N'' group by negocio)
			GROUP BY negocios.id_convenio, unidad.id_unid_negocio, unidad.nombre_unid_negocio, f.negasoc, f.nit ,negocios.num_ciclo,negocios.financia_aval';

		raise notice 'SQL: %',SQL;

	FOR CarteraxCliente IN EXECUTE SQL  LOOP

		SELECT INTO Ciclo * FROM con.ciclos_facturacion WHERE periodo = periodo_corriente AND num_ciclo = CarteraxCliente.num_ciclo;
		raise notice 'ciclo: %',Ciclo.id;

		raise notice 'Negocio Principal: %', CarteraxCliente.negasoc;

		und_negocio = CarteraxCliente.id_unid_negocio::integer;

		SELECT INTO vencimiento_mayor 	CASE WHEN maxdia >= 365 THEN '8- MAYOR A 1 ANIO'
		     WHEN maxdia >= 181 THEN '7- ENTRE 180 Y 360'
		     WHEN maxdia >= 121 THEN '6- ENTRE 121 Y 180'
		     WHEN maxdia >= 91 THEN '5- ENTRE 91 Y 120'
		     WHEN maxdia >= 61 THEN '4- ENTRE 61 Y 90'
		     WHEN maxdia >= 31 THEN '3- ENTRE 31 Y 60'
		     WHEN maxdia >= 1 THEN '2- 1 A 30'
		     WHEN maxdia <= 0 THEN '1- CORRIENTE'
			ELSE '0' END AS rango
		FROM (
			SELECT max(fecha_corte::date-(fecha_vencimiento)) as maxdia
			FROM con.factura fra
			WHERE fra.dstrct = 'FINV'
				AND fra.valor_saldo > 0
				AND fra.reg_status = ''
				AND fra.negasoc = CarteraxCliente.negasoc
				AND fra.tipo_documento in ('FAC','NDC')
				AND substring(fra.documento,1,2) not in ('CP','FF','DF')
				AND fra.fecha_vencimiento <= now()::date
			GROUP BY negasoc

		) vencimiento;


		SELECT INTO und_neg descripcion from unidad_negocio where id = und_negocio;
		SELECT INTO est_comercio payment_name from proveedor pv where nit = (select nit_tercero from negocios where cod_neg = CarteraxCliente.negasoc);

		SELECT INTO agencia SUBSTRING(CarteraxCliente.negasoc,1,2);

		IF(agencia = 'FB') THEN
			CarteraxCliente.agencia = 'BOLIVAR';
		ELSE
			CarteraxCliente.agencia = 'ATLANTICO';
		END IF;

		CarteraxCliente.venc_mayor = vencimiento_mayor;
		CarteraxCliente.est_comercio = est_comercio;

		SELECT INTO _TotalCuotas count(0) from documentos_neg_aceptado where cod_neg = CarteraxCliente.negasoc;
		SELECT INTO _TotalCuotasVencidas count(0) as CtasVencidas from con.factura where reg_status = '' and dstrct = 'FINV' and tipo_documento in ('FAC','NDC') and negasoc = CarteraxCliente.negasoc and valor_saldo > 0 and fecha_vencimiento < now()::date and substring(documento,1,2) not in ('CP','FF','DF') and descripcion not in ('CXC AVAL','CXC_INTERES_FA','CXC_CAT_MC','CXC_INTERES_MC');
		SELECT INTO _TotalCuotasPendientes count(0) as CtasPendientes, max(fecha_corte-(fecha_vencimiento)) as maxdia from con.factura where reg_status = '' and dstrct = 'FINV' and tipo_documento in ('FAC','NDC') and negasoc = CarteraxCliente.negasoc and  valor_saldo > 0  and fecha_vencimiento <=  now()::date and substring(documento,1,2) != 'CP';
		SELECT INTO _TotalCuotasFaltantes count(0) as CtasFaltantes from con.factura where reg_status = '' and dstrct = 'FINV' and tipo_documento in ('FAC','NDC') and negasoc = CarteraxCliente.negasoc   and valor_saldo > 0 and fecha_vencimiento > now()::date  and substring(documento,1,2) not in ('CP','FF','DF') and descripcion not in ('CXC AVAL','CXC_INTERES_FA','CXC_CAT_MC','CXC_INTERES_MC');

		CarteraxCliente.total_cuotas_vencidas = _TotalCuotasVencidas;

		SELECT INTO _cod_temp nextval('tem.extracto_temp_seq');

		if(accion = 'Generar') then
			--CREACION CABECERA DEL EXTRACTO
			INSERT INTO recibo_oficial_pago (cod_rop, id_unidad_negocio, periodo_rop, id_ciclo, vencimiento_rop, negocio, cuotas_vencidas, cuotas_pendientes,
							dias_vencidos, subtotal, total_sanciones, total_descuentos, total, total_abonos, creation_date, creation_user,
							last_update, user_update, observacion,duplicado)
				VALUES('',und_negocio,periodo_corriente,Ciclo.id,CarteraxCliente.vencimiento_rop,CarteraxCliente.negasoc,'0','0/0','0',0,0,0,0,0,now(),usuario,now(),usuario,'','S')
			RETURNING id INTO _cod_rop;
			retorno = _cod_rop;
			raise notice 'Id rop: %', _cod_rop;

		end if;

		--ULTIMO PAGO
		SELECT into FchLastPay max(i.fecha_consignacion) as fecha_consignacion
		FROM con.ingreso_detalle id
		INNER JOIN con.ingreso i ON (id.num_ingreso = i.num_ingreso and id.dstrct = i.dstrct and i.nitcli=id.nitcli )
		WHERE id.dstrct = 'FINV'
			and id.tipo_documento in ('ING','ICA')
			and i.reg_status = ''
			and i.branch_code != ''
			and i.bank_account_no != ''
			and i.nitcli= CarteraxCliente.nit
			and id.reg_status = ''
			and i.fecha_consignacion <= fecha_corte
			and id.num_ingreso in (
						select distinct num_ingreso
						from con.ingreso_detalle id, con.factura f
						where id.factura = f.documento
						and f.negasoc = CarteraxCliente.negasoc
						and f.tipo_documento in ('FAC','NDC')
						and f.reg_status = ''
						and f.devuelta != 'S'
						and f.corficolombiana != 'S'
						and f.endoso_fenalco !='S'
						and id.documento != ''
					     );

		IF FOUND THEN
			FechaCalculoInteres = COALESCE(FchLastPay.fecha_consignacion::date,fecha_corte::date);
		ELSE
			FechaCalculoInteres = fecha_corte::date;
		END IF;

		_SumBase = 0;
		_SumIxM = 0;
		_SumGaC = 0;
		_SumCxCta = 0;
		_SumCapital = 0;
		_SumIntCte = 0;
		_SumIntVencido = 0;
		SumTotalIxM = 0;
		SumTotalGaC = 0;
		_TotalSumBase = 0;
		_TotalSumCxCta = 0;
		_SumCapitanVenc = 0;
		_SumCapitalCte = 0;
		Mensaje = '';
		id_concep_ixm = 0;
		id_concep_gac = 0;
		_SumCuotaManejo = 0; --*

		FOR CarteraxCabeceraCta IN

			SELECT
				f.negasoc as negocio,
				f.documento,
				f.num_doc_fen as cuota,
				sum(f.valor_factura) as valor_factura,
				sum(f.valor_abono) as valor_abono,
				sum(f.valor_saldo) as valor_saldo,
				f.fecha_factura,
				f.fecha_vencimiento
			FROM con.factura f
			WHERE   f.reg_status = ''
				and f.dstrct = 'FINV'
				and f.tipo_documento in ('FAC','NDC')
				and f.valor_saldo > 0
				and f.negasoc = CarteraxCliente.negasoc
				and substring(f.documento,1,2) not in ('CP','FF')
				--and f.fecha_vencimiento <= now()::date
				and replace(substring(f.fecha_vencimiento,1,7),'-','') <= replace(substring(now()::date,1,7),'-','')
				and f.documento in (select documento from recaudo.facturas_rop_duplicado where codigo_duplicado = CoDuplicado and negocio = CarteraxCliente.negasoc)
			GROUP BY f.num_doc_fen,f.negasoc,f.num_doc_fen ,f.fecha_factura,f.fecha_vencimiento,f.documento
			ORDER BY f.num_doc_fen

		LOOP

			BolsaSaldo = CarteraxCabeceraCta.valor_saldo; --CarteraxCabeceraCta.valor_saldo;
			--BolsaSaldo = CarteraxCabeceraCta.valor_saldo;

			_CuotaManejo = 0;
		--Validar si la cuota de manejo esta en un documento CM o si esta en un item en el detalle de la factura.
		SELECT INTO causarCM causar_cuota_admin from documentos_neg_aceptado  where cod_neg =CarteraxCliente.negasoc limit 1;

		IF( causarCM = 'S') THEN
			if ( substring(CarteraxCabeceraCta.documento,8,2) != '00' ) then
				raise notice 'Ciclo.id: %', Ciclo.id;
				--_CuotaManejo = sp_tienecuotamanejo(periodo_corriente, CarteraxCabeceraCta.negocio, CarteraxCabeceraCta.cuota, Ciclo.id);
				_CuotaManejo = sp_cuotamanejo(CarteraxCabeceraCta.negocio, CarteraxCabeceraCta.cuota);
				raise notice '_CuotaManejo: %', _CuotaManejo;

				_SumCuotaManejo = _SumCuotaManejo + _CuotaManejo;
				raise notice '_SumCuotaManejo: %', _SumCuotaManejo;
			end if;

		ELSE
			if ( substring(CarteraxCabeceraCta.documento,8,2) != '00' ) then
				raise notice 'Ciclo.id: %', Ciclo.id;

				_CuotaManejo = sp_cuotamanejoFactura(CarteraxCabeceraCta.negocio, CarteraxCabeceraCta.cuota);
				raise notice '_CuotaManejo: %', _CuotaManejo;

				_SumCuotaManejo = _SumCuotaManejo + _CuotaManejo;
				raise notice '_SumCuotaManejo: %', _SumCuotaManejo;
			end if;
		END IF;



			FOR CarteraxCuota IN

				--NEGOCIO PRINCIPAL
				SELECT negocio, cedula, prefijo, cuota, fecha_factura, fecha_vencimiento, sum(valor_saldo) as valor_saldo, (fecha_corte-fecha_vencimiento::DATE) AS dias_vencidos FROM (

					SELECT
						f.negasoc as negocio,
						f.nit AS cedula,
						f.documento,
						fr.descripcion as prefijo,
						f.num_doc_fen as cuota,
						f.fecha_factura,
						f.fecha_vencimiento,
						fr.valor_unitario as valor_saldo
						--f.valor_saldo
					FROM con.factura f, con.factura_detalle fr
					WHERE   f.documento = fr.documento
						and f.reg_status = ''
						and f.dstrct = 'FINV'
						and f.tipo_documento in ('FAC','NDC')
						and fr.reg_status = ''
						and fr.dstrct = 'FINV'
						and fr.tipo_documento in ('FAC','NDC')
						and f.valor_saldo > 0
						and f.negasoc = CarteraxCabeceraCta.negocio
						--and f.num_doc_fen = CarteraxCabeceraCta.cuota
						--and f.documento in (select documento from recaudo.facturas_rop_duplicado where codigo_duplicado = CoDuplicado and negocio = CarteraxCabeceraCta.negocio)
						and f.documento = CarteraxCabeceraCta.documento
						and substring(f.documento,1,2) not in ('CP','FF')
						and f.codcli != 'CL00201'
						--and f.fecha_vencimiento <= now()::date
						and replace(substring(f.fecha_vencimiento,1,7),'-','') <= replace(substring(now()::date,1,7),'-','')
					) as c
				GROUP BY negocio, cedula, prefijo, cuota, fecha_vencimiento, fecha_factura, dias_vencidos
				ORDER BY prefijo DESC --cuota::numeric


			LOOP

			raise notice 'CarteraxCuota.negocio: %', CarteraxCuota.negocio;
				raise notice 'CarteraxCuota.cuota: %', CarteraxCuota.cuota;

				_IxM = 0;
				_CxCta = 0;
				_Base = 0;
				_GaC = 0;

				-----------------------------------------------------------------------------------------------------------------------
				VerifyDetails = 'N';
				Diferencia = BolsaSaldo - CarteraxCuota.valor_saldo; --valor_unitario

				raise notice 'Negocio: %, Cuota: %, BolsaSaldo: %, valor_saldo: %Diferencia, Diferencia: %',CarteraxCuota.negocio, CarteraxCuota.cuota, BolsaSaldo, CarteraxCuota.valor_saldo, Diferencia;
				/*
				if ( Diferencia <= 0 and BolsaSaldo > 0) then

					_Base = CarteraxCuota.valor_saldo - BolsaSaldo;
					BolsaSaldo = 0;

				elsif ( Diferencia > 0 and BolsaSaldo > 0 ) then

					_Base = 0;
					BolsaSaldo = BolsaSaldo - CarteraxCuota.valor_saldo;

				--elsif ( BolsaSaldo <= 0 ) then
				elsif ( Diferencia <= 0 ) then
					_Base = CarteraxCuota.valor_saldo;
				end if;
				*/
				--

				if ( BolsaSaldo > 0 and Diferencia > 0 ) then

					raise notice 'A';
					_Base = CarteraxCuota.valor_saldo;
					BolsaSaldo = BolsaSaldo - CarteraxCuota.valor_saldo;

				elsif ( BolsaSaldo > 0 and Diferencia <= 0) then

					raise notice 'B';
					_Base = CarteraxCuota.valor_saldo;
					BolsaSaldo = 0;

				end if;

				--------------------------------------------------
				raise notice '_Base: %',_Base;
				if ( _Base > 0 ) then

					raise notice 'Negocio: % Cuota: % _Base: %',CarteraxCuota.negocio, CarteraxCuota.cuota,_Base;

					--SUMA DE BASES
					_SumBase = _SumBase + _Base;
					raise notice '_SumBase: %',_SumBase;

					--Conceptos
					SELECT INTO _ConceptRec * FROM conceptos_recaudo WHERE prefijo = CarteraxCuota.prefijo AND CarteraxCuota.dias_vencidos BETWEEN dias_rango_ini AND dias_rango_fin and id_unidad_negocio = und_negocio;
					raise notice 'prefijo: % dias_vencidos: % und_negocio: %',CarteraxCuota.prefijo, CarteraxCuota.dias_vencidos,und_negocio;
					if found then
						raise notice 'ENCUENTRA!';
						--Sanciones
						FOR _Sancion IN SELECT * FROM sanciones_condonaciones WHERE id_tipo_acto = 1 AND id_conceptos_recaudo = _ConceptRec.id AND CarteraxCuota.dias_vencidos BETWEEN dias_rango_ini AND dias_rango_fin AND periodo = periodo_corriente and id_unidad_negocio = und_negocio LOOP
							raise notice 'ENTRA!';
							IF ( _Sancion.categoria = 'IXM' ) THEN
								raise notice 'A';
								if ( fecha_corte > CarteraxCuota.fecha_vencimiento::date ) then

									select into _Tasa tasa_usura/100 from convenios where id_convenio = CarteraxCliente.id_convenio;

									_IxM = ROUND( _Base*(_Tasa/30) * (fecha_corte - CarteraxCuota.fecha_vencimiento)::numeric );
									_SumIxM = _SumIxM + _IxM;
									raise notice '***CarteraxCliente.id_convenio% _Base % _Tasa % CarteraxCuota.prefijo: % _IxM: %',CarteraxCliente.id_convenio, _Base, _Tasa, CarteraxCuota.prefijo, _IxM;
								end if;

							END IF;

							IF ( _Sancion.categoria = 'GAC' ) THEN
								raise notice 'B';
								if ( fecha_corte > CarteraxCuota.fecha_vencimiento::date ) then
									_GaC = ROUND((_Base * _Sancion.porcentaje::numeric)/100);
									_SumGaC = _SumGaC + _GaC;
								end if;

							END IF;

						END LOOP; --_Sancion

						if ( CarteraxCuota.prefijo = 'CAPITAL' ) then

							_CuotaManejo = sp_cuotamanejoFactura(CarteraxCabeceraCta.negocio, CarteraxCabeceraCta.cuota);--Se agrego porque no la estaba sumando Noviembre 02/17
							_BaseCtaManejo = _Base;-- + _CuotaManejo; --La resto porque la estaba sumando de mas.


							raise notice '_BaseCtaManejo: %', _CuotaManejo;
						else
							--_CuotaManejo = 0;
							--_CuotaManejo = sp_cuotamanejo(periodo_corriente, CarteraxCuota.negocio, CarteraxCuota.cuota, Ciclo.id);

							_BaseCtaManejo = _Base;
							raise notice '_BaseCtaManejo(Cero): 0';
						end if;

						--detalle_extracto
						if(_ConceptRec.descripcion in ('CAPITAL CORRIENTE','AVAL CORRIENTE','REMESA CORRIENTE')) then
							_SumCapitalCte = _SumCapitalCte + _Base;
							_SumCapital = _SumCapital + _Base;
						elsif (_ConceptRec.descripcion in ('CAPITAL VENCIDO','AVAL VENCIDO','REMESA VENCIDO')) then
							_SumCapitanVenc = _SumCapitanVenc + _Base;
							_SumCapital = _SumCapital + _Base;
						elsif (_ConceptRec.descripcion = 'INTERES CORRIENTE') then
							_SumIntCte = _SumIntCte + _Base ;
						elsif (_ConceptRec.descripcion = 'INTERES VENCIDO') then
							_SumIntVencido = _SumIntVencido + _Base;
						end if;

						raise notice 'capital: %',_SumCapital+_SumIntCte+_SumIntVencido;

						insert into tem.extracto_temp (cod_rop,id_concepto,concepto,fecha_venc_padre,vr_concepto,negocio) values (_cod_temp,_ConceptRec.id,_ConceptRec.descripcion,CarteraxCuota.fecha_factura,_Base,CarteraxCliente.negasoc);

						if(accion = 'Generar') then
							INSERT INTO detalle_rop (id_rop, id_conceptos_recaudo, descripcion, cuota, dias_vencidos, fecha_factura_padre, fecha_vencimiento_padre, fecha_ultimo_pago, items, valor_concepto, valor_descuento, valor_ixm, valor_descuento_ixm, valor_gac, valor_descuento_gac, valor_abono, valor_saldo, creation_date, creation_user, negocio)
							VALUES (_cod_rop, _ConceptRec.id, _ConceptRec.descripcion, CarteraxCuota.cuota, CarteraxCuota.dias_vencidos, CarteraxCuota.fecha_factura, CarteraxCuota.fecha_vencimiento,'',1, _BaseCtaManejo, 0, _IxM, 0, _GaC, _CxCta, 0, _BaseCtaManejo+_IxM+_GaC-_CxCta, now(), usuario, CarteraxCliente.negasoc);
						end if;

					end if;

				end if;

			END LOOP; --CarteraxCuota

		END LOOP;

		SumTotalIxM = SumTotalIxM + _SumIxM;
		SumTotalGaC = SumTotalGaC + _SumGaC;

		if ( _SumIxM > 0 ) then
			SELECT INTO id_concep_ixm id FROM conceptos_recaudo WHERE descripcion = 'INTERES MORA' and id_unidad_negocio = und_negocio;
			INSERT INTO tem.extracto_temp (cod_rop, id_concepto, concepto, vr_concepto, valor_saldo, negocio)
			VALUES (_cod_temp, id_concep_ixm, 'INTERES MORA',_SumIxM,_SumIxM,CarteraxCliente.negasoc);

		end if;

		if ( _SumGaC > 0 ) then
			SELECT INTO id_concep_gac id FROM conceptos_recaudo WHERE descripcion = 'GASTOS DE COBRANZA' and id_unidad_negocio = und_negocio;
			INSERT INTO tem.extracto_temp (cod_rop, id_concepto, concepto, vr_concepto, valor_saldo, negocio)
			VALUES (_cod_temp, id_concep_gac, 'GASTOS DE COBRANZA',_SumGaC, _SumGaC, CarteraxCliente.negasoc);

		end if;

		if(accion = 'Generar') then

			--INGRESO DE LOS CONCEPTOS DE INTERES Y DE GASTOS DE COBRANZA
			if ( _SumIxM > 0 ) then
				INSERT INTO detalle_rop (id_rop, id_conceptos_recaudo, descripcion, cuota, dias_vencidos, fecha_factura_padre, fecha_vencimiento_padre, fecha_ultimo_pago, items, valor_concepto, valor_descuento, valor_ixm, valor_descuento_ixm, valor_gac, valor_descuento_gac, valor_abono, valor_saldo, creation_date, creation_user, negocio)
				VALUES (_cod_rop, id_concep_ixm, 'INTERES MORA', 0, 0, '0099-01-01', '0099-01-01','',1, _SumIxM, 0, 0, 0, 0, 0, 0, _SumIxM, now(), usuario, CarteraxCliente.negasoc);
			end if;

			if ( _SumGaC > 0 ) then
				INSERT INTO detalle_rop (id_rop, id_conceptos_recaudo, descripcion, cuota, dias_vencidos, fecha_factura_padre, fecha_vencimiento_padre, fecha_ultimo_pago, items, valor_concepto, valor_descuento, valor_ixm, valor_descuento_ixm, valor_gac, valor_descuento_gac, valor_abono, valor_saldo, creation_date, creation_user, negocio)
				VALUES (_cod_rop, id_concep_gac, 'GASTOS DE COBRANZA', 0, 0, '0099-01-01', '0099-01-01','',1, _SumGaC, 0, 0, 0, 0, 0, 0, _SumGaC, now(), usuario, CarteraxCliente.negasoc);
			end if;

		end if;

		--NEGOCIO DE AVAL		--/*AND und_negocio != 2 AND und_negocio != 8 AND und_negocio != 12*/ quieto esta monda porque estan asumiendo que los negocios educativos no tienen aval
		---------------------------------------------------------------------------------------------
		IF(und_negocio != 1 and CarteraxCliente.financia_aval ) THEN

			_SumIxM = 0;
			_SumGaC = 0;

			---------------------------------------------------------------------------------------------
			FOR NegocioAvales IN

				--select * from negocios where negocio_rel = CarteraxCliente.negasoc
				select negocios.*
				from negocios
				join recaudo.facturas_rop_duplicado on ( codigo_duplicado = CoDuplicado and negocio = negocios.cod_neg)
				where negocio_rel = CarteraxCliente.negasoc

			LOOP
				raise notice 'Negocio Aval: %', NegocioAvales.cod_neg;

				IF NegocioAvales.cod_neg != '' THEN
					raise notice 'cod_neg_aval: %', NegocioAvales.cod_neg;
					FOR CarteraxCabeceraCtaAval IN

						SELECT
							f.negasoc as negocio,
							f.documento,
							f.num_doc_fen as cuota,
							sum(f.valor_factura) as valor_factura,
							sum(f.valor_abono) as valor_abono,
							sum(f.valor_saldo) as valor_saldo,
							f.fecha_factura,
							f.fecha_vencimiento
						FROM con.factura f
						WHERE   f.reg_status = ''
							and f.dstrct = 'FINV'
							and f.tipo_documento in ('FAC','NDC')
							and f.valor_saldo > 0
							and f.negasoc = NegocioAvales.cod_neg --Lo agrego en la tabla que creo Edgar
							and f.documento in (select documento from recaudo.facturas_rop_duplicado where codigo_duplicado = CoDuplicado and negocio = NegocioAvales.cod_neg)
							and substring(f.documento,1,2) not in ('CP','FF')
							--and f.fecha_vencimiento::date <= now()::date
							and replace(substring(f.fecha_vencimiento,1,7),'-','') <= replace(substring(now()::date,1,7),'-','')
						GROUP BY f.num_doc_fen,f.negasoc ,f.fecha_factura,f.fecha_vencimiento,f.documento
						ORDER BY f.num_doc_fen

					LOOP

						BolsaSaldo = CarteraxCabeceraCtaAval.valor_saldo; --CarteraxCabeceraCtaAval.valor_saldo;
						raise notice 'documento_aval: %', CarteraxCabeceraCtaAval.documento;

						FOR CarteraxCuotaAval IN

							SELECT negocio, cedula, prefijo, cuota, fecha_factura, fecha_vencimiento, sum(valor_saldo) as valor_saldo, (fecha_corte-fecha_vencimiento::DATE) AS dias_vencidos FROM (

								SELECT
									f.negasoc as negocio,
									f.nit AS cedula,
									f.documento,
									fr.descripcion as prefijo,
									f.num_doc_fen as cuota,
									f.fecha_factura,
									f.fecha_vencimiento,
									fr.valor_unitario as valor_saldo
								FROM    con.factura f, con.factura_detalle fr
								WHERE   f.documento = fr.documento
									and f.reg_status = ''
									and f.dstrct = 'FINV'
									and f.tipo_documento in ('FAC','NDC')
									and fr.reg_status = ''
									and fr.dstrct = 'FINV'
									and fr.tipo_documento in ('FAC','NDC')
									and f.valor_saldo > 0
									and f.negasoc = CarteraxCabeceraCtaAval.negocio
									--and f.num_doc_fen = CarteraxCabeceraCtaAval.cuota --Indico las facturas que estan en la tabla de Edgar.
									and f.documento = CarteraxCabeceraCtaAval.documento
									--and f.fecha_vencimiento::date <= now()::date
									and replace(substring(f.fecha_vencimiento,1,7),'-','') <= replace(substring(now()::date,1,7),'-','')
									and substring(f.documento,1,2) not in ('CP','FF')
								) as c
							GROUP BY negocio, cedula, prefijo, cuota, fecha_vencimiento, fecha_factura, dias_vencidos
							ORDER BY prefijo DESC--::numeric
						LOOP

							_IxM = 0;
							_CxCta = 0;
							_Base = 0;
							_GaC = 0;
							_ValidarExistencia = 0;

							-----------------------------------------------------------------------------------------------------------------------
							VerifyDetails = 'N';
							Diferencia = BolsaSaldo - CarteraxCuotaAval.valor_saldo; --valor_unitario

							raise notice 'NegocioAval: %, Cuota: %, BolsaSaldo: %, valor_saldo: %',CarteraxCuotaAval.negocio, CarteraxCuotaAval.cuota, BolsaSaldo, CarteraxCuotaAval.valor_saldo;
							/*
							if ( BolsaSaldo > 0 and Diferencia <= 0 ) then

								_Base = CarteraxCuotaAval.valor_saldo - BolsaSaldo;
								BolsaSaldo = 0;

							elsif ( BolsaSaldo > 0 and Diferencia > 0 ) then

								_Base = 0;
								BolsaSaldo = BolsaSaldo - CarteraxCuotaAval.valor_saldo;

							elsif ( BolsaSaldo <= 0 ) then
								_Base = CarteraxCuotaAval.valor_saldo;
							end if;
							*/
							--

							if ( BolsaSaldo > 0 and Diferencia > 0 ) then

								raise notice 'A';
								_Base = CarteraxCuotaAval.valor_saldo;
								BolsaSaldo = BolsaSaldo - CarteraxCuotaAval.valor_saldo;

							elsif ( BolsaSaldo > 0 and Diferencia <= 0) then

								raise notice 'B';
								_Base = CarteraxCuotaAval.valor_saldo;
								BolsaSaldo = 0;

							end if;
							-----------------------------------------------------------------------------------------------------------------------

							if ( _Base > 0 ) then
								raise notice 'Negocio: % Cuota: % _Base: %',CarteraxCuotaAval.negocio, CarteraxCuotaAval.cuota,_Base;
								--SUMA DE BASES
								_SumBase = _SumBase + _Base;

								--Conceptos
								SELECT INTO _ConceptRec * FROM conceptos_recaudo WHERE prefijo = CarteraxCuotaAval.prefijo AND CarteraxCuotaAval.dias_vencidos BETWEEN dias_rango_ini AND dias_rango_fin and id_unidad_negocio = und_negocio;
								if found then

									--Sanciones
									FOR _Sancion IN SELECT * FROM sanciones_condonaciones WHERE id_tipo_acto = 1 AND id_conceptos_recaudo = _ConceptRec.id AND CarteraxCuotaAval.dias_vencidos BETWEEN dias_rango_ini AND dias_rango_fin AND periodo = periodo_corriente and id_unidad_negocio = und_negocio LOOP

										IF ( _Sancion.categoria = 'IXM' ) THEN

											if ( fecha_corte > CarteraxCuotaAval.fecha_vencimiento::date ) then

												select into _Tasa tasa_usura/100 from convenios where id_convenio = CarteraxCliente.id_convenio;

												_IxM = ROUND( _Base*(_Tasa/30) * (fecha_corte - CarteraxCuotaAval.fecha_vencimiento)::numeric );
												_SumIxM = _SumIxM + _IxM;
												raise notice 'ixm: %',_IxM;
											end if;

										END IF;

										IF ( _Sancion.categoria = 'GAC' ) THEN

											if ( fecha_corte > CarteraxCuotaAval.fecha_vencimiento::date ) then
												_GaC = ROUND((_Base * _Sancion.porcentaje::numeric)/100);
												_SumGaC = _SumGaC + _GaC;
											end if;

										END IF;

									END LOOP; --_Sancion

									--detalle_extracto
									if(_ConceptRec.descripcion in ('CAPITAL CORRIENTE','AVAL CORRIENTE','REMESA CORRIENTE')) then
										_SumCapitalCte = _SumCapitalCte + _Base;
										_SumCapital = _SumCapital + _Base + _SumCuotaManejo;
									elsif (_ConceptRec.descripcion in ('CAPITAL VENCIDO','AVAL VENCIDO','REMESA VENCIDO')) then
										_SumCapitanVenc = _SumCapitanVenc + _Base;
										_SumCapital = _SumCapital + _Base ;
									elsif (_ConceptRec.descripcion = 'INTERES CORRIENTE') then
										_SumIntCte = _SumIntCte + _Base ;
									elsif (_ConceptRec.descripcion = 'INTERES VENCIDO') then
										_SumIntVencido = _SumIntVencido + _Base;
									end if;

									raise notice 'capital aval: %',_SumCapital+_SumIntCte+_SumIntVencido;

									insert into tem.extracto_temp (cod_rop,id_concepto,concepto,fecha_venc_padre,vr_concepto,negocio) values (_cod_temp,_ConceptRec.id,_ConceptRec.descripcion,CarteraxCuota.fecha_factura,_Base,CarteraxCabeceraCtaAval.negocio);

									if(accion = 'Generar') then
										--detalle_extracto
										INSERT INTO detalle_rop (id_rop, id_conceptos_recaudo, descripcion, cuota, dias_vencidos, fecha_factura_padre, fecha_vencimiento_padre, fecha_ultimo_pago, items, valor_concepto, valor_descuento, valor_ixm, valor_descuento_ixm, valor_gac, valor_descuento_gac, valor_abono, valor_saldo, creation_date, creation_user, negocio)
										VALUES (_cod_rop, _ConceptRec.id, _ConceptRec.descripcion, CarteraxCuotaAval.cuota, CarteraxCuotaAval.dias_vencidos, CarteraxCuotaAval.fecha_factura, CarteraxCuotaAval.fecha_vencimiento,'',1, _Base, 0, _IxM, 0, _GaC, _CxCta, 0, _Base+_IxM+_GaC-_CxCta, now(), usuario, NegocioAvales.cod_neg);
									end if;

								end if;

							end if;

						END LOOP; --CarteraxCuotaAval

					END LOOP;

					SumTotalIxM = SumTotalIxM + _SumIxM;
					SumTotalGaC = SumTotalGaC + _SumGaC;

					--INGRESO DE LOS CONCEPTOS DE INTERES Y DE GASTOS DE COBRANZA A TEMPORAL
					if ( _SumIxM > 0 ) then
						SELECT INTO _ValidarExistencia sum(valor_saldo) as SumSaldoIxm FROM tem.extracto_temp WHERE cod_rop = _cod_temp and id_concepto = id_concep_ixm;
						IF ( _ValidarExistencia > 0 ) THEN
							_ConsolidarConcepto = _ValidarExistencia + _SumIxM;
							UPDATE tem.extracto_temp SET  vr_concepto = _ConsolidarConcepto, valor_saldo = _ConsolidarConcepto WHERE cod_rop = _cod_temp and id_concepto = id_concep_ixm;
						ELSE
							INSERT INTO tem.extracto_temp (cod_rop, id_concepto, concepto, vr_concepto, valor_ixm, valor_gac,negocio)
							VALUES (_cod_temp, id_concep_ixm, 'INTERES MORA',_SumIxM,_SumIxM,0, NegocioAvales.cod_neg);
						END IF;

					end if;

					if ( _SumGaC > 0 ) then
						SELECT INTO _ValidarExistencia sum(valor_saldo) as SumSaldoGac FROM tem.extracto_temp WHERE cod_rop = _cod_temp and id_concepto = id_concep_gac;
						IF ( _ValidarExistencia > 0 ) THEN
							_ConsolidarConcepto = _ValidarExistencia + _SumGaC;
							UPDATE tem.extracto_temp SET vr_concepto = _ConsolidarConcepto, valor_saldo = _ConsolidarConcepto WHERE cod_rop = _cod_temp and id_concepto = id_concep_gac;
						ELSE
							INSERT INTO tem.extracto_temp (cod_rop, id_concepto, concepto, vr_concepto, valor_ixm, valor_gac,negocio)
							VALUES (_cod_temp, id_concep_gac, 'GASTOS DE COBRANZA',_SumGaC, 0, _SumGaC, NegocioAvales.cod_neg);
						END IF;

					end if;

					--INGRESO DE LOS CONCEPTOS DE INTERES Y DE GASTOS DE COBRANZA AL DETALLE
					if(accion = 'Generar') then

						if ( _SumIxM > 0 ) then
							SELECT INTO _ValidarExistencia sum(valor_saldo) as SumSaldoIxm FROM detalle_rop WHERE id_rop = _cod_rop and id_conceptos_recaudo = id_concep_ixm;
							IF ( _ValidarExistencia > 0 ) THEN
								_ConsolidarConcepto = _ValidarExistencia + _SumIxM;
								UPDATE detalle_rop SET valor_concepto = _ConsolidarConcepto, valor_saldo = _ConsolidarConcepto WHERE id_rop = _cod_rop and id_conceptos_recaudo = id_concep_ixm;
							ELSE
								INSERT INTO detalle_rop (id_rop, id_conceptos_recaudo, descripcion, cuota, dias_vencidos, fecha_factura_padre, fecha_vencimiento_padre, fecha_ultimo_pago, items, valor_concepto, valor_descuento, valor_ixm, valor_descuento_ixm, valor_gac, valor_descuento_gac, valor_abono, valor_saldo, creation_date, creation_user, negocio)
									VALUES (_cod_rop, id_concep_ixm , 'INTERES MORA', 0, 0, '0099-01-01', '0099-01-01','',1, _SumIxM, 0, 0, 0, 0, 0, 0, _SumIxM, now(), usuario, NegocioAvales.cod_neg);
							END IF;


						end if;

						if ( _SumGaC > 0 ) then
							SELECT INTO _ValidarExistencia sum(valor_saldo) as SumSaldoGac FROM detalle_rop WHERE id_rop = _cod_rop and id_conceptos_recaudo = id_concep_gac;
							IF ( _ValidarExistencia > 0 ) THEN
								_ConsolidarConcepto = _ValidarExistencia + _SumGaC;
								UPDATE detalle_rop SET valor_concepto = _ConsolidarConcepto, valor_saldo = _ConsolidarConcepto WHERE id_rop = _cod_rop and id_conceptos_recaudo = id_concep_gac;
							ELSE
								INSERT INTO detalle_rop (id_rop, id_conceptos_recaudo, descripcion, cuota, dias_vencidos, fecha_factura_padre, fecha_vencimiento_padre, fecha_ultimo_pago, items, valor_concepto, valor_descuento, valor_ixm, valor_descuento_ixm, valor_gac, valor_descuento_gac, valor_abono, valor_saldo, creation_date, creation_user, negocio)
									 VALUES (_cod_rop, id_concep_gac, 'GASTOS DE COBRANZA', 0, 0, '0099-01-01', '0099-01-01','',1, _SumGaC, 0, 0, 0, 0, 0, 0, _SumGaC, now(), usuario, NegocioAvales.cod_neg);
							END IF;

						end if;

					end if;

				END IF;

			END LOOP;

			--NEGOCIO DE SEGURO
			raise notice 'El que llega es: %', und_negocio;

			IF ( und_negocio = 3 OR und_negocio = 9 OR und_negocio = 13 ) THEN

				---------------------------------------------------------------------------------------------
				FOR NegocioSeguros IN

					--select * from negocios where negocio_rel_seguro = CarteraxCliente.negasoc
					--union all
					--SELECT * FROM negocios  where negocio_rel in (select cod_neg from negocios where negocio_rel_seguro = CarteraxCliente.negasoc)

					select negocios.cod_neg --negocios.*
					from negocios
					join recaudo.facturas_rop_duplicado on ( codigo_duplicado = CoDuplicado and negocio = negocios.cod_neg)
					where negocio_rel_seguro = CarteraxCliente.negasoc
					group by cod_neg

					union all

					select negocios.cod_neg --negocios.*
					from negocios
					join recaudo.facturas_rop_duplicado on ( codigo_duplicado = CoDuplicado and negocio = negocios.cod_neg)
					where negocio_rel in (select cod_neg from negocios where negocio_rel_seguro = CarteraxCliente.negasoc)
					group by cod_neg

				LOOP
					_SumIxM = 0;
					_SumGaC = 0;

					raise notice 'Negocio seguro: %', NegocioSeguros.cod_neg;

					IF NegocioSeguros.cod_neg != '' THEN

						FOR CarteraxCabeceraCtaSeg IN

							SELECT
								f.negasoc as negocio,
								f.documento,
								f.num_doc_fen as cuota,
								sum(f.valor_factura) as valor_factura,
								sum(f.valor_abono) as valor_abono,
								sum(f.valor_saldo) as valor_saldo,
								f.fecha_factura,
								f.fecha_vencimiento
							FROM 	con.factura  f
							WHERE   f.reg_status = ''
								and f.dstrct = 'FINV'
								and f.tipo_documento in ('FAC','NDC')
								and f.valor_saldo > 0
								and f.negasoc = NegocioSeguros.cod_neg
								and f.documento in (select documento from recaudo.facturas_rop_duplicado where codigo_duplicado = CoDuplicado and negocio = NegocioSeguros.cod_neg)
								and substring(f.documento,1,2) not in ('CP','FF')
								--and f.fecha_vencimiento::date <= now()::date
								and replace(substring(f.fecha_vencimiento,1,7),'-','') <= replace(substring(now()::date,1,7),'-','')
							GROUP BY f.num_doc_fen,f.negasoc ,f.fecha_factura,f.fecha_vencimiento,f.documento
							ORDER BY f.num_doc_fen

						LOOP

							BolsaSaldo = CarteraxCabeceraCtaSeg.valor_saldo; --CarteraxCabeceraCtaSeg.valor_abono
							raise notice 'BolsaSaldo: %, negocio: %, documento: %', BolsaSaldo, CarteraxCabeceraCtaSeg.negocio, CarteraxCabeceraCtaSeg.documento;

							FOR CarteraxCuotaSeguro IN

								SELECT negocio, cedula, prefijo, cuota, fecha_factura, fecha_vencimiento, sum(valor_saldo) as valor_saldo, (fecha_corte-fecha_vencimiento::DATE) AS dias_vencidos FROM (

									SELECT
										f.negasoc as negocio,
										f.nit AS cedula,
										f.documento,
										fr.descripcion as prefijo,  --substring(f.documento,1,2) as prefijo,
										f.num_doc_fen as cuota,
										f.fecha_factura,
										f.fecha_vencimiento,
										fr.valor_unitario as valor_saldo
									FROM con.factura  f, con.factura_detalle fr
									WHERE   f.documento = fr.documento
										and f.reg_status = ''
										and f.dstrct = 'FINV'
										and f.tipo_documento in ('FAC','NDC')
										and fr.reg_status = ''
										and fr.dstrct = 'FINV'
										and fr.tipo_documento in ('FAC','NDC')
										and f.valor_saldo > 0
										and f.negasoc = CarteraxCabeceraCtaSeg.negocio
										and f.documento = CarteraxCabeceraCtaSeg.documento
										--and f.fecha_vencimiento::date <= now()::date
										and replace(substring(f.fecha_vencimiento,1,7),'-','') <= replace(substring(now()::date,1,7),'-','')
										and substring(f.documento,1,2) not in ('CP','FF')
									) as c
								GROUP BY negocio, cedula, prefijo, cuota, fecha_vencimiento, fecha_factura, dias_vencidos
								ORDER BY prefijo DESC --cuota::numeric
							LOOP

								_IxM = 0;
								_CxCta = 0;
								_Base = 0;
								_GaC = 0;
								_ValidarExistencia = 0;

								-----------------------------------------------------------------------------------------------------------------------
								VerifyDetails = 'N';
								Diferencia = BolsaSaldo - CarteraxCuotaSeguro.valor_saldo; --valor_unitario

								raise notice 'Negocio: %, Cuota: %, BolsaSaldo: %, valor_saldo: %, Diferencia: %',CarteraxCuotaSeguro.negocio, CarteraxCuotaSeguro.cuota, BolsaSaldo, CarteraxCuotaSeguro.valor_saldo, Diferencia;

								if ( BolsaSaldo > 0 and Diferencia > 0 ) then

									raise notice 'B';
									_Base = CarteraxCuotaSeguro.valor_saldo;
									BolsaSaldo = BolsaSaldo - CarteraxCuotaSeguro.valor_saldo;

								elsif ( BolsaSaldo > 0 and Diferencia <= 0) then

									raise notice 'A';
									_Base = CarteraxCuotaSeguro.valor_saldo;
									BolsaSaldo = 0;

								end if;

								-----------------------------------------------------------------------------------------------------------------------
								raise notice '_Base: %',_Base;
								if ( _Base > 0 ) then

									raise notice 'Negocio: % Cuota: % _Base: %',CarteraxCuotaSeguro.negocio, CarteraxCuotaSeguro.cuota,_Base;
									--SUMA DE BASES
									_SumBase = _SumBase + _Base;

									--Conceptos
									SELECT INTO _ConceptRec * FROM conceptos_recaudo WHERE prefijo = CarteraxCuotaSeguro.prefijo AND CarteraxCuotaSeguro.dias_vencidos BETWEEN dias_rango_ini AND dias_rango_fin and id_unidad_negocio = und_negocio;

									if found then

										--Sanciones
										FOR _Sancion IN SELECT * FROM sanciones_condonaciones WHERE id_tipo_acto = 1 AND id_conceptos_recaudo = _ConceptRec.id AND CarteraxCuotaSeguro.dias_vencidos BETWEEN dias_rango_ini AND dias_rango_fin AND periodo = periodo_corriente and id_unidad_negocio = und_negocio LOOP

											IF ( _Sancion.categoria = 'IXM' ) THEN

												if ( fecha_corte > CarteraxCuotaSeguro.fecha_vencimiento::date ) then

													select into _Tasa tasa_usura/100 from convenios where id_convenio = CarteraxCliente.id_convenio;

													_IxM = ROUND( _Base*(_Tasa/30) * (fecha_corte - CarteraxCuotaSeguro.fecha_vencimiento)::numeric );

													_SumIxM = _SumIxM + _IxM;
												end if;

											END IF;

											IF ( _Sancion.categoria = 'GAC' ) THEN

												if ( fecha_corte > CarteraxCuotaSeguro.fecha_vencimiento::date ) then
													_GaC = ROUND((_Base * _Sancion.porcentaje::numeric)/100);
													_SumGaC = _SumGaC + _GaC;
												end if;

											END IF;

										END LOOP; --_Sancion

										--detalle_extracto
										if(_ConceptRec.descripcion in ('CAPITAL CORRIENTE','AVAL CORRIENTE','REMESA CORRIENTE')) then
											_SumCapitalCte = _SumCapitalCte + _Base;
											_SumCapital = _SumCapital + _Base;
										elsif (_ConceptRec.descripcion in ('CAPITAL VENCIDO','AVAL VENCIDO','REMESA VENCIDO')) then
											_SumCapitanVenc = _SumCapitanVenc + _Base;
											_SumCapital = _SumCapital + _Base;
										elsif (_ConceptRec.descripcion = 'INTERES CORRIENTE') then
											_SumIntCte = _SumIntCte + _Base;
										elsif (_ConceptRec.descripcion = 'INTERES VENCIDO') then
											_SumIntVencido = _SumIntVencido + _Base;
										end if;
										raise notice 'capital seg: %',_SumCapital+_SumIntCte+_SumIntVencido;
										insert into tem.extracto_temp (cod_rop,id_concepto,concepto,fecha_venc_padre,vr_concepto,negocio) values (_cod_temp,_ConceptRec.id,_ConceptRec.descripcion,CarteraxCuotaSeguro.fecha_factura,_Base,NegocioSeguros.cod_neg);

										if(accion = 'Generar') then
											INSERT INTO detalle_rop (id_rop, id_conceptos_recaudo, descripcion, cuota, dias_vencidos, fecha_factura_padre, fecha_vencimiento_padre, fecha_ultimo_pago, items, valor_concepto, valor_descuento, valor_ixm, valor_descuento_ixm, valor_gac, valor_descuento_gac, valor_abono, valor_saldo, creation_date, creation_user, negocio)
											VALUES (_cod_rop, _ConceptRec.id, _ConceptRec.descripcion, CarteraxCuotaSeguro.cuota, CarteraxCuotaSeguro.dias_vencidos, CarteraxCuotaSeguro.fecha_factura, CarteraxCuotaSeguro.fecha_vencimiento,'',1, _Base, 0, _IxM, 0, _GaC, _CxCta, 0, _Base+_IxM+_GaC-_CxCta, now(), usuario, NegocioSeguros.cod_neg);
										end if;
									end if;
								end if;

							END LOOP; --CarteraxCuotaSeguro

						END LOOP;

						SumTotalIxM = SumTotalIxM + _SumIxM;
						SumTotalGaC = SumTotalGaC + _SumGaC;

						--INGRESO DE LOS CONCEPTOS DE INTERES Y DE GASTOS DE COBRANZA EN TEMPORAL
						if ( _SumIxM > 0 ) then
							SELECT INTO _ValidarExistencia sum(vr_concepto) as SumSaldoIxm FROM tem.extracto_temp WHERE cod_rop = _cod_temp and id_concepto = id_concep_ixm;
							IF ( _ValidarExistencia > 0 ) THEN
								_ConsolidarConcepto = _ValidarExistencia + _SumIxM;
								UPDATE tem.extracto_temp SET vr_concepto = _ConsolidarConcepto, valor_saldo = _ConsolidarConcepto WHERE cod_rop = _cod_temp and id_concepto = id_concep_ixm;
							ELSE
								INSERT INTO tem.extracto_temp (cod_rop, id_concepto, concepto, vr_concepto, valor_ixm, valor_gac,negocio)
								VALUES (_cod_temp, id_concep_ixm, 'INTERES MORA',_SumIxM,_SumIxM,0, NegocioSeguros.cod_neg);
							END IF;


						end if;

						if ( _SumGaC > 0 ) then
							SELECT INTO _ValidarExistencia sum(vr_concepto) as SumSaldoGac FROM tem.extracto_temp WHERE cod_rop = _cod_temp and id_concepto = id_concep_gac;
							IF ( _ValidarExistencia > 0 ) THEN
								_ConsolidarConcepto = _ValidarExistencia + _SumGaC;
								UPDATE tem.extracto_temp SET vr_concepto = _ConsolidarConcepto, valor_saldo = _ConsolidarConcepto WHERE cod_rop = _cod_temp and id_concepto = id_concep_gac;
							ELSE
								INSERT INTO tem.extracto_temp (cod_rop, id_concepto, concepto, vr_concepto, valor_ixm, valor_gac,negocio)
								VALUES (_cod_temp, id_concep_gac, 'GASTOS DE COBRANZA',_SumGaC, 0, _SumGaC, NegocioSeguros.cod_neg);
							END IF;

						end if;

						--INGRESO DE LOS CONCEPTOS DE INTERES Y DE GASTOS DE COBRANZA EN DETALLE
						if(accion = 'Generar') then

							if ( _SumIxM > 0 ) then
								SELECT INTO _ValidarExistencia sum(valor_saldo) as SumSaldoIxm FROM detalle_rop WHERE id_rop = _cod_rop and id_conceptos_recaudo = id_concep_ixm;
								IF ( _ValidarExistencia > 0 ) THEN
									_ConsolidarConcepto = _ValidarExistencia + _SumIxM;
									UPDATE detalle_rop SET valor_concepto = _ConsolidarConcepto, valor_saldo = _ConsolidarConcepto WHERE id_rop = _cod_rop and id_conceptos_recaudo = id_concep_ixm;
								ELSE
									INSERT INTO detalle_rop (id_rop, id_conceptos_recaudo, descripcion, cuota, dias_vencidos, fecha_factura_padre, fecha_vencimiento_padre, fecha_ultimo_pago, items, valor_concepto, valor_descuento, valor_ixm, valor_descuento_ixm, valor_gac, valor_descuento_gac, valor_abono, valor_saldo, creation_date, creation_user, negocio)
									VALUES (_cod_rop, id_concep_ixm, 'INTERES MORA', 0, 0, '0099-01-01', '0099-01-01','',1, _SumIxM, 0, 0, 0, 0, 0, 0, _SumIxM, now(), usuario, NegocioSeguros.cod_neg);
								END IF;


							end if;

							if ( _SumGaC > 0 ) then
								SELECT INTO _ValidarExistencia sum(valor_saldo) as SumSaldoGac FROM detalle_rop WHERE id_rop = _cod_rop and id_conceptos_recaudo = id_concep_gac;
								IF ( _ValidarExistencia > 0 ) THEN
									_ConsolidarConcepto = _ValidarExistencia + _SumGaC;
									UPDATE detalle_rop SET valor_concepto = _ConsolidarConcepto, valor_saldo = _ConsolidarConcepto WHERE id_rop = _cod_rop and id_conceptos_recaudo = id_concep_gac;
								ELSE
									INSERT INTO detalle_rop (id_rop, id_conceptos_recaudo, descripcion, cuota, dias_vencidos, fecha_factura_padre, fecha_vencimiento_padre, fecha_ultimo_pago, items, valor_concepto, valor_descuento, valor_ixm, valor_descuento_ixm, valor_gac, valor_descuento_gac, valor_abono, valor_saldo, creation_date, creation_user, negocio)
									VALUES (_cod_rop, id_concep_gac, 'GASTOS DE COBRANZA', 0, 0, '0099-01-01', '0099-01-01','',1, _SumGaC, 0, 0, 0, 0, 0, 0, _SumGaC, now(), usuario, NegocioSeguros.cod_neg);
								END IF;

							end if;
						end if;

					END IF;

				END LOOP;


				--NEGOCIO DE GPS
				---------------------------------------------------------------------------------------------
				FOR NegocioGps IN

					--select * from negocios where negocio_rel_gps = CarteraxCliente.negasoc
					select *
					from negocios
					join recaudo.facturas_rop_duplicado on ( codigo_duplicado = CoDuplicado and negocio = negocios.cod_neg)
					where negocio_rel_gps = CarteraxCliente.negasoc

				LOOP
					_SumIxM = 0;
					_SumGaC = 0;

					raise notice 'Negocio Gps: %', NegocioGps.cod_neg;

					IF NegocioGps.cod_neg != '' THEN

						FOR CarteraxCabeceraCtaGps IN

							SELECT
								f.negasoc as negocio,
								f.documento,
								f.num_doc_fen as cuota,
								sum(f.valor_factura) as valor_factura,
								sum(f.valor_abono) as valor_abono,
								sum(f.valor_saldo) as valor_saldo,
								f.fecha_factura,
								f.fecha_vencimiento
							FROM 	con.factura  f
							WHERE   f.reg_status = ''
								and f.dstrct = 'FINV'
								and f.tipo_documento in ('FAC','NDC')
								and f.valor_saldo > 0
								and f.negasoc = NegocioGps.cod_neg
								and f.documento in (select documento from recaudo.facturas_rop_duplicado where codigo_duplicado = CoDuplicado and negocio = NegocioGps.cod_neg)
								and substring(f.documento,1,2) not in ('CP','FF')
								--and f.fecha_vencimiento::date <= now()::date
								and replace(substring(f.fecha_vencimiento,1,7),'-','') <= replace(substring(now()::date,1,7),'-','')
							GROUP BY f.num_doc_fen,f.negasoc ,f.fecha_factura,f.fecha_vencimiento,f.documento
							ORDER BY f.num_doc_fen

						LOOP

						raise notice 'CarteraxCuota.negocio: %', CarteraxCuota.negocio;
						raise notice 'CarteraxCuota.cuota: %', CarteraxCuota.cuota;

							BolsaSaldo = CarteraxCabeceraCtaGps.valor_abono;

							FOR CarteraxCuotaGps IN

								SELECT negocio, cedula, prefijo, cuota, fecha_factura, fecha_vencimiento, sum(valor_saldo) as valor_saldo, (fecha_corte-fecha_vencimiento::DATE) AS dias_vencidos FROM (

									SELECT
										f.negasoc as negocio,
										f.nit AS cedula,
										f.documento,
										fr.descripcion as prefijo,  --substring(f.documento,1,2) as prefijo,
										f.num_doc_fen as cuota,
										f.fecha_factura,
										f.fecha_vencimiento,
										fr.valor_unitario as valor_saldo
									FROM con.factura, con.factura_detalle fr
									WHERE   f.documento = fr.documento
										and f.reg_status = ''
										and f.dstrct = 'FINV'
										and f.tipo_documento in ('FAC','NDC')
										and fr.reg_status = ''
										and fr.dstrct = 'FINV'
										and fr.tipo_documento in ('FAC','NDC')
										and f.valor_saldo > 0
										and f.negasoc = CarteraxCabeceraCtaGps.negocio
										and f.documento = CarteraxCabeceraCtaGps.documento
										--and f.fecha_vencimiento::date <= now()::date
										and replace(substring(f.fecha_vencimiento,1,7),'-','') <= replace(substring(now()::date,1,7),'-','')
										and substring(f.documento,1,2) not in ('CP','FF')
									) as c
								GROUP BY negocio, cedula, prefijo, cuota, fecha_vencimiento, fecha_factura, dias_vencidos
								ORDER BY prefijo DESC --cuota::numeric
							LOOP

								_IxM = 0;
								_CxCta = 0;
								_Base = 0;
								_GaC = 0;
								_ValidarExistencia = 0;

								-----------------------------------------------------------------------------------------------------------------------
								VerifyDetails = 'N';
								Diferencia = BolsaSaldo - CarteraxCuotaGps.valor_saldo; --valor_unitario

								raise notice 'Negocio: %, Cuota: %, BolsaSaldo: %, valor_saldo: %',CarteraxCuotaGps.negocio, CarteraxCuotaGps.cuota, BolsaSaldo, CarteraxCuotaGps.valor_saldo;
								/*
								if ( Diferencia <= 0 and BolsaSaldo > 0) then

									_Base = CarteraxCuotaGps.valor_saldo - BolsaSaldo;
									BolsaSaldo = 0;

								elsif ( Diferencia > 0 and BolsaSaldo > 0 ) then

									_Base = 0;
									BolsaSaldo = BolsaSaldo - CarteraxCuotaGps.valor_saldo;

								elsif ( BolsaSaldo <= 0 ) then

									_Base = CarteraxCuotaGps.valor_saldo;

								end if;*/


								if ( BolsaSaldo > 0 and Diferencia > 0 ) then

									raise notice 'A';
									_Base = CarteraxCuotaGps.valor_saldo;
									BolsaSaldo = BolsaSaldo - CarteraxCuotaGps.valor_saldo;

								elsif ( BolsaSaldo > 0 and Diferencia <= 0) then

									raise notice 'B';
									_Base = CarteraxCuotaGps.valor_saldo;
									BolsaSaldo = 0;

								end if;

								-----------------------------------------------------------------------------------------------------------------------
								if ( _Base > 0 ) then

									raise notice 'Negocio: % Cuota: % _Base: %',CarteraxCuotaGps.negocio, CarteraxCuotaGps.cuota,_Base;

									--SUMA DE BASES
									_SumBase = _SumBase + _Base;

									--Conceptos
									SELECT INTO _ConceptRec * FROM conceptos_recaudo WHERE prefijo = CarteraxCuotaGps.prefijo AND CarteraxCuotaGps.dias_vencidos BETWEEN dias_rango_ini AND dias_rango_fin and id_unidad_negocio = und_negocio;

									IF FOUND THEN

										--Sanciones
										FOR _Sancion IN SELECT * FROM sanciones_condonaciones WHERE id_tipo_acto = 1 AND id_conceptos_recaudo = _ConceptRec.id AND CarteraxCuotaGps.dias_vencidos BETWEEN dias_rango_ini AND dias_rango_fin AND periodo = periodo_corriente and id_unidad_negocio = und_negocio LOOP

											IF ( _Sancion.categoria = 'IXM' ) THEN

												if ( fecha_corte > CarteraxCuotaGps.fecha_vencimiento::date ) then

													select into _Tasa tasa_usura/100 from convenios where id_convenio = CarteraxCliente.id_convenio;

													_IxM = ROUND( _Base*(_Tasa/30) * (fecha_corte - CarteraxCuotaGps.fecha_vencimiento)::numeric );
													_SumIxM = _SumIxM + _IxM;
												end if;

											END IF;

											IF ( _Sancion.categoria = 'GAC' ) THEN

												if ( fecha_corte > CarteraxCuotaGps.fecha_vencimiento::date ) then
													_GaC = ROUND((_Base * _Sancion.porcentaje::numeric)/100);
													_SumGaC = _SumGaC + _GaC;
												end if;

											END IF;

										END LOOP; --_Sancion

										--detalle_extracto
										if(_ConceptRec.descripcion in ('CAPITAL CORRIENTE','AVAL CORRIENTE','REMESA CORRIENTE')) then
											_SumCapitalCte = _SumCapitalCte + _Base;
											_SumCapital = _SumCapital + _Base;
										elsif (_ConceptRec.descripcion in ('CAPITAL VENCIDO','AVAL VENCIDO','REMESA VENCIDO')) then
											_SumCapitanVenc = _SumCapitanVenc + _Base;
											_SumCapital = _SumCapital + _Base;
										elsif (_ConceptRec.descripcion = 'INTERES CORRIENTE') then
											_SumIntCte = _SumIntCte + _Base;
										elsif (_ConceptRec.descripcion = 'INTERES VENCIDO') then
											_SumIntVencido = _SumIntVencido + _Base;
										end if;

										insert into tem.extracto_temp (cod_rop,id_concepto,concepto,fecha_venc_padre,vr_concepto,negocio) values (_cod_temp,_ConceptRec.id,_ConceptRec.descripcion,CarteraxCuota.fecha_factura,_Base,NegocioGps.cod_neg);

										if(accion = 'Generar') then
											INSERT INTO detalle_rop (id_rop, id_conceptos_recaudo, descripcion, cuota, dias_vencidos, fecha_factura_padre, fecha_vencimiento_padre, fecha_ultimo_pago, items, valor_concepto, valor_descuento, valor_ixm, valor_descuento_ixm, valor_gac, valor_descuento_gac, valor_abono, valor_saldo, creation_date, creation_user, negocio)
											VALUES (_cod_rop, _ConceptRec.id, _ConceptRec.descripcion, CarteraxCuotaGps.cuota, CarteraxCuotaGps.dias_vencidos, CarteraxCuotaGps.fecha_factura, CarteraxCuotaGps.fecha_vencimiento,'',1, _Base, 0, _IxM, 0, _GaC, _CxCta, 0, _Base+_IxM+_GaC-_CxCta, now(), usuario, NegocioGps.cod_neg);
										end if;
									end if;

								end if;

							END LOOP; --CarteraxCuotaGps

							SumTotalIxM = SumTotalIxM + _SumIxM;
							SumTotalGaC = SumTotalGaC + _SumGaC;

							--INGRESO DE LOS CONCEPTOS DE INTERES Y DE GASTOS DE COBRANZA EN TEMPORAL
							if ( _SumIxM > 0 ) then

								SELECT INTO _ValidarExistencia sum(vr_concepto) as SumSaldoIxm FROM tem.extracto_temp WHERE cod_rop = _cod_temp and id_concepto = id_concep_ixm;
								IF ( _ValidarExistencia > 0 ) THEN
									_ConsolidarConcepto = _ValidarExistencia + _SumIxM;
									UPDATE tem.extracto_temp SET vr_concepto = _ConsolidarConcepto, valor_saldo = _ConsolidarConcepto WHERE cod_rop = _cod_temp and id_concepto = id_concep_ixm;
								ELSE
									 INSERT INTO tem.extracto_temp (cod_rop, id_concepto, concepto, vr_concepto, valor_ixm, valor_gac,negocio)
									VALUES (_cod_temp, id_concep_ixm, 'INTERES MORA',_SumIxM,_SumIxM,0, NegocioGps.cod_neg);
								END IF;


							end if;

							if ( _SumGaC > 0 ) then

								SELECT INTO _ValidarExistencia sum(vr_concepto) as SumSaldoIxm FROM tem.extracto_temp WHERE cod_rop = _cod_temp and id_concepto = id_concep_gac;
								IF ( _ValidarExistencia > 0 ) THEN
									_ConsolidarConcepto = _ValidarExistencia + _SumGaC;
									UPDATE tem.extracto_temp SET vr_concepto = _ConsolidarConcepto, valor_saldo = _ConsolidarConcepto WHERE cod_rop = _cod_temp and id_concepto = id_concep_gac;
								ELSE
									 INSERT INTO tem.extracto_temp (cod_rop, id_concepto, concepto, vr_concepto, valor_ixm, valor_gac,negocio)
									VALUES (_cod_temp, id_concep_gac, 'GASTOS DE COBRANZA',_SumGaC, 0, _SumGaC, NegocioGps.cod_neg);
								END IF;

							end if;

							--INGRESO DE LOS CONCEPTOS DE INTERES Y DE GASTOS DE COBRANZA EN DETALLE
							if(accion = 'Generar') then

								if ( _SumIxM > 0 ) then

									SELECT INTO _ValidarExistencia sum(valor_saldo) as SumSaldoIxm FROM detalle_rop WHERE id_rop = _cod_rop and id_conceptos_recaudo = id_concep_ixm;
									IF ( _ValidarExistencia > 0 ) THEN
										_ConsolidarConcepto = _ValidarExistencia + _SumIxM;
										UPDATE detalle_rop SET valor_concepto = _ConsolidarConcepto, valor_saldo = _ConsolidarConcepto WHERE id_rop = _cod_rop and id_conceptos_recaudo = id_concep_ixm;
									ELSE
										INSERT INTO detalle_rop (id_rop, id_conceptos_recaudo, descripcion, cuota, dias_vencidos, fecha_factura_padre, fecha_vencimiento_padre, fecha_ultimo_pago, items, valor_concepto, valor_descuento, valor_ixm, valor_descuento_ixm, valor_gac, valor_descuento_gac, valor_abono, valor_saldo, creation_date, creation_user, negocio)
										VALUES (_cod_rop, id_concep_ixm, 'INTERES MORA', 0, 0, '0099-01-01', '0099-01-01','',1, _SumIxM, 0, 0, 0, 0, 0, 0, _SumIxM, now(), usuario, NegocioGps.cod_neg);
									END IF;


								end if;

								if ( _SumGaC > 0 ) then

									SELECT INTO _ValidarExistencia sum(valor_saldo) as SumSaldoGac FROM detalle_rop WHERE id_rop = _cod_rop and id_conceptos_recaudo = id_concep_gac;
									IF ( _ValidarExistencia > 0 ) THEN
										_ConsolidarConcepto = _ValidarExistencia + _SumGaC;
										UPDATE detalle_rop SET valor_concepto = _ConsolidarConcepto, valor_saldo = _ConsolidarConcepto WHERE id_rop = _cod_rop and id_conceptos_recaudo = id_concep_gac;
									ELSE
										INSERT INTO detalle_rop (id_rop, id_conceptos_recaudo, descripcion, cuota, dias_vencidos, fecha_factura_padre, fecha_vencimiento_padre, fecha_ultimo_pago, items, valor_concepto, valor_descuento, valor_ixm, valor_descuento_ixm, valor_gac, valor_descuento_gac, valor_abono, valor_saldo, creation_date, creation_user, negocio)
										VALUES (_cod_rop, id_concep_gac, 'GASTOS DE COBRANZA', 0, 0, '0099-01-01', '0099-01-01','',1, _SumGaC, 0, 0, 0, 0, 0, 0, _SumGaC, now(), usuario, NegocioGps.cod_neg);
									END IF;

								end if;
							end if;

						END LOOP;

					END IF;

				END LOOP;


			END IF;

		END IF;

		--CONDONACIONES
		_SumCxCta = 0;
		_SumDsctoCap = 0;
		_SumDsctoIxM = 0;
		_SumDsctoGxC = 0;
		_SumDsctoInt = 0;
		_SumDsctoSeguro = 0;

		/*
		PERFORM * FROM excepciones_condonacion WHERE negocio = CarteraxCliente.negasoc and periodo_condonacion = periodo_corriente;
		IF ( NOT FOUND ) THEN

			FOR _DetalleRopCondonar IN select id_concepto, (select categoria from conceptos_recaudo where id = et.id_concepto) as categoria ,sum(et.vr_concepto) as valor_concepto, min(et.fecha_venc_padre) from tem.extracto_temp et where cod_rop = _cod_temp group by id_concepto, categoria LOOP

				FOR _Condonacion IN SELECT * FROM sanciones_condonaciones WHERE id_tipo_acto = 2 AND aplicado_a = _DetalleRopCondonar.id_concepto AND CarteraxCliente.min_dias_ven BETWEEN dias_rango_ini AND dias_rango_fin AND periodo = periodo_corriente and id_unidad_negocio = und_negocio LOOP

					_CxCta = 0;
					_CxCta = ROUND((_DetalleRopCondonar.valor_concepto * _Condonacion.porcentaje::numeric)/100);

					if(accion = 'Generar') then
						INSERT INTO detalle_rop (id_rop, id_conceptos_recaudo, descripcion, cuota, dias_vencidos, fecha_factura_padre, fecha_vencimiento_padre, fecha_ultimo_pago, items, valor_concepto, valor_descuento, valor_ixm, valor_descuento_ixm, valor_gac, valor_descuento_gac, valor_abono, valor_saldo, creation_date, creation_user, negocio)
						VALUES (_cod_rop, _Condonacion.id_conceptos_recaudo, _Condonacion.descripcion, 0, 0, '0099-01-01', '0099-01-01','',1, _CxCta, 0, 0, 0, 0, 0, 0, _CxCta, now(), usuario, CarteraxCliente.negasoc);
					end if;

					_SumCxCta = _SumCxCta + _CxCta;

					if(_DetalleRopCondonar.categoria in ('CAP','AVA')) then
						_SumDsctoCap = _SumDsctoCap + _CxCta;
					elsif(_DetalleRopCondonar.categoria = 'SEG') then
						_SumDsctoSeguro = _SumDsctoSeguro + _CxCta;
					elsif (_DetalleRopCondonar.categoria = 'IXM') then
						_SumDsctoIxM = 	_SumDsctoIxM + _CxCta;
					elsif (_DetalleRopCondonar.categoria = 'GAC') then
						_SumDsctoGxC = _SumDsctoGxC + _CxCta;
					elsif (_DetalleRopCondonar.categoria = 'INT') then
						_SumDsctoInt = _SumDsctoInt + _CxCta;
					elsif (_DetalleRopCondonar.categoria = 'REM') then
						_SumDsctoCap = _SumDsctoCap + _CxCta;
					end if;

				END LOOP; --_Condonacion

			END LOOP; --_DetalleRopCondonar
		END IF;
		*/
		-----------------------------------------------------------------------------------------------------------------------------------------------------------------

		SELECT INTO ReglasDuplicado sum(valor_intxmora) as valor_intxmora, porcentaje_dscto_intxmora, sum(valor_gac) as valor_gac, porcentaje_dscto_gac FROM recaudo.facturas_rop_duplicado WHERE codigo_duplicado = CoDuplicado group by porcentaje_dscto_intxmora, porcentaje_dscto_gac;

		FOR _Condonacion IN SELECT * FROM conceptos_recaudo where categoria in ('DIXM','DGAC') and id_unidad_negocio = CarteraxCliente.id_unid_negocio LOOP

			_CxCta = 0;

			if ( ReglasDuplicado.porcentaje_dscto_intxmora != 0 and _Condonacion.categoria = 'DIXM' ) then

				_CxCta = ROUND((ReglasDuplicado.valor_intxmora * ReglasDuplicado.porcentaje_dscto_intxmora::numeric)/100);

				if(accion = 'Generar') then
					INSERT INTO detalle_rop (id_rop, id_conceptos_recaudo, descripcion, cuota, dias_vencidos, fecha_factura_padre, fecha_vencimiento_padre, fecha_ultimo_pago, items, valor_concepto, valor_descuento, valor_ixm, valor_descuento_ixm, valor_gac, valor_descuento_gac, valor_abono, valor_saldo, creation_date, creation_user, negocio)
					VALUES (_cod_rop, _Condonacion.id, _Condonacion.descripcion, 0, 0, '0099-01-01', '0099-01-01','',1, _CxCta, 0, 0, 0, 0, 0, 0, _CxCta, now(), usuario, CarteraxCliente.negasoc);
				end if;

				_SumCxCta = _SumCxCta + _CxCta;
				_SumDsctoIxM = 	_SumDsctoIxM + _CxCta;

			end if;

			if ( ReglasDuplicado.porcentaje_dscto_gac != 0 and _Condonacion.categoria = 'DGAC') then

				_CxCta = ROUND((ReglasDuplicado.valor_gac * ReglasDuplicado.porcentaje_dscto_gac::numeric)/100);

				if(accion = 'Generar') then
					INSERT INTO detalle_rop (id_rop, id_conceptos_recaudo, descripcion, cuota, dias_vencidos, fecha_factura_padre, fecha_vencimiento_padre, fecha_ultimo_pago, items, valor_concepto, valor_descuento, valor_ixm, valor_descuento_ixm, valor_gac, valor_descuento_gac, valor_abono, valor_saldo, creation_date, creation_user, negocio)
					VALUES (_cod_rop, _Condonacion.id, _Condonacion.descripcion, 0, 0, '0099-01-01', '0099-01-01','',1, _CxCta, 0, 0, 0, 0, 0, 0, _CxCta, now(), usuario, CarteraxCliente.negasoc);
				end if;

				_SumCxCta = _SumCxCta + _CxCta;
				_SumDsctoGxC = _SumDsctoGxC + _CxCta;

			end if;
		END LOOP;

		-----------------------------------------------------------------------------------------------------------------------------------------------------------------


		--INFORMACION DEL CLIENTE
		select into ClienteRec * from nit where cedula = CarteraxCliente.nit;
		select into _nomCiudad nomciu from ciudad where codciu = ClienteRec.codciu;
		select into _Dpto department_name from estado where department_code = ClienteRec.coddpto;

		Mensaje := '';
		MsgPagueseAntes := '';
		MsgEstadoCredito := '';

		--MENSAJE
		if ( _TotalCuotasPendientes.maxdia <= 0 ) then
			Mensaje := '¡Felicitaciones! | Su pago oportuno lo perfila como un buen | CLIENTE';
			MsgEstadoCredito := 'AL DIA';

			MsgPagueseAntes = (select max(fecha_vencimiento) from con.factura where negasoc = CarteraxCliente.negasoc and valor_saldo > 0 and fecha_vencimiento <= now()::date /*periodo_lote = periodo_corriente and num_ciclo = ciclo and replace(substring(fecha_vencimiento,1,7),'-','')::numeric = periodo_corriente*/);

			if ( MsgPagueseAntes is null ) then
				MsgPagueseAntes = (select max(fecha_vencimiento) from con.factura where negasoc = CarteraxCliente.negasoc and valor_saldo > 0 );
			end if;

		elsif ( _TotalCuotasPendientes.maxdia >= 1 and _TotalCuotasPendientes.maxdia <= 11 ) then

			Mensaje := '¡Lo invita a normalizar tu obligación y gozar | de los beneficios de un buen | BUEN CLIENTE ';
			MsgPagueseAntes := 'INMEDIATO';
			MsgEstadoCredito := 'VENCIDO';

		elsif ( _TotalCuotasPendientes.maxdia >= 12 ) then

			Mensaje := '¡Ponte al día con tu crédito y evita costos que incrementen el valor de la cuota! | ¡Fintra sigue creyendo en Ti! ';
			MsgPagueseAntes := 'INMEDIATO';
			MsgEstadoCredito := 'VENCIDO';
		end if;

		--_CtasPentesFaltantes = _TotalCuotasPendientes.CtasPendientes + _TotalCuotasFaltantes;
		_TotalSumCxCta = _TotalSumCxCta + _SumCxCta;

		if(accion = 'Generar') then
			--ACTUALIZA CABECERA DEL EXTRACTO.
			select into CodRop OVERLAY('EXT0000000' PLACING _cod_rop FROM 11 - length(_cod_rop) FOR length(_cod_rop));

			UPDATE
				recibo_oficial_pago
			SET
				cod_rop = CodRop,
				cedula = CarteraxCliente.nit,
				nombre_cliente = ClienteRec.nombre,
				direccion = ClienteRec.direccion,
				ciudad = ClienteRec.codciu,
				fecha_ultimo_pago = FechaCalculoInteres,
				cuotas_vencidas = CarteraxCliente.total_cuotas_vencidas,
				cuotas_pendientes = _TotalCuotasFaltantes||' de '||_TotalCuotas,
				dias_vencidos = _TotalCuotasPendientes.maxdia,
				subtotal = ROUND(_SumCapital + _SumCuotaManejo + _SumIntCte + _SumIntVencido + SumTotalIxM + SumTotalGac),
				total_sanciones = ROUND(SumTotalIxM + SumTotalGac),
				total_descuentos = ROUND(_SumDsctoCap + _SumDsctoSeguro + _SumDsctoInt + _SumDsctoIxM + _SumDsctoGxC),
				total = ROUND(_SumCapital + _SumCuotaManejo + _SumIntCte + _SumIntVencido + SumTotalIxM + SumTotalGac - _TotalSumCxCta),
				total_abonos = 0,
				observacion = Mensaje,
				msg_paguese_antes = MsgPagueseAntes,
				msg_estado_credito = MsgEstadoCredito
			WHERE id = _cod_rop;
		end if;

		raise notice '_SumCuotaManejo: %', _SumCuotaManejo;

		CarteraxCliente.linea_producto = und_neg;
		CarteraxCliente.nom_cli = ClienteRec.nombre;
		CarteraxCliente.direccion = ClienteRec.direccion;
		CarteraxCliente.barrio = ClienteRec.barrio;
		CarteraxCliente.ciudad = _nomCiudad;
		CarteraxCliente.departamento = _Dpto;
		CarteraxCliente.fecha_ultimo_pago = FechaCalculoInteres;
		CarteraxCliente.cuotas_pendientes = _TotalCuotasFaltantes||' de '||_TotalCuotas;
		CarteraxCliente.min_dias_ven = _TotalCuotasPendientes.maxdia;
		CarteraxCliente.capital = _SumCapital + _SumCuotaManejo; --*
		CarteraxCliente.int_cte = _SumIntCte + _SumIntVencido;
		CarteraxCliente.int_mora = SumTotalIxM;
		CarteraxCliente.gxc = SumTotalGac;
		CarteraxCliente.dscto_cap = ROUND(_SumDsctoCap);
		CarteraxCliente.dscto_seguro = ROUND(_SumDsctoSeguro);
		CarteraxCliente.dscto_int_cte = ROUND(_SumDsctoInt);
		CarteraxCliente.dscto_int_mora = ROUND(_SumDsctoIxM);
		CarteraxCliente.dscto_gxc = ROUND(_SumDsctoGxC);
		CarteraxCliente.subtotal_corriente = _SumCapitalCte + _SumIntCte;
		CarteraxCliente.subtotal_vencido = _SumCapitanVenc + _SumIntVencido;
		CarteraxCliente.subtotal_det = ROUND(_SumCapital  + _SumCuotaManejo + _SumIntCte + _SumIntVencido + SumTotalIxM + SumTotalGac); --*
		CarteraxCliente.subtotalneto = ROUND(_SumCapitalCte  + _SumCuotaManejo + _SumCapitanVenc + _SumIntCte + _SumIntVencido + SumTotalIxM + SumTotalGac);  --*
		CarteraxCliente.total_det = ROUND(_SumCapital + _SumIntCte + _SumIntVencido + SumTotalIxM + SumTotalGac - _TotalSumCxCta);
		CarteraxCliente.total_sanciones = ROUND(SumTotalIxM + SumTotalGac);
		CarteraxCliente.total_descuento = ROUND(_SumDsctoCap + _SumDsctoSeguro + _SumDsctoInt + _SumDsctoIxM + _SumDsctoGxC);
		CarteraxCliente.descuentos = ROUND(_SumDsctoCap + _SumDsctoSeguro + _SumDsctoInt + _SumDsctoIxM + _SumDsctoGxC);
		CarteraxCliente.total = ROUND(_SumCapital  + _SumCuotaManejo +_SumIntCte + _SumIntVencido + SumTotalIxM + SumTotalGac - _TotalSumCxCta); --*
		CarteraxCliente.observaciones = Mensaje;
		CarteraxCliente.msg_paguese_antes = MsgPagueseAntes;
		CarteraxCliente.msg_estado = MsgEstadoCredito;

		if(accion = 'Generar') then
			-- ACTUALIZA LOS NEGOCIOS EN: 'S' PARA QUE NO SEAN GENERADOS NUEVAMENTE
			UPDATE extractos_generados
			SET generado = 'S'
			WHERE cod_neg = CarteraxCliente.negasoc
			and periodo = periodo_corriente
			and num_ciclo = CarteraxCliente.num_ciclo
			and unidad_negocio =  und_negocio;

			update recaudo.facturas_rop_duplicado set rop_generado = 'S' where codigo_duplicado = CoDuplicado;


		end if;
		RAISE NOTICE 'ENTRA ESTA MONDA';
		--RETURN NEXT CarteraxCliente;
		RETURN retorno; --Descomente para que generar el duplicado correcto cuando el negocio tiene aval

	END LOOP; --CarteraxCliente

  	--RETURN retorno; --Comente este porque generaba el duplicado unicamente del aval.
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_extractoduplicado_fenalco(character varying, character varying)
  OWNER TO postgres;
