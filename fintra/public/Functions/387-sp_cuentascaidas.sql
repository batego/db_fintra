-- Function: sp_cuentascaidas(character varying, character varying)

-- DROP FUNCTION sp_cuentascaidas(character varying, character varying);

CREATE OR REPLACE FUNCTION sp_cuentascaidas(periodoasignacion character varying, unidadnegocio character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE
PeriodoTramo varchar;
TramoAnterior varchar;
Cuentas record;
Recaudos record;
venc_mayor_anterior varchar;
venc_mayor_actual varchar;
Cuentas_caidas record;
FechaCortePeriodo varchar;
FechaCortePeriodoAnt varchar;

BEGIN
	DELETE FROM tem.cuentas_caidas_temp;

	if ( substring(PeriodoAsignacion,5) = '01' ) then
		PeriodoTramo = substring(PeriodoAsignacion,1,4)::numeric-1||'12';
		TramoAnterior = substring(PeriodoAsignacion,1,4)::numeric-1||'11';
	elsif ( substring(PeriodoAsignacion,5) = '02' ) then
		PeriodoTramo = PeriodoAsignacion::numeric - 1;
		TramoAnterior = substring(PeriodoAsignacion,1,4)::numeric-1||'12';
	else
		PeriodoTramo = PeriodoAsignacion::numeric - 1;
		TramoAnterior = PeriodoAsignacion::numeric - 1;
	end if;

	RAISE NOTICE 'PeriodoTramo: % TramoAnterior: %',PeriodoTramo,TramoAnterior;

	select into FechaCortePeriodo to_char(to_timestamp(substring(PeriodoTramo,1,4)::numeric || '-' || to_char(substring(PeriodoTramo,5,2)::numeric,'FM00') || '-01', 'YYYY-MM-DD') + INTERVAL '1 month' - INTERVAL '1 days', 'YYYY-MM-DD');
	select into FechaCortePeriodoAnt to_char(to_timestamp(substring(TramoAnterior,1,4)::numeric || '-' || to_char(substring(TramoAnterior,5,2)::numeric,'FM00') || '-01', 'YYYY-MM-DD') + INTERVAL '1 month' - INTERVAL '1 days', 'YYYY-MM-DD');

	raise notice 'FechaCortePeriodo: % FechaCortePeriodoAnt: %',FechaCortePeriodo,FechaCortePeriodoAnt;

	FOR Cuentas IN
		SELECT
			fc.negasoc,
			''::varchar as venc_mayor_ant,
			0::numeric as num_caidas,
			sum(fc.valor_saldo)::numeric as valor_debido,
			0::numeric as valor_recaudo,
			0::numeric as recaudo_aplicado,
			fc.valor_factura::numeric as valor_cuota
		FROM con.foto_cartera fc, negocios n
		WHERE fc.negasoc = n.cod_neg  and fc.dstrct = n.dist
			and fc.reg_status = ''
			and fc.valor_saldo > 0
			and fc.dstrct = 'FINV'
			and fc.tipo_documento in ('FAC','NDC')
			and substring(fc.documento,1,2) not in ('CP','FF','DF')
			and fc.periodo_lote = PeriodoAsignacion
			--and fc.negasoc in ('FA13527','FA13131','FA06251','FA12640')
			and n.id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio = unidadnegocio)
			and replace(substring(fc.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoAsignacion::numeric
		GROUP BY fc.negasoc,fc.valor_factura


	LOOP

		SELECT INTO venc_mayor_actual (
					SELECT
						CASE WHEN maxdia >= 365 THEN '8- MAYOR A 1 AÑO'
						     WHEN maxdia >= 181 THEN '7- ENTRE 181 Y 365'
						     WHEN maxdia >= 121 THEN '6- ENTRE 121 Y 180'
						     WHEN maxdia >= 91 THEN '5- ENTRE 91 Y 120'
						     WHEN maxdia >= 61 THEN '4- ENTRE 61 Y 90'
						     WHEN maxdia >= 31 THEN '3- ENTRE 31 Y 60'
						     WHEN maxdia >= 1 THEN '2- 1 A 30'
						     WHEN maxdia <= 0 THEN '1- CORRIENTE'
							ELSE '0' END AS rango
					FROM (
						 SELECT max(FechaCortePeriodo::date-(fecha_vencimiento)) as maxdia
						 FROM con.foto_cartera fra
						 WHERE fra.dstrct = 'FINV'
							  AND fra.valor_saldo > 0
							  AND fra.reg_status = ''
							  AND fra.negasoc = Cuentas.negasoc
							  AND fra.tipo_documento in ('FAC','NDC')
							  AND substring(fra.documento,1,2) not in ('CP','FF','DF')
							  AND fra.periodo_lote = PeriodoAsignacion
						 GROUP BY negasoc

					) tabla2
					) as vencimiento;

		Cuentas.venc_mayor_ant = venc_mayor_actual;

		RAISE NOTICE 'NEGOCIO: %, VENC: %, num_caidas: %',Cuentas.negasoc,Cuentas.venc_mayor_ant,Cuentas.num_caidas;

		SELECT INTO Recaudos * FROM sp_recaudototalnegocio (Cuentas.negasoc,PeriodoAsignacion) as pg (valor_pagos numeric, valor_sanciones numeric);
		Cuentas.valor_recaudo = Recaudos.valor_pagos;
		Cuentas.recaudo_aplicado = Recaudos.valor_sanciones + Recaudos.valor_pagos;

		IF(Cuentas.valor_recaudo < (Cuentas.valor_debido * 0.95)) THEN
			insert into tem.cuentas_caidas_temp (negocio,periodo,vencimiento_mayor,valor_recaudo,recaudo_aplicado,valor_cuota) values (Cuentas.negasoc,PeriodoAsignacion,Cuentas.venc_mayor_ant,Cuentas.valor_recaudo,Cuentas.recaudo_aplicado,Cuentas.valor_cuota);
			Cuentas.num_caidas=1;
		END IF;

		RETURN NEXT Cuentas;

	END LOOP;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_cuentascaidas(character varying, character varying)
  OWNER TO postgres;
