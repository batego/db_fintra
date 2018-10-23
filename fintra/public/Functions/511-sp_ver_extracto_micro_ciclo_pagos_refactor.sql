-- Function: sp_ver_extracto_micro_ciclo_pagos_refactor(numeric, character varying, numeric, date, character varying, character varying)

-- DROP FUNCTION sp_ver_extracto_micro_ciclo_pagos_refactor(numeric, character varying, numeric, date, character varying, character varying);

CREATE OR REPLACE FUNCTION sp_ver_extracto_micro_ciclo_pagos_refactor(und_negocio numeric, periodo_corriente character varying, nciclo numeric, fecha_corte date, accion character varying, usuario character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE

	Mensaje TEXT;
	MsgPagueseAntes TEXT;
        MsgEstadoCredito TEXT;

	CarteraxCliente record;
	CarteraxCuota record;
	ClienteRec record;
	_ConceptRec record;
	_Sancion record;
	_DetalleRopCondonar record;
	_Condonacion record;
	_TotalCuotasPendientes record;
	Ciclo record;
	recordInteres record;
	recordCat record;
	_detalleSaldoFacturas record;
	_conceptosFacturacion record;


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
	_TotalCuotas numeric;
	_TotalCuotasFaltantes numeric;
	_TotalCuotasVencidas record;

	_SumIxM numeric;
	_SumGaC numeric;
	_SumBase numeric;
	_SumCxCta numeric;

	FechaCalculoInteres date;
	FechaUltimoPago varchar;
	CodRop varchar;

	_basesSanciones numeric[] :='{0.00,0.00,0.00,0.00,0.00}';

	--DECLARAMOS EL CURSOR CON LAS FACTURAS A ITERAR
	cursor_creditos CURSOR(FechaUltimoPago date,und_negocio integer,fecha_corte date,id_ciclo integer,
				periodo_corriente varchar,nciclo integer,accion varchar)
			FOR (SELECT
				FechaUltimoPago::DATE AS vencimiento_rop,
				''::VARCHAR AS venc_mayor,
				f.id_convenio::NUMERIC,
				f.negasoc::VARCHAR,
				f.nit::VARCHAR,
				''::VARCHAR AS nom_cli,
				''::VARCHAR AS direccion,
				''::VARCHAR AS barrio,
				''::VARCHAR AS ciudad,
				''::VARCHAR AS departamento,
				''::VARCHAR AS agencia,
				(SELECT descripcion FROM unidad_negocio WHERE id =und_negocio)::VARCHAR AS linea_producto,
				0::numeric as total_cuotas_vencidas,
				''::varchar as cuotas_pendientes,
				(fecha_corte-min(fecha_vencimiento)::DATE)::NUMERIC AS min_dias_ven,
				fupview.fecha::DATE AS fecha_ultimo_pago,
				0::NUMERIC AS subtotal_det,
				0::NUMERIC AS total_sanciones,
				0::NUMERIC AS total_dscto_det,
				0::NUMERIC AS total_det,
				0::NUMERIC AS total_abonos,
				''::VARCHAR AS observaciones,
				''::VARCHAR AS msg_paguese_antes,
				''::VARCHAR AS msg_estado,
				0::NUMERIC AS capital,
				0::NUMERIC AS cat,
				0::NUMERIC AS int_cte,
				0::NUMERIC AS int_mora,
				0::NUMERIC AS gxc,
				0::NUMERIC AS dscto_cap,
				0::NUMERIC AS dscto_cat,
				0::NUMERIC AS dscto_int_cte,
				0::NUMERIC AS dscto_int_mora,
				0::NUMERIC AS dscto_gxc,
				0::NUMERIC AS subtotal_corriente,
				0::NUMERIC AS subtotal_vencido,
				0::NUMERIC AS subtotal,
				0::NUMERIC AS total_descuento,
				0::NUMERIC AS total
			     FROM con.foto_ciclo_pagos f
			     LEFT JOIN fecha_ultimo_pago_view fupview ON (f.negasoc=fupview.negasoc AND fupview.fecha <= fecha_corte)
			     WHERE   f.reg_status = ''
			     AND f.dstrct = 'FINV'
			     AND f.tipo_documento = 'FAC'
			     AND f.valor_saldo > 0
			     AND SUBSTRING(f.documento,1,2) in ('MC','TD')
			     AND f.id_convenio != 41
			     AND f.id_ciclo =id_ciclo
			     AND (CASE WHEN accion = 'Generar' THEN
				   f.negasoc IN (SELECT cod_neg FROM extractos_generados
						 WHERE periodo =periodo_corriente AND num_ciclo = nciclo
						 AND unidad_negocio =und_negocio AND generado ='N')
				  ELSE
				  --NOT IN
				   f.negasoc NOT IN (SELECT cod_neg FROM extractos_generados
						 WHERE unidad_negocio = und_negocio
						 AND periodo =periodo_corriente AND num_ciclo =nciclo)
				  END
				 )
			  --  AND f.negasoc in ('MC08451','MC08216')
			    GROUP BY f.id_convenio, f.negasoc,f.nit,fupview.fecha

		);

BEGIN

        --0.0) HACEMOS MANTENIMIENTO A LAS TABLAS ANTES DE USARLAS
	DELETE FROM tem.extracto_temp;
	ANALYZE tem.extracto_temp;
	--ANALYZE con.foto_ciclo_pagos;
	--ANALYZE extractos_generados;

        --0.1.) DATOS GLOBALES PARA EL PROCESO
	SELECT INTO Ciclo * FROM con.ciclos_facturacion WHERE periodo = periodo_corriente AND num_ciclo = nciclo;
	FechaUltimoPago := SUBSTRING(Ciclo.fecha_pago,1,8)||sp_diasmes(Ciclo.fecha_pago);

	--0.2.)ABRIMOS EL CURSOR E ITERAMMOS
	OPEN cursor_creditos(FechaUltimoPago::date,und_negocio::integer,fecha_corte::date,Ciclo.id::integer,
			     periodo_corriente::varchar,nciclo::integer,accion::varchar);

	<<_loop>>
	LOOP
		-- FETCH FILA EN MY RECORD O TYPE
		FETCH cursor_creditos INTO CarteraxCliente;

		-- EXIT CUANDO NO HAY MAS FILAS
		EXIT WHEN NOT FOUND;


		--1-) NUMERO TOTAL DE CUOTAS DEL CREDITO
		SELECT INTO _TotalCuotas count(0) AS totalCuotas
		FROM documentos_neg_aceptado
		WHERE cod_neg = CarteraxCliente.negasoc and reg_status='';

		--2-) NUMERO DE CUOTAS QUE A LA FECHA DE FECHA_INICIO DEL CICLO ESTAN EN ESTADO VENCIDO Y MAX DIAS DE VENCIMIENTO.
		raise notice 'CarteraxCliente.negasoc : %  CarteraxCliente.id_convenio : %  periodo_corriente: % Ciclo.fecha_ini : %',CarteraxCliente.negasoc , CarteraxCliente.id_convenio , periodo_corriente,Ciclo.fecha_ini  ;
		SELECT INTO _TotalCuotasVencidas
		        coalesce(count(0),0) AS CtasVencidas,
		        coalesce(max(fecha_corte-(fecha_vencimiento)),-1) as maxdia
		FROM con.foto_ciclo_pagos
		WHERE reg_status = '' AND dstrct = 'FINV'
		AND tipo_documento = 'FAC'
		AND negasoc = CarteraxCliente.negasoc
		AND id_convenio = CarteraxCliente.id_convenio
		AND valor_saldo > 0
		AND fecha_vencimiento <= Ciclo.fecha_ini
		AND SUBSTRING(documento,1,2) in ('MC','TD')
		AND SUBSTRING(documento,1,2) != 'CP'
		AND periodo_lote = periodo_corriente;

		IF(_TotalCuotasVencidas.maxdia = -1 ) THEN

			SELECT INTO _TotalCuotasVencidas.maxdia
				max(fecha_corte-(fecha_vencimiento)) as maxdia
			FROM con.foto_ciclo_pagos
			WHERE reg_status = '' AND dstrct = 'FINV'
			AND tipo_documento = 'FAC'
			AND negasoc = CarteraxCliente.negasoc
			AND id_convenio = CarteraxCliente.id_convenio
			AND valor_saldo > 0
			AND fecha_vencimiento <= Ciclo.fecha_fin
			AND SUBSTRING(documento,1,2) in ('MC','TD')
			AND SUBSTRING(documento,1,2) != 'CP'
			AND periodo_lote = periodo_corriente;

		END IF;

		CarteraxCliente.total_cuotas_vencidas =_TotalCuotasVencidas.CtasVencidas;

		--3-) TOTAL CUOTAS PENDIENTES POR PAGAR
		_TotalCuotasFaltantes:=(SELECT count(*) FROM con.factura
					WHERE negasoc =CarteraxCliente.negasoc
					AND valor_saldo >0
					AND reg_status=''
					AND dstrct='FINV'
					AND tipo_documento='FAC'
					AND descripcion !='CXC AVAL'
					AND substring(documento,1,2) not in ('CP','FF','DF','CM','MI','CA')
					);

		--4-) CALCULAMOS EL VENCIMIENTO MAYOR DEL CREDITO SEGUN LA FOTO DEL CICLO
		CarteraxCliente.venc_mayor :=(SELECT
							eg_altura_mora_periodo(CarteraxCliente.negasoc,201412,3,maxdia::INTEGER)
						    FROM (
							 SELECT max(fecha_corte::date-(fecha_vencimiento)) as maxdia
							 FROM con.foto_ciclo_pagos fra
							 WHERE fra.dstrct = 'FINV'
								  AND fra.valor_saldo > 0
								  AND fra.reg_status = ''
								  AND fra.negasoc = CarteraxCliente.negasoc
								  AND fra.id_convenio = CarteraxCliente.id_convenio
								  AND fra.tipo_documento in ('FAC','NDC')
								  AND substring(fra.documento,1,2) not in ('CP','FF','DF')
								  AND fra.fecha_vencimiento <= Ciclo.fecha_fin
								  AND fra.periodo_lote = periodo_corriente
							 GROUP BY negasoc
						    )t
						);

		--5-)CUANDO ES GENERAR SE CREA LA CABECERA DEL RECIBO DE PAGO
		IF(accion = 'Generar') THEN

			--CREACION CABECERA DEL EXTRACTO
			INSERT INTO recibo_oficial_pago (cod_rop, id_unidad_negocio, periodo_rop, id_ciclo,
							 vencimiento_rop, negocio, cuotas_vencidas, cuotas_pendientes,
							 dias_vencidos, subtotal, total_sanciones, total_descuentos,
							 total, total_abonos, creation_date, creation_user,
							 last_update, user_update, observacion)
			  VALUES('',1,periodo_corriente,Ciclo.id,
				CarteraxCliente.vencimiento_rop,CarteraxCliente.negasoc,'0','0/0',
				'0',0,0,0,
				 0,0,now(),usuario,
				 now(),usuario,'') RETURNING id INTO _cod_rop;

			RAISE notice 'id_Cod_Rop: %',_cod_rop;

		END IF;

		--CODIGO PARA LA TABLA TEMPORAL...
		SELECT INTO _cod_temp nextval('tem.extracto_temp_seq');
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
		id_concep_ixm = 0;
		id_concep_gac = 0;
		Mensaje = '';

		/**
		SE ITERA LA CARTERA DEL CLIENTE POR CUOTA MOSTRANDO SOLO EL CAPITAL (MC).
		PARA AQUELLOS NEGOCIOS DONDE EL CAT, MI Y C-ADMIN ESTAN EN EL DETALLE, SOLO CON BUSCAR EL VALOR SALDO
		DE LAS FACTURAS MC TENDREMOS EL VALOR A PAGAR DEL CLIENTE; MIENTRAS QUE LOS
		NEGOCIOS CUYO ESQUEMA ES GENERAR FACTURAS PARA EL CAT Y EL MI SE DEBEN BUSCAR EN EL LIQUIDADOR
		EL VALOR A COBRAR VALIDANDO ANTES SI ESTOS FUERON GENERADOS Y ABONADOS EN DICHO CASO SE TOMA DE LA TABLA FACTURA.
		**/
		FOR CarteraxCuota IN
					SELECT negocio,
					       cedula,
					       prefijo,
					       cuota,
					       fecha_factura,
					       fecha_vencimiento,
					       sum(valor_saldo) as valor_saldo,
					       (fecha_corte::date-fecha_vencimiento::DATE) AS dias_vencidos,
					       esquema_old
					       FROM (
							SELECT
								f.negasoc as negocio,
								f.nit AS cedula,
								f.documento,
								SUBSTRING(f.documento,1,2) AS prefijo,
								f.num_doc_fen as cuota,
								f.fecha_factura,
								fecha_vencimiento,
								f.valor_saldo,
								coalesce(tem.esquema,'N') as esquema_old
							FROM con.foto_ciclo_pagos f
							LEFT JOIN tem.negocios_facturacion_old tem on (tem.cod_neg=f.negasoc)
							WHERE f.reg_status = ''
								and f.dstrct = 'FINV'
								and f.tipo_documento = 'FAC'
								and f.valor_saldo > 0
								and substring(f.documento,1,2) in ('MC','TD','R0')--Prefijos facturas de capital
								and f.negasoc = CarteraxCliente.negasoc
								and f.fecha_vencimiento <= Ciclo.fecha_fin
								and f.periodo_lote = periodo_corriente
						) AS c
					GROUP BY negocio,
						 cedula,
						 prefijo,
						 cuota,
						 fecha_vencimiento,
						 fecha_factura,
						 dias_vencidos,
						 esquema_old
					ORDER BY cuota::NUMERIC

		LOOP
			_IxM = 0;
			_CxCta = 0;
			_Base = 0;
			_GaC = 0;

			--_basesSanciones[0] --CAPITAL X CUOTA
			--_basesSanciones[1] --MI X CUOTA
			--_basesSanciones[2] --CA X CUOTA


			raise notice 'CarteraxCuota.esquema_old : %',CarteraxCuota.esquema_old;
			--VALIDAMOS SI ES UN NEGOCIOS CON ESQUEMA DE FACTURACION VIEJO
			IF(CarteraxCuota.esquema_old='S' or CarteraxCuota.negocio like 'TF%')THEN

				--SUMA EL VALOR CAPITAL DE CADA CUOTA ITERADA
				_SumCapital := _SumCapital + CarteraxCuota.valor_saldo;
				_basesSanciones[0]:=CarteraxCuota.valor_saldo;
				RAISE notice '_SumCapital : % _basesSanciones[0] : %',_SumCapital,_basesSanciones[0];

				--1)Interes Corriente validamos que este generado, si nros_docs es 1 se genero factura
				SELECT INTO recordInteres coalesce(sum(valor_saldo),0) as saldo, count(0) as nros_docs
				FROM con.factura fac
				WHERE  fac.negasoc= CarteraxCuota.negocio
				AND fac.num_doc_fen= CarteraxCuota.cuota
				AND SUBSTRING(fac.documento,1,2) IN ('MI','TS')
				AND fac.reg_status !='A' ;


				_basesSanciones[1]:=CASE WHEN recordInteres.nros_docs=1 THEN recordInteres.saldo
								ELSE eg_vlrs_liq_cuota(CarteraxCuota.negocio,'INTERES'::VARCHAR, CarteraxCuota.cuota::INTEGER)
								END ;


				_SumIntCte := _SumIntCte + _basesSanciones[1];
				RAISE notice '_SumIntCte : % _basesSanciones[1] : %',_SumIntCte,_basesSanciones[1];

				--2)Cat validamos que este generado para las facturas MC, si nros_docs es 1 se genero factura
				IF(CarteraxCuota.prefijo ='MC')THEN

					SELECT INTO recordCat coalesce(sum(valor_saldo),0) as saldo, count(0) as nros_docs
					FROM con.factura fac
					WHERE  fac.negasoc= CarteraxCuota.negocio
					AND fac.num_doc_fen= CarteraxCuota.cuota
					AND SUBSTRING(fac.documento,1,2) IN ('CA')
					AND fac.reg_status !='A';

					_basesSanciones[2]:=CASE WHEN recordCat.nros_docs=1 THEN recordCat.saldo
								ELSE  eg_vlrs_liq_cuota(CarteraxCuota.negocio,'CAT', CarteraxCuota.cuota::INTEGER) END ;

					_SumCat := _SumCat+_basesSanciones[2];

					RAISE notice '_SumCat : % _basesSanciones[2] : %',_SumCat,_basesSanciones[2];

				END IF ;

			ELSIF(CarteraxCuota.esquema_old='N')THEN --ESQUEMA NUEVO DE FACTURACION

				--BUSCAMMOS LOS SALDO DE CADA CONCEPTO SEGUN EL CRITERIO DE APLICACION..
				SELECT INTO _detalleSaldoFacturas documento, negocio , cuota ,total_factura ,
								  saldo_capital,saldo_interes,saldo_cat,saldo_cuota_manejo,
								  saldo_seguro,total_abonos,saldo_factura
				FROM  eg_detalle_saldo_facturas_mc(CarteraxCuota.negocio::VARCHAR,CarteraxCuota.cuota::INTEGER);

				_SumCapital :=_SumCapital+(_detalleSaldoFacturas.saldo_capital+_detalleSaldoFacturas.saldo_cuota_manejo+_detalleSaldoFacturas.saldo_seguro);
				_SumIntCte :=_SumIntCte + _detalleSaldoFacturas.saldo_interes;
				_SumCat :=_SumCat + _detalleSaldoFacturas.saldo_cat;

				raise notice 'vlidacion capital _SumCapital : %',_SumCapital;

				--Array saldos para el calculo de sanciones
				_basesSanciones[0] :=(_detalleSaldoFacturas.saldo_capital+_detalleSaldoFacturas.saldo_cuota_manejo+_detalleSaldoFacturas.saldo_seguro);
				_basesSanciones[1] :=_detalleSaldoFacturas.saldo_interes;
				_basesSanciones[2] := _detalleSaldoFacturas.saldo_cat;

			END IF;

			--BASE PARA EL CALCULO DE LAS SANCIONES (GAC,MORA)
			_Base:=_basesSanciones[0]+_basesSanciones[1]+_basesSanciones[2];
			_SumBase = _SumBase + _Base;

			--TASA DEL NEGOCIO...
			SELECT INTO _Tasa tasa_usura/100 FROM convenios WHERE id_convenio = CarteraxCliente.id_convenio;

			--SE BUSCAN LOS CONCEPTOS DE LA FACTURACION...
			FOR _conceptosFacturacion in (SELECT prefijo FROM conceptos_facturacion WHERE id_unidad_negocio=und_negocio AND prefijo in ('MC','MI','CA')  ) LOOP

				raise notice '_conceptosFacturacion %',_conceptosFacturacion.prefijo ;
				--VALIDACION DE SALDO PARA CALCULAR LAS SANCIONES DEBE SER POR CONCEPTO
				_Base:= CASE WHEN _conceptosFacturacion.prefijo ='MC' THEN _basesSanciones[0]
					     WHEN _conceptosFacturacion.prefijo ='MI' THEN _basesSanciones[1]
					     WHEN _conceptosFacturacion.prefijo ='CA' THEN _basesSanciones[2]  END ;

				SELECT INTO _ConceptRec id,descripcion FROM conceptos_recaudo
				WHERE prefijo = _conceptosFacturacion.prefijo
				AND CarteraxCuota.dias_vencidos BETWEEN dias_rango_ini AND dias_rango_fin and id_unidad_negocio = 1;

				raise notice 'id_conceptos_recaudo 1 : % ', _ConceptRec.id;

				FOR _Sancion IN

					SELECT categoria, porcentaje FROM sanciones_condonaciones
					WHERE id_tipo_acto = 1 AND id_conceptos_recaudo = _ConceptRec.id
					AND CarteraxCuota.dias_vencidos BETWEEN dias_rango_ini AND dias_rango_fin
					AND periodo = periodo_corriente and id_unidad_negocio = 1

				LOOP

					IF( _Sancion.categoria = 'IXM' ) THEN

						if ( fecha_corte > CarteraxCuota.fecha_vencimiento::DATE ) THEN

							_IxM = ROUND( _Base*(_Tasa/30) * (fecha_corte - CarteraxCuota.fecha_vencimiento)::NUMERIC );
							_SumIxM = _SumIxM + _IxM;

						end if;

					ELSIF( _Sancion.categoria = 'GAC' ) THEN

						IF ( fecha_corte > CarteraxCuota.fecha_vencimiento::DATE ) THEN
							_GaC = ROUND((_Base * _Sancion.porcentaje::NUMERIC)/100);
							_SumGaC = _SumGaC + _GaC;
						END IF;

					END IF;

				END LOOP; --_Sancion

				--detalle_extracto
				IF(_ConceptRec.descripcion = 'CAPITAL CORRIENTE') THEN
					_SumCapitalCte = _SumCapitalCte + _Base;
				ELSIF (_ConceptRec.descripcion = 'CAPITAL VENCIDO') THEN
					_SumCapitalVenc = _SumCapitalVenc + _Base;
				ELSIF (_ConceptRec.descripcion = 'INTERES CORRIENTE') THEN
					_SumInteresCte = _SumInteresCte + _Base;
				ELSIF (_ConceptRec.descripcion = 'INTERES VENCIDO') THEN
					_SumIntVencido = _SumIntVencido + _Base;
				END IF;


				INSERT INTO tem.extracto_temp (cod_rop,id_concepto,concepto,fecha_venc_padre,vr_concepto)
					VALUES (_cod_temp,_ConceptRec.id,_ConceptRec.descripcion,CarteraxCuota.fecha_factura,_Base);

				raise notice 'id_conceptos_recaudo : % ', _ConceptRec.id;

				IF(accion = 'Generar') THEN
					INSERT INTO detalle_rop (id_rop, id_conceptos_recaudo, descripcion, cuota, dias_vencidos, fecha_factura_padre, fecha_vencimiento_padre,
								fecha_ultimo_pago, items, valor_concepto, valor_descuento, valor_ixm, valor_descuento_ixm, valor_gac, valor_descuento_gac,
								valor_abono, valor_saldo, creation_date, creation_user, negocio)
					VALUES (_cod_rop, _ConceptRec.id, _ConceptRec.descripcion, CarteraxCuota.cuota, CarteraxCuota.dias_vencidos, CarteraxCuota.fecha_factura,
						CarteraxCuota.fecha_vencimiento,'',1, _Base, 0, _IxM, 0, _GaC, _CxCta, 0, _Base+_IxM+_GaC-_CxCta, now(), usuario, CarteraxCliente.negasoc);
				END IF;

			END LOOP; --CONCEPTOS DE FATURACION



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
			INSERT INTO detalle_rop (id_rop, id_conceptos_recaudo, descripcion, cuota, dias_vencidos, fecha_factura_padre,
						fecha_vencimiento_padre, fecha_ultimo_pago, items, valor_concepto, valor_descuento, valor_ixm, valor_descuento_ixm,
						valor_gac, valor_descuento_gac, valor_abono, valor_saldo, creation_date, creation_user, negocio)
			VALUES (_cod_rop, id_concep_ixm, 'INTERES MORA', 0, 0, '0099-01-01', '0099-01-01','',1, _SumIxM, 0, 0, 0, 0, 0, 0, _SumIxM, now(), usuario, CarteraxCliente.negasoc);

			INSERT INTO detalle_rop (id_rop, id_conceptos_recaudo, descripcion, cuota, dias_vencidos, fecha_factura_padre,
						fecha_vencimiento_padre, fecha_ultimo_pago, items, valor_concepto, valor_descuento, valor_ixm,
						valor_descuento_ixm, valor_gac, valor_descuento_gac, valor_abono, valor_saldo, creation_date, creation_user, negocio)
			VALUES (_cod_rop, id_concep_gac, 'GASTOS DE COBRANZA', 0, 0, '0099-01-01', '0099-01-01','',1, _SumGaC, 0, 0, 0, 0, 0, 0, _SumGaC, now(), usuario, CarteraxCliente.negasoc);
		end if;


		--CONDONACIONES
		_SumCxCta = 0;
		_SumDsctoCap = 0;
		_SumDsctoCat = 0;
		_SumDsctoIxM = 0;
		_SumDsctoGxC = 0;
		_SumDsctoInt = 0;

		PERFORM * FROM excepciones_condonacion WHERE negocio = CarteraxCliente.negasoc and periodo_condonacion = periodo_corriente;
		IF ( NOT FOUND ) THEN
			raise notice 'entra a condonar';
			FOR _DetalleRopCondonar IN SELECT id_concepto
							  ,(select categoria from conceptos_recaudo where id = et.id_concepto) as categoria
							  ,sum(et.vr_concepto) as valor_concepto
							  , min(et.fecha_venc_padre)
						   FROM tem.extracto_temp et
						   WHERE cod_rop = _cod_temp
						   GROUP BY id_concepto, categoria

			LOOP

				FOR _Condonacion IN SELECT * FROM sanciones_condonaciones
						    WHERE id_tipo_acto = 2
						    AND aplicado_a = _DetalleRopCondonar.id_concepto
						    AND CarteraxCliente.min_dias_ven BETWEEN dias_rango_ini AND dias_rango_fin
						    AND periodo = periodo_corriente
						    AND id_unidad_negocio = 1
				LOOP

					_CxCta = 0;

					_CxCta = ROUND((_DetalleRopCondonar.valor_concepto * _Condonacion.porcentaje::numeric)/100);

					IF(accion = 'Generar') THEN
						INSERT INTO detalle_rop (id_rop, id_conceptos_recaudo, descripcion, cuota, dias_vencidos, fecha_factura_padre, fecha_vencimiento_padre,
									fecha_ultimo_pago, items, valor_concepto, valor_descuento, valor_ixm, valor_descuento_ixm, valor_gac, valor_descuento_gac,
									valor_abono, valor_saldo, creation_date, creation_user, negocio)
						 VALUES (_cod_rop, _Condonacion.id_conceptos_recaudo, _Condonacion.descripcion, 0, 0, '0099-01-01', '0099-01-01','',1, _CxCta, 0, 0, 0,
							0, 0, 0, _CxCta, now(), usuario, CarteraxCliente.negasoc);
					END IF;

					_SumCxCta = _SumCxCta + _CxCta;

					IF(_DetalleRopCondonar.categoria = 'CAP') THEN
						_SumDsctoCap = _SumDsctoCap + _CxCta;
					ELSIF (_DetalleRopCondonar.categoria = 'CAT') THEN
						_SumDsctoCat = _SumDsctoCat + _CxCta;
					ELSIF (_DetalleRopCondonar.categoria = 'IXM') THEN
						_SumDsctoIxM = 	_SumDsctoIxM + _CxCta;
					ELSIF (_DetalleRopCondonar.categoria = 'GAC') THEN
						_SumDsctoGxC = _SumDsctoGxC + _CxCta;
					ELSIF (_DetalleRopCondonar.categoria = 'INT') THEN
						_SumDsctoInt = _SumDsctoInt + _CxCta;
					END IF;

				END LOOP; --_Condonacion

			END LOOP; --_DetalleRopCondonar
		END IF;


		--INFORMACION DEL CLIENTE
		SELECT INTO ClienteRec n.*,c.nomciu,e.department_name FROM nit n
		INNER JOIN ciudad c on (c.codciu=n.codciu)
		INNER JOIN estado e on (e.department_code=n.coddpto)
		WHERE n.cedula = CarteraxCuota.cedula;


		--MENSAJE
		raise notice '_TotalCuotasVencidas.maxdia : %',_TotalCuotasVencidas.maxdia;

		IF ( _TotalCuotasVencidas.maxdia <= 0 ) THEN
			Mensaje := '¡Felicitaciones! | Su pago oportuno lo perfila como un buen | CLIENTE';
			MsgEstadoCredito := 'AL DIA';
			MsgPagueseAntes = (select max(fecha_vencimiento) from con.foto_ciclo_pagos where negasoc = CarteraxCliente.negasoc and valor_saldo > 0 and fecha_vencimiento <= Ciclo.fecha_fin and periodo_lote = periodo_corriente );
				IF ( MsgPagueseAntes is null ) THEN
					MsgPagueseAntes = (select max(fecha_vencimiento) from con.foto_ciclo_pagos where negasoc = CarteraxCliente.negasoc and valor_saldo > 0 and periodo_lote = periodo_corriente and replace(substring(fecha_vencimiento,1,7),'-','')::numeric = periodo_corriente+1);
				END IF;
		ELSIF ( _TotalCuotasVencidas.maxdia BETWEEN 1 AND  11 ) THEN
			Mensaje := '¡Lo invita a normalizar tu obligación y gozar | de los beneficios de un buen | BUEN CLIENTE ';
			MsgPagueseAntes := 'INMEDIATO';
			MsgEstadoCredito := 'VENCIDO';

		ELSIF ( _TotalCuotasVencidas.maxdia >= 12 ) THEN
			Mensaje := '¡Ponte al día con tu crédito y evita costos que incrementen el valor de la cuota! | ¡Fintra sigue creyendo en Ti! ';
			MsgPagueseAntes := 'INMEDIATO';
			MsgEstadoCredito := 'VENCIDO';
		END IF;

		IF(accion = 'Generar') THEN
			--ACTUALIZA CABECERA DEL EXTRACTO.
			SELECT INTO CodRop OVERLAY('EXT0000000' PLACING _cod_rop FROM 11 - length(_cod_rop) FOR length(_cod_rop));

			UPDATE recibo_oficial_pago
			SET cod_rop = CodRop,
			    cedula = CarteraxCuota.cedula,
			    nombre_cliente = ClienteRec.nombre,
			    direccion = ClienteRec.direccion,
			    ciudad = ClienteRec.codciu,
			    fecha_ultimo_pago = CarteraxCliente.fecha_ultimo_pago,
			    cuotas_vencidas = CarteraxCliente.total_cuotas_vencidas,
			    cuotas_pendientes = _TotalCuotasFaltantes||' de '||_TotalCuotas,
			    dias_vencidos = _TotalCuotasVencidas.maxdia,
			    subtotal = ROUND(_SumBase+_SumIxM+_SumGaC),
			    total_sanciones = ROUND(_SumIxM+_SumGaC),
			    total_descuentos = ROUND(_SumCxCta),
			    total = ROUND(_SumBase+_SumIxM+_SumGaC-_SumCxCta),
			    total_abonos = 0,
			    observacion = Mensaje,
			    msg_paguese_antes = MsgPagueseAntes,
			    msg_estado_credito = MsgEstadoCredito,
			    vencimiento_mayor =CarteraxCliente.venc_mayor
			WHERE id = _cod_rop;

		END IF;

		CarteraxCliente.agencia = 'BARRANQUILLA';
		CarteraxCliente.nom_cli = ClienteRec.nombre;
		CarteraxCliente.direccion = ClienteRec.direccion;
		CarteraxCliente.barrio = ClienteRec.barrio;
		CarteraxCliente.ciudad = ClienteRec.nomciu;
		CarteraxCliente.departamento = ClienteRec.department_name;
		CarteraxCliente.cuotas_pendientes = _TotalCuotasFaltantes||' de '||_TotalCuotas;
		CarteraxCliente.min_dias_ven = _TotalCuotasVencidas.maxdia;
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
		CarteraxCliente.subtotal = ROUND(_SumBase+_SumIxM+_SumGaC);
		CarteraxCliente.total_sanciones = ROUND(_SumIxM+_SumGaC);
		CarteraxCliente.total_descuento = ROUND(_SumCxCta);
		CarteraxCliente.total = ROUND(_SumBase+_SumIxM+_SumGaC-_SumCxCta);
		CarteraxCliente.observaciones = Mensaje;
		CarteraxCliente.msg_paguese_antes = MsgPagueseAntes;
		CarteraxCliente.msg_estado = MsgEstadoCredito;

		IF(accion = 'Generar') THEN
			-- ACTUALIZA LOS NEGOCIOS EN: 'S' PARA QUE NO SEAN GENERADOS NUEVAMENTE
			UPDATE extractos_generados
			SET generado = 'S'
			WHERE cod_neg = CarteraxCliente.negasoc
			AND periodo = periodo_corriente
			AND num_ciclo = nciclo
			AND unidad_negocio = und_negocio;
		END IF;

		RETURN NEXT CarteraxCliente;

	END LOOP _loop; --CarteraxCliente


	CLOSE cursor_creditos;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_ver_extracto_micro_ciclo_pagos_refactor(numeric, character varying, numeric, date, character varying, character varying)
  OWNER TO postgres;
