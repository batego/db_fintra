-- Function: sp_liqnegociosterceros(character varying)

-- DROP FUNCTION sp_liqnegociosterceros(character varying);

CREATE OR REPLACE FUNCTION sp_liqnegociosterceros(usuario character varying)
  RETURNS text AS
$BODY$

DECLARE

	BaseObligaciones record;
	Rs record;
	ReturnAjustePagos varchar;
	Msg TEXT := 'OK';

BEGIN

	FOR BaseObligaciones IN

		SELECT nxl.*
		,(nxl.tasa / 100)::NUMERIC as tasa_interes
		,((1 - POW(1 + (nxl.tasa / 100), - nxl.plazo::int))/(nxl.tasa / 100))::NUMERIC AS interes_efectivo
		FROM administrativo.negocios_xliquidacion nxl
		WHERE nxl.fecha_primera_cuota::date != '0099-01-01'::date and estado = 'SP' --'NP'
	LOOP
		--GENERA LIQUIDADOR, CARTERA E INGRESOS DIFERIDOS
		--select into Rs * from SP_liqNegocio(BaseObligaciones.cod_neg, Usuario);

		--CONTABILIZAR NEGOCIO


		--GENERAR CXP


		--ACTUALIZA LOS NEGOCIOS QUE FUERON PROCESADOS
		UPDATE administrativo.negocios_xliquidacion SET estado = 'SP' WHERE cod_neg = BaseObligaciones.cod_neg;

		--AJUSTAR SALDOS CON LOS PAGOS DE LAS TABLAS CARGADAS.
		select into ReturnAjustePagos SP_AjustarSaldos(BaseObligaciones.cod_neg, Usuario);


	END LOOP;

	return Msg;
END
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_liqnegociosterceros(character varying)
  OWNER TO postgres;
