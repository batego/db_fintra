-- Function: sp_contabilizarlibranza(character varying, character varying, character varying, text)

-- DROP FUNCTION sp_contabilizarlibranza(character varying, character varying, character varying, text);

CREATE OR REPLACE FUNCTION sp_contabilizarlibranza(_codigonegocio character varying, _usuario character varying, _concepto character varying, _comentarios text)
  RETURNS text AS
$BODY$

DECLARE

	RsTraza record;
	RsNegocio record;
	RsComprarCartera record;
	Deducciones record;
	ProvExist record;

	VlrComprar numeric := 0;
	VlrDesembolsoWdesc numeric := 0;
	_NewSaldoCliente numeric := 0;
	ValorDeduccion numeric := 0;

	SumDeduccionCC numeric := 0;
	TotalDeduccionCC numeric := 0;
	SumDeduccionLI numeric := 0;
	TotalDeduccionLI numeric := 0;

	conta integer;
	ContaNC integer;

	numCxP varchar := '';
	numNC_CxP varchar := '';

	LibreInversion varchar := 'S';
	CompraCartera varchar := 'N';
	MotivoDeduccion varchar := '';
	CuentaDetalle varchar := '';
	CxP_Cliente varchar := '';

	ReturnSP varchar;
	ReturnCC varchar;
	ReturnCxC varchar;
	ReturNegCont varchar;

        TieneFianza varchar := 'N';
        vectorCuentasFianza varchar[]='{}';
        RsConfigFianza record;
        RsValoresFianza record;
        _VlrFianza numeric := 0;
        _VlrIvaFianza numeric := 0;
        _SubtotalFianza numeric := 0;
        CxP_Fianza varchar := '';
        cmc_factura_fz varchar := '';
        sw boolean:=false; --mientras harold lo arregla


	_respuesta TEXT := 'OK';

BEGIN

	--CONSULTA NEGOCIO.
	SELECT INTO RsNegocio *
	FROM negocios n
	INNER JOIN solicitud_aval sa on (sa.cod_neg = n.cod_neg)
	INNER JOIN solicitud_persona sp on (sp.numero_solicitud = sa.numero_solicitud and sp.tipo = 'S')
        INNER JOIN convenios c on (c.id_convenio=n.id_convenio)
	WHERE n.cod_neg = _CodigoNegocio;

       --OBTENEMOS SI EL NEGOCIO LLEVA FIANZA
	SELECT INTO TieneFianza fianza FROM solicitud_aval WHERE cod_neg = _CodigoNegocio AND reg_status = '';

        --OBTENEMOS INFO CUENTAS FIANZA
        vectorCuentasFianza:=administrativo.get_cuentas_perfil('CXP_FIANZA_LBT',RsNegocio.id_convenio::integer);

        SELECT INTO cmc_factura_fz  cmc FROM con.cmc_doc WHERE tipodoc='FAP' AND cuenta=vectorCuentasFianza[1];

        --OBTENEMOS VALORES CONFIGURADOS PARA LA FIANZA
	SELECT  INTO RsConfigFianza cf.*,p.payment_name as nombre_empresa
				    FROM configuracion_factor_por_millon cf
                                    INNER JOIN proveedor p ON p.nit = cf.nit_empresa
				    INNER JOIN unidad_negocio un ON cf.id_unidad_negocio = un.id
				    INNER JOIN rel_unidadnegocio_convenios run on (run.id_unid_negocio=un.id)
				    WHERE id_unid_negocio = 22
				    AND RsNegocio.nro_docs BETWEEN plazo_inicial AND plazo_final;

        IF(TieneFianza = 'S') THEN

                --OBTENEMOS VALORES CORRESPONDIENTES A LA COMISION
		SELECT INTO RsValoresFianza id_unidad_negocio,CASE WHEN porcentaje_comision > 0 THEN round((RsNegocio.vr_negocio*porcentaje_comision/100)*(1+porcentaje_iva/100))
		    ELSE round((RsNegocio.nro_docs::int*RsNegocio.vr_negocio*valor_comision/1000000)*(1+porcentaje_iva/100)) END AS valor_fianza,
		    CASE WHEN porcentaje_comision > 0 THEN round((RsNegocio.vr_negocio*porcentaje_comision/100)*(porcentaje_iva/100))
		    ELSE round((RsNegocio.nro_docs::int*RsNegocio.vr_negocio*valor_comision/1000000)*(porcentaje_iva/100)) END AS valor_iva_fianza
		    FROM configuracion_factor_por_millon cf
		    WHERE id_unidad_negocio = 22
		    AND RsNegocio.nro_docs::int BETWEEN plazo_inicial AND plazo_final;

                _VlrFianza := RsValoresFianza.valor_fianza;
                _VlrIvaFianza := RsValoresFianza.valor_iva_fianza;
                _SubtotalFianza  := _VlrFianza - _VlrIvaFianza;
        END IF;


	/*--------------------------
	--Oculto la Contabilizacio--
	---------------------------*/
	UPDATE negocios
	SET
	   fecha_cont = '0099-01-01 00:00:00',
	   periodo = 'XXXXXX',
	   no_transacion = 111111
	WHERE cod_neg = _CodigoNegocio;

	/*---------------------
	--GUARDA LA ACTIVIDAD--
	-----------------------*/

	--select * from negocios_trazabilidad where cod_neg = 'FA18244'
	--select * from negocios where cod_neg = 'LN00017'
	select into RsTraza * from negocios_trazabilidad where cod_neg = _CodigoNegocio and actividad = 'LIQ';
	INSERT INTO negocios_trazabilidad (reg_status, dstrct, numero_solicitud, actividad, usuario, fecha, cod_neg, comentarios, concepto) VALUES('', 'FINV', RsTraza.numero_solicitud, 'FOR', _Usuario, now(), _CodigoNegocio, _Comentarios, _Concepto);
	UPDATE negocios SET actividad = 'FOR', estado_neg = 'A', fecha_ap = now() where cod_neg = _CodigoNegocio;

	/*---------------------
	-- CREA EL PROVEEDOR --
	-----------------------*/

	--Debe tener la cuenta a transferir...
	raise notice 'CodCli ES: %',RsNegocio.cod_cli;
	SELECT INTO ProvExist * FROM proveedor WHERE nit = RsNegocio.cod_cli; --RsNegocio.identificacion;
	raise notice 'PROVEEDOR ES: %',ProvExist.nit;

	IF ProvExist is null THEN

		--INSERT
		INSERT INTO proveedor(
			    dstrct,nit, payment_name, creation_date,
			    creation_user, tipo_doc, clasificacion,
			    base, cedula_cuenta, nombre_cuenta, branch_code, bank_account_no,
			    banco_transfer, tipo_cuenta, no_cuenta,
			    agency_id, nit_beneficiario)
		    VALUES ('FINV', RsNegocio.cod_cli, RsNegocio.nombre, now(),
			    _Usuario, RsNegocio.tipo_id, 'PN',
			    'COL', RsNegocio.identificacion, '','BANCOLOMBIA', 'CPAG',
			    'Bancolombia','CC', '76938425062',
			    'OP', RsNegocio.identificacion);
	ELSE
		raise notice 'EL PROVEEDOR YA FUE CREADO';
	END IF;

	/*-----------------------------------
	--Deduce las obligaciones compradas--
	-------------------------------------*/
	SELECT INTO VlrComprar sum(valor_comprar) as valor_comprar FROM solicitud_obligaciones_comprar WHERE numero_solicitud = RsNegocio.numero_solicitud;

	if ( VlrComprar > 0 ) then

		VlrDesembolsoWdesc = RsNegocio.vr_desembolso - VlrComprar;
		if ( VlrDesembolsoWdesc <= 0 ) then
			LibreInversion = 'N';
			sw:=true;
		end if;
		CompraCartera = 'S';


	else
		VlrDesembolsoWdesc = RsNegocio.vr_desembolso;
		SELECT INTO ReturNegCont SP_ContabilizarNegocio(_CodigoNegocio, RsNegocio.cod_cli, RsNegocio.nombre, VlrDesembolsoWdesc, _Usuario);
		SELECT INTO ReturnCxC SP_CxCLibranza(_CodigoNegocio, _Usuario);

	end if;

	/*------------------------
	-- CONTABILIZAR NEGOCIO --
	--------------------------*/
	--RsNegocio.vr_negocio
	--RsNegocio.nombre

	/*-----------------------------------
	--CxP al Cliente -> LIBRE INVERSION--
	-------------------------------------*/
	IF ( LibreInversion = 'S' ) THEN

		numCxP := serie_cxp_libranza();
		CxP_Cliente = numCxP;

	raise notice 'CXP ES: %',CxP_Cliente;

		SELECT INTO ReturnSP SP_CxPLibranza('TRANSFERENCIA', 'FAP', _Usuario, numCxP, '', RsNegocio.cod_cli, RsNegocio.nombre, RsNegocio.cod_neg, VlrDesembolsoWdesc, 1::varchar, 'LC', '23050940', 'CXP TRANSFERENCIA A: ', 'DESEMBOLSO A: ');

		/********************************************************
		*          GENERAMOS NC -> CxP de transferencia         *
		*********************************************************/
		_NewSaldoCliente = RsNegocio.vr_desembolso;
		ContaNC = 1;

		--Transferencia y Globales
		FOR Deducciones IN

			select *
			,(select cuenta_detalle from operaciones_libranza where id = deducciones_libranza.id_operacion_libranza) as cuenta_detalle
			from deducciones_libranza
			where RsNegocio.vr_desembolso between desembolso_inicial and desembolso_final
			      and id_ocupacion_laboral = 1
			      and id_operacion_libranza != 1
			      and reg_status=''

		LOOP

			--numCxP := serie_cxp_libranza();
			numNC_CxP = CxP_Cliente||'_'||ContaNC;
			MotivoDeduccion = Deducciones.descripcion;
			CuentaDetalle = Deducciones.cuenta_detalle;

			if ( Deducciones.valor_cobrar != 0 ) then
				_NewSaldoCliente = _NewSaldoCliente - Deducciones.valor_cobrar;
				ValorDeduccion = Deducciones.valor_cobrar;
				--raise notice '_Desembolso: %, valor_cobrar: %, Resultado: %', _DesembolsoCliente, Deducciones.valor_cobrar, Deducciones.valor_cobrar;
			end if;

			if ( Deducciones.perc_cobrar != 0 ) then
				_NewSaldoCliente = _NewSaldoCliente - (RsNegocio.vr_desembolso * (Deducciones.perc_cobrar/100));
				ValorDeduccion = (RsNegocio.vr_desembolso * (Deducciones.perc_cobrar/100));
				--raise notice '_Desembolso: %, perc_cobrar: %, Resultado: %', _DesembolsoCliente, Deducciones.perc_cobrar, (_DesembolsoCliente * (Deducciones.perc_cobrar/100));
			end if;

			if ( Deducciones.n_xmil != 0 ) then
				_NewSaldoCliente = _NewSaldoCliente - ((RsNegocio.vr_desembolso/1000)*Deducciones.n_xmil);
				ValorDeduccion = ((RsNegocio.vr_desembolso/1000)*Deducciones.n_xmil);
				--raise notice '_Desembolso: %, n_xmil: %, Resultado: %', _DesembolsoCliente, Deducciones.n_xmil, ((_DesembolsoCliente/1000)*Deducciones.n_xmil);
			end if;

			--_SaldoConDeducciones = _NewSaldoCliente;
			raise notice '_NewSaldoCliente_LI: %', _NewSaldoCliente;

			SumDeduccionLI = SumDeduccionLI + ValorDeduccion;
			--raise notice 'SumDeduccionLI: %', SumDeduccionLI;

			--SELECT INTO ReturnSP SP_CxPLibranza('TRANSFERENCIA', 'NC', _Usuario, numCxP, numNC_CxP, RsNegocio.cod_cli, RsNegocio.nombre, RsNegocio.cod_neg, VlrDesembolsoWdesc, 1::varchar, 'LC', CuentaDetalle, 'NOTA CREDITO GENERAL - '||Deducciones.descripcion, MotivoDeduccion);
		/*||*/	SELECT INTO ReturnSP SP_CxPLibranza('TRANSFERENCIA', 'NC', _Usuario, numCxP, numNC_CxP, RsNegocio.cod_cli, RsNegocio.nombre, RsNegocio.cod_neg, ValorDeduccion, 1::varchar, 'LC', CuentaDetalle, 'NOTA CREDITO GENERAL - '||Deducciones.descripcion, MotivoDeduccion);
			--raise notice 'FAP ES: si entra %',numCxP;
			ContaNC = ContaNC + 1;

		END LOOP;
		--

		TotalDeduccionLI = SumDeduccionLI;
		--NC -> Actualizamos la cxp operativamente.

		UPDATE fin.cxp_doc
		SET
                        vlr_neto = vlr_neto - _VlrFianza,
			vlr_neto_me = vlr_neto_me - _VlrFianza,
			vlr_total_abonos = TotalDeduccionLI,
			vlr_saldo = vlr_saldo - TotalDeduccionLI - _VlrFianza,
			vlr_total_abonos_me = TotalDeduccionLI,
			vlr_saldo_me = vlr_saldo_me - TotalDeduccionLI - _VlrFianza,
			last_update=now(),
			user_update=creation_user
		WHERE documento=CxP_Cliente
		      and tipo_documento='FAP'
		      and dstrct='FINV';

		--Actualiza el detalle de la cxp operativa
		UPDATE fin.cxp_items_doc
                       SET
                       vlr = vlr - _VlrFianza,
                       vlr_me = vlr_me - _VlrFianza
                WHERE documento=CxP_Cliente and tipo_documento='FAP' and proveedor = RsNegocio.cod_cli and dstrct='FINV';

                --Actualizamos tabla comprobantes en cabecera y detalle
                UPDATE con.comprobante
                       SET
                       total_debito = total_debito - _VlrFianza,
                       total_credito = total_credito - _VlrFianza
                WHERE numdoc=CxP_Cliente and tipodoc='FAP' and tercero = RsNegocio.cod_cli and dstrct='FINV';

                UPDATE con.comprodet
                       SET
                       valor_debito = CASE WHEN valor_debito > 0 THEN valor_debito - _VlrFianza ELSE valor_debito END,
                       valor_credito = CASE WHEN valor_credito > 0 THEN valor_credito - _VlrFianza ELSE valor_credito END
                WHERE numdoc=CxP_Cliente and tipodoc='FAP' and tercero = RsNegocio.cod_cli and dstrct='FINV';


		--ACTUALIZO LAS EL VALOR DE LAS DEDUCCIONES EN EL NEGOCIO.
		--UPDATE negocios SET valor_deducciones = valor_deducciones + TotalDeduccionLI WHERE cod_neg = _CodigoNegocio;

	END IF;


	/*----------------------------------
	--CxP a Terceros -> COMPRA CARTERA--
	------------------------------------*/
	TotalDeduccionCC = 0;

	--
	IF ( CompraCartera = 'S' ) THEN

		conta = 1;
		SumDeduccionCC = 0;
		--ContaNC = 1;

		FOR RsComprarCartera IN

			SELECT *
			FROM solicitud_obligaciones_comprar
			WHERE numero_solicitud = RsNegocio.numero_solicitud
			AND valor_comprar != 0
			AND reg_status=''
		LOOP

			numCxP := serie_cxp_libranza();

			--SELECT INTO ReturnSP SP_CxPLibranza('CHEQUE', 'FAP', _Usuario, numCxP, CxP_Cliente, RsNegocio.cod_cli, RsNegocio.nombre, RsNegocio.cod_neg, RsComprarCartera.valor_comprar, 1::varchar, 'LC', '23050940', 'CXP - CHEQUE A: '||RsNegocio.nombre, 'DESEMBOLSO - CHEQUE A: '||RsNegocio.cod_cli);
			SELECT INTO ReturnSP SP_CxPLibranza('CHEQUE', 'FAP', _Usuario, numCxP, CxP_Cliente, RsComprarCartera.nit_entidad, RsComprarCartera.entidad, RsNegocio.cod_neg, RsComprarCartera.valor_comprar, 1::varchar, 'LC', '23050940', 'CXP - CHEQUE A: '||RsNegocio.nombre, 'DESEMBOLSO - CHEQUE A: '||RsNegocio.cod_cli);

			/********************************************************
			*     GENERAMOS NC -> CxP de Compra de Obligaciones     *
			*********************************************************/
			_NewSaldoCliente = RsComprarCartera.valor_comprar;

			--Cheques
			FOR Deducciones IN

				select *
				,(select cuenta_detalle from operaciones_libranza where id = deducciones_libranza.id_operacion_libranza) as cuenta_detalle
				from deducciones_libranza
				where RsComprarCartera.valor_comprar between desembolso_inicial and desembolso_final
				      and id_ocupacion_laboral = 1
				      and id_operacion_libranza = 1
				      AND reg_status=''
			LOOP

				--numCxP := serie_cxp_libranza();
				numNC_CxP = CxP_Cliente||'_'||ContaNC;
				MotivoDeduccion = Deducciones.descripcion;
				CuentaDetalle = Deducciones.cuenta_detalle;

				if ( Deducciones.valor_cobrar != 0 ) then
					_NewSaldoCliente = _NewSaldoCliente - Deducciones.valor_cobrar;
					ValorDeduccion = Deducciones.valor_cobrar;
					--raise notice '_Desembolso: %, valor_cobrar: %, Resultado: %', _DesembolsoCliente, Deducciones.valor_cobrar, Deducciones.valor_cobrar;
				end if;

				if ( Deducciones.perc_cobrar != 0 ) then
					_NewSaldoCliente = _NewSaldoCliente - (RsComprarCartera.valor_comprar * (Deducciones.perc_cobrar/100));
					ValorDeduccion = (RsComprarCartera.valor_comprar * (Deducciones.perc_cobrar/100));
					--raise notice '_Desembolso: %, perc_cobrar: %, Resultado: %', _DesembolsoCliente, Deducciones.perc_cobrar, (_DesembolsoCliente * (Deducciones.perc_cobrar/100));
				end if;

				if ( Deducciones.n_xmil != 0 ) then
					_NewSaldoCliente = _NewSaldoCliente - ((RsComprarCartera.valor_comprar/1000)*Deducciones.n_xmil);
					ValorDeduccion = ((RsComprarCartera.valor_comprar/1000)*Deducciones.n_xmil);
					--raise notice '_Desembolso: %, n_xmil: %, Resultado: %', _DesembolsoCliente, Deducciones.n_xmil, ((_DesembolsoCliente/1000)*Deducciones.n_xmil);
				end if;

				--_SaldoConDeducciones = _NewSaldoCliente;
				raise notice '_NewSaldoCliente_CC: %', _NewSaldoCliente;

				SumDeduccionCC = SumDeduccionCC + ValorDeduccion;

				--NC -> Cabecera nota credito.
				SELECT INTO ReturnSP SP_CxPLibranza('TRANSFERENCIA', 'NC', _Usuario, numCxP, numNC_CxP, RsNegocio.cod_cli, RsNegocio.nombre, RsNegocio.cod_neg, ValorDeduccion, 1::varchar, 'LC', CuentaDetalle, 'NOTA CREDITO DESCUENTO POR '||Deducciones.descripcion, MotivoDeduccion);
				--raise notice 'la nc es: %',numCxP;
				ContaNC = ContaNC + 1;

			END LOOP;
			--

			conta = conta + 1;

		END LOOP;
		--

		TotalDeduccionCC = SumDeduccionCC;
		--NC -> Actualizamos la cxp operativamente.

		UPDATE fin.cxp_doc
			SET
                        vlr_neto = vlr_neto - (CASE WHEN sw THEN _VlrFianza ELSE 0 END) ,
			vlr_neto_me = vlr_neto_me - (CASE WHEN sw THEN _VlrFianza ELSE 0 END) ,
			vlr_total_abonos = vlr_total_abonos + TotalDeduccionCC,
			vlr_saldo = vlr_saldo - TotalDeduccionCC -  (CASE WHEN sw THEN _VlrFianza ELSE 0 END) ,
			vlr_total_abonos_me= vlr_total_abonos_me + TotalDeduccionCC,
			vlr_saldo_me = vlr_saldo_me - TotalDeduccionCC -  (CASE WHEN sw THEN _VlrFianza ELSE 0 END) ,
			last_update=now(),
			user_update=creation_user
		WHERE documento=CxP_Cliente and tipo_documento='FAP' and dstrct='FINV';

		--Actualiza el detalle de la cxp operativa
		UPDATE fin.cxp_items_doc
                       SET
                       vlr = vlr -  (CASE WHEN sw THEN _VlrFianza ELSE 0 END) ,
                       vlr_me = vlr_me -  (CASE WHEN sw THEN _VlrFianza ELSE 0 END)
                WHERE documento=CxP_Cliente and tipo_documento='FAP' and proveedor = RsNegocio.cod_cli and dstrct='FINV';

                --Actualizamos tabla comprobantes en cabecera y detalle
                UPDATE con.comprobante
                       SET
                       total_debito = total_debito - (CASE WHEN sw THEN _VlrFianza ELSE 0 END),
                       total_credito = total_credito -  (CASE WHEN sw THEN _VlrFianza ELSE 0 END)
                WHERE numdoc=CxP_Cliente and tipodoc='FAP' and tercero = RsNegocio.cod_cli and dstrct='FINV';

                UPDATE con.comprodet
                       SET
                       valor_debito = CASE WHEN valor_debito > 0 THEN valor_debito - (CASE WHEN sw THEN _VlrFianza ELSE 0 END)  ELSE valor_debito END,
                       valor_credito = CASE WHEN valor_credito > 0 THEN valor_credito - (CASE WHEN sw THEN _VlrFianza ELSE 0 END) ELSE valor_credito END
                WHERE numdoc=CxP_Cliente and tipodoc='FAP' and tercero = RsNegocio.cod_cli and dstrct='FINV';


		--ACTUALIZO LAS EL VALOR DE LAS DEDUCCIONES EN EL NEGOCIO.
		UPDATE negocios SET valor_deducciones = valor_deducciones + TotalDeduccionCC WHERE cod_neg = _CodigoNegocio;

	END IF;
	--GENERAMOS LA CXP DE FIANZA SI APLICA
	IF(TieneFianza = 'S') THEN
                SELECT INTO numCxP get_lcod_fianza_libranza('CXP_FIANZA_LBT');
		CxP_Fianza = numCxP;
	raise notice 'cxp Fianza ES: si entra %',CxP_Fianza;
              	--RsConfigFianza.nit_empresa
		SELECT INTO ReturnSP SP_CxPFianza('TRANSFERENCIA', 'FAP', _Usuario, numCxP, '', RsNegocio.cod_cli, RsConfigFianza.nombre_empresa, RsNegocio.cod_neg, _VlrFianza, 1::varchar, cmc_factura_fz, vectorCuentasFianza[2], 'CXP A ', 'DESCUENTO FIANZA A ');
		--INSERTAMOS EN TABLA DE CONTROL FIANZA
		INSERT INTO administrativo.historico_deducciones_fianza (reg_status,dstrct,periodo_corte,nit_empresa_fianza,nit_cliente,documento_relacionado,
		    negocio,plazo,valor_negocio,valor_desembolsado,subtotal_fianza,valor_iva,valor_fianza,fecha_vencimiento,id_unidad_negocio,id_convenio,creation_user,creation_date,agencia)
		    VALUES('','FINV',replace(substring(now()::date,1,7),'-',''),RsConfigFianza.nit_empresa,RsNegocio.cod_cli,CxP_Fianza,_CodigoNegocio,RsNegocio.nro_docs,round(RsNegocio.vr_negocio),round(RsNegocio.vr_desembolso),
		    round(_SubtotalFianza),round(_VlrIvaFianza),round(_VlrFianza),TO_CHAR(DATE_TRUNC('month', CURRENT_DATE)
		    + INTERVAL '1 month'- INTERVAL '1 day','YYYY-MM-DD')::timestamp without time zone,22,RsNegocio.id_convenio,_usuario,now(),RsNegocio.agencia);

        END IF;



	RETURN _respuesta;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_contabilizarlibranza(character varying, character varying, character varying, text)
  OWNER TO postgres;
