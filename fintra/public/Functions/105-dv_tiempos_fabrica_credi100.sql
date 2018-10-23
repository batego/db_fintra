-- Function: dv_tiempos_fabrica_credi100()

-- DROP FUNCTION dv_tiempos_fabrica_credi100();

CREATE OR REPLACE FUNCTION dv_tiempos_fabrica_credi100()
  RETURNS SETOF record AS
$BODY$

DECLARE

	dias integer;
	festivos integer;
	fecha1 date;
	fecha2 date;
	diferencia varchar;


	NegociosTiempos record;

BEGIN

	FOR NegociosTiempos IN

			SELECT
			  case when get_nombc(cod_cli) is null then
			    sp.nombre::varchar else
			    get_nombc(cod_cli)::varchar end as nombre_cliente,
			cod_cli::varchar as cedula_cliente,
			sp_uneg_negocio_name(n.cod_neg)::varchar AS linea,
			n.cod_neg::varchar as negocio,
			n.periodo::varchar as periodo_neg,
			pre.fecha_credito::date as fecha_presolicitud,
			--pt.fecha::date as fecha_standby_pre,
			--pt.causal::varchar as causal_stby_pre,
			''::varchar as fecha_radicacion,
			0::integer as dias_rad,
			''::varchar as fecha_referenciacion,
			0::integer as dias_ref,
			''::varchar as fecha_analisis,
			0::integer as dias_ana,
			''::varchar as fecha_decision,
			0::integer as dias_dec,
			''::varchar as fecha_formalizacion,
			0::integer as dias_for,
			''::varchar as fecha_desembolso,
			COALESCE(dv_dias_standby(n.cod_neg,'RAD','STANDBY','DEV_STANDBY')::integer,0) as dias_stby_rad,
			COALESCE(dv_causal_standby(n.cod_neg,'RAD','STANDBY')::varchar,'-') as causal_rad,
			COALESCE(dv_dias_standby(n.cod_neg,'REF','STANDBY','DEV_STANDBY')::integer,0) as dias_stby_ref,
			COALESCE(dv_causal_standby(n.cod_neg,'REF','STANDBY')::varchar,'-') as causal_ref,
			COALESCE(dv_dias_standby(n.cod_neg,'DEC','STANDBY','DEV_STANDBY')::integer,0) as dias_stby_dec,
			COALESCE(dv_causal_standby(n.cod_neg,'DEC','STANDBY')::varchar,'-') as causal_dec,
			COALESCE(dv_dias_standby(n.cod_neg,'FOR','STANDBY','DEV_STANDBY')::integer,0) as dias_stby_for,
			COALESCE(dv_causal_standby(n.cod_neg,'FOR','STANDBY')::varchar,'-') as causal_for,
			case
					when (n.actividad = 'LIQ') then 'RADICACION'
					when (n.actividad = 'RAD') then 'REFERENCIACION'
					when (n.actividad = 'REF') then 'ANALISIS'
					when (n.actividad = 'ANA') then 'DECISION'
					when (n.actividad = 'DEC') then 'FORMALIZACION'
					when (n.actividad = 'PFCC') then 'PERFECCION LIBRANZA'
					when (n.actividad = 'FOR') then 'TRANSFERENCIA'
					when (n.actividad = 'DES') then 'NEGOCIO DESEMBOLSADO'
					when (n.actividad = 'STBY') then 'STAND BY'
					END AS etapa_actual,
			get_est(estado_neg)::varchar as estado_neg,
			sa.plazo as plazo_inicial,
			sa.valor_solicitado
			FROM negocios n
			INNER JOIN solicitud_aval sa on (n.cod_neg=sa.cod_neg)
			INNER JOIN solicitud_persona sp on (sa.numero_solicitud=sp.numero_solicitud and sp.tipo='S')
			LEFT JOIN apicredit.pre_solicitudes_creditos pre on pre.numero_solicitud= sa.numero_solicitud
			--LEFT JOIN apicredit.pre_solicitudes_trazabilidad pt on pt.numero_solicitud= pre.numero_solicitud
			WHERE n.periodo >= '201801'  AND n.id_convenio IN (17,19,31,58,18,32,57)
			ORDER BY n.periodo, n.cod_neg
			limit 5


	LOOP

		IF(NegociosTiempos.fecha_presolicitud IS null) THEN
			NegociosTiempos.fecha_presolicitud= '0101-01-01';
		END IF;


		----RADICACION
		SELECT INTO NegociosTiempos.fecha_radicacion max(fecha)::date from negocios_trazabilidad where cod_neg= NegociosTiempos.negocio and actividad = 'RAD';
		SELECT INTO NegociosTiempos.fecha_referenciacion max(fecha)::date from negocios_trazabilidad where cod_neg= NegociosTiempos.negocio and actividad = 'REF';

		dias:=	COALESCE((NegociosTiempos.fecha_referenciacion::date - NegociosTiempos.fecha_radicacion::date),0);
		festivos:= 	(select count(*) 	from fin.dias_festivos 	where festivo = true 	AND fecha between NegociosTiempos.fecha_radicacion  AND NegociosTiempos.fecha_referenciacion);
		NegociosTiempos.dias_rad:= dias - festivos;
		--raise notice 'fecha1: Rad%', NegociosTiempos.fecha_radicacion;
		--raise notice 'fecha2: Rad%', NegociosTiempos.fecha_referenciacion;



		----REFERENCIACION
		SELECT INTO NegociosTiempos.fecha_referenciacion max(fecha)::date from negocios_trazabilidad where cod_neg= NegociosTiempos.negocio and actividad = 'REF';
		SELECT INTO NegociosTiempos.fecha_analisis max(fecha)::date from negocios_trazabilidad where cod_neg= NegociosTiempos.negocio and actividad = 'ANA';

		dias:=	COALESCE((NegociosTiempos.fecha_analisis::date	- NegociosTiempos.fecha_referenciacion::date),0);
		festivos:= 	(select count(*) 	from fin.dias_festivos 	where festivo = true 	AND fecha between NegociosTiempos.fecha_referenciacion  AND NegociosTiempos.fecha_analisis);
		NegociosTiempos.dias_ref:= dias - festivos;
		--raise notice 'fecha1: Ref%', NegociosTiempos.fecha_referenciacion;
		--raise notice 'fecha2: Ref%', NegociosTiempos.fecha_analisis;

		----ANALISIS
		SELECT INTO NegociosTiempos.fecha_analisis max(fecha)::date from negocios_trazabilidad where cod_neg= NegociosTiempos.negocio and actividad = 'ANA';
		SELECT INTO NegociosTiempos.fecha_decision max(fecha)::date from negocios_trazabilidad where cod_neg= NegociosTiempos.negocio and actividad = 'DEC';

		dias:=	COALESCE((NegociosTiempos.fecha_decision::date	- NegociosTiempos.fecha_analisis::date),0);
		festivos:= 	(select count(*) 	from fin.dias_festivos 	where festivo = true 	AND fecha between NegociosTiempos.fecha_analisis  AND NegociosTiempos.fecha_decision);
		NegociosTiempos.dias_ana:= dias - festivos;
		--raise notice 'fecha1: Ana%', NegociosTiempos.fecha_analisis;
		--raise notice 'fecha2: Ana%', NegociosTiempos.fecha_decision;

		----DECISION
		SELECT INTO NegociosTiempos.fecha_decision max(fecha)::date from negocios_trazabilidad where cod_neg= NegociosTiempos.negocio and actividad = 'DEC';
		SELECT INTO NegociosTiempos.fecha_formalizacion max(fecha)::date from negocios_trazabilidad where cod_neg= NegociosTiempos.negocio and actividad = 'FOR';

		dias:=	COALESCE((NegociosTiempos.fecha_formalizacion::date	- NegociosTiempos.fecha_decision::date),0);
		festivos:= 	(select count(*) 	from fin.dias_festivos 	where festivo = true 	AND fecha between NegociosTiempos.fecha_decision  AND NegociosTiempos.fecha_formalizacion);
		NegociosTiempos.dias_dec:= dias - festivos;
		--raise notice 'fecha1: Dec%', NegociosTiempos.fecha_decision;
		--raise notice 'fecha2: Dec%', NegociosTiempos.fecha_formalizacion;

		----FORMALIZACION
		SELECT INTO NegociosTiempos.fecha_formalizacion max(fecha)::date from negocios_trazabilidad where cod_neg= NegociosTiempos.negocio and actividad = 'FOR';
		SELECT INTO NegociosTiempos.fecha_desembolso max(fecha)::date from negocios_trazabilidad where cod_neg= NegociosTiempos.negocio and actividad = 'DES';

		dias:=	COALESCE((NegociosTiempos.fecha_desembolso::date	- NegociosTiempos.fecha_formalizacion::date),0);
		festivos:= 	(select count(*) 	from fin.dias_festivos 	where festivo = true 	AND fecha between NegociosTiempos.fecha_formalizacion  AND NegociosTiempos.fecha_desembolso);
		NegociosTiempos.dias_for:= dias - festivos;
		--raise notice 'fecha1: For%', NegociosTiempos.fecha_formalizacion;
		--raise notice 'fecha2: For%', NegociosTiempos.fecha_desembolso;

		----DESEMBOLSO
		NegociosTiempos.fecha_desembolso:=COALESCE((SELECT max(fecha)::date from negocios_trazabilidad where cod_neg= NegociosTiempos.negocio and actividad = 'DES'),'0101-01-01') as fecha_desembolso;
		--raise notice 'Desembolso:%', NegociosTiempos.fecha_desembolso;




	RETURN  next NegociosTiempos;



	END LOOP;




END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION dv_tiempos_fabrica_credi100()
  OWNER TO postgres;
