-- Function: tem.seguimientocartera_asignacion(numeric, character varying, character varying)

-- DROP FUNCTION tem.seguimientocartera_asignacion(numeric, character varying, character varying);

CREATE OR REPLACE FUNCTION tem.seguimientocartera_asignacion(periodoasignacion numeric, unidadnegocio character varying, agenteext character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE

		carteratotales        RECORD;
		carterageneral        RECORD;
		carterawtramoanterior RECORD;
		clienterec            RECORD;
		bankpay               RECORD;
		fchlastpay            RECORD;

		negocioavales         RECORD;
		negocioseguros        RECORD;
		negociogps            RECORD;

		negociosegurosgps     RECORD;
		negociovencimientoseguro RECORD;
		negociovencimientogps    RECORD;

		sumadeaval               RECORD;
		rs_resultpay             RECORD;

		percvalorasignado        NUMERIC;
		perccantasignado         NUMERIC;
		_tramoanterior           NUMERIC;
		periodotramo             NUMERIC;
		periodotramoanterior     NUMERIC;
		_sumdebidocobrar         NUMERIC;
		ingresoxcuota_fiducia NUMERIC;
		ingresoxcuota_fenalco NUMERIC;
		ingresoxcuota         NUMERIC;

		cadagentes            VARCHAR;
		periodo_corte         VARCHAR;
		fechacorteperiodo     VARCHAR;
		fechacorteperiodoant  VARCHAR;
		statusvcto            VARCHAR;
		ultimopago            VARCHAR;
		negocioarray          RECORD;
		firsttime    VARCHAR;
		dpto_neg VARCHAR;


		returntabla  VARCHAR := '';

		mihoy        DATE;

BEGIN

		IF (substring(periodoasignacion, 5) = '01')
		THEN
				periodotramo = substring(periodoasignacion, 1, 4) :: NUMERIC - 1 || '12';
				_tramoanterior = substring(periodoasignacion, 1, 4) :: NUMERIC - 1 || '12';
		ELSE
				periodotramo = periodoasignacion :: NUMERIC - 1;
				_tramoanterior = periodoasignacion :: NUMERIC - 1;
		END IF;

		periodotramoanterior = periodotramo :: NUMERIC - 1;

		SELECT INTO fechacorteperiodo to_char(to_timestamp(substring(periodotramo, 1, 4) :: NUMERIC || '-' ||
		                                                   to_char(substring(periodotramo, 5, 2) :: NUMERIC, 'FM00') ||
		                                                   '-01', 'YYYY-MM-DD') + INTERVAL '1 month' - INTERVAL '1 days',
		                                      'YYYY-MM-DD');
		SELECT INTO fechacorteperiodoant to_char(to_timestamp(substring(periodotramoanterior, 1, 4) :: NUMERIC || '-' ||
		                                                      to_char(substring(periodotramoanterior, 5, 2) :: NUMERIC,
		                                                              'FM00') || '-01', 'YYYY-MM-DD') + INTERVAL '1 month' -
		                                         INTERVAL '1 days', 'YYYY-MM-DD');

		RAISE NOTICE 'PeriodoTramo: %,FechaCortePeriodo: %', periodotramo, fechacorteperiodo;

		mihoy = now() :: DATE;

		DELETE FROM tem.tabla_array
		WHERE creation_date :: DATE < now() :: DATE AND modulo_cartera = 'SEGUIMIENTO';
		DELETE FROM tem.tabla_array
		WHERE useruse = agenteext AND modulo_cartera = 'SEGUIMIENTO';

		firsttime = 'First';

		FOR carterageneral IN

		SELECT
				nit :: VARCHAR                                                  AS cedula,
				'' :: VARCHAR                                                   AS nombre_cliente,
				'' :: VARCHAR                                                   AS direccion,
				'' :: VARCHAR                                                   AS ciudad,
				'' :: VARCHAR                                                   AS departamento,
				'' :: VARCHAR                                                   AS telefono,
				'' :: VARCHAR                                                   AS telcontacto,
				negasoc :: VARCHAR                                              AS negocio,
				id_convenio :: VARCHAR,
				num_doc_fen :: VARCHAR                                          AS cuota,
				sum(valor_saldo) :: NUMERIC                                     AS valor_asignado,
				fecha_vencimiento :: DATE,
				replace(substring(fecha_vencimiento, 1, 7), '-', '') :: NUMERIC AS periodo_vcto,
				(
						SELECT CASE WHEN maxdia >= 365
								THEN '8- MAYOR A 1 ANIO'
						       WHEN maxdia >= 181
								       THEN '7- ENTRE 180 Y 360'
						       WHEN maxdia >= 121
								       THEN '6- ENTRE 121 Y 180'
						       WHEN maxdia >= 91
								       THEN '5- ENTRE 91 Y 120'
						       WHEN maxdia >= 61
								       THEN '4- ENTRE 61 Y 90'
						       WHEN maxdia >= 31
								       THEN '3- ENTRE 31 Y 60'
						       WHEN maxdia >= 1
								       THEN '2- 1 A 30'
						       WHEN maxdia <= 0
								       THEN '1- CORRIENTE'
						       ELSE '0' END AS rango
						FROM (
								     SELECT max(fechacorteperiodo :: DATE - (fecha_vencimiento)) AS maxdia
								     FROM con.foto_cartera fra
								     WHERE fra.dstrct = 'FINV'
								           AND fra.valor_saldo > 0
								           AND fra.reg_status = ''
								           AND fra.negasoc = con.foto_cartera.negasoc
								           AND fra.tipo_documento IN ('FAC', 'NDC')
								           AND substring(fra.documento, 1, 2) NOT IN ('CP', 'FF', 'DF')
								           AND fra.periodo_lote = periodoasignacion
								     GROUP BY negasoc

						     ) tabla2
				) :: VARCHAR                                                    AS vencimiento_mayor,
				(fechacorteperiodo :: DATE - fecha_vencimiento) :: NUMERIC      AS dias_vencidos,

				(SELECT substring(max(fecha_vencimiento), 9) :: NUMERIC
				 FROM con.foto_cartera fra
				 WHERE fra.dstrct = 'FINV'
				       AND fra.reg_status = ''
				       AND fra.negasoc = con.foto_cartera.negasoc
				       AND fra.tipo_documento IN ('FAC', 'NDC')
				       AND substring(fra.documento, 1, 2) NOT IN ('CP', 'FF', 'DF', 'CA', 'MI')
				       AND fra.periodo_lote = periodoasignacion
				       AND replace(substring(fra.fecha_vencimiento, 1, 7), '-', '') :: NUMERIC <= periodoasignacion
				 GROUP BY negasoc)                                              AS dia_pago,

				'' :: VARCHAR                                                   AS status,
				'' :: VARCHAR                                                   AS status_vencimiento,
				0 :: NUMERIC                                                    AS debido_cobrar,
				0 :: NUMERIC                                                    AS recaudosxcuota_fiducia,
				0 :: NUMERIC                                                    AS recaudosxcuota_fenalco,
				0 :: NUMERIC                                                    AS recaudosxcuota,
				agente :: VARCHAR,
				agente_campo :: VARCHAR

		FROM con.foto_cartera
		WHERE periodo_lote = periodoasignacion
		      AND valor_saldo > 0
		      AND reg_status = ''
		      AND dstrct = 'FINV'
		      AND tipo_documento IN ('FAC', 'NDC')
		      AND substring(documento, 1, 2) NOT IN ('CP', 'FF', 'DF')
		      AND id_convenio IN (SELECT id_convenio
		                          FROM rel_unidadnegocio_convenios
		                          WHERE id_unid_negocio IN (SELECT id
		                                                    FROM unidad_negocio
		                                                    WHERE id = unidadnegocio))
		      AND (SELECT count(0)
		           FROM negocios
		           WHERE cod_neg = con.foto_cartera.negasoc AND negocio_rel = '') > 0
		      AND (SELECT count(0)
		           FROM negocios
		           WHERE cod_neg = con.foto_cartera.negasoc AND negocio_rel_seguro = '') > 0
		      AND (SELECT count(0)
		           FROM negocios
		           WHERE cod_neg = con.foto_cartera.negasoc AND negocio_rel_gps = '') > 0
		GROUP BY id_convenio, cedula, nombre_cliente, direccion, ciudad, telefono, negasoc, num_doc_fen, vencimiento_mayor,
				fecha_vencimiento, periodo_vcto, agente, agente_campo
		ORDER BY negasoc LOOP

				_sumdebidocobrar = 0;
				ingresoxcuota_fiducia = 0;
				ingresoxcuota_fenalco = 0;
				ingresoxcuota = 0;

				--STATUS Y DEBIDO COBRAR
				IF (carterageneral.periodo_vcto = periodoasignacion)
				THEN

						SELECT INTO _sumdebidocobrar coalesce(valor, 0)
						FROM documentos_neg_aceptado
						WHERE cod_neg = carterageneral.negocio AND item = carterageneral.cuota;

						carterageneral.status = 'A Vencer';
						carterageneral.debido_cobrar = coalesce(_sumdebidocobrar, 0);

				ELSE
						IF (carterageneral.dias_vencidos > 0)
						THEN

								carterageneral.status = 'Vencido';
								carterageneral.debido_cobrar = coalesce(carterageneral.valor_asignado, 0);

						ELSE
								SELECT INTO _sumdebidocobrar coalesce(valor, 0)
								FROM documentos_neg_aceptado
								WHERE cod_neg = carterageneral.negocio AND item = carterageneral.cuota;
								carterageneral.status = 'Al Dia';
								carterageneral.debido_cobrar = coalesce(_sumdebidocobrar, 0);
						END IF;
				END IF;

				IF (carterageneral.fecha_vencimiento < mihoy)
				THEN
						carterageneral.status_vencimiento = 'VENCIO';
				ELSE
						carterageneral.status_vencimiento = 'AL DIA';
				END IF;

				--RECAUDO Y ENTIDAD DEL PAGO
				SELECT INTO rs_resultpay *
				FROM SP_PagoNegociosSeguimiento(periodoasignacion :: VARCHAR, carterageneral.negocio, carterageneral.cuota);

				carterageneral.recaudosxcuota_fiducia = rs_resultpay.rs_ingresoxcuota_fiducia;
				carterageneral.recaudosxcuota_fenalco = rs_resultpay.rs_ingresoxcuota_fenalco;
				carterageneral.recaudosxcuota = rs_resultpay.rs_ingresoxcuota;

				IF (rs_resultpay.rs_ingresoxcuota > 0)
				THEN
						carterageneral.recaudosxcuota = rs_resultpay.rs_ingresoxcuota;
				ELSE
						carterageneral.recaudosxcuota = 0;
				END IF;

				SELECT INTO clienterec
						nomcli,
						direccion,
						ciudad,
						CASE WHEN telefono IS NULL
								THEN '0'
						ELSE telefono END AS telefono,
						telcontacto
				FROM cliente
				WHERE nit = carterageneral.cedula;
				carterageneral.nombre_cliente = clienterec.nomcli;
				carterageneral.direccion = clienterec.direccion;
				carterageneral.ciudad = clienterec.ciudad;
				carterageneral.telefono = clienterec.telefono;
				carterageneral.telcontacto = clienterec.telcontacto;

				--BUSCAR DEPARTAMENTO DEL NEGOCIO
				SELECT INTO dpto_neg department_name
				FROM estado
				-- 						INNER JOIN ciudad ON coddpt = department_code
				WHERE department_code = (SELECT sp.departamento
				                         FROM solicitud_aval sa INNER JOIN solicitud_persona sp
								                         ON sp.numero_solicitud = sa.numero_solicitud
				                         WHERE sa.cod_neg = carterageneral.negocio AND  sp.tipo = 'S');

				carterageneral.departamento = dpto_neg;

				RETURN NEXT carterageneral;

		END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION tem.seguimientocartera_asignacion(numeric, character varying, character varying)
  OWNER TO postgres;
