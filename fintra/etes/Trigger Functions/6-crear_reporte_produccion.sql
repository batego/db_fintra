-- Function: etes.crear_reporte_produccion()

-- DROP FUNCTION etes.crear_reporte_produccion();

CREATE OR REPLACE FUNCTION etes.crear_reporte_produccion()
  RETURNS "trigger" AS
$BODY$
DECLARE

recordField RECORD;
recordConfProductos RECORD;
contadorComas INTEGER=1;
contadorField INTEGER=1;
fielType TEXT:='';
fieldAnticipo TEXT:='';
setFieldDinamico TEXT:='';
setFieldCero TEXT :='';

BEGIN


   IF(exists (select 1 from pg_type where typname = 'rs_reporte_produccion')) THEN
     DROP TYPE etes.rs_reporte_produccion CASCADE;
   END IF;

        FOR recordField in (SELECT * FROM etes.field_reporte_produccion WHERE secuencia_field !='R' order by id) LOOP

		IF(contadorComas = (SELECT COUNT(0) FROM etes.field_reporte_produccion WHERE secuencia_field !='R' ))THEN

				fielType := fielType || recordField.name_field ||' '|| recordField.type_field;
				fieldAnticipo:=fieldAnticipo || recordField.parse_anticipo  ;

		ELSE
			--Escluimos los campos dinamicos
			IF(recordField.dinamico !='S')THEN
				fielType := fielType ||'
					   '|| recordField.name_field ||' '|| recordField.type_field || ',';

				fieldAnticipo:=fieldAnticipo||'
					   '||recordField.parse_anticipo || ',';

			ELSIF(recordField.dinamico='S')THEN

				FOR recordConfProductos IN (SELECT * FROM etes.config_productos_descuentos) LOOP

					--CAMPOS DINAMICOS DEL TIPO.
					fielType := fielType ||'porcentanje_dscto_'||recordConfProductos.descripcion_corta||'_'||contadorField||' numeric ,
							'||recordField.secuencia_field||'_'||contadorField||' numeric ,';

					--CAMPOS DINAMICOS DEL ANTICIPO.
					fieldAnticipo:=fieldAnticipo||'
								0.0::NUMERIC AS porcentanje_dscto_'||recordConfProductos.descripcion_corta||'_'||contadorField||',
								0.0::NUMERIC AS '||recordField.secuencia_field||'_'||contadorField||',';


					--ASIGNACION DE VALORES A CAMPOS DINAMICOS.
					setFieldDinamico:=setFieldDinamico||'

					IF(contadorField ='||contadorField||')THEN
						IF(recordDinamico.porcentaje_descuento != 0)THEN
						 rs.porcentanje_dscto_'||recordConfProductos.descripcion_corta||'_'||contadorField||':= recordDinamico.porcentaje_descuento ;
						ELSE
						 rs.porcentanje_dscto_'||recordConfProductos.descripcion_corta||'_'||contadorField||':= 0.0 ;
						END IF;

						rs.'||recordField.secuencia_field||'_'||contadorField||':= recordDinamico.valor_descuento ;
					END IF ;
					';--NO QUITAR ES COMA DE AQUI ASI CREAN QUE NO HACE NADA.

					--CAMPOS DINAMICOS EN CERO
					setFieldCero:=setFieldCero||'rs.porcentanje_dscto_'||recordConfProductos.descripcion_corta||'_'||contadorField||':= 0.0 ;
						       rs.'||recordField.secuencia_field||'_'||contadorField||':= 0.0 ;
						       '; --NO QUITAR ES COMA DE AQUI ASI CREAN QUE NO HACE NADA.

					contadorField:= contadorField+1;

				END LOOP;
			END IF;
		END IF;
		contadorComas:=contadorComas+1;
        END LOOP;

	EXECUTE 'CREATE TYPE etes.rs_reporte_produccion AS ( '||fielType||' );
	         ALTER TYPE rs_planillas_transferencia
	         OWNER TO postgres';


     /***********************************************************************************************************/
     /***********************************************************************************************************/


	EXECUTE 'CREATE OR REPLACE FUNCTION etes.generar_reporte_produccion()
		  RETURNS SETOF etes.rs_reporte_produccion AS $x$
		DECLARE

		 recordAnticipos record;
		 recordDinamico record;
		 rs etes.rs_reporte_produccion;
		 recordReanticipo record;
		 recordDescuentos record;
		 valorPlanilla numeric:=0;
		 contadorField INTEGER=1;

		BEGIN

			FOR recordAnticipos IN (
						SELECT '||fieldAnticipo ||'
						FROM etes.manifiesto_carga AS anticipo
						LEFT JOIN etes.novedades_manifiesto AS novedades ON (anticipo.id=novedades.id_manifiesto_carga AND novedades.id_novedad=3)
						INNER JOIN etes.productos_servicios_transp AS prod_servicio ON (anticipo.id_proserv=prod_servicio.id )
						INNER JOIN etes.agencias AS agencias ON (anticipo.id_agencia=agencias.id )
						INNER JOIN etes.conductor AS conductor ON (anticipo.id_conductor=conductor.id)
						INNER JOIN etes.vehiculo AS vehiculo ON (anticipo.id_vehiculo=vehiculo.id)
						INNER JOIN etes.propietario  AS propietario ON (vehiculo.id_propietario=propietario.id)
						LEFT JOIN etes.transferencias_anticipos AS transferencias ON (transferencias.id_transportadora=agencias.id_transportadora
								AND transferencias.id_manifiesto_carga=anticipo.id AND anticipo.planilla=transferencias.planilla
								AND transferencias.reg_status!=''A'')
						--WHERE anticipo.id=5
						ORDER BY anticipo.fecha_envio_fintra
						)
			LOOP


		                 rs:=recordAnticipos;
				 contadorField:=1;
				/***************************************************************
				****************** BUSCAMOS LOS CAMPOS DINAMICOS  **************
				****************************************************************/
				FOR recordDinamico IN (SELECT descuentos.porcentaje_descuento,descuentos.valor_descuento
							FROM etes.manifiesto_carga AS anticipo
							INNER JOIN etes.manifiesto_descuentos AS descuentos ON (descuentos.id_manifiesto_carga=anticipo.id)
							INNER JOIN etes.config_productos_descuentos  AS configuracion ON (descuentos.id_productos_descuentos=configuracion.id)
							WHERE anticipo.id=recordAnticipos.id AND descuentos.reanticipo=''N'')
				LOOP
					'||setFieldDinamico||'
					contadorField:=contadorField+1;
				END LOOP;

				RETURN NEXT rs;

				/**********************************************
				* Buscamos los reanticipos de cada manifiesto  *
				************************************************/


				FOR recordReanticipo IN (SELECT
								 CASE WHEN reanticipo.reg_status =''A'' THEN ''ANULADO'' END AS estado
								,reanticipo.id_manifiesto_carga
								,reanticipo.planilla
								,to_char(reanticipo.fecha_reanticipo,''YYYY-MM-DD HH24:MI:SS'')::TIMESTAMP AS fecha_anticipo
								,to_char(reanticipo.fecha_envio_fintra,''YYYY-MM-DD HH24:MI:SS'')::TIMESTAMP  AS fecha_envio
								,to_char(reanticipo.creation_date,''YYYY-MM-DD HH24:MI:SS'')::TIMESTAMP  AS fecha_creacion_fintra
								,reanticipo.valor_reanticipo as valor_neto_reanticipo
								,''S''::TEXT AS reanticipo
								,reanticipo.creation_user
								,reanticipo.aprobado
								,reanticipo.transferido
								,transferencias.banco_transferencia
								,transferencias.cuenta_transferencia
								,transferencias.tipo_cuenta_transferencia
								,CASE WHEN reanticipo.transferido=''S'' THEN transferencias.banco END AS banco_conductor
								,CASE WHEN reanticipo.transferido=''S'' THEN transferencias.no_cuenta END AS no_cuenta_conductor
								,CASE WHEN reanticipo.transferido=''S'' THEN transferencias.tipo_cuenta END AS tipo_cuenta_conductor
								,CASE WHEN reanticipo.transferido=''S'' THEN transferencias.nombre_titular_cuenta END AS nombre_cta_conductor
								,CASE WHEN reanticipo.transferido=''S'' THEN transferencias.cedula_titular_cuenta END AS nit_cuenta_conductor
								,reanticipo.valor_descuentos_fintra AS total_dscto
								,reanticipo.valor_desembolsar AS valor_neto
								,coalesce(transferencias.valor_comision_bancaria,0.0) AS valor_comision
								,(reanticipo.valor_desembolsar - coalesce(transferencias.valor_comision_bancaria,0.0)) AS valor_consignado
								,to_char(reanticipo.fecha_transferencia,''YYYY-MM-DD HH24:MI:SS'')::TIMESTAMP as fecha_transferencia
								,reanticipo.numero_egreso
								,reanticipo.valor_egreso
								,reanticipo.origen
								,reanticipo.destino
								,reanticipo.cxc_corrida as nro_corrida
							    FROM  etes.manifiesto_reanticipos  AS reanticipo
								LEFT JOIN etes.manifiesto_carga  AS anticipo ON (reanticipo.id_manifiesto_carga= anticipo.id)
								INNER JOIN etes.conductor AS conductor ON (conductor.id=anticipo.id_conductor)
								INNER JOIN etes.vehiculo AS vehiculo ON (vehiculo.id=anticipo.id_vehiculo)
								INNER JOIN etes.agencias AS agencia ON (agencia.id=anticipo.id_agencia)
								LEFT JOIN etes.transferencias_anticipos AS transferencias ON (transferencias.id_transportadora=agencia.id_transportadora
										AND transferencias.id_manifiesto_carga=reanticipo.id_manifiesto_carga AND reanticipo.planilla=transferencias.planilla
										AND transferencias.reg_status!=''A'')
								WHERE
								anticipo.planilla=rs.planilla
								AND conductor.cod_proveedor=rs.nit_conductor
								AND vehiculo.placa=rs.placa
								AND reanticipo.id_manifiesto_carga=rs.id
								ORDER BY reanticipo.creation_date
							    )



				LOOP

					/*****************************************************************
					* Llenamos la info del reporte con la informacion del reanticipo *
					******************************************************************/
					rs.estado=recordReanticipo.estado;
					rs.planilla :=recordReanticipo.planilla;
					rs.fecha_anticipo := recordReanticipo.fecha_anticipo;
					rs.fecha_envio := recordReanticipo.fecha_envio;
					rs.fecha_creacion_fintra := recordReanticipo.fecha_creacion_fintra;
					rs.valor_anticipo := recordReanticipo.valor_neto_reanticipo;
					rs.reanticipo := recordReanticipo.reanticipo ;
					rs.usuario_creacion := recordReanticipo.creation_user;
					rs.aprobado :=recordReanticipo.aprobado;
					rs.transferido :=recordReanticipo.transferido;
					rs.banco_transferencia :=recordReanticipo.banco_transferencia;
					rs.cuenta_transferencia :=recordReanticipo.cuenta_transferencia;
					rs.tipo_cuenta_transferencia :=recordReanticipo.tipo_cuenta_transferencia;
					rs.banco :=recordReanticipo.banco_conductor;
					rs.cuenta :=recordReanticipo.no_cuenta_conductor;
					rs.tipo_cuenta :=recordReanticipo.tipo_cuenta_conductor;
					rs.nombre_cuenta :=recordReanticipo.nombre_cta_conductor;
					rs.nit_cuenta :=recordReanticipo.nit_cuenta_conductor;


					/***************************************************************
					****************** BUSCAMOS LOS CAMPOS DINAMICOS  **************
					****************************************************************/
					contadorField:=1;
					FOR recordDinamico IN (SELECT descuentos.porcentaje_descuento,descuentos.valor_descuento
							       FROM etes.manifiesto_carga AS anticipo
							       INNER JOIN etes.manifiesto_descuentos AS descuentos ON (descuentos.id_manifiesto_carga=anticipo.id)
							       INNER JOIN etes.config_productos_descuentos  AS configuracion ON (descuentos.id_productos_descuentos=configuracion.id)
							       WHERE anticipo.id=recordReanticipo.id_manifiesto_carga and descuentos.planilla=recordReanticipo.planilla AND descuentos.reanticipo=''S'')
					LOOP
						'||setFieldDinamico||'
						contadorField:=contadorField+1;
						raise notice ''entra reanticipo descuento'';
					END LOOP;

					IF(contadorField = 1)THEN
					  '||setFieldCero||'
					END IF;

					rs.total_dscto :=recordReanticipo.total_dscto ;
					rs.valor_anticipo_con_descuento :=recordReanticipo.valor_neto ;
					rs.valor_comision :=recordReanticipo.valor_comision;
					rs.valor_consignado :=recordReanticipo.valor_consignado;
					rs.fecha_transferencia :=recordReanticipo.fecha_transferencia;
					rs.numero_egreso := recordReanticipo.numero_egreso ;
					rs.valor_egreso := recordReanticipo.valor_egreso ;
					rs.origen :=recordReanticipo.origen;
					rs.destino :=recordReanticipo.destino;
					rs.nro_corrida :=recordReanticipo.nro_corrida ;

					RETURN NEXT rs;


				END LOOP;

			END LOOP;


		END $x$ LANGUAGE plpgsql';


     /***********************************************************************************************************/
     /***********************************************************************************************************/
 RETURN NEW;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.crear_reporte_produccion()
  OWNER TO postgres;
