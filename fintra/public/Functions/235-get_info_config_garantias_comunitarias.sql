-- Function: get_info_config_garantias_comunitarias(character varying, text[])

-- DROP FUNCTION get_info_config_garantias_comunitarias(character varying, text[]);

CREATE OR REPLACE FUNCTION get_info_config_garantias_comunitarias(tipo_doc character varying, params text[])
  RETURNS text AS
$BODY$

DECLARE
        _tipo_doc integer;
        dataToFillClienteRecord record;
        fecha_sistema text:='';
        _info_document text:='';
        retorno text:='';

BEGIN

	_tipo_doc = tipo_doc::integer;

        --Obtenemos fecha actual
	SELECT INTO fecha_sistema extract(DAY FROM now())||' de '||mes.descripcion||' de '||extract(YEAR FROM now())  AS Fecha_Actual
	FROM "meses_año" mes WHERE mes.id = extract(MONTH FROM now());

	--Obtenemos cuerpo del documento obtenido de la configuracion de documentos de garantias comunitarias
	select into _info_document document_info from config_docs_garantias_comunitarias where id_tipo_doc = _tipo_doc AND reg_status = '';


     IF(_tipo_doc=1)THEN

        --Reemplazamos parametros por sus respectivos valores
        select into _info_document regexp_replace(_info_document, 'P1', fecha_sistema, 'g');
        select into _info_document regexp_replace(_info_document, 'P2', params[1], 'g');

        retorno:=_info_document;
     ELSE

        --Obtenemos informacion del cliente
	select into dataToFillClienteRecord nomcli as nombre, c.direccion, coalesce(n.barrio,'') as barrio, ciu.nomciu as ciudad
	FROM cliente c
	INNER JOIN ciudad ciu ON ciu.codciu = c.ciudad
	LEFT JOIN nit n ON n.cedula = c.nit
        WHERE c.nit = params[1];

        select into _info_document regexp_replace(_info_document, 'P3', dataToFillClienteRecord.nombre, 'g');
        select into _info_document regexp_replace(_info_document, 'P4', dataToFillClienteRecord.direccion, 'g');
        select into _info_document regexp_replace(_info_document, 'P5', dataToFillClienteRecord.barrio, 'g');
        select into _info_document regexp_replace(_info_document, 'P6', dataToFillClienteRecord.ciudad, 'g');

        retorno:=_info_document;
     END IF;

	RETURN retorno;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_info_config_garantias_comunitarias(character varying, text[])
  OWNER TO postgres;
