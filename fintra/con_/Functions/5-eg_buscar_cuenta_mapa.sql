-- Function: con.eg_buscar_cuenta_mapa(character varying, character varying)

-- DROP FUNCTION con.eg_buscar_cuenta_mapa(character varying, character varying);

CREATE OR REPLACE FUNCTION con.eg_buscar_cuenta_mapa(incuenta character varying, _concepto character varying)
  RETURNS text AS
$BODY$

DECLARE

  cuentaFintra TEXT;


BEGIN
	raise notice 'concepto= %',_concepto;
	select into cuentaFintra cuenta_remota from con.mapa_cuentas_fintra
	where cuenta_local=inCuenta and
		case when _concepto IN ('219','234','700') and cuenta_local not in ('28151006') then descripcion=_concepto else descripcion='' end
		;

	RETURN cuentaFintra;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.eg_buscar_cuenta_mapa(character varying, character varying)
  OWNER TO postgres;
