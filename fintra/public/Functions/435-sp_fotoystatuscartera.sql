-- Function: sp_fotoystatuscartera()

-- DROP FUNCTION sp_fotoystatuscartera();

CREATE OR REPLACE FUNCTION sp_fotoystatuscartera()
  RETURNS text AS
$BODY$

DECLARE

	mcad TEXT;
	ValidarFoto numeric;
	_peridoFoto text:=replace(substring(now()::date,1,7),'-','');
	_detalle_factura CHARACTER VARYING;
        _outStatusCartera text;

BEGIN

	mcad = 'TERMINADO!';

	select into ValidarFoto count(0) from con.foto_cartera where periodo_lote = replace(substring(now(),1,7),'-','')::numeric;
	--select count(0) from con.foto_cartera where periodo_lote = replace(substring(now(),1,7),'-','')::numeric;

	IF ( ValidarFoto = 0 ) THEN

		mcad = 'VACIO';

		BEGIN

			insert into con.foto_cartera (
				periodo_lote,id_convenio,reg_status, dstrct,
				tipo_documento, documento, nit, codcli, concepto, fecha_negocio,fecha_factura, fecha_vencimiento, fecha_ultimo_pago, descripcion,
				valor_factura, valor_abono, valor_saldo, valor_facturame, valor_abonome, valor_saldome, forma_pago, transaccion,
				fecha_contabilizacion, creation_date_cxc, creation_user, cmc, periodo, negasoc, num_doc_fen, agencia_cobro
			)
			select
			replace(substring(now()::date,1,7),'-',''),(select id_convenio from negocios where cod_neg = con.factura.negasoc and dist = 'FINV'),
			reg_status, dstrct,
			tipo_documento, documento, nit, codcli, substring(concepto,1,6),
			(select fecha_negocio from negocios where cod_neg = con.factura.negasoc and dist = 'FINV'),
			fecha_factura, fecha_vencimiento, fecha_ultimo_pago,
			descripcion,
			valor_factura, valor_abono, valor_saldo, valor_facturame, valor_abonome, valor_saldome, forma_pago, transaccion,
			fecha_contabilizacion, now(), creation_user, cmc, periodo, negasoc, num_doc_fen, agencia_cobro
			from con.factura
			where reg_status != 'A'
			and dstrct = 'FINV'
			and tipo_documento in ('FAC','NDC')
			and substring(documento,1,2) not in ('NM','PM','RM','IPM','INM','IRM','RE','PP','EF');
			--limit 1;

			IF FOUND THEN

				--1.)INSERTAMOS EN LA TABLA DE PERIODOS...
				insert into con.periodos_foto (dstrct,valor,descripcion)
				VALUES ('FINV',_peridoFoto,_peridoFoto);


				_outStatusCartera:=sp_updatestatuscartera();
				raise notice '_outStatusCartera : %',_outStatusCartera;

				mcad = 'FOTO_TOMADA';

			END IF;

		EXCEPTION

			WHEN OTHERS THEN
				--RAISE EXCEPTION 'FOTO_ERROR';
				RAISE EXCEPTION 'EL ERROR FUE: %',SQLERRM;
		END;

	ELSE

		mcad = 'FOTO_YAFUEGENERADA!';

	END IF;

  RETURN mcad;

  END;
  $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_fotoystatuscartera()
  OWNER TO postgres;
