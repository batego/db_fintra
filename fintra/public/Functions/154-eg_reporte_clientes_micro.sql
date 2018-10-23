-- Function: eg_reporte_clientes_micro(numeric, date, character varying)

-- DROP FUNCTION eg_reporte_clientes_micro(numeric, date, character varying);

CREATE OR REPLACE FUNCTION eg_reporte_clientes_micro(peridofoto numeric, fechacorte date, unidadnegocio character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE

	recordClientes record;
	misDias numeric :=0;

BEGIN

	FOR recordClientes IN

		SELECT
			periodo_lote::numeric,
			foto.codcli::varchar,
			cl.nit AS cedula,
			cl.nomcli as nombre,
			cl.direccion,
			cl.telefono,
			(select nomciu from ciudad where codciu=cl.ciudad) as ciudad,
			negasoc::varchar,
			sa.valor_producto::numeric,
			sa.asesor::varchar,
			sa.id_convenio::numeric,

			(
			SELECT
				CASE WHEN maxdia >= 365 THEN '8- MAYOR A 1 ANIO'
				     WHEN maxdia >= 181 THEN '7- ENTRE 180 Y 360'
				     WHEN maxdia >= 121 THEN '6- ENTRE 121 Y 180'
				     WHEN maxdia >= 91 THEN '5- ENTRE 91 Y 120'
				     WHEN maxdia >= 61 THEN '4- ENTRE 61 Y 90'
				     WHEN maxdia >= 31 THEN '3- ENTRE 31 Y 60'
				     WHEN maxdia >= 1 THEN '2- 1 A 30'
				     WHEN maxdia <= 0 THEN '1- CORRIENTE'
					ELSE '0' END AS rango
			FROM (
				 SELECT max(fechaCorte-(fra.fecha_vencimiento)) as maxdia
				 FROM con.foto_cartera fra
				 WHERE fra.dstrct = 'FINV'
					  AND fra.valor_saldo > 0
					  AND fra.reg_status = ''
					  AND fra.negasoc = foto.negasoc
					  AND fra.tipo_documento in ('FAC','NDC')
					  AND substring(fra.documento,1,2) not in ('CP','FF','DF')
					  AND fra.periodo_lote = peridoFoto
				 GROUP BY negasoc

			) tabla2 )::varchar as vencimiento_mayor,
			sum(valor_saldo)::numeric as valor_saldo,
			0::numeric as dias_vencidos,
			round((((SELECT sum(valor) FROM documentos_neg_aceptado  where cod_neg=negasoc) - sum(valor_saldo)) / (SELECT sum(valor) FROM documentos_neg_aceptado  where cod_neg=negasoc))*100)::numeric as porcentaje
		FROM con.foto_cartera as foto
		INNER JOIN solicitud_aval AS sa on (sa.cod_neg =foto.negasoc and foto.id_convenio=sa.id_convenio)
		LEFT JOIN cliente cl ON (cl.nit = foto.nit)
		WHERE 	periodo_lote=peridoFoto
			AND foto.id_convenio IN (SELECT id_convenio FROM rel_unidadnegocio_convenios WHERE id_unid_negocio =unidadNegocio::numeric)
			AND foto.valor_saldo > 0
			AND foto.reg_status = ''
			AND foto.dstrct='FINV'
			AND tipo_documento in ('NDC','FAC')
			AND sa.estado_sol ='T'
			AND sa.dstrct='FINV'
			AND sa.reg_status = ''
		GROUP BY foto.codcli,cl.nit,nombre,cl.direccion,cl.telefono,cl.ciudad,negasoc,sa.valor_producto,sa.asesor,sa.id_convenio,periodo_lote
		ORDER BY negasoc

	LOOP

		SELECT INTO misDias MAX((fecha_ultimo_pago-fecha_vencimiento)) as diferencia_dias
		FROM con.factura
		WHERE negasoc=recordClientes.negasoc
		AND reg_status=''
		AND replace(substring(fecha_vencimiento,1,7),'-','')::numeric < peridoFoto;

		raise notice 'Dias: % negocio: %',misDias,recordClientes.negasoc;

		recordClientes.dias_vencidos:=misDias;

		RETURN NEXT  recordClientes;

	END LOOP;


END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_reporte_clientes_micro(numeric, date, character varying)
  OWNER TO postgres;
