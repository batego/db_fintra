-- Function: reporteprovisionfiduciaintereses()

-- DROP FUNCTION reporteprovisionfiduciaintereses();

CREATE OR REPLACE FUNCTION reporteprovisionfiduciaintereses()
  RETURNS text AS
$BODY$

DECLARE
	PeriodoTable TEXT;
	sql_insert TEXT;
	FacturasMS record;

BEGIN

	TRUNCATE TABLE tem.temfacturas_intereses;

	FOR FacturasMS IN

		SELECT
		fra.ref1, cmc, nit, codcli, (select nomcli from cliente where codcli = fra.codcli) as name_cliente,  documento, clasificacion1, fecha_vencimiento, now()::date, REPLACE(substring(fecha_vencimiento,1,7),'-','') as periodo,
		(select COALESCE(sum(valor_unitario),0) from con.factura_detalle where concepto in ('227','228') and documento = fra.documento) as valor_factura,
		CURRENT_DATE - (CASE WHEN tipo_ref2='SV' THEN
					CASE WHEN SUBSTR(fecha_vencimiento,6,2)='01' THEN SUBSTR(CAST(SUBSTR((fecha_vencimiento+INTERVAL'1 month') ,1,8) || '28' AS TIMESTAMP),1,10) ELSE SUBSTR(CAST(SUBSTR((fecha_vencimiento+INTERVAL'1 month') ,1,8) || '30' AS TIMESTAMP),1,10) END
				ELSE
					SUBSTR((fecha_vencimiento + interval'10 days' ) ,1,10)
				END)::DATE  AS ndiasf
		FROM con.factura fra
		WHERE valor_saldo != 0 and
		fra.dstrct = 'FINV'
		--AND fra.valor_saldo > 0
		--AND fra.cmc IN ('OV','OP','FM')
		AND fra.reg_status != 'A' AND tipo_ref2='SV'
		AND (SUBSTR(fra.documento,1,2) in ('PM','RM') OR NOT EXISTS(SELECT ff.documento FROM con.factura ff WHERE ff.documento=REPLACE(fra.documento,'N','P') and ff.reg_status!='A'))
		AND fra.fecha_vencimiento >= '2013-01-01'
		ORDER BY ref1, documento, fecha_vencimiento LOOP

		PeriodoTable := FacturasMS.periodo;

		sql_insert = 'insert into tem.temfacturas_intereses (ref1, nit, codcli, cliente, cmc, documento, fiducia, fecha_vencimiento, "'||PeriodoTable||'") values('||''''||FacturasMS.ref1||''''||', '||''''||FacturasMS.nit||''''||', '||''''||FacturasMS.codcli||''''||', '||''''||FacturasMS.name_cliente||''''||', '||''''||FacturasMS.cmc||''''||', '||''''||FacturasMS.documento||''''||', '||''''||FacturasMS.clasificacion1||''''||', '||''''||FacturasMS.fecha_vencimiento||''''||', '||FacturasMS.valor_factura||')';
		EXECUTE sql_insert;

	END LOOP;

	RETURN PeriodoTable;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION reporteprovisionfiduciaintereses()
  OWNER TO postgres;
