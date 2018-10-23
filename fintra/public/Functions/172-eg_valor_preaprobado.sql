-- Function: eg_valor_preaprobado(numeric, integer, character varying)

-- DROP FUNCTION eg_valor_preaprobado(numeric, integer, character varying);

CREATE OR REPLACE FUNCTION eg_valor_preaprobado(_valoractual numeric, _unidadnegocio integer, _tipo character varying)
  RETURNS numeric AS
$BODY$

DECLARE

  _valorPreaprobado numeric:=0;
  _incremento numeric:=0;


BEGIN

	IF _tipo='PREAPROBADO' THEN

		PERFORM incremento from configuracion_preaprobados where id_unidad_negocio=_unidadNegocio and _valorActual between valor_inicial and valor_final ;
		IF FOUND then
		   _incremento:=(select incremento from configuracion_preaprobados where id_unidad_negocio=_unidadNegocio and _valorActual between valor_inicial and valor_final);

		  _valorPreaprobado:=ROUND( _valorActual*(1+(_incremento/100)),2);

		ELSE
		    _valorPreaprobado:=_valorActual;
		END IF;

	ELSIF _tipo LIKE 'TIPO%' THEN

		PERFORM incremento from configuracion_incremento_cliente_xtipo where id_unidad_negocio=_unidadNegocio and clasificacion=_tipo ;
		IF FOUND then

		   _incremento:=(SELECT incremento FROM configuracion_incremento_cliente_xtipo where id_unidad_negocio=_unidadNegocio and clasificacion=_tipo);

		  _valorPreaprobado:=ROUND( _valorActual*(1+(_incremento/100)),2);

		ELSE
		    _valorPreaprobado:=_valorActual;
		END IF;
	END IF;

	return _valorPreaprobado;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_valor_preaprobado(numeric, integer, character varying)
  OWNER TO postgres;
