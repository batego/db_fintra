-- Function: con.get_comprobantes_descuadrados(text)

-- DROP FUNCTION con.get_comprobantes_descuadrados(text);

CREATE OR REPLACE FUNCTION con.get_comprobantes_descuadrados(in_periodo text)
  RETURNS SETOF con.rs_comprobantes_descuadrados AS
$BODY$
DECLARE
--***************************************************************************************
-- Funcion .......... con.get_comprobantes_descuadrados(in_periodo numeric)             *
-- Objetivo ......... Obtener los comprobantes contables descuadrados en un periodo	*
-- Parametro ........ Perido Contable	  						*
-- Salida ........... con.rs_comprobantes_descuadrados					*
-- Fecha ............ 07-07-2011                                                        *
-- Autor ............ Ing. Fabian Diaz Andrade                                          *
--***************************************************************************************
rs RECORD;
rs_comprobantes con.rs_comprobantes_descuadrados;
SQL TEXT;
BEGIN
	EXECUTE 'DROP TABLE IF EXISTS tem.comprobante_'||in_periodo;
	EXECUTE 'DROP TABLE IF EXISTS tem.comprodet_'||in_periodo;

	SQL = 'CREATE TABLE tem.comprobante_'||in_periodo ||' AS
		SELECT
			cb.tipodoc,
			cb.numdoc,
			cb.grupo_transaccion,
			cb.total_debito,
			cb.total_credito
		FROM
			con.comprobante cb
		WHERE
			cb.periodo ='''|| in_periodo ||'''';
	EXECUTE SQL;

	SQL = 'CREATE TABLE tem.comprodet_'||in_periodo ||' AS
		SELECT
			ct.tipodoc,
			ct.numdoc,
			ct.grupo_transaccion,
			SUM(ct.valor_debito) AS total_debito,
			SUM(ct.valor_credito) AS total_credito
		FROM
			con.comprodet ct
		WHERE
			ct.periodo ='''|| in_periodo ||'''
		GROUP BY
			ct.tipodoc,
			ct.numdoc,
			ct.grupo_transaccion';
	EXECUTE SQL;

	SQL = 'SELECT * FROM tem.comprobante_'||in_periodo ||' EXCEPT SELECT * FROM  tem.comprodet_'||in_periodo;

	FOR rs_comprobantes IN EXECUTE SQL
	LOOP
		RETURN NEXT rs_comprobantes;
	END LOOP;

        PERFORM COUNT(rs_comprobantes);

        IF NOT FOUND THEN

                SQL = 'SELECT * FROM tem.comprodet_'||in_periodo ||' EXCEPT SELECT * FROM  tem.comprobante_'||in_periodo;

                FOR rs_comprobantes IN EXECUTE SQL
                LOOP
                        RETURN NEXT rs_comprobantes;
                END LOOP;

        END IF;

	RETURN;
END
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.get_comprobantes_descuadrados(text)
  OWNER TO postgres;
