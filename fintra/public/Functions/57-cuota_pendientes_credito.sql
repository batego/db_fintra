-- Function: cuota_pendientes_credito(character varying, character varying)

-- DROP FUNCTION cuota_pendientes_credito(character varying, character varying);

CREATE OR REPLACE FUNCTION cuota_pendientes_credito(_negocio character varying, _periodolote character varying)
  RETURNS integer AS
$BODY$DECLARE

 cuaotas integer:=0;

BEGIN
	SELECT into cuaotas COUNT(*) AS cuotas_vencidas
            FROM con.foto_cartera WHERE reg_status != 'A'
                    AND dstrct = 'FINV'
                    AND tipo_documento IN ('FAC','NDC')
                    AND substring(documento,1,2) NOT IN ('CP','FF','DF','MI','CA')
                    AND valor_saldo > 0
                    AND fecha_vencimiento <= now()::date
		    and periodo_lote=_periodolote
		    and negasoc=_negocio;
RETURN cuaotas;

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION cuota_pendientes_credito(character varying, character varying)
  OWNER TO postgres;
