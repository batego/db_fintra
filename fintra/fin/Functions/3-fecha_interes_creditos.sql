-- Function: fin.fecha_interes_creditos(date, character varying, character varying)

-- DROP FUNCTION fin.fecha_interes_creditos(date, character varying, character varying);

CREATE OR REPLACE FUNCTION fin.fecha_interes_creditos(fecha_in date, _documento character varying, _nit_banco character varying)
  RETURNS date AS
$BODY$
DECLARE

  respuesta date ;

BEGIN

  SELECT into respuesta fecha_inicial from fin.plan_pago_creditos_bancarios
  where documento=_documento and fecha_vencimiento::date !=fecha_in and nit_banco=_nit_banco
  and fecha_in between fecha_inicial and fecha_vencimiento;

  raise notice 'respuesta : %',respuesta;
  if respuesta is null then
	respuesta:=fecha_in;
  end if;

RETURN respuesta;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION fin.fecha_interes_creditos(date, character varying, character varying)
  OWNER TO postgres;
