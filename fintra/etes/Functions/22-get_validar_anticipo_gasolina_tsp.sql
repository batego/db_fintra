-- Function: etes.get_validar_anticipo_gasolina_tsp(integer, character varying, character varying, character varying, character varying)

-- DROP FUNCTION etes.get_validar_anticipo_gasolina_tsp(integer, character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION etes.get_validar_anticipo_gasolina_tsp(idtransportadora integer, cedula_conductor character varying, placa character varying, planillaa character varying, usuario character varying)
  RETURNS text AS
$BODY$
DECLARE

validarAnticipoTSP etes.rs_anticipo_gasolina ;
retorno text:='';

BEGIN
--VALIDAMOS QUE LA TRANSPORTADORA ESTE AUTORIZADA Y TENGA CUPO DISPONIBLE, PARA QUE LA ESTACION ENTREGUE EL ANTICIPO.
     if((SELECT autoriza_venta FROM etes.transportadoras  WHERE id=idtransportadora)='S')THEN

       --1.)Validamos la disponibilidad de la planilla en la tablas de tsp.
	SELECT INTO validarAnticipoTSP  * FROM etes.validar_info_anticipo_tsp(cedula_conductor,placa, planillaa,usuario);

	if (validarAnticipoTSP.tipo_anticipo_busqueda='ERRORLOGIN') then
                retorno:='LO SENTIMOS NO TIENE DESCUENTOS ASIGNADOS.;'||0;
	ELSIF(validarAnticipoTSP.tipo_anticipo_busqueda='ANTICIPO2' OR validarAnticipoTSP.tipo_anticipo_busqueda='ANTICIPO3')THEN

		retorno:='ANTICIPO ENCONTRADO';
		raise notice 'validarAnticipoTSP.vlr_neto_real : %',validarAnticipoTSP.vlr_neto_real;
		IF(validarAnticipoTSP.vlr_neto_real > 0)THEN
			retorno:='OK;'||validarAnticipoTSP.vlr_neto_real||';'||validarAnticipoTSP.id;
		else
			retorno:='LA PLANILLA INGRESADA NO TIENE SALDO DISPONIBLE.;'||0;
		END IF;

	ELSIF(validarAnticipoTSP.tipo_anticipo_busqueda='NOENCONTRADO')THEN

		retorno:='LO SENTIMOS PLANILLA NO ENCONTRADA VERIFIQUE LOS DATOS DE ENTRADA.;'||0;

	end if;
    ELSE
	  retorno:='CODIGO R1, COMUNIQUESE CON LA TRANSPORTADORA.;'||0;
    end if;

RETURN retorno;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.get_validar_anticipo_gasolina_tsp(integer, character varying, character varying, character varying, character varying)
  OWNER TO postgres;
