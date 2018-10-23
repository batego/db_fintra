-- Function: etes.anular_cxp_transferencia_reanticipo()

-- DROP FUNCTION etes.anular_cxp_transferencia_reanticipo();

CREATE OR REPLACE FUNCTION etes.anular_cxp_transferencia_reanticipo()
  RETURNS "trigger" AS
$BODY$
DECLARE

producto varchar:='';
fechaAnulacion timestamp without time zone:='0099-01-01 00:00:00';
grupoTransaccion integer:=0;
--transaccionDetalle integer:=0;

BEGIN


	--1.)PREGUNTAR SI EL PRODUCTO ES TRANSFERENCIA
	SELECT INTO producto codigo_proserv FROM etes.manifiesto_carga anticipo  INNER JOIN etes.productos_servicios_transp productos on (productos.id=id_proserv) WHERE anticipo.id=NEW.id_manifiesto_carga ;

	IF(producto ='ANT00002' AND NEW.reg_status='A' AND OLD.reg_status='' ) THEN

		RAISE NOTICE 'FUNCION ANULAR CXP TRANSFERENCIA REANTICIPO %',producto ;
		RAISE NOTICE 'id_manifiesto : %',NEW.ID;
		RAISE NOTICE 'DOCUMENTO CXP : %',NEW.documento_cxp;


		--2.)VERIFICAMOS SI EXISTE UN COMPROBANTE CONTABLE Y LO REVERSAMOS
		PERFORM * FROM con.comprobante WHERE numdoc=NEW.documento_cxp AND tipodoc='FAP' AND dstrct='FINV';
		IF(FOUND)THEN

			fechaAnulacion:=now();

				SELECT INTO grupoTransaccion nextval('con.comprobante_grupo_transaccion_seq');
				--SELECT INTO transaccionDetalle nextval('con.comprodet_transaccion_seq');

				--3.) CREAMOS LA CABECERA DEL COMPROBANTE
				INSERT INTO con.comprobante
					SELECT
					       reg_status,
					       dstrct,
					       tipodoc,
					       numdoc,
					       grupoTransaccion,
					       sucursal,
					       REPLACE(SUBSTRING(NOW(),1,7),'-','') AS periodo,
					       NOW()::DATE AS fechadoc,
					       'DESCONTABILIZACION CXP TRANSFERENCIA '||NEW.documento_cxp  AS detalle,
					       tercero,
					       total_debito,
					       total_credito,
					       total_items,
					       moneda,
					       NOW() AS fecha_aplicacion,
					       aprobador,
					       '0099-01-01 00:00:00'::timestamp AS last_update,
					       ''::VARCHAR AS user_update,
					       NOW() AS creation_date,
					       'TRIGGER' AS creation_user,
					       base,
					       usuario_aplicacion,
					       tipo_operacion, moneda_foranea, vlr_for, ref_1, ref_2
					  FROM con.comprobante
					WHERE numdoc=NEW.documento_cxp AND tipodoc='FAP' AND dstrct='FINV';


				--3.1)DETALLE DEL COMPROBANTE ::..

				INSERT INTO con.comprodet
					SELECT reg_status,
					       dstrct,
					       tipodoc,
					       numdoc,
					       grupoTransaccion,
					       nextval('con.comprodet_transaccion_seq') AS transaccionDetalle,
					       REPLACE(SUBSTRING(NOW(),1,7),'-','') AS periodo,
					       cuenta,
					       auxiliar,
					       'DESCONTABILIZACION CXP TRANSFERENCIA '||NEW.documento_cxp  AS detalle,
						CASE WHEN valor_debito > 0 THEN 0.0 ELSE valor_credito END AS valor_debito,
						CASE WHEN valor_credito > 0 THEN 0.0 ELSE valor_debito END AS valor_credito,
					       tercero,
					       documento_interno,
					       '0099-01-01 00:00:00'::timestamp AS last_update,
					       ''::VARCHAR AS user_update,
					       NOW() AS creation_date,
					       'TRIGGER' AS creation_user,
					       base,
					       tipodoc_rel,
					       documento_rel, abc, vlr_for,
					       tipo_referencia_1,
					       referencia_1,
					       tipo_referencia_2,
					       referencia_2,
					       tipo_referencia_3,
					       referencia_3
					  FROM con.comprodet
					WHERE  numdoc=NEW.documento_cxp AND tipodoc='FAP' AND dstrct='FINV';

		END IF;

			--4.)ANULAMOS LA CXP DE LA TRANSFERENCIA OPERATIVO.
			        UPDATE fin.cxp_doc
				   SET reg_status='A',
				       usuario_anulo='TRIGGER',
				       fecha_anulacion=now(),
				       fecha_contabilizacion_anulacion=fechaAnulacion,
				       last_update=now(),
				       user_update='TRIGGER'
				WHERE documento=NEW.documento_cxp;

			--5.)ANULAMOS LA CXP DE LA TRANSFERENCIA OPERATIVO DETALLE.
				UPDATE fin.cxp_items_doc
				   SET reg_status='A',
				       last_update=NOW(),
				       user_update='TRIGGER'
				 WHERE documento=NEW.documento_cxp;
	END IF;

 RETURN NEW;

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.anular_cxp_transferencia_reanticipo()
  OWNER TO postgres;
