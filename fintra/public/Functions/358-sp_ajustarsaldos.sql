-- Function: sp_ajustarsaldos(character varying, character varying)

-- DROP FUNCTION sp_ajustarsaldos(character varying, character varying);

CREATE OR REPLACE FUNCTION sp_ajustarsaldos(_negocio character varying, usuario character varying)
  RETURNS text AS
$BODY$

DECLARE

	BaseObligaciones record;
	ItemCtaLiquidador record;
	RsUacOnly record;
	RsUacFondo record;
	FacturasNegocio record;

	mcad TEXT;

	NoCuota int := 1;

	saldo numeric;
	BolsaPagos numeric;

	_numero_factura CHARACTER VARYING;
	_auxiliar CHARACTER VARYING;

BEGIN

	mcad = 'TERMINADO!';

	SELECT INTO BaseObligaciones nxl.*
	,(nxl.tasa / 100)::NUMERIC as tasa_interes
	,((1 - POW(1 + (nxl.tasa / 100), - nxl.plazo::int))/(nxl.tasa / 100))::NUMERIC AS interes_efectivo
	,(referencia::numeric)::int as cod_estudiante
	FROM administrativo.negocios_xliquidacion nxl
	WHERE nxl.fecha_primera_cuota::date != '0099-01-01'::date
	and nxl.estado = 'SP'
	and nxl.cod_neg = _Negocio;

	BolsaPagos = 0;

	select into RsUacOnly * from administrativo.uac where codigo_est = BaseObligaciones.cod_estudiante;
	if found then

		BolsaPagos = RsUacOnly.total_pagos::numeric;
		NoCuota = 1;

		FOR FacturasNegocio IN

			select * from con.factura where negasoc = BaseObligaciones.cod_neg order by documento

		LOOP

			if ( BolsaPagos > 0 ) then

				if ( BolsaPagos >= FacturasNegocio.valor_saldo ) then

					update con.factura set valor_abono = valor_abono::numeric + FacturasNegocio.valor_saldo::numeric, valor_saldo = 0 where documento = FacturasNegocio.documento;
					BolsaPagos = BolsaPagos - FacturasNegocio.valor_saldo;

				elsif ( BolsaPagos < FacturasNegocio.valor_saldo ) then

					update con.factura set valor_abono = valor_abono::numeric + BolsaPagos, valor_saldo = valor_saldo - BolsaPagos where documento = FacturasNegocio.documento;
					BolsaPagos = BolsaPagos - BolsaPagos;

				end if;

			end if;

			update con.factura set num_doc_fen = NoCuota where documento = FacturasNegocio.documento;
			NoCuota = NoCuota + 1;

		END LOOP;
	end if;

	BolsaPagos = 0;

	select into RsUacFondo * from administrativo.uac_fondo where codigo_est = BaseObligaciones.cod_estudiante;
	if found then

		BolsaPagos = RsUacFondo.total_pagos::numeric;
		NoCuota = 1;

		FOR FacturasNegocio IN

			select * from con.factura where negasoc = BaseObligaciones.cod_neg order by documento

		LOOP

			if ( BolsaPagos > 0 ) then

				if ( BolsaPagos >= FacturasNegocio.valor_saldo ) then

					update con.factura set valor_abono = valor_abono::numeric + FacturasNegocio.valor_saldo::numeric, valor_saldo = 0 where documento = FacturasNegocio.documento;
					BolsaPagos = BolsaPagos - FacturasNegocio.valor_saldo;

				elsif ( BolsaPagos < FacturasNegocio.valor_saldo ) then

					update con.factura set valor_abono = valor_abono::numeric + BolsaPagos, valor_saldo = valor_saldo - BolsaPagos where documento = FacturasNegocio.documento;
					BolsaPagos = BolsaPagos - BolsaPagos;

				end if;

			end if;

			update con.factura set num_doc_fen = NoCuota where documento = FacturasNegocio.documento;
			NoCuota = NoCuota + 1;

		END LOOP;

	end if;

	RETURN mcad;

END
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_ajustarsaldos(character varying, character varying)
  OWNER TO postgres;
