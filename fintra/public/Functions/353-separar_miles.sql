-- Function: separar_miles(numeric)

-- DROP FUNCTION separar_miles(numeric);

CREATE OR REPLACE FUNCTION separar_miles(_numero1 numeric)
  RETURNS text AS
$BODY$
-- numero: -123456.00 es decir numero::numeric(15,2)
declare
  _signo text;
  _decimal text;
  _entero text;
  _auxiliar text;
  _numero numeric;
begin
  _signo := '';
  _numero:=_numero1;--ROUND(_numero1);
  if _numero::numeric(15,2) < 0 then
    _signo := '-';
  end if;
  _entero := abs(_numero)::integer::text;
  _decimal := substring((abs(_numero)-abs(_numero)::integer)::numeric(15,2)::text,2);
  _auxiliar := '';
  raise notice '% % %', _signo, _entero, _decimal;
  if (length(_entero) > 3) then
    _auxiliar := _auxiliar || substring(_entero, 1, length(_entero) % 3);
    _entero := substring(_entero, (length(_entero) % 3 ) + 1 );
    if (length(_auxiliar) > 0) then
      _auxiliar := _auxiliar || '.';
    end if;
    raise notice '% % %', _signo, _entero, _decimal;
    while (length(_entero) > 3) loop
      _auxiliar := _auxiliar || substring(_entero,1,3) || '.';
      _entero := substring(_entero,4);
      raise notice '% % %', _signo, _entero, _decimal;
    end loop;
    _auxiliar := _auxiliar || _entero;
  else
    _auxiliar := _entero;
  end if;
  _signo := _signo || _auxiliar ;--|| _decimal;

  return _signo;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION separar_miles(numeric)
  OWNER TO postgres;
