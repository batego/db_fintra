-- Function: sp_indicadorgeneralrq(character varying, character varying, character varying)

-- DROP FUNCTION sp_indicadorgeneralrq(character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION sp_indicadorgeneralrq(ano character varying, mes character varying, _proceso character varying)
  RETURNS SETOF rstype_estadisticas AS
$BODY$

DECLARE

	rs rstype_estadisticas;
	RsCalculos record;
	DiffSeconds record;

	Proceso integer;

	AnoMes varchar := '';
	VarProceso varchar := '';

	BlsMeses numeric := 0;
	BlsMeses2 numeric := 0;
	_enero numeric := 0;
	_febrero numeric := 0;
	_marzo numeric := 0;
	_abril numeric := 0;
	_mayo numeric := 0;
	_junio numeric := 0;
	_julio numeric := 0;
	_agosto numeric := 0;
	_septiembre numeric := 0;
	_octubre numeric := 0;
	_noviembre numeric := 0;
	_diciembre numeric := 0;

	_Kenero numeric := 0;
	_Kfebrero numeric := 0;
	_Kmarzo numeric := 0;
	_Kabril numeric := 0;
	_Kmayo numeric := 0;
	_Kjunio numeric := 0;
	_Kjulio numeric := 0;
	_Kagosto numeric := 0;
	_Kseptiembre numeric := 0;
	_Koctubre numeric := 0;
	_Knoviembre numeric := 0;
	_Kdiciembre numeric := 0;

	Acumulador numeric := 0;
	Promedio numeric := 0;
	days numeric := 0;
	hours numeric := 0;

	Prueba text := 0;

	cont integer := 0;

	SQL TEXT := '';
	SQL2 TEXT := '';
	QRY TEXT := '';
	SqlDiff TEXT := '';

	SQLest TEXT := '';
	_VarEst TEXT := '';

BEGIN

	--SELECT * FROM requisicion WHERE replace(substring(fch_radicacion,1,7),'-','')::numeric = '201510' and id_proceso_interno = 13 and tipo_tarea=2

	if ( _Proceso != '' ) then VarProceso = ' and id_proceso_interno = '||Proceso; Proceso = _Proceso::numeric; else VarProceso = ''; Proceso= 0; end if;

	FOR k IN 1..5 LOOP

		if ( k = 1 ) then

			rs.secuencia_i = k;

			FOR i IN 1..12 LOOP

				AnoMes = ano||OVERLAY('00' PLACING i FROM 3 - length(i) FOR length(i));
				--AnoMes = ano||mes;
				--raise notice 'AnoMes: %', AnoMes;

				SQL =  'SELECT count(0) as cuenta FROM requisicion WHERE id_estado_requisicion = 2 and replace(substring(fch_radicacion,1,7),''-'','''') = '''||AnoMes||''' and tipo_tarea = 2'||VarProceso;
				raise notice 'SQL: %', SQL;

				BlsMeses = 0;

				FOR RsCalculos IN EXECUTE SQL LOOP

					--raise notice 'AnoMes: %, cuenta: %', AnoMes, RsCalculos.cuenta;
					if ( RsCalculos.cuenta != 0 ) then

						if ( i = 1 ) then rs.enero = RsCalculos.cuenta::varchar; BlsMeses = BlsMeses + RsCalculos.cuenta; _enero = RsCalculos.cuenta; else rs.enero = 0; end if;
						if ( i = 2 ) then rs.febrero = RsCalculos.cuenta::varchar; BlsMeses = BlsMeses + RsCalculos.cuenta; _febrero = RsCalculos.cuenta; else rs.febrero = 0; end if;
						if ( i = 3 ) then rs.marzo = RsCalculos.cuenta::varchar; BlsMeses = BlsMeses + RsCalculos.cuenta; _marzo = RsCalculos.cuenta; else rs.marzo = 0; end if;
						if ( i = 4 ) then rs.abril = RsCalculos.cuenta::varchar; BlsMeses = BlsMeses + RsCalculos.cuenta; _abril = RsCalculos.cuenta; else rs.abril = 0; end if;
						if ( i = 5 ) then rs.mayo = RsCalculos.cuenta::varchar; BlsMeses = BlsMeses + RsCalculos.cuenta; _mayo = RsCalculos.cuenta; else rs.mayo = 0; end if;
						if ( i = 6 ) then rs.junio = RsCalculos.cuenta::varchar; BlsMeses = BlsMeses + RsCalculos.cuenta; _junio = RsCalculos.cuenta; else rs.junio = 0; end if;
						if ( i = 7 ) then rs.julio = RsCalculos.cuenta::varchar; BlsMeses = BlsMeses + RsCalculos.cuenta; _julio = RsCalculos.cuenta; else rs.julio = 0; end if;
						if ( i = 8 ) then rs.agosto = RsCalculos.cuenta::varchar; BlsMeses = BlsMeses + RsCalculos.cuenta; _agosto = RsCalculos.cuenta; else rs.agosto = 0; end if;
						if ( i = 9 ) then rs.septiembre = RsCalculos.cuenta::varchar; BlsMeses = BlsMeses + RsCalculos.cuenta; _septiembre = RsCalculos.cuenta; else rs.septiembre = 0; end if;
						if ( i = 10 ) then rs.octubre = RsCalculos.cuenta::varchar; BlsMeses = BlsMeses + RsCalculos.cuenta; _octubre = RsCalculos.cuenta; else rs.octubre = 0; end if;
						if ( i = 11 ) then rs.noviembre = RsCalculos.cuenta::varchar; BlsMeses = BlsMeses + RsCalculos.cuenta; _noviembre = RsCalculos.cuenta; else rs.noviembre = 0; end if;
						if ( i = 12 ) then rs.diciembre = RsCalculos.cuenta::varchar; BlsMeses = BlsMeses + RsCalculos.cuenta; _diciembre = RsCalculos.cuenta; else rs.diciembre = 0; end if;

					end if;

				END LOOP;

				if ( BlsMeses != 0 ) then rs.acumulado = BlsMeses; end if;

			END LOOP;

		elsif ( k = 2 ) then

			rs.secuencia_i = k;
			rs.enero = 0;
			rs.febrero = 0;
			rs.marzo = 0;
			rs.abril = 0;
			rs.mayo = 0;
			rs.junio = 0;
			rs.julio = 0;
			rs.agosto = 0;
			rs.septiembre = 0;
			rs.octubre = 0;
			rs.noviembre = 0;
			rs.diciembre = 0;
			rs.acumulado = 0;

			FOR i IN 1..12 LOOP

				AnoMes = ano||OVERLAY('00' PLACING i FROM 3 - length(i) FOR length(i));
				--raise notice 'AnoMes: %', AnoMes;

				QRY =  'SELECT count(0) as cuenta FROM requisicion WHERE replace(substring(fch_radicacion,1,7),''-'','''') = '''||AnoMes||'''  and tipo_tarea = 2 and fch_cierre is not null'||VarProceso;
				raise notice 'QRY: %', QRY;

				BlsMeses2 = 0;

				FOR RsCalculos IN EXECUTE QRY LOOP

					if ( RsCalculos.cuenta != 0 ) then

						if ( i = 1 ) then rs.enero = RsCalculos.cuenta::varchar; BlsMeses2 = BlsMeses2 + RsCalculos.cuenta; _Kenero = RsCalculos.cuenta; else rs.enero = 0; end if;
						if ( i = 2 ) then rs.febrero = RsCalculos.cuenta::varchar; BlsMeses2 = BlsMeses2 + RsCalculos.cuenta; _Kfebrero = RsCalculos.cuenta; else rs.febrero = 0; end if;
						if ( i = 3 ) then rs.marzo = RsCalculos.cuenta::varchar; BlsMeses2 = BlsMeses2 + RsCalculos.cuenta; _Kmarzo = RsCalculos.cuenta; else rs.marzo = 0; end if;
						if ( i = 4 ) then rs.abril = RsCalculos.cuenta::varchar; BlsMeses2 = BlsMeses2 + RsCalculos.cuenta; _Kabril = RsCalculos.cuenta; else rs.abril = 0; end if;
						if ( i = 5 ) then rs.mayo = RsCalculos.cuenta::varchar; BlsMeses2 = BlsMeses2 + RsCalculos.cuenta; _Kmayo = RsCalculos.cuenta; else rs.mayo = 0; end if;
						if ( i = 6 ) then rs.junio = RsCalculos.cuenta::varchar; BlsMeses2 = BlsMeses2 + RsCalculos.cuenta; _Kjunio = RsCalculos.cuenta; else rs.junio = 0; end if;
						if ( i = 7 ) then rs.julio = RsCalculos.cuenta::varchar; BlsMeses2 = BlsMeses2 + RsCalculos.cuenta; _Kjulio = RsCalculos.cuenta; else rs.julio = 0; end if;
						if ( i = 8 ) then rs.agosto = RsCalculos.cuenta::varchar; BlsMeses2 = BlsMeses2 + RsCalculos.cuenta; _Kagosto = RsCalculos.cuenta; else rs.agosto = 0; end if;
						if ( i = 9 ) then rs.septiembre = RsCalculos.cuenta::varchar; BlsMeses2 = BlsMeses2 + RsCalculos.cuenta; _Kseptiembre = RsCalculos.cuenta; else rs.septiembre = 0; end if;
						if ( i = 10 ) then rs.octubre = RsCalculos.cuenta::varchar; BlsMeses2 = BlsMeses2 + RsCalculos.cuenta; _Koctubre = RsCalculos.cuenta; else rs.octubre = 0; end if;
						if ( i = 11 ) then rs.noviembre = RsCalculos.cuenta::varchar; BlsMeses2 = BlsMeses2 + RsCalculos.cuenta; _Knoviembre = RsCalculos.cuenta; else rs.noviembre = 0; end if;
						if ( i = 12 ) then rs.diciembre = RsCalculos.cuenta::varchar; BlsMeses2 = BlsMeses2 + RsCalculos.cuenta; _Kdiciembre = RsCalculos.cuenta; else rs.diciembre = 0; end if;
					end if;

				END LOOP;

				if ( BlsMeses2 != 0 ) then rs.acumulado = BlsMeses2; end if;

			END LOOP;

		elsif ( k = 3 ) then

			rs.secuencia_i = k;
			rs.enero = 0;
			rs.febrero = 0;
			rs.marzo = 0;
			rs.abril = 0;
			rs.mayo = 0;
			rs.junio = 0;
			rs.julio = 0;
			rs.agosto = 0;
			rs.septiembre = 0;
			rs.octubre = 0;
			rs.noviembre = 0;
			rs.diciembre = 0;
			rs.acumulado = 0;

			if ( _enero != 0 ) then rs.enero = ((_Kenero * 100) / _enero)::numeric(11,2); else rs.enero = 0::numeric(11,2); end if;
			if ( _febrero != 0 ) then rs.febrero = ((_Kfebrero * 100) / _febrero)::numeric(11,2); else rs.febrero = 0::numeric(11,2); end if;
			if ( _marzo != 0 ) then rs.marzo = ((_Kmarzo * 100) / _marzo)::numeric(11,2); else rs.marzo = 0::numeric(11,2); end if;
			if ( _abril != 0 ) then rs.abril = ((_Kabril * 100) / _abril)::numeric(11,2); else rs.abril = 0::numeric(11,2); end if;
			if ( _mayo != 0 ) then rs.mayo = ((_Kmayo * 100) / _mayo)::numeric(11,2); else rs.mayo = 0::numeric(11,2); end if;
			if ( _junio != 0 ) then rs.junio = ((_Kjunio * 100) / _junio)::numeric(11,2); else rs.junio = 0::numeric(11,2); end if;
			if ( _julio != 0 ) then rs.julio = ((_Kjulio * 100) / _julio)::numeric(11,2); else rs.julio = 0::numeric(11,2); end if;
			if ( _agosto != 0 ) then rs.agosto = ((_Kagosto * 100) / _agosto)::numeric(11,2); else rs.agosto = 0::numeric(11,2); end if;
			if ( _septiembre != 0 ) then rs.septiembre = ((_Kseptiembre * 100) / _septiembre)::numeric(11,2); else rs.septiembre = 0::numeric(11,2); end if;
			if ( _octubre != 0 ) then rs.octubre = ((_Koctubre * 100) / _octubre)::numeric(11,2); else rs.octubre = 0::numeric(11,2); end if;
			if ( _noviembre != 0 ) then rs.noviembre = ((_Knoviembre * 100) / _noviembre)::numeric(11,2); else rs.noviembre = 0::numeric(11,2); end if;
			if ( _diciembre != 0 ) then rs.diciembre = ((_diciembre * 100) / _diciembre)::numeric(11,2); else rs.diciembre = 0::numeric(11,2); end if;
			rs.acumulado = 0;

		elsif ( k = 4 ) then

			rs.secuencia_i = k;
			rs.enero = 0;
			rs.febrero = 0;
			rs.marzo = 0;
			rs.abril = 0;
			rs.mayo = 0;
			rs.junio = 0;
			rs.julio = 0;
			rs.agosto = 0;
			rs.septiembre = 0;
			rs.octubre = 0;
			rs.noviembre = 0;
			rs.diciembre = 0;
			rs.acumulado = 0;

			FOR i IN 1..12 LOOP

				AnoMes = ano||OVERLAY('00' PLACING i FROM 3 - length(i) FOR length(i));
				--raise notice 'AnoMes: %', AnoMes;

				SQL2 = 'SELECT
					fch_radicacion, fch_cierre,
					(fch_cierre::timestamp - fch_radicacion::timestamp) as diff_date,
					to_char((fch_cierre::timestamp - fch_radicacion::timestamp) + (to_char(age(fch_cierre::timestamp , fch_radicacion::timestamp)*24 ,''DD'')||'' hour'')::interval,''HH24:MI:ss'') as DiffHoras
					FROM requisicion
					WHERE replace(substring(fch_radicacion,1,7),''-'','''') = '''||AnoMes||'''
					and tipo_tarea = 2'||VarProceso; --Que esten cerradas.
				--raise notice 'SQL2: %', SQL2;

				Acumulador = 0;
				Promedio = 0;
				days = 0;

				FOR RsCalculos IN EXECUTE SQL2 LOOP

					SqlDiff = 'SELECT EXTRACT(EPOCH FROM INTERVAL '''||RsCalculos.diff_date||''') as DiferenciaSegs';

					--raise notice 'SqlDiff: %', SqlDiff;

					FOR DiffSeconds IN EXECUTE SqlDiff LOOP

						raise notice 'DiffSeconds: %', DiffSeconds.DiferenciaSegs;
						Acumulador = Acumulador + DiffSeconds.DiferenciaSegs;
						cont = cont + 1;

					END LOOP;

					if ( Acumulador > 0 ) then

						Promedio = Acumulador / cont;
						days = Promedio/86400;
						--raise notice 'Promedio: %, days: %', Promedio, days::numeric(11,2);

						--Promedio = Promedio % 86400;
						--hours = Promedio/3600;
						--raise notice 'Promedio: %, hours: %', Promedio, hours::numeric(11,2);

					end if;

				END LOOP;

				if ( days > 0 ) then

					Promedio = Acumulador / cont;
					days = Promedio/86400;
					--raise notice 'Promedio: %, days: %', Promedio, days::numeric(11,2);

					if ( i = 1 ) then rs.enero = days::numeric(11,2); else rs.enero = 0; end if;
					if ( i = 2 ) then rs.febrero = days::numeric(11,2); else rs.febrero = 0; end if;
					if ( i = 3 ) then rs.marzo = days::numeric(11,2); else rs.marzo = 0; end if;
					if ( i = 4 ) then rs.abril = days::numeric(11,2); else rs.abril = 0; end if;
					if ( i = 5 ) then rs.mayo = days::numeric(11,2); else rs.mayo = 0; end if;
					if ( i = 6 ) then rs.junio = days::numeric(11,2); else rs.junio = 0; end if;
					if ( i = 7 ) then rs.julio = days::numeric(11,2); else rs.julio = 0; end if;
					if ( i = 8 ) then rs.agosto = days::numeric(11,2); else rs.agosto = 0; end if;
					if ( i = 9 ) then rs.septiembre = days::numeric(11,2); else rs.septiembre = 0; end if;
					if ( i = 10 ) then rs.octubre = days::numeric(11,2); else rs.octubre = 0; end if;
					if ( i = 11 ) then rs.noviembre = days::numeric(11,2); else rs.noviembre = 0; end if;
					if ( i = 12 ) then rs.diciembre = days::numeric(11,2); else rs.diciembre = 0; end if;

				end if;

			END LOOP;

		elsif ( k = 5 ) then

			rs.secuencia_i = k;
			rs.enero = 0;
			rs.febrero = 0;
			rs.marzo = 0;
			rs.abril = 0;
			rs.mayo = 0;
			rs.junio = 0;
			rs.julio = 0;
			rs.agosto = 0;
			rs.septiembre = 0;
			rs.octubre = 0;
			rs.noviembre = 0;
			rs.diciembre = 0;
			rs.acumulado = 0;

			AnoMes = ano||OVERLAY('00' PLACING mes FROM 3 - length(mes) FOR length(mes));
			--raise notice 'AnoMes: %', AnoMes;

			_VarEst = '';--RQ Antendidas
			SQLest = 'SELECT count(0) FROM requisicion WHERE solucionador_responsable != '''' and replace(substring(fch_radicacion,1,7),''-'','''') = '''||AnoMes||''''||VarProceso;
			EXECUTE SQLest INTO _VarEst; --raise notice 'SQLest: % _VarEst: %', SQLest, _VarEst;

			if ( _VarEst != '' ) then rs.enero = _VarEst::numeric; else rs.enero = 0; end if;
			--------------------

			_VarEst = '';--RQ Cerradas
			SQLest = 'SELECT count(0) FROM requisicion WHERE id_estado_requisicion = 2 and replace(substring(fch_radicacion,1,7),''-'','''') = '''||AnoMes||'''  and tipo_tarea = 2'||VarProceso;
			EXECUTE SQLest INTO _VarEst; --raise notice 'SQLest: % _VarEst: %', SQLest, _VarEst;

			if ( _VarEst != '' ) then rs.febrero = _VarEst::numeric; else rs.febrero = 0; end if;
			--------------------

			_VarEst = '';--RQ Cronogramadas(1) Pendientes OOOOOOOJOOOOO
			SQLest = 'SELECT count(0) FROM requisicion WHERE id_estado_requisicion = 1 and replace(substring(fch_radicacion,1,7),''-'','''') = '''||AnoMes||''' and tipo_tarea = 1'||VarProceso;
			EXECUTE SQLest INTO _VarEst; --raise notice 'SQLest: % _VarEst: %', SQLest, _VarEst;

			if ( _VarEst != '' ) then rs.marzo = _VarEst::numeric; else rs.marzo = 0; end if;
			--------------------

			_VarEst = '';--RQ Pendientes Mes Actual
			SQLest = 'SELECT count(0) FROM requisicion WHERE id_estado_requisicion = 1 and replace(substring(fch_radicacion,1,7),''-'','''') = '''||AnoMes||''' and tipo_tarea = 2'||VarProceso;
			EXECUTE SQLest INTO _VarEst; --raise notice 'SQLest: % _VarEst: %', SQLest, _VarEst;

			if ( _VarEst != '' ) then rs.abril = _VarEst::numeric; else rs.abril = 0; end if;
			--------------------

			_VarEst = '';--RQ Cerradas fuera de su mes
			SQLest = 'SELECT count(0) FROM requisicion WHERE id_estado_requisicion = 2 and replace(substring(fch_radicacion,1,7),''-'','''') <> replace(substring(fch_cierre,1,7),''-'','''') and replace(substring(fch_radicacion,1,7),''-'','''') = '''||AnoMes||'''  and tipo_tarea = 2'||VarProceso;
			EXECUTE SQL INTO _VarEst; --raise notice 'SQLest: % _VarEst: %', SQLest, _VarEst;

			if ( _VarEst != '' ) then rs.mayo = _VarEst::numeric; else rs.mayo = 0; end if;
			--------------------

			_VarEst = '';--RQ Cronogramadas(2) Cerradas
			SQLest = 'SELECT count(0) FROM requisicion WHERE id_estado_requisicion = 2 and replace(substring(fch_radicacion,1,7),''-'','''') = '''||AnoMes||''' and replace(substring(fch_radicacion,1,7),''-'','''') = '''||AnoMes||'''  and tipo_tarea = 1'||VarProceso;
			EXECUTE SQL INTO _VarEst; --raise notice 'SQLest: % _VarEst: %', SQLest, _VarEst;

			if ( _VarEst != '' ) then rs.junio = _VarEst::numeric; else rs.junio = 0; end if;
			--------------------

			_VarEst = '';--RQ Cerradas mes actual, no del mes actual
			SQLest = 'SELECT count(0) FROM requisicion WHERE id_estado_requisicion = 2 and replace(substring(fch_radicacion,1,7),''-'','''') <> replace(substring(fch_cierre,1,7),''-'','''') and replace(substring(fch_cierre,1,7),''-'','''') = '''||AnoMes||''' and replace(substring(fch_radicacion,1,7),''-'','''') = '''||AnoMes||'''  and tipo_tarea = 1'||VarProceso;
			EXECUTE SQL INTO _VarEst; --raise notice 'SQLest: % _VarEst: %', SQLest, _VarEst;

			if ( _VarEst != '' ) then rs.julio = _VarEst::numeric; else rs.julio = 0; end if;
			--------------------

		end if;

		RETURN NEXT rs;

	END LOOP;

	/*
	select * from SP_IndicadorGeneralRq('2009', '10', 20)
	FOR i IN 1..12 LOOP
		RETURN NEXT rs;
	END LOOP;
	*/
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_indicadorgeneralrq(character varying, character varying, character varying)
  OWNER TO postgres;
