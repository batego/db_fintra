-- Function: get_valor_fianza(integer, integer, integer, numeric)

-- DROP FUNCTION get_valor_fianza(integer, integer, integer, numeric);

CREATE OR REPLACE FUNCTION get_valor_fianza(_idsolicitud integer, _idconvenio integer, _plazo integer, _valornegocio numeric)
  RETURNS numeric AS
$BODY$

DECLARE

  _valorFianza numeric:=0;
  
BEGIN
	PERFORM  * FROM solicitud_aval WHERE numero_solicitud = _idSolicitud AND fianza = 'S';
	IF FOUND then 
	
	   _valorFianza:=(SELECT CASE WHEN porcentaje_comision > 0 THEN round((_valorNegocio*porcentaje_comision/100)*(1+porcentaje_iva/100)) 
			    ELSE round((_Plazo*_valorNegocio*valor_comision/1000000)*(1+porcentaje_iva/100)) END AS valor
			    FROM configuracion_factor_por_millon cf
			    INNER JOIN unidad_negocio un ON cf.id_unidad_negocio = un.id
			    INNER JOIN rel_unidadnegocio_convenios run on (run.id_unid_negocio=un.id)  
			    WHERE id_unid_negocio in((select id_unid_negocio from rel_unidadnegocio_procinterno
			    WHERE id_proceso_interno = (select id from proceso_interno where descripcion = 'COBRANZA ESTRATEGICA'))) AND id_convenio=_idConvenio
			    AND _Plazo BETWEEN plazo_inicial AND plazo_final);	

	END IF;
	
	return _valorFianza;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_valor_fianza(integer, integer, integer, numeric)
  OWNER TO postgres;

