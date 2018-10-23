-- Function: sp_desembolsocheque(character varying, character varying, character varying)

-- DROP FUNCTION sp_desembolsocheque(character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION sp_desembolsocheque(_cxp_cheque character varying, banco_transferencia character varying, _usuariu character varying)
  RETURNS text AS
$BODY$

DECLARE

	RsNeg record;

	ReturnCC varchar;
	ReturnEG varchar;
	NegocioRelacionado varchar;
	RtNegCont varchar;

	_respuesta varchar := 'BAD';

BEGIN

	select into NegocioRelacionado documento_relacionado from fin.cxp_doc where documento = _cxp_cheque;

	/*---------------------------------
	--FUNCION: Contabilizo el negocio--
	-----------------------------------*/

	--CONSULTA NEGOCIO.
	SELECT INTO RsNeg *
	FROM negocios n
	INNER JOIN solicitud_aval sa on (sa.cod_neg = n.cod_neg)
	INNER JOIN solicitud_persona sp on (sp.numero_solicitud = sa.numero_solicitud and sp.tipo = 'S')
	WHERE n.cod_neg = NegocioRelacionado and periodo = 'XXXXXX' and no_transacion = 111111;

	if ( RsNeg.fecha_cont = '0099-01-01 00:00:00' ) then
		SELECT INTO RtNegCont SP_ContabilizarNegocio(NegocioRelacionado, RsNeg.cod_cli, RsNeg.nombre, RsNeg.vr_desembolso, _Usuariu);
	end if;

	/*------------------------------
	--FUNCION: Generar los Egresos--
	--------------------------------*/
	SELECT INTO ReturnEG SP_EgresoLibranza(_cxp_cheque, banco_transferencia, _Usuariu);

	if ( ReturnCC != '' and ReturnEG != '' ) then
		_respuesta = 'OK';
	end if;

	RETURN _respuesta;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_desembolsocheque(character varying, character varying, character varying)
  OWNER TO postgres;
