-- Function: prueba090917()

-- DROP FUNCTION prueba090917();

CREATE OR REPLACE FUNCTION prueba090917()
  RETURNS boolean AS
$BODY$DECLARE
    _group RECORD;
    _count INTEGER;
    i INTEGER;
BEGIN
    i:=0;
    SELECT count(*) into _count from tablagen where table_type='prueba0917';
    FOR _group IN SELECT * FROM tablagen where table_type='prueba0917' LOOP     -- buggy without "ORDER BY"
    --FOR _group IN SELECT * FROM groups ORDER BY groupname LOOP     -- normal
        i := i + 1;
        --raise notice ''N. = %, name = %'', i, _group.groupname;
        UPDATE tablagen  SET descripcion = descripcion || i ||  _group.dato where table_type='prueba0917' AND descripcion =_group.descripcion;--WHERE groupname = _group.groupname;
    END LOOP;
    RETURN TRUE;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION prueba090917()
  OWNER TO postgres;
