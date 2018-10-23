-- Function: opav.sl_preparar_facturacion(character varying, numeric, numeric, character varying, text)

-- DROP FUNCTION opav.sl_preparar_facturacion(character varying, numeric, numeric, character varying, text);

CREATE OR REPLACE FUNCTION opav.sl_preparar_facturacion(_id_solicitud character varying, _valor_facturar numeric, _valor_fact_material numeric, usuariocrea character varying, observaciones text)
  RETURNS text AS
$BODY$

DECLARE
_accionPrincipal varchar := '';
_nombre_distribucion varchar := '';
recordDistribucion record;
_consecutivoOferta varchar := '';
_consecutivoAccion varchar := '';
_codigoCliente varchar := '';
_consecutivoCotizacion varchar := '';
_valor_mano_obra numeric := 0;
_iva  numeric(7,5):=0;
_existeNic varchar :='';
_existeSubcliente varchar :='';
_existeFacturaConsorcio varchar :='';
_recordcot record;
_costo_contratista numeric :=0;

retorno text:='OK';

BEGIN
	--select  opav.sl_preparar_facturacion('924776' , 3723357 , 1000000 , 'WSIADO' , 'LOL');
        _valor_mano_obra := _valor_facturar - _valor_fact_material;
	RAISE NOTICE 'mano de obra:% ',_valor_mano_obra;

	--OBTENEMOS ACCION PRINCIPAL
	SELECT INTO _accionPrincipal id_accion FROM opav.acciones where id_solicitud = _id_solicitud  AND accion_principal = 1;

       --ANULAMOS LA ACCION PRINCIPAL ASOCIADA A LA SOLICITUD DADA
       UPDATE opav.acciones SET reg_status = 'A' where id_solicitud = _id_solicitud  AND accion_principal = 1;

       --OBTENEMOS NUEVO CONSECUTIVO OFERTA
        SELECT INTO _consecutivoOferta
		SUBSTRING(now()::date,3,2)||'.OPAV.'||lpad(ltrim(to_char(last_number, '9999999999')) , length(serial_fished_no)-1,'0')||'PE'
	FROM series
	WHERE
		dstrct = 'FINV' and
		agency_id = 'OP' and
		document_type = 'OFERTASERIE';

       --OBTENEMOS LA DISTRIBUCION ASOCIADA A LA SOLICITUD
       SELECT INTO _nombre_distribucion trim(distribucion_rentabilidad_esquema) FROM opav.sl_cotizacion where id_accion = _accionPrincipal;

       RAISE NOTICE '_nombre_distribucion:% ',_nombre_distribucion;

        --buscamos el tipo de distribucion
            SELECT INTO recordDistribucion nombre_distribucion as tipo_solicitud,tipo as tipo_distribucion , ((((((((a.porc_opav + a.porc_fintra + a.porc_interventoria + a.porc_provintegral)/100)+1)*(((a.porc_eca)/100)+1))-1)*100)/100)+1)::numeric(12,9) as porcentaje
            FROM opav.tipo_distribucion_eca a
            LEFT JOIN tablagen b on (a.tipo= b.dato)
            LEFT JOIN tablagen c on (b.table_code = c.table_code)
            WHERE c.table_type ilike ('%tipo_ofert%') and b.reg_status =''
            AND (b.table_code || ' (' || (a.porc_opav + a.porc_fintra + a.porc_interventoria + a.porc_provintegral)::numeric(6,3) || ' - ' || (a.porc_eca)::numeric(6,3) || ')') = _nombre_distribucion;

        RAISE NOTICE 'TIPO SOLICITUD:% ',recordDistribucion.tipo_solicitud;
        RAISE NOTICE 'TIPO DISTRIBUCION:% ',recordDistribucion.tipo_distribucion;
        RAISE NOTICE 'PORCENTAJE:% ',recordDistribucion.porcentaje;

        --ACTUALIZAMOS TABLA OFERTAS
        UPDATE opav.ofertas SET
		tipo_solicitud = recordDistribucion.tipo_solicitud,
		tipodistribucion = recordDistribucion.tipo_distribucion,
		estudio_cartera = '010',
		consecutivo_oferta = _consecutivoOferta
        WHERE id_solicitud = _id_solicitud;

	RAISE NOTICE '_existeNic:% ', _existeNic;
	--SE COMPRUEBA SI EXISTE EL NIC DE LA OFERTA SINO ENTONCES SE INSERTA
	select into _existeNic
	coalesce (
	(SELECT distinct 'EXISTE' FROM opav.clientes_eca_nics nic
			inner join opav.ofertas ofe on (nic.id_cliente = ofe.id_cliente)
			where id_solicitud = _id_solicitud
	), 'NO') as resultado;

	if(_existeNic ='NO') then
		insert into opav.clientes_eca_nics
			(nic, id_cliente, creation_user, creation_date)
		values
			('NIC'||(select id_cliente FROM opav.ofertas where id_solicitud = _id_solicitud), (select id_cliente FROM opav.ofertas where id_solicitud = _id_solicitud) , usuariocrea, now()::date);
	end if;

	--SE VERIFICA SI EXISTE EL SUBCLIENTE OFERTA SINO SE INSERTA
	select into _existeSubcliente
	coalesce (
	(SELECT distinct 'EXISTE'
		FROM opav.subclientes_ofertas
		where id_solicitud = _id_solicitud
	), 'NO') as resultado;

	if(_existeSubcliente ='NO') then
	insert into opav.subclientes_ofertas
		( id_cliente, id_solicitud ,creation_user, creation_date)
	values
		( (select id_cliente FROM opav.ofertas where id_solicitud = _id_solicitud) ,_id_solicitud ,usuariocrea, now()::date);
	end if;

	--BUSCAMOS LA FACTURA EN CONSORCIO Y ACTUALIZAMOS EL ESTADO

	select into _existeFacturaConsorcio
	coalesce (
	(SELECT distinct 'EXISTE'
		FROM con.factura_consorcio
		where id_solicitud = _id_solicitud
	), 'NO') as resultado;

	if (_existeFacturaConsorcio = 'EXISTE')then
		update con.factura_consorcio set estado_pe ='S' WHERE  id_solicitud = _id_solicitud ;
	end if;

	--ACTUALIZAMOS LA DESCRIPCION DE LA OFERTA
	update opav.ofertas set
		descripcion = descripcion||'- '|| observaciones,last_update = NOW(),USER_UPDATE = usuariocrea
	where id_solicitud = _id_solicitud;

        --ACTUALIZAMOS SERIE CONSECUTIVO OFERTA
	UPDATE series SET
		last_number = last_number + 1
	WHERE
		dstrct = 'FINV' AND
		agency_id = 'OP' AND
		document_type = 'OFERTASERIE';

        --OBTENEMOS ID_CLIENTE DE LA TABLA OFERTAS
        SELECT INTO _codigoCliente id_cliente FROM opav.ofertas WHERE id_solicitud = _id_solicitud;

        --ACTUALIZAMOS CAMPO TIPO EN TABLA CLIENTES Y LO COLOCAMOS EN R
        UPDATE cliente SET tipo = 'R' WHERE codcli = _codigoCliente;

        --OBTENEMOS ACTUALIZAMOS LA SERIE DE ACCIONES
	SELECT  into _consecutivoAccion
		prefix||lpad(ltrim(to_char(last_number, '9999999999')) , length(serial_fished_no),'0')
	FROM series
	WHERE
		dstrct = 'FINV' and
		agency_id = 'OP' and
		document_type = 'ACMS';

	update series set
		last_number = last_number + 1
	where
		dstrct = 'FINV' and
		agency_id = 'OP' and
		document_type = 'ACMS';

        --Insertamos cabecera de la cotizacion
	SELECT INTO _consecutivoCotizacion
		prefix||lpad(ltrim(to_char(last_number, '9999999999')) , length(serial_fished_no),'0')
	FROM series
	WHERE
		dstrct = 'FINV' and
		agency_id = 'BQ' and
		document_type = 'COTSER';

	--OBTENEMOS EL IVA VIGENTE
	select INTO _iva round(((porcentaje1/100)+1),5) from tipo_de_impuesto where codigo_impuesto = 'IVA02' order by fecha_vigencia desc limit 1;


	--OBTENEMOS UN RECORD DONDE SE ENCUENTRA SI LLEVA AIU O IVA
	SELECT INTO _recordcot * FROM opav.sl_cotizacion where id_accion = _accionPrincipal;

	IF(_recordcot.modalidad_comercial = 0) then
		--IVA

		--INSERTAMOS EN TABLA ACCION
		INSERT INTO
			opav.acciones(id_accion, id_solicitud, estado, contratista, material, mano_obra, descripcion, tipo_trabajo,preparar_facturacion,prefacturar)
		VALUES
			(_consecutivoAccion,_id_solicitud,'090','CC761',_valor_fact_material/recordDistribucion.porcentaje, _valor_mano_obra/recordDistribucion.porcentaje,'Mano de obra', 'Proyectos','S','N');

		--INSERTAR CABECERA DE COTIZACION
		INSERT INTO
			opav.cotizacion(reg_status,idcotizacion,consecutivo,fecha,id_accion,estado,orden_generada,last_update,user_update)
		VALUES
			('',nextval('opav.cotizacion_idcotizacion_seq'),_consecutivoCotizacion,now(),_consecutivoAccion,'P','N',now(),usuariocrea);

		RAISE NOTICE 'Valor de IVA:% ', _iva;
		RAISE NOTICE 'Valor A Facturar:% ', round((_valor_facturar*_iva),2);

		---INSERTAMOS EN DETALLE DE COTIZACION
		INSERT INTO
		opav.cotizaciondets (reg_status,idcotizaciondets,codigo_material,cantidad,aprobado,cod_cotizacion,fecha,observacion,id_accion, compra_provint, cant_provint,precio,precio_venta,oficial)
		VALUES
			('',nextval('opav.cotizaciondets_idcotizaciondets_seq'),'PR035406',1.0,'N',_consecutivoCotizacion,'now()',
			'',_consecutivoAccion,'N',1.0,_valor_facturar/recordDistribucion.porcentaje, round((_valor_facturar*_iva),2) ,'');

	ELSE
		--AIU
		--INSERTAMOS EN TABLA ACCION
		_costo_contratista := (_valor_fact_material/recordDistribucion.porcentaje) + ( _valor_mano_obra/recordDistribucion.porcentaje);
		INSERT INTO
			opav.acciones(id_accion, id_solicitud, estado, contratista, material, mano_obra, administracion , imprevisto , utilidad ,  porc_administracion , porc_imprevisto , porc_utilidad , descripcion, tipo_trabajo,preparar_facturacion,prefacturar)
		VALUES
			(_consecutivoAccion,_id_solicitud,'090','CC761',_valor_fact_material/recordDistribucion.porcentaje, _valor_mano_obra/recordDistribucion.porcentaje, (_costo_contratista * _recordcot.perc_administracion/100) , (_costo_contratista * _recordcot.perc_imprevisto/100 ), (_costo_contratista * _recordcot.perc_utilidad/100 ), _recordcot.perc_administracion , _recordcot.perc_imprevisto , _recordcot.perc_utilidad ,'Mano de obra', 'Proyectos','S','N');

		--INSERTAR CABECERA DE COTIZACION
		INSERT INTO
			opav.cotizacion(reg_status,idcotizacion,consecutivo,fecha,id_accion,estado,orden_generada,last_update,user_update)
		VALUES
			('',nextval('opav.cotizacion_idcotizacion_seq'),_consecutivoCotizacion,now(),_consecutivoAccion,'P','N',now(),usuariocrea);


		RAISE NOTICE 'Valor A Facturar:% ', round((_valor_facturar*_iva),2);

		---INSERTAMOS EN DETALLE DE COTIZACION
		INSERT INTO
		opav.cotizaciondets (reg_status,idcotizaciondets,codigo_material,cantidad,aprobado,cod_cotizacion,fecha,observacion,id_accion, compra_provint, cant_provint,precio,precio_venta,oficial)
		VALUES
			('',nextval('opav.cotizaciondets_idcotizaciondets_seq'),'PR035406',1.0,'N',_consecutivoCotizacion,'now()',
			'',_consecutivoAccion,'N',1.0,_valor_facturar/recordDistribucion.porcentaje, round(((_valor_facturar * ((_recordcot.perc_aiu/100.0)+1)) + (_valor_facturar* (_recordcot.perc_utilidad/100.0) * (_iva-1)) ),2) ,'');
	END IF;



	--Actualizamos la serie
	update series set
		last_number = last_number + 1
	where
		dstrct = 'FINV' and
		agency_id = 'BQ' and
		document_type = 'COTSER';


	RETURN retorno;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sl_preparar_facturacion(character varying, numeric, numeric, character varying, text)
  OWNER TO postgres;
