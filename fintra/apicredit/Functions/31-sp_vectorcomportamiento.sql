-- Function: apicredit.sp_vectorcomportamiento(character varying, integer, integer, character varying, character varying)

-- DROP FUNCTION apicredit.sp_vectorcomportamiento(character varying, integer, integer, character varying, character varying);

CREATE OR REPLACE FUNCTION apicredit.sp_vectorcomportamiento(vectcomportamiento character varying, _numerosol integer, meses integer, reporte character varying, edadesmora character varying)
  RETURNS text AS
$BODY$

DECLARE

	respuesta varchar := 'P';
	CompMestoMes varchar := '';
	Cad_to_String varchar := '';
	RtaVector varchar := '';
	SQL varchar := '';

	LongitudCad integer;
	ContadorMeses integer := 0;
	ResultadoMEses integer := 0;
	MesReverse integer := 0;

	vble_mercado_buro record;
	RsPuntajes record;
	RsCon record;

	tbl_array text[];
	t integer;
	ContRtaVector integer;
	Reversor integer;

	rayita varchar:='-';

BEGIN
	PERFORM * FROM APICREDIT.VECTOR_COMPORTAMIENTO WHERE NUMERO_SOLICITUD = _NUMEROSOL;
	IF(FOUND) THEN
		DELETE FROM APICREDIT.VECTOR_COMPORTAMIENTO WHERE NUMERO_SOLICITUD = _NUMEROSOL;
	END IF;

-- 	create index vector_solicitud
-- 	on apicredit.vector_comportamiento
-- 	using btree
-- 	(numero_solicitud,reg_status)

	--*RAISE NOTICE 'EdadesMora: %', EdadesMora;
	select into LongitudCad length(VectComportamiento);
	--*RAISE NOTICE 'LongitudCad: %', LongitudCad;

	Reversor = LongitudCad;

	FOR i IN REVERSE LongitudCad .. 1 LOOP
		CompMestoMes = substring(VectComportamiento,i,1);
		if ( CompMestoMes = '-' ) then
			Reversor = Reversor-1;
		else
			exit;
		end if;
	END LOOP;
	--*RAISE NOTICE 'Reversor: %', Reversor;

	--FOR i IN 1..LongitudCad LOOP
	FOR i IN 1..Reversor LOOP

		--*RAISE NOTICE 'i: %', i;
		CompMestoMes = substring(VectComportamiento,i,1);
		--RAISE NOTICE 'CompMestoMes: %', CompMestoMes;

		--if ( CompMestoMes != '-' ) then
			ContadorMeses = ContadorMeses + 1;
			Cad_to_String = Cad_to_String || CompMestoMes ||',';
		--end if;

	END LOOP;
	--*RAISE NOTICE 'Cad_to_String: %', Cad_to_String;
	--*RAISE NOTICE 'ContadorMeses: %', ContadorMeses;

	--respuesta = ContadorMeses||'-'||length(Cad_to_String)||'-'||Cad_to_String||'*'||substring(Cad_to_String,1,length(Cad_to_String)-1);

	if ( ContadorMeses::numeric > 0 and ContadorMeses > Meses ) then

		ResultadoMEses = ContadorMeses - Meses + 1;

		--FOR i IN REVERSE ContadorMeses..Meses LOOP
		--	RAISE NOTICE 'In Reverse: %', i;
		--END LOOP;

		--*raise notice 'l: %',string_to_array(substring(Cad_to_String,1,length(Cad_to_String)-1),',');
		tbl_array = string_to_array(substring(Cad_to_String,1,length(Cad_to_String)-1),',');
		--RAISE NOTICE 'ESTA COSA ES: %', array_upper(tbl_array, 1);

		MesReverse = Meses;
		FOR t IN REVERSE array_upper(tbl_array, 1) .. ResultadoMEses LOOP

			--*RAISE NOTICE 't: %, Contenido: %', t, tbl_array[t];
			INSERT INTO apicredit.vector_comportamiento (numero_solicitud, mes, mora) VALUES(_NumeroSol,MesReverse,tbl_array[t]);
			MesReverse = MesReverse - 1;

		END LOOP;

		IF ( Reporte = 'MAX' ) THEN
			SELECT into ContRtaVector count(0) FROM apicredit.vector_comportamiento WHERE mora not in ('N','-','C','D') and numero_solicitud = _NumeroSol;
			if ( ContRtaVector > 0 ) then
				SELECT into RtaVector MAX(mora) FROM apicredit.vector_comportamiento WHERE mora not in ('N','-','C','D') and numero_solicitud = _NumeroSol;
			else
				SELECT into RtaVector 0;
			end if;
		END IF;

		IF ( Reporte = 'CON' ) THEN

			--SELECT INTO RtaVector COUNT(mora) FROM apicredit.vector_comportamiento WHERE mora not in ('N','-') and mora in (EdadesMora) and numero_solicitud = 77763; -- _NumeroSol;
			SQL =  'SELECT COUNT(mora) as cuenta_mora
				FROM apicredit.vector_comportamiento
				WHERE mora not in (''N'',''-'')
				AND mora in ('||EdadesMora||')
				AND numero_solicitud = '||_NumeroSol;
			--RAISE NOTICE 'SQL: %', SQL;

			FOR RsCon IN EXECUTE SQL LOOP
				--raise notice 'a: %',RsCon.cuenta_mora;
				RtaVector = RsCon.cuenta_mora;
			END LOOP;

		END IF;

		respuesta = RtaVector::varchar;
	else
		respuesta = 0;
	end if;

	return respuesta;

end;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION apicredit.sp_vectorcomportamiento(character varying, integer, integer, character varying, character varying)
  OWNER TO postgres;
