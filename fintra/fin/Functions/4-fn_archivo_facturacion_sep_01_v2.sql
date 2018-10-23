-- Function: fin.fn_archivo_facturacion_sep_01_v2(text[], text, integer)

-- DROP FUNCTION fin.fn_archivo_facturacion_sep_01_v2(text[], text, integer);

CREATE OR REPLACE FUNCTION fin.fn_archivo_facturacion_sep_01_v2(_cabecera text[], _periodo text, _ciclo integer)
  RETURNS SETOF text AS
$BODY$
 DECLARE
  _cantidad INTEGER;
  _suma NUMERIC;
  _fecha TEXT;

  _record_det RECORD;

 BEGIN
  _cantidad := 0;
  _suma := 0;

  raise notice '------------------------------------';
--select to_char(current_timestamp, 'YYYYMMDDHH24MI') (replace(replace(replace(now(),'-',''),':',''),' ',''))
  IF _cabecera[4] = 'now' THEN
	SELECT INTO _fecha to_char(current_timestamp, 'YYYYMMDDHH24MI');
  ELSE _fecha = _cabecera[4];
  END IF;

  RETURN NEXT
      (SELECT ('01'
           || lpad(SUBSTRING(_cabecera[1], 1, 10), 10, '0')
           || lpad(SUBSTRING(_cabecera[2], 1, 10), 10, '0')
           || lpad(SUBSTRING(_cabecera[3], 1, 3), 3, '0')
           || lpad(SUBSTRING(_fecha, 1, 12), 12, '0')
           || lpad(SUBSTRING(_cabecera[5], 1, 1), 1, '0')
           || lpad('', 182, ' '))::TEXT);

  RETURN NEXT
      (SELECT ('05'
           || lpad(SUBSTRING(_cabecera[6], 1, 13), 13, '0')
           || '0001'
           || lpad(SUBSTRING(_cabecera[7], 1, 15), 15, '0')
           || lpad('', 186, ' '))::TEXT);

  FOR _record_det IN (SELECT
                            replace(cod_rop,'EXT','') as ident_factura,
                            cedula as ident_usuario,
                            substring (periodo_rop ,5,2) as periodo_facturado,
                            ciclo.num_ciclo ::text as ciclo,
                            total as valor_servicio,
                            replace((ciclo.fecha_pago + interval '1 mons -1 day')::date,'-','') as fecha_vencimiento --vencimiento_rop
                            FROM recibo_oficial_pago
			    INNER JOIN con.ciclos_facturacion ciclo
				    ON id_ciclo = ciclo.id AND ciclo.periodo=_periodo AND ciclo.num_ciclo = _ciclo
				    WHERE duplicado = 'N')

                            /*WHERE cod_rop (
				select cod_rop from recibo_oficial_pago where periodo_rop='201506' and cod_rop not like 'EPR%' and id_ciclo=22)
                            ) select * from con.ciclos_facturacion
	/* in (select cod_rop from recibo_oficial_pago
	where creation_date::date =
	(select max(creation_date::date)
	from recibo_oficial_pago where cod_rop not like 'EPR%')))*/
  LOOP

    raise notice '--> ';
    _cantidad = _cantidad + 1;
    _suma = _suma + _record_det.valor_servicio;
    RETURN NEXT
        (SELECT ('06'
	    || lpad(SUBSTRING(_record_det.ident_factura, 1, 48), 48, '0')
	    || lpad(SUBSTRING(_record_det.ident_usuario, 1, 30), 30, '0')
	    || lpad(SUBSTRING(_record_det.periodo_facturado, 1, 2), 2, '0')
	    || lpad(SUBSTRING(_record_det.ciclo, 1, 3), 3, '0')
	    || lpad(SUBSTRING(replace(_record_det.valor_servicio, '.',''), 1, 14), 14, '0')
	    || lpad(SUBSTRING('', 1, 27), 27, '0')
	    || lpad(SUBSTRING(_record_det.fecha_vencimiento, 1, 8), 8, '0')
	    || lpad(SUBSTRING('', 1, 62), 62, '0')
	    || lpad('', 24, ' '))::TEXT);
  END LOOP;


  RETURN NEXT
      (SELECT ('08'
           || lpad(_cantidad, 9, '0')
           || lpad(replace(_suma, '.',''), 18, '0')
           || lpad('', 18, '0')
           || '0001'
           || lpad('', 169, ' '))::TEXT);

  RETURN NEXT
      (SELECT ('09'
           || lpad(_cantidad, 9, '0')
           || lpad(replace(_suma, '.',''), 18, '0')
           || lpad('', 18, '0')
           || lpad('', 173, ' '))::TEXT);

 END
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION fin.fn_archivo_facturacion_sep_01_v2(text[], text, integer)
  OWNER TO postgres;
