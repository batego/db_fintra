-- Function: con.interfaz_sl_inventario_tralados_bodega(integer, integer, numeric, character varying)

-- DROP FUNCTION con.interfaz_sl_inventario_tralados_bodega(integer, integer, numeric, character varying);

CREATE OR REPLACE FUNCTION con.interfaz_sl_inventario_tralados_bodega(_bod_1 integer, _bod_2 integer, _costo numeric, _documento character varying)
  RETURNS text AS
$BODY$

DECLARE

 /************************************************
  *DESCRIPCION: 2 - ENTRADA Y SALIDAS DE MATERIALES BODEGAS.
  *AUTOR		:=		@WSIADO	
  *FECHA CREACION	:=		2018-09-15
  *LAST_UPDATE		:=	 	
  *DESCRIPCION DE CAMBIOS Y FECHA
  ************************************************/

 /*************************************************
  *<<<<<<<<<<<<<<<<<DICCIONARIO>>>>>>>>>>>>>>>>>>>>
  
  ************************************************/
BO	 		RECORD;
BD	 		RECORD;
ID_SOLICITUD_		NUMERIC;
INFOITEMS_ 		RECORD;  	
INFOCLIENTE 		RECORD;
LONGITUD 		NUMERIC;
SECUENCIA_GEN 		INTEGER;
SECUENCIA_INT 		INTEGER			:= 1;
FECHADOC_ 		VARCHAR			:= '';
MCTYPE 			CON.TYPE_INSERT_MC;
SW 			TEXT			:='N';
validaciones 		TEXT;
_tipo_modulo 		NUMERIC 		:=0;
_id_accion 		NUMERIC 		:=0;
_aiu	 		numeric 		:=0;
_iva	 		numeric(10,4);
_v_multiplicador	numeric(10,4)		:=1;

BEGIN

	perform * from opav.sl_traslado_movimientos_contables_inventario_apoteosys_2 where codigo_movimiento = _documento;
	if not found then 
		
		select porcentaje1 into _iva  from tipo_de_impuesto where tipo_impuesto = 'IVA' order by creation_date desc limit 1;

		raise notice 'IVA :%', _iva;

			
		----SECUENCIA GENERAL
		SELECT INTO SECUENCIA_GEN  NEXTVAL('CON.INTERFAZ_SECUENCIA_INVENTARIO_APOTEOSYS');

		MCTYPE.MC_____CODIGO____CONTAB_B := 'SELE';	--CODIGO CONTABLE EMPRESA.
		MCTYPE.MC_____CODIGO____TD_____B := 'INVE'; 	--TIPO DOCUMENTO PARA APOTEOSYS.
		MCTYPE.MC_____CODIGO____CD_____B := 'TL'; 	--CONCEPTO.	
		
		
		
		MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN; 	--SECUENCIA GENERAL.
	   

		IF (_bod_1 = 1) then

			select 
				 a.id_solicitud,  nuevo_modulo, centro_costos_ingreso,centro_costos_gastos, 1 as id_cuenta ,b.CENTRO_COSTOS_GASTOS, b.num_os  INTO BO 
			from 		opav.sl_bodega 	as A
			left join 	opav.ofertas  	as B on (A.id_solicitud = B.id_solicitud)
			where 	id  = _bod_2;
		else
			select 
				 a.id_solicitud,  nuevo_modulo, centro_costos_ingreso,centro_costos_gastos,
					(CASE 
						WHEN tipo_bodega =2 	THEN 3
						WHEN tipo_bodega =4	THEN 4
					END) as id_cuenta,
					b.CENTRO_COSTOS_GASTOS, b.num_os

				  INTO BO 
			from 		opav.sl_bodega 	as A
			left join 	opav.ofertas  	as B on (A.id_solicitud = B.id_solicitud)
			where 	id  = _bod_1;
		
		end if;
		
		

		select 
			a.id_solicitud,  nuevo_modulo, centro_costos_ingreso,centro_costos_gastos,
					(CASE 
						WHEN tipo_bodega =2 	THEN 3
						WHEN tipo_bodega =4	THEN 4
					END) as id_cuenta  ,
					b.CENTRO_COSTOS_GASTOS, b.num_os
					 INTO BD
		from 		opav.sl_bodega 	as A
		left join 	opav.ofertas  	as B on (A.id_solicitud = B.id_solicitud)
		where 	id  = _bod_2;



		/*

		if (BD.id_solicitud) then
			ID_SOLICITUD_ = BD.id_solicitud;		
		else
			ID_SOLICITUD_ = BO.id_solicitud;
		end if;
			
		--Se verifica si pertenece al nuevo aplicativo.
		select 
			nuevo_modulo into _tipo_modulo 
		from 
			opav.ofertas where id_solicitud =  ID_SOLICITUD_;
			

		--Dependiendo si pertenece al nuevo aplicativo se procede a obtener el valor del AIU.
		IF(_tipo_modulo = 1) THEN
			--se obtiene el id_accion que pertenece la solicitud.
			select id_accion into _id_accion from opav.acciones where accion_principal = 1 and id_solicitud = ID_SOLICITUD_;
			
			--se obtiene si lleva iva o aiu pasando por parametro el id_accion obtenido anteriormente.
			SELECT sum(perc_administracion + perc_imprevisto + perc_utilidad) into _aiu  FROM opav.sl_cotizacion where id_accion = _id_accion;
			
		ELSE

			select sum(porc_imprevisto + porc_imprevisto + porc_utilidad) into _aiu from opav.acciones where id_solicitud =ID_SOLICITUD_;

		END IF;
		
		--En caso de llevar AIU el proyecto entonces el valor de los materiales en la cuenta va con el incremento del iva.(por esta razon la variable _v_multiplicador)
		IF (_AIU > 0) THEN 

			_v_multiplicador= (_iva/100) +1 ;
		
		ELSE
		
			_v_multiplicador= 1 ;
			
		END IF;
		*/




		/**BUSCAMOS LA INFORMACION COMPLETA QUE CONFORMARA EL ASIENTO CONTABLE PARA MANDARLO A APOTEOSYS*/
		FOR INFOITEMS_ IN 		


			
			SELECT 
				CUENTA,
				(_costo * _v_multiplicador)  AS VALOR_CREDT,
				0 AS VALOR_DEB,
				'', DESCRIPCION,
				_bod_1 AS id_bod,
				BO.CENTRO_COSTOS_GASTOS as CENTRO_COSTOS_GASTOS,
				BO.num_os as num_os
			FROM 	OPAV.SL_CUENTAS_INVENTARIO
			WHERE 	ID = bo.id_cuenta
			
			UNION ALL
			SELECT 
				CUENTA,
				
				0 AS VALOR_CREDT,
				(_costo * _v_multiplicador)  AS VALOR_DEB,
				'', DESCRIPCION,
				_bod_1 as id_bod,
				BD.CENTRO_COSTOS_GASTOs as CENTRO_COSTOS_GASTOS,
				BD.num_os as num_os
			FROM 	OPAV.SL_CUENTAS_INVENTARIO
			WHERE 	ID = bd.id_cuenta
			
						
		LOOP
			select INTO INFOCLIENTE
				c.nit as nit,
				'CC' 	as TERCER_CODIGO____TIT____B,
				'RCOM'  as TERCER_CODIGO____TT_____B,
				'08001' as TERCER_CODIGO____CIUDAD_B,
				(C.NOMBRE) AS TERCER_NOMBCORT__B,
				(C.NOMBRE) AS TERCER_APELLIDOS_B,
				(C.NOMBRE) as TERCER_NOMBEXTE__B,
				C.direccion as TERCER_DIRECCION_B,
				'0' as TERCER_TELEFONO1_B
			from 		opav.sl_bodega as a
			inner join 	opav.sl_bodega_usuario  as b on (a.id = b.id_bodega)
			inner join	usuario_view_dblink as c on (b.id_usuario = c.idusuario)
			where b.id_bodega = INFOITEMS_.id_bod order by b.creation_date desc limit 1;
			
			
			iF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('INV_SEL','INV', INFOITEMS_.cuenta,'', 6)='S')THEN
				MCTYPE.MC_____FECHVENC__B = now()::date; --fecha vencimiento
				MCTYPE.MC_____FECHEMIS__B = now()::date; --fecha creacion
			ELSE
				MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
				MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';
			END IF;

			
			FECHADOC_ := NOW();
			MCTYPE.MC_____FECHA_____B := NOW();
			MCTYPE.MC_____SECUINTE__DCD____B := SECUENCIA_INT;--secuencia interna
			MCTYPE.MC_____SECUINTE__B := SECUENCIA_INT;--secuencia interna
			MCTYPE.MC_____REFERENCI_B := INFOITEMS_.num_os; ---cambiar a multiservicio...
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING(  REPLACE(SUBSTRING( NOW(),1,7),'-',''),1,4)::INT; 
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING(  REPLACE(SUBSTRING( NOW(),1,7),'-',''),5,2)::INT;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF'; 
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('INV_SEL', 'INV', INFOITEMS_.cuenta,'', 1); 
			MCTYPE.MC_____CODIGO____CU_____B := INFOITEMS_.CENTRO_COSTOS_GASTOS;
			MCTYPE.MC_____IDENTIFIC_TERCER_B := substring(REPLACE(INFOCLIENTE.nit,'-',''),1,9);
			MCTYPE.MC_____DEBMONORI_B := 0; 
			MCTYPE.MC_____CREMONORI_B := 0;
			MCTYPE.MC_____DEBMONLOC_B := INFOITEMS_.valor_deb::NUMERIC;
			MCTYPE.MC_____CREMONLOC_B := INFOITEMS_.valor_credt::NUMERIC;
			MCTYPE.MC_____INDTIPMOV_B := 4;
			MCTYPE.MC_____INDMOVREV_B := 'N';
			MCTYPE.MC_____OBSERVACI_B := SUBSTRING(INFOITEMS_.descripcion,1,249);
			MCTYPE.MC_____FECHORCRE_B := NOW();
			MCTYPE.MC_____AUTOCREA__B := 'ADMIN';
			MCTYPE.MC_____FEHOULMO__B := NOW();
			MCTYPE.MC_____AUTULTMOD_B := '';
			MCTYPE.MC_____VALIMPCON_B := 0;
			MCTYPE.MC_____NUMERO_OPER_B := '';
			MCTYPE.TERCER_CODIGO____TIT____B := INFOCLIENTE.TERCER_CODIGO____TIT____B;
			MCTYPE.TERCER_NOMBCORT__B := SUBSTRING(INFOCLIENTE.TERCER_NOMBCORT__B,1,32);
			MCTYPE.TERCER_NOMBEXTE__B := SUBSTRING(INFOCLIENTE.TERCER_NOMBEXTE__B,1,64);
			MCTYPE.TERCER_APELLIDOS_B := INFOCLIENTE.TERCER_APELLIDOS_B;
			MCTYPE.TERCER_CODIGO____TT_____B := INFOCLIENTE.TERCER_CODIGO____TT_____B;
			MCTYPE.TERCER_DIRECCION_B := CASE WHEN CHAR_LENGTH(INFOCLIENTE.TERCER_DIRECCION_B)>64 THEN SUBSTR(INFOCLIENTE.TERCER_DIRECCION_B,1,64) ELSE INFOCLIENTE.TERCER_DIRECCION_B END;
			MCTYPE.TERCER_CODIGO____CIUDAD_B := INFOCLIENTE.TERCER_CODIGO____CIUDAD_B;
			MCTYPE.TERCER_TELEFONO1_B := 0;
			MCTYPE.TERCER_TIPOGIRO__B := 1;
			MCTYPE.TERCER_CODIGO____EF_____B := '';
			MCTYPE.TERCER_SUCURSAL__B := '';
			MCTYPE.TERCER_NUMECUEN__B := '';
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('INV_SEL','INV', INFOITEMS_.cuenta,'', 3);
			MCTYPE.MC_____BASE______B:=0;

			IF(MCTYPE.MC_____FECHEMIS__B > MCTYPE.MC_____FECHA_____B) THEN
				MCTYPE.MC_____FECHEMIS__B :=  MCTYPE.MC_____FECHA_____B;
			END IF;

			IF(INFOITEMS_.VALOR_CREDT= 0)THEN
				IF(INFOITEMS_.VALOR_CREDT)THEN
					CONTINUE; 
				END IF;
			END IF;

			

			MCTYPE.MC_____BASE______B:= 0;
				
			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('INV_SEL','INV', INFOITEMS_.cuenta,'', 4)='S')THEN
				MCTYPE.MC_____NUMDOCSOP_B := _documento;
			ELSE
				MCTYPE.MC_____NUMDOCSOP_B := '';
			END IF;

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('INV_SEL', 'INV', INFOITEMS_.cuenta,'', 5)::INT=1)THEN
				MCTYPE.MC_____NUMEVENC__B := 1;--numero de cuotas
			ELSE
				MCTYPE.MC_____NUMEVENC__B := NULL;
			END IF;

			

			
			raise notice 'INV ====>>>> ';	
			SW:=con.sp_insert_table_mc_sl_inventario_sel(MCTYPE);
			SECUENCIA_INT :=SECUENCIA_INT+1;
		
		END LOOP;

		raise notice '<<<<==== Termino ====>>>> %',_DOCUMENTO;


		--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
		 IF CON.SP_VALIDACIONES_SEL(MCTYPE,'INV_BOD_PRINC') ='N' THEN 
			SW = 'N';
		END IF;	
		 
			
		if(SW = 'S')then
			--select * from opav.sl_traslado_movimientos_contables_inventario_apoteosys_2
			insert into opav.sl_traslado_movimientos_contables_inventario_apoteosys_2  (codigo_movimiento, creation_user, creation_date)
			values (_documento , 'WSIADO', now() );
		end if;

		SECUENCIA_INT:=1;
			

		delete from con.mc_sl_inventario_sel  where  MC_____DEBMONLOC_B= 0 and  MC_____CREMONLOC_B= 0;
		RETURN 'OK';
	else
		return 'ERROR'	;
	end if;
		
	

	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_sl_inventario_tralados_bodega(integer, integer, numeric, character varying)
  OWNER TO postgres;
