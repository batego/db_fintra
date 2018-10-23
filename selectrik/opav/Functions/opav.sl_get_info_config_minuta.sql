-- Function: opav.sl_get_info_config_minuta(character varying, character varying)

-- DROP FUNCTION opav.sl_get_info_config_minuta(character varying, character varying);

CREATE OR REPLACE FUNCTION opav.sl_get_info_config_minuta(tipo_doc character varying, num_solicitud character varying)
  RETURNS text AS
$BODY$

DECLARE
        _tipo_doc integer;
        dataToFillSolicitudRecord record;
        dataToFillEmpresaRecord record;
        dataToFillRepLegalRecord record;
        _info_document text:='';
        retorno text:='';

BEGIN

	_tipo_doc = tipo_doc::integer;

        --Obtenemos informacion de la solicitud
	select into dataToFillSolicitudRecord ofe.id_solicitud AS id_solicitud, nomcli AS razon_social_empresa, nit AS nit_empresa, direccion AS direccion_empresa, nombre_representante
            FROM opav.ofertas ofe
            INNER JOIN (
            select codcli,nomcli,nit,tipo,ciudad,direccion,nomcontacto,telcontacto,cargo_contacto,
            nombre_representante,tel_representante,celular_representante,email_contacto,cel_contacto,
            email_representante,clasificacion,digito_verificacion  from cliente
            union all
            select cod_agencia,nom_agencia,nit,'', ciudad,direccion,nomcontacto,telcontacto,cargo_contacto,
            nombre_representante,tel_representante,celular_representante,email_contacto,cel_contacto,
            email_representante,id_cliente_padre,digito_verificacion  from opav.agencias) t ON ofe.id_cliente = t.codcli
            WHERE ofe.id_solicitud=num_solicitud and ofe.reg_status='';

        --Obtenemos informacion empresa demandante
        select into dataToFillEmpresaRecord tgen.referencia as tipo_identificacion, replace(to_char(documento::BIGINT,'FM999,999,999,999,999'),',','.') as identificacion,nombre,dep.department_name as departamento,
			ciu.nomciu as ciudad, direccion, telefono, tel_extension as ext, celular, email, tarjeta_profesional,
			doc_lugar_exped as lugar_exped from  opav.sl_actores_minutas act
			INNER JOIN tablagen tgen ON tgen.table_code = act.tipo_documento AND table_type in ('TIPID')
			INNER JOIN ciudad ciu ON ciu.codciu = act.codciu
			INNER JOIN estado dep ON dep.department_code = act.coddpto WHERE tipo_actor = 1;

        --Obtenemos informacion del representante legal Empresa demandante
        select into dataToFillRepLegalRecord tgen.referencia as tipo_identificacion, replace(to_char(documento::BIGINT,'FM999,999,999,999,999'),',','.') AS identificacion,nombre,dep.department_name as departamento,
			ciu.nomciu as ciudad,direccion, telefono, tel_extension as ext, celular, email, tarjeta_profesional,
			doc_lugar_exped as lugar_exped from opav.sl_actores_minutas act
			INNER JOIN tablagen tgen ON tgen.table_code = act.tipo_documento AND table_type in ('TIPID')
			INNER JOIN ciudad ciu ON ciu.codciu = act.codciu
			INNER JOIN estado dep ON dep.department_code = act.coddpto WHERE tipo_actor = 2;

	--Obtenemos cuerpo del documento obtenido de la configuracion de minutas
	select into _info_document document_info from opav.sl_config_docs_minutas where id_tipo_doc = _tipo_doc AND reg_status = '';

        --Reemplazamos parametros por sus respectivos valores
        select into _info_document regexp_replace(_info_document, 'P1', dataToFillSolicitudRecord.nit_empresa, 'g');
        select into _info_document regexp_replace(_info_document, 'P2', dataToFillSolicitudRecord.razon_social_empresa, 'g');
        select into _info_document regexp_replace(_info_document, 'P3', dataToFillSolicitudRecord.nombre_representante, 'g');

        select into _info_document regexp_replace(_info_document, 'P5', dataToFillEmpresaRecord.identificacion, 'g');
        select into _info_document regexp_replace(_info_document, 'P6', dataToFillEmpresaRecord.nombre, 'g');
        select into _info_document regexp_replace(_info_document, 'P7', dataToFillRepLegalRecord.nombre, 'g');
        select into _info_document regexp_replace(_info_document, 'P8', dataToFillRepLegalRecord.identificacion, 'g');
        select into _info_document regexp_replace(_info_document, 'P9', dataToFillRepLegalRecord.lugar_exped, 'g');


        retorno:=_info_document;


	RETURN retorno;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sl_get_info_config_minuta(character varying, character varying)
  OWNER TO postgres;
