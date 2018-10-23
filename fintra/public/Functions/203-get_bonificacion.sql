-- Function: get_bonificacion(numeric, text, text, text, text)

-- DROP FUNCTION get_bonificacion(numeric, text, text, text, text);

CREATE OR REPLACE FUNCTION get_bonificacion(numeric, text, text, text, text)
  RETURNS numeric AS
$BODY$Declare

	costo_contratista ALIAS FOR $1;
	fecha_oferta ALIAS FOR $2;
	cliente ALIAS FOR $3;
	nombre_cliente ALIAS FOR $4;
	oficial ALIAS FOR $5;

	valor numeric(12,2);
	posicion_nombre integer;

begin

valor := 0.00;

--select into posicion_nombre position ( 'COMCEL' in nombre_cliente) ;


--IF posicion_nombre = 0 THEN

	IF fecha_oferta < '2011-09-01' THEN

		select into valor to_number(substr(d.descripcion,1,9),'999999999')
		from tablagen d
		where d.table_type = 'BONI'
		      and costo_contratista  >= to_number(d.table_code,'999999999')
		      and costo_contratista  <  to_number(d.referencia,'999999999');

	ELSIF fecha_oferta > '2011-09-01' and fecha_oferta < '2013-02-15' THEN

		IF oficial = 'N' THEN

			select into valor round( to_number(substr(d.descripcion,1,7),'999D999') * costo_contratista / 100, 0)
			from tablagen d
			where d.table_type = 'BONIGEN'
			      and costo_contratista  >= to_number(d.table_code,'9999999999')
			      and costo_contratista  <  to_number(d.referencia,'9999999999');

		ELSE

			select into valor round( to_number(substr(d.descripcion,1,7),'999D999') * costo_contratista / 100 , 0)
			from tablagen d, opav.subclientes_eca f
			where f.id_subcliente = cliente
			      and d.table_type = 'BONIEXC'
			      and substr(d.table_code,1,7)  = f.id_cliente_padre
			      and costo_contratista  >= to_number(substr(d.table_code,8,10),'9999999999')
			      and costo_contratista  <  to_number(d.referencia,'9999999999');

			IF not found THEN
				select into valor round( to_number(substr(d.descripcion,1,7),'999D999') * costo_contratista / 100 , 0)
				from tablagen d
				where d.table_type = 'BONIOFI'
				      and costo_contratista  >= to_number(d.table_code,'9999999999')
				      and costo_contratista  <  to_number(d.referencia,'9999999999');
			END IF;

		END IF;

	ELSIF fecha_oferta > '2013-02-14' THEN

		IF oficial = 'N' THEN

			select into valor round( to_number(substr(d.descripcion,1,7),'999D999') * costo_contratista / 100, 0)
			from tablagen d
			where d.table_type = 'BONIGEN2'
			      and costo_contratista  >= to_number(d.table_code,'9999999999')
			      and costo_contratista  <  to_number(d.referencia,'9999999999');

		ELSE

			select into valor round( to_number(substr(d.descripcion,1,7),'999D999') * costo_contratista / 100 , 0)
			from tablagen d, opav.subclientes_eca f
			where f.id_subcliente = cliente
			      and d.table_type = 'BONIEXC2'
			      and substr(d.table_code,1,7)  = f.id_cliente_padre
			      and costo_contratista  >= to_number(substr(d.table_code,8,10),'9999999999')
			      and costo_contratista  <  to_number(d.referencia,'9999999999');

			IF not found THEN
				select into valor round( to_number(substr(d.descripcion,1,7),'999D999') * costo_contratista / 100 , 0)
				from tablagen d
				where d.table_type = 'BONIOFI2'
				      and costo_contratista  >= to_number(d.table_code,'9999999999')
				      and costo_contratista  <  to_number(d.referencia,'9999999999');
			END IF;

		END IF;


	END IF;

--END IF;

RETURN valor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_bonificacion(numeric, text, text, text, text)
  OWNER TO postgres;
