-- Function: actualizar_referencias_23050118(text)

-- DROP FUNCTION actualizar_referencias_23050118(text);

CREATE OR REPLACE FUNCTION actualizar_referencias_23050118(text)
  RETURNS text AS
$BODY$
DECLARE
    _periodo ALIAS FOR $1;

    detalle RECORD;

    _distrito CHARACTER(15):= '';
    _proveedor CHARACTER(15):= '';
    _tipo_documento CHARACTER(15):= '';
    _documento CHARACTER(30):= '';
    _item CHARACTER(30):= '';
    _planilla CHARACTER(10):= '';
    _propietario CHARACTER(12):= '';

    _leidos NUMERIC(8):= 0;
    _actualizados NUMERIC(8) := 0;




BEGIN


    FOR detalle IN select
                     tipodoc,
                     numdoc,
                     grupo_transaccion,
                     transaccion,
                     valor_debito
                   from
                     con.comprodet
                   where
                     tipodoc = 'FAP' and
                     periodo = _periodo and
                     cuenta = '23050118' and
                     referencia_2 = '' and
                     valor_debito > 0
                   order by
                     grupo_transaccion, transaccion

    LOOP

        _leidos := _leidos + 1;

	select into
	  _distrito, _proveedor, _tipo_documento, _documento, _item, _planilla, _propietario

	  b.dstrct,
	  b.proveedor,
	  b.tipo_documento,
	  b.documento,
	  b.item,
	  b.descripcion as planilla,
	  c.propietario_planilla

	from
	  fin.cxp_doc a,
	  fin.cxp_items_doc b,
	  tem.planilla c

	where
	  a.dstrct = 'FINV' and
	  a.tipo_documento = 'FAP' and
	  a.documento = detalle.numdoc and
	  a.transaccion = detalle.grupo_transaccion and
	  b.dstrct = a.dstrct and
	  b.proveedor = a.proveedor and
	  b.tipo_documento = a.tipo_documento and
	  b.documento = a.documento and
	  b.vlr = detalle.valor_debito and
	  b.referencia_2 = '' and
	  c.planilla = b.descripcion
	limit 1 ;


        if _propietario  is not null then

                _actualizados := _actualizados + 1;

		update
		  fin.cxp_items_doc i
		set
		  tipo_referencia_2 = 'PLA',
		  referencia_2 = _planilla,
		  tipo_referencia_3 = 'NIP',
		  referencia_3 = _propietario
		where
		  i.dstrct = _distrito and
		  i.proveedor = _proveedor and
		  i.tipo_documento = _tipo_documento and
		  i.documento = _documento and
		  i.item = _item;


		 update
		   con.comprodet c
		 set
		  tipo_referencia_2 = 'PLA',
		  referencia_2 = _planilla,
		  tipo_referencia_3 = 'NIP',
		  referencia_3 = _propietario
		 where
		  c.tipodoc = detalle.tipodoc and
		  c.numdoc = detalle.numdoc and
		  c.grupo_transaccion = detalle.grupo_transaccion and
		  c.transaccion = detalle.transaccion ;

	end if;

    END LOOP;


    RETURN 'Leidos: '||_leidos||'  Actualizados: '||_actualizados;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION actualizar_referencias_23050118(text)
  OWNER TO postgres;
