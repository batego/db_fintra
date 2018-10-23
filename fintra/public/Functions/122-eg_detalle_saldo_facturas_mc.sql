-- Function: eg_detalle_saldo_facturas_mc(text, integer)

-- DROP FUNCTION eg_detalle_saldo_facturas_mc(text, integer);

CREATE OR REPLACE FUNCTION eg_detalle_saldo_facturas_mc(codneg text, cuota integer)
  RETURNS SETOF rs_detalle_saldo_facturas AS
$BODY$
DECLARE

  _saldo_aplicar numeric:=0.00;
  _recordFacturas record;
  rs rs_detalle_saldo_facturas;

BEGIN
	raise notice 'codneg : %',codneg;

       _saldo_aplicar:=(SELECT valor_abono FROM con.factura fac WHERE fac.negasoc =codneg AND fac.num_doc_fen=cuota AND fac.reg_status='' AND fac.reg_status='' AND fac.tipo_documento = 'FAC' AND documento LIKE 'MC%');
        rs.total_abonos :=_saldo_aplicar;


       raise notice '_valor_abono : %',_saldo_aplicar;

       FOR _recordFacturas IN  (
					SELECT  fdet.descripcion
					       ,fdet.valor_unitario
					       ,fac.documento
					       ,fac.fecha_vencimiento
					       ,fac.valor_factura
					       ,fac.valor_abono
					       ,fac.valor_saldo
					       ,coalesce(tem.esquema,'N') as esquema
				       FROM con.factura fac
				       INNER JOIN con.factura_detalle fdet ON (fac.documento=fdet.documento)
				       INNER JOIN conceptos_facturacion cf ON (fdet.descripcion=cf.descripcion)
				       LEFT JOIN tem.negocios_facturacion_old tem ON (tem.cod_neg=fac.negasoc)
				       WHERE fac.negasoc = codneg
				       AND fac.reg_status=''
				       AND fac.dstrct = 'FINV'
				       AND fac.tipo_documento = 'FAC'
				       AND fac.num_doc_fen= cuota
				       ORDER BY cf.prioridad_pago
				)
	LOOP
		rs.documento=_recordFacturas.documento;
		rs.total_factura:=_recordFacturas.valor_factura;

		RAISE NOTICE 'recordFacturas.descripcion: % esquema: %',_recordFacturas.descripcion,_recordFacturas.esquema;

		IF(_recordFacturas.descripcion='CUOTA-ADMINISTRCION')THEN

			IF(_saldo_aplicar >= _recordFacturas.valor_unitario)THEN
			   rs.saldo_cuota_manejo:=0.00;
			ELSIF(_saldo_aplicar > 0)THEN
			   rs.saldo_cuota_manejo:=_recordFacturas.valor_unitario-_saldo_aplicar ;
			ELSE
			    rs.saldo_cuota_manejo:=_recordFacturas.valor_unitario;
			END IF;

		ELSIF(_recordFacturas.esquema='S')THEN
			 rs.saldo_cuota_manejo:=0.00;
		END IF;

		RAISE NOTICE '------>rs.saldo_cuota_manejo: %', rs.saldo_cuota_manejo;

		IF(_recordFacturas.descripcion='CAT')THEN

			IF(_saldo_aplicar >= _recordFacturas.valor_unitario)THEN
			   rs.saldo_cat :=0.00;
			ELSIF(_saldo_aplicar > 0)THEN
			   rs.saldo_cat :=_recordFacturas.valor_unitario-_saldo_aplicar ;
			ELSE
			   rs.saldo_cat := _recordFacturas.valor_unitario;
			END IF;

		ELSIF(_recordFacturas.esquema='S')THEN
			rs.saldo_cat :=0.00;
		END IF;


		RAISE NOTICE '------>rs.saldo_cat: %', rs.saldo_cat;

		IF(_recordFacturas.descripcion='INTERES')THEN

			IF(_saldo_aplicar >= _recordFacturas.valor_unitario)THEN
			   rs.saldo_interes :=0.00;
			ELSIF(_saldo_aplicar > 0)THEN
			   rs.saldo_interes :=_recordFacturas.valor_unitario-_saldo_aplicar ;
			ELSE
			   rs.saldo_interes := _recordFacturas.valor_unitario;
			END IF;

		ELSIF(_recordFacturas.esquema='S')THEN
			rs.saldo_interes :=0.00;
		END IF;

		RAISE NOTICE '------>rs.saldo_interes: %',rs.saldo_interes;

		IF(_recordFacturas.descripcion ='SEGURO')THEN

			IF(_saldo_aplicar >= _recordFacturas.valor_unitario)THEN
			   rs.saldo_seguro :=0.00;
			ELSIF(_saldo_aplicar > 0)THEN
			  rs.saldo_seguro :=_recordFacturas.valor_unitario-_saldo_aplicar ;
			ELSE
			   rs.saldo_seguro := _recordFacturas.valor_unitario;
			END IF;
		END IF;

		RAISE NOTICE '------>rs.saldo_seguro: %',rs.saldo_seguro;

		IF(_recordFacturas.descripcion ='CAPITAL')THEN

			IF(_saldo_aplicar >= _recordFacturas.valor_unitario)THEN
			   rs.saldo_capital :=0.00;
			ELSIF(_saldo_aplicar > 0)THEN
			  rs.saldo_capital :=_recordFacturas.valor_unitario-_saldo_aplicar ;
			ELSE
			   rs.saldo_capital:= _recordFacturas.valor_unitario;
			END IF;

		END IF;

		RAISE NOTICE '------>rs.saldo_capital: %',rs.saldo_capital;

		--Validamos el abono
		_saldo_aplicar:=_saldo_aplicar-_recordFacturas.valor_unitario;

	END LOOP;
	raise notice '%',rs;
	rs.cuota:=cuota;
	rs.negocio:=codneg;
	rs.saldo_factura := rs.saldo_cuota_manejo+rs.saldo_cat+ rs.saldo_interes + rs.saldo_seguro + rs.saldo_capital ;

    RETURN NEXT rs;

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_detalle_saldo_facturas_mc(text, integer)
  OWNER TO postgres;
