-- Function: opav.asignar_contratista()

-- DROP FUNCTION opav.asignar_contratista();

CREATE OR REPLACE FUNCTION opav.asignar_contratista()
  RETURNS text AS
$BODY$DECLARE
  contratista_sel TEXT;
  ronda_actual INTEGER;
  contratistas RECORD;
  total_rondas INTEGER;
  i INTEGER;

BEGIN

  i:= 1;
  contratista_sel:='';

  SELECT c.ronda INTO ronda_actual FROM opav.control_visita  cv
  INNER JOIN opav.contratistas_aires c ON (cv.contratista=c.contratista)
  WHERE cv.creation_date=(SELECT MAX(creation_date) FROM opav.control_visita) LIMIT 1;

  SELECT MAX(num_tecnicos) INTO total_rondas FROM  opav.contratistas_aires;

	IF ronda_actual IS NULL THEN
		ronda_actual=1;
	END IF;



	WHILE ronda_actual<=total_rondas LOOP

		FOR contratistas IN SELECT  contratista, ronda, num_tecnicos FROM opav.contratistas_aires WHERE tipo='I' ORDER BY nombre ASC

		LOOP
			IF i=1 THEN
			contratista_sel:=contratistas.contratista;
			END IF;

			i:=i+1;


			IF (contratistas.num_tecnicos >= ronda_actual AND contratistas.ronda<ronda_actual) THEN

				contratista_sel :=contratistas.contratista;
				UPDATE opav.contratistas_aires SET ronda=ronda_actual WHERE contratista=contratista_sel;
				-- EXIT;
				RETURN contratista_sel;
			END IF;

		END LOOP;
		ronda_actual:=ronda_actual+1;

	END LOOP;

	UPDATE opav.contratistas_aires SET ronda=0;

        UPDATE opav.contratistas_aires SET ronda=1 WHERE contratista=contratista_sel;


	RETURN contratista_sel;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.asignar_contratista()
  OWNER TO postgres;
