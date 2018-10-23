-- Function: opav.metodocalculo_ricardo(integer, character varying)

-- DROP FUNCTION opav.metodocalculo_ricardo(integer, character varying);

CREATE OR REPLACE FUNCTION opav.metodocalculo_ricardo(tipo integer, codigo character varying)
  RETURNS text AS
$BODY$
declare
    valor numeric;
    reg record;
    num integer;
    porc numeric;
/*
Tipo: 1 Percentil,
      2 Ultimo Precio,
      3 Promedio Ultimos 3 Meses,
      4 Promedio Ultimos 6 Meses

Codigo: Codigo del insumo
*/

begin

        valor:=0.00;

        IF (tipo=1) THEN --Obtener el percentil

                --Obtener la cantidad de materiales que se han comprado y el porcentaje del percentil
                SELECT Count(codigo_insumo),
                       (SELECT referencia :: NUMERIC
                        FROM   tablagen
                        WHERE  table_type = 'METCALC'
                               AND table_code = 'PERCENTIL')
                INTO   num, porc
                FROM   opav.sl_ocs_detalle
                WHERE  codigo_insumo = codigo;

                --Calcular el percentil 95 de un material basado en el precio que ha tenido en las ordenes de compra.
                SELECT   COALESCE(costo_unitario_compra::numeric,0)
                INTO     valor
                FROM     opav.sl_ocs_detalle
                WHERE    codigo_insumo=codigo
                ORDER BY costo_unitario_compra limit 1 offset ceiling((num::numeric*porc::numeric)/100::numeric)-1;

                IF(valor IS NULL) then
                  VALOR:=0.00; END IF;

        ELSE
        IF (tipo=2) THEN --Obtener el ultimo precio de compra

                SELECT coalesce(costo_unitario_compra::numeric, 0) INTO valor
                FROM opav.sl_ocs_detalle
                WHERE codigo_insumo=codigo
                ORDER BY creation_date DESC
                LIMIT 1;

                IF(valor IS NULL) THEN
                  valor:=0.00;
                END IF;


        ELSE
        IF (tipo=3) THEN --Obtener promedio del los ultimos 3 meses

                SELECT coalesce(round(sum(costo_unitario_compra::numeric)/count(codigo_insumo), 2), 0) INTO valor
                FROM opav.sl_ocs_detalle
                WHERE codigo_insumo=codigo
                  AND creation_date::date BETWEEN (CURRENT_DATE - interval '3 month')::date AND CURRENT_DATE ;


        ELSE
        IF (tipo=4) THEN --Obtener promedio del los ultimos 6 meses

                SELECT coalesce(round(sum(costo_unitario_compra::numeric)/count(codigo_insumo), 2), 0) INTO valor
                FROM opav.sl_ocs_detalle
                WHERE codigo_insumo=codigo
                  AND creation_date::date BETWEEN (CURRENT_DATE - interval '6 month')::date AND CURRENT_DATE ;

        END IF;
        END IF;
        END IF;
        END IF;

 return valor;


end;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.metodocalculo_ricardo(integer, character varying)
  OWNER TO postgres;
