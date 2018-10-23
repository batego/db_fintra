-- Function: tem.buscar_fechas_demo(character varying)

-- DROP FUNCTION tem.buscar_fechas_demo(character varying);

CREATE OR REPLACE FUNCTION tem.buscar_fechas_demo(_identificacion character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE

 _fechapago record;
 recordRet record;
 _fecha_pago varchar;
 _cumple_tiempo varchar:='N';
 _iteracion integer:=1;
BEGIN

	for _fechapago in

			SELECT
				sp.numero_solicitud,
				sp.identificacion,
				sp.tipo,tipo_id,
				max(fac.fecha_vencimiento) as max_fecha_ven ,
				sum(fac.valor_saldo) as valor_saldo,
				(now()::date-max(fac.fecha_vencimiento::date))::integer AS periodo_gracia,
				neg.nro_docs::integer as cuotas
			FROM solicitud_persona sp
			INNER JOIN solicitud_aval sa ON (sa.numero_solicitud=sp.numero_solicitud)
			INNER JOIN negocios neg ON (neg.cod_neg=sa.cod_neg)
			INNER JOIN con.factura fac on (neg.cod_neg = fac.negasoc and fac.reg_status='')
			WHERE tipo='S' AND sp.reg_status=''
			AND neg.estado_neg='T'
			AND (now()::DATE-neg.creation_date::DATE) > 60
			and identificacion=  _identificacion
			GROUP BY  identificacion,tipo,tipo_id,sp.numero_solicitud,neg.nro_docs
			order by max(fac.fecha_vencimiento) desc
	loop

		raise notice '_fechapago.valor_saldo : % ,_fechapago.cuotas : % , _fechapago.periodo_gracia : % , _fechapago.max_fecha_ven : % , _iteracion %',_fechapago.valor_saldo,_fechapago.cuotas, _fechapago.periodo_gracia,_fechapago.max_fecha_ven,_iteracion ;

		--1. Validamos si el saldo es cero
		if(_fechapago.valor_saldo=0.00)then
			if _iteracion =1 then
			    _fecha_pago:=current_date;
			    _cumple_tiempo:='S';
			    exit ;
			end if;
		end if;

		--validad fecha de vencimientos.
		if(_fechapago.max_fecha_ven::date <now()::date and _iteracion =1 )then
			_fecha_pago:=_fechapago.max_fecha_ven;
			_cumple_tiempo:='S';
			exit ;
		end if;


		IF(_fechapago.valor_saldo>0 AND _fechapago.cuotas <=8 and _fechapago.periodo_gracia >= -30)then

			_fecha_pago:=_fechapago.max_fecha_ven;
			_cumple_tiempo:='S';

		ELSIF(_fechapago.valor_saldo>0 AND (_fechapago.cuotas between 9 and 14)  and _fechapago.periodo_gracia >= -60)then

			_fecha_pago:=_fechapago.max_fecha_ven;
			_cumple_tiempo:='S';

		ELSIF(_fechapago.valor_saldo>0 AND _fechapago.cuotas > 14 and _fechapago.periodo_gracia >= -90)then

			_fecha_pago:=_fechapago.max_fecha_ven;
			_cumple_tiempo:='S';

		ELSIF(_fechapago.valor_saldo>0 )THEN

			_fecha_pago:=_fechapago.max_fecha_ven;
			_cumple_tiempo:='N';

		END IF;


		_iteracion:=_iteracion+1;

	end loop;
	raise notice '_fecha_pago: % _cumple_tiempo: %',_fecha_pago,_cumple_tiempo;

	select into recordRet _fecha_pago::varchar as fecha_pago , _cumple_tiempo::varchar as tiempo ;

	return next recordRet;


	--return 'xxx';


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION tem.buscar_fechas_demo(character varying)
  OWNER TO postgres;
