-- Function: apicredit.eg_validar_siniestrohdc_fa(integer, character varying)

-- DROP FUNCTION apicredit.eg_validar_siniestrohdc_fa(integer, character varying);

CREATE OR REPLACE FUNCTION apicredit.eg_validar_siniestrohdc_fa(_idconvenio integer, _identificacion character varying)
  RETURNS SETOF apicredit.rs_valida_siniestro AS
$BODY$
DECLARE
  result apicredit.rs_valida_siniestro ;
  _recordConvenio record;
  _tipo_negocio varchar:='';
  respuesta varchar:='';
 BEGIN

	SELECT into _recordConvenio aval_tercero,aval_anombre,nit_anombre,factura_tercero  FROM convenios  WHERE id_convenio=_idconvenio;

	result.estado_neg := 'P';
	result.comentario := 'Solicitud aceptada';
	result.causal := '';
	result.reporte := '';
	result.nit_empresa:=_recordConvenio.nit_anombre;



  if(not _recordConvenio.aval_tercero)then
	--Validamos cedula reportada en siniestros
	respuesta:=coalesce((SELECT array_to_string(array_accum(r.mcedesrep), ', ')as descripcion
		      FROM fenalco.fcedfic cr
		      INNER JOIN fenalco.mreced r ON (cr.mcecodrep=r.mcecodrep)
		      WHERE cr.mcecodrep IN (5,6,8,11,52) AND cr.didnum=_identificacion
		      GROUP BY cr.didnum),'');

		      raise notice 'respuesta: %',respuesta;

		if(respuesta !='')then

			result.estado_neg := 'R';
			result.comentario := respuesta;
			result.causal := '17';
			result.resdeudor := 'RECHAZAD';

		else
			--si la unidad de negocio es educativo validamos las cuentas
			select into _tipo_negocio un.id from unidad_negocio  un
			inner join rel_unidadnegocio_convenios unc on (un.id=unc.id_unid_negocio)
			where unc.check_api='S' and unc.id_convenio =_idconvenio ;
			if(_tipo_negocio='2')then
				respuesta:=coalesce((SELECT to_char(sinconnum,'99999999') FROM fenalco.siniestr where  sinesta in('F','N','A','C') and   sindidnum=_identificacion limit 1),'');
				if(respuesta !='')then

					result.estado_neg := 'R';
					result.comentario := respuesta;
					result.causal := '18';
					result.resdeudor := 'RECHAZAD';

				END IF;

				--Validar solicitudes realizadas por una cedula desde el front
				if((select count(0) from apicredit.pre_solicitudes_creditos where identificacion=_identificacion and reg_status='')>3)then

				    result.estado_neg := 'R';
                                    result.comentario := 'maxima operacion permitida en un dia';
                                    result.causal := '19';
                                    result.reporte := 'error';

				end if;

			end if;

		end if;
  end if;

RETURN next result;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION apicredit.eg_validar_siniestrohdc_fa(integer, character varying)
  OWNER TO postgres;
