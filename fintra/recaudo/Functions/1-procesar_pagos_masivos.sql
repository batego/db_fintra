-- Function: recaudo.procesar_pagos_masivos()

-- DROP FUNCTION recaudo.procesar_pagos_masivos();

CREATE OR REPLACE FUNCTION recaudo.procesar_pagos_masivos()
  RETURNS text AS
$BODY$DECLARE

--************************************************************************************
-- Funcion .......... recaudo.procesar_pagos_masivos						*
-- Objetivo ......... Toma los registros no procesados de la tabla de 				*
--			recaudo.pagos_masivos_lineas y genera automaticamente los pagos 		*
--			cualquier linea									*
-- Fecha ............ Julio 05 de 2018                                           			*
-- Autor ............ Jean Paul Zapata	                                           		*
--************************************************************************************

mensaje text :='';
lineas_pagos record;
val_saldo_neg moneda;

BEGIN
	--1.CONSULTO LOS PAGOS A REALIZAR
	for lineas_pagos in
		select
			id,
			negocio,
			identificacion,
			unidad_negocio,
			banco,
			sucursal,
			valor_aplicar_neto,
			mora,
			gac,
			tipo_pago,
			cta_mora,
			cta_gac,
			id_rop
		from
			recaudo.pagos_masivos_lineas
		WHERE
			coalesce(reg_procesado,'N')='N'
	loop

		--2 REVISO EL SALDO DE LA FACTURA SEGUN EL NEGOCIO

		Select
			into val_saldo_neg sum(valor_saldo)
		from
			tem.factura_temp_simu_pago
		where
			negasoc=lineas_pagos.negocio;

		--2.1VERIFICO QUE EL SALDO DEL NEGOCIO SEA MAYOR O IGUAL QUE EL PAGO

		IF(val_saldo_neg>=lineas_pagos.valor_aplicar_neto)THEN
			mensaje:='TRUE';
			--TRUE -> SIGO CON EL PROCESO
			IF(lineas_pagos.tipo_pago='P')THEN
			--3.1 PARCIAL
			--3.1.1 GENERO EL INGRESO
			--3.1.2 ABONO A LAS FACTURAS
			ELSIF(lineas_pagos.tipo_pago='T')THEN
			--3.2 TOTAL
			--3.2.1 GENERO EL INGRESO
			--3.2.2 ABONO A LA CARTERA
			--3.2.3 GENERO LA IA DE REVERSION DE INTERES, SEGUROS, ETC
			END IF;
			--4 MARCO LA TABLA RECAUDO.PAGOS_MASIVOS_LINEAS PARA SABER CUALES FUERON PROCESADOS
		ELSE
			mensaje:='FALSE';
			--FALSE -> ACTUALIZO EL REGISTRO CON UN MENSAJE
		END IF;

	end loop;

 --5 DEVUELVO MENSAJE DE ERROR O DE OK
  RETURN ( mensaje );

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION recaudo.procesar_pagos_masivos()
  OWNER TO postgres;
COMMENT ON FUNCTION recaudo.procesar_pagos_masivos() IS 'Procesa Los Pagos Masivos';
