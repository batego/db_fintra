-- Function: opav.sl_apoteosys_migracion_oc_selectrik_iva_transporte(character varying)

-- DROP FUNCTION opav.sl_apoteosys_migracion_oc_selectrik_iva_transporte(character varying);

CREATE OR REPLACE FUNCTION opav.sl_apoteosys_migracion_oc_selectrik_iva_transporte(oc_ character varying)
  RETURNS character varying AS
$BODY$
DECLARE

 _resultado 		character varying 	:='OK';
 _ocs 			record;
 _proveedor		record;
 _val_parametrizados	record;
 _contador 		numeric 		:=0;
 _rec_sum 		record;
 _existe 		character varying 	:='';
 _sub_total 		numeric 		:=0;



BEGIN

	/*====SE VERIFICA SI LA OC YA EXISTE EN LA TABLA DE SL_APOTEOSYS_TABLA_MAESTRA=====*/
	select INTO _existe coalesce((select 'SI'::VARCHAR from opav.sl_apoteosys_tabla_maestra where ord_orden_interna = oc_ limit 1),'NO');

	IF(_existe = 'NO' )THEN

		FOR _ocs IN

			SELECT
                                OC.cod_ocs,  OC.fecha_actual , OC.cod_proveedor ,  COALESCE(TIP.ID, 1) as id_insumo , COALESCE(TIP.NOMBRE_INSUMO,'MATERIAL')::character varying AS nombre_insumo , round(SUM(costo_total_compra),2) as ORD_SUBTOTAL ,COALESCE(OFE.centro_costos_gastos,'') as CCA , OFE.id_solicitud
                        FROM 		opav.sl_orden_compra_servicio 		AS OC
                        INNER JOIN 	opav.sl_ocs_detalle			AS OCD 		ON (OC.id		=	OCD.id_ocs)
                        INNER JOIN	opav.sl_solicitud_ocs			AS SOCS		ON (OCD.cod_solicitud 	=	SOCS.cod_solicitud)
                        left JOIN	opav.ofertas    			AS OFE		ON (SOCS.id_solicitud  	=	OFE.id_solicitud)
                        LEFT JOIN	OPAV.SL_INSUMO				AS INS 		ON (OCD.CODIGO_INSUMO = INS.CODIGO_MATERIAL)
                        LEFT JOIN 	OPAV.SL_SUBCATEGORIA			AS SUB 		ON (INS.ID_SUBCATEGORIA = SUB.ID)
                        LEFT JOIN 	OPAV.SL_REL_CAT_SUB 			AS RSC 		ON (SUB.ID = RSC.ID_SUBCATEGORIA)
                        LEFT JOIN	OPAV.SL_CATEGORIA 			AS CAT 		ON (RSC.ID_CATEGORIA = CAT.ID)
                        LEFT JOIN 	OPAV.SL_TIPO_INSUMO 			AS TIP 		ON (CAT.ID_TIPO_INSUMO = TIP.ID)
                        where OC.COD_OCS = oc_ and OC.COD_OCS ilike 'OC%'
                        group by OC.cod_ocs,  OC.fecha_actual , OC.cod_proveedor ,  TIP.ID ,TIP.NOMBRE_INSUMO , OFE.centro_costos_gastos , OFE.id_solicitud
                        order by OC.cod_ocs, OC.cod_proveedor


		LOOP


				select
						(CASE
						WHEN tipo_doc ='CED' THEN 'CC'
						WHEN tipo_doc ='RIF' THEN 'CE'
						WHEN tipo_doc ='NIT' THEN 'NIT' ELSE
						'CC' END) 								as tercer_codigo____tit____b,

						(D.NOMBRE1||' '||D.NOMBRE2) 						AS tercer_nombcort__b,
						 D.NOMBRE 								AS tercer_nombexte__b,
						(D.APELLIDO1||' '||D.APELLIDO2) 					AS tercer_apellidos_b,

						(CASE
						WHEN GRAN_CONTRIBUYENTE ='N' AND AGENTE_RETENEDOR ='N' THEN 'RCOM'
						WHEN GRAN_CONTRIBUYENTE ='N' AND AGENTE_RETENEDOR ='S' THEN 'RCAU'
						WHEN GRAN_CONTRIBUYENTE ='S' AND AGENTE_RETENEDOR ='N' THEN 'GCON'
						WHEN GRAN_CONTRIBUYENTE ='S' AND AGENTE_RETENEDOR ='S' THEN 'GCAU'
						ELSE 'PNAL' END) 							as tercer_codigo____tt_____b,
						D.direccion								AS tercer_direccion_b,
						'08001'::character varying						AS tercer_codigo____ciudad_b ,
						D.telefono								AS tercer_telefono1_b,

						1 									AS tercer_tipogiro__b,
						0									AS tercer_sucursal__b into _proveedor
						from proveedor prov
						LEFT JOIN NIT D ON(D.CEDULA=prov.NIT)
						LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
						where nit = _ocs.cod_proveedor;




			RAISE NOTICE '_ocs :% ',_ocs ;
			RAISE NOTICE '_proveedor :% ',_proveedor ;

			IF(_contador > 0) THEN
				_contador := _contador+1;
			ELSE
				_contador:=1;
			END IF;
			raise notice 'id_solicitud %', _ocs.id_solicitud::integer;
			raise notice 'id_insumo %', _ocs.id_insumo;
			_rec_sum :=(select opav.sl_homologacion_insumos_apo_iva_transporte(_ocs.id_solicitud::integer , _ocs.id_insumo));
			raise notice '_rec_sum %', _rec_sum;
			_sub_total = _sub_total + _ocs.ord_subtotal;
			RAISE NOTICE 'CODIGO INSMO : %', _rec_sum.INSUMO_APOTEOSYS;
			RAISE NOTICE 'PORC_IVA : %', _rec_sum.PORC_IVA;

			_rec_sum.PORC_IVA = (_rec_sum.PORC_IVA /100)::numeric(10,3);

			RAISE NOTICE 'PORC_IVA : %', _rec_sum.PORC_IVA;

			INSERT INTO OPAV.sl_apoteosys_tabla_maestra (
					--OC Cabecera
					ORD_ORDEN_INTERNA, ORD_FECHA, ORD_PRO_PROVEEDOR,
					ORD_SUBTOTAL, ORD_PCT_DESCUENTO_GLOBAL, ORD_DESCUENTO, ORD_OTRO_IMPUESTO, ORD_IVA,
					ORD_TOTAL, ORD_FECHA_AUTORIZACION,
					ORD_DEP_DEPARTAMENTO,
					ORD_ANT_INCLUYEIVA,  ORD_INDEJEPRE, ORD_INDCARINI,  ORD_VALOTASA, ORD_REPARABLE,
					ORD_PERCAMEST, ID_SL_APOTEOSYS_FASE_OC,

					--OC Detalle
					DOR_LINEA, DOR_SUM_SUMINISTRO,
					DOR_DESCRIPCION, DOR_DESCRIPCION_ALTERNA, DOR_CANTIDAD_PEDIDA,
					DOR_CANTIDAD_BACKORDER, DOR_COSTO_FOB,DOR_IMPUESTO_VENTA_MONTO,
					DOR_TOTAL_LINEA, DOR_MED_MEDIDA_CANTIDAD_MEDIDA,
					DOR_DEP_DEPARTAMENTO,

					--Despacho Cabecera
					DPC_DEP_DEPARTAMENTO,

					--Despacho Detalle
					DDF_LINEA, DDF_DOR_LINEA,
					DDF_CANTIDAD,  DDF_CANTIDAD_BACKORDER,
					DDF_DEP_DEPARTAMENTO,

					--Proveedor
					TERCER_CODIGO____TIT____B,
					TERCER_NOMBCORT__B,
					TERCER_NOMBEXTE__B,
					TERCER_APELLIDOS_B,
					TERCER_CODIGO____TT_____B,
					TERCER_DIRECCION_B,
					TERCER_CODIGO____CIUDAD_B,
					TERCER_TELEFONO1_B,
					TERCER_TIPOGIRO__B,
					TERCER_SUCURSAL__B	)

			VALUES (
					--OC Cabecera
					_ocs.cod_ocs, _ocs.fecha_actual, _ocs.cod_proveedor,
					0,'0', '0', '0', '0', --_ocs.ord_subtotal
					0, _ocs.fecha_actual,--_ocs.ord_subtotal
					_ocs.cca,
					'N', 'S', 'N', '0', 'N',
					'N' , 1,

					--OC Detalle
					_contador, _rec_sum.insumo_apoteosys,
					_ocs.nombre_insumo, _ocs.nombre_insumo, '1',
					'1', _ocs.ord_subtotal,(_ocs.ord_subtotal*_rec_sum.PORC_IVA),
					(_ocs.ord_subtotal*(_rec_sum.PORC_IVA+1)), 'UND',
					_ocs.cca,

					--Despacho Cabecera
					_ocs.cca,

					--Despacho Detalle
					_contador, _contador,
					'1',  '1',
					_ocs.cca,

					--proveedor
					_proveedor.TERCER_CODIGO____TIT____B,
					_proveedor.TERCER_NOMBCORT__B,
					SUBSTR(_proveedor.TERCER_NOMBEXTE__B,1,64),
					_proveedor.TERCER_APELLIDOS_B,
					_proveedor.TERCER_CODIGO____TT_____B,
					_proveedor.TERCER_DIRECCION_B,
					_proveedor.TERCER_CODIGO____CIUDAD_B,
					_proveedor.TERCER_TELEFONO1_B,
					_proveedor.TERCER_TIPOGIRO__B,
					_proveedor.TERCER_SUCURSAL__B
					);






		END LOOP;


		RAISE NOTICE '_sub_total : %',_sub_total;

 		update opav.sl_apoteosys_tabla_maestra set
			--valores por defecto OC cabecera 'COM_ORDEN_TB_NX'
			ORD_AUTORIZADO 			= (select opav.sl_get_campo_apoteosys(1 , 'ORD_AUTORIZADO')),
			ORD_CAT_CATEGORIA 		= (select opav.sl_get_campo_apoteosys(1 , 'ORD_CAT_CATEGORIA')),
			ORD_CPA_CONDICION		= (select opav.sl_get_campo_apoteosys(1 , 'ORD_CPA_CONDICION')),
			ORD_CPA_CONDICION2 		= (select opav.sl_get_campo_apoteosys(1 , 'ORD_CPA_CONDICION2')),
			ORD_DOC_DOCUMENTO 		= (select opav.sl_get_campo_apoteosys(1 , 'ORD_DOC_DOCUMENTO')),
			ORD_PRO_MON_MONEDA		= (select opav.sl_get_campo_apoteosys(1 , 'ORD_PRO_MON_MONEDA')),
			ORD_STATUS 			= (select opav.sl_get_campo_apoteosys(1 , 'ORD_STATUS')),
			ORD_TIPO 			= (select opav.sl_get_campo_apoteosys(1 , 'ORD_TIPO')),
			ORD_TIPO_ORDEN 			= (select opav.sl_get_campo_apoteosys(1 , 'ORD_TIPO_ORDEN')),
			ORD_CMP_COMPRADOR 		= (select opav.sl_get_campo_apoteosys(1 , 'ORD_CMP_COMPRADOR')),
			ORD_CREADO_POR 			= (select opav.sl_get_campo_apoteosys(1 , 'ORD_CREADO_POR')),
			ORD_EMP_EMPRESA 		= (select opav.sl_get_campo_apoteosys(1 , 'ORD_EMP_EMPRESA')),

			--valores por defecto OC Detalle 'COM_DETALLE_ORDEN_TB_NX'
			DOR_DEP_EMP_EMPRESA		= (select opav.sl_get_campo_apoteosys(2 , 'DOR_DEP_EMP_EMPRESA')),
			DOR_ORD_EMP_EMPRESA		= (select opav.sl_get_campo_apoteosys(2 , 'DOR_ORD_EMP_EMPRESA')),
			DOR_CANTIDAD_RECIBIDA 		= (select opav.sl_get_campo_apoteosys(2 , 'DOR_CANTIDAD_RECIBIDA'))::numeric,
			DOR_STATUS 			= (select opav.sl_get_campo_apoteosys(2 , 'DOR_STATUS')),
			DOR_SUM_EMP_EMPRESA 		= (select opav.sl_get_campo_apoteosys(2 , 'DOR_SUM_EMP_EMPRESA')),


			--valores por defecto 'COM_DESPACHO_TB_NX'
			DPC_EMP_EMPRESA_DESPACHO 	= (select opav.sl_get_campo_apoteosys(3 , 'DPC_EMP_EMPRESA_DESPACHO')),
			DPC_LCG_LOCALIZACION 		= (select opav.sl_get_campo_apoteosys(3 , 'DPC_LCG_LOCALIZACION')),
			DPC_ORD_EMP_EMPRESA 		= (select opav.sl_get_campo_apoteosys(3 , 'DPC_ORD_EMP_EMPRESA')),
			DPC_CREADO_POR 			= (select opav.sl_get_campo_apoteosys(3 , 'DPC_CREADO_POR')),

			--valores por defecto 'COM_DET_DESPACHO_TB_NX'
			DDF_CANCELADO 			= (select opav.sl_get_campo_apoteosys(4 , 'DDF_CANCELADO')),
			DDF_DEP_EMP_EMPRESA 		= (select opav.sl_get_campo_apoteosys(4 , 'DDF_DEP_EMP_EMPRESA')),
			DDF_CREADO_POR 			= (select opav.sl_get_campo_apoteosys(4 , 'DDF_CREADO_POR')),
			DDF_DOR_ORD_EMP_EMPRESA 	= (select opav.sl_get_campo_apoteosys(4 , 'DDF_DOR_ORD_EMP_EMPRESA'))


		WHERE ID_SL_APOTEOSYS_FASE_OC = 1 and ord_orden_interna = oc_;


		update opav.sl_apoteosys_tabla_maestra as a set
			ord_subtotal = b.costo,
			ORD_IVA = b.iva ,
			ord_total = b.total

		from (select  ord_orden_interna  , sum(dor_costo_fob) as costo , sum(dor_impuesto_venta_monto) as iva , sum(dor_total_linea) as total from opav.sl_apoteosys_tabla_maestra where ord_orden_interna = oc_  and ord_emp_empresa = 'SELE' group by ord_orden_interna  ) as b
		where a.ord_orden_interna = b.ord_orden_interna and a.ord_emp_empresa = 'SELE';

		update opav.sl_orden_compra_servicio set estado_apoteosys = 'S' where cod_ocs= oc_ ;
	ELSE
		RAISE NOTICE 'ERROR : La _ocs ya Existe en la tabla de traslado. :% ',oc_ ;
		_resultado:= 'ERROR';
	END IF;

 RETURN _resultado;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sl_apoteosys_migracion_oc_selectrik_iva_transporte(character varying)
  OWNER TO postgres;
