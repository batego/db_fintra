-- Function: sp_extractoduplicado_micro(character varying, character varying)

-- DROP FUNCTION sp_extractoduplicado_micro(character varying, character varying);

CREATE OR REPLACE FUNCTION sp_extractoduplicado_micro(usuario character varying, coduplicado character varying)
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
	ClienteRec record;
	_nomCiudad varchar;
	_Dpto varchar;
	vencimiento_mayor varchar;
	_ConceptRec record;
	_Sancion record;
	_DetalleRopCondonar record;
	_Condonacion record;
	FchLastPay record;
	_TotalCuotasPendientes record;
	CodRop varchar;
	_cod_rop numeric;
	_cod_temp numeric;
	_Base numeric;
	_IxM numeric;
	_GaC numeric;
	_CxCta numeric;
	_Tasa numeric;
	_SumCapital numeric;
	_SumIntCte numeric;
	_SumCat numeric;
	_SumDsctoCap numeric;
	_SumDsctoCat numeric;
	_SumDsctoIxM numeric;
	_SumDsctoGxC numeric;
	_SumDsctoInt numeric;
	_SumCapitalVenc numeric;
	_SumCapitalCte numeric;
	_SumIntVencido numeric;
	_SumInteresCte numeric;
	id_concep_ixm numeric;
	id_concep_gac numeric;

	ReglasDuplicado record;
	und_negocio numeric;

	_TotalCuotas numeric;
	_TotalCuotasFaltantes numeric;
	_CtasPentesFaltantes numeric;
	_TotalCuotasVencidas numeric;

	_SumIxM numeric;
	_SumGaC numeric;
	_SumBase numeric;
	_SumCxCta numeric;

	FechaCalculoInteres date;
	fecha_corte date;
	UltimoDia varchar;
	FechaUltimoPago varchar;
	periodo_corriente varchar;

	_Int_mora record;
	_Int_gxc record;
	Ciclo record;

BEGIN
	DELETE FROM tem.extracto_temp;

	SELECT INTO UltimoDia * FROM sp_diasmes(now()::date);
	FechaUltimoPago = substring(now()::date,1,8)||UltimoDia;

	raise notice 'ultimo pago: %',FechaUltimoPago;

	fecha_corte = now()::date;
	periodo_corriente = replace(substring(now(),1,7),'-','');

	SQL = 'select
		'''||FechaUltimoPago||'''::date as vencimiento_rop,
		''''::varchar as venc_mayor,
		negocios.id_convenio::numeric, unidad.id_unid_negocio::integer, unidad.nombre_unid_negocio::varchar,
		f.negasoc::varchar, f.nit::varchar,
		negocios.num_ciclo::integer,
		''''::varchar as nom_cli,
		''''::varchar as direccion,
		''''::varchar as barrio,
		''''::varchar as ciudad,
		''''::varchar as departamento,
		''''::varchar as agencia,
		''''::varchar as linea_producto,
		0::numeric as total_cuotas_vencidas,
		''''::varchar as cuotas_pendientes,
		('''||fecha_corte||'''-min(fecha_vencimiento)::date)::numeric as min_dias_ven,
		null::date as fecha_ultimo_pago,
		0::numeric as subtotal_det,
		0::numeric as total_sanciones,
		0::numeric as total_dscto_det,
		0::numeric as total_det,
		0::numeric as total_abonos,
		''''::varchar as observaciones,
		''''::varchar as msg_paguese_antes,
		''''::varchar as msg_estado,
		0::numeric as capital,
		0::numeric as cat,
		0::numeric as int_cte,
		0::numeric as int_mora,
		0::numeric as gxc,
		0::numeric as dscto_cap,
		0::numeric as dscto_cat,
		0::numeric as dscto_int_cte,
		0::numeric as dscto_int_mora,
		0::numeric as dscto_gxc,
		0::numeric as subtotal_corriente,
		0::numeric as subtotal_vencido,
		0::numeric as subtotalneto,
		0::numeric as total_descuento,
		0::numeric as total
		FROM con.factura f, negocios
		inner join (select * from SP_NombreUnidadNegocio_all() as un(id_unid_negocio integer, nombre_unid_negocio varchar, id_convenio integer,ref_4 varchar)) unidad on (unidad.id_convenio=negocios.id_convenio)
		WHERE   f.negasoc = negocios.cod_neg
			and f.reg_status = ''''
			and f.dstrct = ''FINV''
			and f.tipo_documento = ''FAC''
			and f.valor_saldo > 0
			and substring(f.documento,1,2) in (''MC'')
			and negasoc in (select negocio from recaudo.facturas_rop_duplicado where codigo_duplicado = '''||CoDuplicado||''' and rop_generado = ''N'' group by negocio)
		GROUP BY negocios.id_convenio, unidad.id_unid_negocio, unidad.nombre_unid_negocio, f.negasoc, f.nit ,negocios.num_ciclo';

	raise notice 'SQL: %',SQL;

	FOR CarteraxCliente IN EXECUTE SQL LOOP

		SELECT INTO Ciclo * FROM con.ciclos_facturacion WHERE periodo = periodo_corriente AND num_ciclo = CarteraxCliente.num_ciclo;
		raise notice 'ciclo: %',Ciclo.id;

		SELECT INTO _TotalCuotas count(0) as totalCuotas from documentos_neg_aceptado where cod_neg = CarteraxCliente.negasoc;
		SELECT INTO _TotalCuotasVencidas count(0) as CtasVencidas from con.factura where reg_status = '' and dstrct = 'FINV' and tipo_documento = 'FAC' and negasoc = CarteraxCliente.negasoc and valor_saldo > 0 and fecha_vencimiento < now()::date and substring(documento,1,2) = 'MC' and substring(documento,1,2) != 'CP';
		SELECT INTO _TotalCuotasPendientes count(0) as CtasPendientes, max(fecha_corte-(fecha_vencimiento)) as maxdia from con.factura where reg_status = '' and dstrct = 'FINV' and tipo_documento = 'FAC' and negasoc = CarteraxCliente.negasoc and valor_saldo > 0 and substring(documento,1,2) = 'MC' and fecha_vencimiento <= now()::date;
		SELECT INTO _TotalCuotasFaltantes count(0) as CtasFaltantes from con.factura where reg_status = '' and dstrct = 'FINV' and tipo_documento = 'FAC' and negasoc = CarteraxCliente.negasoc and valor_saldo > 0 and fecha_vencimiento > now()::date and substring(documento,1,2) = 'MC' and substring(documento,1,2) != 'CP';

		CarteraxCliente.total_cuotas_vencidas = _TotalCuotasVencidas;
		--_CtasPentesFaltantes = _TotalCuotasPendientes.CtasPendientes + _TotalCuotasFaltantes;

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
			--AND fra.fecha_vencimiento::date <= now()::date
			AND replace(substring(fra.fecha_vencimiento,1,7),'-','')::numeric <= replace(substring(now(),1,7),'-','')::numeric
		 GROUP BY negasoc

		) vencimiento;


		SELECT INTO und_neg descripcion from unidad_negocio where id = und_negocio;

		raise notice 'negocio: % _TotalCuotas: %',CarteraxCliente.negasoc,_TotalCuotas;

		SELECT INTO _cod_temp nextval('tem.extracto_temp_seq');

		if(accion = 'Generar') then
			--CREACION CABECERA DEL EXTRACTO
			INSERT INTO recibo_oficial_pago (cod_rop, id_unidad_negocio, periodo_rop, id_ciclo, vencimiento_rop, negocio, cuotas_vencidas, cuotas_pendientes,
							dias_vencidos, subtotal, total_sanciones, total_descuentos, total, total_abonos, creation_date, creation_user,
							last_update, user_update, observacion, duplicado)
			  VALUES('',1,periodo_corriente,Ciclo.id,CarteraxCliente.vencimiento_rop,CarteraxCliente.negasoc,'0','0/0','0',0,0,0,0,0,now(),usuario,now(),usuario,'','S')
			RETURNING id INTO _cod_rop;
			retorno = _cod_rop;

		end if;

		raise notice 'Cod_Rop: %',_cod_rop;

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
		_SumInteresCte = 0;
		_SumCat = 0;
		_SumCapitalVenc = 0;
		_SumCapitalCte = 0;
		Mensaje = '';
		id_concep_ixm = 0;
		id_concep_gac = 0;

		FOR CarteraxCuota IN

			SELECT negocio, cedula, prefijo, cuota, fecha_factura, fecha_vencimiento, sum(valor_saldo) as valor_saldo, (fecha_corte::date-fecha_vencimiento::DATE) AS dias_vencidos FROM (

				SELECT
					f.negasoc as negocio,
					f.nit AS cedula,
					f.documento,
					substring(f.documento,1,2) as prefijo,
					f.num_doc_fen as cuota,
					case when substring(f.documento,1,2) in ('MC','R0') then f.fecha_factura else (select fecha_factura from con.factura mf where mf.documento = (select numero_remesa from con.factura_detalle where documento = f.documento limit 1)) end as fecha_factura,
					case when substring(f.documento,1,2) in ('MC','R0') then f.fecha_vencimiento else (select fecha_vencimiento from con.factura mf where mf.documento = (select numero_remesa from con.factura_detalle where documento = f.documento limit 1)) end as fecha_vencimiento,
					f.valor_saldo
				FROM con.factura f
				WHERE f.reg_status = ''
					and f.dstrct = 'FINV'
					and f.tipo_documento = 'FAC'
					and f.valor_saldo > 0
					and substring(f.documento,1,2) in ('MC','MI','CA','R0')
					and f.negasoc = CarteraxCliente.negasoc
					--and f.fecha_vencimiento::date <= now()::date
					and replace(substring(f.fecha_vencimiento,1,7),'-','') <= replace(substring(now()::date,1,7),'-','')
					and f.documento in (select documento from con.factura where negasoc = CarteraxCliente.negasoc and num_doc_fen in (select cuota from recaudo.facturas_rop_duplicado where codigo_duplicado = CoDuplicado and negocio = CarteraxCliente.negasoc))
				) as c
			GROUP BY negocio, cedula, prefijo, cuota, fecha_vencimiento, fecha_factura, dias_vencidos
			ORDER BY cuota::numeric


		LOOP
			_IxM = 0;
			_CxCta = 0;
			_Base = 0;
			_GaC = 0;
			IF (CarteraxCuota.prefijo IN ('MC','R0')) THEN
				_SumCapital = _SumCapital + CarteraxCuota.valor_saldo;
			ELSIF (CarteraxCuota.prefijo = 'MI') THEN
				_SumIntCte = _SumIntCte + CarteraxCuota.valor_saldo;
			ELSE
				_SumCat = _SumCat + CarteraxCuota.valor_saldo;
			END IF;

			--BASES
			if ( fecha_corte < CarteraxCuota.fecha_vencimiento::date ) then
				_Base = CarteraxCuota.valor_saldo;
			else
				_Base = CarteraxCuota.valor_saldo;
			end if;

			--SUMA DE BASES
			_SumBase = _SumBase + _Base;

			--Conceptos
			SELECT INTO _ConceptRec id,descripcion FROM conceptos_recaudo WHERE prefijo = CarteraxCuota.prefijo AND CarteraxCuota.dias_vencidos BETWEEN dias_rango_ini AND dias_rango_fin and id_unidad_negocio = 1;

			FOR _Sancion IN

				SELECT categoria, porcentaje FROM sanciones_condonaciones WHERE id_tipo_acto = 1 AND id_conceptos_recaudo = _ConceptRec.id AND CarteraxCuota.dias_vencidos BETWEEN dias_rango_ini AND dias_rango_fin AND periodo = periodo_corriente and id_unidad_negocio = 1
			LOOP

				IF ( _Sancion.categoria = 'IXM' ) THEN

					if ( fecha_corte > CarteraxCuota.fecha_vencimiento::date ) then

						select into _Tasa tasa_interes/100 from convenios where id_convenio = CarteraxCliente.id_convenio;

						_IxM = ROUND( _Base*(_Tasa/30) * (fecha_corte - CarteraxCuota.fecha_vencimiento)::numeric );
						_SumIxM = _SumIxM + _IxM;
						raise notice 'ixm: %',_IxM;
					end if;

				ELSIF ( _Sancion.categoria = 'GAC' ) THEN

					if ( fecha_corte > CarteraxCuota.fecha_vencimiento::date ) then
						_GaC = ROUND((_Base * _Sancion.porcentaje::numeric)/100);
						_SumGaC = _SumGaC + _GaC;
					end if;

				END IF;

			END LOOP; --_Sancion

			--detalle_extracto
			if(_ConceptRec.descripcion = 'CAPITAL CORRIENTE') then
				_SumCapitalCte = _SumCapitalCte + _Base;
			elsif (_ConceptRec.descripcion = 'CAPITAL VENCIDO') then
				_SumCapitalVenc = _SumCapitalVenc + _Base;
			elsif (_ConceptRec.descripcion = 'INTERES CORRIENTE') then
				_SumInteresCte = _SumInteresCte + _Base;
			elsif (_ConceptRec.descripcion = 'INTERES VENCIDO') then
				_SumIntVencido = _SumIntVencido + _Base;
			end if;

			RAISE NOTICE 'CONCEPTO: % _Base: % CarteraxCuota.prefijo: % _ConceptRec.id: % CarteraxCuota.dias_vencidos: %',_ConceptRec.descripcion,_Base,CarteraxCuota.prefijo,_ConceptRec.id,CarteraxCuota.dias_vencidos;
			insert into tem.extracto_temp (cod_rop,id_concepto,concepto,fecha_venc_padre,vr_concepto) values (_cod_temp,_ConceptRec.id,_ConceptRec.descripcion,CarteraxCuota.fecha_factura,_Base);

			if(accion = 'Generar') then
				INSERT INTO detalle_rop (id_rop, id_conceptos_recaudo, descripcion, cuota, dias_vencidos, fecha_factura_padre, fecha_vencimiento_padre, fecha_ultimo_pago, items, valor_concepto, valor_descuento, valor_ixm, valor_descuento_ixm, valor_gac, valor_descuento_gac, valor_abono, valor_saldo, creation_date, creation_user, negocio)
				VALUES (_cod_rop, _ConceptRec.id, _ConceptRec.descripcion, CarteraxCuota.cuota, CarteraxCuota.dias_vencidos, CarteraxCuota.fecha_factura, CarteraxCuota.fecha_vencimiento,'',1, _Base, 0, _IxM, 0, _GaC, _CxCta, 0, _Base+_IxM+_GaC-_CxCta, now(), usuario, CarteraxCliente.negasoc);
			end if;

		END LOOP; --CarteraxCuota

		CarteraxCliente.capital = _SumCapital;
		CarteraxCliente.int_cte = _SumIntCte;
		CarteraxCliente.cat = _SumCat;
		CarteraxCliente.int_mora = _SumIxM;
		CarteraxCliente.gxc = _SumGaC;

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
			INSERT INTO detalle_rop (id_rop, id_conceptos_recaudo, descripcion, cuota, dias_vencidos, fecha_factura_padre, fecha_vencimiento_padre, fecha_ultimo_pago, items, valor_concepto, valor_descuento, valor_ixm, valor_descuento_ixm, valor_gac, valor_descuento_gac, valor_abono, valor_saldo, creation_date, creation_user, negocio)
			VALUES (_cod_rop, id_concep_ixm, 'INTERES MORA', 0, 0, '0099-01-01', '0099-01-01','',1, _SumIxM, 0, 0, 0, 0, 0, 0, _SumIxM, now(), usuario, CarteraxCliente.negasoc);

			INSERT INTO detalle_rop (id_rop, id_conceptos_recaudo, descripcion, cuota, dias_vencidos, fecha_factura_padre, fecha_vencimiento_padre, fecha_ultimo_pago, items, valor_concepto, valor_descuento, valor_ixm, valor_descuento_ixm, valor_gac, valor_descuento_gac, valor_abono, valor_saldo, creation_date, creation_user, negocio)
			VALUES (_cod_rop, id_concep_gac, 'GASTOS DE COBRANZA', 0, 0, '0099-01-01', '0099-01-01','',1, _SumGaC, 0, 0, 0, 0, 0, 0, _SumGaC, now(), usuario, CarteraxCliente.negasoc);
		end if;


		--CONDONACIONES
		_SumCxCta = 0;
		_SumDsctoCap = 0;
		_SumDsctoCat = 0;
		_SumDsctoIxM = 0;
		_SumDsctoGxC = 0;
		_SumDsctoInt = 0;

		/*
		PERFORM * FROM excepciones_condonacion WHERE negocio = CarteraxCliente.negasoc and periodo_condonacion = periodo_corriente;
		IF ( NOT FOUND ) THEN

			FOR _DetalleRopCondonar IN select id_concepto, (select categoria from conceptos_recaudo where id = et.id_concepto) as categoria ,sum(et.vr_concepto) as valor_concepto, min(et.fecha_venc_padre) from tem.extracto_temp et where cod_rop = _cod_temp group by id_concepto, categoria LOOP

				FOR _Condonacion IN SELECT * FROM sanciones_condonaciones WHERE id_tipo_acto = 2 AND aplicado_a = _DetalleRopCondonar.id_concepto AND CarteraxCliente.min_dias_ven BETWEEN dias_rango_ini AND dias_rango_fin AND periodo = periodo_corriente and id_unidad_negocio = 1 LOOP

					_CxCta = 0;

					_CxCta = ROUND((_DetalleRopCondonar.valor_concepto * _Condonacion.porcentaje::numeric)/100);

					if(accion = 'Generar') then
						INSERT INTO detalle_rop (id_rop, id_conceptos_recaudo, descripcion, cuota, dias_vencidos, fecha_factura_padre, fecha_vencimiento_padre, fecha_ultimo_pago, items, valor_concepto, valor_descuento, valor_ixm, valor_descuento_ixm, valor_gac, valor_descuento_gac, valor_abono, valor_saldo, creation_date, creation_user, negocio)
						 VALUES (_cod_rop, _Condonacion.id_conceptos_recaudo, _Condonacion.descripcion, 0, 0, '0099-01-01', '0099-01-01','',1, _CxCta, 0, 0, 0, 0, 0, 0, _CxCta, now(), usuario, CarteraxCliente.negasoc);
					end if;

					_SumCxCta = _SumCxCta + _CxCta;

					if(_DetalleRopCondonar.categoria = 'CAP') then
						_SumDsctoCap = _SumDsctoCap + _CxCta;
					elsif (_DetalleRopCondonar.categoria = 'CAT') then
						_SumDsctoCat = _SumDsctoCat + _CxCta;
					elsif (_DetalleRopCondonar.categoria = 'IXM') then
						_SumDsctoIxM = 	_SumDsctoIxM + _CxCta;
					elsif (_DetalleRopCondonar.categoria = 'GAC') then
						_SumDsctoGxC = _SumDsctoGxC + _CxCta;
					elsif (_DetalleRopCondonar.categoria = 'INT') then
						_SumDsctoInt = _SumDsctoInt + _CxCta;
					end if;

				END LOOP; --_Condonacion

			END LOOP; --_DetalleRopCondonar
		END IF;
		*/
		-----------------------------------------------------------------------------------------------------------------------------------------------------------------
		raise notice 'id_unid_negocio: %',CarteraxCliente.id_unid_negocio;
		SELECT INTO ReglasDuplicado sum(valor_intxmora) as valor_intxmora, porcentaje_dscto_intxmora, sum(valor_gac) as valor_gac, porcentaje_dscto_gac FROM recaudo.facturas_rop_duplicado WHERE codigo_duplicado = CoDuplicado group by porcentaje_dscto_intxmora, porcentaje_dscto_gac;

		FOR _Condonacion IN SELECT * FROM conceptos_recaudo where categoria in ('DIXM','DGAC') and id_unidad_negocio = CarteraxCliente.id_unid_negocio LOOP

			_CxCta = 0;

			if ( ReglasDuplicado.porcentaje_dscto_intxmora != 0 and _Condonacion.categoria = 'DIXM' ) then

				--_CxCta = ROUND((_DetalleRopCondonar.valor_concepto * _Condonacion.porcentaje::numeric)/100);
				_CxCta = ROUND((ReglasDuplicado.valor_intxmora * ReglasDuplicado.porcentaje_dscto_intxmora::numeric)/100);

				if(accion = 'Generar') then
					INSERT INTO detalle_rop (id_rop, id_conceptos_recaudo, descripcion, cuota, dias_vencidos, fecha_factura_padre, fecha_vencimiento_padre, fecha_ultimo_pago, items, valor_concepto, valor_descuento, valor_ixm, valor_descuento_ixm, valor_gac, valor_descuento_gac, valor_abono, valor_saldo, creation_date, creation_user, negocio)
					VALUES (_cod_rop, _Condonacion.id, _Condonacion.descripcion, 0, 0, '0099-01-01', '0099-01-01','',1, _CxCta, 0, 0, 0, 0, 0, 0, _CxCta, now(), usuario, CarteraxCliente.negasoc);
				end if;

				_SumCxCta = _SumCxCta + _CxCta;
				_SumDsctoIxM = 	_SumDsctoIxM + _CxCta;

			end if;

			if ( ReglasDuplicado.porcentaje_dscto_gac != 0 and _Condonacion.categoria = 'DGAC' ) then

				--_CxCta = ROUND((_DetalleRopCondonar.valor_concepto * _Condonacion.porcentaje::numeric)/100);
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
		select into ClienteRec * from nit where cedula = CarteraxCuota.cedula;
		select into _nomCiudad nomciu from ciudad where codciu = ClienteRec.codciu;
		select into _Dpto department_name from estado where department_code = ClienteRec.coddpto;

		--MENSAJE
		Mensaje = '';
		MsgPagueseAntes = '';
		MsgEstadoCredito = '';
		if ( _TotalCuotasPendientes.maxdia <= 0 ) then
			Mensaje := '¡Felicitaciones! | Su pago oportuno lo perfila como un buen | CLIENTE';
			MsgEstadoCredito := 'AL DIA';
			MsgPagueseAntes = (select max(fecha_vencimiento) from con.factura where negasoc = CarteraxCliente.negasoc and valor_saldo > 0 and fecha_vencimiento::date <= now()::date);
				if ( MsgPagueseAntes is null ) then
					MsgPagueseAntes = (select max(fecha_vencimiento) from con.factura where negasoc = CarteraxCliente.negasoc and valor_saldo > 0);
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

		if(accion = 'Generar') then
			--ACTUALIZA CABECERA DEL EXTRACTO.
			select into CodRop OVERLAY('EXT0000000' PLACING _cod_rop FROM 11 - length(_cod_rop) FOR length(_cod_rop));

			UPDATE recibo_oficial_pago
			SET cod_rop = CodRop, cedula = CarteraxCuota.cedula, nombre_cliente = ClienteRec.nombre, direccion = ClienteRec.direccion, ciudad = ClienteRec.codciu, fecha_ultimo_pago = FechaCalculoInteres, cuotas_vencidas = CarteraxCliente.total_cuotas_vencidas, cuotas_pendientes = _TotalCuotasFaltantes||' de '||_TotalCuotas, dias_vencidos = _TotalCuotasPendientes.maxdia,
			    subtotal = ROUND(_SumBase+_SumIxM+_SumGaC), total_sanciones = ROUND(_SumIxM+_SumGaC), total_descuentos = ROUND(_SumCxCta), total = ROUND(_SumBase+_SumIxM+_SumGaC-_SumCxCta), total_abonos = 0, observacion = Mensaje, msg_paguese_antes = MsgPagueseAntes, msg_estado_credito = MsgEstadoCredito
			WHERE id = _cod_rop;

		end if;

		CarteraxCliente.agencia = 'BARRANQUILLA';
		CarteraxCliente.linea_producto = und_neg;
		CarteraxCliente.nom_cli = ClienteRec.nombre;
		CarteraxCliente.direccion = ClienteRec.direccion;
		CarteraxCliente.barrio = ClienteRec.barrio;
		CarteraxCliente.ciudad = _nomCiudad;
		CarteraxCliente.departamento = _Dpto;
		CarteraxCliente.fecha_ultimo_pago = FechaCalculoInteres;
		CarteraxCliente.venc_mayor = vencimiento_mayor;
		CarteraxCliente.cuotas_pendientes = _TotalCuotasFaltantes||' de '||_TotalCuotas;
		CarteraxCliente.min_dias_ven = _TotalCuotasPendientes.maxdia;
		CarteraxCliente.dscto_cap = ROUND(_SumDsctoCap);
		CarteraxCliente.dscto_cat = ROUND(_SumDsctoCat);
		CarteraxCliente.dscto_int_cte = ROUND(_SumDsctoInt);
		CarteraxCliente.dscto_int_mora = ROUND(_SumDsctoIxM);
		CarteraxCliente.dscto_gxc = ROUND(_SumDsctoGxC);
		CarteraxCliente.total_dscto_det = ROUND(_SumCxCta);
		CarteraxCliente.subtotal_corriente = ROUND(_SumCapitalCte + _SumInteresCte);
		CarteraxCliente.subtotal_vencido = ROUND(_SumCapitalVenc + _SumIntVencido);
		CarteraxCliente.subtotal_det = ROUND(_SumBase + _SumIxM +_SumGaC);
		CarteraxCliente.total_det = ROUND(_SumBase + _SumIxM +_SumGaC - _SumCxCta);
		CarteraxCliente.subtotalneto = ROUND(_SumBase+_SumIxM+_SumGaC);
		CarteraxCliente.total_sanciones = ROUND(_SumIxM+_SumGaC);
		CarteraxCliente.total_descuento = ROUND(_SumCxCta);
		CarteraxCliente.total = ROUND(_SumBase+_SumIxM+_SumGaC-_SumCxCta); --_SumDsctoCap + _SumDsctoCat + _SumDsctoIxM + _SumDsctoGxC +_SumDsctoInt
		CarteraxCliente.observaciones = Mensaje;
		CarteraxCliente.msg_paguese_antes = MsgPagueseAntes;
		CarteraxCliente.msg_estado = MsgEstadoCredito;

		if(accion = 'Generar') then
			--ACTUALIZA LOS NEGOCIOS EN: 'S' PARA QUE NO SEAN GENERADOS NUEVAMENTE
			UPDATE extractos_generados SET generado = 'S' WHERE cod_neg = CarteraxCliente.negasoc and periodo = periodo_corriente and num_ciclo = CarteraxCliente.num_ciclo and unidad_negocio =  und_negocio;
			update recaudo.facturas_rop_duplicado set rop_generado = 'S' where codigo_duplicado = CoDuplicado;
		end if;

		--RETURN NEXT CarteraxCliente;
		RETURN retorno;

	END LOOP; --CarteraxCliente

	raise notice 'FIN';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_extractoduplicado_micro(character varying, character varying)
  OWNER TO postgres;
