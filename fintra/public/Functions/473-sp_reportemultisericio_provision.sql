-- Function: sp_reportemultisericio_provision()

-- DROP FUNCTION sp_reportemultisericio_provision();

CREATE OR REPLACE FUNCTION sp_reportemultisericio_provision()
  RETURNS text AS
$BODY$

DECLARE
	PeriodoTable TEXT;
	sql_insert TEXT;
	CIdb CHARACTER VARYING;
	VarFACcc TEXT;
	VarFACcg TEXT;
	CountDocum CHARACTER VARYING;
	FactRem con.factura_detalle;
	RemDetalle integer;
	mcad TEXT;
	vfacs numeric;
	CntX numeric;
	message TEXT;

	FacturasMSCapital record;
	FacturasMSInteres record;
	QryCasos record;
	myrec record;


	_Concepto CHARACTER VARYING;
	_Validate CHARACTER VARYING;
	VarRef CHARACTER VARYING;
	_SumCapital numeric;
	_SumInteres numeric;


BEGIN

	DROP TABLE IF EXISTS provision_temporal;

	CREATE TEMPORARY TABLE provision_temporal
	(
	  ref1 character varying(15) DEFAULT ''::character varying,
	  nit character varying(15) DEFAULT ''::character varying,
	  codcli character varying(15) DEFAULT ''::character varying,
	  cliente character varying(100) DEFAULT ''::character varying,
	  fiducia character varying(15) DEFAULT ''::character varying,
	  documento character varying(15) DEFAULT ''::character varying,
	  fecha_vencimiento date DEFAULT '0099-01-01'::date,
	  periodo_vencimiento character varying(15) DEFAULT '',
	  valor_factura moneda,
	  valor_abono moneda,
	  valor_saldo moneda,
	  concepto character varying(20) DEFAULT ''::character varying,
	  valor_concepto moneda
	) WITH (OIDS=TRUE); ALTER TABLE provision_temporal OWNER TO postgres;

	_SumCapital = 0;
	_SumInteres = 0;
	CntX = 0;
	sql_insert = '';
	message = 'TERMINADO!';

	FOR FacturasMSCapital IN

		SELECT
		f.ref1, f.nit, f.codcli
		,(select nomcli from cliente where codcli = f.codcli) as nombre_cliente
		,f.clasificacion1 as fiducia, f.documento, f.fecha_vencimiento, now()::date, REPLACE(substring(f.fecha_vencimiento,1,7),'-','') as periodo, f.valor_factura, f.valor_abono, f.valor_saldo,
		CURRENT_DATE - (CASE WHEN f.tipo_ref2='SV' THEN
					CASE WHEN SUBSTR(f.fecha_vencimiento,6,2)='01' THEN SUBSTR(CAST(SUBSTR((f.fecha_vencimiento+INTERVAL'1 month') ,1,8) || '28' AS TIMESTAMP),1,10) ELSE SUBSTR(CAST(SUBSTR((f.fecha_vencimiento+INTERVAL'1 month') ,1,8) || '30' AS TIMESTAMP),1,10) END
				ELSE
					SUBSTR((f.fecha_vencimiento + interval'10 days' ) ,1,10)
				END)::DATE  AS ndiasf
		--,fd.concepto
		--, fd.descripcion
		, sum(fd.valor_unitario) as SumCapital
		FROM con.factura f, con.factura_detalle fd
		WHERE f.documento = fd.documento
			--AND f.valor_saldo != 0
			AND f.dstrct = 'FINV'
			AND f.reg_status != 'A'
			AND f.tipo_ref2='SV'
			AND (SUBSTR(f.documento,1,2) in ('PM','RM') OR NOT EXISTS(SELECT ff.documento FROM con.factura ff WHERE ff.documento=REPLACE(f.documento,'N','P') and ff.reg_status!='A'))
			--AND f.documento in ('RM00001_18','RM00001_19','RM00001_20','PM07311_1','RM00001_21')
			AND fd.concepto in ('235','239','234','225')
		GROUP BY f.ref1, f.nit, f.codcli, nombre_cliente, f.clasificacion1, f.documento, f.fecha_vencimiento, now, periodo, f.valor_factura, f.valor_abono, f.valor_saldo, ndiasf
		ORDER BY f.ref1, f.documento, f.fecha_vencimiento LOOP

		_Concepto = 'CAPITAL';
		sql_insert = 'insert into provision_temporal (ref1, nit, codcli, cliente, fiducia, documento, fecha_vencimiento, periodo_vencimiento, valor_factura, valor_abono, valor_saldo, concepto, valor_concepto) values('||''''||FacturasMSCapital.ref1||''''||', '||''''||FacturasMSCapital.nit||''''||', '||''''||FacturasMSCapital.codcli||''''||', '||''''||FacturasMSCapital.nombre_cliente||''''||', '||''''||FacturasMSCapital.fiducia||''''||', '||''''||FacturasMSCapital.documento||''''||', '||''''||FacturasMSCapital.fecha_vencimiento||''''||', '||''''||FacturasMSCapital.periodo||''''||', '||FacturasMSCapital.valor_factura||', '||FacturasMSCapital.valor_abono||', '||FacturasMSCapital.valor_saldo||','||''''||_Concepto||''''||', '||FacturasMSCapital.SumCapital||')';
		EXECUTE sql_insert;

	END LOOP;


	FOR FacturasMSInteres IN

		SELECT
		f.ref1, f.nit, f.codcli
		,(select nomcli from cliente where codcli = f.codcli) as nombre_cliente
		,f.clasificacion1 as fiducia, f.documento, f.fecha_vencimiento, now()::date, REPLACE(substring(f.fecha_vencimiento,1,7),'-','') as periodo, f.valor_factura, f.valor_abono, f.valor_saldo,
		CURRENT_DATE - (CASE WHEN f.tipo_ref2='SV' THEN
					CASE WHEN SUBSTR(f.fecha_vencimiento,6,2)='01' THEN SUBSTR(CAST(SUBSTR((f.fecha_vencimiento+INTERVAL'1 month') ,1,8) || '28' AS TIMESTAMP),1,10) ELSE SUBSTR(CAST(SUBSTR((f.fecha_vencimiento+INTERVAL'1 month') ,1,8) || '30' AS TIMESTAMP),1,10) END
				ELSE
					SUBSTR((f.fecha_vencimiento + interval'10 days' ) ,1,10)
				END)::DATE  AS ndiasf
		--,fd.concepto
		--, fd.descripcion
		, sum(fd.valor_unitario) as SumInteres
		FROM con.factura f, con.factura_detalle fd
		WHERE f.documento = fd.documento
			--AND f.valor_saldo != 0
			AND f.dstrct = 'FINV'
			AND f.reg_status != 'A'
			AND f.tipo_ref2='SV'
			AND (SUBSTR(f.documento,1,2) in ('PM','RM') OR NOT EXISTS(SELECT ff.documento FROM con.factura ff WHERE ff.documento=REPLACE(f.documento,'N','P') and ff.reg_status!='A'))
			--AND f.documento in ('RM00001_18','RM00001_19','RM00001_20','PM07311_1','RM00001_21')
			AND fd.concepto in ('227','228')
		GROUP BY f.ref1, f.nit, f.codcli, nombre_cliente, f.clasificacion1, f.documento, f.fecha_vencimiento, now, periodo, f.valor_factura, f.valor_abono, f.valor_saldo, ndiasf
		ORDER BY f.ref1, f.documento, f.fecha_vencimiento LOOP

		_Concepto = 'INTERES';
		sql_insert = 'insert into provision_temporal (ref1, nit, codcli, cliente, fiducia, documento, fecha_vencimiento, periodo_vencimiento, valor_factura, valor_abono, valor_saldo, concepto, valor_concepto) values('||''''||FacturasMSInteres.ref1||''''||', '||''''||FacturasMSInteres.nit||''''||', '||''''||FacturasMSInteres.codcli||''''||', '||''''||FacturasMSInteres.nombre_cliente||''''||', '||''''||FacturasMSInteres.fiducia||''''||', '||''''||FacturasMSInteres.documento||''''||', '||''''||FacturasMSInteres.fecha_vencimiento||''''||', '||''''||FacturasMSInteres.periodo||''''||', '||FacturasMSInteres.valor_factura||', '||FacturasMSInteres.valor_abono||', '||FacturasMSInteres.valor_saldo||','||''''||_Concepto||''''||', '||FacturasMSInteres.SumInteres||')';
		EXECUTE sql_insert;

	END LOOP;

	--DROP TABLE IF EXISTS tem.temfactura_provision;
	--create table tem.temfactura_provision as select * from provision_temporal order by ref1, documento, fecha_vencimiento;


	RETURN message;
END;
--$$
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_reportemultisericio_provision()
  OWNER TO postgres;
