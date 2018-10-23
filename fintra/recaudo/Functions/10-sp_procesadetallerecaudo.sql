-- Function: recaudo.sp_procesadetallerecaudo(integer, character varying)

-- DROP FUNCTION recaudo.sp_procesadetallerecaudo(integer, character varying);

CREATE OR REPLACE FUNCTION recaudo.sp_procesadetallerecaudo(id_recaudo integer, usuario character varying)
  RETURNS text AS
$BODY$

DECLARE
        identificacionResult character varying;
        idRop integer;
        fechaRecaudo date;
        codEntidad integer;
        causalDevolucion character varying;
      	detalleRecaudoRecord record;
	retorno text:='OK';
        good text:='';

BEGIN
        /*Obtenemos valores correspondientes a la fecha recaudo y entidad debitada para el lote dado*/
        Select into fechaRecaudo, codEntidad  fecha_recaudo::date,recaudadora_cod from recaudo.recaudos where id = id_recaudo;

        FOR detalleRecaudoRecord IN

		select  * from recaudo.recaudo_detalles where id_rec=id_recaudo

		LOOP

		    identificacionResult =  recaudo.sp_buscadetallerecaudoenrecibopago(detalleRecaudoRecord.referencia_factura,detalleRecaudoRecord.valor_recaudado);
		    if(identificacionResult = 'NO ENCONTRADO') then
			  update recaudo.recaudo_detalles set encontrado=false where id=detalleRecaudoRecord.id;
                    ELSE
                          select into idRop, causalDevolucion  split_part(identificacionResult,' ',2),split_part(identificacionResult,' ',3);
                          select into causalDevolucion case when recibo_aplicado='S' then 'C02' else '' END AS resp from recibo_oficial_pago where id=idRop;

			  update recaudo.recaudo_detalles
				set encontrado=true,
				   causal_dev_procesamiento=causalDevolucion
		          where id=detalleRecaudoRecord.id;

			  if (causalDevolucion = '') THEN
			    select into good recaudo.sp_aplicacionpago(id_recaudo,detalleRecaudoRecord.id,idRop,usuario,fechaRecaudo,codEntidad);
			  end if;

		    end if;

		END LOOP;


	RETURN retorno;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION recaudo.sp_procesadetallerecaudo(integer, character varying)
  OWNER TO postgres;
