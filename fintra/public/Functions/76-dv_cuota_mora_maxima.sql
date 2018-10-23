-- Function: dv_cuota_mora_maxima(character varying)

-- DROP FUNCTION dv_cuota_mora_maxima(character varying);

CREATE OR REPLACE FUNCTION dv_cuota_mora_maxima(negocio character varying)
  RETURNS text AS
$BODY$

DECLARE

  cuotaMaxima varchar:='';
  -- cuotaMaxima record;



BEGIN

	select into cuotaMaxima a.num_doc_fen from (SELECT max(sp_fecha_corte_foto(substring(periodo_lote,1,4),substring(periodo_lote,5)::integer)::date-(fecha_vencimiento)) as maxdia, num_doc_fen
				FROM con.foto_cartera fra
				WHERE fra.dstrct = 'FINV'   and fra.reg_status=''
				and fra.valor_saldo > 5000
				AND fra.negasoc != ''
				AND fra.tipo_documento in ('FAC','NDC')
				AND substring(fra.documento,1,2) not in ('CP','FF','DF')
				AND fra.negasoc =negocio
				group by fra.num_doc_fen
				order by maxdia desc limit 1
				) as a;


	return cuotaMaxima;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION dv_cuota_mora_maxima(character varying)
  OWNER TO postgres;
