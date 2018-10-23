-- Function: eg_detalle_saldo_facturas_mc_foto(text, integer, character varying)

-- DROP FUNCTION eg_detalle_saldo_facturas_mc_foto(text, integer, character varying);

CREATE OR REPLACE FUNCTION eg_detalle_saldo_facturas_mc_foto(codneg text, cuota integer, _perido_foto character varying)
  RETURNS SETOF rs_detalle_saldo_facturas AS
$BODY$
DECLARE

  _saldo_aplicar numeric:=0.00;
  _recordFacturas record;
  rs rs_detalle_saldo_facturas;

BEGIN
	raise notice 'codnegxxx : % cuota: %' ,codneg, cuota;
	--select * from con.foto_cartera fac WHERE fac.negasoc ='MC09851' and fac.num_doc_fen='2' and  fac.reg_status='' AND fac.reg_status='' AND fac.tipo_documento = 'FAC'
	 --select * from con.factura   fac WHERE fac.negasoc ='MC09851' and fac.num_doc_fen='2' and  fac.reg_status='' AND fac.reg_status='' AND fac.tipo_documento = 'FAC'
       _saldo_aplicar:=(SELECT valor_abono FROM con.foto_cartera fac WHERE fac.periodo_lote=_perido_foto and fac.negasoc =codneg AND fac.num_doc_fen=cuota AND fac.reg_status='' AND fac.reg_status='' AND fac.tipo_documento = 'FAC');
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
				       FROM con.foto_cartera fac
				       INNER JOIN con.factura_detalle fdet ON (fac.documento=fdet.documento)
				       INNER JOIN conceptos_facturacion cf on (fdet.descripcion=cf.descripcion)
				       WHERE fac.negasoc = codneg
				       and fac.periodo_lote=_perido_foto
				       AND fac.reg_status=''
				       AND fac.dstrct = 'FINV'
				       AND fac.tipo_documento = 'FAC'
				       AND fac.num_doc_fen= cuota
				       ORDER BY cf.prioridad_pago
				)
	LOOP
		rs.documento=_recordFacturas.documento;
		rs.total_factura:=_recordFacturas.valor_factura;

		IF(_recordFacturas.descripcion='CUOTA-ADMINISTRCION')THEN

			IF(_saldo_aplicar >= _recordFacturas.valor_unitario)THEN
			   rs.saldo_cuota_manejo:=0.00;
			ELSIF(_saldo_aplicar > 0)THEN
			   rs.saldo_cuota_manejo:=_recordFacturas.valor_unitario-_saldo_aplicar ;
			ELSE
			    rs.saldo_cuota_manejo:=_recordFacturas.valor_unitario;
			END IF;

		END IF;

		IF(_recordFacturas.descripcion='CAT')THEN

			IF(_saldo_aplicar >= _recordFacturas.valor_unitario)THEN
			   rs.saldo_cat :=0.00;
			ELSIF(_saldo_aplicar > 0)THEN
			   rs.saldo_cat :=_recordFacturas.valor_unitario-_saldo_aplicar ;
			ELSE
			   rs.saldo_cat := _recordFacturas.valor_unitario;
			END IF;

		END IF;

		IF(_recordFacturas.descripcion='INTERES')THEN

			IF(_saldo_aplicar >= _recordFacturas.valor_unitario)THEN
			   rs.saldo_interes :=0.00;
			ELSIF(_saldo_aplicar > 0)THEN
			   rs.saldo_interes :=_recordFacturas.valor_unitario-_saldo_aplicar ;
			ELSE
			   rs.saldo_interes := _recordFacturas.valor_unitario;
			END IF;

		END IF;

		IF(_recordFacturas.descripcion ='SEGURO')THEN

			IF(_saldo_aplicar >= _recordFacturas.valor_unitario)THEN
			   rs.saldo_seguro :=0.00;
			ELSIF(_saldo_aplicar > 0)THEN
			  rs.saldo_seguro :=_recordFacturas.valor_unitario-_saldo_aplicar ;
			ELSE
			   rs.saldo_seguro := _recordFacturas.valor_unitario;
			END IF;

		END IF;

		IF(_recordFacturas.descripcion ='CAPITAL')THEN

			IF(_saldo_aplicar >= _recordFacturas.valor_unitario)THEN
			   rs.saldo_capital :=0.00;
			ELSIF(_saldo_aplicar > 0)THEN
			  rs.saldo_capital :=_recordFacturas.valor_unitario-_saldo_aplicar ;
			ELSE
			   rs.saldo_capital:= _recordFacturas.valor_unitario;
			END IF;

		END IF;

		--Validamos el abono
		_saldo_aplicar:=_saldo_aplicar-_recordFacturas.valor_unitario;

	END LOOP;

	rs.cuota:=cuota;
	rs.negocio:=codneg;
	rs.saldo_factura := rs.saldo_cuota_manejo+rs.saldo_cat + rs.saldo_interes + rs.saldo_seguro + rs.saldo_capital ;

    RETURN NEXT rs;

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_detalle_saldo_facturas_mc_foto(text, integer, character varying)
  OWNER TO postgres;
