-- Function: opav.serie_insumo(text)

-- DROP FUNCTION opav.serie_insumo(text);

CREATE OR REPLACE FUNCTION opav.serie_insumo(idsub text)
  RETURNS text AS
$BODY$

DECLARE

  secuencia TEXT;
  retcod record;
  tipo_insumo INTEGER;

BEGIN

	select
		id_tipo_insumo INTO tipo_insumo
	from
		opav.sl_categoria a
	inner join
		opav.sl_rel_cat_sub b on(b.id_categoria=a.id)
	where
		b.id_subcategoria=idsub;

	if tipo_insumo = 1 then

		Select into retcod *
		from series
		where document_type = '004' and id=2691
		and reg_status='';

		secuencia := retcod.prefix||lpad(retcod.last_number, 5, '0');

		UPDATE series set last_number = last_number+1 where document_type = '004' and id=2691 and reg_status = '';

	elsif tipo_insumo = 2 then

		Select into retcod *
		from series
		where document_type = '004' and id=2689
		and reg_status='';

		secuencia := retcod.prefix||lpad(retcod.last_number, 5, '0');

		UPDATE series set last_number = last_number+1 where document_type = '004' and id=2689 and reg_status = '';

	elsif tipo_insumo = 3 then

		Select into retcod *
		from series
		where document_type = '004' and id=2688
		and reg_status='';

		secuencia := retcod.prefix||lpad(retcod.last_number, 5, '0');

		UPDATE series set last_number = last_number+1 where document_type = '004' and id=2688 and reg_status = '';

	elsif tipo_insumo = 4 then

		Select into retcod *
		from series
		where document_type = '004' and id=2690
		and reg_status='';

		secuencia := retcod.prefix||lpad(retcod.last_number, 5, '0');

		UPDATE series set last_number = last_number+1 where document_type = '004' and id=2690 and reg_status = '';

	else

		Select into retcod *
		from series
		where document_type = '004' and id=2695
		and reg_status='';

		secuencia := retcod.prefix||lpad(retcod.last_number, 5, '0');

		UPDATE series set last_number = last_number+1 where document_type = '004' and id=2695 and reg_status = '';


	end if;



	return secuencia;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.serie_insumo(text)
  OWNER TO postgres;
