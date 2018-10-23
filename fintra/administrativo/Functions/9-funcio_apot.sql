-- Function: administrativo.funcio_apot(administrativo.type_empleados)

-- DROP FUNCTION administrativo.funcio_apot(administrativo.type_empleados);

CREATE OR REPLACE FUNCTION administrativo.funcio_apot(mctype administrativo.type_empleados)
  RETURNS text AS
$BODY$

DECLARE

BEGIN


INSERT INTO ADMINISTRATIVO.FUNCIO_APOT(
            FUNCIO_IDENTIFIC_B, FUNCIO_CODIGO____TIT____B,
            FUNCIO_NOMBCORT__B, FUNCIO_APELLIDOS_B, FUNCIO_NOMBEXTE__B,
            FUNCIO_CODIGO____TT_____B, FUNCIO_DIRECCION_B,
            FUNCIO_CODIGO____CIUDAD_B, FUNCIO_TELEFONO1_B,
            FUNCIO_CODIGO____CARGO__B, FUNCIO_AUTOCREA__B,
            FUNCIO_CODIGO____USUARI_B, FUNCIO_EMAIL_____B
            )
    VALUES (
            MCTYPE.FUNCIO_IDENTIFIC_B, MCTYPE.FUNCIO_CODIGO____TIT____B,
            MCTYPE.FUNCIO_NOMBCORT__B, MCTYPE.FUNCIO_APELLIDOS_B, MCTYPE.FUNCIO_NOMBEXTE__B,
            MCTYPE.FUNCIO_CODIGO____TT_____B, MCTYPE.FUNCIO_DIRECCION_B,
            MCTYPE.FUNCIO_CODIGO____CIUDAD_B, MCTYPE.FUNCIO_TELEFONO1_B,
            MCTYPE.FUNCIO_CODIGO____CARGO__B, MCTYPE.FUNCIO_AUTOCREA__B,
            MCTYPE.FUNCIO_CODIGO____USUARI_B, MCTYPE.FUNCIO_EMAIL_____B);

RETURN 'S';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION administrativo.funcio_apot(administrativo.type_empleados)
  OWNER TO postgres;
