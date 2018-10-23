-- Function: eg_cuentas_cobro_fintra(character varying, character varying, character varying)

-- DROP FUNCTION eg_cuentas_cobro_fintra(character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION eg_cuentas_cobro_fintra(usuario character varying, numcxpcontratista character varying, _proveedor character varying)
  RETURNS boolean AS
$BODY$

DECLARE

	_tipoDocumento text:='FAP';
	_hcFactura text:='CD';
	_terceroSelectrik text:='9008439923';
	_hcFacturaSelectrik text:='SL';
	_item integer:=0;
        _aprobador_automatico TEXT:=(select valor from  constante where  dstrct = 'FINV' and  codigo ='APROBADOR_AUTOMATICO' and reg_status = '' );
        _banco_xdefecto TEXT:=(select valor from  constante where  dstrct = 'FINV' and  codigo ='BANCO_POR_DEFECTO' and reg_status = '' );
        _sucursal_xdefecto TEXT:=(select valor from  constante where  dstrct = 'FINV' and  codigo ='SUCURSAL_POR_DEFECTO' and reg_status = '' );
        recordAcciones record;
        cxpIngresoSelectrik text;
        rs boolean:=true;

BEGIN
	raise notice 'numCXPContratista : % _proveedor : % ',numCXPContratista,_proveedor;

	--A.)CXP CUENTA DE COBRO CONTRATISTA EN FINTRA
        insert into fin.cxp_items_doc (reg_status, dstrct, proveedor,tipo_documento, documento, item,
		       descripcion, vlr, vlr_me, codigo_cuenta, codigo_abc, planilla,
		       last_update, user_update, creation_date, creation_user, base,
		       codcliarea, tipcliarea, concepto, auxiliar, tipo_referencia_1,
		       referencia_1, tipo_referencia_2, referencia_2, tipo_referencia_3,
		       referencia_3)
	select reg_status, dstrct, proveedor,_tipoDocumento as tipo_documento, documento, item,
	       descripcion, vlr, vlr_me, CASE WHEN SUBSTRING(descripcion,1,12)='Bonificacion' THEN con.eg_buscar_cuenta_mapa(codigo_cuenta,'700') ELSE con.eg_buscar_cuenta_mapa(codigo_cuenta,concepto)  end as  codigo_cuenta, codigo_abc, planilla,
	       last_update, user_update, now(), usuario, base,
	       codcliarea, tipcliarea, concepto, auxiliar, tipo_referencia_1,
	       referencia_1, tipo_referencia_2, referencia_2, tipo_referencia_3,
	       referencia_3
        from fin.cxp_detalle_dblink where documento=numCXPContratista and tipo_documento='FAP' and reg_status='' and proveedor=_proveedor;



        --2.)CXP CUENTA DE COBRO CONTRATISTA EN FINTRA FACTORING Y FORMULA
        SELECT into _item count(0) from fin.cxp_detalle_dblink where documento =numCXPContratista and tipo_documento='FAP' and proveedor=_proveedor ;

        insert into fin.cxp_items_doc (reg_status, dstrct, proveedor, tipo_documento, documento, item,
		       descripcion, vlr, vlr_me, codigo_cuenta, codigo_abc, planilla,
		       last_update, user_update, creation_date, creation_user, base,
		       codcliarea, tipcliarea, concepto, auxiliar, tipo_referencia_1,
		       referencia_1, tipo_referencia_2, referencia_2, tipo_referencia_3,
		       referencia_3)
	(select reg_status, dstrct, proveedor, _tipoDocumento as tipo_documento, documento, lpad(item::integer+_item ,'3','0') as items,
	       descripcion, (vlr*-1) as vlr , (vlr_me*-1) as vlr_me, con.eg_buscar_cuenta_mapa(codigo_cuenta,'') as codigo_cuenta, codigo_abc, planilla,
	       last_update, user_update, now(), usuario, base,
	       codcliarea, tipcliarea, concepto, auxiliar, tipo_referencia_1,
	       referencia_1, tipo_referencia_2, referencia_2, tipo_referencia_3,
	       referencia_3
        from fin.cxp_detalle_dblink where documento =numCXPContratista and tipo_documento='NC' and reg_status='' and proveedor=_proveedor);


        --3.)CREAMOS LA CABECERA DE A CXP
        INSERT INTO fin.cxp_doc(
	    reg_status, dstrct, proveedor, tipo_documento, documento, descripcion,
	    agencia, handle_code, id_mims, tipo_documento_rel, documento_relacionado,
	    fecha_aprobacion, aprobador, usuario_aprobacion, banco, sucursal,
	    moneda, vlr_neto, vlr_total_abonos, vlr_saldo, vlr_neto_me, vlr_total_abonos_me,
	    vlr_saldo_me, tasa, last_update, user_update,
	    creation_date, creation_user, base, fecha_documento, fecha_vencimiento,clase_documento,
	    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
	    tipo_referencia_3, referencia_3, indicador_traslado_fintra)

	values ('','FINV',_proveedor,_tipoDocumento,numCXPContratista,'CXP CONTRATISTA',
	       'BQ',_hcFactura,'','','',
	       '0099-01-01 00:00:00'::timestamp,_aprobador_automatico,'',_banco_xdefecto,_sucursal_xdefecto,
	       'PES',0.00,0.00,0.00,0.00,0.00,
	       0.00,1.00,'0099-01-01 00:00:00'::timestamp,'',
	       now(),usuario,'COL',NOW()::DATE,NOW()::DATE,4,
	       '','','','',
	       '','','N');

       --4.)ACTULIZAMOS LA CABECERA DE LA FACTURA...

	update fin.cxp_doc set
		vlr_neto=(select sum(vlr) from fin.cxp_items_doc where documento=numCXPContratista AND tipo_documento='FAP' and proveedor=_proveedor),
		vlr_saldo=(select sum(vlr) from fin.cxp_items_doc where documento=numCXPContratista AND tipo_documento='FAP' and proveedor=_proveedor),
		vlr_neto_me=(select sum(vlr) from fin.cxp_items_doc where documento=numCXPContratista AND tipo_documento='FAP' and proveedor=_proveedor),
		vlr_saldo_me=(select sum(vlr) from fin.cxp_items_doc where documento=numCXPContratista AND tipo_documento='FAP' and proveedor=_proveedor)
	where documento=numCXPContratista AND tipo_documento='FAP' and proveedor=_proveedor
	and reg_status='';



 	--B)CXP A SELECTRICK INGRESOS
 	cxpIngresoSelectrik:=eg_serie_cxp_selectrik();
	_item:=1;
 	for recordAcciones in (
				select
					id_accion,
					bonificacion,
					opav as comision_opav,
					interventoria as comision_interventoria,
					provintegral as comision_provintegral,
					fintra as comision_selectrik,
					iva_bonificacion,
					iva_opav,
					iva_interventoria,
					iva_provintegral,
					iva_fintra as iva_selectrik
				from opav_acciones_dblink where id_accion in (select referencia_1 from fin.cxp_items_doc
				where documento=numCXPContratista and tipo_referencia_1='ACC' and proveedor=_proveedor  and tipo_documento='FAP' and reg_status='' group by referencia_1)
				)
	loop

		--1.)CONCEPTOBONIFICACION
		INSERT INTO fin.cxp_items_doc(
			    reg_status, dstrct, proveedor, tipo_documento, documento, item,
			    descripcion, vlr, vlr_me, codigo_cuenta, codigo_abc, planilla,
			    last_update, user_update, creation_date, creation_user, base,
			    codcliarea, tipcliarea, concepto, auxiliar, tipo_referencia_1,
			    referencia_1, tipo_referencia_2, referencia_2, tipo_referencia_3,
			    referencia_3)
		    VALUES ('', 'FINV', _terceroSelectrik, _tipoDocumento, cxpIngresoSelectrik, lpad(_item,'4','0'),
			    'CONCEPTO_BONIFICACION', recordAcciones.bonificacion,recordAcciones.bonificacion,'28151002', '', '',
			    '0099-01-01 00:00:000'::timestamp, '', now(), usuario, 'COL',
			    '', '','', _terceroSelectrik,'ACC',
			    recordAcciones.id_accion, '', '', '',
			    '');

			_item:=_item+1;

		--2.)IVA_BONIFICACION

		INSERT INTO fin.cxp_items_doc(
			    reg_status, dstrct, proveedor, tipo_documento, documento, item,
			    descripcion, vlr, vlr_me, codigo_cuenta, codigo_abc, planilla,
			    last_update, user_update, creation_date, creation_user, base,
			    codcliarea, tipcliarea, concepto, auxiliar, tipo_referencia_1,
			    referencia_1, tipo_referencia_2, referencia_2, tipo_referencia_3,
			    referencia_3)
		    VALUES ('', 'FINV', _terceroSelectrik, _tipoDocumento, cxpIngresoSelectrik, lpad(_item,'4','0'),
			    'IVA_BONIFICACION', recordAcciones.iva_bonificacion, recordAcciones.iva_bonificacion,'28151007', '', '',
			    '0099-01-01 00:00:000'::timestamp, '', now(), usuario, 'COL',
			    '', '','', _terceroSelectrik,'ACC',
			    recordAcciones.id_accion, '', '', '',
			    '');

			raise notice '_item:= %',_item;
			_item:=_item+1;

		--3.)COMISION OPAV

		INSERT INTO fin.cxp_items_doc(
			    reg_status, dstrct, proveedor, tipo_documento, documento, item,
			    descripcion, vlr, vlr_me, codigo_cuenta, codigo_abc, planilla,
			    last_update, user_update, creation_date, creation_user, base,
			    codcliarea, tipcliarea, concepto, auxiliar, tipo_referencia_1,
			    referencia_1, tipo_referencia_2, referencia_2, tipo_referencia_3,
			    referencia_3)
		    VALUES ('', 'FINV', _terceroSelectrik, _tipoDocumento, cxpIngresoSelectrik, lpad(_item,'4','0'),
			    'COMISION_OPAV', recordAcciones.comision_opav,recordAcciones.comision_opav,'28151015', '', '',
			    '0099-01-01 00:00:000'::timestamp, '', now(), usuario, 'COL',
			    '', '','', _terceroSelectrik,'ACC',
			    recordAcciones.id_accion, '', '', '',
			    '');

			raise notice '_item:= %',_item;
			_item:=_item+1;

		--4.)IVA_OPAV

		INSERT INTO fin.cxp_items_doc(
			    reg_status, dstrct, proveedor, tipo_documento, documento, item,
			    descripcion, vlr, vlr_me, codigo_cuenta, codigo_abc, planilla,
			    last_update, user_update, creation_date, creation_user, base,
			    codcliarea, tipcliarea, concepto, auxiliar, tipo_referencia_1,
			    referencia_1, tipo_referencia_2, referencia_2, tipo_referencia_3,
			    referencia_3)
		    VALUES ('', 'FINV', _terceroSelectrik, _tipoDocumento, cxpIngresoSelectrik, lpad(_item,'4','0'),
			    'IVA_OPAV', recordAcciones.iva_opav,recordAcciones.iva_opav,'28151011', '', '',
			    '0099-01-01 00:00:000'::timestamp, '', now(), usuario, 'COL',
			    '', '','', _terceroSelectrik,'ACC',
			    recordAcciones.id_accion, '', '', '',
			    '');

			raise notice '_item:= %',_item;
			_item:=_item+1;

		--5.)COMISION INTERVENTORIA

		INSERT INTO fin.cxp_items_doc(
			    reg_status, dstrct, proveedor, tipo_documento, documento, item,
			    descripcion, vlr, vlr_me, codigo_cuenta, codigo_abc, planilla,
			    last_update, user_update, creation_date, creation_user, base,
			    codcliarea, tipcliarea, concepto, auxiliar, tipo_referencia_1,
			    referencia_1, tipo_referencia_2, referencia_2, tipo_referencia_3,
			    referencia_3)
		    VALUES ('', 'FINV', _terceroSelectrik, _tipoDocumento, cxpIngresoSelectrik, lpad(_item,'4','0'),
			    'COMISION_INTERVENTORIA', recordAcciones.comision_interventoria,recordAcciones.comision_interventoria,'28151003', '', '',
			    '0099-01-01 00:00:000'::timestamp, '', now(), usuario, 'COL',
			    '', '','', _terceroSelectrik,'ACC',
			    recordAcciones.id_accion, '', '', '',
			    '');

			raise notice '_item:= %',_item;
			_item:=_item+1;

		--6.)IVA_INTERVENTORIA

		INSERT INTO fin.cxp_items_doc(
			    reg_status, dstrct, proveedor, tipo_documento, documento, item,
			    descripcion, vlr, vlr_me, codigo_cuenta, codigo_abc, planilla,
			    last_update, user_update, creation_date, creation_user, base,
			    codcliarea, tipcliarea, concepto, auxiliar, tipo_referencia_1,
			    referencia_1, tipo_referencia_2, referencia_2, tipo_referencia_3,
			    referencia_3)
		    VALUES ('', 'FINV', _terceroSelectrik, _tipoDocumento, cxpIngresoSelectrik, lpad(_item,'4','0'),
			    'IVA_INTERVENTORIA', recordAcciones.iva_interventoria,recordAcciones.iva_interventoria,'28151008', '', '',
			    '0099-01-01 00:00:000'::timestamp, '', now(), usuario, 'COL',
			    '', '','', _terceroSelectrik,'ACC',
			    recordAcciones.id_accion, '', '', '',
			    '');

			raise notice '_item:= %',_item;
			_item:=_item+1;

		--7.COMISION PROVINTEGRAL

		INSERT INTO fin.cxp_items_doc(
			    reg_status, dstrct, proveedor, tipo_documento, documento, item,
			    descripcion, vlr, vlr_me, codigo_cuenta, codigo_abc, planilla,
			    last_update, user_update, creation_date, creation_user, base,
			    codcliarea, tipcliarea, concepto, auxiliar, tipo_referencia_1,
			    referencia_1, tipo_referencia_2, referencia_2, tipo_referencia_3,
			    referencia_3)
		    VALUES ('', 'FINV', _terceroSelectrik, _tipoDocumento, cxpIngresoSelectrik, lpad(_item,'4','0'),
			    'COMISION_PROVINTEGRAL', recordAcciones.comision_provintegral, recordAcciones.comision_provintegral,'28151004', '', '',
			    '0099-01-01 00:00:000'::timestamp, '', now(), usuario, 'COL',
			    '', '','', _terceroSelectrik,'ACC',
			    recordAcciones.id_accion, '', '', '',
			    '');

			raise notice '_item:= %',_item;
			_item:=_item+1;

		--8.)IVA_PROVINTEGRAL

		INSERT INTO fin.cxp_items_doc(
			    reg_status, dstrct, proveedor, tipo_documento, documento, item,
			    descripcion, vlr, vlr_me, codigo_cuenta, codigo_abc, planilla,
			    last_update, user_update, creation_date, creation_user, base,
			    codcliarea, tipcliarea, concepto, auxiliar, tipo_referencia_1,
			    referencia_1, tipo_referencia_2, referencia_2, tipo_referencia_3,
			    referencia_3)
		    VALUES ('', 'FINV', _terceroSelectrik, _tipoDocumento, cxpIngresoSelectrik, lpad(_item,'4','0'),
			    'IVA_PROVINTEGRAL', recordAcciones.iva_provintegral, recordAcciones.iva_provintegral,'28151009', '', '',
			    '0099-01-01 00:00:000'::timestamp, '', now(), usuario, 'COL',
			    '', '','', _terceroSelectrik,'ACC',
			    recordAcciones.id_accion, '', '', '',
			    '');

			raise notice '_item:= %',_item;
			_item:=_item+1;

		--9.COMISION SELECTRICK

		INSERT INTO fin.cxp_items_doc(
			    reg_status, dstrct, proveedor, tipo_documento, documento, item,
			    descripcion, vlr, vlr_me, codigo_cuenta, codigo_abc, planilla,
			    last_update, user_update, creation_date, creation_user, base,
			    codcliarea, tipcliarea, concepto, auxiliar, tipo_referencia_1,
			    referencia_1, tipo_referencia_2, referencia_2, tipo_referencia_3,
			    referencia_3)
		    VALUES ('', 'FINV', _terceroSelectrik, _tipoDocumento, cxpIngresoSelectrik, lpad(_item,'4','0'),
			    'COMISION_SELECTRICK', recordAcciones.comision_selectrik, recordAcciones.comision_selectrik,'28151012', '', '',
			    '0099-01-01 00:00:000'::timestamp, '', now(), usuario, 'COL',
			    '', '','', _terceroSelectrik,'ACC',
			    recordAcciones.id_accion, '', '', '',
			    '');

			raise notice '_item:= %',_item;
			_item:=_item+1;

		--10.)IVA_SELECTRICK

		INSERT INTO fin.cxp_items_doc(
			    reg_status, dstrct, proveedor, tipo_documento, documento, item,
			    descripcion, vlr, vlr_me, codigo_cuenta, codigo_abc, planilla,
			    last_update, user_update, creation_date, creation_user, base,
			    codcliarea, tipcliarea, concepto, auxiliar, tipo_referencia_1,
			    referencia_1, tipo_referencia_2, referencia_2, tipo_referencia_3,
			    referencia_3)
		    VALUES ('', 'FINV', _terceroSelectrik, _tipoDocumento, cxpIngresoSelectrik, lpad(_item,'4','0'),
			    'IVA_SELECTRICK', recordAcciones.iva_selectrik, recordAcciones.iva_selectrik,'28151013', '', '',
			    '0099-01-01 00:00:000'::timestamp, '', now(), usuario, 'COL',
			    '', '','', _terceroSelectrik,'ACC',
			     recordAcciones.id_accion, '', '', '',
			    '');

			raise notice '_item:= %',_item;
			_item:=_item+1;


	end loop;


		--11.)CXP A SELECTRICK CABECERA

		INSERT INTO fin.cxp_doc(
		    reg_status, dstrct, proveedor, tipo_documento, documento, descripcion,
		    agencia, handle_code, id_mims, tipo_documento_rel, documento_relacionado,
		    fecha_aprobacion, aprobador, usuario_aprobacion, banco, sucursal,
		    moneda, vlr_neto, vlr_total_abonos, vlr_saldo, vlr_neto_me, vlr_total_abonos_me,
		    vlr_saldo_me, tasa, last_update, user_update,
		    creation_date, creation_user, base, fecha_documento, fecha_vencimiento,clase_documento,
		    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
		    tipo_referencia_3, referencia_3, indicador_traslado_fintra)

		values ('','FINV',_terceroSelectrik,_tipoDocumento,cxpIngresoSelectrik,'CXP A SELECTRICK INGRESOS',
		       'BQ',_hcFacturaSelectrik,'','FAP',numCXPContratista,
		       NOW(),_aprobador_automatico,_aprobador_automatico,_banco_xdefecto,_sucursal_xdefecto,
		       'PES',0.00,0.00,0.00,0.00,0.00,
		       0.00,1.00,'0099-01-01 00:00:00'::timestamp,'',
		       now(),usuario,'COL',NOW()::DATE,NOW()::DATE,4,
		       '','','','',
		       '','','N');



	 --12.)ACTULIZAMOS LA CABECERA DE LA FACTURA...

	update fin.cxp_doc set
		vlr_neto=(select sum(vlr) from fin.cxp_items_doc where documento=cxpIngresoSelectrik AND tipo_documento='FAP' and proveedor=_terceroSelectrik),
		vlr_saldo=(select sum(vlr) from fin.cxp_items_doc where documento=cxpIngresoSelectrik AND tipo_documento='FAP'  and proveedor=_terceroSelectrik),
		vlr_neto_me=(select sum(vlr) from fin.cxp_items_doc where documento=cxpIngresoSelectrik AND tipo_documento='FAP' and proveedor=_terceroSelectrik),
		vlr_saldo_me=(select sum(vlr) from fin.cxp_items_doc where documento=cxpIngresoSelectrik AND tipo_documento='FAP' and proveedor=_terceroSelectrik)
	where documento=cxpIngresoSelectrik AND tipo_documento='FAP' and proveedor=_terceroSelectrik
	and reg_status='';

	RETURN  rs;

END $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_cuentas_cobro_fintra(character varying, character varying, character varying)
  OWNER TO postgres;
