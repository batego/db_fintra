-- Function: con.datos_basicos_cliente(character varying, character varying, character varying)

-- DROP FUNCTION con.datos_basicos_cliente(character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION con.datos_basicos_cliente(_tipo_validacion character varying, _valor character varying, _agente_retenedor character varying)
  RETURNS text AS
$BODY$
DECLARE
 _resultado TEXT:='';
BEGIN

  /*********************************************************************************
  * Funcion para retornar la homologacion sociodemografica del tercero en apoteosys
  * @egonzalez
  * @2017-06-09
  ********/
        --Tipo documento de identidad
	IF(_tipo_validacion='tipo_identificacion')THEN
		_resultado:=(CASE
				 WHEN _valor='CED' THEN 'CC'
				 WHEN _valor='RIF' THEN 'CE'
				 WHEN _valor='' THEN 'CC'
				 ELSE _valor END);
	END IF;
	 --Tipo documento de identidad
	IF(_tipo_validacion='tipo_agente')THEN
		_resultado:=(CASE
				 WHEN _valor='N' AND _agente_retenedor='N' THEN 'RCOM'
				 WHEN _valor='N' AND _agente_retenedor='S' THEN 'RCAU'
				 WHEN _valor='S' AND _agente_retenedor='N' THEN 'GCON'
				 WHEN _valor='S' AND _agente_retenedor='S' THEN 'GCAU'
				 ELSE 'PNAL' END);


	END IF;
	--Tipo documento de identidad
	IF(_tipo_validacion='ciudad')THEN
		_resultado:=(CASE
				 WHEN _valor !='' THEN _valor
				 ELSE '08001' END);
	END IF;

	RETURN _resultado;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.datos_basicos_cliente(character varying, character varying, character varying)
  OWNER TO postgres;
