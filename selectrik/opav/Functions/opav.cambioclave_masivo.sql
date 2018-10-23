-- Function: opav.cambioclave_masivo()

-- DROP FUNCTION opav.cambioclave_masivo();

CREATE OR REPLACE FUNCTION opav.cambioclave_masivo()
  RETURNS boolean AS
$BODY$
  DECLARE
    _group RECORD;
  BEGIN

    FOR _group IN select * from opav.app_contratistas LOOP
        --UPDATE tablagen  SET descripcion = descripcion || i ||  _group.dato where table_type='prueba0917' AND descripcion =_group.descripcion;--WHERE groupname = _group.groupname;
        update opav.app_contratistas set clave = (select trunc(random() * 999999 + 1) from generate_series(0,0)) where id_contratista = _group.id_contratista;
    END LOOP;

    RETURN TRUE;

  END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.cambioclave_masivo()
  OWNER TO postgres;
