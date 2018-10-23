-- Function: sp_auditoria_ingresos(numeric, character varying)

-- DROP FUNCTION sp_auditoria_ingresos(numeric, character varying);

CREATE OR REPLACE FUNCTION sp_auditoria_ingresos(periodoasignacion numeric, usuarioact character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE

	CarteraGeneral record;
	CarteraGeneralTwo record;
	cuentasRecord record;
	cuentasRecordIngDesc record;
	cuentasRecordTotal record;
	ClienteRec record;
	FacturaActual record;
	NegocioAvales record;
	_ConceptRec record;
	_Sancion record;
	_sanciofa record;
	NegocioArray record;
	_SancionFacts record;

	CarteraAval record;
	CarteraSeguro record;
	NegocioSeguro record;
	NegocioSeguros record;
	_sanciofaval record ;

	FechaCortePeriodo varchar;
	VencimientoMayor varchar;
	FechaMayor varchar;
	VerifyDetails varchar;
	numero_ingreso varchar :='';
	numero_ingreso_aux varchar :='';
	numero_negocio_aux  varchar :='';
	fecha_ultimo_pago varchar:='';

	fecha_ultimo_pago_aval varchar :='';
	numero_negocio_aux_aval varchar:= '';
	_cuentas_gac varchar = '';
	_cuentas_ixm varchar = '';
	fechaCorte varchar :='';
	fechaCorte_aval varchar :='';
	fechaCorte_seguro varchar :='';
	numero_ingreso_aval varchar:='';
	numero_ingreso_aux_aval varchar:='';
	numero_ingreso_seguro varchar:='';
	numero_ingreso_aux_seguro varchar:='';

	NegocioSecundario varchar := '';
	NegocioVctoMayor varchar := '';
	NumIngresoSelect varchar := '';

	UnidadNegocio record;

	PeriodoNow numeric;
	PeriodoFoto numeric;
	PeriodoCorte numeric;
	PeriodoVctoMayor numeric;
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
	vlr_cxc_aval numeric;
	vlr_cxc_seguro numeric;
	contador numeric :=0;

	_SumIxM_Aval numeric := 0;
	_SumGaC_Aval numeric := 0;
	BolsaSaldoAval numeric := 0;
	vlor_ingreso_aval numeric := 0;
	vlr_gac_ingreso_aval numeric :=0;
	vlr_ixm_ingreso_aval numeric :=0;

	BolsaSaldoSeguro numeric := 0;
	_sancioseguro record;
	vlor_ingreso_seguro numeric:= 0;
	vlr_gac_ingreso_seguro numeric :=0;
	vlr_ixm_ingreso_seguro numeric :=0;
	fecha_ultimo_pago_seguro varchar:='';
	_SumIxM_Seguro numeric := 0;
	_SumGaC_Seguro numeric:= 0;

	_G16252145 numeric = 0;
	_G94350302 numeric = 0;
	_GI010010014205 numeric = 0;
	_I16252147 numeric = 0;
	_I94350301 numeric = 0;
	_II010010014170 numeric = 0;

	_I010140014170 numeric = 0;
	_I010140014205 numeric = 0;

	_I28150530 numeric = 0;
	_I28150531 numeric = 0;

	resta numeric = 0;
	CantAuxAuditar numeric = 0;
	CantComprodet numeric = 0;

	buscaraval boolean :=false;
	buscarseguro boolean := false;
	ControlPago boolean := true;
	ControlIngreso boolean := true;

	sql_detalle TEXT;

BEGIN

	--Debe ser un delete...
	--TRUNCATE tem.tabla_array_sanciones;
	DELETE FROM tem.tabla_array_sanciones WHERE usuario = UsuarioAct;

	if ( substring(PeriodoAsignacion,5) = '01' ) then
		PeriodoTramo = substring(PeriodoAsignacion,1,4)::numeric-1||'12';
	else
		PeriodoTramo = PeriodoAsignacion::numeric - 1;
	end if;


	PeriodoNow = PeriodoAsignacion; --replace(substring(now()::date,1,7),'-','')::numeric;
	PeriodoFoto = PeriodoAsignacion::numeric;
	PeriodoCorte = PeriodoTramo::numeric;

	select into FechaCortePeriodo to_char(to_timestamp(substring(PeriodoCorte,1,4)::numeric || '-' || to_char(substring(PeriodoCorte,5,2)::numeric,'FM00') || '-01', 'YYYY-MM-DD') + INTERVAL '1 month' - INTERVAL '1 days', 'YYYY-MM-DD');

	SELECT INTO CantComprodet count(distinct a.numdoc)
	FROM con.comprodet a
	     INNER JOIN con.comprobante b ON (b.tipodoc = a.tipodoc AND b.numdoc = a.numdoc AND b.grupo_transaccion = a.grupo_transaccion)
	     LEFT  JOIN con.tipo_docto  c ON (c.codigo  = a.tipodoc)
	WHERE a.dstrct = 'FINV'
	    AND a.cuenta in ('16252145','94350302','I010010014205','I010130014205','16252147','94350301','I010010014170','I010130024170','I010140014170','I010140014205','28150530','28150531')
	    AND b.periodo = PeriodoNow
	    --and a.numdoc in ('IC210940','IC211328')
	    AND a.reg_status = '';


	SELECT INTO CantAuxAuditar count(0) FROM tem.aux_auditar_sancion WHERE periodo = PeriodoNow;

	IF ( CantAuxAuditar < CantComprodet ) THEN

		if ( CantAuxAuditar > 0 ) then
			delete from tem.aux_auditar_sancion where periodo = PeriodoNow;
		end if;

		INSERT INTO tem.aux_auditar_sancion
		SELECT distinct on (numdoc)
			a.dstrct, a.cuenta, a.auxiliar, a.periodo, b.fechadoc, a.tipodoc, coalesce(UPPER(c.descripcion), a.tipodoc ) as tipodoc_desc,
			a.numdoc
			,a.detalle
			,a.abc, a.valor_debito, a.valor_credito
			,a.tercero, CASE WHEN a.tercero != '' THEN get_nombrenit(a.tercero) ELSE '' END as nombre_tercero,a.tipodoc_rel
			,CASE WHEN a.documento_rel = '' THEN (select numero_remesa from con.factura_detalle where documento = a.numdoc and numero_remesa != '' limit 1) else a.documento_rel END as documento_rel
			,a.vlr_for, b.moneda_foranea
			,a.tipo_referencia_1
			,CASE WHEN b.tipodoc in ('ING','ICA') THEN (select negasoc from con.factura where documento = (select documento from con.ingreso_detalle where num_ingreso = b.numdoc and item = 1)) END as referencia_1
			,a.tipo_referencia_2
			,a.referencia_2
			,a.tipo_referencia_3
			,a.referencia_3
		FROM con.comprodet a
		     INNER JOIN con.comprobante b ON (b.tipodoc = a.tipodoc AND b.numdoc = a.numdoc AND b.grupo_transaccion = a.grupo_transaccion)
		     LEFT  JOIN con.tipo_docto  c ON (c.codigo  = a.tipodoc)
		WHERE a.dstrct = 'FINV'
		    AND a.cuenta in ('16252145','94350302','I010010014205','I010130014205','16252147','94350301','I010010014170','I010130024170','I010140014170','I010140014205','28150530','28150531')
		    AND b.periodo = PeriodoNow
		    AND a.reg_status = ''
		    --and a.numdoc in ('IC210940','IC211328')
		ORDER BY a.numdoc;

	END IF;
	--

	FOR CarteraGeneral IN

		select
			''::varchar as negocio,
			tercero::varchar as cedula,
			nombre_tercero::varchar as nombre_cliente,
			''::varchar as vencimiento_mayor,
			''::varchar as fecha_pago_ingreso, --fecha_consignacion
			''::varchar as fecha_vencimiento_mayor,
			''::varchar as diferencia_pago,
			0::numeric as valor_saldo_foto,
			0::numeric as interes_mora,
			0::numeric as gasto_cobranza,
			numdoc::varchar as num_ingreso,
			valor_credito::numeric as valor_ingreso,
			0::numeric as valor_cxc_ingreso,
			0::numeric as G16252145,
			0::numeric as G94350302,
			0::numeric as GI010010014205,
			0::numeric as GI010130014205, --
			0::numeric as I16252147,
			0::numeric as I94350301,
			0::numeric as II010010014170,
			0::numeric as II010130024170, --

			0::numeric as I010140014170,
			0::numeric as I010140014205,

			0::numeric as I28150530, --Fenalco
			0::numeric as I28150531, --Microcredito

			0::numeric as valor_ixm_ingreso,
			0::numeric as valor_gac_ingreso,

			''::varchar as convenio

		from tem.aux_auditar_sancion where periodo = periodoasignacion --and numdoc in ('IA424791') -- IA420686|IC187242|IC188365|IA420577|IA414770|IA420565 numdoc in ('IC184953','IC180335','IC183888') | numdoc = 'IA414770' 'IA414768','IA414769',

	LOOP
		contador :=contador+1;

		raise notice 'Item: %  IngresoNo: %', contador, CarteraGeneral.num_ingreso;

		--SANCIONES
		_SumIxM = 0;
		_SumGaC = 0;

		--VALORES CxC
		vlr_cxc = 0;
		vlr_gac_ingreso :=0;
		vlr_ixm_ingreso :=0;

		_cuentas_gac = '';
		_cuentas_ixm = '';

		_G16252145 = 0;
		_G94350302 = 0;
		_GI010010014205 = 0;
		_I16252147 = 0;
		_I94350301 = 0;
		_II010010014170 = 0;

		_I010140014170 = 0;
		_I010140014205 = 0;

		_I28150530 = 0;
		_I28150531 = 0;

		numero_ingreso = '';

		--VALIDACION PARA CONSULTAR SOLO UNA VEZ POR NEGOCIO.
		buscaraval := true;
		buscarseguro := true;

		ControlIngreso = false;

		----------------------------------------------------------------------------------------------------------
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
				AND fra.negasoc in (
							SELECT (select negasoc from con.factura where documento = id.factura) as negocio
							FROM con.ingreso_detalle id
							INNER JOIN con.ingreso i ON (id.num_ingreso = i.num_ingreso and id.dstrct = i.dstrct and i.nitcli=id.nitcli )
							WHERE id.dstrct = 'FINV'
								and id.tipo_documento in ('ING','ICA')
								and i.reg_status = ''
								and id.reg_status = ''
								and id.factura != ''
								and i.num_ingreso = CarteraGeneral.num_ingreso
							group by (select negasoc from con.factura where documento = id.factura)

				)
				AND fra.tipo_documento in ('FAC','NDC')
				AND substring(fra.documento,1,2) not in ('CP','FF','DF')
				AND fra.periodo_lote = periodoasignacion
				AND replace(substring(fra.fecha_vencimiento,1,7),'-','')::numeric <= periodoasignacion
		) tabla2;

		if found then
			CarteraGeneral.vencimiento_mayor = VencimientoMayor;
			raise notice 'VencimientoMayor: %',VencimientoMayor;
		end if;
		----------------------------------------------------------------------------------------------------------

		FOR cuentasRecord in

			SELECT
				i.num_ingreso,
				i.fecha_consignacion::varchar,
				i.vlr_ingreso as valor_ingreso_cabe,
				(select negasoc from con.factura where documento = id.factura) as negocio,
				--(select id_convenio from negocios where cod_neg = (select negasoc from con.factura where documento = id.factura)) as convenio,
				id.cuenta,
				sum(id.valor_ingreso) as valor_ingreso_det
			FROM con.ingreso_detalle id
			INNER JOIN con.ingreso i ON (id.num_ingreso = i.num_ingreso and id.dstrct = i.dstrct and i.nitcli=id.nitcli )
			WHERE id.dstrct = 'FINV'
				and id.tipo_documento in ('ING','ICA')
				and i.reg_status = ''
				and id.reg_status = ''
				and i.num_ingreso = CarteraGeneral.num_ingreso
			GROUP BY i.num_ingreso,i.fecha_consignacion,i.vlr_ingreso, id.cuenta, negocio--, convenio
			ORDER BY fecha_consignacion::date desc, num_ingreso

		LOOP
			raise notice 'NEGOCIO PRINCIPAL: %',cuentasRecord.negocio;

			NegocioSecundario = '';

			CarteraGeneral.G16252145 = 0;
			CarteraGeneral.G94350302 = 0;
			CarteraGeneral.GI010010014205 = 0;
			CarteraGeneral.GI010130014205 = 0;

			CarteraGeneral.I16252147 = 0;
			CarteraGeneral.I94350301 = 0;
			CarteraGeneral.II010010014170 = 0;
			CarteraGeneral.II010130024170 = 0;

			CarteraGeneral.I010140014170 = 0;
			CarteraGeneral.I010140014205 = 0;

			CarteraGeneral.I28150530 = 0;
			CarteraGeneral.I28150531 = 0;

			CarteraGeneral.valor_cxc_ingreso = 0;

			IF ( cuentasRecord.cuenta = '16252145' ) THEN

				--vlr_gac_ingreso = vlr_gac_ingreso + cuentasRecord.valor_ingreso_det;
				--_G16252145 = _G16252145 + cuentasRecord.valor_ingreso_det;
				CarteraGeneral.G16252145 = cuentasRecord.valor_ingreso_det;

			ELSIF ( cuentasRecord.cuenta = '94350302' ) THEN

				--vlr_gac_ingreso = vlr_gac_ingreso + cuentasRecord.valor_ingreso_det;
				--_G94350302 = _G94350302 + cuentasRecord.valor_ingreso_det;
				CarteraGeneral.G94350302 = cuentasRecord.valor_ingreso_det;

			ELSIF ( cuentasRecord.cuenta = 'I010010014205' ) THEN

				--vlr_gac_ingreso = vlr_gac_ingreso + cuentasRecord.valor_ingreso_det;
				--_GI010010014205 = _GI010010014205 + cuentasRecord.valor_ingreso_det;
				CarteraGeneral.GI010010014205 = cuentasRecord.valor_ingreso_det;

			ELSIF ( cuentasRecord.cuenta = '16252147' ) THEN

				--vlr_ixm_ingreso = vlr_ixm_ingreso + cuentasRecord.valor_ingreso_det;
				--_I16252147 = _I16252147 + cuentasRecord.valor_ingreso_det;
				CarteraGeneral.I16252147 = cuentasRecord.valor_ingreso_det;

			ELSIF ( cuentasRecord.cuenta = '94350301' ) THEN

				--vlr_ixm_ingreso = vlr_ixm_ingreso + cuentasRecord.valor_ingreso_det;
				--_I94350301 = _I94350301 + cuentasRecord.valor_ingreso_det;
				CarteraGeneral.I94350301 = cuentasRecord.valor_ingreso_det;

			ELSIF ( cuentasRecord.cuenta = 'I010010014170' ) THEN

				--vlr_ixm_ingreso = vlr_ixm_ingreso + cuentasRecord.valor_ingreso_det;
				--_II010010014170 = _II010010014170 + cuentasRecord.valor_ingreso_det;
				CarteraGeneral.II010010014170 = cuentasRecord.valor_ingreso_det;

			ELSIF ( cuentasRecord.cuenta = 'I010130014205' ) THEN

				CarteraGeneral.GI010130014205 = cuentasRecord.valor_ingreso_det;

			ELSIF ( cuentasRecord.cuenta = 'I010130024170' ) THEN

				CarteraGeneral.II010130024170 = cuentasRecord.valor_ingreso_det;

			---------------------------------------------
			ELSIF ( cuentasRecord.cuenta = 'I010140014170' ) THEN

				CarteraGeneral.I010140014170 = cuentasRecord.valor_ingreso_det;

			ELSIF ( cuentasRecord.cuenta = 'I010140014205' ) THEN

				CarteraGeneral.I010140014205 = cuentasRecord.valor_ingreso_det;
			---------------------------------------------

			---------------------------------------------
			ELSIF ( cuentasRecord.cuenta = '28150530' ) THEN

				CarteraGeneral.I28150530 = cuentasRecord.valor_ingreso_det;

			ELSIF ( cuentasRecord.cuenta = '28150531' ) THEN

				CarteraGeneral.I28150531 = cuentasRecord.valor_ingreso_det;
			---------------------------------------------

			ELSE
				--vlr_cxc = vlr_cxc + cuentasRecord.valor_ingreso_det;
				--vlr_cxc = cuentasRecord.valor_ingreso_det;
				CarteraGeneral.valor_cxc_ingreso = cuentasRecord.valor_ingreso_det;

				IF ( cuentasRecord.cuenta ilike '2380%' ) THEN

					ControlIngreso = TRUE;
					raise notice 'ControlIngreso: %',ControlIngreso;

					FOR cuentasRecordIngDesc in

						SELECT
							i.num_ingreso,
							i.descripcion_ingreso,
							i.fecha_consignacion::varchar,
							i.vlr_ingreso as valor_ingreso_cabe,
							(select negasoc from con.factura where documento = id.factura) as negocio,
							id.cuenta,
							id.factura,
							sum(id.valor_ingreso) as valor_ingreso_det
						FROM con.ingreso_detalle id
						INNER JOIN con.ingreso i ON (id.num_ingreso = i.num_ingreso and id.dstrct = i.dstrct and i.nitcli=id.nitcli )
						WHERE id.dstrct = 'FINV'
							and id.tipo_documento in ('ING','ICA')
							and i.reg_status = ''
							and id.reg_status = ''
							and substring(descripcion_ingreso,1,8) = CarteraGeneral.num_ingreso
						GROUP BY i.num_ingreso,i.descripcion_ingreso,i.fecha_consignacion,i.vlr_ingreso, id.cuenta, id.factura, negocio--, convenio
						ORDER BY fecha_consignacion::date desc, num_ingreso
					LOOP

						IF ( cuentasRecordIngDesc.negocio is not null ) THEN
							NegocioSecundario = cuentasRecordIngDesc.negocio;
							raise notice 'NEGOCIO SECUNDARIO: %',cuentasRecordIngDesc.negocio;
						END IF;

					END LOOP;


				END IF;

			END IF;
			--
			raise notice 'FechaCortePeriodo: %, PeriodoFoto: %',FechaCortePeriodo, PeriodoFoto;

			IF ( NegocioSecundario != '' ) THEN

				NegocioVctoMayor = cuentasRecordIngDesc.negocio;
				NumIngresoSelect = cuentasRecordIngDesc.num_ingreso;
				PeriodoVctoMayor = PeriodoTramo; --PeriodoFoto-1;

				SELECT INTO UnidadNegocio ruc.id_convenio, un.*
				FROM rel_unidadnegocio_convenios ruc, unidad_negocio un
				WHERE ruc.id_unid_negocio = un.id
				AND id_convenio IN (select id_convenio from negocios where cod_neg = cuentasRecordIngDesc.negocio)
				AND id_unid_negocio in (1,2,3,4,5,6,7,8,9,10,11);

				raise notice 'UnidadNegocioSecundario: %',UnidadNegocio.descripcion;

				CarteraGeneral.convenio = UnidadNegocio.descripcion;

			ELSE
				NegocioVctoMayor = cuentasRecord.negocio;
				NumIngresoSelect = cuentasRecord.num_ingreso;
				PeriodoVctoMayor = PeriodoFoto;
			END IF;
			/*
			raise notice 'NegocioVctoMayor: %',NegocioVctoMayor;

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
					AND fra.negasoc = NegocioVctoMayor --cuentasRecord.negocio
					AND fra.tipo_documento in ('FAC','NDC')
					AND substring(fra.documento,1,2) not in ('CP','FF','DF')
					AND fra.periodo_lote = PeriodoVctoMayor --PeriodoFoto
					AND replace(substring(fra.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoFoto
				 GROUP BY negasoc

			) tabla2;

			if found then
				CarteraGeneral.vencimiento_mayor = VencimientoMayor;
				raise notice 'VencimientoMayor: %',VencimientoMayor;
			end if;
			*/
			SELECT INTO FechaMayor max(fecha_vencimiento) as maxdia
			FROM con.foto_cartera fra
			WHERE fra.dstrct = 'FINV'
				AND fra.valor_saldo > 0
				AND fra.reg_status = ''
				AND fra.negasoc = NegocioVctoMayor --cuentasRecord.negocio
				AND fra.tipo_documento in ('FAC','NDC')
				AND substring(fra.documento,1,2) not in ('CP','FF','DF')
				AND fra.periodo_lote = PeriodoVctoMayor --PeriodoFoto
				AND replace(substring(fra.fecha_vencimiento,1,7),'-','')::numeric < PeriodoFoto
			GROUP BY negasoc;

			if found then
				--CarteraGeneral.vencimiento_mayor = VencimientoMayor;
				CarteraGeneral.fecha_vencimiento_mayor = FechaMayor;
				raise notice 'FechaMayor: %',FechaMayor;
			end if;

			CarteraGeneral.valor_ingreso = cuentasRecord.valor_ingreso_cabe;
			CarteraGeneral.fecha_pago_ingreso = cuentasRecord.fecha_consignacion; --fecha_consignacion
			CarteraGeneral.negocio = cuentasRecord.negocio;
			--CarteraGeneral.convenio = cuentasRecord.convenio;

			IF ( cuentasRecord.negocio is not null ) THEN

				raise notice 'NEGOCIO ES: %',cuentasRecord.negocio;

				INSERT INTO tem.tabla_array_sanciones(creation_date, negocio, usuario) VALUES (now(), cuentasRecord.negocio, UsuarioAct);

				SELECT INTO UnidadNegocio ruc.id_convenio, un.*
				FROM rel_unidadnegocio_convenios ruc, unidad_negocio un
				WHERE ruc.id_unid_negocio = un.id
				AND id_convenio IN (select id_convenio from negocios where cod_neg = cuentasRecord.negocio)
				AND id_unid_negocio in (1,2,3,4,5,6,7,8,9,10,11);

				raise notice 'UnidadNegocio: %',UnidadNegocio.descripcion;

				CarteraGeneral.convenio = UnidadNegocio.descripcion;

				--IF(fecha_ultimo_pago != '') THEN
				IF ( cuentasRecord.fecha_consignacion != '' ) THEN
					resta := cuentasRecord.fecha_consignacion::date - FechaMayor::date;
					--fechaCorte := cuentasRecord.fecha_consignacion;
					fechaCorte := FechaCortePeriodo;
					--raise notice 'fecha_consignacion: %, FechaMayor: %',cuentasRecord.fecha_consignacion, FechaMayor;
				ELSE
					resta := -1;
					--fechaCorte := FechaCortePeriodo::date +  INTERVAL '1 month';
				END IF;

				--raise notice 'RestoCalcularDebidos: %, fecha_ultimo_pago: %, fecha_vencimiento: %',resta, fecha_ultimo_pago, FechaMayor;
				--IF(resta > 0 )THEN

				       --SANCIONES
					_SumIxM = 0;
					_SumGaC = 0;

					--BolsaSaldo = CarteraGeneral.valor_saldo;

					IF ( UnidadNegocio.descripcion = 'MICROCREDITO' ) THEN

						sql_detalle = 'SELECT f.valor_saldo::numeric as valor_unitario, f.documento, f.fecha_vencimiento,
								(
								SELECT SUM(valor_saldo)
								FROM con.foto_cartera f
								WHERE f.negasoc = '''||cuentasRecord.negocio|| '''
								AND f.periodo_lote = '||PeriodoFoto|| '
								AND f.reg_status = ''''
								AND substring(f.documento,1,2) not in (''CP'',''FF'',''DF'')
								AND replace(substring(f.fecha_vencimiento,1,7),''-'','''')::numeric <= '||PeriodoFoto|| '
								AND f.valor_saldo > 0
								)::numeric as valor_saldo
								FROM con.foto_cartera f
								WHERE f.negasoc = '''||cuentasRecord.negocio|| '''
								AND f.periodo_lote = '||PeriodoFoto|| '
								AND f.reg_status = ''''
								AND substring(f.documento,1,2) not in (''CP'',''FF'',''DF'')
								AND replace(substring(f.fecha_vencimiento,1,7),''-'','''')::numeric <= '||PeriodoFoto|| '
								AND f.valor_saldo > 0
								AND f.documento in (select factura from con.ingreso_detalle where num_ingreso = '''||CarteraGeneral.num_ingreso|| ''' and factura != '''')';
								--raise notice 'sql_detalle: %',sql_detalle;
					ELSE
						sql_detalle = 'SELECT f.valor_saldo::numeric, f.fecha_vencimiento, fd.valor_unitario::numeric, fd.documento, fd.descripcion
								FROM con.foto_cartera f, con.factura_detalle fd
								WHERE f.documento = fd.documento
								AND f.negasoc = '''||NegocioVctoMayor|| '''
								AND f.periodo_lote = '||PeriodoFoto|| '
								AND f.reg_status = ''''
								AND substring(f.documento,1,2) not in (''CP'',''FF'',''DF'')
								AND replace(substring(f.fecha_vencimiento,1,7),''-'','''')::numeric <= '||PeriodoFoto|| '
								AND f.valor_saldo > 0
								AND f.documento in (select factura from con.ingreso_detalle where num_ingreso = '''||NumIngresoSelect|| ''' and factura != '''')';
					END IF;

					FOR _sanciofa IN EXECUTE sql_detalle LOOP
						raise notice 'sql_detalle: %', sql_detalle;
						--raise notice 'VALOR_SALDO: %', _sanciofa.valor_saldo;
						IF ( UnidadNegocio.descripcion = 'MICROCREDITO' ) THEN

							VerifyDetails = 'S';
							_Base = _sanciofa.valor_unitario;

						ELSE

							BolsaSaldo = _sanciofa.valor_saldo;

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

						END IF;

						--raise notice 'VerifyDetails: %',VerifyDetails;
						if ( VerifyDetails = 'S' ) then

							--Conceptos
							--	SELECT INTO _ConceptRec * FROM conceptos_recaudo WHERE prefijo = _sanciofa.descripcion AND (fechaCorte::date - _sanciofa.fecha_vencimiento::date ) BETWEEN dias_rango_ini AND dias_rango_fin and id_unidad_negocio = UnidadNegocio.id;
							IF ( UnidadNegocio.descripcion = 'MICROCREDITO' ) THEN
								SELECT INTO _ConceptRec * FROM conceptos_recaudo WHERE prefijo = substring(_sanciofa.documento,1,2) AND (fechaCorte::date - _sanciofa.fecha_vencimiento ) BETWEEN dias_rango_ini AND dias_rango_fin and id_unidad_negocio = UnidadNegocio.id;
								raise notice 'CODIGO: %, factura: %, descripcion: %, fechaCorte: %, fecha_vencimiento: %, dias: %',_ConceptRec.id, _sanciofa.documento, substring(_sanciofa.documento,1,2), fechaCorte::date, _sanciofa.fecha_vencimiento::date, fechaCorte::date - _sanciofa.fecha_vencimiento::date;
							ELSE
								SELECT INTO _ConceptRec * FROM conceptos_recaudo WHERE prefijo = _sanciofa.descripcion AND (fechaCorte::date - _sanciofa.fecha_vencimiento::date ) BETWEEN dias_rango_ini AND dias_rango_fin and id_unidad_negocio = UnidadNegocio.id;
								raise notice 'CODIGO: %, factura: %, descripcion: %, fechaCorte: %, fecha_vencimiento: %, dias: %',_ConceptRec.id, _sanciofa.documento, _sanciofa.descripcion, fechaCorte::date, _sanciofa.fecha_vencimiento::date, fechaCorte::date - _sanciofa.fecha_vencimiento::date;
							END IF;

							FOR _Sancion IN

								SELECT * FROM sanciones_condonaciones
								WHERE id_tipo_acto = 1
									AND id_conceptos_recaudo = _ConceptRec.id
									AND (fechaCorte::date - _sanciofa.fecha_vencimiento::date ) BETWEEN dias_rango_ini AND dias_rango_fin
									AND periodo = periodoasignacion and id_unidad_negocio = UnidadNegocio.id
							LOOP

								IF ( _Sancion.categoria = 'IXM' ) THEN

									if (  fechaCorte::date > _sanciofa.fecha_vencimiento::date ) then --if ( now()::date > CarteraxCuota.fecha_vencimiento::date ) then
										raise notice 'PASA - IXM!';
										select into _Tasa tasa_interes/100 from convenios where id_convenio = UnidadNegocio.id_convenio; --(select id_convenio from negocios where cod_neg = cuentasRecord.negocio);

										_IxM = ROUND( _Base *(_Tasa/30) * (fechaCorte::date - _sanciofa.fecha_vencimiento)::numeric );
										_SumIxM = _SumIxM + _IxM;
									end if;

								END IF;

								IF ( _Sancion.categoria = 'GAC' ) THEN
									raise notice 'PASA - GAC!';
									if ( fechaCorte::date  > _sanciofa.fecha_vencimiento::date ) then --if ( now()::date > CarteraxCuota.fecha_vencimiento::date ) then
										_GaC = ROUND(( _Base * _Sancion.porcentaje::numeric)/100);
										_SumGaC = _SumGaC + _GaC;
									end if;

								END IF;

							END LOOP;
						end if;

						CarteraGeneral.valor_saldo_foto = _sanciofa.valor_saldo::numeric;

					END LOOP;

					CarteraGeneral.interes_mora= _SumIxM;
					CarteraGeneral.gasto_cobranza= _SumGaC;

				--END IF;

			END IF;
			--

			--Se restringen algunos campos
			IF ( cuentasRecord.negocio is null ) THEN

				CarteraGeneral.negocio = 'SANCION INGRESO No: ' || cuentasRecord.num_ingreso;
				--CarteraGeneral.fecha_pago_ingreso = '';
				--CarteraGeneral.cedula = '';
				--CarteraGeneral.nombre_cliente = '';
				CarteraGeneral.interes_mora = 0;
				CarteraGeneral.gasto_cobranza = 0;
				CarteraGeneral.valor_saldo_foto = 0;

			END IF;

			RETURN NEXT CarteraGeneral;

		END LOOP;
		raise notice '-----xxxxxxxxxxxx----';
	END LOOP;
	--

	----------------------------------------------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------------------------------------------
	/*
	fechaCorte := FechaCortePeriodo;

	FOR CarteraGeneralTwo IN

		select
			negasoc::varchar as negocio,
			nit::varchar as cedula,
			''::varchar as nombre_cliente,
			''::varchar as vencimiento_mayor,
			''::varchar as fecha_pago_ingreso, --fecha_consignacion
			''::varchar as fecha_vencimiento_mayor,
			''::varchar as diferencia_pago,
			valor_saldo::numeric as valor_saldo_foto,
			0::numeric as interes_mora,
			0::numeric as gasto_cobranza,
			0::varchar as num_ingreso,
			0::numeric as valor_ingreso,
			0::numeric as valor_cxc_ingreso,
			0::numeric as G16252145,
			0::numeric as G94350302,
			0::numeric as GI010010014205,
			0::numeric as GI010130014205, --
			0::numeric as I16252147,
			0::numeric as I94350301,
			0::numeric as II010010014170,
			0::numeric as II010130024170, --
			0::numeric as valor_ixm_ingreso,
			0::numeric as valor_gac_ingreso,
			id_convenio::varchar as convenio
		FROM (

			select
				negasoc::varchar,
				nit::varchar,
				id_convenio::varchar,
				sum(valor_saldo)::numeric as valor_saldo
			from con.foto_cartera f
			where periodo_lote = PeriodoFoto
				and f.reg_status = ''
				--and f.id_convenio in (SELECT id_convenio FROM rel_unidadnegocio_convenios WHERE id_unid_negocio IN  (SELECT id FROM unidad_negocio WHERE id = unidadnegocio))
				--and (SELECT count(0) from negocios where cod_neg = f.negasoc and negocio_rel = '') > 0
				--and (select count(0) from negocios where cod_neg = f.negasoc and negocio_rel_seguro = '') > 0
				--and (select count(0) from negocios where cod_neg = f.negasoc and negocio_rel_gps = '') > 0
				and substring(documento,1,2) not in ('CP','FF','DF')
				and replace(substring(f.fecha_vencimiento,1,7),'-','')::numeric < PeriodoFoto
				and f.valor_saldo > 0
				and negasoc not in (select negocio from tem.tabla_array_sanciones)
				and negasoc = 'XXXXX' --in ('FA00440','FA00442','FA00730','FB00085')
			group by negasoc,nit,id_convenio
			order by negasoc

		) c

	LOOP

		SELECT INTO ClienteRec nomcli FROM cliente WHERE nit = CarteraGeneralTwo.cedula;
		CarteraGeneralTwo.nombre_cliente = ClienteRec.nomcli;

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
				  AND fra.negasoc = CarteraGeneralTwo.negocio
				  AND fra.tipo_documento in ('FAC','NDC')
				  AND fra.periodo_lote = PeriodoAsignacion
			 GROUP BY negasoc

		) tabla2;

		CarteraGeneralTwo.vencimiento_mayor = VencimientoMayor;

		SELECT INTO FechaMayor max(fecha_vencimiento) as maxdia
		FROM con.foto_cartera fra
		WHERE fra.dstrct = 'FINV'
			AND fra.valor_saldo > 0
			AND fra.reg_status = ''
			AND fra.negasoc = CarteraGeneralTwo.negocio
			AND fra.tipo_documento in ('FAC','NDC')
			AND substring(fra.documento,1,2) not in ('CP','FF','DF')
			AND fra.periodo_lote = PeriodoAsignacion
			AND replace(substring(fra.fecha_vencimiento,1,7),'-','')::numeric <= periodoasignacion
		GROUP BY negasoc;

		CarteraGeneralTwo.fecha_vencimiento_mayor = FechaMayor;

		SELECT INTO UnidadNegocio ruc.id_convenio, un.*
		FROM rel_unidadnegocio_convenios ruc, unidad_negocio un
		WHERE ruc.id_unid_negocio = un.id
		AND id_convenio IN (select id_convenio from negocios where cod_neg = CarteraGeneralTwo.negocio)
		AND id_unid_negocio in (1,2,3,4,5,6,7,8,9,10,11);

		CarteraGeneralTwo.convenio = UnidadNegocio.descripcion;

	       --SANCIONES
		_SumIxM = 0;
		_SumGaC = 0;

		FOR _SancionFacts IN

			SELECT f.valor_saldo,f.fecha_vencimiento,f.id_convenio, fd.*
			FROM con.foto_cartera f, con.factura_detalle fd
			WHERE f.documento = fd.documento
			AND f.negasoc = CarteraGeneralTwo.negocio
			AND f.periodo_lote = PeriodoFoto
			AND f.reg_status = ''
			AND substring(f.documento,1,2) not in ('CP','FF','DF')
			AND replace(substring(f.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoFoto
			AND f.valor_saldo > 0

		LOOP
			BolsaSaldo = _SancionFacts.valor_saldo;

			VerifyDetails = 'N';
			Diferencia = BolsaSaldo - _SancionFacts.valor_unitario; --valor_unitario

			if ( Diferencia <= 0 and BolsaSaldo > 0) then

				VlDetFactura = BolsaSaldo;
				_Base = VlDetFactura;

				BolsaSaldo = BolsaSaldo - _SancionFacts.valor_unitario; --valor_unitario
				VerifyDetails = 'S';

			elsif ( Diferencia > 0 and BolsaSaldo > 0 ) then

				VlDetFactura = _SancionFacts.valor_unitario;
				_Base = VlDetFactura;

				BolsaSaldo = BolsaSaldo - _SancionFacts.valor_unitario; --valor_unitario
				VerifyDetails = 'S';

			end if;

			raise notice 'VerifyDetails: %',VerifyDetails;
			if ( VerifyDetails = 'S' ) then

				-- Sancion
				--Conceptos
				SELECT INTO _ConceptRec * FROM conceptos_recaudo WHERE prefijo = _SancionFacts.descripcion AND (fechaCorte::date - _SancionFacts.fecha_vencimiento::date ) BETWEEN dias_rango_ini AND dias_rango_fin and id_unidad_negocio = UnidadNegocio.id;
				raise notice 'CODIGO: %, factura: %, descripcion: %, fechaCorte: %, fecha_vencimiento: %, dias: %',_ConceptRec.id, _SancionFacts.documento, _SancionFacts.descripcion, fechaCorte::date, _SancionFacts.fecha_vencimiento::date, fechaCorte::date - _SancionFacts.fecha_vencimiento::date;

				FOR _Sancion IN

					SELECT * FROM sanciones_condonaciones
					WHERE id_tipo_acto = 1
						AND id_conceptos_recaudo = _ConceptRec.id
						AND (fechaCorte::date - _SancionFacts.fecha_vencimiento::date ) BETWEEN dias_rango_ini AND dias_rango_fin
						AND periodo = periodoasignacion and id_unidad_negocio = UnidadNegocio.id
				LOOP

					IF ( _Sancion.categoria = 'IXM' ) THEN

						if (  fechaCorte::date > _SancionFacts.fecha_vencimiento::date ) then --if ( now()::date > CarteraxCuota.fecha_vencimiento::date ) then
							raise notice 'PASA - IXM!';
							select into _Tasa tasa_interes/100 from convenios where id_convenio = _SancionFacts.id_convenio; --(select id_convenio from negocios where cod_neg = _SancionFacts.negasoc); --NegocioRef

							_IxM = ROUND( _Base *(_Tasa/30) * (fechaCorte::date - _SancionFacts.fecha_vencimiento)::numeric );
							_SumIxM = _SumIxM + _IxM;
						end if;

					END IF;

					IF ( _Sancion.categoria = 'GAC' ) THEN
						raise notice 'PASA - GAC!';
						if ( fechaCorte::date  > _SancionFacts.fecha_vencimiento::date ) then --if ( now()::date > CarteraxCuota.fecha_vencimiento::date ) then
							_GaC = ROUND(( _Base * _Sancion.porcentaje::numeric)/100);
							_SumGaC = _SumGaC + _GaC;
						end if;

					END IF;

				END LOOP;
			end if;

			CarteraGeneralTwo.valor_saldo_foto = _SancionFacts.valor_saldo;
			CarteraGeneralTwo.fecha_pago_ingreso = '0099-01-01';

		END LOOP;

		CarteraGeneralTwo.interes_mora= _SumIxM;
		CarteraGeneralTwo.gasto_cobranza= _SumGaC;

		RETURN NEXT CarteraGeneralTwo;

	END LOOP;
	*/
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_auditoria_ingresos(numeric, character varying)
  OWNER TO postgres;
