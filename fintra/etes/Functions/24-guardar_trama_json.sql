-- Function: etes.guardar_trama_json(text[], text[], text[], text[], text[], integer, character varying)

-- DROP FUNCTION etes.guardar_trama_json(text[], text[], text[], text[], text[], integer, character varying);

CREATE OR REPLACE FUNCTION etes.guardar_trama_json(propietario text[], conductor text[], intermediario text[], vehiculo text[], anticipo text[], idproceso integer, usuario character varying)
  RETURNS boolean AS
$BODY$
DECLARE
retorno boolean:=true;
idPropietario integer;
recordAgenciaTransportadora record;
idVehiculo integer;
idConductor integer;
idIntermediario integer;
idProserv integer;
nro_planilla varchar:='';
id_tabla integer:=0;
descuentos text:='';



BEGIN

	/****************************************************************************************/
	/*************************       PROCESAMOS EL ARRAY DE PROPIETARIO	    *************/
	/****************************************************************************************/
	FOR i IN 1 .. (array_upper(propietario, 1))
	LOOP

	     PERFORM * FROM proveedor where nit=propietario[i][2];
		IF(FOUND)THEN
		 RAISE NOTICE '1.0 EXISTE SE ACTUALIZA PROVEEDOR';
			/********ACTUALIZAMOS EL PROVEEDOR********/
			UPDATE proveedor
				SET	payment_name=upper(propietario[i][4]),
					branch_code= upper(propietario[i][5]),
					bank_account_no=upper(propietario[i][6]),
					tipo_cuenta=propietario[i][9],
					no_cuenta=propietario[i][10],
					cedula_cuenta=propietario[i][7],
					nombre_cuenta=propietario[i][8],
					last_update=NOW(),
					user_update=usuario
			WHERE nit=propietario[i][2];

			/****VERIFICAMOS QUE EXISTA EL PROPIETARIO SI EXISTE SE ACTUALIZA SI NO SE INSERTA***/
			PERFORM * FROM etes.propietario where cod_proveedor=propietario[i][2];
			   IF(FOUND)THEN
				RAISE NOTICE '1.1 EXISTE SE ACTUALIZA PROPIETARIO';
				UPDATE etes.propietario
				   SET  nombre=upper(propietario[i][4]),
					banco=upper(propietario[i][5]),
				        sucursal=upper(propietario[i][6]),
				        cedula_titular_cuenta=propietario[i][7],
				        nombre_titular_cuenta=propietario[i][8],
				        tipo_cuenta=propietario[i][9],
				        no_cuenta=propietario[i][10],
				        direccion=propietario[i][11],
				        veto=propietario[i][12],
				        veto_causal=propietario[i][13],
				        last_update=NOW(),
					user_update=usuario
				 WHERE cod_proveedor=propietario[i][2];

			   ELSE
				RAISE NOTICE '1.2 SE INSERTA EL PROPIETARIO';
				/***INSERT PROPIETARIO***/
				INSERT INTO etes.propietario(
					    reg_status, dstrct, cod_proveedor, nombre, banco, sucursal,
					    cedula_titular_cuenta, nombre_titular_cuenta, tipo_cuenta, no_cuenta,
					    direccion, veto, veto_causal, creation_date, creation_user, last_update,user_update)
				    VALUES ('', 'FINV', propietario[i][2], upper(propietario[i][4]), upper(propietario[i][5]), upper(propietario[i][6]),
					    propietario[i][7], propietario[i][8], propietario[i][9], propietario[i][10],
					    propietario[i][11], '', '', NOW(), usuario, '0099-01-01 00:00:00'::timestamp without time zone,'');

			   END IF;


		ELSE

		   RAISE NOTICE '1.3 NO EXISTE SE INSERTA EL PROVEEDOR Y PROPIETARIO';
			/***INSERT PROVEEDOR***/
			INSERT INTO proveedor(
				    reg_status, dstrct, nit, id_mims, payment_name, branch_code,
				    bank_account_no, agency_id, last_update, user_update, creation_date,
				    creation_user, tipo_doc, banco_transfer, suc_transfer, tipo_cuenta,
				    no_cuenta, codciu_cuenta, clasificacion, gran_contribuyente,
				    agente_retenedor, autoret_rfte, autoret_iva, autoret_ica, hc,
				    plazo, base, cedula_cuenta, nombre_cuenta, concept_code, cmc,
				    tipo_pago, nit_beneficiario, aprobado, fecha_aprobacion, usuario_aprobacion,
				    ret_pago, cod_fenalco, tasa_fenalco, cliente_fenalco, cliente_captacion,
				    tasa_captacion, frecuencia_captacion, custodiacheque, remesa,
				    dtsp, afiliado, sede, regimen, nit_afiliado)
			    VALUES ('', 'FINV', propietario[i][2], '',upper(propietario[i][4]), upper(propietario[i][5]),
				    upper(propietario[i][6]), '', '0099-01-01 00:00:00'::timestamp without time zone, '', NOW(),
				    usuario, propietario[i][3], '', '', propietario[i][9],
				    propietario[i][10], '', propietario[i][1], 'N',
				    'N', 'N', 'N', 'N', '',
				    1, 'COL', propietario[i][7], propietario[i][8], '01', '01',
				    'T', propietario[i][2], 'N', '0099-01-01 00:00:00'::timestamp without time zone, '',
				    'N', '', 0, false, false,
				    0, 'Mensual', 1450, 0,
				    '', 'N', 'N', '', '');

			/***INSERT PROPIETARIO***/
			INSERT INTO etes.propietario(
				    reg_status, dstrct, cod_proveedor, nombre, banco, sucursal,
				    cedula_titular_cuenta, nombre_titular_cuenta, tipo_cuenta, no_cuenta,
				    direccion, veto, veto_causal, creation_date, creation_user, last_update,user_update)
			    VALUES ('', 'FINV', propietario[i][2], upper(propietario[i][4]), upper(propietario[i][5]), upper(propietario[i][6]),
				    propietario[i][7], propietario[i][8], propietario[i][9], propietario[i][10],
				    propietario[i][11], '', '', NOW(), usuario, '0099-01-01 00:00:00'::timestamp without time zone,'');


		END IF;


		/********* INSERT TABLA CLIENTES DESPUES DE PITO POR EL NEGRO *********/
		INSERT INTO cliente(
		    estado, codcli, nomcli, creation_date,
		    base,  nit,dstrct,cmc,direccion, telefono, nomcontacto, telcontacto,
		    email_contacto,
		    direccion_contacto, hc, rif, ciudad, pais, creation_user )
		SELECT 'A',get_lcod('CLIENTE'), propietario[i][4], now(), 'COL', propietario[i][2], 'FINV',
		    '', propietario[i][11],'', '', '', '', '','',propietario[i][3], 'BQ','CO', usuario
		WHERE  not exists (select nit from cliente where nit =propietario[i][2]);

			      RAISE NOTICE 'indice i: % indice j: % clasificacion : %',i,1, propietario[i][1];
			      RAISE NOTICE 'indice i: % indice j: % nit : %',i,2, propietario[i][2];
			      RAISE NOTICE 'indice i: % indice j: % tipo_doc : %',i,3, propietario[i][3];
			      RAISE NOTICE 'indice i: % indice j: % nombre : %',i,4, propietario[i][4];
			      RAISE NOTICE 'indice i: % indice j: % banco : %',i,5, propietario[i][5];
			      RAISE NOTICE 'indice i: % indice j: % sucursal : %',i,6, propietario[i][6];
			      RAISE NOTICE 'indice i: % indice j: % cedula_titular_cuenta : %',i,7, propietario[i][7];
			      RAISE NOTICE 'indice i: % indice j: % nombre_titular_cuenta : %',i,8, propietario[i][8];
			      RAISE NOTICE 'indice i: % indice j: % tipo_cuenta : %',i,9, propietario[i][9];
			      RAISE NOTICE 'indice i: % indice j: % no_cuenta : %',i,10, propietario[i][10];
			      RAISE NOTICE 'indice i: % indice j: % direccion : %',i,11, propietario[i][11];
			      RAISE NOTICE 'indice i: % indice j: % veto : %',i,12, propietario[i][12];
			      RAISE NOTICE 'indice i: % indice j: % veto_causal : %',i,13, propietario[i][13];
			    --  RAISE NOTICE 'indice i: % indice j: % creation_date : %',i,14, propietario[i][14];
			    --  RAISE NOTICE 'indice i: % indice j: % creation_user : %',i,15, propietario[i][15];

	END LOOP;


	/****************************************************************************************/
	/*************************       PROCESAMOS EL ARRAY DEL CONDUCTOR	    *************/
	/****************************************************************************************/
	FOR i IN 1 .. (array_upper(conductor, 1))
	LOOP

		PERFORM * FROM proveedor where nit=conductor[i][2];
		IF(FOUND)THEN

		   RAISE NOTICE '2.0 EXISTE SE ACTUALIZA PROVEEDOR';
			/********ACTUALIZAMOS EL PROVEEDOR********/
			UPDATE proveedor
				SET	payment_name=upper(conductor[i][5]),
					branch_code=upper(conductor[i][6]),
					bank_account_no=upper(conductor[i][7]),
					tipo_cuenta= conductor[i][10],
					no_cuenta=conductor[i][11],
					cedula_cuenta= conductor[i][8],
					nombre_cuenta=conductor[i][9],
					last_update=NOW(),
					user_update=usuario
			WHERE nit=conductor[i][2];

			/****VERIFICAMOS QUE EXISTA EL CONDUCTOR SI EXISTE SE ACTUALIZA SI NO SE INSERTA***/
			PERFORM * FROM etes.conductor where cod_proveedor=conductor[i][2];
			    IF(FOUND)THEN
				RAISE NOTICE '2.1 EXISTE SE ACTUALIZA CONDUCTOR';
				  UPDATE etes.conductor
					   SET
					       nombre=upper(conductor[i][5]),
					       banco=upper(conductor[i][6]),
					       sucursal=upper(conductor[i][7]),
					       cedula_titular_cuenta=conductor[i][8],
					       nombre_titular_cuenta=conductor[i][9],
					       tipo_cuenta=conductor[i][10],
					       no_cuenta=conductor[i][11],
					       direccion=conductor[i][16],
					       veto=conductor[i][12],
					       veto_causal=conductor[i][13],
					       last_update=NOW(),
					       user_update=usuario
				  WHERE cod_proveedor=conductor[i][2];

			     ELSE

				   /***INSERT CONDUCTOR***/
				   INSERT INTO etes.conductor(
						reg_status, dstrct, cod_proveedor, nombre, banco, sucursal,
						cedula_titular_cuenta, nombre_titular_cuenta, tipo_cuenta, no_cuenta,
						direccion, veto, veto_causal, creation_date, creation_user, last_update,user_update)
					 VALUES ('', 'FINV', conductor[i][2], upper(conductor[i][5]), upper(conductor[i][6]), upper(conductor[i][7]),
					       conductor[i][8], conductor[i][9], conductor[i][10], conductor[i][11],
					       conductor[i][16], conductor[i][12], conductor[i][13], NOW(), usuario, '0099-01-01 00:00:00'::timestamp without time zone,'');
			    END IF;

		ELSE

		   RAISE NOTICE '2.2 NO EXISTE SE INSERTA EL PROVEEDOR Y CONDUCTOR';

			/***INSERT PROVEEDOR***/
			INSERT INTO proveedor(
				    reg_status, dstrct, nit, id_mims, payment_name, branch_code,
				    bank_account_no, agency_id, last_update, user_update, creation_date,
				    creation_user, tipo_doc, banco_transfer, suc_transfer, tipo_cuenta,
				    no_cuenta, codciu_cuenta, clasificacion, gran_contribuyente,
				    agente_retenedor, autoret_rfte, autoret_iva, autoret_ica, hc,
				    plazo, base, cedula_cuenta, nombre_cuenta, concept_code, cmc,
				    tipo_pago, nit_beneficiario, aprobado, fecha_aprobacion, usuario_aprobacion,
				    ret_pago, cod_fenalco, tasa_fenalco, cliente_fenalco, cliente_captacion,
				    tasa_captacion, frecuencia_captacion, custodiacheque, remesa,
				    dtsp, afiliado, sede, regimen, nit_afiliado)
			    VALUES ('', 'FINV', conductor[i][2], '',upper(conductor[i][5]), upper(conductor[i][6]),
				    upper(conductor[i][7]), '','0099-01-01 00:00:00'::timestamp without time zone, '', NOW(),
				    usuario, conductor[i][3], '', '', conductor[i][10],
				    conductor[i][11], '', conductor[i][1], 'N',
				    'N', 'N', 'N', 'N', '',
				    1, 'COL', conductor[i][8], conductor[i][9], '01', '01',
				    'T', conductor[i][2], 'N', '0099-01-01 00:00:00'::timestamp without time zone, '',
				    'N', '', 0, false, false,
				    0, 'Mensual', 1450, 0,
				    '', 'N', 'N', '', '');

			/***INSERT CONDUCTOR***/
			INSERT INTO etes.conductor(
				    reg_status, dstrct, cod_proveedor, nombre, banco, sucursal,
				    cedula_titular_cuenta, nombre_titular_cuenta, tipo_cuenta, no_cuenta,
				    direccion, veto, veto_causal, creation_date, creation_user, last_update,
				    user_update)
			    VALUES ('', 'FINV', conductor[i][2], upper(conductor[i][5]), upper(conductor[i][6]),upper(conductor[i][7]),
				    conductor[i][8], conductor[i][9], conductor[i][10], conductor[i][11],
				    conductor[i][16], conductor[i][12], conductor[i][13], NOW(), usuario, '0099-01-01 00:00:00'::timestamp without time zone,
				    '');



		END IF;

		/********* INSERT TABLA CLIENTES DESPUES DE PITO POR EL NEGRO *********/
		INSERT INTO cliente(
		    estado, codcli, nomcli, creation_date,
		    base,  nit,dstrct,cmc,direccion, telefono, nomcontacto, telcontacto,
		    email_contacto,
		    direccion_contacto, hc, rif, ciudad, pais, creation_user )
		SELECT 'A',get_lcod('CLIENTE'), conductor[i][5], now(), 'COL', conductor[i][2], 'FINV',
		    '', conductor[i][16],conductor[i][17], '', '', conductor[i][19], '','',conductor[i][3],'BQ','CO', usuario
		WHERE  not exists (select nit from cliente where nit =conductor[i][2]);

			      RAISE NOTICE 'indice i: % indice j: % clasificacion : %',i,1, conductor[i][1];
			      RAISE NOTICE 'indice i: % indice j: % nit : %',i,2, conductor[i][2];
			      RAISE NOTICE 'indice i: % indice j: % tipo_doc : %',i,3, conductor[i][3];
			      RAISE NOTICE 'indice i: % indice j: % fecha_nacimiento : %',i,4, conductor[i][4];
			      RAISE NOTICE 'indice i: % indice j: % nombre : %',i,5, conductor[i][5];
			      RAISE NOTICE 'indice i: % indice j: % banco : %',i,6, conductor[i][6];
			      RAISE NOTICE 'indice i: % indice j: % sucursal : %',i,7, conductor[i][7];
			      RAISE NOTICE 'indice i: % indice j: % cedula_titular_cuenta : %',i,8, conductor[i][8];
			      RAISE NOTICE 'indice i: % indice j: % nombre_titular_cuenta : %',i,9, conductor[i][9];
			      RAISE NOTICE 'indice i: % indice j: % tipo_cuenta : %',i,10, conductor[i][10];
			      RAISE NOTICE 'indice i: % indice j: % no_cuenta : %',i,11, conductor[i][11];
			      RAISE NOTICE 'indice i: % indice j: % veto : %',i,12, conductor[i][12];
			      RAISE NOTICE 'indice i: % indice j: % veto_causal : %',i,13, conductor[i][13];
			      RAISE NOTICE 'indice i: % indice j: % ciudad : %',i,14, conductor[i][14];
			      RAISE NOTICE 'indice i: % indice j: % barrio : %',i,15, conductor[i][15];
			      RAISE NOTICE 'indice i: % indice j: % direccion : %',i,16, conductor[i][16];
			      RAISE NOTICE 'indice i: % indice j: % telefono : %',i,17, conductor[i][17];
			      RAISE NOTICE 'indice i: % indice j: % celular : %',i,18, conductor[i][18];
			      RAISE NOTICE 'indice i: % indice j: % email : %',i,19, conductor[i][19];
			   --   RAISE NOTICE 'indice i: % indice j: % last_update : %',i,20, conductor[i][20];
			   --   RAISE NOTICE 'indice i: % indice j: % user_update : %',i,21, conductor[i][21];
			   --   RAISE NOTICE 'indice i: % indice j: % creation_date : %',i,22, conductor[i][22];
			   --   RAISE NOTICE 'indice i: % indice j: % creation_user : %',i,23, conductor[i][23];

	END LOOP;

        /****************************************************************************************/
	/*************************       PROCESAMOS EL ARRAY DEL INTERMEDIARIO	    *************/
	/****************************************************************************************/
	IF(array_upper(intermediario, 1) > 0)THEN

		FOR i IN 1 .. (array_upper(intermediario, 1))
		LOOP
		      PERFORM * FROM proveedor where nit=intermediario[i][2];
			IF(FOUND)THEN

			   RAISE NOTICE '3.0 EXISTE SE ACTUALIZA PROVEEDOR';
				/********ACTUALIZAMOS EL PROVEEDOR********/
				UPDATE proveedor
					SET	payment_name=upper(intermediario[i][4]),
						branch_code= upper(intermediario[i][5]),
						bank_account_no=upper(intermediario[i][6]),
						tipo_cuenta= intermediario[i][9],
						no_cuenta=intermediario[i][10],
						cedula_cuenta= intermediario[i][7],
						nombre_cuenta=intermediario[i][8],
						last_update=NOW(),
						user_update=usuario
				WHERE nit=intermediario[i][2];

				/****VERIFICAMOS QUE EXISTA EL INTERMEDIARIO SI EXISTE SE ACTUALIZA SI NO SE INSERTA***/
				PERFORM * FROM etes.intermediario where cod_proveedor=intermediario[i][2];
				    IF(FOUND)THEN
					RAISE NOTICE '3.1 EXISTE SE ACTUALIZA INTERMEDIARIO';
					UPDATE etes.intermediario
					   SET nombre= upper(intermediario[i][4]),
					       veto=intermediario[i][11],
					       veto_causal=intermediario[i][12],
					       last_update=NOW(),
					       user_update=usuario
					 WHERE cod_proveedor=intermediario[i][2];
				    ELSE
					 /***INSERT INTERMEDIARIO***/
					INSERT INTO etes.intermediario(
						    reg_status, dstrct, cod_proveedor, nombre,
						    banco,sucursal,cedula_titular_cuenta,nombre_titular_cuenta,tipo_cuenta,no_cuenta,
						    veto, veto_causal,
						    creation_date, creation_user, last_update, user_update)
					    VALUES ('', 'FINV', intermediario[i][2], upper(intermediario[i][4]),
						    intermediario[i][5],intermediario[i][6],intermediario[i][7],intermediario[i][8],intermediario[i][9],intermediario[i][10],
						    intermediario[i][11], intermediario[i][12],
						    NOW(), usuario, '0099-01-01 00:00:00'::timestamp without time zone, '');

				    END IF;

			ELSE
				RAISE NOTICE '3.2 NO EXISTE SE INSERTA EL PROVEEDOR E INTERMEDIARIO';

				/***INSERT PROVEEDOR***/
				INSERT INTO proveedor(
					    reg_status, dstrct, nit, id_mims, payment_name, branch_code,
					    bank_account_no, agency_id, last_update, user_update, creation_date,
					    creation_user, tipo_doc, banco_transfer, suc_transfer, tipo_cuenta,
					    no_cuenta, codciu_cuenta, clasificacion, gran_contribuyente,
					    agente_retenedor, autoret_rfte, autoret_iva, autoret_ica, hc,
					    plazo, base, cedula_cuenta, nombre_cuenta, concept_code, cmc,
					    tipo_pago, nit_beneficiario, aprobado, fecha_aprobacion, usuario_aprobacion,
					    ret_pago, cod_fenalco, tasa_fenalco, cliente_fenalco, cliente_captacion,
					    tasa_captacion, frecuencia_captacion, custodiacheque, remesa,
					    dtsp, afiliado, sede, regimen, nit_afiliado)
				    VALUES ('', 'FINV',  intermediario[i][2], '',upper(intermediario[i][4]), upper(intermediario[i][5]),
					    upper(intermediario[i][6]), '', '0099-01-01 00:00:00'::timestamp without time zone, '', NOW(),
					    usuario, intermediario[i][3], '', '', intermediario[i][9],
					    intermediario[i][10], '',intermediario[i][1], 'N',
					    'N', 'N', 'N', 'N', '',
					    1, 'COL', intermediario[i][7], intermediario[i][8], '01', '01',
					    'T',intermediario[i][2], 'N', '0099-01-01 00:00:00'::timestamp without time zone, '',
					    'N', '', 0, false, false,
					    0, 'Mensual', 1450, 0,
					    '', 'N', 'N', '', '');

				 /***INSERT INTERMEDIARIO***/

				INSERT INTO etes.intermediario(
					    reg_status, dstrct, cod_proveedor, nombre,
					    banco,sucursal,cedula_titular_cuenta,nombre_titular_cuenta,tipo_cuenta,no_cuenta,
					    veto, veto_causal,
					    creation_date, creation_user, last_update, user_update)
				    VALUES ('', 'FINV', intermediario[i][2], upper(intermediario[i][4]),
					    intermediario[i][5],intermediario[i][6],intermediario[i][7],intermediario[i][8],intermediario[i][9],intermediario[i][10],
					    intermediario[i][11], intermediario[i][12],
					    NOW(), usuario, '0099-01-01 00:00:00'::timestamp without time zone, '');

			END IF;

			/********* INSERT TABLA CLIENTES DESPUES DE PITO POR EL NEGRO *********/
			INSERT INTO cliente(
			    estado, codcli, nomcli, creation_date,
			    base,  nit,dstrct,cmc,direccion, telefono, nomcontacto, telcontacto,
			    email_contacto,
			    direccion_contacto, hc, rif, ciudad, pais, creation_user )
			SELECT 'A',get_lcod('CLIENTE'), intermediario[i][4], now(), 'COL', intermediario[i][2], 'FINV',
			    '', '','', '', '', '', '','',intermediario[i][3], 'BQ','CO', usuario
			WHERE  not exists (select nit from cliente where nit =intermediario[i][2]);

			      RAISE NOTICE 'indice i: % indice j: % clasificacion : %',i,1, intermediario[i][1];
			      RAISE NOTICE 'indice i: % indice j: % nit : %',i,2, intermediario[i][2];
			      RAISE NOTICE 'indice i: % indice j: % tipo_doc : %',i,3, intermediario[i][3];
			      RAISE NOTICE 'indice i: % indice j: % nombre : %',i,4, intermediario[i][4];
			      RAISE NOTICE 'indice i: % indice j: % banco : %',i,5, intermediario[i][5];
			      RAISE NOTICE 'indice i: % indice j: % sucursal : %',i,6, intermediario[i][6];
			      RAISE NOTICE 'indice i: % indice j: % cedula_titular_cuenta : %',i,7, intermediario[i][7];
			      RAISE NOTICE 'indice i: % indice j: % nombre_titular_cuenta : %',i,8, intermediario[i][8];
			      RAISE NOTICE 'indice i: % indice j: % tipo_cuenta : %',i,9, intermediario[i][9];
			      RAISE NOTICE 'indice i: % indice j: % no_cuenta : %',i,10, intermediario[i][10];
			      RAISE NOTICE 'indice i: % indice j: % veto : %',i,11, intermediario[i][11];
			      RAISE NOTICE 'indice i: % indice j: % veto_causal : %',i,12, intermediario[i][12];
			    --  RAISE NOTICE 'indice i: % indice j: % last_update : %',i,13, intermediario[i][13];
			    --  RAISE NOTICE 'indice i: % indice j: % user_update : %',i,14, intermediario[i][14];
			    --  RAISE NOTICE 'indice i: % indice j: % creation_date : %',i,15, intermediario[i][15];
			    --  RAISE NOTICE 'indice i: % indice j: % creation_user : %',i,16, intermediario[i][16];

		END LOOP;
	END IF;

	/****************************************************************************************/
	/*************************       PROCESAMOS EL ARRAY DEL VEHICULO	    *************/
	/****************************************************************************************/
	FOR i IN 1 .. (array_upper(vehiculo, 1))
	LOOP
		SELECT INTO idPropietario id FROM etes.propietario where cod_proveedor=vehiculo[i][1];
		  RAISE NOTICE 'idPropietario %',idPropietario;
		PERFORM * FROM etes.vehiculo where upper(placa)=upper(vehiculo[i][2]);
		    IF(FOUND)THEN
			  RAISE NOTICE '4.0 EXISTE SE ACTUALIZA EL VEHICULO';
				UPDATE etes.vehiculo
				   SET id_propietario=idPropietario,
				       marca=vehiculo[i][3],
				       modelo=vehiculo[i][4],
				       servicio=vehiculo[i][5],
				       tipo_vehiculo=vehiculo[i][6],
				       veto=vehiculo[i][7],
				       veto_causal=vehiculo[i][8],
				       last_update=NOW(),
				       user_update=usuario
				 WHERE upper(placa) =upper(vehiculo[i][2]);
	            ELSE
			  RAISE NOTICE '4.1 NO EXISTE SE INSERTA EL VEHICULO';
				INSERT INTO etes.vehiculo(
					    reg_status, dstrct, id_propietario, placa, marca, modelo,
					    servicio, tipo_vehiculo, veto, veto_causal, creation_date, creation_user,
					    last_update, user_update)
				    VALUES ('', 'FINV', idPropietario, upper(vehiculo[i][2]),vehiculo[i][3], vehiculo[i][4],
					    vehiculo[i][5], vehiculo[i][6], vehiculo[i][7],vehiculo[i][8],NOW(), usuario,
					    '0099-01-01 00:00:00'::timestamp without time zone, '');

		    END IF;

			RAISE NOTICE 'indice i: % indice j: % cedula_propietario : %',i,1, vehiculo[i][1];
			RAISE NOTICE 'indice i: % indice j: % placa : %',i,2, vehiculo[i][2];
			RAISE NOTICE 'indice i: % indice j: % marca : %',i,3, vehiculo[i][3];
			RAISE NOTICE 'indice i: % indice j: % modelo : %',i,4, vehiculo[i][4];
			RAISE NOTICE 'indice i: % indice j: % servicio : %',i,5, vehiculo[i][5];
			RAISE NOTICE 'indice i: % indice j: % tipo_vehiculo : %',i,6, vehiculo[i][6];
			RAISE NOTICE 'indice i: % indice j: % veto : %',i,7, vehiculo[i][7];
			RAISE NOTICE 'indice i: % indice j: % veto_causal : %',i,8, vehiculo[i][8];
			--RAISE NOTICE 'indice i: % indice j: % last_update : %',i,9, vehiculo[i][9];
			--RAISE NOTICE 'indice i: % indice j: % user_update : %',i,10, vehiculo[i][10];
			--RAISE NOTICE 'indice i: % indice j: % creation_date : %',i,11, vehiculo[i][11];
			--RAISE NOTICE 'indice i: % indice j: % creation_user : %',i,12, vehiculo[i][12];

	END LOOP;

	/****************************************************************************************/
	/*************************       PROCESAMOS EL ARRAY DEL ANTICIPO	    *************/
	/****************************************************************************************/
	FOR i IN 1 .. (array_upper(anticipo, 1))
	LOOP

		RAISE NOTICE '5.0 INSERTAMOS EL MANIFIESTO DE CARGA';


		/********** BUSCAMOS EL ID AGENCIA y TRANSPORTADORA*************/
		SELECT INTO recordAgenciaTransportadora a.id as idAgencia , t.id as idTransportadora FROM etes.agencias a INNER JOIN etes.transportadoras t ON (a.id_transportadora=t.id)
		WHERE a.cod_agencia=anticipo[i][2] AND t.cod_transportadora= anticipo[i][1]  AND a.reg_status='' AND t.reg_status='' ;

		/********** BUSCAMOS EL ID VEHICULO *************/
		SELECT INTO idVehiculo id FROM etes.vehiculo WHERE upper(placa)=upper(anticipo[i][3]) AND veto='N' AND reg_status='' ;

		/********** BUSCAMOS EL ID CONDUCTOR *************/
		SELECT INTO idConductor c.id FROM etes.conductor c INNER JOIN proveedor p ON (c.cod_proveedor=p.nit)
		WHERE p.nit=anticipo[i][5] AND  p.tipo_doc=anticipo[i][4] AND c.veto='N';

		/********** VALIDAMOS SI TIENE INTERMEDIARIO Y OBTENEMOS SU ID  *************/
		IF(anticipo[i][6] !='' AND anticipo[i][7] !='') THEN
		     SELECT INTO idIntermediario inter.id FROM etes.intermediario inter INNER JOIN proveedor p ON (inter.cod_proveedor=p.nit)
		     WHERE p.nit=anticipo[i][7] AND  p.tipo_doc=anticipo[i][6] AND inter.veto='N';
		ELSE
		     idIntermediario:=1;
		END IF;

		/********** BUSCAMOS EL ID DE LOS PRODUCTOS Y SERVICIOS *************/
		SELECT INTO idProserv id FROM etes.productos_servicios_transp WHERE codigo_proserv=anticipo[i][8];

		raise notice 'idConductor : %',idConductor;

		nro_planilla:=anticipo[i][11];

		INSERT INTO etes.manifiesto_carga(
			    reg_status, dstrct, periodo, id_agencia, id_vehiculo, id_conductor,
			    id_intermediario, id_proserv, planilla, origen, destino, fecha_creacion_anticipo,
			    fecha_envio_fintra, valor_planilla, valor_neto_anticipo, valor_descuentos_fintra,
			    porc_comision_intermediario, valor_comision_intermediario, valor_desembolsar,
			    aprobado, fecha_aprobacion, creation_date, creation_user, last_update,user_update,
			    banco,sucursal,cedula_titular_cuenta,nombre_titular_cuenta,
			    tipo_cuenta,no_cuenta)
		    VALUES ('', 'FINV', REPLACE(SUBSTRING(NOW(),1,7),'-',''),recordAgenciaTransportadora.idAgencia, idVehiculo, idConductor,
			    idIntermediario, idProserv, anticipo[i][11], anticipo[i][9], anticipo[i][10],anticipo[i][17]::timestamp without time zone,
			    anticipo[i][16]::timestamp without time zone, anticipo[i][12]::numeric, anticipo[i][13]::numeric, 0.0,
			    anticipo[i][14]::numeric, anticipo[i][15]::numeric, 0.0,
			    'N','0099-01-01 00:00:00'::timestamp without time zone, NOW(), usuario, '0099-01-01 00:00:00'::timestamp without time zone,'',
			    anticipo[i][18],anticipo[i][19],anticipo[i][20],anticipo[i][21],
			    anticipo[i][22],anticipo[i][23]) RETURNING id INTO id_tabla ;

		/********** CREAMOS LA RELACION VEHICULO TRANSPORTADORA  *************/
		PERFORM * FROM etes.rel_vehiculo_transportadora WHERE id_trasportadora=recordAgenciaTransportadora.idTransportadora AND id_vehiculo=idVehiculo ;
		     IF(NOT FOUND)THEN
			INSERT INTO etes.rel_vehiculo_transportadora(
					    id_trasportadora, id_vehiculo)
			             VALUES (recordAgenciaTransportadora.idTransportadora,idVehiculo);
		      END IF;

	        /********** CALCULAMOS LOS DESCUENTOS DEL ANTICIPO ***************/
		RAISE NOTICE 'id_tabla: %',id_tabla;
		SELECT INTO descuentos etes.sp_descuentosfintra(id_tabla,'A');
		RAISE NOTICE 'descuentos: %',descuentos;

			RAISE NOTICE 'indice i: % indice j: % codigo_empresa : %',i,1, anticipo[i][1];
			RAISE NOTICE 'indice i: % indice j: % codigo_agencia : %',i,2, anticipo[i][2];
			RAISE NOTICE 'indice i: % indice j: % placa : %',i,3, anticipo[i][3];
			RAISE NOTICE 'indice i: % indice j: % tipo_doc_conductor : %',i,4, anticipo[i][4];
			RAISE NOTICE 'indice i: % indice j: % cedula_conductor : %',i,5, anticipo[i][5];
			RAISE NOTICE 'indice i: % indice j: % tipo_doc_intermediario : %',i,6, anticipo[i][6];
			RAISE NOTICE 'indice i: % indice j: % cedula_intermediario : %',i,7, anticipo[i][7];
			RAISE NOTICE 'indice i: % indice j: % codigo_producto : %',i,8, anticipo[i][8];
			RAISE NOTICE 'indice i: % indice j: % origen : %',i,9, anticipo[i][9];
			RAISE NOTICE 'indice i: % indice j: % destino : %',i,10, anticipo[i][10];
			RAISE NOTICE 'indice i: % indice j: % planilla : %',i,11, anticipo[i][11];
			RAISE NOTICE 'indice i: % indice j: % valor_planilla : %',i,12, anticipo[i][12];
			RAISE NOTICE 'indice i: % indice j: % valor_neto_anticipo : %',i,13, anticipo[i][13];
			RAISE NOTICE 'indice i: % indice j: % porc_comision_intermediario : %',i,14, anticipo[i][14];
			RAISE NOTICE 'indice i: % indice j: % valor_comision_intermediario : %',i,15, anticipo[i][15];
			RAISE NOTICE 'indice i: % indice j: % fecha_envio_fintra : %',i,16, anticipo[i][16];
			RAISE NOTICE 'indice i: % indice j: % fecha_creacion_anticipo : %',i,17, anticipo[i][17];
			RAISE NOTICE 'indice i: % indice j: % banco : %',i,18, anticipo[i][18];
			RAISE NOTICE 'indice i: % indice j: % sucursal : %',i,19, anticipo[i][19];
			RAISE NOTICE 'indice i: % indice j: % cedula_titular_cuenta : %',i,20, anticipo[i][20];
			RAISE NOTICE 'indice i: % indice j: % nombre_titular_cuenta : %',i,21, anticipo[i][21];
			RAISE NOTICE 'indice i: % indice j: % tipo_cuenta : %',i,22, anticipo[i][22];
			RAISE NOTICE 'indice i: % indice j: % no_cuenta : %',i,23, anticipo[i][23];

	END LOOP;


		/************ MARCAMOS LA TRAMA COMO PROCESADA ************/
		UPDATE etes.trama_anticipos
		   SET procesado=true,
		       fecha_fin_proceso=now()
		 WHERE id=Idproceso;


 RETURN retorno;
EXCEPTION

	WHEN foreign_key_violation THEN
		RAISE EXCEPTION 'NO EXISTEN DEPENDENCIAS FORANEAS PARA ALGUNOS REGISTROS.';
		retorno:=false ;
		return retorno;
	WHEN unique_violation THEN
		RAISE EXCEPTION 'ERROR INSERTANDO EN LA BD, YA EXISTE UNO DE LOS MANIFIESTO DE CARGA EN LA BASE DE DATOS, PLANILLA : %', nro_planilla;
		retorno:=false ;
		return retorno;
        WHEN  null_value_not_allowed  THEN
		RAISE EXCEPTION 'VALOR NULO NO PERMITIDO';
		retorno:=false ;
		return retorno;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.guardar_trama_json(text[], text[], text[], text[], text[], integer, character varying)
  OWNER TO postgres;
