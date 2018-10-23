-- Function: get_costo_solicitud(character varying)

-- DROP FUNCTION get_costo_solicitud(character varying);

CREATE OR REPLACE FUNCTION get_costo_solicitud(idsolicitud character varying)
  RETURNS numeric AS
$BODY$
declare
    costo_solicitud numeric;
begin
    -- retorna el costo de la solicitud
    select into costo_solicitud sum( administracion+imprevisto+utilidad+material+mano_obra+transporte )
    from opav.acciones
    where id_solicitud=idSolicitud and reg_status != 'A';

    return costo_solicitud;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_costo_solicitud(character varying)
  OWNER TO postgres;
