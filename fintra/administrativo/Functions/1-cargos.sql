-- Function: administrativo.cargos(administrativo.type_cargos)

-- DROP FUNCTION administrativo.cargos(administrativo.type_cargos);

CREATE OR REPLACE FUNCTION administrativo.cargos(ctype administrativo.type_cargos)
  RETURNS text AS
$BODY$

DECLARE

BEGIN


INSERT INTO ADMINISTRATIVO.cargos_apoteosys(
            CARGO__CODIGO____B, CARGO__NOMBRE____B, CARGO__OBSERVACI_B, CARGO__FECHORCRE_B,
            CARGO__AUTOCREA__B, CARGO__FEHOULMO__B, CARGO__AUTULTMOD_B

            )
    VALUES (
            CTYPE.CARGO__CODIGO____B, CTYPE.CARGO__NOMBRE____B, CTYPE.CARGO__OBSERVACI_B, CTYPE.CARGO__FECHORCRE_B,
            CTYPE.CARGO__AUTOCREA__B, CTYPE.CARGO__FEHOULMO__B, CTYPE.CARGO__AUTULTMOD_B);

RETURN 'S';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION administrativo.cargos(administrativo.type_cargos)
  OWNER TO postgres;
