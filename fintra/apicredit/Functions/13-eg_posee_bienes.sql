-- Function: apicredit.eg_posee_bienes(integer)

-- DROP FUNCTION apicredit.eg_posee_bienes(integer);

CREATE OR REPLACE FUNCTION apicredit.eg_posee_bienes(_numerosolicitud integer)
  RETURNS text AS
$BODY$
DECLARE
    result text := '';
BEGIN

   RETURN coalesce((SELECT posee_bienes FROM apicredit.tab_informacion_solicitante WHERE numero_solicitud=_numeroSolicitud and tipo='S' limit  1),'');

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION apicredit.eg_posee_bienes(integer)
  OWNER TO postgres;
