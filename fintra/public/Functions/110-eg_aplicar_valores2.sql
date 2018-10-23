-- Function: eg_aplicar_valores2(integer, character varying, character varying, numeric)

-- DROP FUNCTION eg_aplicar_valores2(integer, character varying, character varying, numeric);

CREATE OR REPLACE FUNCTION eg_aplicar_valores2(ids integer, pla_owner character varying, reanticipo character varying, vlr numeric)
  RETURNS text AS
$BODY$
DECLARE


 recordTablaBanco record;
 valor numeric:=0;
 porcentaje_1 numeric:=0;
 descuento numeric:=0;
 neto numeric:=0;
 comision numeric:=0;
 consignar numeric:=0;

 retorno TEXT:='OK';

BEGIN

                /*Aplicamos los descuentos */

		valor := vlr;

		SELECT INTO porcentaje_1 vlr_desc FROM fin.descuentos_propietarios
			WHERE   nit  = pla_owner;

		IF(reanticipo = 'N' )THEN

			SELECT into recordTablaBanco table_code,descripcion,referencia FROM   tablagen
			WHERE table_type = 'VALDEFAULT'  AND   table_code = UPPER('PORANT');

			porcentaje_1:= recordTablaBanco.referencia;

		END IF;

		descuento := ( valor * porcentaje_1 )/100;
		neto := valor - descuento ;

		raise notice 'descuento: % neto %',descuento,neto;

		comision := 0;

		raise notice 'comision: % neto %',comision,neto;
		consignar:= round( neto - comision );

		UPDATE  fin.anticipos_pagos_terceros
			SET
			   porcentaje =  porcentaje_1,
			   vlr_descuento = descuento,
			   vlr_neto = neto,
			   vlr_combancaria  =comision,
			   vlr_consignacion = consignar
			WHERE
			  id  = ids
			  AND reg_status=''
			  AND agency_id NOT IN (SELECT table_code FROM tablagen WHERE table_type='AGENCIADES' AND reg_status!='A');


		return retorno ;

EXCEPTION

	WHEN foreign_key_violation THEN
		RAISE EXCEPTION 'La planilla no puede ser actualizada.';
		retorno='FAIL' ;
		return retorno;

	WHEN function_executed_no_return_statement THEN
		RAISE EXCEPTION 'Se ha superado el maximo de caracteres permitidos.';
		retorno='FAIL' ;
		return retorno;

	WHEN unique_violation THEN
		RAISE EXCEPTION 'Error Actualizando en la bd, ya existe en la base de datos.';
		retorno='FAIL' ;
		return retorno;


END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_aplicar_valores2(integer, character varying, character varying, numeric)
  OWNER TO postgres;
