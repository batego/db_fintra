-- Function: eg_calculo_sanciones_micro(character varying, numeric, numeric, character varying)

-- DROP FUNCTION eg_calculo_sanciones_micro(character varying, numeric, numeric, character varying);

CREATE OR REPLACE FUNCTION eg_calculo_sanciones_micro(_negocio character varying, _base numeric, _diasmora numeric, _tipocalculo character varying)
  RETURNS numeric AS
$BODY$
DECLARE

  _valor numeric:=0.00;
  _tasaIm numeric:=0.00;
  _tasaIg numeric:=0.00;


BEGIN


	IF(_tipoCalculo='IXM')THEN

		/*********************************************
		* Buscamos tasa del negocio. por el convenio *
		**********************************************/

		SELECT INTO _tasaIm c.tasa_usura FROM negocios as n
		INNER JOIN convenios as c on (c.id_convenio=n.id_convenio)
		WHERE n.cod_neg =_negocio;


		_valor = coalesce(round((((_base * _tasaIm)/100 ) / 30) * _diasMora ),0);

	ELSE

		/************************************
		* Gastos de Cobranza por factura    *
		************************************/

	SELECT INTO _tasaIg max(porcentaje) FROM sanciones_condonaciones
		WHERE id_unidad_negocio = 1
		AND id_conceptos_recaudo in (2,4,6)
		AND id_tipo_acto = 1
		AND categoria='GAC'
		AND periodo = replace(substring(now(),1,7),'-','')
		AND _diasMora between dias_rango_ini and dias_rango_fin
		GROUP BY id_conceptos_recaudo
		ORDER by id_conceptos_recaudo ;

		_valor=coalesce(round((_base * _tasaIg) ::numeric /100),0);

	END IF;

    RETURN _valor;

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_calculo_sanciones_micro(character varying, numeric, numeric, character varying)
  OWNER TO postgres;
