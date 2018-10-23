-- Function: get_acciones_cxp(text)

-- DROP FUNCTION get_acciones_cxp(text);

CREATE OR REPLACE FUNCTION get_acciones_cxp(text)
  RETURNS text AS
$BODY$Declare
  factura_cxp ALIAS FOR $1;
  accion TEXT;
begin
 -- Busca las id acciones de un numero de factura eca
  select into accion
    array_to_string(array_accum(a.id_accion ), ',') as acciones
  from
   (select
      factura_contratista,
      a.id_accion
    from
      app_accord a
    where
      a.factura_contratista = factura_cxp) a ;


  RETURN accion;


end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_acciones_cxp(text)
  OWNER TO postgres;
