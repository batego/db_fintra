-- Function: opav.sl_crea_contrato_doc(character varying, character varying, character varying, character varying, character varying)

-- DROP FUNCTION opav.sl_crea_contrato_doc(character varying, character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION opav.sl_crea_contrato_doc(empresa character varying, num_solicitud character varying, contrato character varying, tipo_contrato character varying, usuariocrea character varying)
  RETURNS text AS
$BODY$

DECLARE
        _tipo_doc integer;
        _info_document text:='';
       retorno text:='OK';

BEGIN
   _tipo_doc = tipo_contrato::integer;

  IF (NOT EXISTS(select * from  opav.sl_minutas_docs where id_tipo_doc = _tipo_doc AND id_contrato = contrato AND reg_status = '')) then

         INSERT INTO opav.sl_minutas_docs (reg_status, dstrct, id_tipo_doc, id_contrato, document_info, creation_user, creation_date)
         SELECT '',empresa,_tipo_doc,contrato,opav.sl_get_info_config_minuta(tipo_contrato,num_solicitud),usuariocrea,now();

  END IF;

	RETURN retorno;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sl_crea_contrato_doc(character varying, character varying, character varying, character varying, character varying)
  OWNER TO postgres;
