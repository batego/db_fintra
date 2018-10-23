-- Function: tem.test_script()

-- DROP FUNCTION tem.test_script();

CREATE OR REPLACE FUNCTION tem.test_script()
  RETURNS text AS
$BODY$
DECLARE
 RECORD_FUNTION RECORD;
 _PARAMETROS VARCHAR;
 _function varchar;
BEGIN

   FOR RECORD_FUNTION IN  (SELECT   PRONAME AS FUNCION
				   ,PROARGNAMES AS PARAMETROS
				   ,STRING_TO_ARRAY(PG_CATALOG.OIDVECTORTYPES(PROARGTYPES),',') AS TIPO_DATOS
				   ,PROSRC AS CUERPO,
				   t.typname  as retorno,
				   l.lanname as lenguaje,
				   N.NSPNAME as esquema
				 FROM PG_PROC P
				JOIN PG_CATALOG.PG_NAMESPACE N ON N.OID = P.PRONAMESPACE
				JOIN pg_type t on p.prorettype = t.oid
				join pg_language l on  p.prolang = l.oid
				WHERE N.NSPNAME = 'apicredit') LOOP

			--raise notice 'RECORD_FUNTION %',RECORD_FUNTION.FUNCION;
			_parametros:='';
			if RECORD_FUNTION.PARAMETROS is not null then
				FOR i IN 1 .. (array_upper(RECORD_FUNTION.PARAMETROS, 1))
				LOOP
					if (i=(array_upper(RECORD_FUNTION.PARAMETROS, 1)))then
					_parametros:=_parametros||RECORD_FUNTION.PARAMETROS[i]||' '||RECORD_FUNTION.TIPO_DATOS[i];
					else
					_parametros:=_parametros||RECORD_FUNTION.PARAMETROS[i]||' '||RECORD_FUNTION.TIPO_DATOS[i]||', ';
					end if;

				END LOOP;
		       end if;

		       _function:='-- Function: eg_guardar_caracterizacion_clientes(character varying)'||E'\n'||E'\n'||
				  '-- DROP FUNCTION eg_guardar_caracterizacion_clientes(character varying);'||E'\n'||E'\n'||
				  'CREATE OR REPLACE FUNCTION '||RECORD_FUNTION.FUNCION||' ('||_parametros||')'||E'\n'||
				   'RETURNS '||RECORD_FUNTION.retorno||' AS '||E'\n'||
				   '$LAMONDA$'||E'\n'||
				    RECORD_FUNTION.CUERPO||E'\n'||
				   '$LAMONDA$'||E'\n'||
				   'LANGUAGE '||RECORD_FUNTION.lenguaje||' VOLATILE;'||E'\n'||
				   'ALTER FUNCTION '||RECORD_FUNTION.FUNCION||' ('||_parametros||')'||E'\n'||
				   'OWNER TO postgres;';

			RAISE NOTICE '_function: %',_function;

			insert into tem.funciones_bd (esquema,nombre,retorno,lenguaje,fuente)
			values(RECORD_FUNTION.ESQUEMA,RECORD_FUNTION.FUNCION,RECORD_FUNTION.retorno,RECORD_FUNTION.lenguaje,replace(_function,'LAMONDA','BODY'));
   END LOOP ;

   RETURN 'OK';


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION tem.test_script()
  OWNER TO postgres;
