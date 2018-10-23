-- Function: etes.generar_reporte_produccion()

-- DROP FUNCTION etes.generar_reporte_produccion();

CREATE OR REPLACE FUNCTION etes.generar_reporte_produccion()
  RETURNS SETOF etes.rs_reporte_produccion AS
$BODY$
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
						SELECT
					   anticipo.id,
					   CASE WHEN anticipo.reg_status ='A' THEN 'ANULADO' END AS estado,
					   novedades.descripcion AS obs_anulacion,
					   prod_servicio.descripcion AS producto,
					   agencias.nombre_agencia,
					   conductor.cod_proveedor as nit_conductor,
					   conductor.nombre as nombre_conductor,
					   conductor.veto,
					   conductor.veto_causal,
					   propietario.cod_proveedor as nit_propietario,
					   propietario.nombre as nombre_propietario,
					   propietario.veto,
					   propietario.veto_causal,
					   vehiculo.placa,
					   anticipo.planilla,
					   to_char(anticipo.fecha_creacion_anticipo,'YYYY-MM-DD HH:MM:SS')::TIMESTAMP as fecha_anticipo,
					   to_char(anticipo.fecha_envio_fintra ,'YYYY-MM-DD HH:MM:SS')::TIMESTAMP  as fecha_envio,
					   to_char(anticipo.creation_date,'YYYY-MM-DD HH:MM:SS')::TIMESTAMP  as fecha_creacion_fintra,
					   'N'::TEXT AS reanticipo,
					   anticipo.creation_user AS usuario_creacion,
					   anticipo.aprobado,
					   anticipo.transferido,
					   transferencias.banco_transferencia,
					   transferencias.cuenta_transferencia,
					   transferencias.tipo_cuenta_transferencia ,
					   CASE WHEN anticipo.transferido='S' THEN transferencias.banco END AS banco_conductor,
					   CASE WHEN anticipo.transferido='S' THEN transferencias.no_cuenta END AS no_cuenta_conductor,
					   CASE WHEN anticipo.transferido='S' THEN transferencias.tipo_cuenta END AS tipo_cuenta_conductor,
					   CASE WHEN anticipo.transferido='S' THEN transferencias.nombre_titular_cuenta END AS nombre_cta_conductor,
					   CASE WHEN anticipo.transferido='S' THEN transferencias.cedula_titular_cuenta END AS nit_cuenta_conductor,
					   anticipo.valor_planilla,
					   anticipo.valor_neto_anticipo,
								0.0::NUMERIC AS porcentanje_dscto_ANTTRANSFERENCIA_1,
								0.0::NUMERIC AS valor_dscto_1,
								0.0::NUMERIC AS porcentanje_dscto_DESCUENTOATERCEROS_2,
								0.0::NUMERIC AS valor_dscto_2,
					   anticipo.valor_descuentos_fintra as total_dscto,
					   anticipo.valor_desembolsar as valor_neto,
					   coalesce(transferencias.valor_comision_bancaria,0.0) AS valor_comision,
					   (anticipo.valor_desembolsar - coalesce(transferencias.valor_comision_bancaria,0.0)) AS valor_consignado,
					   --to_char(anticipo.fecha_transferencia,'YYYY-MM-DD HH:MM:SS')::TIMESTAMP AS fecha_transferencia,
					   anticipo.fecha_transferencia,
					   anticipo.numero_egreso,
					   anticipo.valor_egreso,
					   agencias.id_transportadora,
					   (SELECT razon_social FROM etes.transportadoras  WHERE id=agencias.id_transportadora) AS transportadora,
					   anticipo.origen,
					   anticipo.destino,
					   anticipo.cxc_corrida as nro_corrida,etes.validar_legalizacion_anticipo(anticipo.id) as legalizacion
						FROM etes.manifiesto_carga AS anticipo
						LEFT JOIN etes.novedades_manifiesto AS novedades ON (anticipo.id=novedades.id_manifiesto_carga AND novedades.id_novedad=3)
						INNER JOIN etes.productos_servicios_transp AS prod_servicio ON (anticipo.id_proserv=prod_servicio.id )
						INNER JOIN etes.agencias AS agencias ON (anticipo.id_agencia=agencias.id )
						INNER JOIN etes.conductor AS conductor ON (anticipo.id_conductor=conductor.id)
						INNER JOIN etes.vehiculo AS vehiculo ON (anticipo.id_vehiculo=vehiculo.id)
						INNER JOIN etes.propietario  AS propietario ON (vehiculo.id_propietario=propietario.id)
						LEFT JOIN etes.transferencias_anticipos AS transferencias ON (transferencias.id_transportadora=agencias.id_transportadora
								AND transferencias.id_manifiesto_carga=anticipo.id AND anticipo.planilla=transferencias.planilla
								AND transferencias.reg_status!='A')
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
							WHERE anticipo.id=recordAnticipos.id AND descuentos.reanticipo='N')
				LOOP


					IF(contadorField =1)THEN
						IF(recordDinamico.porcentaje_descuento != 0)THEN
						 rs.porcentanje_dscto_ANTTRANSFERENCIA_1:= recordDinamico.porcentaje_descuento ;
						ELSE
						 rs.porcentanje_dscto_ANTTRANSFERENCIA_1:= 0.0 ;
						END IF;

						rs.valor_dscto_1:= recordDinamico.valor_descuento ;
					END IF ;


					IF(contadorField =2)THEN
						IF(recordDinamico.porcentaje_descuento != 0)THEN
						 rs.porcentanje_dscto_DESCUENTOATERCEROS_2:= recordDinamico.porcentaje_descuento ;
						ELSE
						 rs.porcentanje_dscto_DESCUENTOATERCEROS_2:= 0.0 ;
						END IF;

						rs.valor_dscto_2:= recordDinamico.valor_descuento ;
					END IF ;

					contadorField:=contadorField+1;
				END LOOP;

				RETURN NEXT rs;

				/**********************************************
				* Buscamos los reanticipos de cada manifiesto  *
				************************************************/


				FOR recordReanticipo IN (SELECT
								 CASE WHEN reanticipo.reg_status ='A' THEN 'ANULADO' END AS estado
								,reanticipo.id_manifiesto_carga
								,reanticipo.planilla
								,to_char(reanticipo.fecha_reanticipo,'YYYY-MM-DD HH24:MI:SS')::TIMESTAMP AS fecha_anticipo
								,to_char(reanticipo.fecha_envio_fintra,'YYYY-MM-DD HH24:MI:SS')::TIMESTAMP  AS fecha_envio
								,to_char(reanticipo.creation_date,'YYYY-MM-DD HH24:MI:SS')::TIMESTAMP  AS fecha_creacion_fintra
								,reanticipo.valor_reanticipo as valor_neto_reanticipo
								,'S'::TEXT AS reanticipo
								,reanticipo.creation_user
								,reanticipo.aprobado
								,reanticipo.transferido
								,transferencias.banco_transferencia
								,transferencias.cuenta_transferencia
								,transferencias.tipo_cuenta_transferencia
								,CASE WHEN reanticipo.transferido='S' THEN transferencias.banco END AS banco_conductor
								,CASE WHEN reanticipo.transferido='S' THEN transferencias.no_cuenta END AS no_cuenta_conductor
								,CASE WHEN reanticipo.transferido='S' THEN transferencias.tipo_cuenta END AS tipo_cuenta_conductor
								,CASE WHEN reanticipo.transferido='S' THEN transferencias.nombre_titular_cuenta END AS nombre_cta_conductor
								,CASE WHEN reanticipo.transferido='S' THEN transferencias.cedula_titular_cuenta END AS nit_cuenta_conductor
								,reanticipo.valor_descuentos_fintra AS total_dscto
								,reanticipo.valor_desembolsar AS valor_neto
								,coalesce(transferencias.valor_comision_bancaria,0.0) AS valor_comision
								,(reanticipo.valor_desembolsar - coalesce(transferencias.valor_comision_bancaria,0.0)) AS valor_consignado
								--,to_char(reanticipo.fecha_transferencia,'YYYY-MM-DD HH24:MI:SS')::TIMESTAMP as fecha_transferencia
								,reanticipo.fecha_transferencia
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
										AND transferencias.reg_status!='A')
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
							       WHERE anticipo.id=recordReanticipo.id_manifiesto_carga and descuentos.planilla=recordReanticipo.planilla AND descuentos.reanticipo='S')
					LOOP


					IF(contadorField =1)THEN
						IF(recordDinamico.porcentaje_descuento != 0)THEN
						 rs.porcentanje_dscto_ANTTRANSFERENCIA_1:= recordDinamico.porcentaje_descuento ;
						ELSE
						 rs.porcentanje_dscto_ANTTRANSFERENCIA_1:= 0.0 ;
						END IF;

						rs.valor_dscto_1:= recordDinamico.valor_descuento ;
					END IF ;


					IF(contadorField =2)THEN
						IF(recordDinamico.porcentaje_descuento != 0)THEN
						 rs.porcentanje_dscto_DESCUENTOATERCEROS_2:= recordDinamico.porcentaje_descuento ;
						ELSE
						 rs.porcentanje_dscto_DESCUENTOATERCEROS_2:= 0.0 ;
						END IF;

						rs.valor_dscto_2:= recordDinamico.valor_descuento ;
					END IF ;

						contadorField:=contadorField+1;
						raise notice 'entra reanticipo descuento';
					END LOOP;

					IF(contadorField = 1)THEN
					  rs.porcentanje_dscto_ANTTRANSFERENCIA_1:= 0.0 ;
						       rs.valor_dscto_1:= 0.0 ;
						       rs.porcentanje_dscto_DESCUENTOATERCEROS_2:= 0.0 ;
						       rs.valor_dscto_2:= 0.0 ;

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


		END $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.generar_reporte_produccion()
  OWNER TO postgres;
