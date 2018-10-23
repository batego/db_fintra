-- Function: sp_cxclibranza_ii(character varying, character varying)

-- DROP FUNCTION sp_cxclibranza_ii(character varying, character varying);

CREATE OR REPLACE FUNCTION sp_cxclibranza_ii(_cod_neg character varying, _user character varying)
  RETURNS text AS
$BODY$

DECLARE

	fila_items record;
	rsProveedor record;

	_respuesta varchar := 'OK';
	_numerofac_query varchar := '';
	_numero_factura varchar := '';
	_auxiliar varchar := '';
	_PeriodoCte varchar := '';
	SerieIFLibranza varchar := '';
	SerieCxPSeguro varchar := '';

	cnt numeric;
	saldo numeric;
	_grupo_transaccion numeric;
	_transaccion numeric;
	_ValorCuota numeric;

	miHoy date;

BEGIN

	miHoy = now()::date;
	_PeriodoCte = replace(substring(miHoy,1,7),'-','')::varchar;

	/*-----------------------------
	   --Generar la cartera--
	-------------------------------*/

	_numerofac_query = '';
	--SELECT INTO _numerofac_query get_lcod('CXC_LIBRANZA'); --*
	cnt = 1;

	FOR fila_items IN

		SELECT dna.cod_neg, dna.item, dna.fecha, dna.dias, dna.saldo_inicial, dna.capital, dna.interes, dna.valor, dna.saldo_final, dna.reg_status, dna.creation_date, dna.no_aval, dna.capacitacion, dna.cat, dna.seguro, dna.interes_causado, dna.fch_interes_causado, dna.documento_cat, dna.custodia, dna.remesa, dna.causar, n.cod_cli, n.fecha_negocio, n.cmc, n.id_convenio
		FROM documentos_neg_aceptado dna, negocios n
		WHERE dna.cod_neg = n.cod_neg
		      AND item != 0
		      AND dna.cod_neg = _cod_neg
		ORDER BY dna.dias
	LOOP

		/*---------------------------------------
		   --Generar Control de CxP Aseguradora--
		-----------------------------------------*/

		SELECT INTO SerieCxPSeguro SP_SerieSegurosLibranza();

		INSERT INTO control_seguros_libranza(
			    reg_status, dstrct, nit, cod_neg, tipodoc, documento, cuota,
			    fecha_vencimiento, valor, periodo, transaccion, fecha_contabilizacion,
			    creation_date, creation_user, usuario_aplicacion, last_update, user_update)
		    VALUES (
			    '', 'FINV', fila_items.cod_cli, _cod_neg, 'CXP_DIF', SerieCxPSeguro, fila_items.item,
			    fila_items.fecha, fila_items.seguro, '', 0, '0099-01-01 00:00:00',
			    now(), _User, '', now(), '');
	END LOOP;

	RETURN _respuesta;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_cxclibranza_ii(character varying, character varying)
  OWNER TO postgres;
