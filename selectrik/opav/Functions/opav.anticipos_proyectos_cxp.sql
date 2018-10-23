-- Function: opav.anticipos_proyectos_cxp(character varying, character varying)

-- DROP FUNCTION opav.anticipos_proyectos_cxp(character varying, character varying);

CREATE OR REPLACE FUNCTION opav.anticipos_proyectos_cxp(documentocxc_ character varying, usuario_ character varying)
  RETURNS boolean AS
$BODY$

DECLARE

respuesta boolean :=false;

nit_cliente VARCHAR;
numero_documentoCXP VARCHAR;

anticipoFacturado RECORD;
infoCuentaHcCXP RECORD;
facturaAnticipo RECORD;
info_factura RECORD;

countCxp numeric;

  BEGIN

	raise notice 'documentoCxc_: % usuario_%',documentoCxc_,usuario_;

	--BUSCAMOS LOS ANTICIPOS QUE ESTAN SIN FACTURAR
	FOR anticipoFacturado IN
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
		AND num_factura =documentoCxc_

	LOOP
		raise notice 'anticipoFacturado: %',anticipoFacturado;

		FOR facturaAnticipo IN
			SELECT
				documento::varchar,
				nit::varchar,
				codcli::varchar,
				valor_factura::numeric,
				valor_abono::numeric,
				valor_saldo::numeric
			FROM con.factura
			WHERE documento = documentoCxc_

		LOOP

			--BUSCAMOS SI EXISTE CXP REALCIONADAS AL ANTICIPO
			select into countCxp count(*) from fin.cxp_doc where tipo_referencia_2 ='ANP' and referencia_2 = anticipoFacturado.cod_anticipo;
			raise notice 'countCxp: %',countCxp;

			IF (facturaAnticipo.valor_saldo = 0 AND countCxp = 0) THEN
				select into info_factura * from con.factura where documento = anticipoFacturado.num_factura;

				--BUSCAMOS EL NIT DEL CLIENTE
				SELECT INTO nit_cliente nit
				FROM cliente
				WHERE codcli = anticipoFacturado.cod_cli;
				raise notice 'nit_cliente: %',nit_cliente;

				---OBTENERMOS LA CUENTA Y EL HC PARA CXP
				FOR  infoCuentaHcCXP IN
					SELECT
						cuenta,
						hc
					FROM opav.sl_cuentas_anticipos
					WHERE reg_status =''
					AND tipo_documento = 'FAP'
				LOOP
					raise notice 'infoCuentaHcCXP: %',infoCuentaHcCXP;
				END LOOP;

				--GENERAMOS EL NUMERO DE CXP
				SELECT INTO numero_documentoCXP 'FPP'||(get_lcod('FPP'));
				raise notice 'numero_documentoCXP: %',numero_documentoCXP;

				--CREAMOS LA CABECERA DE LA CXP
				--// FECHA DE VENCIMIENTO //BANCO
				INSERT INTO fin.cxp_doc(
					reg_status,dstrct, proveedor, tipo_documento, documento, descripcion,agencia,
					handle_code, aprobador, moneda,
					vlr_neto, vlr_total_abonos, vlr_saldo, vlr_neto_me, vlr_total_abonos_me, vlr_saldo_me,
					creation_date, creation_user, base, moneda_banco,fecha_documento, fecha_vencimiento,
					tipo_documento_rel, documento_relacionado,tipo_referencia_2,referencia_2, tipo_referencia_3,referencia_3,banco,sucursal)
				VALUES (
					'','FINV', nit_cliente, 'FAP', numero_documentoCXP, 'FACTURA A PAGAR DEL ANTICPO: '||anticipoFacturado.cod_anticipo, 'OP',
					infoCuentaHcCXP.hc, 'ADMIN', 'PES',
					info_factura.valor_factura, 0, info_factura.valor_factura, info_factura.valor_factura, 0, info_factura.valor_factura,
					now(), usuario_, 'COL','PES', NOW(),NOW(),
					'ANP', anticipoFacturado.cod_anticipo, 'ANP', anticipoFacturado.cod_anticipo, 'SOL',anticipoFacturado.id_solicitud,'BANCOLOMBIA','CA');

				--CREAMOS EL DETALLE DE LA CXP
				INSERT INTO fin.cxp_items_doc(
					reg_status,dstrct, proveedor, tipo_documento, documento, item,
					descripcion, vlr, vlr_me, codigo_cuenta,
					creation_date, creation_user, base,
					tipo_referencia_2, referencia_2, tipo_referencia_3,referencia_3)
				VALUES (
					'','FINV', nit_cliente, 'FAP', numero_documentoCXP, '001',
					'FACTURA A PAGAR DEL ANTICPO: '||anticipoFacturado.cod_anticipo, info_factura.valor_factura, info_factura.valor_factura, infoCuentaHcCXP.cuenta,
					now(), usuario_, 'COL',
					'ANP', anticipoFacturado.cod_anticipo, 'SOL', anticipoFacturado.id_solicitud );

				--ACTUALIZAMOS EL ANTICIPO COLOCANDO EL NUMERO DE CXC GANERADO
				UPDATE opav.sl_anticipos SET
				num_cxp=numero_documentoCXP, last_update=now(), user_update=usuario_
				WHERE id_solicitud=anticipoFacturado.id_solicitud;

				respuesta:= true;
			END IF;
		END LOOP;
	END LOOP;
raise notice 'respuesta: %',respuesta;
return respuesta;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.anticipos_proyectos_cxp(character varying, character varying)
  OWNER TO postgres;
