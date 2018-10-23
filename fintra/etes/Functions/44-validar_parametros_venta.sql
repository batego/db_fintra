-- Function: etes.validar_parametros_venta(integer, character varying, character varying, character varying)

-- DROP FUNCTION etes.validar_parametros_venta(integer, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION etes.validar_parametros_venta(idtransportadora integer, planillaa character varying, cedula_conductor character varying, placaa character varying)
  RETURNS text AS
$BODY$
DECLARE

retorno text:='OK';

BEGIN

     --VALIDAMOS QUE LA TRANSPORTADORA ESTE AUTORIZADA Y TENGA CUPO DISPONIBLE, PARA QUE LA ESTACION ENTREGUE EL ANTICIPO.
     if((SELECT autoriza_venta FROM etes.transportadoras  WHERE id=idtransportadora)='S' and etes.validar_cupo_transportadora(idtransportadora))THEN

	     --VALIDAR SI EXISTE LA PALNILA PARA EL PRODUCTO DE GASOLINA---
	     PERFORM * FROM etes.manifiesto_carga WHERE UPPER(planilla)=UPPER(planillaa) and id_proserv=1 ;
	      IF(FOUND)THEN
		   --VALIDAR SI EXISTE PARA EL CONDUCTOR---
		   PERFORM * FROM etes.manifiesto_carga WHERE UPPER(planilla)=UPPER(planillaa) AND id_conductor = (SELECT id FROM etes.conductor WHERE  cod_proveedor= cedula_conductor) ;
		      IF(FOUND)THEN
			  --VALIDAR SI EXISTE PARA EL CONDUCTOR Y VEHICULO--
			  PERFORM * FROM etes.manifiesto_carga
				    WHERE UPPER(planilla)=UPPER(planillaa)
				    AND id_conductor =(SELECT id FROM etes.conductor WHERE  cod_proveedor= cedula_conductor)
				    AND id_vehiculo =(SELECT id FROM etes.vehiculo  WHERE  UPPER(placa)=UPPER(placaa));
			      IF(FOUND)THEN
				    --VALIDAR TRANSPORTADORA POR AGENCIA---
				   PERFORM * FROM etes.manifiesto_carga
						  WHERE UPPER(planilla)=UPPER(planillaa)
						  AND id_conductor =(SELECT id FROM etes.conductor WHERE  cod_proveedor= cedula_conductor)
						  AND id_vehiculo =(SELECT id FROM etes.vehiculo  WHERE  UPPER(placa)= UPPER(placaa))
						  and id_agencia IN (SELECT id FROM etes.agencias WHERE id_transportadora= idtransportadora);
				      IF(FOUND)THEN
					retorno :='OK';
				      ELSE
					retorno:='LA TRANSPORTADORA NO CORRESPONDE CON EL NUMERO DE PLANILLA.';
				      END IF;
			      ELSE
				  retorno:='LA PLACA DEL VEHICULO NO CORRESPONDE CON EL NUMERO DE PLANILLA.';
			      END IF;
		      ELSE
			retorno:='LA CEDULA DEL CONDUCTOR NO CORRESPONDE CON EL NUMERO DE PLANILLA.';
		      END IF;
	      ELSE
		retorno:='PLANILLA NO REGISTRADA.';
	      END IF;
	ELSE
	  retorno:='CODIGO R1, COMUNIQUESE CON LA TRANSPORTADORA.';
	END IF;


RETURN retorno;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.validar_parametros_venta(integer, character varying, character varying, character varying)
  OWNER TO postgres;
