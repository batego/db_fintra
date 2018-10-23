-- Function: get_costo_accion(character varying)

-- DROP FUNCTION get_costo_accion(character varying);

CREATE OR REPLACE FUNCTION get_costo_accion(idaccion character varying)
  RETURNS numeric AS
$BODY$
declare
    costo_accion numeric;
begin
    -- retorna el costo de la accion
    select into costo_accion ( administracion+imprevisto+utilidad+material+mano_obra+transporte )
    from opav.acciones
    where id_accion=idAccion;

    return costo_accion;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_costo_accion(character varying)
  OWNER TO postgres;
