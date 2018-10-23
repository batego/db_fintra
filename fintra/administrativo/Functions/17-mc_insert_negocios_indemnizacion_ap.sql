-- Function: administrativo.mc_insert_negocios_indemnizacion_ap(character varying[], character varying, character varying, character varying, character varying, boolean, boolean, character varying, character varying, boolean)

-- DROP FUNCTION administrativo.mc_insert_negocios_indemnizacion_ap(character varying[], character varying, character varying, character varying, character varying, boolean, boolean, character varying, character varying, boolean);

CREATE OR REPLACE FUNCTION administrativo.mc_insert_negocios_indemnizacion_ap(negocios_ character varying[], periodo_ character varying, linea_negocio_ character varying, empresa_fianza_ character varying, mora_ character varying, acelerar_pagare_ boolean, gac_ boolean, usuario_ character varying, filtro character varying, ixm_ boolean)
  RETURNS text AS
$BODY$

DECLARE

		negocio_detalle   RECORD;
		negocio_detalle2  RECORD;
		infocliente       RECORD;
		pagare_acelerado_ VARCHAR;

BEGIN
		IF (acelerar_pagare_ = TRUE)
		THEN
				pagare_acelerado_ := 'S';
		ELSE
				pagare_acelerado_ := 'N';
		END IF;

		FOR negocio_detalle IN
		SELECT
				nombre_linea_negocio,
				codcli,
				nit_cliente,
				nombre_cliente,
				periodo_foto,
				negocio,
				num_pagare,
				documento,
				cuota,
				fecha_vencimiento,
				dias_mora,
				valor_factura,
				valor_saldo_capital,
				valor_saldo_seguro,
				valor_desistir,
				fecha_indemnizacion,
				valor_saldo_mi,
				valor_saldo_ca,
				valor_saldo_cm,
				ixm,
				gac,
				total_saldo,
				altura_mora,
				estado,
				convenio
		FROM sp_facturas_indemnizar_fianza_micro(periodo_ :: VARCHAR, linea_negocio_ :: INT, empresa_fianza_ :: VARCHAR,
		                                         mora_ :: INT, '' :: VARCHAR, acelerar_pagare_ :: BOOLEAN, gac_ :: BOOLEAN,
		                                         ixm_ :: BOOLEAN) AS
		     (nombre_linea_negocio CHARACTER VARYING,
		     codcli CHARACTER VARYING,
		     nit_cliente CHARACTER VARYING,
		     nombre_cliente CHARACTER VARYING,
		     periodo_foto CHARACTER VARYING,
		     negocio CHARACTER VARYING,
		     num_pagare CHARACTER VARYING,
		     documento CHARACTER VARYING,
		     cuota CHARACTER VARYING,
		     fecha_vencimiento DATE,
		     dias_mora INT,
		     valor_factura NUMERIC,
		     valor_saldo_capital NUMERIC,
		     valor_desistir NUMERIC,
		     fecha_indemnizacion DATE,
		     valor_saldo_mi NUMERIC,
		     valor_saldo_ca NUMERIC,
		     ixm NUMERIC,
		     gac NUMERIC,
		     total_saldo NUMERIC,
		     convenio INT,
		     cuenta CHARACTER VARYING,
		     ref_4 CHARACTER VARYING,
		     cartera_en CHARACTER VARYING,
		     estado CHARACTER VARYING,
		     valor_saldo_cm NUMERIC,
		     valor_saldo_seguro NUMERIC,
		     valor_abono NUMERIC,
		     altura_mora CHARACTER VARYING,
		     esquema_old CHARACTER VARYING
		     )
		WHERE negocio = ANY (negocios_ :: VARCHAR [])
		ORDER BY negocio
		LOOP
				RAISE NOTICE 'acelerar_pagare_%', acelerar_pagare_;
				RAISE NOTICE 'Negocio: %, Documento: %, Cuota: %', negocio_detalle.negocio, negocio_detalle.documento, negocio_detalle.cuota;

				INSERT INTO administrativo.control_indemnizacion_fianza (
						periodo_foto, nit_empresa_fianza, codcli, nit_cliente, nombre_cliente, negocio, num_pagare,
						documento, cuota, fecha_vencimiento, fecha_indemnizacion, altura_mora, dias_vencidos, valor_factura,
						valor_saldo_capital, valor_saldo_mi, valor_saldo_ca, ixm, gac, valor_indemnizado,
						id_convenio, linea_negocio, creation_date, creation_user, valor_saldo_seguro, pagare_acelerado, estado_factura, valor_saldo_cm)
				VALUES (negocio_detalle.periodo_foto, empresa_fianza_, negocio_detalle.codcli, negocio_detalle.nit_cliente,
				                                      negocio_detalle.nombre_cliente, negocio_detalle.negocio,
				                                      negocio_detalle.num_pagare,
				                                      negocio_detalle.documento, negocio_detalle.cuota,
				                                      negocio_detalle.fecha_vencimiento, now(), negocio_detalle.altura_mora,
						negocio_detalle.dias_mora, negocio_detalle.valor_factura,
						negocio_detalle.valor_saldo_capital, negocio_detalle.valor_saldo_mi, negocio_detalle.valor_saldo_ca,
						negocio_detalle.ixm, negocio_detalle.gac, negocio_detalle.total_saldo,
						negocio_detalle.convenio, linea_negocio_, now(), usuario_, negocio_detalle.valor_saldo_seguro,
						    pagare_acelerado_, negocio_detalle.estado, negocio_detalle.valor_saldo_cm);
		END LOOP;


		RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION administrativo.mc_insert_negocios_indemnizacion_ap(character varying[], character varying, character varying, character varying, character varying, boolean, boolean, character varying, character varying, boolean)
  OWNER TO postgres;
