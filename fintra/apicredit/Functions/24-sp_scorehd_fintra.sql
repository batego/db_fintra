-- Function: apicredit.sp_scorehd_fintra(integer, integer)

-- DROP FUNCTION apicredit.sp_scorehd_fintra(integer, integer);

CREATE OR REPLACE FUNCTION apicredit.sp_scorehd_fintra(_numsolicitud integer, _unid_negocio integer)
  RETURNS text AS
$BODY$

DECLARE

RESPUESTA VARCHAR := '{"respuesta":"R","valor":"0"}';  --'{}';
_ESTADO_SOL VARCHAR:='P';


BEGIN
	IF(_unid_negocio=30)THEN --consumo fintra

		RESPUESTA := apicredit.SP_ScoreHDC_Consumo(_Numsolicitud);

	ELSIF(_unid_negocio=31)THEN --educativo fintra.


		RESPUESTA :=apicredit.sp_scorehdc_educativo(_Numsolicitud,'');

	ELSE
		UPDATE apicredit.pre_solicitudes_creditos
			SET estado_sol=_ESTADO_SOL,
			    comentario='Unidad de negocio no validad'
			WHERE numero_solicitud=_numsolicitud;
	END IF;


	RETURN RESPUESTA;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION apicredit.sp_scorehd_fintra(integer, integer)
  OWNER TO postgres;
