-- Function: recaudo.sp_aplicacionpago(integer, integer, integer, character varying, date, integer)

-- DROP FUNCTION recaudo.sp_aplicacionpago(integer, integer, integer, character varying, date, integer);

CREATE OR REPLACE FUNCTION recaudo.sp_aplicacionpago(loterecaudo integer, idetalle_recaudo integer, codrop integer, usuario character varying, fecharecaudo date, entidadrecaudadora integer)
  RETURNS text AS
$BODY$

DECLARE

	EntidadRecaudo record;
	IdentificarIngresos record;
	ReciboOficial record;
	RsNegociosInRop record;
	rsNegociosFacturas record;
	DetalleCartera record;
	MontoRopMontoCartera record;

	BolsaRop numeric;
	BolsaValorAbono numeric;
	PercPagar numeric;
	ValorPorcion numeric;
	ValorAccionWPerc numeric;
	restoAplicacionInt numeric;
	resta numeric;
	_PeriodoCte numeric;

	ReturnAplicarPagoCartera varchar;
	CtaIxM varchar;
	CtaGaC varchar;
	CtaCabIngreso varchar;
	CtaDetIngreso varchar;

	fecha_hoy date;
	fechaAnterior date;
	miHoy date;

	ValidarIxMGaC boolean := true;

	SQL TEXT;
	SQL1 TEXT;
	mcad TEXT := 'OK';

BEGIN

	BolsaRop = 0;
	PercPagar = 0;
	ValorPorcion = 0;
	ValorAccionWPerc = 0;
	restoAplicacionInt = 0;

	miHoy = now()::date;
	_PeriodoCte = replace(substring(miHoy,1,7),'-','')::numeric;

	/**
	EL INICIO DE ESTE PROCESO PARTE EN IDENTIFICAR CUANTOS INGRESOS DEBE HACER EL PROCESO. ESTO OBEDECE A QUE DEPENDIENDO EN DóNDE SE ENCUENTRE
	LA CARTERA EL INGRESO TENDRÁ SUS PARTICULARES; Y EN EL CASO DE NUESTRO PROCESO SE PUEDE DAR QUE UN CLIENTE TENGA CARTERA EN FINTRA Y EN
	CUENTAS DE ORDEN AL MISMO TIEMPO.
	**/

	--CONSULTAMOS QUE LA ENTIDAD RECAUDADORA EXISTA
	SELECT INTO EntidadRecaudo * FROM recaudo.entidad_recaudo WHERE codigo_entidad = EntidadRecaudadora;
	IF FOUND THEN

		--..::VALIDAMOS QUE SEA PARA SUPER-EFECTIVO/BALOTO::..
		IF ( EntidadRecaudo.pago_automatico = 'S' and EntidadRecaudadora = 501 ) THEN

			select into MontoRopMontoCartera id_rop, sum(saldo_cartera) as saldo_cartera, sum(saldo_rop) as saldo_rop
			from (
				select dr.id_rop, dr.negocio, f.negasoc, f.num_doc_fen, f.saldo_cartera, sum(dr.valor_concepto) as saldo_rop
				from detalle_rop dr
					INNER JOIN (
						select negasoc, num_doc_fen, sum(valor_saldo) as saldo_cartera
						from con.factura f
						where f.dstrct = 'FINV'
						and f.reg_status = ''
						and f.tipo_documento in ('FAC','NDC')
						and substring(f.documento,1,2) not in ('CP','FF','DF')
						and f.valor_saldo > 0
						and replace(substring(f.fecha_vencimiento,1,7),'-','') <= (select periodo_rop from recibo_oficial_pago where id = CodRop) --replace(substring(FechaRecaudo,1,7),'-','') --FechaRecaudo
						group by negasoc, num_doc_fen
					) f ON (f.negasoc = dr.negocio and f.num_doc_fen = dr.cuota)
				where dr.id_rop = CodRop
				and dr.descripcion not in ('INTERES MORA','GASTOS DE COBRANZA')
				group by dr.id_rop, dr.negocio, f.negasoc, f.num_doc_fen, f.saldo_cartera
				order by f.negasoc
			) c
			group by id_rop;

			--VALIDO QUE ROP Y CARTERA SEAN IGUALES
			if ( MontoRopMontoCartera.saldo_cartera = MontoRopMontoCartera.saldo_rop ) then

				/*OBTENEMOS LA INFORMACION DEL RECIBO OFICIAL DE PAGO - EXTRACTO*/
				SELECT INTO ReciboOficial * FROM recibo_oficial_pago WHERE id = CodRop and recibo_aplicado = 'N';

				IF FOUND THEN

					SQL =  'select cmc, (select cuenta from con.cmc_doc where cmc = f.cmc and tipodoc = ''FAC'') as cuenta
						from detalle_rop dr, con.factura f
						where f.negasoc = dr.negocio
							and dr.id_rop = '||ReciboOficial.id||'
							and f.dstrct = ''FINV''
							and f.reg_status = ''''
							and f.tipo_documento in (''FAC'',''NDC'')
							and substring(f.documento,1,2) not in (''CP'',''FF'',''DF'')
							and dr.descripcion not in (''INTERES MORA'',''GASTOS DE COBRANZA'')
							and f.valor_saldo > 0
						group by cmc, cuenta';
					--raise notice 'sql: %',SQL;

					FOR IdentificarIngresos IN EXECUTE SQL LOOP

						raise notice 'UnidadNegocio: %, Cuenta: %',ReciboOficial.id_unidad_negocio, IdentificarIngresos.cuenta;

						--CARTERA EN FINTRA
						IF ( IdentificarIngresos.cuenta LIKE '13%' ) THEN

							/*NO EXISTE RESTRICCION POR CONVENIO - APLICA TANTO A MICRO COMO A FENALCO
							--------------------------------------------------------------------------*/

							--Seteamos las cuentas de Interes Mora y los Gastos de Cobranza
							IF ( ReciboOficial.id_unidad_negocio = 1 ) THEN
								CtaIxM = 'I010130014170'; --I010130024170
								CtaGaC = 'I010130014205';
								CtaCabIngreso = '11050527'; --'13809501';
								CtaDetIngreso = 'cmc_factura';
							ELSIF ( ReciboOficial.id_unidad_negocio = 21 ) THEN
								CtaIxM = 'I010300014170';
								CtaGaC = 'I010300014205';
								CtaCabIngreso = '11050527'; --'13809501';
								CtaDetIngreso = 'cmc_factura';
							ELSE
								CtaIxM = 'I010140014170'; --'I010010014170' -> OLD CUENTA: Cambia a partir del 4 de Septiembre
								CtaGaC = 'I010140014205'; --'I010010014205' -> OLD CUENTA: Cambia a partir del 4 de Septiembre
								CtaCabIngreso = '11050527'; --'13809501';
								CtaDetIngreso = 'cmc_factura';

							END IF;

							raise notice 'CodRop: %, ValidarIxMGaC: %, ICAC: %, Usuario: %, CtaCabIngreso: %, CtaDetIngreso: %, cuenta: %, CtaIxM: %, CtaGaC: %',CodRop, ValidarIxMGaC, 'INGC', 'HCUELLO', CtaCabIngreso, CtaDetIngreso, IdentificarIngresos.cuenta, CtaIxM, CtaGaC;

							select into ReturnAplicarPagoCartera recaudo.SP_AplicarPagoCartera(EntidadRecaudadora, FechaRecaudo, LoteRecaudo, idetalle_recaudo, CodRop, ValidarIxMGaC, 'INGC', 'Distribuido', substring(IdentificarIngresos.cuenta,1,2), ReciboOficial.id_unidad_negocio, Usuario, IdentificarIngresos.cmc, CtaCabIngreso, CtaDetIngreso, IdentificarIngresos.cuenta, CtaIxM, CtaGaC);
							raise notice 'INGRESO_IAoIC: %',ReturnAplicarPagoCartera;
							ValidarIxMGaC := false;


						--CARTERA EN FIDUCIA
						ELSIF ( IdentificarIngresos.cuenta LIKE '16%' ) THEN

							/*SOLO APLICA PARA EL CONVENIO DE FENALCO
							-----------------------------------------*/
							IF ( ReciboOficial.id_unidad_negocio != 1 ) THEN

								--Seteamos las cuentas de Interes Mora y los Gastos de Cobranza
								CtaIxM = 'I010140014170'; -- Se cambia el 10Marzo/2016 '16252147';
								CtaGaC = 'I010140014205'; -- Se cambia el 10Marzo/2016 '16252145';
								CtaCabIngreso = '11050527'; --'13809501';
								CtaDetIngreso = 'cmc_factura';

								raise notice 'CodRop: %, ValidarIxMGaC: %, ICAC: %, Usuario: %, CtaCabIngreso: %, CtaDetIngreso: %, cuenta: %, CtaIxM: %, CtaGaC: %',CodRop, ValidarIxMGaC, 'INGC', 'HCUELLO', CtaCabIngreso, CtaDetIngreso, IdentificarIngresos.cuenta, CtaIxM, CtaGaC;

								select into ReturnAplicarPagoCartera recaudo.SP_AplicarPagoCartera(EntidadRecaudadora, FechaRecaudo, LoteRecaudo, idetalle_recaudo, CodRop, ValidarIxMGaC, 'INGC', 'Distribuido', substring(IdentificarIngresos.cuenta,1,2), ReciboOficial.id_unidad_negocio, Usuario, IdentificarIngresos.cmc, CtaCabIngreso, CtaDetIngreso, IdentificarIngresos.cuenta, CtaIxM, CtaGaC);
								raise notice 'INGRESO_IAoIC: %',ReturnAplicarPagoCartera;
								ValidarIxMGaC := false;


							END IF;

						--CARTERA EN CUENTAS DE ORDEN FENALCO
						ELSIF ( IdentificarIngresos.cuenta LIKE '9%' ) THEN

							/*SE HACEN DOS(2) INGRESOS: UN IA & IC
							--------------------------------------*/

							--Seteamos las cuentas de Interes Mora y los Gastos de Cobranza
							CtaIxM = 'I010130014170'; --I010130024170
							CtaGaC = 'I010130014205';

							--.::IA::.-- Cambia a IC?
							CtaCabIngreso = '13809501';
							CtaDetIngreso = '23809660';

							raise notice 'CodRop: %, ValidarIxMGaC: %, ICAC: %, Usuario: %, CtaCabIngreso: %, CtaDetIngreso: %, cuenta: %, CtaIxM: %, CtaGaC: %',CodRop, ValidarIxMGaC, 'ICAC', 'HCUELLO', CtaCabIngreso, CtaDetIngreso, IdentificarIngresos.cuenta, CtaIxM, CtaGaC;

							select into ReturnAplicarPagoCartera recaudo.SP_AplicarPagoCartera(EntidadRecaudadora, FechaRecaudo, LoteRecaudo, idetalle_recaudo, CodRop, ValidarIxMGaC, 'ICAC', 'Pleno', substring(IdentificarIngresos.cuenta,1,2), ReciboOficial.id_unidad_negocio, Usuario, IdentificarIngresos.cmc, CtaCabIngreso, CtaDetIngreso, IdentificarIngresos.cuenta, CtaIxM, CtaGaC);
							raise notice 'INGRESO_IAoIC: %',ReturnAplicarPagoCartera;
							ValidarIxMGaC := false;

							--.::IC::.--
							--select codigo_cuenta,* from banco where bank_account_no ilike '%CORFICOL%'
							CtaCabIngreso = '94350201'; --'BANCO CORFICOLOMBIANA cta: 9';
							CtaDetIngreso = 'cmc_factura';

							raise notice 'CodRop: %, ValidarIxMGaC: %, ICAC: %, Usuario: %, CtaCabIngreso: %, CtaDetIngreso: %, cuenta: %, CtaIxM: %, CtaGaC: %',CodRop, ValidarIxMGaC, 'ICAC', 'HCUELLO', CtaCabIngreso, CtaDetIngreso, IdentificarIngresos.cuenta, CtaIxM, CtaGaC;

							select into ReturnAplicarPagoCartera recaudo.SP_AplicarPagoCartera(EntidadRecaudadora, FechaRecaudo, LoteRecaudo, idetalle_recaudo, CodRop, ValidarIxMGaC, 'INGC', 'Distribuido', substring(IdentificarIngresos.cuenta,1,2), ReciboOficial.id_unidad_negocio, Usuario, IdentificarIngresos.cmc, CtaCabIngreso, CtaDetIngreso, IdentificarIngresos.cuenta, CtaIxM, CtaGaC);
							raise notice 'INGRESO_IAoIC: %',ReturnAplicarPagoCartera;


						--CARTERA EN CUENTAS DE ORDEN MICROCREDITO
						ELSIF ( IdentificarIngresos.cuenta LIKE '83%' ) THEN

							/*SE HACEN DOS(2) INGRESOS: 2 x IA
							----------------------------------*/

							--Seteamos las cuentas de Interes Mora y los Gastos de Cobranza
							CtaIxM = '93950702';
							CtaGaC = '93950701';

							--.::IA1::.--
							CtaCabIngreso = '13809501';
							CtaDetIngreso = '23050128';

							raise notice 'CodRop: %, ValidarIxMGaC: %, ICAC: %, Usuario: %, CtaCabIngreso: %, CtaDetIngreso: %, cuenta: %, CtaIxM: %, CtaGaC: %',CodRop, ValidarIxMGaC, 'ICAC', 'HCUELLO', CtaCabIngreso, CtaDetIngreso, IdentificarIngresos.cuenta, CtaIxM, CtaGaC;

							select into ReturnAplicarPagoCartera recaudo.SP_AplicarPagoCartera(EntidadRecaudadora, FechaRecaudo, LoteRecaudo, idetalle_recaudo, CodRop, ValidarIxMGaC, 'ICAC', 'Pleno', substring(IdentificarIngresos.cuenta,1,2), ReciboOficial.id_unidad_negocio, Usuario, IdentificarIngresos.cmc, CtaCabIngreso, CtaDetIngreso, IdentificarIngresos.cuenta, CtaIxM, CtaGaC);
							raise notice 'INGRESO_IAoIC: %',ReturnAplicarPagoCartera;
							ValidarIxMGaC := false;

							--.::IA2::.--
							CtaCabIngreso = '94350320';
							CtaDetIngreso = '83251020';

							raise notice 'CodRop: %, ValidarIxMGaC: %, ICAC: %, Usuario: %, CtaCabIngreso: %, CtaDetIngreso: %, cuenta: %, CtaIxM: %, CtaGaC: %',CodRop, ValidarIxMGaC, 'ICAC', 'HCUELLO', CtaCabIngreso, CtaDetIngreso, IdentificarIngresos.cuenta, CtaIxM, CtaGaC;

							select into ReturnAplicarPagoCartera recaudo.SP_AplicarPagoCartera(EntidadRecaudadora, FechaRecaudo, LoteRecaudo, idetalle_recaudo, CodRop, ValidarIxMGaC, 'ICAC', 'Distribuido', substring(IdentificarIngresos.cuenta,1,2), ReciboOficial.id_unidad_negocio, Usuario, IdentificarIngresos.cmc, CtaCabIngreso, CtaDetIngreso, IdentificarIngresos.cuenta, CtaIxM, CtaGaC);
							raise notice 'INGRESO_IAoIC: %',ReturnAplicarPagoCartera;

						END IF;

					END LOOP;
					--

					RETURN mcad;

				ELSE

					mcad := 'NoEncontrado';
					RETURN mcad;

				END IF;

			else

				--CAUSAL DE NO PROCESADO. C03->DIFERENCIAS CARTERA/EXTRACTO.
				UPDATE recaudo.recaudo_detalles SET causal_dev_procesamiento = 'C03' WHERE id_rec = LoteRecaudo AND referencia_factura = CodRop;
				mcad := 'NoProcesado';
				RETURN mcad;

			end if;
		ELSE

			--CAUSAL DE NO PROCESADO. C05->ENTIDAD DE RECAUDO NO PERMITIDA
			UPDATE recaudo.recaudo_detalles SET causal_dev_procesamiento = 'C05' WHERE id_rec = LoteRecaudo AND referencia_factura = CodRop;
			mcad := 'NoProcesado';
			RETURN mcad;

		END IF;

		--CAUSAL DE NO PROCESADO. C06->ENTIDAD DE RECAUDO NO EXISTE
		UPDATE recaudo.recaudo_detalles SET causal_dev_procesamiento = 'C06' WHERE id_rec = LoteRecaudo AND referencia_factura = CodRop;
		mcad := 'NoProcesado';
		RETURN mcad;

	END IF;
END;


$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION recaudo.sp_aplicacionpago(integer, integer, integer, character varying, date, integer)
  OWNER TO postgres;
