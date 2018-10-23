-- Function: etes.agrupar_transferencia_tem(text)

-- DROP FUNCTION etes.agrupar_transferencia_tem(text);

CREATE OR REPLACE FUNCTION etes.agrupar_transferencia_tem(id text)
  RETURNS SETOF etes.transferencia_anticipos_temp AS
$BODY$
DECLARE

 nro_transferencia text:=etes.serie_trans_egreso();
 listaAgrupada record;
 lista record;
 lista_egresos record;
 cabeceraEgreso record;
 listEgresoDetalle record;
 recordCxp record;
 vectorCuentas varchar[]='{}';
 secuencia integer:=1;
 fecha_trans timestamp:=now();
 contabilizaEgreso text:='';
generarDocumentosContables  text:='';
 rs etes.transferencia_anticipos_temp ;


BEGIN

	--1.)asignar egreso del grupo de transferencia
	EXECUTE 'UPDATE etes.transferencia_anticipos_temp SET egreso_grupo='''||nro_transferencia||''' WHERE id in ' || id;

	--2.)ASIGNAMOS LOS NUMERO DE EGRESOS FUTUROS.
	FOR listaAgrupada IN EXECUTE 'SELECT
					cedula_propietario,
					banco,
					cuenta,
					tipo_cuenta,
					nombre_cuenta,
					nit_cuenta,
					sum(valor_anticipo) as vlr,
					sum(valor_consignacion) as vlr_consignacion
					FROM etes.transferencia_anticipos_temp
					WHERE id in '||id||'
					GROUP BY
					cedula_propietario,
					banco,
					cuenta,
					tipo_cuenta,
					nombre_cuenta,
					nit_cuenta'
	LOOP

		/*rs.cedula_propietario:=listaAgrupada.cedula_propietario;
		rs.banco:=listaAgrupada.banco;
		rs.cuenta:=listaAgrupada.cuenta;
		rs.tipo_cuenta:= listaAgrupada.tipo_cuenta;
		rs.nombre_cuenta:=listaAgrupada.nombre_cuenta;
		rs.nit_cuenta:=listaAgrupada.nit_cuenta;
		rs.reanticipo:=listaAgrupada.reanticipo;
		rs.valor_anticipo:=listaAgrupada.vlr;
		rs.valor_consignacion:=listaAgrupada.vlr_consignacion; */

		FOR lista IN EXECUTE 'SELECT * FROM etes.transferencia_anticipos_temp WHERE  id in '||id LOOP

			IF(listaAgrupada.banco=lista.banco AND listaAgrupada.cuenta=lista.cuenta AND
			   listaAgrupada.tipo_cuenta=lista.tipo_cuenta AND listaAgrupada.nit_cuenta=lista.nit_cuenta AND
			   listaAgrupada.cedula_propietario =lista.cedula_propietario)THEN

				--RAISE NOTICE 'MISMO GRUPO % secuencia % caca: %, id: %',nro_transferencia,secuencia,caca,lista.id;
				EXECUTE 'UPDATE etes.transferencia_anticipos_temp SET egreso_item='''||nro_transferencia||'_'||secuencia||''' WHERE id='||lista.id;

			END IF;
		END LOOP;
			secuencia:=secuencia+1;

	END LOOP;

        --3.)LLENAMOS LA TABLA DE TRANSFERENCIAS CON LOS DATOS DE LA TEMPORAL Y GENERAMOS EL EGRESO A FINTRA.
	FOR lista IN EXECUTE 'SELECT * FROM etes.transferencia_anticipos_temp WHERE  id in '||id LOOP

			INSERT INTO etes.transferencias_anticipos(
				    reg_status, dstrct, periodo, id_transportadora, id_manifiesto_carga,
				    planilla, reanticipo, comision_bancaria, valor_comision_bancaria,
				    valor_transferencia, transferido, fecha_transferencia, banco_transferencia,
				    cuenta_transferencia, tipo_cuenta_transferencia, banco, sucursal,
				    cedula_titular_cuenta, nombre_titular_cuenta, tipo_cuenta, no_cuenta,
				    numero_egreso, valor_egreso, creation_date, creation_user)
			    VALUES ('', 'FINV', REPLACE(SUBSTRING(NOW(),1,7),'-',''), lista.id_transportadora, lista.id_manifiesto,
				    lista.planilla, lista.reanticipo, lista.comision, lista.comision,
				    lista.valor_consignacion,'S',fecha_trans, lista.banco_transferencia,
				    lista.cuenta_transferencia, lista.tipo_cuenta_transferencia, lista.banco,lista.sucursal,
				    lista.nit_cuenta, lista.nombre_cuenta, lista.tipo_cuenta, lista.cuenta,
				    lista.egreso_item, lista.valor_consignacion, NOW(),lista.usuario_sesion);

			--4.)ACTUALIZAMOS LOS MANIFIESTOS (CARGA O REANTICIPO)

			IF(lista.reanticipo='N')THEN
				EXECUTE 'UPDATE etes.manifiesto_carga
				   SET transferido=''S'', fecha_transferencia='''||fecha_trans||''', numero_egreso='''||lista.egreso_item||''',
				    valor_egreso='||lista.valor_consignacion||'
				WHERE id='||lista.id_manifiesto;

			ELSIF(lista.reanticipo='S')THEN

				EXECUTE 'UPDATE etes.manifiesto_reanticipos
				   SET transferido=''S'', fecha_transferencia='''||fecha_trans||''', numero_egreso='''||lista.egreso_item||''',
				       valor_egreso='||lista.valor_consignacion||'
				 WHERE id='||lista.id_manifiesto;
			END IF;

			--RETURN NEXT rs;
	END LOOP;

	--3.1)BUSCAMOS LAS CUETAS DEL EGRESO EN EL PERFIL.
	vectorCuentas:=etes.get_cuentas_perfil('EGRESO_TRANSFERENCIA');
	RAISE NOTICE 'CUENTA ITEM CON CXP :vectorCuentas[1]: %', vectorCuentas[1] ;
	RAISE NOTICE 'CUENTA ITEM COMISION BANCO :vectorCuentas[1]: %', vectorCuentas[2] ;

	--4.)GENERAMOS EGRESO DE LA TRANSFERENCIA
	FOR lista_egresos IN EXECUTE 'SELECT  cedula_propietario,
					      banco_transferencia,
					      tipo_cuenta_transferencia,
					      egreso_item,
					      sum(valor_consignacion) as vlr_consignacion,
					      usuario_sesion
					FROM etes.transferencia_anticipos_temp
					WHERE egreso_grupo !='''' AND egreso_item !=''''
					AND  id in '||id||'
					GROUP BY banco_transferencia,tipo_cuenta_transferencia, egreso_item,usuario_sesion,cedula_propietario'

	LOOP
		---CABECERA DEL EGRESO----

		INSERT INTO egreso(
			    reg_status, dstrct, branch_code, bank_account_no, document_no,
			    nit, payment_name, agency_id, pmt_date, printer_date, concept_code,
			    vlr, vlr_for, currency, last_update, user_update, creation_date,
			    creation_user, base, tipo_documento, tasa, fecha_cheque, usuario_impresion,
			    usuario_contabilizacion, fecha_contabilizacion,nit_beneficiario,
			    nit_proveedor, usuario_generacion, contabilizable)
		    VALUES ('','FINV', lista_egresos.banco_transferencia, lista_egresos.tipo_cuenta_transferencia,lista_egresos.egreso_item,
			    lista_egresos.cedula_propietario, get_nombp(lista_egresos.cedula_propietario), 'OP', NOW()::date, NOW()::date, 'FAC',
			    lista_egresos.vlr_consignacion,lista_egresos.vlr_consignacion,'PES', '0099-01-01'::TIMESTAMP,'', NOW(),
			    lista_egresos.usuario_sesion, 'COL', '004', 1.0,  NOW()::date, 'ADMIN',
			    '','0099-01-01'::TIMESTAMP, lista_egresos.cedula_propietario,
			    lista_egresos.cedula_propietario, 'ADMIN', 'S');

		--DETALLE DEL EGRESO----

                secuencia:=1;
		FOR listEgresoDetalle IN  SELECT * FROM  etes.transferencia_anticipos_temp WHERE egreso_item=lista_egresos.egreso_item   LOOP
                    RAISE NOTICE 'DETALLE EGRESO..: %',listEgresoDetalle.egreso_item;

                        ---ITEM  CON CXP
			INSERT INTO egresodet(
				    reg_status, dstrct, branch_code, bank_account_no, document_no,
				    item_no, concept_code, vlr, vlr_for, currency, last_update,
				    user_update, creation_date, creation_user, description, base,
				    tasa, tipo_documento, documento, tipo_pago, cuenta,
				    auxiliar)
			    VALUES ('','FINV', listEgresoDetalle.banco_transferencia, listEgresoDetalle.tipo_cuenta_transferencia, listEgresoDetalle.egreso_item,
				    lpad(secuencia, 3, '0'), 'FAC',listEgresoDetalle.valor_neto_con_descueto, listEgresoDetalle.valor_neto_con_descueto, 'PES', '0099-01-01'::TIMESTAMP,
				    '', NOW(),listEgresoDetalle.usuario_sesion,'VALOR PLANILLA', 'COL',
				    1.0, (SELECT COALESCE(tipo_documento,'-') FROM fin.cxp_doc  where documento=listEgresoDetalle.documento_cxp), listEgresoDetalle.documento_cxp, 'C',vectorCuentas[1],
				    '');

			secuencia:=secuencia+1;

			--ITEM  COMISION
			INSERT INTO egresodet(
				    reg_status, dstrct, branch_code, bank_account_no, document_no,
				    item_no, concept_code, vlr, vlr_for, currency, last_update,
				    user_update, creation_date, creation_user, description, base,
				    tasa, tipo_documento, documento, tipo_pago, cuenta,
				    auxiliar)
			    VALUES ('','FINV', listEgresoDetalle.banco_transferencia, listEgresoDetalle.tipo_cuenta_transferencia, listEgresoDetalle.egreso_item,
				    lpad(secuencia, 3, '0'), 'FAC', (listEgresoDetalle.comision * -1), (listEgresoDetalle.comision * -1), 'PES', '0099-01-01'::TIMESTAMP,
				    '', NOW(),listEgresoDetalle.usuario_sesion,'COMISION BANCARIA', 'COL',
				    1.0,(SELECT COALESCE(tipo_documento,'-')  FROM fin.cxp_doc  where documento=listEgresoDetalle.documento_cxp), listEgresoDetalle.documento_cxp, 'C',  vectorCuentas[2],
				    '');

			--ACTUALIZAR SALDO DE LA CXP

			UPDATE fin.cxp_doc
			   SET
			       vlr_total_abonos=listEgresoDetalle.valor_consignacion,
			       vlr_saldo=0,
			       vlr_total_abonos_me=listEgresoDetalle.valor_consignacion,
			       vlr_saldo_me=0,
			       cheque=listEgresoDetalle.egreso_item
			WHERE  documento=listEgresoDetalle.documento_cxp;

			secuencia:=secuencia+1;

                END LOOP;
	END LOOP;

	--5.)MARCAMOS LOS REGISTROS DE LA TABLA TEMPORAL COMO TRANSFERIDOS.
	EXECUTE 'UPDATE etes.transferencia_anticipos_temp SET transferido=''S'' WHERE id in ' || id;

        --6.)CONTABILIZAMOS LOS EGRESOS.
	FOR lista IN EXECUTE 'SELECT egreso_item,usuario_sesion,max(documento_cxp) as documento_cxp  FROM  etes.transferencia_anticipos_temp WHERE transferido=''S'' AND id in '||id||'  GROUP BY egreso_item,usuario_sesion' LOOP
                SELECT into recordCxp periodo,fecha_documento from fin.cxp_doc  where documento =lista.documento_cxp;
		contabilizaEgreso:=etes.contabilizar_egreso_transferencia(lista.egreso_item,recordCxp.fecha_documento,recordCxp.periodo,lista.usuario_sesion);
		raise notice 'contabilizaEgreso : %',contabilizaEgreso;
	END LOOP;

	--7.)GENERAMOS LOS DOCUMENTOS CONTABLES PARA LA TRANSFERENCIA CON EL MISMO PERIODO DE LA CXP
	for lista in EXECUTE 'SELECT * FROM etes.transferencia_anticipos_temp WHERE transferido=''S''  AND id in '||id||''  loop
		SELECT into recordCxp periodo,fecha_documento from fin.cxp_doc  where documento =lista.documento_cxp;
		generarDocumentosContables :=etes.contabilizar_transferencia(lista.id_manifiesto,recordCxp.fecha_documento, recordCxp.periodo,lista.reanticipo ,lista.usuario_sesion);
		raise notice 'documentos contables : %',generarDocumentosContables;
	end loop;

	--8.)RETORNAR LISTA
	FOR lista IN EXECUTE 'SELECT * FROM etes.transferencia_anticipos_temp WHERE  id in '||id   LOOP
		rs:=lista;
            RETURN NEXT rs;
	END LOOP;


END $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.agrupar_transferencia_tem(text)
  OWNER TO postgres;
