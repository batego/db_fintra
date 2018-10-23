-- Function: get_nit_fiducia(text)

-- DROP FUNCTION get_nit_fiducia(text);

CREATE OR REPLACE FUNCTION get_nit_fiducia(text)
  RETURNS text AS
$BODY$DECLARE
  _documento ALIAS FOR $1;
  _nit TEXT;
BEGIN

IF TRIM(_documento) != '' THEN

	  SELECT
	   INTO _nit
	        case
		when fc.nit_enviado_fiducia is not null and fc.nit_enviado_fiducia !='' then fc.nit_enviado_fiducia||'0'
		else
			case
			when not (length(replace(replace(replace(REPLACE(fc.nit,'_',''),'-',''),' ',''),'	','')) >9 and substring(fc.nit,1,1) in ('8','9')) then REPLACE(REPLACE(REPLACE(REPLACE(fc.nit,'_',''),'.',''),'-',''),'	','')||'0'
			ELSE REPLACE(REPLACE(REPLACE(REPLACE(fc.nit,'_',''),'.',''),'-',''),'	','')
			END
		end
	  FROM
		con.factura fc

	  WHERE
		fc.documento = _documento;
ELSE
	_nit := NULL;
END IF;


  RETURN _nit;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_nit_fiducia(text)
  OWNER TO postgres;
