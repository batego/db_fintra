-- Function: apicredit.sp_reldeudorcodeudor(integer, character varying)

-- DROP FUNCTION apicredit.sp_reldeudorcodeudor(integer, character varying);

CREATE OR REPLACE FUNCTION apicredit.sp_reldeudorcodeudor(_numerosolicitudnew integer, _identificacion character varying)
  RETURNS text AS
$BODY$

DECLARE

	respuesta varchar := 'R';
	_IdentSolPer varchar := '';

	DiasMoraDeudorActual varchar := '';
	ResultadoDeudorActual varchar := '';
	AlturaMoraDeudorActual varchar := '';

	DiasMoraDeudorHistorico varchar := '';
	ResultadoDeudorHistorico varchar := '';
	AlturaMoraDeudorHistorico varchar := '';

	DiasMoraCodeudorActual varchar := '';
	ResultadoCodeudorActual varchar := '';
	AlturaMoraCodeudorActual varchar := '';

	DiasMoraCodeudorHistorico varchar := '';
	ResultadoCodeudorHistorico varchar := '';
	AlturaMoraCodeudorHistorico varchar := '';

	_NumSol integer := 0;
	_SolPersona integer := 0;

	_TotalCuotasCanceladas numeric;
	_TotalCuotasEnMora numeric;
	_TotalCuotasVigentes numeric;

	fecha_hoy date;

BEGIN

	fecha_hoy = now()::date;

	select into _NumSol coalesce(max(numero_solicitud),0) from solicitud_persona where identificacion = _identificacion and numero_solicitud != _NumeroSolicitudNew;

	if ( _NumSol != 0 ) then

		--select identificacion, * from solicitud_persona where numero_solicitud = _NumSol and tipo = 'C';

		select into _IdentSolPer identificacion from solicitud_persona where numero_solicitud = _NumSol and tipo = 'S';
		raise notice 'Identificacion: %', _IdentSolPer;

		if ( _IdentSolPer != '' ) then

			DiasMoraDeudorActual := coalesce((SELECT   max( sp_fecha_corte_foto(substring(now()::date,1,4),substring(now()::date,6,2)::integer)::date - fecha_vencimiento )::varchar as maxdia
						FROM con.factura fra
						WHERE fra.dstrct = 'FINV'
						AND fra.reg_status = ''
						AND fra.negasoc != ''
						AND fra.nit = _IdentSolPer
						AND fra.tipo_documento in ('FAC','NDC')
						AND substring(fra.documento,1,2) not in ('CP','FF','DF')),'0');


			SELECT INTO AlturaMoraDeudorActual
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
				SELECT max( sp_fecha_corte_foto(substring(now()::date,1,4),substring(now()::date,6,2)::integer)::date - fecha_vencimiento )::numeric as maxdia
				FROM con.factura fra
				WHERE fra.dstrct = 'FINV'
				AND fra.reg_status = ''
				AND fra.negasoc != ''
				AND fra.nit = _IdentSolPer
				AND fra.tipo_documento in ('FAC','NDC')
				AND substring(fra.documento,1,2) not in ('CP','FF','DF')
				AND fra.valor_saldo > 0
			) tabla2;

			if ( AlturaMoraDeudorActual != '' ) then

				ResultadoDeudorActual = AlturaMoraDeudorActual || ' ('||DiasMoraDeudorActual||')';
				raise notice 'Identificacion: %, ResultadoDeudorActual: %', _IdentSolPer, ResultadoDeudorActual;
			end if;

			-------------------------------------------------------------------------------------------------------------------

			DiasMoraDeudorHistorico = coalesce(eg_altura_mora_periodo(_IdentSolPer,201412,4,0),'0');

			SELECT INTO AlturaMoraDeudorHistorico
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
				select eg_altura_mora_periodo(_IdentSolPer,201412,4,0)::numeric as maxdia

			) tabla2;

			ResultadoDeudorHistorico = AlturaMoraDeudorActual || ' ('||DiasMoraDeudorHistorico||')';
			raise notice 'Identificacion: %, ResultadoDeudorHistorico: %', _IdentSolPer, ResultadoDeudorHistorico;

			respuesta = ResultadoDeudorActual;

		end if;

		SELECT INTO _TotalCuotasEnMora count(0) as CtasEnMora from con.factura where reg_status = '' and dstrct = 'FINV' and tipo_documento in ('FAC','NDC') and negasoc = (select cod_neg from solicitud_aval where numero_solicitud = _NumSol) and valor_saldo = 0 and fecha_vencimiento <= fecha_hoy and substring(documento,1,2) not in ('CP','FF','DF') and descripcion not in ('CXC AVAL','CXC_INTERES_FA','CXC_CAT_MC','CXC_INTERES_MC');
		SELECT INTO _TotalCuotasVigentes count(0) as CtasVigentes from con.factura where reg_status = '' and dstrct = 'FINV' and tipo_documento in ('FAC','NDC') and negasoc = (select cod_neg from solicitud_aval where numero_solicitud = _NumSol) and substring(documento,1,2) not in ('CP','FF','DF') and descripcion not in ('CXC AVAL','CXC_INTERES_FA','CXC_CAT_MC','CXC_INTERES_MC');

		UPDATE solicitud_aval
		SET
			cuotas_pendientes = _TotalCuotasEnMora::varchar||'/'||_TotalCuotasVigentes::varchar,
			altura_mora_actual_titular = ResultadoDeudorActual,
			altura_mora_history_titular= ResultadoDeudorHistorico,
			altura_mora_actual_codeudor='PRIMERA VEZ',
			altura_mora_history_codeudor='PRIMERA VEZ'
		WHERE numero_solicitud = _NumeroSolicitudNew;

		--select into _IdentSolPer identificacion from solicitud_persona where numero_solicitud = _NumSol and tipo in ('E','C');
		--raise notice 'Identificacion: %', _IdentSolPer;

	else
		respuesta = 'NOHAY';
		UPDATE solicitud_aval
		SET
			cuotas_pendientes = '0/0',
			altura_mora_actual_titular = 'PRIMERA VEZ',
			altura_mora_history_titular= 'PRIMERA VEZ',
			altura_mora_actual_codeudor='PRIMERA VEZ',
			altura_mora_history_codeudor='PRIMERA VEZ'
		WHERE numero_solicitud = _NumeroSolicitudNew;
	end if;

	--Buscar el

	return respuesta;


end;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION apicredit.sp_reldeudorcodeudor(integer, character varying)
  OWNER TO postgres;
