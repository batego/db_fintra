-- Function: sp_distribucionpagos2(integer, character varying)

-- DROP FUNCTION sp_distribucionpagos2(integer, character varying);

CREATE OR REPLACE FUNCTION sp_distribucionpagos2(codrop integer, negotcio character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE

	ReciboOficial record;
	rsNegociosFacturas record;
	DetalleCartera record;
	PercPagar record;

	BolsaRop numeric;
	BolsaAbonos numeric;
	--PercPagar numeric;
	ValorPorcion numeric;
	ValorAccionWPerc numeric;
	restoAplicacionInt numeric;
	resta numeric;

	fecha_hoy date;
	fechaAnterior date;

	SQLfact TEXT;
	SQL TEXT;

BEGIN

	BolsaRop = 0;
	--PercPagar = 0;
	ValorPorcion = 0;
	ValorAccionWPerc = 0;
	restoAplicacionInt = 0;

	FOR ReciboOficial IN

		SELECT *,
			(capital-(capital*dcto_capital/100))::numeric(11,2) as capital,
			(interes-(interes*dcto_interes/100))::numeric(11,2) as interes,
			--((capital-(capital*dcto_capital/100))::numeric(11,2) + (interes-(interes*dcto_interes/100))::numeric(11,2)) as sumato
			(SELECT valor_pagar FROM tabla_pago_inicial_reestruturacion WHERE id_rop = resumen_saldo_reestructuracion.id_rop AND negocio = resumen_saldo_reestructuracion.negocio) as sumato
		FROM resumen_saldo_reestructuracion
		WHERE id_rop = CodRop
		AND negocio = Negotcio
		ORDER BY negocio

	LOOP

		SELECT INTO PercPagar * FROM tabla_pago_inicial_reestruturacion WHERE id_rop = CodRop AND negocio = ReciboOficial.negocio;
		--

		--BolsaRop = round(ReciboOficial.sumato*PercPagar.pct_pagar/100)::numeric(11,0);
		BolsaRop = ReciboOficial.sumato;

		raise notice 'EstadoCartera: %',ReciboOficial.estado_cartera;
		raise notice 'PercPagar: %',PercPagar.pct_pagar;
		raise notice 'BOLSA$$: %',BolsaRop;
		raise notice '';

		SQLfact = 'select
				f.negasoc,
				f.documento,
				f.num_doc_fen,
				f.fecha_vencimiento,
				(replace(substring(f.fecha_vencimiento,1,7),''-'','''')) as periodo_vcto,
				('''||ReciboOficial.creation_date||'''::date-f.fecha_vencimiento) as num_dias,
				f.valor_factura,
				f.valor_abono,
				f.valor_saldo
			   from con.factura f
			   where negasoc = '''||ReciboOficial.negocio||'''
			   and valor_saldo > 0
			   and substring(f.documento,1,2) not in (''CP'',''FF'',''DF'')';

		IF ( ReciboOficial.estado_cartera = 'VENCIDO' ) THEN

			SQLfact := SQLfact || ' AND ('''||ReciboOficial.creation_date||'''::date-f.fecha_vencimiento) > 0';

		ELSIF ( ReciboOficial.estado_cartera = 'CORRIENTE' ) THEN

			SQLfact := SQLfact || ' AND ('''||ReciboOficial.creation_date||'''::date-f.fecha_vencimiento) <= 0';

			ValorPorcion = ReciboOficial.interes;
			raise notice 'ValorPorcion: %',ValorPorcion;

		END IF;

		SQLfact := SQLfact || ' ORDER BY f.fecha_vencimiento';

		raise notice 'SQLfact: %',SQLfact;
		raise notice '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$';

		FOR rsNegociosFacturas IN EXECUTE SQLfact LOOP

			BolsaAbonos = rsNegociosFacturas.valor_abono;

			SQL =   'SELECT
					''''::varchar as negasoc,
					''''::varchar as documento,
					''''::varchar as num_doc_fen,
					''''::varchar as fecha_vencimiento,
					''''::varchar as periodo_vcto,
					0::integer as num_dias,
					''''::varchar as estado_cartera,
					fd.descripcion::varchar,
					fd.valor_item::numeric,
					''''::varchar as accion,
					0::numeric as valor_accion,
					0::numeric as valor_llevar_a,
					0::numeric as valor_abono
				FROM con.factura_detalle fd
				WHERE fd.documento = '''||rsNegociosFacturas.documento||'''
				ORDER BY fd.descripcion DESC';

			raise notice '';
			raise notice '----------------------------------------------------------------';
			raise notice '';
			raise notice 'SQL: %',SQL;

			raise notice '';
			raise notice '::::::::::::::::::::::::::::::::::::::::::::::::::::';
			raise notice 'FacturaCabecera: %, valor_factura: %, valor_abono: %, valor_saldo: %',rsNegociosFacturas.documento,rsNegociosFacturas.valor_factura, BolsaAbonos, rsNegociosFacturas.valor_saldo;

			FOR DetalleCartera IN EXECUTE SQL LOOP

				--ASIGNO LOS VALORES DE LA CABECERA DE LA FACTURA EN EL RECORD DEL DETALLE DE LA MISMA FACTURA
				DetalleCartera.negasoc = rsNegociosFacturas.negasoc;
				DetalleCartera.documento = rsNegociosFacturas.documento;
				DetalleCartera.num_doc_fen = rsNegociosFacturas.num_doc_fen;
				DetalleCartera.fecha_vencimiento = rsNegociosFacturas.fecha_vencimiento;
				DetalleCartera.periodo_vcto = rsNegociosFacturas.periodo_vcto;
				DetalleCartera.num_dias = rsNegociosFacturas.num_dias;
				DetalleCartera.valor_abono = rsNegociosFacturas.valor_abono;

				--Define si tiene abono en la cabecera de la factura
				if ( BolsaAbonos > 0 ) then
					restoAplicacionInt = DetalleCartera.valor_item - BolsaAbonos; --DetalleCartera.valor_item | DetalleCartera.valor_abono
				end if;

				raise notice '----';
				raise notice 'FacturaDetalle: %, Descripcion: %, valor_item: %, valor_abono: %, restoAplicacionInt: %', rsNegociosFacturas.documento, DetalleCartera.descripcion, DetalleCartera.valor_item, BolsaAbonos, restoAplicacionInt;

				/**
				SI HAY ABONO -> Acá se define cómo se distribuye en el capital y en el interés
				**/

				--EL ABONO ES MENOR QUE EL ITEM
				IF ( restoAplicacionInt >= 0 )THEN

					raise notice 'EL ABONO ES MENOR QUE EL ITEM';
					if ( DetalleCartera.descripcion = 'CAPITAL' ) then

						--VALIDO QUE EXISTA ABONO PARA HACER ESTA OPERACION
						if ( BolsaAbonos > 0 ) then
							DetalleCartera.valor_item = DetalleCartera.valor_item - BolsaAbonos;
							BolsaAbonos = BolsaAbonos - DetalleCartera.valor_item;
						end if;

					elsif ( DetalleCartera.descripcion = 'INTERESES' ) then

						if ( BolsaAbonos > 0 ) then
							DetalleCartera.valor_item = restoAplicacionInt;
							BolsaAbonos = BolsaAbonos - restoAplicacionInt;
						end if;
					end if;

				--EL ABONO ES MAYOR QUE EL ITEM
				ELSE

					raise notice 'EL ABONO ES MAYOR QUE EL ITEM';
					if ( DetalleCartera.descripcion = 'CAPITAL' ) then

						if ( BolsaValorAbono > 0 ) then
							restoAplicacionInt = (restoAplicacionInt * -1);
							DetalleCartera.valor_item = DetalleCartera.valor_item - restoAplicacionInt;
							BolsaAbonos = BolsaAbonos - restoAplicacionInt;
						end if;

					elsif ( DetalleCartera.descripcion = 'INTERESES' ) then

						if ( BolsaValorAbono > 0 ) then
							BolsaAbonos = BolsaAbonos - DetalleCartera.valor_item;
							DetalleCartera.valor_item = 0;
						end if;

					end if;

				END IF;

				/**
				ACA ME MUESTRA LA PARTE DERECHA
				**/

				/*VALOR PORCENTUADO DEL ITEM*/
				ValorAccionWPerc = ROUND((DetalleCartera.valor_item::numeric*PercPagar.pct_pagar::numeric/100))::numeric(11,2);
				--ValorAccionWPerc = DetalleCartera.valor_item; --PALIATIVO

				raise notice 'ValorAccionWPerc: %',ValorAccionWPerc;
				raise notice 'EstadoCartera: %',ReciboOficial.estado_cartera;

				IF ( ReciboOficial.estado_cartera = 'VENCIDO' ) THEN

					fechaAnterior = rsNegociosFacturas.fecha_vencimiento;
					raise notice 'fechaAnterior: %',fechaAnterior;

					DetalleCartera.estado_cartera = 'VENCIDO';
					raise notice 'BolsaRop: %, ValorAccionWPerc: %, Diferencia: %', BolsaRop, ValorAccionWPerc, BolsaRop-ValorAccionWPerc;

					if ( BolsaRop > 0 and (BolsaRop-ValorAccionWPerc) >= 0 ) then

						DetalleCartera.accion = 'SALDAR '||PercPagar.pct_pagar||'%';
						DetalleCartera.valor_accion = ValorAccionWPerc;

						BolsaRop = BolsaRop - ValorAccionWPerc;
						raise notice 'RestaBolsaRop: %',BolsaRop;

					else

						--DetalleCartera.accion = 'SALDAR 0%';
						DetalleCartera.accion = 'SALDAR '||PercPagar.pct_pagar||'%';
						DetalleCartera.valor_accion = BolsaRop;

					end if;

				/*CARTERA A VENCER*/
				ELSIF ( ReciboOficial.estado_cartera = 'CORRIENTE' ) THEN

					resta = rsNegociosFacturas.fecha_vencimiento - fechaAnterior;
					raise notice 'resta: %',resta;

					/*CARTERA CORRIENTE*/
					--IF ( DetalleCartera.periodo_vcto = replace(substring(ReciboOficial.creation_date,1,7),'-','') ) THEN --Debo tener en cuenta que pueden haber facturas que se vencen el mes siguiente pero son corrientes
					IF(resta between 27  and 34)THEN --Condicion Edgar

						raise notice 'my hoy - fecha vencimiento anterior %',(now()::date-fechaAnterior::date);
						DetalleCartera.estado_cartera = 'CORRIENTE';

						if ( DetalleCartera.descripcion = 'CAPITAL' ) then
							/*
							if ( BolsaRop > 0 and (BolsaRop-ValorAccionWPerc) >= 0 ) then

								DetalleCartera.accion = 'SALDAR '||PercPagar.pct_pagar||'%';
								DetalleCartera.valor_accion = ValorAccionWPerc;

								BolsaRop = BolsaRop - ValorAccionWPerc;		-------------
								raise notice 'RestaBolsaRop: %',BolsaRop;	-------------

							else

								DetalleCartera.accion = 'SALDAR 0%';
								DetalleCartera.valor_accion = 0;

							end if;*/

							DetalleCartera.accion = 'AJUSTE AUTOMATICO CAPITAL';
							DetalleCartera.valor_accion = 0;

						elsif ( DetalleCartera.descripcion = 'INTERESES' ) then

							if ( BolsaRop > 0 and (BolsaRop-ValorPorcion) >= 0 ) then

								DetalleCartera.accion = 'APLICAR POR $'||ValorPorcion;
								DetalleCartera.valor_accion = ValorPorcion;
								DetalleCartera.valor_llevar_a = DetalleCartera.valor_item::numeric-ValorPorcion::numeric;

								BolsaRop = BolsaRop - ValorPorcion;
								raise notice 'RestaBolsaRop: %',BolsaRop;
							else

								DetalleCartera.accion = 'NO APLICAR';
								DetalleCartera.valor_accion = 0;

							end if;

						end if;

					/*CARTERA FUTURO*/
					ELSE
						BolsaRop = 0;
						DetalleCartera.estado_cartera = 'FUTURO';

						if ( DetalleCartera.descripcion = 'CAPITAL' OR DetalleCartera.descripcion = 'AVAL') then
							raise notice 'Entra A';
							DetalleCartera.accion = 'AJUSTE AUTOMATICO CAPITAL';
							/*
							if ( BolsaRop > 0 and (BolsaRop-ValorAccionWPerc) >= 0 ) then

								DetalleCartera.accion = 'SALDAR '||PercPagar.pct_pagar||'%';
								DetalleCartera.valor_accion = ValorAccionWPerc;

								BolsaRop = BolsaRop - ValorAccionWPerc;
								raise notice 'RestaBolsaRop: %',BolsaRop;
							else
								raise notice 'BolsaRop: %, ValorAccionWPerc: %',BolsaRop,ValorAccionWPerc;
								DetalleCartera.accion = 'AJUSTE AUTOMATICO CAPITAL';
								DetalleCartera.valor_accion = 0;

							end if;	*/

						elsif ( DetalleCartera.descripcion = 'INTERESES' ) then

							raise notice 'Entra B';
							DetalleCartera.accion = 'REVERTIR INTERESES';
							/*
							IF ( PercPagar.pct_pagar < 100 ) THEN
								DetalleCartera.accion = 'AJUSTE AUTOMATICO INTERESES';
								DetalleCartera.valor_accion = 0;
							ELSE
								DetalleCartera.valor_accion = ValorAccionWPerc;
								DetalleCartera.accion = 'REVERTIR INTERESES';
							END IF;
							*/

						end if;

					END IF;

				END IF;

				RETURN NEXT DetalleCartera;

			END LOOP;

		END LOOP;

		raise notice '';
		raise notice 'XXXXXXXXXXXXXX###############################################XXXXXXXXXXXXXX';
		raise notice '';

	END LOOP;
	--

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_distribucionpagos2(integer, character varying)
  OWNER TO postgres;
