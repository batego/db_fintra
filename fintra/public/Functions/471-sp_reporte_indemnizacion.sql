-- Function: sp_reporte_indemnizacion()

-- DROP FUNCTION sp_reporte_indemnizacion();

CREATE OR REPLACE FUNCTION sp_reporte_indemnizacion()
  RETURNS SETOF record AS
$BODY$

DECLARE
	FacturaEndosada record;
	FacturaRemesa record;
	FacturaRemesaCuentas record;
	FacturaDeTurno record;
	QryCasos record;

	VarController1 TEXT;
	VarController2 TEXT;
	Cuentas TEXT;

	FACpa varchar;
	FACpaFecha varchar;
	FACpaVencimiento varchar;
	FACpaValor numeric;

	FACfen TEXT;
	FACfenFecha varchar;
	FACfenVencimiento varchar;
	FACfenValor numeric;


BEGIN
	--RAISE NOTICE 'Inicializando esta "$%#"$%"%';

	FOR FacturaEndosada IN select * from con.factura where nit_endoso != '' LOOP

		--IF something_wrong_with(FacturaEndosada) THEN
		--    RAISE EXCEPTION 'Something went wrong';
		--END IF;

		VarController1 := 'N';
		VarController2 := 'N';
		Cuentas := '';

		FACpa := '';
		FACpaFecha := '';
		FACpaVencimiento := '';
		FACpaValor := 0;

		FACfen := '';
		FACfenFecha := '';
		FACfenVencimiento := '';
		FACfenValor := 0;

		FOR FacturaRemesaCuentas IN select * from con.factura_detalle where numero_remesa = FacturaEndosada.documento and substring(documento,1,2) in (select prefix from series where document_type in (select prefijo_factura_endoso from convenios_cxc_fiducias where prefijo_factura_endoso != '' group by prefijo_factura_endoso)) LOOP
			Cuentas := Cuentas ||  FacturaRemesaCuentas.codigo_cuenta_contable || ',';
		END LOOP;

		FOR FacturaRemesa IN select distinct on (documento) * from con.factura_detalle where numero_remesa = FacturaEndosada.documento LOOP

			SELECT INTO FacturaDeTurno * from con.factura where documento = FacturaRemesa.documento;

			IF ( substring(FacturaRemesa.documento,1,2) in (select prefix from series where document_type in (select prefijo_factura_endoso from convenios_cxc_fiducias where prefijo_factura_endoso != '' group by prefijo_factura_endoso)) ) THEN

				FACpa := FacturaDeTurno.documento;
				FACpaFecha := FacturaDeTurno.fecha_factura;
				FACpaVencimiento := FacturaDeTurno.fecha_vencimiento;
				FACpaValor := FacturaDeTurno.valor_factura;
				VarController1 := 'S';

			ELSIF ( substring(FacturaRemesa.documento,1,2) in ('FF','CP','PF') ) THEN

				FACfen := FacturaDeTurno.documento;
				FACfenFecha := FacturaDeTurno.fecha_factura;
				FACfenVencimiento := FacturaDeTurno.fecha_vencimiento;
				FACfenValor := FacturaDeTurno.valor_factura;
				VarController2 := 'S';

			END IF;

		END LOOP;

		IF ( VarController1 = 'S' and VarController2 = 'S' ) THEN

			FOR QryCasos IN

				select negasoc::varchar, nit::varchar, codcli::varchar, (select nomcli from cliente where nit = con.factura.nit limit 1)::varchar, (select nit_fen from negocios where cod_neg = con.factura.negasoc)::varchar, documento::varchar, fecha_factura::varchar, fecha_vencimiento::varchar, valor_factura::numeric, FACpa::varchar, Cuentas::varchar, FACpaFecha::varchar, FACpaVencimiento::varchar, FACpaValor::numeric, FACfen::varchar, FACfenFecha::varchar, FACfenVencimiento::varchar, FACfenValor::numeric
				from con.factura
				where documento = FacturaEndosada.documento LOOP

				RETURN NEXT QryCasos;

			END LOOP;

		END IF;

	END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_reporte_indemnizacion()
  OWNER TO postgres;
