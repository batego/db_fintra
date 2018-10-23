-- Function: eg_altura_mora_ultimo_neg(character varying)

-- DROP FUNCTION eg_altura_mora_ultimo_neg(character varying);

CREATE OR REPLACE FUNCTION eg_altura_mora_ultimo_neg(cedula character varying)
  RETURNS text AS
$BODY$

DECLARE

  moraMaxima varchar:='';



BEGIN

	moraMaxima:=(SELECT  max(sp_fecha_corte_foto(substring(periodo_lote,1,4),substring(periodo_lote,5)::integer)::date-(fecha_vencimiento)) as maxdia
				FROM con.foto_cartera fra
				WHERE fra.dstrct = 'FINV'   and fra.reg_status=''
				and fra.valor_saldo > 5000
				AND fra.negasoc != ''
				--AND fra.nit = '72341863'
				AND fra.tipo_documento in ('FAC','NDC')
				AND substring(fra.documento,1,2) not in ('CP','FF','DF')
				AND fra.negasoc = (SELECT cod_neg
							from negocios neg
							where creation_date::date = (select max(creation_date)::date from negocios where cod_cli = cedula)
							and neg.cod_cli = cedula));


	return moraMaxima;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_altura_mora_ultimo_neg(character varying)
  OWNER TO postgres;
