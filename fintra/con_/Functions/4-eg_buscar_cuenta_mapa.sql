-- Function: con.eg_buscar_cuenta_mapa(character varying)

-- DROP FUNCTION con.eg_buscar_cuenta_mapa(character varying);

CREATE OR REPLACE FUNCTION con.eg_buscar_cuenta_mapa(incuenta character varying)
  RETURNS text AS
$BODY$

DECLARE

  cuentaFintra TEXT;


BEGIN

	select into cuentaFintra cuenta_local from con.mapa_cuentas_fintra  where cuenta_remota=inCuenta;

	RETURN cuentaFintra;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.eg_buscar_cuenta_mapa(character varying)
  OWNER TO postgres;
