-- Function: sp_fecha_inicio_mora(character varying, character varying)

-- DROP FUNCTION sp_fecha_inicio_mora(character varying, character varying);

CREATE OR REPLACE FUNCTION sp_fecha_inicio_mora(_codigo_negocio character varying, _periodo_foto character varying)
  RETURNS text AS
$BODY$
DECLARE

--retorno text:='';
_fechaInicioMora varchar;

BEGIN

   _fechaInicioMora:=(SELECT replace(min(fecha_vencimiento)::date,'-','') AS fecha_inicio_mora
					FROM con.foto_cartera foto
					WHERE  negasoc = _codigo_negocio
					AND foto.documento LIKE 'MC%'
					AND valor_saldo > 0
                                        AND foto.periodo_lote = _periodo_foto
					AND foto.reg_status !='A');

	raise notice '_fechaMora : %',_fechaInicioMora;



return _fechaInicioMora;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_fecha_inicio_mora(character varying, character varying)
  OWNER TO postgres;
