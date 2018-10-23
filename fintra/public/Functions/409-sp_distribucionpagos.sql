-- Function: sp_distribucionpagos(integer, character varying)

-- DROP FUNCTION sp_distribucionpagos(integer, character varying);

CREATE OR REPLACE FUNCTION sp_distribucionpagos(codrop integer, negotcio character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE

	ReciboOficial record;
	rsNegociosFacturas record;
	DetalleCartera record;
	PercPagar record;

	BolsaRop numeric;
	BolsaValorAbono numeric;
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
		IF ( PercPagar.pct_pagar < 100 ) THEN

			IF ( ReciboOficial.estado_cartera = 'VENCIDO' ) THEN
				BolsaRop = round(ReciboOficial.sumato*PercPagar.pct_pagar/100)::numeric(11,0);
			ELSIF ( ReciboOficial.estado_cartera = 'CORRIENTE' ) THEN
				BolsaRop = 0;
				--BolsaRop = round(ReciboOficial.sumato*PercPagar.pct_pagar/100)::numeric(11,0); --PALIATIVO
			END IF;

		ELSIF ( PercPagar.pct_pagar >= 100 ) THEN

			BolsaRop = 0; --round(ReciboOficial.sumato*PercPagar.pct_pagar/100)::numeric(11,0);

			/*
			IF ( ReciboOficial.estado_cartera = 'VENCIDO' ) THEN
				BolsaRop = round(ReciboOficial.sumato*PercPagar.pct_pagar/100)::numeric(11,0);
			ELSIF ( ReciboOficial.estado_cartera = 'CORRIENTE' ) THEN
				BolsaRop = 0;
				--BolsaRop = round(ReciboOficial.sumato*PercPagar.pct_pagar/100)::numeric(11,0); --PALIATIVO
			END IF;
			*/
		END IF;

		raise notice 'BOLSA$$: %',BolsaRop;
		raise notice 'PercPagar: %',PercPagar.pct_pagar;

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

		END IF;

		SQLfact := SQLfact || ' ORDER BY f.fecha_vencimiento';

		raise notice 'SQLfact: %',SQLfact;


		FOR rsNegociosFacturas IN EXECUTE SQLfact LOOP

			BolsaValorAbono = rsNegociosFacturas.valor_abono;

			raise notice '----------------------------------------------------------------';
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
			raise notice 'SQL: %',SQL;

			FOR DetalleCartera IN EXECUTE SQL LOOP

				--ASIGNO LOS VALORES DE LA CABECERA DE LA FACTURA EN EL RECORD DEL DETALLE DE LA MISMA FACTURA
				DetalleCartera.negasoc = rsNegociosFacturas.negasoc;
				DetalleCartera.documento = rsNegociosFacturas.documento;
				DetalleCartera.num_doc_fen = rsNegociosFacturas.num_doc_fen;
				DetalleCartera.fecha_vencimiento = rsNegociosFacturas.fecha_vencimiento;
				DetalleCartera.periodo_vcto = rsNegociosFacturas.periodo_vcto;
				DetalleCartera.num_dias = rsNegociosFacturas.num_dias;
				DetalleCartera.valor_abono = rsNegociosFacturas.valor_abono;

				raise notice 'Factura: %, Descripcion: %, ValorItem: %',DetalleCartera.documento,DetalleCartera.descripcion,DetalleCartera.valor_item;

				--Define si tiene abono en la cabecera de la factura
				if ( BolsaValorAbono > 0 ) then
					restoAplicacionInt = DetalleCartera.valor_item - BolsaValorAbono; --DetalleCartera.valor_item | DetalleCartera.valor_abono
				end if;

				raise notice '&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&';
				raise notice 'Factura: %, valor_item: %, valor_abono: %, restoAplicacionInt: %', rsNegociosFacturas.documento, DetalleCartera.valor_item, BolsaValorAbono, restoAplicacionInt;

				--Si hay abono, esta parte define cómo se distribuye el dinero
				--EL ABONO ES MENOR QUE EL ITEM
				IF ( restoAplicacionInt >= 0 )THEN

					if ( DetalleCartera.descripcion = 'CAPITAL' ) then

						--VALIDO QUE EXISTA ABONO PARA HACER ESTA OPERACION
						if ( BolsaValorAbono > 0 ) then
							DetalleCartera.valor_item = DetalleCartera.valor_item - BolsaValorAbono;
							BolsaValorAbono = BolsaValorAbono - DetalleCartera.valor_item;
						end if;

					elsif ( DetalleCartera.descripcion = 'INTERESES' ) then

						if ( BolsaValorAbono > 0 ) then
							DetalleCartera.valor_item = restoAplicacionInt;
							BolsaValorAbono = BolsaValorAbono - restoAplicacionInt;
						end if;
					end if;

				--EL ABONO ES MAYOR QUE EL ITEM
				ELSE
					--RARO
					/*
					if ( DetalleCartera.descripcion = 'CAPITAL' ) then

						if ( BolsaValorAbono > 0 ) then
							restoAplicacionInt = (restoAplicacionInt * -1);
							DetalleCartera.valor_item = DetalleCartera.valor_item - restoAplicacionInt;
							BolsaValorAbono = BolsaValorAbono - restoAplicacionInt;
						end if;

					elsif ( DetalleCartera.descripcion = 'INTERESES' ) then

						if ( BolsaValorAbono > 0 ) then
							BolsaValorAbono = BolsaValorAbono - DetalleCartera.valor_item;
							DetalleCartera.valor_item = 0;
						end if;

					end if;
					*/
				END IF;
				--X--

				raise notice 'Factura: %, Descripcion: %, ValorItem: %',DetalleCartera.documento,DetalleCartera.descripcion,DetalleCartera.valor_item;

				/*VALOR PORCENTUADO DEL ITEM*/
				ValorAccionWPerc = ROUND((DetalleCartera.valor_item::numeric*PercPagar.pct_pagar::numeric/100))::numeric(11,2);
				--ValorAccionWPerc = DetalleCartera.valor_item; --PALIATIVO

				raise notice 'ValorAccionWPerc: %',ValorAccionWPerc;

				/*CARTERA VENCIDA*/
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

							if ( BolsaRop > 0 and (BolsaRop-ValorAccionWPerc) >= 0 ) then

								DetalleCartera.accion = 'SALDAR '||PercPagar.pct_pagar||'%';
								DetalleCartera.valor_accion = ValorAccionWPerc;

								BolsaRop = BolsaRop - ValorAccionWPerc;		-------------
								raise notice 'RestaBolsaRop: %',BolsaRop;	-------------

							else

								DetalleCartera.accion = 'SALDAR 0%';
								DetalleCartera.valor_accion = 0;

							end if;

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

						DetalleCartera.estado_cartera = 'FUTURO';

						if ( DetalleCartera.descripcion = 'CAPITAL' OR DetalleCartera.descripcion = 'AVAL') then
							raise notice 'Entra A';
							if ( BolsaRop > 0 and (BolsaRop-ValorAccionWPerc) >= 0 ) then

								DetalleCartera.accion = 'SALDAR '||PercPagar.pct_pagar||'%';
								DetalleCartera.valor_accion = ValorAccionWPerc;

								BolsaRop = BolsaRop - ValorAccionWPerc;
								raise notice 'RestaBolsaRop: %',BolsaRop;
							else
								raise notice 'BolsaRop: %, ValorAccionWPerc: %',BolsaRop,ValorAccionWPerc;
								DetalleCartera.accion = 'AJUSTE AUTOMATICO CAPITAL';
								DetalleCartera.valor_accion = 0;

							end if;

						elsif ( DetalleCartera.descripcion = 'INTERESES' ) then

							raise notice 'Entra B';
							IF ( PercPagar.pct_pagar < 100 ) THEN
								DetalleCartera.accion = 'AJUSTE AUTOMATICO INTERESES';
								DetalleCartera.valor_accion = 0;
							ELSE
								DetalleCartera.valor_accion = ValorAccionWPerc;
								DetalleCartera.accion = 'REVERTIR INTERESES';
							END IF;


						end if;


						------------------------------------------PALIATIVO----------------------------------------------------------------
						/*
						RAISE NOTICE 'AAAAAAXXXXAAAAA:, %',BolsaRop;

						DetalleCartera.estado_cartera = 'CORRIENTE-LOCO';
						raise notice 'BolsaRop: %, ValorAccionWPerc: %, Diferencia: %',BolsaRop,ValorAccionWPerc,BolsaRop-ValorAccionWPerc;

						if ( BolsaRop > 0 and (BolsaRop-ValorAccionWPerc) >= 0 ) then

							DetalleCartera.accion = 'SALDAR '||PercPagar.pct_pagar||'%';
							DetalleCartera.valor_accion = ValorAccionWPerc;

							BolsaRop = BolsaRop - ValorAccionWPerc;
							raise notice 'RestaBolsaRop: %',BolsaRop;

						else

							--DetalleCartera.accion = 'SALDAR 0%';
							DetalleCartera.accion = 'SALDAR '||PercPagar.pct_pagar||'%';
							DetalleCartera.valor_accion = BolsaRop;
							BolsaRop = 0;
							DetalleCartera.accion = 'SALDAR 0%';

						end if;
						*/
						----------------------------------------------------------------------------------------------------------

					END IF;

				END IF;

				RETURN NEXT DetalleCartera;

			END LOOP;
			--

		END LOOP;

		raise notice '#############################################################';


	END LOOP;
	--

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_distribucionpagos(integer, character varying)
  OWNER TO postgres;
