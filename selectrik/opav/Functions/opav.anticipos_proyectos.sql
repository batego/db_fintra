-- Function: opav.anticipos_proyectos(character varying, character varying, character varying, numeric, numeric, character varying, character varying)

-- DROP FUNCTION opav.anticipos_proyectos(character varying, character varying, character varying, numeric, numeric, character varying, character varying);

CREATE OR REPLACE FUNCTION opav.anticipos_proyectos(codigo_cliente_ character varying, cod_cotizacion_ character varying, id_solicitud_ character varying, porcentaje_anticipo_ numeric, valor_anticipo_ numeric, usuario_ character varying, tipo_anticipo_ character varying)
  RETURNS boolean AS
$BODY$

DECLARE

respuesta boolean :=false;

nit_cliente VARCHAR;
numero_documentoCXC VARCHAR;
numero_documentoCXP VARCHAR;
numero_anticipo VARCHAR;
tipo_anticipo_caso varchar;

anticipoxfacturar RECORD;
infoCuentaHcCXC RECORD;
infoCuentaHcCXP RECORD;
infoOferta RECORD;


  BEGIN

	-- INSERTAMOS EL ANTICIPO DE LA SOLICITUD


		INSERT INTO opav.sl_anticipos(
			cod_anticipo, id_solicitud, cod_cli,
			cod_cotizacion, porc_anticipo, valor_anticipo, creation_date,
			creation_user,tipo_anticipo)
		VALUES (
			'ANP'||(get_lcod('ANP')), id_solicitud_,codigo_cliente_,
			cod_cotizacion_, porcentaje_anticipo_, valor_anticipo_, now(), usuario_,tipo_anticipo_);

	--BUSCAMOS LOS ANTICIPOS QUE ESTAN SIN FACTURAR
	FOR anticipoxfacturar IN
		SELECT
			cod_anticipo::varchar,
			id_solicitud::varchar,
			cod_cli::varchar,
			cod_cotizacion::varchar,
			porc_anticipo::numeric,
			valor_anticipo::numeric,
			num_factura::varchar
		FROM opav.sl_anticipos
		WHERE reg_status =''
		AND num_factura =''

	LOOP
		raise notice 'anticipoxfacturar: %',anticipoxfacturar;

		--GENERAMOS EL NUMERO DE CXC
		SELECT INTO numero_documentoCXC 'FPA'||(get_lcod('FPA'));
		raise notice 'numero_documentoCXC: %',numero_documentoCXC;

		--BUSCAMOS EL NIT DEL CLIENTE
		SELECT INTO nit_cliente nit
		FROM cliente WHERE codcli = codigo_cliente_;
		raise notice 'nit_cliente: %',nit_cliente;

		select into tipo_anticipo_caso caso
		from opav.sl_anticipos_casos
		where id = tipo_anticipo_;


		FOR  infoCuentaHcCXC IN
			SELECT
				cuenta,
				hc
			FROM opav.sl_cuentas_anticipos
			WHERE reg_status =''
			AND tipo_documento = 'FAC'
		LOOP
			raise notice 'infoCuentaHcCXC: %',infoCuentaHcCXC;
		END LOOP;

		FOR  infoOferta IN
			SELECT
				num_os,
				id_solicitud
			FROM opav.ofertas
			WHERE reg_status =''
			AND id_solicitud = anticipoxfacturar.id_solicitud
		LOOP
			raise notice 'infoOferta: %',infoOferta;
		END LOOP;

		--INSERTAMOS LA CABECERA DE LA CXC
		INSERT INTO con.factura(
			reg_status,dstrct,tipo_documento,documento,nit,codcli,
			fecha_factura,fecha_vencimiento,descripcion,valor_factura,valor_abono,
			valor_saldo,valor_facturame,valor_abonome,valor_saldome,moneda,cantidad_items,forma_pago,agencia_facturacion,base,
			creation_date,creation_user,cmc,tipo_referencia_1,referencia_1,tipo_referencia_2,referencia_2, tipo_ref1, ref1,tipo_referencia_3,referencia_3)
		VALUES (
			'','FINV','FAC',numero_documentoCXC,nit_cliente,codigo_cliente_,
			NOW(),(now() +'7 days')::date,'FACTURA ANTICIPO'||tipo_anticipo_caso|| ' SOLICITUD - '||id_solicitud_,valor_anticipo_,0,
			valor_anticipo_,valor_anticipo_,0,valor_anticipo_,'PES','001','CREDITO','OP','COL',
			now(),usuario_,infoCuentaHcCXC.hc,'SOL',id_solicitud_,'ANP',anticipoxfacturar.cod_anticipo,'SOL',id_solicitud_,'NUMOS',infoOferta.num_os);

		--INSERTAMOS EL DETALLE DE LA CXC
		INSERT INTO con.factura_detalle(
			reg_status,dstrct,tipo_documento,documento,item,nit,descripcion,
			codigo_cuenta_contable,cantidad,valor_unitario,valor_unitariome,valor_item,valor_itemme,
			moneda,base,tipo_referencia_1,referencia_1,tipo_referencia_2,referencia_2,creation_user,creation_date,tipo_documento_rel,documento_relacionado,tipo_referencia_3,referencia_3)
		VALUES
			('','FINV','FAC',numero_documentoCXC,'001',nit_cliente,'FACTURA ANTICIPO'||tipo_anticipo_caso|| ' SOLICITUD - '||id_solicitud_,
			infoCuentaHcCXC.cuenta,'1',valor_anticipo_,valor_anticipo_,valor_anticipo_,valor_anticipo_,
			'PES','COL','SOL',id_solicitud_,'ANP',anticipoxfacturar.cod_anticipo,usuario_ ,now(),'NUMOS',infoOferta.num_os,'NUMOS',infoOferta.num_os);

		--ACTUALIZAMOS EL ANTICIPO COLOCANDO EL NUMERO DE CXC GANERADO
		UPDATE opav.sl_anticipos SET
		num_factura=numero_documentoCXC, last_update=now(), user_update=usuario_
		WHERE id_solicitud=id_solicitud_;


		--ACTUALIZAMOS EL ESTADO DE LA SOLICITUD Y TRAZABILIDAD

		UPDATE opav.ofertas SET estado = '430', trazabilidad ='4'
		WHERE id_solicitud = id_solicitud_;

		respuesta:= true;

	END LOOP;

   	return respuesta;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.anticipos_proyectos(character varying, character varying, character varying, numeric, numeric, character varying, character varying)
  OWNER TO postgres;
