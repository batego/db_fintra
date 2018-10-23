-- Function: recaudo.sp_buscadetallerecaudoenrecibopago(character varying, numeric)

-- DROP FUNCTION recaudo.sp_buscadetallerecaudoenrecibopago(character varying, numeric);

CREATE OR REPLACE FUNCTION recaudo.sp_buscadetallerecaudoenrecibopago(referencia character varying, valor_recaudo numeric)
  RETURNS text AS
$BODY$

DECLARE
        cantRegistros integer;
        causalDevolucion character varying;
        codcli character varying;
	reciboOficialRecord record;
	retorno text:='NO ENCONTRADO';

BEGIN
        --Buscamos por el codigo del recibo
        if (NOT EXISTS(select id from recibo_oficial_pago where cod_rop ilike '%'||referencia||'%')) then

		--Buscamos por cedula
		if (NOT EXISTS(select id from recibo_oficial_pago where cedula = referencia)) then

                    --Buscamos por negocio
                   if (NOT EXISTS(select id from recibo_oficial_pago where negocio = referencia )) then

			if(NOT EXISTS(select documento from con.factura where documento=referencia and reg_status='')) then

                               cantRegistros=0;

                       else
				select into codcli nit from con.factura where documento=referencia and reg_status='';
				cantRegistros=0;
				FOR reciboOficialRecord IN

				select  coalesce(id,0) as idrop,coalesce(total,0)::numeric as total_rop from recibo_oficial_pago where cedula = codcli
					and periodo_rop=(select max(periodo_rop) from recibo_oficial_pago where cedula = codcli and periodo_rop <=
					replace(substring(now()::date,1,7),'-','')) and total=valor_recaudo

				LOOP

					cantRegistros=cantRegistros+1;

				END LOOP;

		        END IF;
                   else
                        cantRegistros=0;
			FOR reciboOficialRecord IN

			select  coalesce(id,0) as idrop,coalesce(total,0)::numeric as total_rop from recibo_oficial_pago where negocio = referencia
				and periodo_rop=(select max(periodo_rop) from recibo_oficial_pago where negocio = referencia and periodo_rop <=
				replace(substring(now()::date,1,7),'-',''))  and total=valor_recaudo

		        LOOP

				cantRegistros=cantRegistros+1;

			END LOOP;

                   end if;
		else
                        cantRegistros=0;
			FOR reciboOficialRecord IN

			select  coalesce(id,0) as idrop,coalesce(total,0)::numeric as total_rop from recibo_oficial_pago where cedula = referencia
				and periodo_rop=(select max(periodo_rop) from recibo_oficial_pago where cedula = referencia and periodo_rop <=
				replace(substring(now()::date,1,7),'-','')) and total=valor_recaudo

			LOOP

				cantRegistros=cantRegistros+1;

			END LOOP;

		end if;

		IF (cantRegistros=0) THEN
		    select into reciboOficialRecord 0 as idrop,0.0 as total_rop;
		elsif(cantRegistros>1) THEN
		    causalDevolucion='C01';
		END IF;

	else
	      select into reciboOficialRecord coalesce(id,0) as idrop,coalesce(total,0)::numeric as total_rop  from recibo_oficial_pago where cod_rop ilike '%'||referencia||'%';
        end if;

        if (reciboOficialRecord.idrop > 0 and reciboOficialRecord.total_rop = valor_recaudo) then
              retorno:='ENCONTRADO '||reciboOficialRecord.idrop;
              IF (causalDevolucion!='') THEN
                   retorno:='ENCONTRADO '||reciboOficialRecord.idrop||' '||causalDevolucion;
              END IF;
        end if;

	RETURN retorno;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION recaudo.sp_buscadetallerecaudoenrecibopago(character varying, numeric)
  OWNER TO postgres;
