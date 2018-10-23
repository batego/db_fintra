-- Function: sp_buscarfacturasendosar(character varying, character varying, character varying, character varying, character varying, character varying)

-- DROP FUNCTION sp_buscarfacturasendosar(character varying, character varying, character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION sp_buscarfacturasendosar(linea_negocio character varying, unidadnegocio character varying, cartera_en character varying, cedula_cliente character varying, negocio character varying, checksaldo character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE

	CarteraGeneral record;
	SaldoActual record;

	SQL TEXT;

	filtro varchar;
	nombre_fiducia varchar;

	miHoy date;

BEGIN

	IF (UnidadNegocio = 'todos') THEN
		filtro = 'AND un.ref_4 = ''' || linea_negocio || '''';
	ELSIF (UnidadNegocio = 'null') THEN
		filtro = '';
	ELSE
		filtro = 'AND un.id = ''' || UnidadNegocio || '''';
	END IF;

	IF ( cartera_en = '8020220161' ) THEN

		SQL = '
		SELECT
			''''::varchar as cartera_en,
			sp_uneg_negocio(negasoc)::varchar as id_uneg_negocio,
			sp_uneg_negocio_name(negasoc)::varchar as uneg_negocio,
			nit::varchar as nit_cliente,
			get_nombc(f.nit)::varchar as nombre_cliente,
			f.codcli::varchar,
			negasoc::varchar as negocio,
			eg_tipo_negocio(negasoc)::varchar as tipo_negocio,
			f.documento::varchar,
			f.num_doc_fen::varchar as cuota,
			f.fecha_vencimiento::date,
			(now()::date-f.fecha_vencimiento::date)::numeric as dias_vencidos,
			f.valor_factura::numeric,
			f.valor_abono::numeric,
			f.valor_saldo::numeric
		FROM con.factura f
		     inner join negocios as neg on (neg.cod_neg=f.negasoc and neg.estado_neg IN (''T'',''A''))
		     inner join rel_unidadnegocio_convenios as run on (run.id_convenio=neg.id_convenio)
		     inner join unidad_negocio as un on (run.id_unid_negocio=un.id and ref_4 != '''' '|| filtro ||')
		     inner join con.cmc_doc AS cmc on (cmc.cmc=f.cmc and cmc.tipodoc=f.tipo_documento)
		     left join administrativo.control_endosofiducia as ctrl on (ctrl.documento = f.documento and ctrl.negocio = f.negasoc and ctrl.endosar_en != '''')
		WHERE f.reg_status=''''
			AND f.dstrct =''FINV''
			AND substring(f.documento,1,2) not in (''AP'',''AC'',''R0'',''FF'',''CP'',''PF'')
			AND f.valor_saldo > 0
			AND ctrl.documento is null
			and negasoc in (select negasoc from tem.endoso_fc_sept18 group by negasoc)
			and negasoc not in (select codneg from ing_fenalco where periodo != '''' and reg_status = '''' group by codneg)';
		if ( cedula_cliente != '' ) then SQL = SQL || ' AND nit = '''||cedula_cliente||''''; end if;
		if ( Negocio != '' ) then SQL = SQL || ' AND negasoc = '''||Negocio||''''; end if;
		SQL = SQL || ' ORDER BY negasoc,documento, num_doc_fen'; --where negasoc = ''FA31150''
		--and negasoc in (select negasoc from tem.endoso_fc_marzo group by negasoc)
		--inner join unidad_negocio as un on (run.id_unid_negocio=un.id and ref_4 != '''' '|| filtro ||') | 2,4 | 8,10
		raise notice 'SQL: %', SQL;
	ELSE

		SQL = '
		SELECT
			endosar_en::varchar as cartera_en,
			id_unidad_negocio::varchar,
			unidad_negocio::varchar,
			nit_cliente::varchar,
			nombre_cliente::varchar,
			f.codcli::varchar,
			f.negocio::varchar,
			f.tipo_negocio::varchar,
			f.documento::varchar,
			f.cuota::varchar,
			f.fecha_vencimiento::date,
			(now()::date-f.fecha_vencimiento::date)::numeric as dias_vencidos,
			0::numeric as valor_factura,
			0::numeric as valor_abono,
			0::numeric as valor_saldo
		FROM administrativo.control_endosofiducia f
		     inner join negocios as neg on (neg.cod_neg=f.negocio and neg.estado_neg IN (''T'',''A''))
		     inner join rel_unidadnegocio_convenios as run on (run.id_convenio=neg.id_convenio)
		     inner join unidad_negocio as un on (run.id_unid_negocio=un.id and ref_4 != '''' '|| filtro ||')
		     inner join con.factura fa on (fa.documento=f.documento) --CAMBIO DANIELA
		WHERE f.reg_status=''''
		AND f.dstrct =''FINV''
		AND negocio in (select negasoc from tem.endoso_fc_sept18 group by negasoc)
		AND fa.valor_saldo > 0 --CAMBIO DANIELA
		AND endosar_en = '''||cartera_en||'''';
		if ( cedula_cliente != '' ) then SQL = SQL || ' AND nit_cliente = '''||cedula_cliente||''''; end if;
		if ( Negocio != '' ) then SQL = SQL || ' AND negocio = '''||Negocio||''''; end if;
		SQL = SQL || ' ORDER BY negocio,documento, cuota';

	END IF;

	raise notice 'SQL PPAL: %',SQL;
	FOR CarteraGeneral IN EXECUTE SQL LOOP

		select into nombre_fiducia nombre from nit where cedula = cartera_en;

		IF ( cartera_en != '8020220161' ) THEN

			select into SaldoActual * from con.factura where documento = CarteraGeneral.documento;
			CarteraGeneral.valor_factura = SaldoActual.valor_factura;
			CarteraGeneral.valor_abono = SaldoActual.valor_abono;
			CarteraGeneral.valor_saldo = SaldoActual.valor_saldo;

		END IF;

		CarteraGeneral.cartera_en = nombre_fiducia;
		RETURN NEXT CarteraGeneral;

	END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_buscarfacturasendosar(character varying, character varying, character varying, character varying, character varying, character varying)
  OWNER TO postgres;
