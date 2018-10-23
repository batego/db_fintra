-- Function: opav.sp_codinsumos_repetidos()

-- DROP FUNCTION opav.sp_codinsumos_repetidos();

CREATE OR REPLACE FUNCTION opav.sp_codinsumos_repetidos()
  RETURNS text AS
$BODY$
DECLARE

_insumos record;
_resultado varchar:='OK';
_cod_material varchar:='';


 BEGIN

	FOR _insumos IN
		--Esta consulta obtiene los insumo que se encuentran con el codigo insumo repetidos.
		SELECT
			*
		FROM
			opav.sl_insumo
		WHERE
			codigo_material in (
				select codigo_material  from opav.sl_insumo group by codigo_material having count(*)>1) order by codigo_material

	LOOP

		RAISE NOTICE 'id_subcategoria :% ',_insumos.id_subcategoria;

		--obtenemos el nuevo codigo del insumo pasando por parametro la sub-categoria.
		select opav.serie_insumo(_insumos.id_subcategoria) into _cod_material;
		RAISE NOTICE 'Codigo Material :% ',_cod_material;

		--insertamos el codigo del insumo
		update opav.sl_insumo set codigo_material = _cod_material where id = _insumos.id;


	END LOOP;


return _resultado;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_codinsumos_repetidos()
  OWNER TO postgres;
