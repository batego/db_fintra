-- Function: apicredit.eg_datos_clientes(character varying)

-- DROP FUNCTION apicredit.eg_datos_clientes(character varying);

CREATE OR REPLACE FUNCTION apicredit.eg_datos_clientes(_identificacion character varying)
  RETURNS SETOF apicredit.rs_datos_cliente AS
$BODY$

DECLARE

 rs apicredit.rs_datos_cliente;
 recordNegocios record ;
 recordAfiliados record;
 _fechapago record;
 _valor_sado numeric:=0;


 --DECLARAMOS EL CURSOR
 cursor_negocios CURSOR( _identificacion varchar) FOR (SELECT
							    ''::varchar as ciudad_credito
							   ,''::varchar as nit_afiliado
							   ,''::varchar as tipo_carrera
							   ,''::varchar as dia_pago
							   ,''::varchar as fecha_pago
							   ,''::varchar as mora_actual
							   ,''::varchar as cumple_tiempo
							   ,neg.cod_neg
							   ,neg.nit_tercero
							   ,sp.numero_solicitud as numero_solicitud_padre
							   ,sp.nombre
							   ,sp.primer_nombre
							   ,sp.primer_apellido
							   ,sp.fecha_nacimiento::date
							   ,sp.tipo_id as tipo_identificacion
							   ,sp.identificacion
							   ,sp.fecha_expedicion_id::date as fecha_expedicion
							   ,sp.telefono
							   ,sp.celular
							   ,COALESCE(ccf.clasificacion,'SIN_CLASIFICAR') as tipo_cliente
							   ,(SELECT SUM(salario) FROM solicitud_laboral where numero_solicitud=sp.numero_solicitud and tipo='S') as ingresos
							   ,COALESCE(ccf.valor_preaprobado,0)as valor_preaprobado
							FROM solicitud_persona  sp
							INNER JOIN (
								SELECT max(numero_solicitud) AS numero_solicitud,identificacion,tipo,tipo_id, max(max_fecha_ven) as fecha_vencimiento , count(0) as num_solicitudes
									FROM (
										 SELECT sp.numero_solicitud,identificacion,tipo,tipo_id,count(0) as count,max(fac.fecha_vencimiento) as max_fecha_ven , sum(fac.valor_saldo) as valor_saldo
												FROM solicitud_persona sp
												INNER JOIN solicitud_aval sa ON (sa.numero_solicitud=sp.numero_solicitud)
												INNER JOIN negocios neg ON (neg.cod_neg=sa.cod_neg)
												INNER JOIN con.factura fac on (neg.cod_neg = fac.negasoc)
												WHERE tipo='S' AND sp.reg_status='' AND neg.estado_neg='T'
												AND (now()::DATE-neg.creation_date::DATE) > 60
												GROUP BY sp.numero_solicitud,identificacion,tipo,tipo_id
									)t GROUP BY identificacion,tipo,tipo_id
							    )tabla
							    ON (tabla.numero_solicitud=sp.numero_solicitud AND tabla.identificacion=sp.identificacion AND tabla.tipo_id=sp.tipo_id AND tabla.tipo=sp.tipo)
							INNER JOIN solicitud_aval sa ON (sa.numero_solicitud=sp.numero_solicitud)
							INNER JOIN negocios neg ON (neg.cod_neg=sa.cod_neg)
							INNER JOIN rel_unidadnegocio_convenios  run on (run.id_convenio=neg.id_convenio)
							INNER JOIN unidad_negocio u on (run.id_unid_negocio=u.id and u.ref_4!='' )
							LEFT JOIN (SELECT a.* FROM administrativo.clasificacion_clientes_fintracredit a
								    INNER JOIN (SELECT max(periodo) AS periodo,id_unidad_negocio
										    FROM administrativo.clasificacion_clientes_fintracredit
										    WHERE id_unidad_negocio in (2,8,31) GROUP BY id_unidad_negocio) b
								    ON (a.periodo=b.periodo and a.id_unidad_negocio=b.id_unidad_negocio)

							    )ccf ON (ccf.cedula_deudor= sp.identificacion AND ccf.id_unidad_negocio in (2,8,31))

							WHERE sp.identificacion=_identificacion AND  u.id in (2,8,31)
							ORDER BY ccf.clasificacion
						   );

-- SELECT max(sp.numero_solicitud) as numero_solicitud,identificacion,tipo,tipo_id,count(0)
-- FROM solicitud_persona sp
-- INNER JOIN solicitud_aval sa ON (sa.numero_solicitud=sp.numero_solicitud)
-- INNER JOIN negocios neg ON (neg.cod_neg=sa.cod_neg)
-- WHERE tipo='S' AND sp.reg_status='' AND neg.estado_neg='T' AND (now()::DATE-neg.creation_date::DATE) > 60
-- GROUP BY identificacion,tipo,tipo_id

BEGIN

	--ABRIMOS EL CURSOR SIN PARAMETROS
	OPEN cursor_negocios(_identificacion) ;
	<<_loop>>
	LOOP
		-- FETCH FILA EN MY RECORD O TYPE
		FETCH cursor_negocios INTO recordNegocios;
		-- EXIT CUANDO NO HAY MAS FILAS
		EXIT WHEN NOT FOUND;

		raise notice 'neg.cod_neg : %',recordNegocios.cod_neg;
		SELECT INTO recordAfiliados
		    DISTINCT pc.nit_proveedor as nit_afiliado,
		    pc.nombre_afiliado as nombre_afiliado,
		    p.cod_fenalco,
		    ref_4,
		    run.id_convenio,
		    producto,
		    ref_4 as referencia_ciudad
		FROM prov_convenio pc
		INNER JOIN proveedor p ON (pc.nit_proveedor = p.nit )
		inner join rel_unidadnegocio_convenios run on (run.id_convenio=pc.id_convenio)
		inner join unidad_negocio un on (un.id=run.id_unid_negocio)
		where check_api='S' and ref_4 !=''
		AND nit_proveedor !='8020220161'
		AND cod_fenalco !=''
		AND pc.nit_proveedor=recordNegocios.nit_tercero ;

		recordNegocios.ciudad_credito:=recordAfiliados.referencia_ciudad;
		recordNegocios.nit_afiliado:=recordAfiliados.nit_afiliado;
		recordNegocios.tipo_carrera:=(SELECT CASE WHEN tipo_carrera='PROFESIONAL' THEN 'PRE'
							WHEN tipo_carrera='POSGRADO' THEN 'POS'
							END AS tipo_carrera
						FROM solicitud_estudiante  WHERE numero_solicitud=recordNegocios.numero_solicitud_padre);

		--busca la fecha de pago teniendo en cuenta el tiempo < a dos meses y 20 dias.
		 SELECT INTO _FECHAPAGO FECHA_PAGO,TIEMPO FROM TEM.BUSCAR_FECHAS_DEMO(_IDENTIFICACION) AS F (FECHA_PAGO VARCHAR , TIEMPO VARCHAR);

		recordNegocios.dia_pago:=date_part('day',_FECHAPAGO.FECHA_PAGO::date);
 		recordNegocios.fecha_pago:=_FECHAPAGO.FECHA_PAGO::DATE;
 		recordNegocios.cumple_tiempo:=	_FECHAPAGO.TIEMPO;

		raise notice 'recordNegocios.cod_neg % recordNegocios.dia_pago:% ', recordNegocios.cod_neg, recordNegocios.dia_pago ;

		SELECT INTO _valor_sado COALESCE(sum(fac.valor_saldo),0) AS valor_saldo
		FROM con.factura fac
		INNER JOIN con.factura_detalle fdet ON (fac.documento=fdet.documento AND fac.tipo_documento=fdet.tipo_documento)
		WHERE fac.valor_saldo >0
		and fac.negasoc=recordNegocios.cod_neg
		and fac.valor_saldo > 0
		and fac.reg_status = ''
		and fac.dstrct = 'FINV'
		and fac.tipo_documento in ('FAC','NDC')
		and substring(fac.documento,1,2) not in ('CP','FF','DF') ;
		--
		IF(recordNegocios.dia_pago::INTEGER < 10)THEN
			recordNegocios.dia_pago:='0'||recordNegocios.dia_pago;
		END IF;

		--validamos que la fecha de pago sea mayor a hoy
		raise notice 'recordNegocios.fecha_pago 1: %',recordNegocios.fecha_pago;
		IF(recordNegocios.fecha_pago::date < now()::date OR _valor_sado =0)THEN
			recordNegocios.fecha_pago:=now()::date;
		END IF;
		raise notice 'recordNegocios.fecha_pago 2: %',recordNegocios.fecha_pago;

		--altura de mora actual...
		SELECT  INTO recordNegocios.mora_actual
			CASE WHEN maxdia >= 365 THEN '8- MAYOR A 1 AÑO'
			WHEN maxdia >= 181 THEN '7- ENTRE 180 Y 360'
			WHEN maxdia >= 121 THEN '6- ENTRE 121 Y 180'
			WHEN maxdia >= 91 THEN '5- ENTRE 91 Y 120'
			WHEN maxdia >= 61 THEN '4- ENTRE 61 Y 90'
			WHEN maxdia >= 31 THEN '3- ENTRE 31 Y 60'
			WHEN maxdia >= 1 THEN '2- 1 A 30'
			WHEN maxdia <= 0 THEN '1- CORRIENTE'
			WHEN maxdia is null  THEN '1- CORRIENTE'
			ELSE '0' END AS rango
		FROM(SELECT  max(now()::date-(fecha_vencimiento)) as maxdia
			FROM con.factura fra
			WHERE fra.dstrct = 'FINV'   and fra.reg_status=''
			and fra.valor_saldo > 0
			AND fra.negasoc = recordNegocios.cod_neg
			AND fra.tipo_documento in ('FAC','NDC')
			AND substring(fra.documento,1,2) not in ('CP','FF','DF')
			) AS t;

		raise notice 'mora_actual: %',recordNegocios.mora_actual;

		raise notice 'recordNegocios.fecha_pago: % recordNegocios.cod_neg :%',recordNegocios.fecha_pago,recordNegocios.cod_neg;

		rs.ciudad_credito:=recordNegocios.ciudad_credito;
		rs.nit_afiliado:=recordNegocios.nit_afiliado;
		rs.tipo_carrera:=recordNegocios.tipo_carrera;
		rs.dia_pago:=recordNegocios.dia_pago;
		rs.fecha_pago:=recordNegocios.fecha_pago;
		rs.mora_actual:=recordNegocios.mora_actual;
		rs.cumple_tiempo:=recordNegocios.cumple_tiempo;
		rs.cod_neg:=recordNegocios.cod_neg;
		rs.numero_solicitud_padre:=recordNegocios.numero_solicitud_padre;
		rs.nombre:=recordNegocios.nombre;
		rs.primer_nombre:=recordNegocios.primer_nombre;
		rs.primer_apellido:=recordNegocios.primer_apellido;
		rs.fecha_nacimiento:=recordNegocios.fecha_nacimiento;
		rs.tipo_identificacion:=recordNegocios.tipo_identificacion;
		rs.identificacion:=recordNegocios.identificacion;
		rs.fecha_expedicion:=recordNegocios.fecha_expedicion;
		rs.telefono:=recordNegocios.telefono;
		rs.celular:=recordNegocios.celular;
		rs.tipo_cliente:=recordNegocios.tipo_cliente;
		rs.ingresos :=recordNegocios.ingresos;
		rs.valor_preaprobado:=recordNegocios.valor_preaprobado;

		RETURN NEXT rs;

	END LOOP  _loop ;

	--CERRAMOS EL CURSOR
	CLOSE cursor_negocios;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION apicredit.eg_datos_clientes(character varying)
  OWNER TO postgres;
