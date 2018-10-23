-- Function: fin.sp_facturas_generadas_ap_ac(date, date)

-- DROP FUNCTION fin.sp_facturas_generadas_ap_ac(date, date);

CREATE OR REPLACE FUNCTION fin.sp_facturas_generadas_ap_ac(fecha_inicio date, fecha_final date)
  RETURNS SETOF record AS
$BODY$

DECLARE
	FacturaEndosada record;

	_numero_remesa record;
	documentos TEXT;

BEGIN

	FOR FacturaEndosada IN
		SELECT
		f.reg_status::varchar,
		f.documento::varchar AS numero_factura,
		f.creation_date::date AS fecha_creacion,
		f.fecha_vencimiento::date,
		f.nit::varchar AS nit_cliente,
		get_nombc(f.nit)::varchar AS nombre_cliente,
		f.valor_factura::numeric(15,2),
		d.valor_detalle::numeric(15,2),
		f.valor_saldo::numeric(15,2),
		d.items::numeric(15,0),
		d.codigo_cuenta_contable::varchar AS cuentas_contable_detalle,
		''::text AS documento_relacionado
		FROM con.factura f
		LEFT JOIN (
			Select documento,
			sum(valor_item) AS valor_detalle, count(*) AS items,
			codigo_cuenta_contable
			from con.factura_detalle
			where reg_status !='A' group by 1,4
		) d ON (f.documento=d.documento)
		WHERE substring(f.documento,1,2) in ('AP','AC')
		AND f.creation_Date::date between fecha_inicio and fecha_final
		order by f.documento
	 LOOP
		documentos = '';
		FOR _numero_remesa IN select numero_remesa from con.factura_detalle where documento = FacturaEndosada.numero_factura and reg_status!='A' LOOP
			raise notice 'Devielve: %',_numero_remesa.numero_remesa;
			--if found then
				documentos = (documentos || _numero_remesa.numero_remesa || ',')::text;
				FacturaEndosada.documento_relacionado = documentos;
			--end if;
		END LOOP;



		RETURN NEXT FacturaEndosada;

	END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION fin.sp_facturas_generadas_ap_ac(date, date)
  OWNER TO postgres;
