-- Function: tem.getultimoitem(text)

-- DROP FUNCTION tem.getultimoitem(text);

CREATE OR REPLACE FUNCTION tem.getultimoitem(text)
  RETURNS integer AS
$BODY$DECLARE
ultimox INTEGER;
codx ALIAS FOR $1;

BEGIN

SELECT  INTO ultimox item FROM tem.ultimo_it WHERE documento=codx;

if ultimox is not null then

UPDATE  tem.ultimo_it  SET item=item+1  WHERE documento=codx;

else

insert into tem.ultimo_it values (codx,2);
ultimox:=1;

end if;

RETURN ultimox;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION tem.getultimoitem(text)
  OWNER TO postgres;
