-- Function: apicredit.sp_scoreformularioconsumo_new(integer)

-- DROP FUNCTION apicredit.sp_scoreformularioconsumo_new(integer);

CREATE OR REPLACE FUNCTION apicredit.sp_scoreformularioconsumo_new(_numero_solicitud integer)
  RETURNS text AS
$BODY$

DECLARE

	vble_mercado_edu record;
	RsPuntajes record;
	RsPresolicitudes record;
	RsSolAval record;
	RsCountSolAval record;
	RsSolPersona record;
	RsPersonaSol record;
	RsSolLaboral record;
	RsSolReferencias record;
	RsSolBienes record;
	RsSolEstudiante	record;
	RsSolActivEconom record;
	RsPreSol record;
	RsNegocioPropio varchar;

	PuntajeMax numeric := 0;
	SalarioMin numeric := 0;
	UndSalMin numeric := 0;
	BiienRaiz numeric := 0;
	ProporcionSemestre numeric := 0;

	buro numeric := 0;
	postscore numeric := 0;
	totalscore numeric := 0;

	respuesta varchar := '';
	_RtAccion varchar := '';
	ControlProceso varchar := 'R';
	CapEndeuda varchar := '0%';
	TiempoResidencia varchar := '';
	VarAntiguedadRes varchar := '';

	MoraDeudores  varchar := '';


BEGIN

	--update unidad_negocio set puntaje_maximo = 750, minimo = 535, maximo = 965, cutoff = 630
	select into RsPuntajes un.puntaje_maximo, un.minimo, un.maximo, un.cutoff, un.cutoff_total
	from rel_unidadnegocio_convenios ruc
	inner join unidad_negocio un on ruc.id_unid_negocio = un.id
	where ruc.id_convenio = (select id_convenio from apicredit.pre_solicitudes_creditos where numero_solicitud = _numero_solicitud )
	and ref_4 != '';

	if ( RsPuntajes is not null ) then

		PuntajeMax = RsPuntajes.puntaje_maximo;
		raise notice 'CONSTANTE: %', PuntajeMax;

		select into RsPresolicitudes *
		from apicredit.pre_solicitudes_creditos
		where numero_solicitud = _numero_solicitud;

		raise notice 'RsPresolicitudes: %', RsPresolicitudes;
		raise notice 'CONDICION: %', ( RsPresolicitudes is not null );

		--if ( RsPresolicitudes is not null ) then

			FOR vble_mercado_edu IN

				select * from administrativo.variable_mercado_autoscore_consumo order by id
			LOOP
				--SABER SI TIENE NEGOCIO PROPIO
				select into RsNegocioPropio negocio_propio
				FROM apicredit.tab_cons_solicitud_laboral
				where numero_solicitud = _numero_solicitud;

				--SOLICITUD AVAL
				select into RsSolAval *
				from solicitud_aval
				where numero_solicitud = _numero_solicitud;

				--SOLICITUD PERSONA ESTUDIANTE
				select into RsSolPersona *, (select round((now()::date - fecha_nacimiento::date)::numeric/365)) as edad
				from solicitud_persona
				where numero_solicitud = _numero_solicitud and tipo = 'S';

				--SOLICITUD PERSONA SOLICITANTE
				select into RsPersonaSol *, (select round((now()::date - fecha_nacimiento::date)::numeric/365)) as edad
				from solicitud_persona
				where numero_solicitud = _numero_solicitud and tipo = 'S';

				--SOLICITUD LABORAL
				select into RsSolLaboral *, (select round((now()::date - fecha_ingreso::date)::numeric/365)) as antiguedad_laboral
				from solicitud_laboral
				where numero_solicitud = _numero_solicitud;

				--SOLICITUD REFERENCIAS
				select into RsSolReferencias *
				from solicitud_referencias
				where numero_solicitud = _numero_solicitud;

				--SOLICITUD BIENES
				select into RsSolBienes *
				from solicitud_bienes
				where numero_solicitud = _numero_solicitud;

				--SOLICITUD ESTUDIANTE
				select into RsSolEstudiante *
				from solicitud_estudiante
				where numero_solicitud = _numero_solicitud;

				--SOLICITUD ACTIVIDAD ECONOMICA
				select into RsSolActivEconom *
				from solicitud_actividad_economica
				where numero_solicitud = _numero_solicitud;

				select into RsCountSolAval count(0) as cuenta from solicitud_aval where numero_solicitud = _numero_solicitud;

				if ( RsCountSolAval.cuenta > 0 ) then

					ControlProceso = 'P';

					if ( vble_mercado_edu.id = 1 ) then

						raise notice 'item_variable: %, - variable_mercado_consumo: %', vble_mercado_edu.id, vble_mercado_edu.variable_buro;
						raise notice 'Edad Es: %',RsSolPersona.edad;

						if ( RsSolPersona.edad <= 25 ) then

							PuntajeMax = PuntajeMax - 20;
							raise notice 'Resta:20, PuntajeMax: %', PuntajeMax;

						elsif ( RsSolPersona.edad >= 46 and RsSolPersona.edad <= 50 ) then

							PuntajeMax = PuntajeMax + 35;
							raise notice 'Suma:35, PuntajeMax: %', PuntajeMax;

						elsif (RsSolPersona.edad >= 51 ) then

							PuntajeMax = PuntajeMax + 45;
							raise notice 'Suma:45, PuntajeMax: %', PuntajeMax;


						end if;

						raise notice '..::---------::..';
					end if;

					if ( vble_mercado_edu.id = 2 ) then

						raise notice 'item_variable: %, - variable_mercado_consumo: %', vble_mercado_edu.id, vble_mercado_edu.variable_buro;
						raise notice 'EstadoCivil Es: %',RsSolPersona.estado_civil;

						if ( RsSolPersona.estado_civil = 'C' ) then

							PuntajeMax = PuntajeMax + 30;
							raise notice 'Suma:30, PuntajeMax: %', PuntajeMax;

						elsif ( RsSolPersona.estado_civil = 'V' )then

							PuntajeMax = PuntajeMax + 30;
							raise notice 'Suma:30, PuntajeMax: %', PuntajeMax;

						elsif ( RsSolPersona.estado_civil = 'S' )then

							PuntajeMax = PuntajeMax - 25;
							raise notice 'Resta:25, PuntajeMax: %', PuntajeMax;

						elsif ( RsSolPersona.estado_civil = 'E' )then

							PuntajeMax = PuntajeMax - 20;
							raise notice 'Resta:20, PuntajeMax: %', PuntajeMax;

						end if;

						raise notice '..::---------::..';
					end if;

					if ( vble_mercado_edu.id = 3 ) then

						raise notice 'item_variable: %, - variable_mercado_consumo: %', vble_mercado_edu.id, vble_mercado_edu.variable_buro;
						raise notice 'NivelEstudio Es: %',RsSolPersona.nivel_estudio;

						if (RsSolPersona.nivel_estudio in ('UNIVERSITARIO','PROFESIONAL')) then

							PuntajeMax = PuntajeMax + 45;
							raise notice 'Suma:45, PuntajeMax: %', PuntajeMax;

						end if;

						raise notice '..::---------::..';
					end if;

					if ( vble_mercado_edu.id = 4 ) then

						raise notice 'item_variable: %, - variable_mercado_consumo: %', vble_mercado_edu.id, vble_mercado_edu.variable_buro;
						raise notice 'ActividadEconomica Es: %',RsSolLaboral.actividad_economica;

						if (RsSolLaboral.actividad_economica in ('INDNFO','PROIN')) then

							PuntajeMax = PuntajeMax - 40;
							raise notice 'Resta:40, PuntajeMax: %', PuntajeMax;

						elsif (RsSolLaboral.actividad_economica in ('PENSI')) then

							PuntajeMax = PuntajeMax + 40;
							raise notice 'Suma:40, PuntajeMax: %', PuntajeMax;

						end if;

						raise notice '..::---------::..';
					end if;

					if ( vble_mercado_edu.id = 5 ) then

						raise notice 'item_variable: %, - variable_mercado_consumo: %', vble_mercado_edu.id, vble_mercado_edu.variable_buro;
						raise notice 'PersonasCargo Es: %',RsSolPersona.personas_a_cargo;

						if (RsSolPersona.personas_a_cargo=0 and RsSolLaboral.actividad_economica in ('INDNFO','PROIN')) then

							PuntajeMax = PuntajeMax + 15;
							raise notice 'Suma:15, PuntajeMax: %', PuntajeMax;

						end if;

						raise notice '..::---------::..';

					end if;

					if ( vble_mercado_edu.id = 6 ) then

						raise notice 'item_variable: %, - variable_mercado_consumo: %', vble_mercado_edu.id, vble_mercado_edu.variable_buro;
						raise notice 'TipoVivienda Es: %',RsPersonaSol.tipo_vivienda;

						if ( RsPersonaSol.tipo_vivienda = '01') then
							PuntajeMax = PuntajeMax + 30;
							raise notice 'Suma:30, PuntajeMax: %', PuntajeMax;
						end if;

						raise notice '..::---------::..';
					end if;

					if ( vble_mercado_edu.id = 7 ) then

						raise notice 'item_variable: %, - variable_mercado_consumo: %', vble_mercado_edu.id, vble_mercado_edu.variable_buro;
						raise notice 'TipoVivienda Es: %; Genero es: %',RsPersonaSol.tipo_vivienda, RsPersonaSol.genero;

						if ( RsPersonaSol.tipo_vivienda = '01' and RsPersonaSol.genero='F' ) then
							PuntajeMax = PuntajeMax + 15;
							raise notice 'Suma:15, PuntajeMax: %', PuntajeMax;

						elsif ( RsPersonaSol.tipo_vivienda = '02' and RsPersonaSol.genero='M' ) then
							PuntajeMax = PuntajeMax - 25;
							raise notice 'Resta:25, PuntajeMax: %', PuntajeMax;
						end if;

						raise notice '..::---------::..';
					end if;

					if ( vble_mercado_edu.id = 8 ) then

						raise notice 'item_variable: %, - variable_mercado_consumo: %', vble_mercado_edu.id, vble_mercado_edu.variable_buro;

						VarAntiguedadRes = case when RsPersonaSol.tiempo_residencia = '' then '0 Años' else RsPersonaSol.tiempo_residencia end;
						TiempoResidencia = substring(VarAntiguedadRes,1,position(' ' in VarAntiguedadRes));
						raise notice 'TiempoResidencia Es: %',TiempoResidencia;

						if ( TiempoResidencia::numeric <= 0 ) then
							PuntajeMax = PuntajeMax - 10;
							raise notice 'Resta:10, PuntajeMax: %', PuntajeMax;

						elsif ( TiempoResidencia::numeric >= 5 ) then
							PuntajeMax = PuntajeMax + 20;
							raise notice 'Suma:20, PuntajeMax: %', PuntajeMax;
						end if;

						raise notice '..::---------::..';
					end if;

					if ( vble_mercado_edu.id = 9 ) then

						raise notice 'item_variable: %, - variable_mercado_consumo: %', vble_mercado_edu.id, vble_mercado_edu.variable_buro;
						raise notice 'AntiguedadLaboral Es: %',RsSolLaboral.antiguedad_laboral;

						if ( RsSolLaboral.antiguedad_laboral <= 2 ) then
							PuntajeMax = PuntajeMax - 35;
							raise notice 'Resta:35, PuntajeMax: %', PuntajeMax;

							elsif ( RsSolLaboral.antiguedad_laboral >= 5 ) then
							PuntajeMax = PuntajeMax + 35;
							raise notice 'Suma:35, PuntajeMax: %', PuntajeMax;
						end if;

						raise notice '..::---------::..';
					end if;

					--
					if ( vble_mercado_edu.id = 10 ) then

						raise notice 'item_variable: %, - variable_mercado_consumo: %', vble_mercado_edu.id, vble_mercado_edu.variable_buro;
						raise notice 'TipoContrato Es: %',RsSolLaboral.tipo_contrato;

						if ( RsSolLaboral.tipo_contrato = 'INDEFINIDO' ) then

							PuntajeMax = PuntajeMax + 15;
							raise notice 'Suma:15, PuntajeMax: %', PuntajeMax;

						end if;

						raise notice '..::---------::..';
					end if;

					if (RsSolLaboral.actividad_economica in ('INDNFO','PROIN')) then --EMLEADOS INDEPENDIENTES


						if ( vble_mercado_edu.id = 11 ) then

							raise notice 'item_variable: %, - variable_mercado_consumo: %', vble_mercado_edu.id, vble_mercado_edu.variable_buro;
							raise notice 'antiguedad_laboral Es: %',RsSolLaboral.antiguedad_laboral;

							if ( RsSolLaboral.antiguedad_laboral < 2 ) then
								PuntajeMax = PuntajeMax - 10;
								raise notice 'Resta:10, PuntajeMax: %', PuntajeMax;

							elsif ( RsSolLaboral.antiguedad_laboral >= 5 and RsSolLaboral.antiguedad_laboral <= 10) then
								PuntajeMax = PuntajeMax + 15;
								raise notice 'Suma:15, PuntajeMax: %', PuntajeMax;

							elsif ( RsSolLaboral.antiguedad_laboral >10) then
								PuntajeMax = PuntajeMax + 25;
								raise notice 'Suma:25, PuntajeMax: %', PuntajeMax;

							end if;

							raise notice '..::---------::..';
						end if;

						if ( vble_mercado_edu.id = 12 ) then

							raise notice 'item_variable: %, - variable_mercado_consumo: %', vble_mercado_edu.id, vble_mercado_edu.variable_buro;
							raise notice 'RsNegocioPropio Es: %',RsNegocioPropio;

							if ( RsNegocioPropio = 'S' ) then
								PuntajeMax = PuntajeMax + 10;
								raise notice 'Suma:10, PuntajeMax: %', PuntajeMax;

							end if;

							raise notice '..::---------::..';
						end if;

					end if;

					if ( vble_mercado_edu.id = 13 ) then

						raise notice 'item_variable: %, - variable_mercado_consumo: %', vble_mercado_edu.id, vble_mercado_edu.variable_buro;

						select into SalarioMin salario_minimo_mensual from salario_minimo where ano = substring(now()::date,1,4);
						UndSalMin = RsSolLaboral.salario/SalarioMin;
						raise notice 'UndSalMin Es: %',UndSalMin;

						if ( UndSalMin >= 5 ) then

							PuntajeMax = PuntajeMax + 10;
							raise notice 'Suma:10, PuntajeMax: %', PuntajeMax;

						end if;

						raise notice '..::---------::..';
					end if;

				else
					ControlProceso = 'R';
					--PuntajeMax = 0;

				end if;

			END LOOP;

			select into RsPreSol * from apicredit.pre_solicitudes_creditos where numero_solicitud = _numero_solicitud;

			if ( RsPreSol.score > 0 ) then
				buro = RsPreSol.score * 0.4;
			end if;

			if ( PuntajeMax > 0 ) then
				postscore = PuntajeMax * 0.6;
			end if;

			totalscore = buro + postscore;

			raise notice 'buro: %, postscore: %, ControlProceso: %', RsPreSol.score, PuntajeMax, ControlProceso;
			raise notice 'cutoff: %, buro_porc: %, postscore_porc: %, totalscore: % ', RsPuntajes.cutoff, buro, postscore, totalscore;

			--CAMBIO
			select into CapEndeuda apicredit.SP_CapacidadEndeudamiento(_numero_solicitud);
			UPDATE solicitud_aval SET score_buro = RsPreSol.score, score_lisim = PuntajeMax, score_total = totalscore, capacidad_endeudamiento = CapEndeuda, accion_sugerida = 'APROBAR' WHERE numero_solicitud = _numero_solicitud;


			if ( ControlProceso = 'P' and totalscore > RsPuntajes.cutoff_total ) then

				select into CapEndeuda apicredit.SP_CapacidadEndeudamiento(_numero_solicitud);
				UPDATE solicitud_aval SET score_buro = RsPreSol.score, score_lisim = PuntajeMax, score_total = totalscore, capacidad_endeudamiento = CapEndeuda, accion_sugerida = 'APROBAR' WHERE numero_solicitud = _numero_solicitud;
				raise notice 'ACTUALIZA POSITIVO';

			elsif ( ControlProceso = 'P' and totalscore < RsPuntajes.cutoff_total ) then

				UPDATE solicitud_aval SET score_buro = RsPreSol.score, score_lisim = PuntajeMax, score_total = totalscore, capacidad_endeudamiento = CapEndeuda, accion_sugerida = 'RECHAZAR' WHERE numero_solicitud = _numero_solicitud;
				raise notice 'ACTUALIZA NEGATIVO';

			elsif ( ControlProceso = 'R' ) then

				UPDATE solicitud_aval SET score_buro = RsPreSol.score, score_lisim = 0, score_total = 0, capacidad_endeudamiento = '0%', accion_sugerida = 'RECHAZADO - NO CORRIO EL MODELO DE AUTOSCORE' WHERE numero_solicitud = _numero_solicitud;
				raise notice 'ACTUALIZA NEGATIVO';

			end if;

			--update solicitud_laboral set actividad_economica = ocupacion where numero_solicitud = _numero_solicitud;

			respuesta = totalscore;
			raise notice 'totalscore: %', totalscore;

			--MoraDeudores := apicredit.SP_RelDeudorCodeudor(_numero_solicitud, RsPresolicitudes.identificacion);
			--raise notice 'MoraDeudores: %', MoraDeudores;

		--end if;

	end if;



	return respuesta;

end;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION apicredit.sp_scoreformularioconsumo_new(integer)
  OWNER TO postgres;
