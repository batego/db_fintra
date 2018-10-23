-- Function: get_ultimo_pagare_vigente(character varying, character varying, character varying, character varying, character varying)

-- DROP FUNCTION get_ultimo_pagare_vigente(character varying, character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION get_ultimo_pagare_vigente(codigo_negocio character varying, solicitante character varying, codeudor character varying, estudiante character varying, afiliado character varying)
  RETURNS text AS
$BODY$
declare

    pagare text:='';
    idConvenio integer;
    id_unidad_negocio integer;
/*
Retorna el ultimo pagaré asignado a un cliente para una linea de credito, un codeudor y/o un estudiante dado
*/
begin
        --OBTENEMOS CONVENIO ASOCIADO AL NEGOCIO
        SELECT INTO idConvenio id_convenio FROM negocios where cod_neg = codigo_negocio;

        --OBTENEMOS LA UNIDAD DE NEGOCIO CORRESPONDIENTE AL CONVENIO
        SELECT INTO id_unidad_negocio id_unid_negocio FROM rel_unidadnegocio_convenios run
						    INNER JOIN unidad_negocio un on (run.id_unid_negocio=un.id)
						    WHERE ref_4 != '' AND id_convenio=idConvenio;

        --OBTENEMOS ULTIMO PAGARE GENERADO PARA LAS CONDICIONES DADAS
	SELECT INTO pagare num_pagare FROM historico_pagares_fintracredit
	WHERE unidad_negocio = id_unidad_negocio AND nit_solicitante = solicitante AND nit_codeudor = codeudor
	AND nit_estudiante = estudiante AND nit_afiliado = afiliado AND tipo_negocio = eg_tipo_negocio(codigo_negocio)
	AND ultimo_credito_vigente = 'S' AND reg_status = '';


    return pagare::text;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_ultimo_pagare_vigente(character varying, character varying, character varying, character varying, character varying)
  OWNER TO postgres;
