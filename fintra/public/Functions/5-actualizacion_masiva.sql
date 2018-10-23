-- Function: actualizacion_masiva()

-- DROP FUNCTION actualizacion_masiva();

CREATE OR REPLACE FUNCTION actualizacion_masiva()
  RETURNS boolean AS
$BODY$
  DECLARE
    _group RECORD;
  BEGIN

    FOR _group IN select cod_cli from negocios where cod_cli != ' ' and cod_cli like ' %' LOOP
        --UPDATE tablagen  SET descripcion = descripcion || i ||  _group.dato where table_type='prueba0917' AND descripcion =_group.descripcion;--WHERE groupname = _group.groupname;
        update negocios set cod_cli = trim(both ' ' from _group.cod_cli) where cod_cli = _group.cod_cli;
    END LOOP;

    RETURN TRUE;

  END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION actualizacion_masiva()
  OWNER TO postgres;
