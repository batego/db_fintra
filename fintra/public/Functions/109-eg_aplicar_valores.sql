-- Function: eg_aplicar_valores(integer, character varying, character varying, character varying, numeric, character varying, character varying, character varying)

-- DROP FUNCTION eg_aplicar_valores(integer, character varying, character varying, character varying, numeric, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION eg_aplicar_valores(ids integer, pla_owner character varying, reanticipo character varying, descripcion character varying, vlr numeric, tipo_cuenta character varying, banco character varying, bancoin character varying)
  RETURNS text AS
$BODY$
DECLARE

 recordTablaBanco record;

 valor numeric:=0;
 tipoCTA varchar:='';
 bancof  varchar:='';
 bancoNuevo varchar:='';
 porcentaje_1 numeric:=0;
 descuento numeric:=0;
 neto numeric:=0;
 comision numeric:=0;
 consignar numeric:=0;

 retorno TEXT:='OK';

BEGIN

		valor := vlr;
		tipoCTA :=tipo_cuenta;
		bancof := banco;

		SELECT INTO porcentaje_1 vlr_desc FROM fin.descuentos_propietarios
			WHERE   nit  = pla_owner;

		IF(reanticipo = 'N' )THEN

			SELECT into recordTablaBanco table_code,descripcion,referencia FROM   tablagen
			WHERE table_type = 'VALDEFAULT'  AND   table_code = UPPER('PORANT');

			porcentaje_1:= recordTablaBanco.referencia;

		END IF;

                raise notice 'porcentaje_1 %', porcentaje_1;

		descuento := ( valor * porcentaje_1 )/100;
		neto := valor - descuento ;

		/* ****************************************
		 *   Validamos los bancos de entrada.      *
		*******************************************/
                raise notice 'BANCOIN: %',BancoIN;
		IF( BancoIN = 'OCCIDENTE' OR BancoIN = '23' ) THEN
			bancoNuevo:='BANCO OCCIDENTE';
		END IF;

		IF( BancoIN = '' OR BancoIN = '07' OR BancoIN ='7B' )THEN
			bancoNuevo:='BANCOLOMBIA';
		END IF;

                raise notice 'bancoNuevo: % bancoof: % bancoin: %',bancoNuevo,bancof,bancoin;
                comision :=0;

                raise notice 'tipoCTA: %',tipoCTA;
		IF( bancoNuevo = bancof )THEN

			IF(tipoCTA = 'EF')THEN
			 SELECT INTO comision cb.valor FROM comisiones_bancos as cb WHERE banco_transfer='EFECTIVO' and anio= substring(now(),1,4) ;
			ELSE
			 SELECT INTO comision cb.valor FROM comisiones_bancos as cb WHERE banco_transfer='TRANSFERENCIA' and anio= substring(now(),1,4) ;
			END IF;
		ELSE
			IF(tipoCTA = 'EF')THEN
			 SELECT INTO comision cb.valor FROM comisiones_bancos as cb WHERE banco_transfer='EFECTIVO_BB' and anio= substring(now(),1,4) ;
			ELSE
				if (bancoin = 'CT')then
					SELECT INTO comision cb.valor FROM comisiones_bancos as cb WHERE banco_transfer='TRANSFERENCIA' and anio= substring(now(),1,4) ;
				else
					SELECT INTO comision cb.valor FROM comisiones_bancos as cb WHERE banco_transfer='TRANSFERENCIA_BB' and anio= substring(now(),1,4) ;
				end if;

			END IF;

		END IF;
		raise notice 'comision: %',comision;
		IF(descripcion = 'EFECTIVO')THEN
			comision := 0;
		END IF;


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
ALTER FUNCTION eg_aplicar_valores(integer, character varying, character varying, character varying, numeric, character varying, character varying, character varying)
  OWNER TO postgres;
