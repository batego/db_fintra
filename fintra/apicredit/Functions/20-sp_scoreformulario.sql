-- Function: apicredit.sp_scoreformulario(integer)

-- DROP FUNCTION apicredit.sp_scoreformulario(integer);

CREATE OR REPLACE FUNCTION apicredit.sp_scoreformulario(_numero_solicitud integer)
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
	QuantoValor record;

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

	IngresoSolicitante numeric := 0;


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

		if ( RsPresolicitudes is not null ) then

			FOR vble_mercado_edu IN

				select * from administrativo.variable_mercado_autoscore_edu order by id
			LOOP

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

						if ( RsSolPersona.edad <= 20 ) then

							PuntajeMax = PuntajeMax - 25;
							raise notice 'vble_mercado_edu: %, Resta:25, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;

						elsif ( RsSolPersona.edad > 20 and RsSolPersona.edad <= 25 ) then

							PuntajeMax = PuntajeMax - 20;
							raise notice 'vble_mercado_edu: %, Resta:20, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;

						end if;
					end if;

					--
					if ( vble_mercado_edu.id = 2 ) then

						select into SalarioMin salario_minimo_mensual from salario_minimo where ano = substring(now()::date,1,4);

						--VALOR QUANTO
						select into QuantoValor * from wsdc.productos_valores where nit_empresa = '8020220161' and identificacion = RsPresolicitudes.identificacion;
						IF FOUND THEN
							raise notice 'QUANTO';
							IngresoSolicitante = coalesce(QuantoValor.valor1::numeric*1000,RsSolLaboral.salario);
						ELSE
							raise notice 'FORMULARIO';
							IngresoSolicitante = RsSolLaboral.salario;
						END IF;

						UndSalMin = IngresoSolicitante/SalarioMin;

						if ( UndSalMin > 6 ) then

							PuntajeMax = PuntajeMax + 35;
							raise notice 'vble_mercado_edu: %, Suma:35, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;

						end if;
					end if;

					--
					if ( vble_mercado_edu.id = 3 ) then

						if ( RsSolPersona.estrato in (4,5,6) ) then

							PuntajeMax = PuntajeMax + 35;
							raise notice 'vble_mercado_edu: %, Suma:35, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;

						end if;
					end if;

					--
					if ( vble_mercado_edu.id = 5 ) then

						if ( RsSolPersona.estado_civil = 'C' ) then

							PuntajeMax = PuntajeMax + 30;
							raise notice 'vble_mercado_edu: %, Suma:30, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;

						end if;
					end if;

					--
					if ( vble_mercado_edu.id = 4 ) then

						if ( RsPersonaSol.genero = 'M' and RsPersonaSol.edad between 51 and 55 ) then
							PuntajeMax = PuntajeMax + 20;
							raise notice 'vble_mercado_edu: %, Suma:20, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;
						end if;

						if ( RsPersonaSol.genero = 'M' and RsPersonaSol.edad > 55 ) then
							PuntajeMax = PuntajeMax + 40;
							raise notice 'vble_mercado_edu: %, Suma:40, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;
						end if;

						if ( RsPersonaSol.genero = 'F' and RsPersonaSol.edad > 50 ) then
							PuntajeMax = PuntajeMax + 45;
							raise notice 'vble_mercado_edu: %, Suma:45, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;
						end if;

					end if;

					--
					if ( vble_mercado_edu.id = 6 ) then

						select into BiienRaiz count(0) from solicitud_bienes where numero_solicitud = _numero_solicitud;

						if ( BiienRaiz > 0 ) then

							PuntajeMax = PuntajeMax + 20;
							raise notice 'vble_mercado_edu: %, Suma:20, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;

						end if;
					end if;

					--
					if ( vble_mercado_edu.id = 7 ) then

						if ( RsSolActivEconom.ocupacion in ('INDNFO','PROIN') ) then
							PuntajeMax = PuntajeMax - 10;
							raise notice 'vble_mercado_edu: %, Resta:10, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;
						end if;

					end if;

					--
					if ( vble_mercado_edu.id = 8 ) then

						if ( RsPersonaSol.tipo_vivienda = '01') then
							PuntajeMax = PuntajeMax + 15;
							raise notice 'vble_mercado_edu: %, Suma:15, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;
						end if;

						if ( RsPersonaSol.tipo_vivienda = '02' ) then
							PuntajeMax = PuntajeMax - 30;
							raise notice 'vble_mercado_edu: %, Resta:30, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;
						end if;

						if ( RsPersonaSol.tipo_vivienda = '03' ) then
							PuntajeMax = PuntajeMax - 30;
							raise notice 'vble_mercado_edu: %, Resta:30, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;
						end if;

					end if;

					--
					if ( vble_mercado_edu.id = 9 ) then

						VarAntiguedadRes = case when RsPersonaSol.tiempo_residencia = '' then '0 Años' else RsPersonaSol.tiempo_residencia end;
						--raise notice 'VarAntiguedadRes: %', VarAntiguedadRes;

						TiempoResidencia = substring(VarAntiguedadRes,1,position(' ' in VarAntiguedadRes));
						--raise notice 'TiempoResidencia: %', TiempoResidencia;

						if ( TiempoResidencia::numeric >= 5 ) then
							PuntajeMax = PuntajeMax + 20;
							raise notice 'vble_mercado_edu: %, Suma:20, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;
						end if;

					end if;

					--
					if ( vble_mercado_edu.id = 10 ) then

						if ( RsSolLaboral.antiguedad_laboral >= 5 ) then
							PuntajeMax = PuntajeMax + 25;
							raise notice 'vble_mercado_edu: %, Suma:25, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;
						end if;

					end if;

					--
					if ( vble_mercado_edu.id = 11 ) then

						if ( RsSolLaboral.tipo_contrato = 'INDEFINIDO' ) then

							PuntajeMax = PuntajeMax + 20;
							raise notice 'vble_mercado_edu: %, Suma:20, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;

						elsif ( RsSolLaboral.tipo_contrato in (' ','','TEMPORAL','OTRO') )  then

							PuntajeMax = PuntajeMax - 35;
							raise notice 'vble_mercado_edu: %, Resta:35, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;

						end if;

					end if;

					--
					if ( vble_mercado_edu.id = 12 ) then

						if ( RsSolEstudiante.parentesco_girador not in ('PADRES','ABUELOS','CONYUGE','SOY_EL_GIRADOR') ) then
							PuntajeMax = PuntajeMax - 5;
							raise notice 'vble_mercado_edu: %, Resta:5, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;

						end if;

					end if;

					--
					if ( vble_mercado_edu.id = 13 ) then

						if ( RsSolEstudiante.programa ilike '%derecho%' OR RsSolEstudiante.programa ilike '%abogado%' OR RsSolEstudiante.programa ilike '%juri%' ) then

							PuntajeMax = PuntajeMax - 5;
							raise notice 'vble_mercado_edu: %, Resta:5, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;

						end if;

					end if;

					--
					if ( vble_mercado_edu.id = 14 ) then

						ProporcionSemestre = round((RsSolEstudiante.semestre::numeric/10)*100);
						if ( ProporcionSemestre > 60 ) then

							PuntajeMax = PuntajeMax + 15;
							raise notice 'vble_mercado_edu: %, Suma:15, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;

						end if;

					end if;

					--
					if ( vble_mercado_edu.id = 15 ) then

						if ( RsSolEstudiante.colegio_bachillerato = 'P' ) then

							PuntajeMax = PuntajeMax + 15;
							raise notice 'vble_mercado_edu: %, Suma:15, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;

						end if;

					end if;

					--
					if ( vble_mercado_edu.id = 16 ) then

						if ( RsSolEstudiante.sisben in ('1','2') ) then

							PuntajeMax = PuntajeMax - 25;
							raise notice 'vble_mercado_edu: %, Resta:25, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;

						elsif ( RsSolEstudiante.sisben = '3' ) then

							PuntajeMax = PuntajeMax - 20;
							raise notice 'vble_mercado_edu: %, Resta:20, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;

						end if;

					end if;

					--
					if ( vble_mercado_edu.id = 17 ) then
						--raise notice 'nivel_educativo_padre: %', RsSolEstudiante.nivel_educativo_padre;
						if ( RsSolEstudiante.nivel_educativo_padre = '' ) then

							PuntajeMax = PuntajeMax - 50;
							raise notice 'vble_mercado_edu: %, Resta:50, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;

						elsif ( RsSolEstudiante.nivel_educativo_padre in ('TECNICA','TECNOLOGICA') ) then

							PuntajeMax = PuntajeMax - 30;
							raise notice 'vble_mercado_edu: %, Resta:30, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;

						end if;

					end if;
				else
					ControlProceso = 'R';
					PuntajeMax = 0;

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
			
			--validacion de Quato medio en cero.
			if (ControlProceso = 'P' and totalscore > RsPuntajes.cutoff_total and RsPresolicitudes.comentario != 'APROBADO CON CONDICION' and RsPreSol.qm=0 )then 
			
				select into CapEndeuda apicredit.SP_CapacidadEndeudamiento(_numero_solicitud);
				UPDATE solicitud_aval SET score_buro = RsPreSol.score, 
										  score_lisim = PuntajeMax, 
										  score_total = totalscore, 
										  capacidad_endeudamiento = CapEndeuda, 
										  accion_sugerida = 'VALIDAR CAPACIDAD', 
										  aprobado_score = 'P' 
			  	WHERE numero_solicitud = _numero_solicitud;
				raise notice '1.) ACTUALIZA POSITIVO';

			elsif ( ControlProceso = 'P' and totalscore > RsPuntajes.cutoff_total and RsPresolicitudes.comentario != 'APROBADO CON CONDICION') then

				select into CapEndeuda apicredit.SP_CapacidadEndeudamiento(_numero_solicitud);
				UPDATE solicitud_aval SET score_buro = RsPreSol.score, score_lisim = PuntajeMax, score_total = totalscore, capacidad_endeudamiento = CapEndeuda, accion_sugerida = 'APROBAR', aprobado_score = 'V' WHERE numero_solicitud = _numero_solicitud;
				raise notice '2.) ACTUALIZA POSITIVO';

			elsif ( ControlProceso = 'P' and totalscore > RsPuntajes.cutoff_total and RsPresolicitudes.comentario = 'APROBADO CON CONDICION') then

				select into CapEndeuda apicredit.SP_CapacidadEndeudamiento(_numero_solicitud);
				UPDATE solicitud_aval SET score_buro = RsPreSol.score, score_lisim = PuntajeMax, score_total = totalscore, capacidad_endeudamiento = CapEndeuda, accion_sugerida = 'VALIDAR CAPACIDAD', aprobado_score = 'P' WHERE numero_solicitud = _numero_solicitud;
				raise notice '3.) ACTUALIZA POSITIVO';

			elsif ( ControlProceso = 'P' and totalscore < RsPuntajes.cutoff_total and RsPresolicitudes.comentario = 'APROBADO TIPO 5') then

				select into CapEndeuda apicredit.SP_CapacidadEndeudamiento(_numero_solicitud);
				UPDATE solicitud_aval SET score_buro = RsPreSol.score, score_lisim = PuntajeMax, score_total = totalscore, capacidad_endeudamiento = CapEndeuda, accion_sugerida = 'VALIDAR HISTORIA CREDITO', aprobado_score = 'P' WHERE numero_solicitud = _numero_solicitud;
				raise notice '4.) ACTUALIZA POSITIVO';

			elsif ( ControlProceso = 'P' and totalscore < RsPuntajes.cutoff_total ) then

				UPDATE solicitud_aval SET score_buro = RsPreSol.score, score_lisim = PuntajeMax, score_total = totalscore, capacidad_endeudamiento = CapEndeuda, accion_sugerida = 'RECHAZAR', aprobado_score = 'R' WHERE numero_solicitud = _numero_solicitud;
				raise notice '5.) ACTUALIZA NEGATIVO';

			elsif ( ControlProceso = 'R' ) then

				UPDATE solicitud_aval SET score_buro = RsPreSol.score, score_lisim = 0, score_total = 0, capacidad_endeudamiento = '0%', accion_sugerida = 'RECHAZADO - NO CORRIO EL MODELO DE AUTOSCORE', aprobado_score = 'R' WHERE numero_solicitud = _numero_solicitud;
				raise notice '6.) ACTUALIZA NEGATIVO';

			end if;

			--update solicitud_laboral set actividad_economica = ocupacion where numero_solicitud = _numero_solicitud;

			respuesta = totalscore;
			raise notice 'totalscore: %', totalscore;

			MoraDeudores := apicredit.SP_RelDeudorCodeudor(_numero_solicitud, RsPresolicitudes.identificacion);
			raise notice 'MoraDeudores: %', MoraDeudores;

		end if;

	end if;



	return respuesta;

end;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION apicredit.sp_scoreformulario(integer)
  OWNER TO postgres;
