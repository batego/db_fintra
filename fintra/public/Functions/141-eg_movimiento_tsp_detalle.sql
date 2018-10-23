-- Function: eg_movimiento_tsp_detalle(integer, character varying, character varying, character varying, character varying)

-- DROP FUNCTION eg_movimiento_tsp_detalle(integer, character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION eg_movimiento_tsp_detalle(_filtro integer, _periodoi character varying, _periodof character varying, _tipoanticipo character varying, _paso character varying)
  RETURNS character varying AS
$BODY$
DECLARE

recordResultado RECORD;
resultado VARCHAR:='OK';

BEGIN


	IF(_paso='paso1')THEN

	ELSIF(_paso='paso2')THEN

	ELSIF(_paso='paso3')THEN

	ELSIF(_paso='paso4')THEN

	ELSIF(_paso='paso5')THEN

		DROP TABLE IF EXISTS tem.detalle_movimiento_tsp_paso_cinco;
		create table tem.detalle_movimiento_tsp_paso_cinco  as (
		SELECT
			documento_rel,
			fechadoc,
			periodo,
			sum(valor_debito) as valor_debito,
			sum(valor_credito) as  valor_credito
			FROM eg_movimiento_tsp_paso5(_filtro,_periodoI,_periodoF,_tipoanticipo)as coco(dstrct varchar,cuenta varchar,auxiliar varchar,periodo varchar,fechadoc varchar,
														    tipodoc varchar,tipodoc_desc text,numdoc varchar,detalle varchar,detalle_comprobante varchar,
														    abc varchar, valor_debito numeric,valor_credito numeric,tercero varchar,nombre_tercero text,
														    tipodoc_rel varchar,documento_rel varchar, vlr_for numeric,modena_foranea varchar, tipo_referencia_1 varchar,
														    referencia_1 varchar,tipo_referencia_2 varchar, referencia_2 varchar,tipo_referencia_3 varchar, referencia_3 varchar,
														    documento_rel2 varchar,referencia_4 varchar )

			group by documento_rel,periodo,fechadoc);

			/*FOR recordResultado IN (
				SELECT documento_rel::VARCHAR,
				      periodo::VARCHAR,
				      fechadoc::VARCHAR,
				      sum(valor_debito)::NUMERIC as valor_debito,
				      sum(valor_credito)::NUMERIC as  valor_credito,
				      sum(valor_debito) -sum(valor_credito)::NUMERIC as dif
				FROM temtable
				where documento_rel in (SELECT documento_rel FROM temtable group by documento_rel having sum(valor_debito) -sum(valor_credito) > 0 ) --and documento_rel='PP01761347'
				group by documento_rel,periodo,fechadoc
				order by documento_rel,periodo,fechadoc
				)
			LOOP
				 RETURN NEXT recordResultado;
			END LOOP;
			*/



	END IF;


	RETURN resultado;



END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_movimiento_tsp_detalle(integer, character varying, character varying, character varying, character varying)
  OWNER TO postgres;
