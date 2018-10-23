-- Function: tem.actualizar_cuotas_negocios()

-- DROP FUNCTION tem.actualizar_cuotas_negocios();

CREATE OR REPLACE FUNCTION tem.actualizar_cuotas_negocios()
  RETURNS text AS
$BODY$
DECLARE

recordNegocios record;
recordLiq record;
j record;
i integer;
BEGIN

	FOR recordNegocios IN (select cod_neg, count(0)::integer as inde  from documentos_neg_aceptado  where length(item)>2 and creation_date::date >'2016-11-30' group by cod_neg)
	LOOP
		i:=0;
		FOR j IN  select * from documentos_neg_aceptado  WHERE cod_neg =recordNegocios.cod_neg AND reg_status='' order by fecha LOOP

			i:=i+1;
			raise notice 'recordNegocios.cod_neg : % cuotas: %',recordNegocios.cod_neg ,j;
			UPDATE documentos_neg_aceptado SET item =i where cod_neg=recordNegocios.cod_neg and item=j.item;

		END LOOP;

	END LOOP;

	RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION tem.actualizar_cuotas_negocios()
  OWNER TO postgres;
