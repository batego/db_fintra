-- Function: con.mc_causar_intreses_multiservicio(character varying, character varying, character varying, character varying)

-- DROP FUNCTION con.mc_causar_intreses_multiservicio(character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION con.mc_causar_intreses_multiservicio(_periodo character varying, _cmc character varying, _cuentaingresointeres character varying, usuario character varying)
  RETURNS text AS
$BODY$
DECLARE

infoFacturas record;
_numeroComprobante varchar;
_grupo_transaccion VARCHAR;
_transaccion VARCHAR;
resultado varchar :='Error';
totalValor numeric;
items_ numeric;
_descripcionCmc varchar;

BEGIN
	SELECT into _numeroComprobante COALESCE(('CIM'||get_lcod('CIM')),'');

	IF( _numeroComprobante !='')THEN
		RAISE notice '_numeroComprobante %',_numeroComprobante;
		-- if (_cmc = 'SV') then
-- 			_descripcionCmc := 'FACTURA NM A PM FINTRA';
-- 		elsif (_cmc = 'SR' ) then
-- 			_descripcionCmc := 'REINTEGRO CARTERA FIDUCIA FMS';
-- 		elsif (_cmc = 'AS') then
-- 			_descripcionCmc := 'AIRES MULTISERVICIO';
-- 		elsif  (_cmc = 'FP') then
-- 			_descripcionCmc := 'FID COLPATRIA FMS';
-- 		end if;

		SELECT INTO _grupo_transaccion nextval('con.comprobante_grupo_transaccion_seq');

		FOR infoFacturas IN
			SELECT * FROM (
				SELECT
					documento::varchar as factura,
					(select codigo_cuenta_contable
						from con.factura_detalle
						where documento =CASE WHEN fra.cmc ='AS' THEN fra.documento ELSE  'N'||substring (fra.documento,2) END
						and concepto=227
						group by documento,codigo_cuenta_contable
					)::varchar as codigo_cuenta_contable_db,
					fra.nit::varchar AS nit_cliente,
					get_nombc(fra.nit) AS nombre_cliente,
					CASE when reg_status='A' then 'Anulada' else CASE WHEN valor_saldo=0 THEN 'Cancelada' ELSE 'Pendiente' END END as estado,
					CASE WHEN tipo_ref1='MS' THEN 'MULTISERVICIO' ELSE 'CREDITO' END AS tipo_cartera,
					CASE WHEN tipo_ref1='MS' THEN ref1 ELSE negasoc END AS relacionado,
					fecha_factura::date,
					fecha_vencimiento::date,
					valor_factura::numeric,
					valor_saldo::numeric,
					(select con.nombre from negocios n inner join convenios con on con.id_convenio=n.id_convenio where cod_neg = negasoc) as convenio,
					(select sum(fd.valor_unitario)
					from con.factura  f
					inner join con.factura_detalle fd  on ( fd.dstrct=f.dstrct and fd.tipo_documento=f.tipo_documento  and fd.documento = f.documento )
					where fd.concepto = '227'
					and substring(f.documento,1,2) in ('PM','RM')
					and f.documento=fra.documento) as Intereses,
					fra.ref1 AS multiservicio
				FROM con.factura fra
				WHERE  replace((substring(fra.fecha_vencimiento,1,7 )),'-','')::INTEGER = _periodo::INTEGER
				AND fra.cmc =_cmc
				AND fra.causacion_int_ms='N'
				AND fra.fecha_causacion_int_ms='0099-01-01 00:00:00'
				AND fra.reg_status=''
			)t_temporal
			WHERE Intereses IS NOT NULL
		LOOP

			--Debito
			SELECT INTO _transaccion nextval('con.comprodet_transaccion_seq');
			INSERT INTO con.comprodet(
				dstrct, tipodoc, numdoc, grupo_transaccion, transaccion,
				periodo, cuenta, detalle, valor_debito, valor_credito,
				tercero, documento_interno,creation_date,
				creation_user, tipodoc_rel, documento_rel,
				tipo_referencia_1, referencia_1)
			VALUES (
				'FINV', 'CDIAR', _numeroComprobante, _grupo_transaccion::integer, _transaccion::integer,
				_periodo, infoFacturas.codigo_cuenta_contable_db, _cmc||'_CAUS_INT_CTES_('||_periodo||')', infoFacturas.Intereses, 0,
				infoFacturas.nit_cliente, 'CD', now(), usuario,
				'NUMOS', infoFacturas.multiservicio, substring(infoFacturas.factura,1,2),infoFacturas.factura
			);

			--Credito
			SELECT INTO _transaccion nextval('con.comprodet_transaccion_seq');
				INSERT INTO con.comprodet(
					dstrct, tipodoc, numdoc, grupo_transaccion, transaccion,
					periodo, cuenta, detalle, valor_debito, valor_credito,
					tercero, documento_interno,creation_date,
					creation_user, tipodoc_rel, documento_rel,
					tipo_referencia_1, referencia_1)
				VALUES (
					'FINV', 'CDIAR', _numeroComprobante, _grupo_transaccion::integer, _transaccion::integer,
					_periodo, _cuentaIngresoInteres, _cmc||'_CAUS_INT_CTES_('||_periodo||')', 0, infoFacturas.Intereses,
					infoFacturas.nit_cliente, 'CD', now(), usuario,
					'NUMOS',  infoFacturas.multiservicio, substring(infoFacturas.factura,1,2),infoFacturas.factura );


			--marcamos la nm y la pm como causada
			--SELECT causacion_int_ms,fecha_causacion_int_ms,* FROM  con.factura  where documento='PM10266_10'

			UPDATE con.factura  SET causacion_int_ms='S',
						fecha_causacion_int_ms=now()
			WHERE documento IN (infoFacturas.factura, REPLACE(infoFacturas.factura,'P','N')) AND tipo_documento='FAC';


		END LOOP;

		SELECT INTO totalValor sum(valor_debito) from con.comprodet where numdoc = _numeroComprobante and tipodoc='CDIAR' AND grupo_transaccion=_grupo_transaccion;
		SELECT INTO items_ count(*) from con.comprodet where numdoc = _numeroComprobante and tipodoc='CDIAR' AND grupo_transaccion=_grupo_transaccion;

		--validamos el comprobante que este cuadrado
		IF((select sum(valor_debito)-sum(valor_credito) FROM con.comprodet  WHERE numdoc=_numeroComprobante AND grupo_transaccion=_grupo_transaccion) !=0.00)THEN
			DELETE FROM con.comprodet  WHERE numdoc=_numeroComprobante AND tipodoc='CDIAR' AND grupo_transaccion=_grupo_transaccion;
			RETURN resultado;
		END IF;

		INSERT INTO con.comprobante(
		    dstrct, tipodoc, numdoc, grupo_transaccion, sucursal,
		    periodo, fechadoc, detalle, tercero, total_debito, total_credito,
		    total_items, moneda, fecha_aplicacion,
		     creation_date, creation_user,  usuario_aplicacion,
		    tipo_operacion)
		VALUES (
			'FINV', 'CDIAR', _numeroComprobante, _grupo_transaccion::integer, 'OP',
			_periodo, now()::date, 'CAUSACION INTERESES MULTISERVICIOS '||_periodo,
			'8020220161', totalValor, totalValor, items_, 'PES', now(),  now(), usuario,
			usuario, 'GRAL');


		resultado:=_numeroComprobante;
	END IF;

	return resultado;
EXCEPTION WHEN others THEN
	raise notice '% %', SQLERRM, SQLSTATE;
	return resultado;

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.mc_causar_intreses_multiservicio(character varying, character varying, character varying, character varying)
  OWNER TO postgres;
