-- Function: sp_tramo_anterior(character varying, character varying)

-- DROP FUNCTION sp_tramo_anterior(character varying, character varying);

CREATE OR REPLACE FUNCTION sp_tramo_anterior(_periodofoto character varying, _negocio character varying)
  RETURNS text AS
$BODY$
DECLARE

 _tramoAnterior varchar;

BEGIN


     SELECT into _tramoAnterior tramo_periodo_lote  from con.foto_cartera fra
	WHERE fra.dstrct = 'FINV'
	  AND fra.reg_status = ''
	  AND fra.tipo_documento in ('FAC','NDC')
	  AND substring(fra.documento,1,2) not in ('CP','FF','DF')
	  AND fra.periodo_lote = _periodoFoto
	  and fra.negasoc=_negocio
	group by tramo_periodo_lote;

	IF (_tramoAnterior IS NULL OR _tramoAnterior='') THEN
		_tramoAnterior:='1- CORRIENTE';
		raise notice 'entro';
	END IF;

	RAISE NOTICE 'negocio : % _tramoAnterior: %',_negocio,_tramoAnterior;
	RETURN _tramoAnterior;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_tramo_anterior(character varying, character varying)
  OWNER TO postgres;
