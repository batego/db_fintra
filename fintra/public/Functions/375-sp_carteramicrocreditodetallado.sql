-- Function: sp_carteramicrocreditodetallado(character varying)

-- DROP FUNCTION sp_carteramicrocreditodetallado(character varying);

CREATE OR REPLACE FUNCTION sp_carteramicrocreditodetallado(varasesor character varying)
  RETURNS SETOF record AS
$BODY$
--RETURNS text AS $HYS$

DECLARE

	PeriodoVencido TEXT;
	ValorVencido TEXT;
	sql_insert TEXT;

	FacturasMS record;
	QryCasos record;

	mcad TEXT;
	message TEXT;

BEGIN

	--DROP TABLE IF EXISTS tem.temCarteraMicroDetallado;
	/*
	CREATE TABLE tem.temCarteraMicroDetallado
	(
	  asesor character varying(60) DEFAULT ''::character varying,
	  cliente character varying(120) DEFAULT ''::character varying,
	  direccion character varying(80) DEFAULT ''::character varying,
	  telefono character varying(15) DEFAULT ''::character varying,
	  negocio character varying(15) DEFAULT ''::character varying,
	  cuota character varying(15) DEFAULT ''::character varying,
	  no_factura character varying(15) DEFAULT ''::character varying,
	  fecha_vencimiento date DEFAULT '0099-01-01'::date,
	  corriente numeric(15,0) NOT NULL DEFAULT 0,
	  "d0A30" numeric(15,0) NOT NULL DEFAULT 0,
	  "d31A60" numeric(15,0) NOT NULL DEFAULT 0,
	  "d61A90" numeric(15,0) NOT NULL DEFAULT 0,
	  "d91A120" numeric(15,0) NOT NULL DEFAULT 0,
	  "d121A180" numeric(15,0) NOT NULL DEFAULT 0,
	  "d180A360" numeric(15,0) NOT NULL DEFAULT 0,
	  "MAYORA1" numeric(15,0) NOT NULL DEFAULT 0
	) WITH (OIDS=TRUE); ALTER TABLE tem.temCarteraMicroDetallado OWNER TO postgres;
	*/
	TRUNCATE TABLE tem.temCarteraMicroDetallado;

	FOR FacturasMS IN

		select
		(select nombre from usuarios where idusuario = sa.asesor) AS NombreAsesor,
		(SELECT nomcli FROM cliente WHERE nit=n.cod_cli) AS Nombre_Cliente,
		(SELECT direccion FROM cliente WHERE nit=n.cod_cli) AS Direccion,
		(select telefono from solicitud_persona where numero_solicitud = (select numero_solicitud from solicitud_aval where cod_neg = n.cod_neg) limit 1) AS telefono,
		n.cod_neg,
		fac.reg_status, fac.cmc, fac.negasoc, fac.num_doc_fen,
		fac.documento, fac.creation_date, fac.periodo, fac.fecha_factura, fac.fecha_vencimiento, fac.descripcion, fac.valor_factura, fac.valor_abono, fac.valor_saldo
		,CURRENT_DATE-(fecha_vencimiento)::DATE  AS ndiasf
		from con.factura fac
		inner join negocios n on (n.cod_neg=fac.negasoc)
		inner join solicitud_aval sa on (sa.cod_neg=n.cod_neg and sa.asesor = VarAsesor)
		where --CURRENT_DATE-(fecha_vencimiento)::DATE >= 0
		valor_saldo != 0
		and fac.reg_status = ''
		order by fac.negasoc, num_doc_fen::numeric, creation_date LOOP

		IF ( FacturasMS.ndiasf < 0 ) THEN

		   PeriodoVencido := 'corriente';

		ELSIF ( FacturasMS.ndiasf >= 0 AND FacturasMS.ndiasf <= 30 ) THEN

		   PeriodoVencido := 'd0A30';
		   ValorVencido := FacturasMS.valor_saldo;

		ELSIF ( FacturasMS.ndiasf >= 31 AND FacturasMS.ndiasf <= 90 ) THEN

		   PeriodoVencido := 'd31A60';
		   ValorVencido := FacturasMS.valor_saldo;

		ELSIF ( FacturasMS.ndiasf >= 61 AND FacturasMS.ndiasf <= 90 ) THEN

		   PeriodoVencido := 'd61A90';
		   ValorVencido := FacturasMS.valor_saldo;

		ELSIF ( FacturasMS.ndiasf >= 91 AND FacturasMS.ndiasf <= 120 ) THEN

		   PeriodoVencido := 'd91A120';
		   ValorVencido := FacturasMS.valor_saldo;

		ELSIF ( FacturasMS.ndiasf >= 121 AND FacturasMS.ndiasf <= 180 ) THEN

		   PeriodoVencido := 'd121A180';
		   ValorVencido := FacturasMS.valor_saldo;

		ELSIF ( FacturasMS.ndiasf >= 180 AND FacturasMS.ndiasf <= 360 ) THEN

		   PeriodoVencido := 'd180A360';
		   ValorVencido := FacturasMS.valor_saldo;

		ELSIF ( FacturasMS.ndiasf > 360 ) THEN

		   PeriodoVencido := 'MAYORA1';
		   ValorVencido := FacturasMS.valor_saldo;

		END IF;

		sql_insert = 'INSERT INTO tem.temCarteraMicroDetallado (asesor, cliente, direccion, telefono, negocio, cuota, no_factura, fecha_vencimiento, "'||PeriodoVencido||'") values('||''''||FacturasMS.NombreAsesor||''''||', '||''''||FacturasMS.Nombre_Cliente||''''||', '||''''||FacturasMS.Direccion||''''||', '||''''||FacturasMS.telefono||''''||', '||''''||FacturasMS.cod_neg||''''||', '||''''||FacturasMS.num_doc_fen||''''||','||''''||FacturasMS.documento||''''||', '||''''||FacturasMS.fecha_vencimiento||''''||', '||FacturasMS.valor_saldo||')';
		EXECUTE sql_insert;

	END LOOP;

	FOR QryCasos IN select asesor::varchar, cliente::varchar, direccion::varchar, telefono::varchar, negocio::varchar, cuota::varchar, no_factura::varchar,fecha_vencimiento::date, corriente::numeric, "d0A30"::numeric, "d31A60"::numeric, "d61A90"::numeric, "d91A120"::numeric, "d121A180"::numeric, "d180A360"::numeric, "MAYORA1"::numeric from tem.temCarteraMicroDetallado LOOP
	    RETURN NEXT QryCasos;
	END LOOP;

	--RETURN PeriodoVencido;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_carteramicrocreditodetallado(character varying)
  OWNER TO postgres;
