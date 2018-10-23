-- Function: tem.mc_cambio_documentos(character varying)

-- DROP FUNCTION tem.mc_cambio_documentos(character varying);

CREATE OR REPLACE FUNCTION tem.mc_cambio_documentos(usuario character varying)
  RETURNS boolean AS
$BODY$

DECLARE

	documentos_info RECORD;
	resultado boolean :=false;


  BEGIN
		/*  consultamos todos los datos que fueron insertados por el excel pero con el campo procesado en N  */

		for documentos_info in
			select
				tipo::varchar,
				documento::varchar,
				tipo_documento::varchar,
				nit_codcli::varchar,
				banco::varchar,
				sucursal::varchar,
				cambio::varchar,
				periodo::varchar,
				periodo_nuevo::varchar,
				fecha_nueva::varchar,
				grupo_transaccion::varchar,
				procesado::varchar

			from tem.historico_cambio_documentos
			where procesado ='N'

		loop
			/*  preguntamos el tipo de cambio ya sea f: cambio de fecha para contabilizar
			    o p: periodo cambio de periodo */
			raise notice 'documentos_info: %', documentos_info;
			raise notice 'documentos_info.documento: %', documentos_info.documento;
			raise notice 'documentos_info.nit_codcli: %',documentos_info.nit_codcli;
			raise notice 'documentos_info.periodo: %',documentos_info.periodo;
			raise notice 'documentos_info.tipo: %',documentos_info.tipo;
			raise notice 'documentos_info.tipo_documento: %',documentos_info.tipo_documento;
			IF (documentos_info.cambio ='F')THEN

				if(documentos_info.tipo='CXP')then

					INSERT INTO tem.info_cxp_doc
						SELECT *
						FROM  fin.cxp_doc
						WHERE  documento = documentos_info.documento AND  tipo_documento = documentos_info.tipo_documento and proveedor = documentos_info.nit_codcli;

					INSERT INTO tem.info_cxp_items_doc
						SELECT *
						FROM  fin.cxp_items_doc
						WHERE  documento = documentos_info.documento AND  tipo_documento = documentos_info.tipo_documento and proveedor = documentos_info.nit_codcli;

					update fin.cxp_doc
					set  user_update = usuario,creation_date= documentos_info.fecha_nueva::timestamp, fecha_documento = documentos_info.fecha_nueva::date,last_update =now()
					where   documento = documentos_info.documento AND  tipo_documento = documentos_info.tipo_documento and proveedor = documentos_info.nit_codcli and periodo in ('','000000');

					update fin.cxp_items_doc
					set  user_update= usuario,creation_date = documentos_info.fecha_nueva::timestamp,last_update =now()
					where  documento = documentos_info.documento AND  tipo_documento = documentos_info.tipo_documento and proveedor = documentos_info.nit_codcli;

					update tem.historico_cambio_documentos
					set  procesado ='S'
					where  documento = documentos_info.documento AND  tipo_documento = documentos_info.tipo_documento and nit_codcli = documentos_info.nit_codcli;



				elsif (documentos_info.tipo='EGRESO')then

					INSERT INTO tem.info_egreso
						SELECT *
						FROM egreso
						where document_no = documentos_info.documento  and branch_code = documentos_info.banco and bank_account_no = documentos_info.sucursal;

					INSERT INTO tem.info_egresodet
						SELECT *
						FROM egresodet
						where document_no = documentos_info.documento  and branch_code = documentos_info.banco and bank_account_no = documentos_info.sucursal;

					update egreso
					set user_update = usuario,creation_date = documentos_info.fecha_nueva::timestamp ,last_update =now()
					where document_no = documentos_info.documento  and branch_code = documentos_info.banco and bank_account_no = documentos_info.sucursal and periodo in ('','000000');

					update egresodet
					set user_update = usuario,creation_date = documentos_info.fecha_nueva::timestamp ,last_update =now()
					where document_no = documentos_info.documento  and branch_code = documentos_info.banco and bank_account_no = documentos_info.sucursal;

					update tem.historico_cambio_documentos
					set  procesado ='S'
					where  documento = documentos_info.documento  and banco = documentos_info.banco and sucursal = documentos_info.sucursal;

				elsif (documentos_info.tipo='INGRESO')then

					INSERT INTO tem.info_ingreso
						SELECT *
						FROM con.ingreso
						where num_ingreso = documentos_info.documento  and codcli = documentos_info.nit_codcli
							AND tipo_documento = documentos_info.tipo_documento;


					INSERT INTO tem.info_ingreso_detalle
						SELECT *
						FROM con.ingreso_detalle
						where num_ingreso = documentos_info.documento;


					update con.ingreso
					set  user_update = usuario,creation_date = documentos_info.fecha_nueva::timestamp ,last_update =now()
					where num_ingreso = documentos_info.documento  and codcli = documentos_info.nit_codcli
						and periodo in ('','000000') and tipo_documento = documentos_info.tipo_documento;

					update con.ingreso_detalle
					set user_update = usuario,creation_date = documentos_info.fecha_nueva::timestamp ,last_update = now()
					where num_ingreso = documentos_info.documento and periodo in ('','000000');

					update tem.historico_cambio_documentos
					set  procesado ='S'
					where  documento = documentos_info.documento  and nit_codcli = documentos_info.nit_codcli;


				elsif (documentos_info.tipo='CXC')then

					INSERT INTO tem.info_factura
						SELECT *
						FROM  con.factura
						where  documento = documentos_info.documento and nit = documentos_info.nit_codcli and tipo_documento = documentos_info.tipo_documento;

					INSERT INTO tem.info_factura_detalle
						SELECT *
						FROM con.factura_detalle
						where   documento = documentos_info.documento and nit = documentos_info.nit_codcli;

					update con.factura
					set user_update = usuario ,fecha_factura = documentos_info.fecha_nueva::date, creation_date = documentos_info.fecha_nueva::timestamp ,last_update = now()
					where  documento = documentos_info.documento and nit = documentos_info.nit_codcli and periodo in ('','000000') and tipo_documento = documentos_info.tipo_documento;

					update con.factura_detalle
					set user_update = usuario,creation_date = documentos_info.fecha_nueva::timestamp ,last_update = now()
					where   documento = documentos_info.documento and nit = documentos_info.nit_codcli ;

					update tem.historico_cambio_documentos
					set  procesado ='S'
					where   documento = documentos_info.documento and nit_codcli = documentos_info.nit_codcli;

				end if;

			ELSIF (documentos_info.cambio ='P')THEN

				if(documentos_info.tipo='CXP')then

					INSERT INTO tem.info_cxp_doc
						SELECT *
						FROM  fin.cxp_doc
						where   documento = documentos_info.documento AND  tipo_documento = documentos_info.tipo_documento
						and proveedor = documentos_info.nit_codcli and periodo = documentos_info.periodo;

					INSERT INTO tem.info_comprobante
						SELECT *
						FROM con.comprobante
						where numdoc  = documentos_info.documento and periodo = documentos_info.periodo and grupo_transaccion = documentos_info.grupo_transaccion;

					INSERT INTO tem.info_comprodet
						SELECT *
						FROM con.comprodet
						where numdoc  = documentos_info.documento and periodo = documentos_info.periodo and grupo_transaccion = documentos_info.grupo_transaccion;

					update fin.cxp_doc
					set  user_update = usuario,periodo = documentos_info.periodo_nuevo ,last_update =now()
					where   documento = documentos_info.documento AND  tipo_documento = documentos_info.tipo_documento
					and proveedor = documentos_info.nit_codcli and periodo = documentos_info.periodo;

					update tem.historico_cambio_documentos
					set  procesado ='S'
					where   documento = documentos_info.documento AND  tipo_documento = documentos_info.tipo_documento
						and  nit_codcli = documentos_info.nit_codcli ;

					update con.comprobante set user_update = usuario ,periodo = documentos_info.periodo_nuevo ,last_update =now()
					where numdoc  = documentos_info.documento and periodo = documentos_info.periodo and grupo_transaccion = documentos_info.grupo_transaccion;

					update con.comprodet set user_update = usuario ,periodo = documentos_info.periodo_nuevo ,last_update =now()
					where numdoc  = documentos_info.documento and periodo = documentos_info.periodo and grupo_transaccion = documentos_info.grupo_transaccion;

				elsif (documentos_info.tipo='EGRESO')then

					INSERT INTO tem.info_egreso
						SELECT *
						FROM egreso
						where document_no = documentos_info.documento  and branch_code = documentos_info.banco
						and bank_account_no = documentos_info.sucursal and periodo = documentos_info.periodo;


					INSERT INTO tem.info_comprobante
						SELECT *
						FROM con.comprobante
						where numdoc  = documentos_info.documento and periodo = documentos_info.periodo and grupo_transaccion = documentos_info.grupo_transaccion;

					INSERT INTO tem.info_comprodet
						SELECT *
						FROM con.comprodet
						where numdoc  = documentos_info.documento and periodo = documentos_info.periodo and grupo_transaccion = documentos_info.grupo_transaccion;

					update egreso
					set user_update = usuario,periodo = documentos_info.periodo_nuevo,last_update =now()
					where document_no = documentos_info.documento  and branch_code = documentos_info.banco
						and bank_account_no = documentos_info.sucursal and periodo = documentos_info.periodo;

					update tem.historico_cambio_documentos
					set  procesado ='S'
					where   documento = documentos_info.documento  and banco = documentos_info.banco
						and sucursal = documentos_info.sucursal;

					update con.comprobante set user_update = usuario ,periodo = documentos_info.periodo_nuevo ,last_update =now()
					where numdoc  = documentos_info.documento and periodo = documentos_info.periodo and grupo_transaccion = documentos_info.grupo_transaccion;

					update con.comprodet set user_update = usuario ,periodo = documentos_info.periodo_nuevo ,last_update =now()
					where numdoc  = documentos_info.documento and periodo = documentos_info.periodo and grupo_transaccion = documentos_info.grupo_transaccion;

				elsif (documentos_info.tipo='INGRESO')then

					INSERT INTO tem.info_ingreso
						SELECT *
						FROM con.ingreso
						where num_ingreso = documentos_info.documento  and codcli = documentos_info.nit_codcli and branch_code = documentos_info.banco
						and bank_account_no = documentos_info.sucursal and periodo = documentos_info.periodo and tipo_documento = documentos_info.tipo_documento;

					INSERT INTO tem.info_ingreso_detalle
						SELECT *
						FROM con.ingreso_detalle
						where num_ingreso = documentos_info.documento  and periodo = documentos_info.periodo;

					INSERT INTO tem.info_comprobante
						SELECT *
						FROM con.comprobante
						where numdoc  = documentos_info.documento and periodo = documentos_info.periodo and grupo_transaccion = documentos_info.grupo_transaccion
						 and tipodoc = documentos_info.tipo_documento ;

					INSERT INTO tem.info_comprodet
						SELECT *
						FROM con.comprodet
						where numdoc  = documentos_info.documento and periodo = documentos_info.periodo and grupo_transaccion = documentos_info.grupo_transaccion
						and tipodoc = documentos_info.tipo_documento;

					update con.ingreso
					set  user_update = usuario,periodo = documentos_info.periodo_nuevo,last_update =now()
					where num_ingreso = documentos_info.documento  and codcli = documentos_info.nit_codcli and branch_code = documentos_info.banco
					and bank_account_no = documentos_info.sucursal and periodo = documentos_info.periodo and tipo_documento = documentos_info.tipo_documento;

					update con.ingreso_detalle
					set user_update = usuario,periodo = documentos_info.periodo_nuevo,last_update = now()
					where num_ingreso = documentos_info.documento  and periodo = documentos_info.periodo;

					update tem.historico_cambio_documentos
					set  procesado ='S'
					where   documento = documentos_info.documento  and nit_codcli = documentos_info.nit_codcli and banco = documentos_info.banco
					and sucursal = documentos_info.sucursal;

					update con.comprobante set user_update = usuario ,periodo = documentos_info.periodo_nuevo ,last_update =now()
					where numdoc  = documentos_info.documento and periodo = documentos_info.periodo and grupo_transaccion = documentos_info.grupo_transaccion
					and tipodoc = documentos_info.tipo_documento;

					update con.comprodet set user_update = usuario ,periodo = documentos_info.periodo_nuevo ,last_update =now()
					where numdoc  = documentos_info.documento and periodo = documentos_info.periodo and grupo_transaccion = documentos_info.grupo_transaccion
					and tipodoc = documentos_info.tipo_documento;

				elsif (documentos_info.tipo='CXC')then

					INSERT INTO tem.info_factura
						SELECT *
						FROM  con.factura
						where  documento = documentos_info.documento and nit = documentos_info.nit_codcli and periodo = documentos_info.periodo
						and tipo_documento = documentos_info.tipo_documento;

					INSERT INTO tem.info_comprobante
						SELECT *
						FROM con.comprobante
						where numdoc  = documentos_info.documento and periodo = documentos_info.periodo and grupo_transaccion = documentos_info.grupo_transaccion
						and tipodoc = documentos_info.tipo_documento;

					INSERT INTO tem.info_comprodet
						SELECT *
						FROM con.comprodet
						where numdoc  = documentos_info.documento and periodo = documentos_info.periodo and grupo_transaccion = documentos_info.grupo_transaccion
						and tipodoc = documentos_info.tipo_documento;


					update con.factura
					set user_update = usuario ,periodo = documentos_info.periodo_nuevo ,last_update = now()
					where  documento = documentos_info.documento and nit = documentos_info.nit_codcli and periodo = documentos_info.periodo
					and tipo_documento  = documentos_info.tipo_documento;

					update tem.historico_cambio_documentos
					set  procesado ='S'
					where   documento = documentos_info.documento and nit_codcli = documentos_info.nit_codcli;

					update con.comprobante set user_update = usuario ,periodo = documentos_info.periodo_nuevo ,last_update =now()
					where numdoc  = documentos_info.documento and periodo = documentos_info.periodo and grupo_transaccion = documentos_info.grupo_transaccion
					and tipodoc = documentos_info.tipo_documento;

					update con.comprodet set user_update = usuario ,periodo = documentos_info.periodo_nuevo ,last_update =now()
					where numdoc  = documentos_info.documento and periodo = documentos_info.periodo and grupo_transaccion = documentos_info.grupo_transaccion
					and tipodoc = documentos_info.tipo_documento;
				end if;

			END IF;

			resultado:= true;
			raise notice 'documentos_info: %',documentos_info;

		end loop;



   	return resultado;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION tem.mc_cambio_documentos(character varying)
  OWNER TO postgres;
