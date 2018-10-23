-- Function: eg_unificarfichasagente(character varying, character varying, character varying, character varying, character varying, character varying, character varying)

-- DROP FUNCTION eg_unificarfichasagente(character varying, character varying, character varying, character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION eg_unificarfichasagente(_usuario character varying, _vencimiento character varying, _periodo character varying, _uni_negocio character varying, _agente character varying, _ciclo character varying, _juridica character varying)
  RETURNS SETOF tem.negocios_fichas_impresion AS
$BODY$
DECLARE

		rs           tem.NEGOCIOS_FICHAS_IMPRESION;
		recordfichas RECORD;

BEGIN

		--1.)BORRAMOS LA TABLA TEMPORAL POR USUARIO DE CONSULTA...
		DELETE FROM tem.negocios_fichas_impresion
		WHERE creation_user = _usuario;

		--1.)INSERTAMOS EN LA TABLA TEMPORAL POR USUARIO DE CONSULTA...
		RAISE NOTICE 'INSERTANDO DATOS ....******.....';
		INSERT INTO tem.negocios_fichas_impresion (cod_neg, vencimiento_mayor, cuotas_vencidas, saldo_vencido,
		                                           total, tipo_principal, identificacion, nombre, direccion, departamento,
		                                           barrio, ciudad, telefono, telefono2, celular, id_cony, nom_cony,
		                                           telefono_cony, celular_cony, direccion_cony, nombre_empresa,
		                                           direccion_empresa, ciudad_empresa, telefono_empresa, nombre_negocio,
		                                           direccion_negocio, departamento_negocio, ciudad_negocio, barrio_negocio,
		                                           tipo_referencia, parentesco, nombre_referencia, telefono1_referencia,
		                                           telefono2_referencia, celular_referencia, etapa_proc_ejec, num_ciclo,
		                                           creation_user, dia_pago, valor_cuota)

				(SELECT DISTINCT
						 ng.cod_neg,
						 fc.vencimiento_mayor,
						 ----------------------cartera----------------------
						 cuota_pendientes_credito(ng.cod_neg, fc.periodo_lote) :: INTEGER AS cuotas_vencidas,
						 ('$ ' || trim(to_char(fcv.total, '999G999G999G999D99'))) :: TEXT AS saldo_vencido,
						 ('$ ' || trim(to_char(fc.total, '999G999G999G999D99'))) :: TEXT  AS total,
						 --'0099-01-01'::date AS fecha_ult_pago,
						 --('$ '||trim(to_char(0,'999G999G999G999D99'))) AS vlr_ult_pago,
						 ----------------------personales----------------------
						 CASE WHEN sp.tipo = 'S'
								 THEN 'deudor'
						 WHEN sp.tipo = 'C' OR sp.tipo = 'E'
								 THEN 'codeudor'
						 ELSE sp.tipo END                                                 AS tipo_principal,
						 sp.identificacion,
						 sp.nombre,
						 sp.direccion,
						 (SELECT department_name
						  FROM estado
						  WHERE department_code = sp.departamento)                        AS departamento,
						 sp.barrio,
						 (SELECT nomciu
						  FROM ciudad
						  WHERE codciu = sp.ciudad)                                       AS ciudad,
						 sp.telefono,
						 sp.telefono2,
						 sp.celular,
						 sp.id_cony,
						 (sp.primer_apellido_cony || ' ' || sp.segundo_apellido_cony || ' ' || sp.primer_nombre_cony || ' ' ||
						  sp.segundo_nombre_cony)                                         AS nom_cony,
						 sp.telefono_cony,
						 sp.celular_cony,
						 sp.direccion_cony,
						 ----------------------laborales----------------------
						 COALESCE(sl.nombre_empresa, '')                                  AS nombre_empresa,
						 COALESCE(sl.direccion, '')                                       AS direccion_empresa,
						 COALESCE((SELECT nomciu
						           FROM ciudad
						           WHERE codciu = sl.ciudad), '')                         AS ciudad_empresa,
						 COALESCE(sl.telefono, '')                                        AS telefono_empresa,
						 ----------------------negocio----------------------
						 COALESCE(sn.nombre, '')                                          AS nombre_negocio,
						 COALESCE(sn.direccion, '')                                       AS direccion_negocio,
						 COALESCE((SELECT department_name
						           FROM estado
						           WHERE department_code = sn.departamento), '')          AS departamento_negocio,
						 COALESCE((SELECT nomciu
						           FROM ciudad
						           WHERE codciu = sn.ciudad), '')                         AS ciudad_negocio,
						 COALESCE(sn.barrio, '')                                          AS barrio_negocio,
						 ----------------------referencias----------------------
						 CASE WHEN sr.tipo_referencia = 'F'
								 THEN 'familiar'
						 WHEN sr.tipo_referencia = 'P'
								 THEN 'personal'
						 ELSE '' END                                                      AS tipo_referencia,
						 sr.parentesco,
						 sr.nombre                                                        AS nombre_referencia,
						 sr.telefono1                                                     AS telefono1_referencia,
						 sr.telefono2                                                     AS telefono2_referencia,
						 sr.celular                                                       AS celular_referencia,
						 ng.etapa_proc_ejec,
						 ng.num_ciclo :: INTEGER,
						 _usuario :: VARCHAR                                              AS creation_user,
						 -- 						 dia_pago,
						 ''                                                               AS dia_pago,
						 (SELECT ('$ ' || trim(to_char((valor), '999G999G999G999D99'))) AS valor_cuota
						  FROM documentos_neg_aceptado
						  WHERE cod_neg = ng.cod_neg
						  LIMIT 1)
				 FROM negocios ng
						 INNER JOIN (

								            SELECT
										            negasoc,
										            vencimiento_mayor,
										            count(*)           AS cuotas_vencidas,
										            sum(debido_cobrar) AS total,
										            agente_campo,
										            id_convenio,
										            _periodo           AS periodo_lote--,
								            -- 										            dia_pago
								            FROM SP_SeguimientoCartera2(_periodo :: NUMERIC, _uni_negocio,
								                                        'ASIGNA' :: VARCHAR) AS coco(cedula VARCHAR, nombre VARCHAR, direccion VARCHAR, ciudad VARCHAR, telefono VARCHAR, telcontacto VARCHAR, negasoc VARCHAR, id_convenio VARCHAR, pagaduria VARCHAR, cuota VARCHAR, valor_asignado NUMERIC, fecha_vencimiento DATE, periodo_vcto NUMERIC, vencimiento_mayor VARCHAR, dias_vencidos NUMERIC, dia_pago NUMERIC, status VARCHAR, status_vencimiento VARCHAR, debido_cobrar NUMERIC, recaudosxcuota_fiducia NUMERIC, recaudosxcuota_fenalco NUMERIC, recaudosxcuota NUMERIC, agente VARCHAR, agente_campo VARCHAR)
								            WHERE
										            CASE WHEN _vencimiento = 'true'
												            THEN TRUE
										            ELSE vencimiento_mayor = _vencimiento END AND --parametro uno
										            CASE WHEN (vencimiento_mayor = '1- CORRIENTE' OR '3' = _uni_negocio)
												            THEN status = 'A Vencer'
										            ELSE status IN ('A Vencer', 'Vencido', 'Al Dia') END AND agente_campo = _agente
								            GROUP BY negasoc, vencimiento_mayor, agente_campo, id_convenio, periodo_lote--, dia_pago

						            ) fc ON (fc.negasoc = ng.cod_neg)
						 INNER JOIN (
								            SELECT
										            SUM(valor_saldo) AS total,
										            COUNT(*)         AS cuotas_vencidas,
										            negasoc,
										            agente_campo,
										            periodo_lote
								            FROM con.foto_cartera
								            WHERE reg_status != 'A'
								                  AND dstrct = 'FINV'
								                  AND tipo_documento IN ('FAC', 'NDC')
								                  AND substring(documento, 1, 2) NOT IN ('CP', 'FF', 'DF')
								                  AND valor_saldo > 0
								                  AND fecha_vencimiento <= now() :: DATE
								            GROUP BY negasoc, agente_campo, periodo_lote
						            ) fcv ON (fcv.negasoc = fc.negasoc AND fcv.agente_campo = fc.agente_campo AND
						                      fcv.periodo_lote = fc.periodo_lote)
						 INNER JOIN solicitud_aval sv ON (sv.cod_neg = ng.cod_neg AND sv.estado_sol != 'R')
						 INNER JOIN solicitud_persona sp
								 ON (sp.numero_solicitud = sv.numero_solicitud AND sp.reg_status != 'A' AND (sp.tipo = 'S'
								                                                                             OR CASE WHEN
								 sp_uneg_negocio(sv.cod_neg) IN (2, 8)
								 THEN sp.tipo = 'E'
								                                                                                ELSE sp.tipo = 'C' END
						 ))
						 LEFT JOIN solicitud_negocio sn ON (sn.numero_solicitud = sv.numero_solicitud AND sn.reg_status != 'A')
						 LEFT JOIN solicitud_laboral sl
								 ON (sl.numero_solicitud = sv.numero_solicitud AND sl.reg_status != 'A' AND sl.tipo = sp.tipo)
						 LEFT JOIN solicitud_referencias sr ON (sr.numero_solicitud = sv.numero_solicitud AND sr.reg_status != 'A'
						                                        AND sr.tipo = sp.tipo AND sr.tipo_referencia IN ('F', 'P') AND
						                                        sr.tipo = 'S')
				 WHERE ng.negocio_rel IN ('', NULL)
				       AND CASE WHEN _ciclo = ''
						 THEN TRUE
				           ELSE ng.num_ciclo = _ciclo :: INTEGER END
				       AND CASE WHEN _juridica = 'N'
						 THEN ng.etapa_proc_ejec IN ('', '0')
				           ELSE TRUE END --preguntar a manuel

				);
		--RETORNAMOS LA PREVISUALIZACION DE LOS DATOS.

		FOR recordfichas IN (SELECT
				                     identificacion,
				                     nombre,
				                     cod_neg,
				                     vencimiento_mayor,
				                     cuotas_vencidas,
				                     saldo_vencido,
				                     total,
				                     direccion,
				                     barrio,
				                     ciudad
		                     FROM tem.negocios_fichas_impresion
		                     WHERE tipo_principal = 'deudor' AND creation_user = _usuario
		                     GROUP BY identificacion, nombre, cod_neg, vencimiento_mayor, cuotas_vencidas, saldo_vencido,
				                     total, direccion, barrio, ciudad
		                     ORDER BY cod_neg)

		LOOP
				rs.identificacion := recordfichas.identificacion;
				rs.nombre := recordfichas.nombre;
				rs.cod_neg := recordfichas.cod_neg;
				rs.vencimiento_mayor := recordfichas.vencimiento_mayor;
				rs.cuotas_vencidas := recordfichas.cuotas_vencidas;
				rs.saldo_vencido := recordfichas.saldo_vencido;
				rs.total := recordfichas.total;
				rs.direccion := recordfichas.direccion;
				rs.barrio := recordfichas.barrio;
				rs.ciudad := recordfichas.ciudad;
				RETURN NEXT rs;
		END LOOP;

		--return next recordFichas;

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_unificarfichasagente(character varying, character varying, character varying, character varying, character varying, character varying, character varying)
  OWNER TO postgres;
