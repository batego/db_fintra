CREATE OR REPLACE VIEW public.negocios_endosados
AS 

select negocio, case when mod(COUNT(*),2)=0 then 'DESENDOSADO'
				when mod(COUNT(*),2)!=0 then 'ENDOSADO' end as estado
from (		
	 select lote_endoso,negocio
     from administrativo.control_endosofiducia 
	 group by lote_endoso,negocio
	)t
group by negocio;



ALTER TABLE public.negocios_endosados OWNER TO postgres;
GRANT ALL ON TABLE public.negocios_endosados TO postgres;

