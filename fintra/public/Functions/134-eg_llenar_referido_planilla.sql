-- Function: eg_llenar_referido_planilla(character varying)

-- DROP FUNCTION eg_llenar_referido_planilla(character varying);

CREATE OR REPLACE FUNCTION eg_llenar_referido_planilla(nit character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE
recordReferido record;
_asesor_comercial varchar:='';
_referenciado varchar:='';
_status varchar:='';
_observacion varchar:='';
_contador numeric:=1;

BEGIN
	FOR recordReferido IN	SELECT
					LEYENDA::varchar,
					substring(  dato,  posIni::int + 1 , longitud::int )::varchar as CONTENIDO,
					''::varchar as ASESOR_COMERCIAL,
					''::varchar as REFERENCIADO,
					''::varchar as STATUS,
					''::varchar as OBSERVACION
					     FROM
					      (
						   SELECT
							  a.leyenda,
							  a.secuencia,
							  a.longitud,
							  b.dato,
							  sum( ( case when a.secuencia::int = 1 then  0 else  c.longitud end  ) ) as posIni
						   FROM
							  tablas_generales_dato  a
							  LEFT JOIN tablas_generales_dato c
							       ON   ( c.table_type = a.table_type and c.secuencia < a.secuencia ),
							  tablas_generales       b
						   WHERE
							  UPPER( a.table_type)   = UPPER('CLIFINTRA')
						      AND a.reg_status          != 'A'
						      AND b.table_type           = a.table_type
						      AND b.referencia           = nit

						   GROUP BY 1,2,3,4
						   ORDER BY a.secuencia::int
					) a
	LOOP
                _contador:=_contador+1;

                IF recordReferido.LEYENDA='ASESOR COMERCIAL' THEN
		   _asesor_comercial:=recordReferido.CONTENIDO;
                END IF;

		IF recordReferido.LEYENDA='REFERENCIADO' THEN
		   _referenciado:=recordReferido.CONTENIDO;
                END IF;

		IF recordReferido.LEYENDA='STATUS' THEN
		  _status:=recordReferido.CONTENIDO ;
                END IF;

		IF recordReferido.LEYENDA='OBSERVACION' THEN
		   _observacion:=recordReferido.CONTENIDO ;
                END IF;

		recordReferido.ASESOR_COMERCIAL:=_asesor_comercial;
		recordReferido.REFERENCIADO:=_referenciado;
		recordReferido.STATUS:=_status;
		recordReferido.OBSERVACION:=_observacion;

                IF(_contador = 4)THEN
	         return next recordReferido;
		END IF;

	END LOOP;


END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_llenar_referido_planilla(character varying)
  OWNER TO postgres;
