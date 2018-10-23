-- Function: apicredit.sp_scoreformularioproductivo(integer)

-- DROP FUNCTION apicredit.sp_scoreformularioproductivo(integer);

CREATE OR REPLACE FUNCTION apicredit.sp_scoreformularioproductivo(_numero_solicitud integer)
  RETURNS void AS
$BODY$

DECLARE

	vble_mercado_edu record;
	RsPuntajes record;
	RsPresolicitudes record;
	RsSolAval record;
	RsSolPersona record;
	RsPersonaSol record;
	RsSolLaboral record;
	RsSolReferencias record;
	RsSolBienes record;
	RsSolEstudiante	record;
	RsSolActivEconom record;
	RsPreSol record;

	PuntajeMax numeric := 0;
	SalarioMin numeric := 0;
	UndSalMin numeric := 0;
	BiienRaiz numeric := 0;
	ProporcionSemestre numeric := 0;

	buro numeric := 0;
	postscore numeric := 0;
	totalscore numeric := 0;

	respuesta varchar := 'P';
	_RtAccion varchar := '';

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
				where numero_solicitud = _numero_solicitud and tipo = 'E';

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

				--
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
					UndSalMin = RsSolLaboral.salario/SalarioMin;

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
				if ( vble_mercado_edu.id = 6 ) then

					if ( RsSolPersona.estado_civil = 'C' ) then

						PuntajeMax = PuntajeMax + 30;
						raise notice 'vble_mercado_edu: %, Suma:30, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;

					end if;
				end if;

				--
				if ( vble_mercado_edu.id = 5 ) then

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
				if ( vble_mercado_edu.id = 7 ) then

					select into BiienRaiz count(0) from solicitud_bienes where numero_solicitud = _numero_solicitud;

					if ( BiienRaiz > 0 ) then

						PuntajeMax = PuntajeMax + 20;
						raise notice 'vble_mercado_edu: %, Suma:20, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;

					end if;
				end if;

				--
				if ( vble_mercado_edu.id = 8 ) then

					if ( RsSolActivEconom.ocupacion in ('INDNFO','PROIN') ) then
						PuntajeMax = PuntajeMax - 10;
						raise notice 'vble_mercado_edu: %, Resta:10, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;
					end if;

				end if;

				--
				if ( vble_mercado_edu.id = 9 ) then

					if ( RsPersonaSol.tipo_vivienda = '01') then
						PuntajeMax = PuntajeMax + 15;
						raise notice 'vble_mercado_edu: %, Suma:15, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;
					end if;

					if ( RsPersonaSol.tipo_vivienda = '02' ) then
						PuntajeMax = PuntajeMax - 30;
						raise notice 'vble_mercado_edu: %, Resta:40, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;
					end if;

					if ( RsPersonaSol.tipo_vivienda = '03' ) then
						PuntajeMax = PuntajeMax - 30;
						raise notice 'vble_mercado_edu: %, Resta:45, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;
					end if;

				end if;

				--
				if ( vble_mercado_edu.id = 11 ) then

					if ( RsSolLaboral.antiguedad_laboral >= 5 ) then
						PuntajeMax = PuntajeMax + 25;
						raise notice 'vble_mercado_edu: %, Suma:25, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;
					end if;

				end if;

				--
				if ( vble_mercado_edu.id = 12 ) then

					if ( RsSolLaboral.tipo_contrato = 'INDEFINIDO' ) then

						PuntajeMax = PuntajeMax + 20;
						raise notice 'vble_mercado_edu: %, Suma:20, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;

					elsif ( RsSolLaboral.tipo_contrato in (' ','','TEMPORAL','OTRO') )  then

						PuntajeMax = PuntajeMax - 35;
						raise notice 'vble_mercado_edu: %, Resta:35, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;

					end if;

				end if;

				--
				if ( vble_mercado_edu.id = 13 ) then

					if ( RsSolEstudiante.parentesco_girador not in ('PADRES','ABUELOS') ) then
						PuntajeMax = PuntajeMax - 5;
						raise notice 'vble_mercado_edu: %, Resta:5, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;

					end if;

				end if;

				--
				if ( vble_mercado_edu.id = 14 ) then

					if ( RsSolEstudiante.programa ilike '%derecho%' ) then

						PuntajeMax = PuntajeMax - 20;
						raise notice 'vble_mercado_edu: %, Resta:20, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;

					end if;

				end if;

				--
				if ( vble_mercado_edu.id = 15 ) then

					ProporcionSemestre = (RsSolEstudiante.semestre/10)*100;
					if ( ProporcionSemestre > 60 ) then

						PuntajeMax = PuntajeMax + 15;
						raise notice 'vble_mercado_edu: %, Suma:15, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;

					end if;

				end if;

				--
				if ( vble_mercado_edu.id = 16 ) then

					if ( RsSolEstudiante.colegio_bachillerato = 'P' ) then

						PuntajeMax = PuntajeMax - 15;
						raise notice 'vble_mercado_edu: %, Resta:15, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;

					end if;

				end if;

				--
				if ( vble_mercado_edu.id = 17 ) then

					if ( RsSolEstudiante.sisben in ('1','2') ) then

						PuntajeMax = PuntajeMax - 25;
						raise notice 'vble_mercado_edu: %, Resta:25, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;

					elsif ( RsSolEstudiante.sisben = '3' ) then

						PuntajeMax = PuntajeMax - 20;
						raise notice 'vble_mercado_edu: %, Resta:20, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;

					end if;

				end if;

				--
				if ( vble_mercado_edu.id = 18 ) then

					if ( RsSolEstudiante.nivel_educativo_padre = '' ) then

						PuntajeMax = PuntajeMax - 50;
						raise notice 'vble_mercado_edu: %, Resta:50, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;

					elsif ( RsSolEstudiante.nivel_educativo_padre in ('TECNICA','TECNOLOGICA') ) then

						PuntajeMax = PuntajeMax - 30;
						raise notice 'vble_mercado_edu: %, Resta:30, PuntajeMax: %', vble_mercado_edu.id, PuntajeMax;

					end if;

				end if;

			END LOOP;

			select into RsPreSol * from apicredit.pre_solicitudes_creditos where numero_solicitud = _numero_solicitud;

			buro = RsPreSol.score * 0.4;
			postscore = PuntajeMax * 0.6;
			totalscore = buro + postscore;

			raise notice 'buro: %, postscore: %', RsPreSol.score, PuntajeMax;
			raise notice 'cutoff: %, buro_porc: %, postscore_porc: %, totalscore: % ', RsPuntajes.cutoff, buro, postscore, totalscore;

			if ( totalscore > RsPuntajes.cutoff_total ) then
				UPDATE solicitud_aval SET score_buro = buro, score_lisim = postscore, score_total = totalscore, accion_sugerida = 'APROBAR' WHERE numero_solicitud = _numero_solicitud;
				raise notice 'P';
			else
				UPDATE solicitud_aval SET score_buro = buro, score_lisim = postscore, score_total = totalscore, accion_sugerida = 'RECHAZAR' WHERE numero_solicitud = _numero_solicitud;
				raise notice 'R';
			end if;

			--respuesta = totalscore;

			raise notice 'totalscore: %', totalscore;
		end if;

	end if;

	--return respuesta;

end;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION apicredit.sp_scoreformularioproductivo(integer)
  OWNER TO postgres;
