-- Function: sp_extractoeducativo(numeric, date, character varying, date, date)

-- DROP FUNCTION sp_extractoeducativo(numeric, date, character varying, date, date);

CREATE OR REPLACE FUNCTION sp_extractoeducativo(unidadneg numeric, fecha_hoy date, periodo_corriente character varying, vcto_rop date, pagar_antesde date)
  RETURNS text AS
$BODY$

DECLARE

	mcad TEXT;
	Mensaje TEXT;
	MsgPagueseAntes TEXT;
        MsgEstadoCredito TEXT;

	CarteraxCliente record;
	CarteraxCuota record;
	NegocioAvales record;
	NegocioSeguros record;
	ClienteRec record;
	--RecaudoxCuota record;
	_ConceptRec record;
	_Sancion record;
	_DetalleRopCondonar record;
	_Condonacion record;
	FchLastPay record;
	_TotalCuotasPendientes record;
	CarteraxCuotaAval record;
	CarteraxCuotaSeguro record;
	CarteraxCabeceraCta record;
	RsCodSanciones record;

	--IngresoxCuota numeric;
	_cod_rop numeric;
	_Current_codrop numeric;
	_Base numeric;
	_IxM numeric;
	_GaC numeric;
	_CxCta numeric;
	_Tasa numeric;
	BolsaSaldo numeric;
	Diferencia numeric;
	VlDetFactura numeric;


	_TotalCuotas numeric;
	_TotalCuotasFaltantes numeric;
	_CtasPentesFaltantes numeric;

	account integer;

	_SumIxM numeric;
	_SumGaC numeric;
	_SumBase numeric;
	_SumCxCta numeric;
	_SumDebidoCobrar numeric;

	CodRop varchar;
	--periodo_corriente varchar;
	VerifyDetails varchar;

	IntMora integer;
	GastCobranza integer;

	FechaCalculoInteres date;

BEGIN

	mcad = 'TERMINADO!';
	CodRop = '';
	IntMora = 0;
	GastCobranza = 0;

	--periodo_corriente = replace(substring(fecha_hoy,1,7),'-','');
	FOR RsCodSanciones IN select * from conceptos_recaudo where id_unidad_negocio = UnidadNeg and descripcion in ('INTERES MORA','GASTOS DE COBRANZA') order by 2,1 LOOP

		if ( RsCodSanciones.descripcion = 'INTERES MORA' ) then
			IntMora = RsCodSanciones.id::integer;
		elsif ( RsCodSanciones.descripcion = 'GASTOS DE COBRANZA' ) then
			GastCobranza = RsCodSanciones.id::integer;
		end if;

	END LOOP;

	FOR CarteraxCliente IN

		select id_convenio, negasoc, f.nit
		,count(0)-1 as total_cuotas_vencidas
		,(fecha_hoy-min(fecha_vencimiento)::DATE) as min_dias_ven
		FROM con.foto_cartera f
		WHERE f.reg_status = ''
			and f.dstrct = 'FINV'
			and f.tipo_documento in ('FAC','NDC')
			and f.id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio = UnidadNeg) --(17,19) --select * from convenios order by id_convenio 17,19/31
			and f.valor_saldo > 0
			and replace(substring(f.fecha_vencimiento,1,7),'-','')::numeric <= periodo_corriente::numeric
			and f.periodo_lote = periodo_corriente::numeric
			and substring(f.documento,1,2) not in ('CP','FF')
			--and f.negasoc = 'NG15999'
			group by id_convenio, negasoc, f.nit LOOP

			--SELECT INTO _TotalCuotas count(0) from con.foto_cartera where reg_status = '' and dstrct = 'FINV' and tipo_documento = 'FAC' and negasoc = CarteraxCliente.negasoc and id_convenio = CarteraxCliente.id_convenio and periodo_lote = periodo_corriente::numeric; --and replace(substring(fecha_vencimiento,1,7),'-','')::numeric <= periodo_corriente::numeric;
			SELECT INTO _TotalCuotas count(0) from documentos_neg_aceptado where cod_neg = CarteraxCliente.negasoc;
			SELECT INTO _TotalCuotasPendientes count(0) as CtasPendientes, max(fecha_hoy-(fecha_vencimiento)) as maxdia from con.foto_cartera where reg_status = '' and dstrct = 'FINV' and tipo_documento = 'FAC' and negasoc = CarteraxCliente.negasoc and id_convenio = CarteraxCliente.id_convenio and valor_saldo > 0 and periodo_lote = periodo_corriente::numeric and replace(substring(fecha_vencimiento,1,7),'-','')::numeric <= periodo_corriente::numeric and substring(documento,1,2) != 'CP';
			SELECT INTO _TotalCuotasFaltantes count(0) as CtasFaltantes from con.foto_cartera where reg_status = '' and dstrct = 'FINV' and tipo_documento = 'FAC' and negasoc = CarteraxCliente.negasoc and id_convenio = CarteraxCliente.id_convenio and valor_saldo > 0 and periodo_lote = periodo_corriente::numeric and replace(substring(fecha_vencimiento,1,7),'-','')::numeric > periodo_corriente::numeric  and substring(documento,1,2) != 'CP';


			--CREACION CABECERA DEL EXTRACTO
			SELECT INTO _cod_rop nextval('recibo_oficial_pago_cod');
			select into CodRop OVERLAY('EXT0000000' PLACING _cod_rop FROM 11 - length(_cod_rop) FOR length(_cod_rop));

			INSERT INTO recibo_oficial_pago (cod_rop, id_unidad_negocio, periodo_rop, vencimiento_rop, negocio, cuotas_vencidas, cuotas_pendientes, dias_vencidos, subtotal, total_sanciones, total_descuentos, total, total_abonos, creation_date, creation_user, last_update, user_update, observacion)
			/* 2-8 */		  VALUES(CodRop,UnidadNeg,periodo_corriente,vcto_rop,CarteraxCliente.negasoc,'0','0/0','0',0,0,0,0,0,now(),'HCUELLO',now(),'HCUELLO','');


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
				and i.fecha_consignacion <= fecha_hoy
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
				FechaCalculoInteres = COALESCE(FchLastPay.fecha_consignacion::date,fecha_hoy::date);
			ELSE
				FechaCalculoInteres = fecha_hoy::date;
			END IF;

			_SumBase = 0;
			_SumIxM = 0;
			_SumGaC = 0;
			_SumCxCta = 0;

			Mensaje = '';

			FOR CarteraxCabeceraCta IN

				SELECT
					f.negasoc as negocio,
					f.documento,
					f.num_doc_fen as cuota,
					f.valor_saldo,
					f.fecha_factura,
					f.fecha_vencimiento
				FROM con.foto_cartera f
				WHERE   f.reg_status = ''
					and f.dstrct = 'FINV'
					and f.tipo_documento in ('FAC','NDC')
					and f.valor_saldo > 0
					and f.id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio = UnidadNeg)  --17,19/31
					and f.negasoc = CarteraxCliente.negasoc
					and replace(substring(f.fecha_vencimiento,1,7),'-','')::numeric <= periodo_corriente
					and f.periodo_lote = periodo_corriente::numeric

			LOOP

				BolsaSaldo = CarteraxCabeceraCta.valor_saldo;
				FOR CarteraxCuota IN

					--NEGOCIO PRINCIPAL
					SELECT negocio, cedula, prefijo, cuota, fecha_factura, fecha_vencimiento, sum(valor_saldo) as valor_saldo, (fecha_hoy-fecha_vencimiento::DATE) AS dias_vencidos FROM (

						SELECT
							f.negasoc as negocio,
							f.nit AS cedula,
							f.documento,
							fr.descripcion as prefijo,  --substring(f.documento,1,2) as prefijo,
							f.num_doc_fen as cuota,
							f.fecha_factura,
							f.fecha_vencimiento,
							fr.valor_unitario as valor_saldo --f.valor_saldo
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
							and replace(substring(f.fecha_vencimiento,1,7),'-','')::numeric <= periodo_corriente
							and f.periodo_lote = periodo_corriente::numeric
						) as c
					GROUP BY negocio, cedula, prefijo, cuota, fecha_vencimiento, fecha_factura, dias_vencidos
					ORDER BY cuota --::numeric
				LOOP

					_IxM = 0;
					_CxCta = 0;
					_Base = 0;
					_GaC = 0;

					-----------------------------------------------------------------------------------------------------------------------
					VerifyDetails = 'N';
					Diferencia = BolsaSaldo - CarteraxCuota.valor_saldo; --valor_unitario

					if ( Diferencia <= 0 and BolsaSaldo > 0) then

						VlDetFactura = BolsaSaldo;
						_Base = VlDetFactura;

						BolsaSaldo = BolsaSaldo - CarteraxCuota.valor_saldo; --valor_unitario
						VerifyDetails = 'S';

					elsif ( Diferencia > 0 and BolsaSaldo > 0 ) then

						VlDetFactura = CarteraxCuota.valor_saldo;
						_Base = VlDetFactura;

						BolsaSaldo = BolsaSaldo - CarteraxCuota.valor_saldo; --valor_unitario
						VerifyDetails = 'S';

					end if;

					-----------------------------------------------------------------------------------------------------------------------
					if ( VerifyDetails = 'S' ) then
						--BASES
						--_Base = CarteraxCuota.valor_saldo;

						--SUMA DE BASES
						_SumBase = _SumBase + _Base;

						--Conceptos
						SELECT INTO _ConceptRec * FROM conceptos_recaudo WHERE prefijo = CarteraxCuota.prefijo AND CarteraxCuota.dias_vencidos BETWEEN dias_rango_ini AND dias_rango_fin and id_unidad_negocio = UnidadNeg;

						if found then

							--Sanciones
							FOR _Sancion IN SELECT * FROM sanciones_condonaciones WHERE id_tipo_acto = 1 AND id_conceptos_recaudo = _ConceptRec.id AND CarteraxCuota.dias_vencidos BETWEEN dias_rango_ini AND dias_rango_fin AND periodo = periodo_corriente and id_unidad_negocio = UnidadNeg LOOP

								IF ( _Sancion.categoria = 'IXM' ) THEN

									if ( fecha_hoy > CarteraxCuota.fecha_vencimiento::date ) then

										select into _Tasa tasa_interes/100 from convenios where id_convenio = CarteraxCliente.id_convenio;

										_IxM = ROUND( _Base*(_Tasa/30) * (fecha_hoy - CarteraxCuota.fecha_vencimiento)::numeric );
										_SumIxM = _SumIxM + _IxM;
									end if;

								END IF;

								IF ( _Sancion.categoria = 'GAC' ) THEN

									if ( fecha_hoy > CarteraxCuota.fecha_vencimiento::date ) then
										_GaC = ROUND((_Base * _Sancion.porcentaje::numeric)/100);
										_SumGaC = _SumGaC + _GaC;
									end if;

								END IF;

							END LOOP; --_Sancion

							--detalle_extracto
							--SELECT currval('recibo_oficial_pago_cod');
							SELECT INTO _Current_codrop currval('recibo_oficial_pago_cod');
							INSERT INTO detalle_rop (id_rop, id_conceptos_recaudo, descripcion, cuota, dias_vencidos, fecha_factura_padre, fecha_vencimiento_padre, fecha_ultimo_pago, items, valor_concepto, valor_descuento, valor_ixm, valor_descuento_ixm, valor_gac, valor_descuento_gac, valor_abono, valor_saldo, creation_date, creation_user, negocio)
									 VALUES (_Current_codrop, _ConceptRec.id, _ConceptRec.descripcion, CarteraxCuota.cuota, CarteraxCuota.dias_vencidos, CarteraxCuota.fecha_factura, CarteraxCuota.fecha_vencimiento,'',1, _Base, 0, _IxM, 0, _GaC, _CxCta, 0, _Base+_IxM+_GaC-_CxCta, now(), 'HCUELLO', CarteraxCliente.negasoc);
						end if;

					end if;

				END LOOP; --CarteraxCuota

			END LOOP; --CarteraxCabeceraCta


			--INGRESO DE LOS CONCEPTOS DE INTERES Y DE GASTOS DE COBRANZA
			if ( _SumIxM > 0 ) then
				INSERT INTO detalle_rop (id_rop, id_conceptos_recaudo, descripcion, cuota, dias_vencidos, fecha_factura_padre, fecha_vencimiento_padre, fecha_ultimo_pago, items, valor_concepto, valor_descuento, valor_ixm, valor_descuento_ixm, valor_gac, valor_descuento_gac, valor_abono, valor_saldo, creation_date, creation_user, negocio)
				/* 59-153 */		 VALUES (_Current_codrop, IntMora, 'INTERES MORA', 0, 0, '0099-01-01', '0099-01-01','',1, _SumIxM, 0, 0, 0, 0, 0, 0, _SumIxM, now(), 'HCUELLO', CarteraxCliente.negasoc);
			end if;
			if ( _SumGaC > 0 ) then
				INSERT INTO detalle_rop (id_rop, id_conceptos_recaudo, descripcion, cuota, dias_vencidos, fecha_factura_padre, fecha_vencimiento_padre, fecha_ultimo_pago, items, valor_concepto, valor_descuento, valor_ixm, valor_descuento_ixm, valor_gac, valor_descuento_gac, valor_abono, valor_saldo, creation_date, creation_user, negocio)
				/*60-154*/		 VALUES (_Current_codrop, GastCobranza, 'GASTOS DE COBRANZA', 0, 0, '0099-01-01', '0099-01-01','',1, _SumGaC, 0, 0, 0, 0, 0, 0, _SumGaC, now(), 'HCUELLO', CarteraxCliente.negasoc);
			end if;

			--CONDONACIONES
			_SumCxCta = 0;
			FOR _DetalleRopCondonar IN select id_conceptos_recaudo, (select categoria from conceptos_recaudo where id = dr.id_conceptos_recaudo) as categoria ,sum(dr.valor_concepto) as valor_concepto, min(fecha_vencimiento_padre) from detalle_rop dr where id_rop = _Current_codrop group by id_conceptos_recaudo, categoria LOOP

				FOR _Condonacion IN SELECT * FROM sanciones_condonaciones WHERE id_tipo_acto = 2 AND aplicado_a = _DetalleRopCondonar.id_conceptos_recaudo AND CarteraxCliente.min_dias_ven BETWEEN dias_rango_ini AND dias_rango_fin AND periodo = periodo_corriente and id_unidad_negocio = UnidadNeg LOOP

					_CxCta = 0;

					_CxCta = ROUND((_DetalleRopCondonar.valor_concepto * _Condonacion.porcentaje::numeric)/100);

					INSERT INTO detalle_rop (id_rop, id_conceptos_recaudo, descripcion, cuota, dias_vencidos, fecha_factura_padre, fecha_vencimiento_padre, fecha_ultimo_pago, items, valor_concepto, valor_descuento, valor_ixm, valor_descuento_ixm, valor_gac, valor_descuento_gac, valor_abono, valor_saldo, creation_date, creation_user, negocio)
							 VALUES (_Current_codrop, _Condonacion.id_conceptos_recaudo, _Condonacion.descripcion, 0, 0, '0099-01-01', '0099-01-01','',1, _CxCta, 0, 0, 0, 0, 0, 0, _CxCta, now(), 'HCUELLO', CarteraxCliente.negasoc);

					_SumCxCta = _SumCxCta + _CxCta;

				END LOOP; --_Condonacion

			END LOOP; --_DetalleRopCondonar


			--INFORMACION DEL CLIENTE
			SELECT INTO ClienteRec nomcli,direccion,ciudad FROM cliente WHERE nit = CarteraxCuota.cedula;


 			--MENSAJE
			if ( _TotalCuotasPendientes.maxdia <= 0 ) then
				Mensaje := '¡Este estado de cuentas tiene fecha de corte 1 de Junio de 2014, si Usted realizó el pago en fecha posterior, será reflejado en el próximo estado de cuentas. | Cualquier inquietud, agradecemos ponerse en contacto con nuestro Call Center. | ¡Fintra sigue creyendo en Ti!';
				MsgPagueseAntes := pagar_antesde;
				MsgEstadoCredito := 'AL DIA';
			elsif ( _TotalCuotasPendientes.maxdia >= 1 and _TotalCuotasPendientes.maxdia <= 11 ) then
				Mensaje := 'Este estado de cuentas tiene fecha de corte 1 de Junio de 2014, si Usted realizó el pago en fecha posterior, será reflejado en el próximo estado de cuentas. | Cualquier inquietud, agradecemos ponerse en contacto con nuestro Call Center. | ¡Fintra sigue creyendo en Ti!';
				MsgPagueseAntes := 'INMEDIATO';
				MsgEstadoCredito := 'VENCIDO';

			elsif ( _TotalCuotasPendientes.maxdia >= 12 ) then
				Mensaje := 'Este estado de cuentas tiene fecha de corte 1 de Junio de 2014, si Usted realizó el pago en fecha posterior, será reflejado en el próximo estado de cuentas. | Cualquier inquietud, agradecemos ponerse en contacto con nuestro Call Center. | ¡Fintra sigue creyendo en Ti!';
				MsgPagueseAntes := 'INMEDIATO';
				MsgEstadoCredito := 'VENCIDO';
			end if;


			--ACTUALIZA CABECERA DEL EXTRACTO.
			_CtasPentesFaltantes = _TotalCuotasPendientes.CtasPendientes + _TotalCuotasFaltantes;
			UPDATE recibo_oficial_pago SET cedula = CarteraxCuota.cedula, nombre_cliente = ClienteRec.nomcli, direccion = ClienteRec.direccion, ciudad = ClienteRec.ciudad, fecha_ultimo_pago = FechaCalculoInteres, cuotas_vencidas = CarteraxCliente.total_cuotas_vencidas, cuotas_pendientes = _CtasPentesFaltantes||' de '||_TotalCuotas, dias_vencidos = _TotalCuotasPendientes.maxdia, subtotal = ROUND(_SumBase+_SumIxM+_SumGaC), total_sanciones = ROUND(_SumIxM+_SumGaC), total_descuentos = ROUND(_SumCxCta), total = ROUND(_SumBase+_SumIxM+_SumGaC-_SumCxCta), total_abonos = 0, observacion = Mensaje, msg_paguese_antes = MsgPagueseAntes, msg_estado_credito = MsgEstadoCredito WHERE id = _Current_codrop;

	END LOOP; --CarteraxCliente

    RETURN mcad;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_extractoeducativo(numeric, date, character varying, date, date)
  OWNER TO postgres;
