-- Function: sp_fecha_corte_foto(character varying, integer)

-- DROP FUNCTION sp_fecha_corte_foto(character varying, integer);

CREATE OR REPLACE FUNCTION sp_fecha_corte_foto(anio character varying, _mes integer)
  RETURNS text AS
$BODY$
DECLARE

--retorno text:='';
_fechaCorte varchar;

BEGIN
    _fechaCorte:=anio;

   _fechaCorte:=( select CASE WHEN _mes=1 THEN _fechaCorte::integer-1||'-12-31'
         WHEN _mes=2 THEN _fechaCorte||'-01-31'
         WHEN _mes=3 THEN case when (anio::integer%4)=0 then  _fechaCorte||'-02-29' else   _fechaCorte||'-02-28' end
         WHEN _mes=4 THEN _fechaCorte||'-03-31'
         WHEN _mes=5 THEN _fechaCorte||'-04-30'
         WHEN _mes=6 THEN _fechaCorte||'-05-31'
         WHEN _mes=7 THEN _fechaCorte||'-06-30'
         WHEN _mes=8 THEN _fechaCorte||'-07-31'
         WHEN _mes=9 THEN _fechaCorte||'-08-31'
         WHEN _mes=10 THEN _fechaCorte||'-09-30'
         WHEN _mes=11 THEN _fechaCorte||'-10-31'
         WHEN _mes=12 THEN _fechaCorte||'-11-30'
     end);

	--raise notice '_fechaCorte : %',_fechaCorte;



return _fechaCorte;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_fecha_corte_foto(character varying, integer)
  OWNER TO postgres;
