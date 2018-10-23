-- Function: etes.buscar_anticipos_transferencia2(text, text, text, text, integer, text)

-- DROP FUNCTION etes.buscar_anticipos_transferencia2(text, text, text, text, integer, text);

CREATE OR REPLACE FUNCTION etes.buscar_anticipos_transferencia2(banco_trans text, codigo_banco_trans text, cuenta_trans text, tipo_cuenta_trans text, idtransportadora integer, usuario text)
  RETURNS SETOF etes.transferencia_anticipos_temp AS
$BODY$
DECLARE

 recordAnticipos record;
 rs etes.rs_transferencia ;
 comision_banco numeric:=0;
 previsualizar etes.transferencia_anticipos_temp;
 lote_nro text:=etes.serie_lote_trans();
 retorno text:='OK';
BEGIN

   --1.)BORRAR TABLA TEMPORAL DE TRANSFERENCIA POR USUARIO
   DELETE FROM etes.transferencia_anticipos_temp WHERE transferido='N' AND usuario_sesion=usuario;

   FOR recordAnticipos IN  ( SELECT * FROM (
			    SELECT
			    trans.id
			    ,trans.razon_social as transportadora
			    ,anticipo.id as id_manifiesto
			    ,agencia.nombre_agencia
			    ,conductor.nombre as conductor
                            ,propietario.cod_proveedor as cedula_propietario
			    ,propietario.nombre as propietario
			    ,vehiculo.placa
			    ,anticipo.planilla
			    ,to_char(anticipo.fecha_envio_fintra,'YYYY-MM-DD HH24-MM-SS') as fecha_anticipo
			    ,anticipo.creation_user as usuario_creacion
			    ,producto_ser.codigo_proserv
			    ,producto_ser.descripcion
			    ,'N'::text as reanticipo
			    ,anticipo.usuario_aprobacion
			    ,anticipo.valor_neto_anticipo as valor_anticipo
                            ,0.0::numeric as porcentaje_descuento
			    ,anticipo.valor_descuentos_fintra
			    ,anticipo.valor_desembolsar --sin comision banco
			    ,0.0::numeric as comision
			    ,0.0::numeric as valor_consignacion
                            ,anticipo.banco
			    ,anticipo.sucursal
			    ,anticipo.no_cuenta
			    ,anticipo.tipo_cuenta
			    ,anticipo.nombre_titular_cuenta
			    ,anticipo.cedula_titular_cuenta
			    ,anticipo.documento_cxp
			    FROM etes.manifiesto_carga as anticipo
			    INNER JOIN etes.agencias as agencia on(agencia.id=anticipo.id_agencia)
			    INNER JOIN etes.vehiculo as vehiculo on(vehiculo.id=anticipo.id_vehiculo)
			    INNER JOIN etes.transportadoras as trans on (agencia.id_transportadora=trans.id)
			    INNER JOIN etes.conductor as conductor on (anticipo.id_conductor=conductor.id)
			    INNER JOIN etes.propietario as propietario on (vehiculo.id_propietario=propietario.id)
			    INNER JOIN etes.productos_servicios_transp as producto_ser on (anticipo.id_proserv=producto_ser.id)
			    WHERE
			    anticipo.reg_status=''
			    and conductor.veto='N'
			    and anticipo.transferido='N'
			    and anticipo.fecha_transferencia='0099-01-01 00:00:00'::timestamp without time zone
			    and anticipo.aprobado='S'
			    and anticipo.fecha_aprobacion !='0099-01-01 00:00:00'::timestamp without time zone
			    and producto_ser.codigo_proserv='ANT00002'
			    UNION ALL
			    SELECT
			    trans.id
			    ,trans.razon_social as transportadora
			    ,reanticipo.id as id_manifiesto
			    ,agencia.nombre_agencia
			    ,conductor.nombre as conductor
			    ,propietario.cod_proveedor as cedula_propietario
			    ,propietario.nombre as propietario
			    ,vehiculo.placa
			    ,reanticipo.planilla
			    ,to_char(anticipo.fecha_envio_fintra,'YYYY-MM-DD HH24-MM-SS') as fecha_anticipo
			    ,reanticipo.creation_user as usuario_creacion
			    ,producto_ser.codigo_proserv
			    ,producto_ser.descripcion
			    ,'S'::text as reanticipo
			    ,reanticipo.usuario_aprobacion
			    ,reanticipo.valor_reanticipo as valor_anticipo
			    ,0.0::numeric as porcentaje_descuento
                            ,reanticipo.valor_descuentos_fintra
                            ,reanticipo.valor_desembolsar --sin comision banco
                            ,0.0::numeric as comision
			    ,0.0::numeric as valor_consignacion
			    ,reanticipo.banco
			    ,reanticipo.sucursal
			    ,reanticipo.no_cuenta
			    ,reanticipo.tipo_cuenta
			    ,reanticipo.nombre_titular_cuenta
			    ,reanticipo.cedula_titular_cuenta
			    ,reanticipo.documento_cxp
			    FROM etes.manifiesto_reanticipos as reanticipo
			    INNER JOIN etes.manifiesto_carga as anticipo on (reanticipo.id_manifiesto_carga=anticipo.id)
			    INNER JOIN etes.agencias as agencia on(agencia.id=anticipo.id_agencia)
			    INNER JOIN etes.vehiculo as vehiculo on(vehiculo.id=anticipo.id_vehiculo)
			    INNER JOIN etes.transportadoras as trans on (agencia.id_transportadora=trans.id)
			    INNER JOIN etes.conductor as conductor on (anticipo.id_conductor=conductor.id)
			    INNER JOIN etes.propietario as propietario on (vehiculo.id_propietario=propietario.id)
			    INNER JOIN etes.productos_servicios_transp as producto_ser on (anticipo.id_proserv=producto_ser.id)
			    WHERE
			    anticipo.reg_status=''
			    and reanticipo.reg_status=''
			    and conductor.veto='N'
			    and reanticipo.transferido='N'
			    and reanticipo.fecha_transferencia='0099-01-01 00:00:00'
			    and reanticipo.aprobado='S'
			    and reanticipo.fecha_aprobacion !='0099-01-01 00:00:00'
			    and producto_ser.codigo_proserv='ANT00002'
			    )tabla
			    WHERE CASE WHEN idtransportadora !=0 THEN id=idtransportadora ELSE  id > 0 END
			    ORDER BY planilla, fecha_anticipo, reanticipo desc
		)

   LOOP
		rs:=recordAnticipos;
		--SELECT INTO rs.banco  nombre  FROM bancos  where codigo=upper(recordAnticipos.banco);
		SELECT INTO rs.banco table_code FROM  tablagen WHERE  table_type = 'BANCOLOMBI' AND dato = UPPER(recordAnticipos.banco);

		/* ************************************
		* BUSCAMOS EL PORCENTAJE DE DESCUENTO *
		***************************************/
                IF(recordAnticipos.reanticipo='N') THEN

			SELECT INTO rs.porcetaje_descuto CASE WHEN md.porcentaje_descuento > 0 THEN md.porcentaje_descuento ELSE md.valor_descuento END as descuento
			FROM etes.manifiesto_descuentos as md
			INNER JOIN etes.config_productos_descuentos as cpd on (cpd.id=md.id_productos_descuentos)
			INNER JOIN etes.productos_servicios_transp as pst on (pst.id=cpd.id_proserv)
			WHERE id_manifiesto_carga=recordAnticipos.id_manifiesto and pst.codigo_proserv=recordAnticipos.codigo_proserv;
		ELSE

			SELECT INTO rs.porcetaje_descuto  CASE WHEN md.porcentaje_descuento > 0 THEN md.porcentaje_descuento ELSE md.valor_descuento END as descuento FROM etes.manifiesto_reanticipos  reanticipo
			INNER JOIN etes.manifiesto_carga anticipo on (reanticipo.id_manifiesto_carga=anticipo.id)
			INNER JOIN etes.manifiesto_descuentos md on (anticipo.id=md.id_manifiesto_carga)
			INNER JOIN etes.config_productos_descuentos as cpd on (cpd.id=md.id_productos_descuentos)
			INNER JOIN etes.productos_servicios_transp as pst on (pst.id=cpd.id_proserv)
			WHERE reanticipo.id=recordAnticipos.id_manifiesto and  pst.codigo_proserv=recordAnticipos.codigo_proserv;

		END IF;

		/* ********************************
		* CALCULAMOS LA COMISION BANCARIO *
		***********************************/
                comision_banco :=0;

		IF(upper(codigo_banco_trans)=upper(recordAnticipos.banco))THEN

			IF(recordAnticipos.tipo_cuenta = 'EF')THEN
			 SELECT INTO comision_banco cb.valor FROM comisiones_bancos as cb WHERE banco_transfer='EFECTIVO' and anio= substring(now(),1,4) ;
			ELSE
			 SELECT INTO comision_banco cb.valor FROM comisiones_bancos as cb WHERE banco_transfer='TRANSFERENCIA' and anio= substring(now(),1,4) ;
			END IF;
		ELSE

			IF(recordAnticipos.tipo_cuenta  = 'EF')THEN
			 SELECT INTO comision_banco cb.valor FROM comisiones_bancos as cb WHERE banco_transfer='EFECTIVO_BB' and anio= substring(now(),1,4) ;
			ELSE
			 SELECT INTO comision_banco cb.valor FROM comisiones_bancos as cb WHERE banco_transfer='TRANSFERENCIA_BB' and anio= substring(now(),1,4) ;
			END IF;
		END IF;

                rs.comision:=comision_banco;
                rs.valor_consignacion :=recordAnticipos.valor_desembolsar - comision_banco;

		--2.)INSERTA LA BUSQUEDA EN LA TABLA DE TRANSFERENCIAS TEMPORAL
		INSERT INTO etes.transferencia_anticipos_temp(
			    nro_lote, transferido, usuario_sesion, id_transportadora,
			    transportadora, id_manifiesto, nombre_agencia, conductor,cedula_propietario, propietario,
			    placa, planilla, fecha_anticipo, usuario_creacion, codigo_proserv,
			    descripcion, reanticipo, usuario_aprobacion, valor_anticipo,
			    porcetaje_descuto, valor_descuento, valor_neto_con_descueto,
			    comision, valor_consignacion,banco_transferencia,cod_banco_transferencia,cuenta_transferencia,tipo_cuenta_transferencia,
  			    banco, sucursal, cuenta, tipo_cuenta,
			    nombre_cuenta, nit_cuenta,documento_cxp,archivo_banco_generado)
		    VALUES (lote_nro,'N',usuario,rs.id_transportadora,rs.transportadora
			    ,rs.id_manifiesto,rs.nombre_agencia,rs.conductor ,rs.cedula_propietario,rs.propietario
			    ,rs.placa ,rs.planilla,rs.fecha_anticipo ,rs.usuario_creacion
			    ,rs.codigo_proserv ,rs.descripcion ,rs.reanticipo,rs.usuario_aprobacion
			    ,rs.valor_anticipo,rs.porcetaje_descuto,rs.valor_descuento,rs.valor_neto_con_descueto
			    ,rs.comision,rs.valor_consignacion,banco_trans,codigo_banco_trans,cuenta_trans,tipo_cuenta_trans
			    ,rs.banco ,rs.sucursal,rs.cuenta ,rs.tipo_cuenta
			    ,rs.nombre_cuenta ,rs.nit_cuenta,rs.documento_cxp,'N');


   END LOOP;

   --3.)Mostramos la previsualizacion de la transferencia.
  FOR previsualizar IN SELECT * from etes.transferencia_anticipos_temp WHERE transferido='N' AND usuario_sesion=usuario LOOP
      RETURN NEXT previsualizar;
  END LOOP;

END $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.buscar_anticipos_transferencia2(text, text, text, text, integer, text)
  OWNER TO postgres;
