-- Function: etes.guardar_venta_tsp_eds(text[], integer, integer, character varying, integer, character varying, integer, integer)

-- DROP FUNCTION etes.guardar_venta_tsp_eds(text[], integer, integer, character varying, integer, character varying, integer, integer);

CREATE OR REPLACE FUNCTION etes.guardar_venta_tsp_eds(productos text[], idestacion integer, idmanifiesto integer, planillaa character varying, kilometros integer, usuario character varying, idtransportadora integer, idproceso integer)
  RETURNS text AS
$BODY$
DECLARE

confProdRecord record;
valorComisionFintra numeric:=0;
numero_venta varchar:='';
retorno text:='OK';
spcontabilizar text:='';
valorGasolina numeric=0;
valorEfectivo numeric=0;

BEGIN
	/**Validacion 1: verificar que la planilla corresponde al id manifiesto**/
	IF(EXISTS (SELECT * FROM fin.anticipos_pagos_terceros_tsp  WHERE UPPER(planilla)=UPPER(planillaa) AND id=idmanifiesto))THEN
             IF(array_upper(productos, 1) > 0)THEN

		SELECT INTO numero_venta etes.serie_num_venta();
		FOR i IN 1 .. (array_upper(productos, 1)) LOOP

			/**Validacion 2: verificar que el producto corresponde a la eds de que realiza la operacion**/
			IF(EXISTS (SELECT * FROM etes.configcomerial_productos   WHERE id_eds=idestacion AND id_producto_es=productos[i][1]::integer))THEN

				/**VALIDACION 3: verificar que el total enviado sea igual al total calculado**/
				RAISE NOTICE 'DD %',ROUND(productos[i][3]::NUMERIC * productos[i][4]::NUMERIC,5);
				IF(ROUND(productos[i][3]::NUMERIC * productos[i][4]::NUMERIC,5)=productos[i][5]::NUMERIC)THEN

					--VALOR EFECTIVO
					if((SELECT cod_producto from etes.productos_es  where id=productos[i][1]::integer)='PES00001')then
						valorEfectivo:=ROUND(productos[i][3]::NUMERIC * productos[i][4]::NUMERIC,5);
					end if;

					--VALOR GASOLINA
					if((SELECT cod_producto from etes.productos_es  where id=productos[i][1]::integer)='PES00002')then
						valorGasolina:=ROUND(productos[i][3]::NUMERIC * productos[i][4]::NUMERIC,5);
					end if;

					--1.) CALCULAMOS EL VALOR COMISION DE FINTRA.
					SELECT INTO confProdRecord * FROM etes.configcomerial_productos   WHERE id_eds=idestacion AND id_producto_es=productos[i][1]::integer ;

					IF(confProdRecord.comision_afintra_xproducto='S')THEN

						IF(confProdRecord.porcentaje_ganancia_producto > 0)THEN --VENTA TOTAL
						   valorComisionFintra:=productos[i][5]::NUMERIC * (confProdRecord.porcentaje_ganancia_producto/100);
						END IF;
						IF(confProdRecord.valor_ganancia_producto > 0)THEN --XCANTIDAD
						   valorComisionFintra:=productos[i][4]::NUMERIC * confProdRecord.valor_ganancia_producto;
						END IF;

					ELSE
					 valorComisionFintra:=0;
					END IF;

					--2.) GUARDAMOS LOS ITEMS DE LA VENTA.
					INSERT INTO etes.ventas_eds_tsp(
						    reg_status, dstrct, id_transportadora, id_manifiesto_carga, id_eds, num_venta,
						    fecha_venta, periodo, kilometraje, id_producto, precio_producto_xunidadmedida,
						    cantidad_suministrada, total_venta, id_configcomercial_producto,
						    valor_comision_fintra, creation_date, creation_user, last_update,
						    user_update)
					    VALUES ('','FINV', idtransportadora, idmanifiesto, idestacion, numero_venta,
						    NOW(),REPLACE(SUBSTRING(NOW(),1,7),'-','')::varchar, kilometros, productos[i][1]::integer, productos[i][3]::NUMERIC,
						    productos[i][4]::NUMERIC,(productos[i][3]::NUMERIC * productos[i][4]::NUMERIC),confProdRecord.id,
						    valorComisionFintra,NOW(), usuario, '0099-01-01 00:00:00',
						    '');

					--2.) ACTUALIZAMOS EL PRECIO EN LA CONFIGURACION COMERCIAL DE PRODUCTOS.
					UPDATE etes.configcomerial_productos
					   SET precio_producto= productos[i][3]::numeric,
					       last_update=NOW(),
					       user_update=usuario
					WHERE id_eds=idestacion AND id_producto_es=productos[i][1]::integer ;


					retorno:='OK'||numero_venta;

				ELSE
					retorno:='EL VALOR TOTAL  PARA EL PRODUCTO ID : '||productos[i][1]||' NOMBRE :'|| productos[i][2] ||' NO ES IGUAL AL CALCULAO.';
					RAISE EXCEPTION 'ERROR VALIDANDO TOTAL PRODUCTO';
					EXIT;
				END IF;

			ELSE
				retorno:='EL PRODUCTO ID : '||productos[i][1]||' :: NOMBRE :'|| productos[i][2] ||' NO FUE ENCONTRADO EN LA CONFIGURACION.';
				RAISE EXCEPTION 'ERROR VALIDANDO CONFIGURACION DEL PRODUCTO';
				EXIT;
			END IF;

			RAISE NOTICE 'indice i: % indice j: % id_producto : %',i,1, productos[i][1];
			RAISE NOTICE 'indice i: % indice j: % nombre_producto : %',i,2, productos[i][2];
			RAISE NOTICE 'indice i: % indice j: % precio_xunidad : %',i,3, productos[i][3];
			RAISE NOTICE 'indice i: % indice j: % cantidad : %',i,4, productos[i][4];
			RAISE NOTICE 'indice i: % indice j: % total : %',i,5, productos[i][5];

		END LOOP;

			--Aceptar el anticipo gasolina aceptarAnticipoGasolina de tsp.
			raise notice 'VALOR GASOLINA: % VALOR EFECTIVO: % ',valorGasolina,valorEfectivo;
			UPDATE fin.anticipos_pagos_terceros_tsp
			SET estado_pago_tercero='A',
			    user_update= usuario ,
			    vlr_efectivo=vlr_efectivo+valorEfectivo,
			    vlr_gasolina=vlr_gasolina+valorGasolina,
			    last_update=now(),
			    fecha_autorizacion=now(),
			    user_autorizacion=usuario,
			    vlr_neto=(vlr-(((get_porcentaje_descuento_gasolina(usuario,agency_id))/100)*vlr))
			WHERE
			id = idmanifiesto AND estado_pago_tercero NOT IN ('P')
			AND reg_status='' ;

             ELSE
		retorno:='LA LISTA DE PRODUCTOS ESTA VACIA.';
             END IF;
	ELSE
	  retorno:='LA PLANILLA NRO ' ||planillaa||', NO CORRESPONDE CON EL DEL MANIFIESTO DE CARGA.';
	END IF;

	/************ MARCAMOS LA TRAMA COMO PROCESADA ************/
	/*UPDATE etes.trama_anticipos
	   SET procesado=true,
	       fecha_fin_proceso=now()
	 WHERE id=idproceso;*/
RETURN retorno;
EXCEPTION
	WHEN raise_exception THEN
	  return retorno;
	WHEN foreign_key_violation THEN
		RAISE EXCEPTION 'NO EXISTEN DEPENDENCIAS FORANEAS PARA ALGUNOS REGISTROS.';
	WHEN  null_value_not_allowed  THEN
		RAISE EXCEPTION 'VALOR NULO NO PERMITIDO';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.guardar_venta_tsp_eds(text[], integer, integer, character varying, integer, character varying, integer, integer)
  OWNER TO postgres;
