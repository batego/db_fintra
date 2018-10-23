-- Function: opav.metodocalculo(integer, character varying)

-- DROP FUNCTION opav.metodocalculo(integer, character varying);

CREATE OR REPLACE FUNCTION opav.metodocalculo(tipo integer, codigo character varying)
  RETURNS text AS
$BODY$
declare
    valor numeric;
    reg record;
    num integer;
    porc numeric;
/*
Tipo: 1 Percentil, 2 Ultimo Precio, 3 Promedio Ultimos 3 Meses, 4 Promedio Ultimos 6 Meses
Codigo: Codigo del insumo
*/

begin
valor:=0.00;
IF (tipo=1) THEN

	select
		count(nuevo_codigo),
		(select referencia::numeric from tablagen where table_type='METCALC' and table_code='PERCENTIL')
		into num, porc
	from
		tem.mapeo_insumos
	where
		nuevo_codigo=codigo;

	raise notice 'num %',num;
	raise notice 'porc %',porc;

	select
		coalesce(valor_unitario::numeric,0) into valor
	from
		tem.mapeo_insumos
	where
		nuevo_codigo=codigo
	order by
		valor_unitario
	LIMIT
		1
	OFFSET
		ceiling((num::numeric*porc::numeric)/100::numeric)-1;

	if(valor is null) then
		valor:=0.00;
	end if;

	raise notice 'codigo %',codigo;
	raise notice 'valor %',valor;

	ELSE

		IF (tipo=2) THEN
			select
				coalesce(valor_unitario::numeric,0) into valor
			from
				tem.mapeo_insumos
			where
				nuevo_codigo=codigo
			order by
				fecha desc
			LIMIT
				1;

			if(valor is null) then
				valor:=0.00;
			end if;

raise notice 'entro %',2;

		ELSE

			IF (tipo=3) THEN

				select
					coalesce(round(sum(valor_unitario::numeric)/count(nuevo_codigo),2),0) into valor
				from
					tem.mapeo_insumos
				where
					nuevo_codigo=codigo and fecha::date between (current_date - interval '3 month')::date and current_date ;
raise notice 'entro %',3;

			ELSE
				IF (tipo=4) THEN

					select
						coalesce(round(sum(valor_unitario::numeric)/count(nuevo_codigo),2),0) into valor
					from
						tem.mapeo_insumos
					where
						nuevo_codigo=codigo and fecha::date between (current_date - interval '6 month')::date and current_date ;
raise notice 'entro %',4;

				END IF;
			END IF;

		END IF;

END IF;

 return valor;


end;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.metodocalculo(integer, character varying)
  OWNER TO postgres;
