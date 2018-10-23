-- Function: sp_detallecarteraxsancionxconsolidadofenalco(numeric, character varying, character varying)

-- DROP FUNCTION sp_detallecarteraxsancionxconsolidadofenalco(numeric, character varying, character varying);

CREATE OR REPLACE FUNCTION sp_detallecarteraxsancionxconsolidadofenalco(periodoasignacion numeric, unidadnegocio character varying, negocioref character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE
	animalandia text;
	CarteraGeneral record;
	cuentasRecord record;
	cuentasRecordTotal record;
	ClienteRec record;
	FacturaActual record;
	NegocioAvales record;
	_ConceptRec record;
	_Sancion record;
	_sanciofa record;
	NegocioArray record;

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
	vlr_cxc_aval numeric;
	vlr_cxc_seguro numeric;
	contador numeric :=0;

	VerifyDetails varchar;
	numero_ingreso varchar :='';
	numero_ingreso_aux varchar :='';
	numero_negocio_aux  varchar :='';
	fecha_ultimo_pago varchar:='';

	CarteraAval record;
	CarteraSeguro record;
	NegocioSeguro record;
	NegocioSeguros record;
	_sanciofaval record ;
	_SumIxM_Aval numeric := 0;
	_SumGaC_Aval numeric := 0;
	BolsaSaldoAval numeric := 0;
	buscaraval boolean :=false;
	buscarseguro boolean := false;

	vlor_ingreso_aval numeric := 0;
	numero_ingreso_aval varchar:='';
	numero_ingreso_aux_aval varchar:='';
	vlr_gac_ingreso_aval numeric :=0;
	vlr_ixm_ingreso_aval numeric :=0;
	fecha_ultimo_pago_aval varchar :='';
	numero_negocio_aux_aval varchar:= '';
	_cuentas_gac varchar = '';
	_cuentas_ixm varchar = '';


	BolsaSaldoSeguro numeric := 0;
	_sancioseguro record;
	vlor_ingreso_seguro numeric:= 0;
	numero_ingreso_seguro varchar:='';
	numero_ingreso_aux_seguro varchar:='';
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

	resta numeric :=0;
	fechaCorte varchar :='';
	fechaCorte_aval varchar :='';
	fechaCorte_seguro varchar :='';

BEGIN

	if ( substring(periodoasignacion,5) = '01' ) then
		PeriodoTramo = substring(periodoasignacion,1,4)::numeric-1||'12';
	else
		PeriodoTramo = periodoasignacion::numeric - 1;
	end if;

	--PeriodoTramo = PeriodoAsignacion::numeric -1;
	animalandia = '';

	select into FechaCortePeriodo to_char(to_timestamp(substring(PeriodoTramo,1,4)::numeric || '-' || to_char(substring(PeriodoTramo,5,2)::numeric,'FM00') || '-01', 'YYYY-MM-DD') + INTERVAL '1 month' - INTERVAL '1 days', 'YYYY-MM-DD');

	DELETE FROM tem.tabla_array_cash WHERE creation_date <= now()::date;

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

			0::numeric as G16252145,
			0::numeric as G94350302,
			0::numeric as GI010010014205,
			0::numeric as I16252147,
			0::numeric as I94350301,
			0::numeric as II010010014170,

			0::numeric as valor_gac_ingreso,
			0::numeric as valor_ixm_ingreso

		       /*
		       0::numeric as valor_gac_ingreso,
		       ''::varchar as cuentas_gac,
		       0::numeric as valor_ixm_ingreso,
		       ''::varchar as cuentas_ixm
		       */
		FROM con.foto_cartera f
		WHERE periodo_lote = periodoasignacion
			AND reg_status = ''
			AND id_convenio in (SELECT id_convenio FROM rel_unidadnegocio_convenios WHERE id_unid_negocio IN  (SELECT id FROM unidad_negocio WHERE id = unidadnegocio))
			AND (SELECT count(0) from negocios where cod_neg = f.negasoc and negocio_rel = '') > 0
			AND (select count(0) from negocios where cod_neg = f.negasoc and negocio_rel_seguro = '') > 0
			AND (select count(0) from negocios where cod_neg = f.negasoc and negocio_rel_gps = '') > 0
			--AND (SELECT count(0) FROM tem.seguros_vehiculos WHERE ciclo_fecha = '2014-07-29' AND negocio_seguro = f.negasoc) = 0
			AND substring(documento,1,2) not in ('CP','FF','DF')
			AND replace(substring(f.fecha_vencimiento,1,7),'-','')::numeric <= periodoasignacion
			AND valor_saldo > 0
			--AND negasoc in ('FA00028') --FA02493,FA01614
		GROUP BY negasoc,cedula,nombre_cliente,cuota,fecha_vencimiento,dias_vencidos,vencimiento_mayor,status,debido_cobrar,interes_mora,gasto_cobranza,valor_gac_ingreso,valor_ixm_ingreso,creation_date,documento,valor_saldo
		ORDER BY negasoc,num_doc_fen,creation_date


	LOOP
		contador :=contador+1;

		raise notice 'Item: %  Negocio Principal: %', contador, CarteraGeneral.negocio;

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
				  AND fra.tipo_documento in ('FAC','NDC')
				  AND fra.periodo_lote = PeriodoAsignacion
			 GROUP BY negasoc

		) tabla2;

		CarteraGeneral.vencimiento_mayor = VencimientoMayor;

		--SANCIONES
		_SumIxM = 0;
		_SumGaC = 0;

		--VALORES CxC
		vlr_cxc = 0;
		vlr_gac_ingreso :=0;
		vlr_ixm_ingreso :=0;

		_cuentas_gac = '';
		_cuentas_ixm = '';

		CarteraGeneral.interes_mora= _SumIxM;
		CarteraGeneral.gasto_cobranza= _SumGaC;

		_G16252145 = 0;
		_G94350302 = 0;
		_GI010010014205 = 0;
		_I16252147 = 0;
		_I94350301 = 0;
		_II010010014170 = 0;

		--VALIDACION PARA CONSULTAR SOLO UNA VEZ POR NEGOCIO.
		IF ( numero_negocio_aux = '' ) THEN

			buscaraval:=true;
			buscarseguro := true;
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
					--and i.branch_code != '' --and (i.branch_code != '' and i.branch_code != 'FENALCO ATLANTI')
					--and i.bank_account_no != ''
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
								--and f.devuelta != 'S'
								--and f.corficolombiana != 'S'
								--and f.endoso_fenalco !='S'
								and id.documento != ''
							     )
				GROUP BY i.num_ingreso,i.fecha_consignacion,i.vlr_ingreso ,id.cuenta
				ORDER BY fecha_consignacion::date desc, num_ingreso

			LOOP
				raise notice 'Tiene Pagos';
				select into NegocioArray campo_compara from tem.tabla_array_cash where campo_compara = cuentasRecord.num_ingreso and cuenta_contable = cuentasRecord.cuenta;

				if ( NOT FOUND ) then

					insert into tem.tabla_array_cash (campo_compara, cuenta_contable) values(cuentasRecord.num_ingreso, cuentasRecord.cuenta);

					IF ( cuentasRecord.cuenta = '16252145' ) THEN

						vlr_gac_ingreso = vlr_gac_ingreso + cuentasRecord.valor_ingreso_det;
						_G16252145 = _G16252145 + cuentasRecord.valor_ingreso_det;

					ELSIF ( cuentasRecord.cuenta = '94350302' ) THEN

						vlr_gac_ingreso = vlr_gac_ingreso + cuentasRecord.valor_ingreso_det;
						_G94350302 = _G94350302 + cuentasRecord.valor_ingreso_det;

					ELSIF ( cuentasRecord.cuenta = 'I010010014205' ) THEN

						vlr_gac_ingreso = vlr_gac_ingreso + cuentasRecord.valor_ingreso_det;
						--_cuentas_gac = _cuentas_gac || cuentasRecord.cuenta||',';
						_GI010010014205 = _GI010010014205 + cuentasRecord.valor_ingreso_det;

					ELSIF ( cuentasRecord.cuenta = '16252147' ) THEN

						vlr_ixm_ingreso = vlr_ixm_ingreso + cuentasRecord.valor_ingreso_det;
						_I16252147 = _I16252147 + cuentasRecord.valor_ingreso_det;

					ELSIF ( cuentasRecord.cuenta = '94350301' ) THEN

						vlr_ixm_ingreso = vlr_ixm_ingreso + cuentasRecord.valor_ingreso_det;
						_I94350301 = _I94350301 + cuentasRecord.valor_ingreso_det;

					ELSIF ( cuentasRecord.cuenta = 'I010010014170' ) THEN

						vlr_ixm_ingreso = vlr_ixm_ingreso + cuentasRecord.valor_ingreso_det;
						--_cuentas_ixm = _cuentas_ixm || cuentasRecord.cuenta||',';
						_II010010014170 = _II010010014170 + cuentasRecord.valor_ingreso_det;

					ELSE
						vlr_cxc = vlr_cxc + cuentasRecord.valor_ingreso_det;
					END IF;

					if(numero_ingreso_aux = '') then

						numero_ingreso := cuentasRecord.num_ingreso;
						vlor_ingreso := cuentasRecord.valor_ingreso_cabe;
						numero_ingreso_aux := cuentasRecord.num_ingreso;
						raise notice 'valor ingreso cab : %',cuentasRecord.valor_ingreso_cabe;
						animalandia = animalandia||','||cuentasRecord.num_ingreso;

					elsif (numero_ingreso_aux != cuentasRecord.num_ingreso ) then

						numero_ingreso := numero_ingreso||','||cuentasRecord.num_ingreso;
						vlor_ingreso := vlor_ingreso+cuentasRecord.valor_ingreso_cabe;
						numero_ingreso_aux := cuentasRecord.num_ingreso;
						raise notice 'valor ingreso cab 2 : %',cuentasRecord.num_ingreso;
						animalandia = animalandia||','||cuentasRecord.num_ingreso;
					end if;

					fecha_ultimo_pago := cuentasRecord.fecha_consignacion;

				end if;

			END LOOP;


		ELSIF (numero_negocio_aux != CarteraGeneral.negocio) then

			raise notice 'SE EJECUTA CUANDO SE CAMBIA DE NEGOCIO';

			buscaraval:=true;
			buscarseguro := true;
			vlor_ingreso:= 0;
			numero_ingreso:='';
			numero_ingreso_aux :='';
			vlr_gac_ingreso :=0;
			vlr_ixm_ingreso :=0;
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
				INNER JOIN con.ingreso i ON (id.num_ingreso = i.num_ingreso and id.dstrct = i.dstrct and i.nitcli = id.nitcli)
				WHERE id.dstrct = 'FINV'
					and id.tipo_documento in ('ING','ICA')
					and i.reg_status = ''
					--and i.branch_code != '' --and (i.branch_code != '' and i.branch_code != 'FENALCO ATLANTI')
					--and i.bank_account_no != ''
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
								--and f.devuelta != 'S'
								--and f.corficolombiana != 'S'
								--and f.endoso_fenalco !='S'
								and id.documento != ''
							    )
				group by i.num_ingreso,i.fecha_consignacion,i.vlr_ingreso ,id.cuenta
				order by fecha_consignacion::date desc, num_ingreso

			LOOP

				select into NegocioArray campo_compara from tem.tabla_array_cash where campo_compara = cuentasRecord.num_ingreso and cuenta_contable = cuentasRecord.cuenta;

				if ( NOT FOUND ) then

					insert into tem.tabla_array_cash (campo_compara, cuenta_contable) values(cuentasRecord.num_ingreso, cuentasRecord.cuenta);

					IF ( cuentasRecord.cuenta = '16252145' ) THEN

						vlr_gac_ingreso = vlr_gac_ingreso + cuentasRecord.valor_ingreso_det;
						_G16252145 = _G16252145 + cuentasRecord.valor_ingreso_det;

					ELSIF ( cuentasRecord.cuenta = '94350302' ) THEN

						vlr_gac_ingreso = vlr_gac_ingreso + cuentasRecord.valor_ingreso_det;
						_G94350302 = _G94350302 + cuentasRecord.valor_ingreso_det;

					ELSIF ( cuentasRecord.cuenta = 'I010010014205' ) THEN

						vlr_gac_ingreso = vlr_gac_ingreso + cuentasRecord.valor_ingreso_det;
						--_cuentas_gac = _cuentas_gac || cuentasRecord.cuenta||',';
						_GI010010014205 = _GI010010014205 + cuentasRecord.valor_ingreso_det;

					ELSIF ( cuentasRecord.cuenta = '16252147' ) THEN

						vlr_ixm_ingreso = vlr_ixm_ingreso + cuentasRecord.valor_ingreso_det;
						_I16252147 = _I16252147 + cuentasRecord.valor_ingreso_det;

					ELSIF ( cuentasRecord.cuenta = '94350301' ) THEN

						vlr_ixm_ingreso = vlr_ixm_ingreso + cuentasRecord.valor_ingreso_det;
						_I94350301 = _I94350301 + cuentasRecord.valor_ingreso_det;

					ELSIF ( cuentasRecord.cuenta = 'I010010014170' ) THEN

						vlr_ixm_ingreso = vlr_ixm_ingreso + cuentasRecord.valor_ingreso_det;
						--_cuentas_ixm = _cuentas_ixm || cuentasRecord.cuenta||',';
						_II010010014170 = _II010010014170 + cuentasRecord.valor_ingreso_det;

					ELSE
						vlr_cxc = vlr_cxc + cuentasRecord.valor_ingreso_det;
					END IF;

					if ( numero_ingreso_aux = '' ) then

						numero_ingreso:= cuentasRecord.num_ingreso;
						vlor_ingreso:=cuentasRecord.valor_ingreso_cabe;
						numero_ingreso_aux:=cuentasRecord.num_ingreso;
						animalandia = animalandia||','||cuentasRecord.num_ingreso;

					elsif ( numero_ingreso_aux != cuentasRecord.num_ingreso ) then

						numero_ingreso:=numero_ingreso||','||cuentasRecord.num_ingreso;
						vlor_ingreso:=vlor_ingreso+cuentasRecord.valor_ingreso_cabe;
						numero_ingreso_aux:=cuentasRecord.num_ingreso ;
						animalandia = animalandia||','||cuentasRecord.num_ingreso;
					end if;

					--vlor_ingreso:=cuentasRecord.valor_ingreso_cabe;

					fecha_ultimo_pago := cuentasRecord.fecha_consignacion;
				end if;

			END LOOP;

		END IF;

		--RAISE NOTICE 'DESPUES  DEL INGRESO: %', numero_ingreso;
		CarteraGeneral.valor_ingreso := vlor_ingreso;
		CarteraGeneral.num_ingreso := numero_ingreso;
		CarteraGeneral.fecha_pago_ingreso := fecha_ultimo_pago;
		CarteraGeneral.valor_gac_ingreso := vlr_gac_ingreso;
		CarteraGeneral.valor_ixm_ingreso := vlr_ixm_ingreso;
		CarteraGeneral.valor_cxc_ingreso = vlr_cxc;

		--CarteraGeneral.cuentas_ixm = _cuentas_ixm;
		--CarteraGeneral.cuentas_gac = _cuentas_gac;

		CarteraGeneral.G16252145 = _G16252145;
		CarteraGeneral.G94350302 = _G94350302;
		CarteraGeneral.GI010010014205 = _GI010010014205;

		CarteraGeneral.I16252147 = _I16252147;
		CarteraGeneral.I94350301 = _I94350301;
		CarteraGeneral.II010010014170 = _II010010014170;

		--calculamos otra vez los gastos de cobranza si el pago es mayor que la fecha vencimiento.
		IF(fecha_ultimo_pago != '') THEN
			resta := fecha_ultimo_pago::date - CarteraGeneral.fecha_vencimiento::date;
			fechaCorte := fecha_ultimo_pago;
		ELSE
			resta := -1;
			--fechaCorte := FechaCortePeriodo::date +  INTERVAL '1 month';
		END IF;

		raise notice 'RestoCalcularDebidos: %, fecha_ultimo_pago: %, fecha_vencimiento: %',resta, fecha_ultimo_pago, CarteraGeneral.fecha_vencimiento;
		IF(resta > 0 )THEN

			RAISE NOTICE 'ENTRO AQUI NEG PRINCIPAL';

		       --SANCIONES
			_SumIxM = 0;
			_SumGaC = 0;

			BolsaSaldo = CarteraGeneral.valor_saldo;

		        --AQUI VA PARA EL RESTO.
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
					SELECT INTO _ConceptRec * FROM conceptos_recaudo WHERE prefijo = _sanciofa.descripcion AND (fechaCorte::date - CarteraGeneral.fecha_vencimiento ) BETWEEN dias_rango_ini AND dias_rango_fin and id_unidad_negocio = unidadnegocio;
					raise notice 'descripcion: %, fechaCorte: %, fecha_vencimiento: %, dias: %',_sanciofa.descripcion, fechaCorte::date, CarteraGeneral.fecha_vencimiento, fechaCorte::date - CarteraGeneral.fecha_vencimiento;

					FOR _Sancion IN

						SELECT * FROM sanciones_condonaciones
						WHERE id_tipo_acto = 1 AND id_conceptos_recaudo = _ConceptRec.id
						AND (fechaCorte::date - CarteraGeneral.fecha_vencimiento )  BETWEEN dias_rango_ini AND dias_rango_fin
						AND periodo = periodoasignacion and id_unidad_negocio = unidadnegocio
					LOOP

						IF ( _Sancion.categoria = 'IXM' ) THEN

							if (  fechaCorte::date > CarteraGeneral.fecha_vencimiento::date ) then --if ( now()::date > CarteraxCuota.fecha_vencimiento::date ) then
								raise notice 'PASAAAAA!';
								select into _Tasa tasa_usura/100 from convenios where id_convenio = (select id_convenio from negocios where cod_neg=CarteraGeneral.negocio); --NegocioRef

								_IxM = ROUND( _Base *(_Tasa/30) * (fechaCorte::date - CarteraGeneral.fecha_vencimiento)::numeric );
								_SumIxM = _SumIxM + _IxM;
							end if;

						END IF;

						IF ( _Sancion.categoria = 'GAC' ) THEN

							if ( fechaCorte::date  > CarteraGeneral.fecha_vencimiento::date ) then --if ( now()::date > CarteraxCuota.fecha_vencimiento::date ) then
								_GaC = ROUND(( _Base * _Sancion.porcentaje::numeric)/100);
								_SumGaC = _SumGaC + _GaC;
							end if;

						END IF;

					END LOOP;
				end if;

			END LOOP;

			CarteraGeneral.interes_mora= _SumIxM;
			CarteraGeneral.gasto_cobranza= _SumGaC;


		END IF;

		RETURN NEXT CarteraGeneral;

		------------------------------------------------------------------------------------------------------------------------------------------------------

		--NEGOCIO DE AVAL
		IF ( buscaraval ) THEN

			--raise notice 'buscar aval';
			SELECT INTO NegocioAvales cod_neg from negocios where negocio_rel= CarteraGeneral.negocio;
			raise notice 'Negocio Aval: %', NegocioAvales.cod_neg;

			IF FOUND THEN

				FOR CarteraAval IN

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

						0::numeric as G16252145,
						0::numeric as G94350302,
						0::numeric as GI010010014205,
						0::numeric as I16252147,
						0::numeric as I94350301,
						0::numeric as II010010014170,

						0::numeric as valor_gac_ingreso,
						0::numeric as valor_ixm_ingreso

					FROM con.foto_cartera f
					WHERE  negasoc = NegocioAvales.cod_neg
						AND periodo_lote = periodoasignacion
						AND reg_status = ''
						AND id_convenio in (SELECT id_convenio FROM rel_unidadnegocio_convenios WHERE id_unid_negocio IN  (SELECT id FROM unidad_negocio WHERE id = unidadnegocio))
						AND substring(documento,1,2) not in ('CP','FF','DF') AND replace(substring(f.fecha_vencimiento,1,7),'-','')::numeric <= periodoasignacion
						AND valor_saldo > 0
					GROUP BY negasoc,cedula,nombre_cliente,cuota,fecha_vencimiento,dias_vencidos,vencimiento_mayor,status,debido_cobrar,interes_mora,gasto_cobranza,valor_gac_ingreso,valor_ixm_ingreso,creation_date,documento,valor_saldo
					ORDER BY negasoc,num_doc_fen,creation_date

				LOOP

					SELECT INTO ClienteRec nomcli FROM cliente WHERE nit = CarteraAval.cedula;
					CarteraAval.nombre_cliente := ClienteRec.nomcli;

					CarteraAval.debido_cobrar := CarteraAval.valor_saldo;
					BolsaSaldoAval := CarteraAval.valor_saldo;

					CarteraAval.vencimiento_mayor :=VencimientoMayor;

					--SANCIONES
					_SumIxM_Aval = 0;
					_SumGaC_Aval = 0;
					_cuentas_gac = '';
					_cuentas_ixm = '';


					--VALORES CxC
					vlr_cxc_aval = 0;
					vlr_gac_ingreso_aval = 0;
					vlr_ixm_ingreso_aval = 0;

					CarteraAval.interes_mora := _SumIxM_Aval;
					CarteraAval.gasto_cobranza := _SumGaC_Aval;

					_G16252145 = 0;
					_G94350302 = 0;
					_GI010010014205 = 0;
					_I16252147 = 0;
					_I94350301 = 0;
					_II010010014170 = 0;

					--_Sancion
					--ingreso del aval
					vlor_ingreso_aval:= 0;
					numero_ingreso_aval:='';
					numero_ingreso_aux_aval :='';
					--vlr_gac_ingreso_aval :=0;
					--vlr_ixm_ingreso_aval :=0;
					fecha_ultimo_pago_aval :='';

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
							--and i.branch_code != '' --and (i.branch_code != '' and i.branch_code != 'FENALCO ATLANTI')
							--and i.bank_account_no != ''
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
										--and f.devuelta != 'S'
										--and f.corficolombiana != 'S'
										--and f.endoso_fenalco !='S'
										and id.documento != ''
									     )
						group by i.num_ingreso,i.fecha_consignacion,i.vlr_ingreso,id.cuenta
						order by fecha_consignacion::date desc, num_ingreso

					LOOP

						select into NegocioArray campo_compara from tem.tabla_array_cash where campo_compara = cuentasRecord.num_ingreso and cuenta_contable = cuentasRecord.cuenta;

						if ( NOT FOUND ) then

							insert into tem.tabla_array_cash (campo_compara, cuenta_contable) values(cuentasRecord.num_ingreso, cuentasRecord.cuenta);
							/*
							IF ( cuentasRecord.cuenta in ('16252145','94350302','I010010014205') ) THEN
								vlr_gac_ingreso_aval = vlr_gac_ingreso_aval + cuentasRecord.valor_ingreso_det;
								_cuentas_gac = _cuentas_gac || cuentasRecord.cuenta||',';

							ELSIF ( cuentasRecord.cuenta in ('16252147','94350301','I010010014170') ) THEN
								vlr_ixm_ingreso_aval = vlr_ixm_ingreso_aval + cuentasRecord.valor_ingreso_det;
								_cuentas_ixm = _cuentas_ixm || cuentasRecord.cuenta||',';
							ELSE
								vlr_cxc_aval = vlr_cxc_aval + cuentasRecord.valor_ingreso_det;
							END IF;
							*/

							IF ( cuentasRecord.cuenta = '16252145' ) THEN

								vlr_gac_ingreso_aval = vlr_gac_ingreso_aval + cuentasRecord.valor_ingreso_det;
								_G16252145 = _G16252145 + cuentasRecord.valor_ingreso_det;

							ELSIF ( cuentasRecord.cuenta = '94350302' ) THEN

								vlr_gac_ingreso_aval = vlr_gac_ingreso_aval + cuentasRecord.valor_ingreso_det;
								_G94350302 = _G94350302 + cuentasRecord.valor_ingreso_det;

							ELSIF ( cuentasRecord.cuenta = 'I010010014205' ) THEN

								vlr_gac_ingreso_aval = vlr_gac_ingreso_aval + cuentasRecord.valor_ingreso_det;
								--_cuentas_gac = _cuentas_gac || cuentasRecord.cuenta||',';
								_GI010010014205 = _GI010010014205 + cuentasRecord.valor_ingreso_det;

							ELSIF ( cuentasRecord.cuenta = '16252147' ) THEN

								vlr_gac_ingreso_aval = vlr_gac_ingreso_aval + cuentasRecord.valor_ingreso_det;
								_I16252147 = _I16252147 + cuentasRecord.valor_ingreso_det;

							ELSIF ( cuentasRecord.cuenta = '94350301' ) THEN

								vlr_gac_ingreso_aval = vlr_gac_ingreso_aval + cuentasRecord.valor_ingreso_det;
								_I94350301 = _I94350301 + cuentasRecord.valor_ingreso_det;

							ELSIF ( cuentasRecord.cuenta = 'I010010014170' ) THEN

								vlr_gac_ingreso_aval = vlr_gac_ingreso_aval + cuentasRecord.valor_ingreso_det;
								--_cuentas_ixm = _cuentas_ixm || cuentasRecord.cuenta||',';
								_II010010014170 = _II010010014170 + cuentasRecord.valor_ingreso_det;

							ELSE
								vlr_cxc_aval = vlr_cxc_aval + cuentasRecord.valor_ingreso_det;
							END IF;


							if(numero_ingreso_aux_aval = '')	then
								numero_ingreso_aval:= cuentasRecord.num_ingreso;
								vlor_ingreso_aval:=cuentasRecord.valor_ingreso_cabe;
								numero_ingreso_aux_aval:=cuentasRecord.num_ingreso;
								animalandia = animalandia||','||cuentasRecord.num_ingreso;

							elsif (numero_ingreso_aux_aval != cuentasRecord.num_ingreso ) then
								numero_ingreso_aval:=numero_ingreso_aval||','||cuentasRecord.num_ingreso ;
								vlor_ingreso_aval:=vlor_ingreso_aval+cuentasRecord.valor_ingreso_cabe;
								numero_ingreso_aux_aval:=cuentasRecord.num_ingreso ;
								animalandia = animalandia||','||cuentasRecord.num_ingreso;
							end if;

							fecha_ultimo_pago_aval := cuentasRecord.fecha_consignacion;

						end if;

					END LOOP;

					CarteraAval.valor_ingreso := vlor_ingreso_aval;
					CarteraAval.num_ingreso := numero_ingreso_aval;
					CarteraAval.fecha_pago_ingreso := fecha_ultimo_pago_aval;
					CarteraAval.valor_gac_ingreso := vlr_gac_ingreso_aval;
					CarteraAval.valor_ixm_ingreso := vlr_ixm_ingreso_aval;
					CarteraGeneral.valor_cxc_ingreso = vlr_cxc_aval;

					--CarteraGeneral.cuentas_ixm = _cuentas_ixm;
					--CarteraGeneral.cuentas_gac = _cuentas_gac;

					CarteraGeneral.G16252145 = _G16252145;
					CarteraGeneral.G94350302 = _G94350302;
					CarteraGeneral.GI010010014205 = _GI010010014205;

					CarteraGeneral.I16252147 = _I16252147;
					CarteraGeneral.I94350301 = _I94350301;
					CarteraGeneral.II010010014170 = _II010010014170;

					IF(fecha_ultimo_pago_aval != '') THEN
						resta := fecha_ultimo_pago_aval::date - CarteraAval.fecha_vencimiento::date;
						fechaCorte_aval := fecha_ultimo_pago_aval;
					ELSE
						resta := -1;
						--fechaCorte := FechaCortePeriodo::date +  INTERVAL '1 month';
					END IF;

					IF(resta > 0) THEN

						BolsaSaldoAval := CarteraAval.valor_saldo;
						_SumIxM_Aval = 0;
						_SumGaC_Aval = 0;

						FOR _sanciofaval IN (SELECT * FROM con.factura_detalle where documento = CarteraAval.documento) LOOP

							VerifyDetails = 'N';
							Diferencia = BolsaSaldoAval - _sanciofaval.valor_unitario; --valor_unitario

							if ( Diferencia <= 0 and BolsaSaldoAval > 0) then

								VlDetFactura = BolsaSaldoAval;
								_Base = VlDetFactura;

								BolsaSaldoAval = BolsaSaldoAval - _sanciofaval.valor_unitario; --valor_unitario
								VerifyDetails = 'S';

							elsif ( Diferencia > 0 and BolsaSaldoAval > 0 ) then

								VlDetFactura = _sanciofaval.valor_unitario;
								_Base = VlDetFactura;

								BolsaSaldoAval = BolsaSaldoAval - _sanciofaval.valor_unitario; --valor_unitario
								VerifyDetails = 'S';

							end if;

							if ( VerifyDetails = 'S' ) then

								-- Sancion
								--Conceptos
								SELECT INTO _ConceptRec * FROM conceptos_recaudo WHERE prefijo = _sanciofa.descripcion AND (fechaCorte_aval::date - CarteraGeneral.fecha_vencimiento ) BETWEEN dias_rango_ini AND dias_rango_fin and id_unidad_negocio = unidadnegocio;

								FOR _Sancion IN

									SELECT *
									FROM sanciones_condonaciones
									WHERE id_tipo_acto = 1
									      AND id_conceptos_recaudo = _ConceptRec.id
									      AND (fechaCorte_aval::date - CarteraAval.fecha_vencimiento )  BETWEEN dias_rango_ini AND dias_rango_fin
									      AND periodo = periodoasignacion and id_unidad_negocio = unidadnegocio

								LOOP

									IF ( _Sancion.categoria = 'IXM' ) THEN

										if (  fechaCorte_aval::date> CarteraAval.fecha_vencimiento::date ) then --if ( now()::date > CarteraxCuota.fecha_vencimiento::date ) then

											select into _Tasa tasa_usura/100 from convenios where id_convenio = (select id_convenio from negocios where cod_neg=NegocioAvales.cod_neg);

											_IxM = ROUND( _Base *(_Tasa/30) * (fechaCorte_aval::date - CarteraGeneral.fecha_vencimiento)::numeric );
											_SumIxM_Aval = _SumIxM_Aval + _IxM;
										end if;

									END IF;

									IF ( _Sancion.categoria = 'GAC' ) THEN

										if ( fechaCorte_aval::date  > CarteraAval.fecha_vencimiento::date ) then --if ( now()::date > CarteraxCuota.fecha_vencimiento::date ) then
											_GaC = ROUND(( _Base * _Sancion.porcentaje::numeric)/100);
											_SumGaC_Aval = _SumGaC + _GaC;
										end if;

									END IF;

								END LOOP;
							end if;

						END LOOP;

						CarteraAval.interes_mora := _SumIxM_Aval;
						CarteraAval.gasto_cobranza := _SumGaC_Aval;

					END IF;


					RETURN NEXT CarteraAval;

				END LOOP;

			END IF;

			buscaraval:=false;

		END IF;
		--

		------------------------------------------------------------------------------------------------------------------------------------------------------

		--NEGOCIO DE SEGURO.
		IF(buscarseguro)THEN
			raise notice 'Entra acá!';
			FOR NegocioSeguros IN

				select * from negocios where negocio_rel_seguro = CarteraGeneral.negocio

			LOOP

				raise notice 'Negocio seguro: %', NegocioSeguros.cod_neg;

				IF FOUND THEN

					FOR CarteraSeguro IN

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

							0::numeric as G16252145,
							0::numeric as G94350302,
							0::numeric as GI010010014205,
							0::numeric as I16252147,
							0::numeric as I94350301,
							0::numeric as II010010014170,

							0::numeric as valor_gac_ingreso,
							0::numeric as valor_ixm_ingreso

						FROM con.foto_cartera f
						WHERE  negasoc = NegocioSeguros.cod_neg --negocio_seguro
						AND periodo_lote = periodoasignacion
						AND reg_status = ''
						AND id_convenio in (SELECT id_convenio FROM rel_unidadnegocio_convenios WHERE id_unid_negocio IN  (SELECT id FROM unidad_negocio WHERE id = unidadnegocio))
						AND substring(documento,1,2) not in ('CP','FF','DF') AND replace(substring(f.fecha_vencimiento,1,7),'-','')::numeric <= periodoasignacion
						AND valor_saldo > 0
						GROUP BY
						negasoc,cedula,nombre_cliente,cuota,fecha_vencimiento,dias_vencidos,vencimiento_mayor,status,debido_cobrar,interes_mora,gasto_cobranza,valor_gac_ingreso,valor_ixm_ingreso,creation_date,documento,valor_saldo
						ORDER BY negasoc,num_doc_fen,creation_date

					LOOP

						SELECT INTO ClienteRec nomcli FROM cliente WHERE nit = CarteraSeguro.cedula;
						CarteraSeguro.nombre_cliente := ClienteRec.nomcli;

						CarteraSeguro.debido_cobrar := CarteraSeguro.valor_saldo;
						BolsaSaldoSeguro := CarteraSeguro.valor_saldo;

						CarteraSeguro.vencimiento_mayor :=VencimientoMayor;

						--SANCIONES
						_SumIxM_Seguro := 0;
						_SumGaC_Seguro := 0;

						_cuentas_gac = '';
						_cuentas_ixm = '';

						--VALORES CxC
						vlr_cxc_seguro = 0;
						vlr_gac_ingreso_seguro = 0;
						vlr_ixm_ingreso_seguro = 0;

						_G16252145 = 0;
						_G94350302 = 0;
						_GI010010014205 = 0;
						_I16252147 = 0;
						_I94350301 = 0;
						_II010010014170 = 0;

						CarteraSeguro.interes_mora := _SumIxM_Seguro;
						CarteraSeguro.gasto_cobranza := _SumGaC_Seguro;

						vlor_ingreso_seguro:= 0;
						numero_ingreso_seguro:='';
						numero_ingreso_aux_seguro :='';
						--vlr_gac_ingreso_seguro :=0;
						--vlr_ixm_ingreso_seguro :=0;
						fecha_ultimo_pago_seguro :='';

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
								--and i.branch_code != '' --and (i.branch_code != '' and i.branch_code != 'FENALCO ATLANTI')
								--and i.bank_account_no != ''
								and i.nitcli= CarteraGeneral.cedula
								and id.reg_status = ''
								and replace(substring(i.fecha_consignacion,1,7),'-','') = PeriodoAsignacion
								and id.num_ingreso in (
											select distinct num_ingreso
											from con.ingreso_detalle id, con.factura f
											where id.factura = f.documento
											and f.negasoc = NegocioSeguros.cod_neg --CarteraGeneral.negocio
											and f.tipo_documento in ('FAC','NDC')
											and f.reg_status = ''
											--and f.devuelta != 'S'
											--and f.corficolombiana != 'S'
											--and f.endoso_fenalco !='S'
											and id.documento != ''
										      )
							group by i.num_ingreso,i.fecha_consignacion,i.vlr_ingreso,id.cuenta
							order by fecha_consignacion::date desc, num_ingreso

						LOOP

							select into NegocioArray campo_compara from tem.tabla_array_cash where campo_compara = cuentasRecord.num_ingreso and cuenta_contable = cuentasRecord.cuenta;

							if ( NOT FOUND ) then

								insert into tem.tabla_array_cash (campo_compara, cuenta_contable) values(cuentasRecord.num_ingreso, cuentasRecord.cuenta);
								/*
								IF ( cuentasRecord.cuenta in ('16252145','94350302','I010010014205') ) THEN
									vlr_gac_ingreso_seguro = vlr_gac_ingreso_seguro + cuentasRecord.valor_ingreso_det;
									_cuentas_gac = _cuentas_gac || cuentasRecord.cuenta ||',';

								ELSIF ( cuentasRecord.cuenta in ('16252147','94350301','I010010014170') ) THEN
									vlr_ixm_ingreso_seguro = vlr_ixm_ingreso_seguro + cuentasRecord.valor_ingreso_det;
									_cuentas_ixm = _cuentas_ixm || cuentasRecord.cuenta ||',';

								ELSE
									vlr_cxc_seguro = vlr_cxc_seguro + cuentasRecord.valor_ingreso_det;
								END IF;
								*/

								IF ( cuentasRecord.cuenta = '16252145' ) THEN

									vlr_gac_ingreso_seguro = vlr_gac_ingreso_seguro + cuentasRecord.valor_ingreso_det;
									_G16252145 = _G16252145 + cuentasRecord.valor_ingreso_det;

								ELSIF ( cuentasRecord.cuenta = '94350302' ) THEN

									vlr_gac_ingreso_seguro = vlr_gac_ingreso_seguro + cuentasRecord.valor_ingreso_det;
									_G94350302 = _G94350302 + cuentasRecord.valor_ingreso_det;

								ELSIF ( cuentasRecord.cuenta = 'I010010014205' ) THEN

									vlr_gac_ingreso_seguro = vlr_gac_ingreso_seguro + cuentasRecord.valor_ingreso_det;
									--_cuentas_gac = _cuentas_gac || cuentasRecord.cuenta||',';
									_GI010010014205 = _GI010010014205 + cuentasRecord.valor_ingreso_det;

								ELSIF ( cuentasRecord.cuenta = '16252147' ) THEN

									vlr_gac_ingreso_seguro = vlr_gac_ingreso_seguro + cuentasRecord.valor_ingreso_det;
									_I16252147 = _I16252147 + cuentasRecord.valor_ingreso_det;

								ELSIF ( cuentasRecord.cuenta = '94350301' ) THEN

									vlr_gac_ingreso_seguro = vlr_gac_ingreso_seguro + cuentasRecord.valor_ingreso_det;
									_I94350301 = _I94350301 + cuentasRecord.valor_ingreso_det;

								ELSIF ( cuentasRecord.cuenta = 'I010010014170' ) THEN

									vlr_gac_ingreso_seguro = vlr_gac_ingreso_seguro + cuentasRecord.valor_ingreso_det;
									--_cuentas_ixm = _cuentas_ixm || cuentasRecord.cuenta||',';
									_II010010014170 = _II010010014170 + cuentasRecord.valor_ingreso_det;

								ELSE
									vlr_cxc_seguro = vlr_cxc_seguro + cuentasRecord.valor_ingreso_det;
								END IF;

								if(numero_ingreso_aux_seguro = '')	then
									numero_ingreso_seguro := cuentasRecord.num_ingreso;
									vlor_ingreso_seguro:=cuentasRecord.valor_ingreso_cabe;
									numero_ingreso_aux_seguro:=cuentasRecord.num_ingreso;
									animalandia = animalandia||','||cuentasRecord.num_ingreso;

								elsif (numero_ingreso_aux_seguro != cuentasRecord.num_ingreso ) then
									numero_ingreso_seguro:=numero_ingreso_seguro||','||cuentasRecord.num_ingreso ;
									vlor_ingreso_seguro:=vlor_ingreso_seguro+cuentasRecord.valor_ingreso_cabe;
									numero_ingreso_aux_seguro:=cuentasRecord.num_ingreso ;
									animalandia = animalandia||','||cuentasRecord.num_ingreso;
								end if;

								--vlor_ingreso:=cuentasRecord.valor_ingreso_cabe;
								fecha_ultimo_pago_seguro := cuentasRecord.fecha_consignacion;

							end if;

						END LOOP;

						CarteraSeguro.valor_ingreso := vlor_ingreso_seguro;
						CarteraSeguro.num_ingreso := numero_ingreso_seguro;
						CarteraSeguro.fecha_pago_ingreso := fecha_ultimo_pago_seguro;
						CarteraSeguro.valor_gac_ingreso := vlr_gac_ingreso_seguro;
						CarteraSeguro.valor_ixm_ingreso := vlr_ixm_ingreso_seguro;
						CarteraGeneral.valor_cxc_ingreso = vlr_cxc_seguro;

						--CarteraGeneral.cuentas_ixm = _cuentas_ixm;
						--CarteraGeneral.cuentas_gac = _cuentas_gac;

						CarteraGeneral.G16252145 = _G16252145;
						CarteraGeneral.G94350302 = _G94350302;
						CarteraGeneral.GI010010014205 = _GI010010014205;

						CarteraGeneral.I16252147 = _I16252147;
						CarteraGeneral.I94350301 = _I94350301;
						CarteraGeneral.II010010014170 = _II010010014170;

						IF(fecha_ultimo_pago_seguro != '') THEN
							resta := fecha_ultimo_pago_seguro::date - CarteraAval.fecha_vencimiento::date;
							fechaCorte_seguro := fecha_ultimo_pago_seguro;
						ELSE
							resta := -1;
							--fechaCorte := FechaCortePeriodo::date +  INTERVAL '1 month';
						END IF;

						IF(resta > 0) THEN

							BolsaSaldoSeguro := CarteraSeguro.valor_saldo;
							_SumIxM_Seguro := 0;
							_SumGaC_Seguro := 0;

							FOR _sancioseguro IN (SELECT * FROM con.factura_detalle where documento = CarteraSeguro.documento) LOOP

								VerifyDetails = 'N';
								Diferencia = BolsaSaldoSeguro - _sancioseguro.valor_unitario; --valor_unitario

								if ( Diferencia <= 0 and BolsaSaldoSeguro > 0) then

									VlDetFactura = BolsaSaldoSeguro;
									_Base = VlDetFactura;

									BolsaSaldoSeguro = BolsaSaldoSeguro - _sancioseguro.valor_unitario; --valor_unitario
									VerifyDetails = 'S';

								elsif ( Diferencia > 0 and BolsaSaldoSeguro > 0 ) then

									VlDetFactura = _sancioseguro.valor_unitario;
									_Base = VlDetFactura;

									BolsaSaldoSeguro = BolsaSaldoSeguro - _sancioseguro.valor_unitario; --valor_unitario
									VerifyDetails = 'S';

								end if;

								if ( VerifyDetails = 'S' ) then
									-- Sancion
									--Conceptos
									SELECT INTO _ConceptRec * FROM conceptos_recaudo WHERE prefijo = _sancioseguro.descripcion AND (fechaCorte_seguro::date - CarteraSeguro.fecha_vencimiento ) BETWEEN dias_rango_ini AND dias_rango_fin and id_unidad_negocio = unidadnegocio;

									FOR _Sancion IN

										SELECT *
										FROM sanciones_condonaciones
										WHERE id_tipo_acto = 1 AND id_conceptos_recaudo = _ConceptRec.id
											AND (fechaCorte_seguro::date - CarteraSeguro.fecha_vencimiento )  BETWEEN dias_rango_ini AND dias_rango_fin
											AND periodo = periodoasignacion and id_unidad_negocio = unidadnegocio

									LOOP

										IF ( _Sancion.categoria = 'IXM' ) THEN

											if (  fechaCorte_seguro::date> CarteraSeguro.fecha_vencimiento::date ) then --if ( now()::date > CarteraxCuota.fecha_vencimiento::date ) then

												select into _Tasa tasa_usura/100 from convenios where id_convenio = (select id_convenio from negocios where cod_neg= NegocioSeguros.cod_neg);

												_IxM = ROUND( _Base *(_Tasa/30) * (fechaCorte_seguro::date - CarteraSeguro.fecha_vencimiento)::numeric );
												_SumIxM_Seguro = _SumIxM_Seguro + _IxM;
											end if;

										END IF;

										IF ( _Sancion.categoria = 'GAC' ) THEN

											if ( fechaCorte_seguro::date  > CarteraSeguro.fecha_vencimiento::date ) then --if ( now()::date > CarteraxCuota.fecha_vencimiento::date ) then
												_GaC = ROUND(( _Base * _Sancion.porcentaje::numeric)/100);
												_SumGaC_Seguro = _SumGaC_Seguro + _GaC;
											end if;

										END IF;

									END LOOP;
								end if;

							END LOOP;

						END IF;

						RETURN NEXT CarteraSeguro;

					END LOOP;

				END IF;

			END LOOP;

			buscarseguro :=false;

		END IF;
		--

	END LOOP;
	--
	raise notice 'animalandia, %', animalandia;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_detallecarteraxsancionxconsolidadofenalco(numeric, character varying, character varying)
  OWNER TO postgres;
