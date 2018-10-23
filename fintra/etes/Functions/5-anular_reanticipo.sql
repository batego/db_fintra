-- Function: etes.anular_reanticipo(text[], character varying, integer)

-- DROP FUNCTION etes.anular_reanticipo(text[], character varying, integer);

CREATE OR REPLACE FUNCTION etes.anular_reanticipo(reanticipo text[], usuario character varying, idproceso integer)
  RETURNS boolean AS
$BODY$
DECLARE

retorno boolean:=true;
planilla text:='';

BEGIN

	FOR i IN 1 .. (array_upper(reanticipo, 1))
	LOOP

		RAISE NOTICE 'indice i: % indice j: % codigo_transportadora : %',i,1, reanticipo[i][1];
		RAISE NOTICE 'indice i: % indice j: % codigo_agencia : %',i,2, reanticipo[i][2];
		RAISE NOTICE 'indice i: % indice j: % id : %',i,3, reanticipo[i][3];
		RAISE NOTICE 'indice i: % indice j: % planilla : %',i,4, reanticipo[i][4];
		RAISE NOTICE 'indice i: % indice j: % planilla_interna : %',i,5, reanticipo[i][5];
		RAISE NOTICE 'indice i: % indice j: % secuencia : %',i,6, reanticipo[i][6];
		RAISE NOTICE 'indice i: % indice j: % placa : %',i,7, reanticipo[i][7];
		RAISE NOTICE 'indice i: % indice j: % usuario_anulacion : %',i,8, reanticipo[i][8];
		RAISE NOTICE 'indice i: % indice j: % descripcion_anulacion : %',i,9, reanticipo[i][9];

                planilla:=planilla||','||reanticipo[i][5];
		/************ ANULAMOS LOS REANTICIPOS SELECIONADOS ************/
		UPDATE etes.manifiesto_reanticipos
		   SET reg_status='A',
		       last_update=now(),
		       user_update=reanticipo[i][8]
		WHERE id=reanticipo[i][3] and cxc_corrida = '';


        END LOOP;

	/************ MARCAMOS LA TRAMA COMO PROCESADA ************/
	UPDATE etes.trama_anticipos
	   SET procesado=true,
	       fecha_fin_proceso=now(),
	       observaciones ='REANTICIPOS ANULADOS:'||planilla
	 WHERE id=idproceso;

RETURN retorno;

EXCEPTION

	WHEN foreign_key_violation THEN
		RAISE EXCEPTION 'NO EXISTEN DEPENDENCIAS FORANEAS PARA ALGUNOS REGISTROS.';
	WHEN  null_value_not_allowed  THEN
		RAISE EXCEPTION 'VALOR NULO NO PERMITIDO';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.anular_reanticipo(text[], character varying, integer)
  OWNER TO postgres;
