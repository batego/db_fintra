-- Function: get_acciones(text)

-- DROP FUNCTION get_acciones(text);

CREATE OR REPLACE FUNCTION get_acciones(text)
  RETURNS text AS
$BODY$Declare
  factura_cxc ALIAS FOR $1;
  accion TEXT;
begin
 -- Busca las id acciones de un numero de factura eca
  select into accion
    array_to_string(array_accum(a.id_accion ), ',') as acciones
  from
   (select
      factura_eca,
      id_accion
    from
      tem.factura_eca
    where
      factura_eca = factura_cxc and
      factura_contratista <> '' ) a ;


  RETURN accion;


end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_acciones(text)
  OWNER TO postgres;
