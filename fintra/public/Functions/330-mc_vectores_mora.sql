-- Function: mc_vectores_mora(character varying)

-- DROP FUNCTION mc_vectores_mora(character varying);

CREATE OR REPLACE FUNCTION mc_vectores_mora(negocio character varying)
  RETURNS character varying[] AS
$BODY$

DECLARE
datoNegocio record;
indice integer := 0;
vectorDatos varchar[]:= '{NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA}';

BEGIN
	
	
	for datoNegocio in (
		SELECT  
			case 
			when dias <=0 then 0
			when dias between 1 and 29 then 0
			when dias between 30 and 59 then 1
			when dias between 60 and 89 then 2
			when dias between 90 and 119 then 3
			when dias >= 120 then 4
			End as maxdia	
		FROM (
			SELECT 
			max(sp_fecha_corte_foto(substring(periodo_lote,1,4),substring(periodo_lote,5)::integer)::date-(fecha_vencimiento)) as dias
			FROM con.foto_cartera fra
			WHERE fra.dstrct = 'FINV'
			AND fra.reg_status=''
			AND fra.negasoc = negocio
			and fra.valor_saldo >0
			AND fra.tipo_documento in ('FAC','NDC')
			AND fra.negasoc in (SELECT cod_neg FROM negocios  where creation_date::date > '2014-01-31'::date AND cod_neg like 'MC%' AND estado_neg IN ('T') )
			AND substring(fra.documento,1,2) not in ('CP','FF','DF')
			and fra.reg_status=''
			group by 
			periodo_lote
			order by periodo_lote::integer	    
		)t)
	loop 
		vectorDatos[indice]:= datoNegocio.maxdia;
		indice := indice + 1;

                if(indice >24)then
		  EXIT;
		end if ;
		raise info 'vector%',vectorDatos;

	end loop;

	
return vectorDatos;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION mc_vectores_mora(character varying)
  OWNER TO postgres;

