-- Function: actualiza_fecha_oferta(text, date)

-- DROP FUNCTION actualiza_fecha_oferta(text, date);

CREATE OR REPLACE FUNCTION actualiza_fecha_oferta(text, date)
  RETURNS text AS
$BODY$DECLARE

  doc TEXT;
  sw boolean ;

BEGIN
  doc = 'Actualizada';
  sw=(select (case when id_solicitud!='' then true else false end) as resp from opav.ofertas where  id_solicitud=$1 and tipo_solicitud='Alquiler');

  if(sw) then
 update opav.ofertas set fecha_oferta = $2 ,fecha_entrega_oferta = $2  where id_solicitud=$1 and tipo_solicitud='Alquiler';
  else
  doc = 'La Solicitud no existe o el tipo de trabajo no es Alquiler';
 end if;
  RETURN doc;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION actualiza_fecha_oferta(text, date)
  OWNER TO postgres;
