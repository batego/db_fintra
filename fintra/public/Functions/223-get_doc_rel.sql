-- Function: get_doc_rel(text, text, text)

-- DROP FUNCTION get_doc_rel(text, text, text);

CREATE OR REPLACE FUNCTION get_doc_rel(text, text, text)
  RETURNS text AS
$BODY$
DECLARE
	documento ALIAS FOR $1;
	type_doc ALIAS FOR $2;
	tipo ALIAS FOR $3;
	documento_rel TEXT;
	tipo_doc_rel TEXT;
	doc_tipo_rel TEXT;
	prefix TEXT;

--***************************************************************************************
-- Funcion .......... get_doc_rel		                                        *
-- Objetivo ......... Obtener el tipo y documento relacionado de una CxC o CxP          *
-- Parametro 1....... documento						        	*
-- Parametro 2....... tipo del documento	        			        *
-- Parametro 3....... tipo de documento a procesar (CxC o CXP)				*
-- Salida............ tipo y documento relacionado					*
-- Autor ............ Ing. Fabian Diaz Andrade                                          *
-- Fecha ............ 27-05-2010                                                        *
--***************************************************************************************

BEGIN
	prefix := SUBSTR(documento,1,2);

IF (UPPER(tipo) = 'CXC') THEN

	RAISE NOTICE 'tipo : %', tipo;

	IF (prefix IN ('FC','FG','FL','FM')) THEN

		SELECT
			INTO doc_tipo_rel neg.cod_neg || '#' || 'NEG'
		FROM
			con.factura fac
		INNER JOIN
			negocios neg ON (neg.cod_neg = fac.negasoc)
		WHERE
			fac.documento = documento;

		RAISE NOTICE 'FC FG FL FM documento: % doc_tipo_rel : %', documento, doc_tipo_rel;

		ELSE IF (prefix IN ('FF','PC','PF','PG','PL','RE','ND','PM')) THEN

			SELECT
				INTO doc_tipo_rel fac.documento || '#' || fac.tipo_documento
			FROM
				con.factura fac,
				(
				SELECT
					fad.numero_remesa
				FROM
					con.factura fac
				INNER JOIN
					con.factura_detalle fad ON (fad.dstrct = fac.dstrct AND  fad.tipo_documento = fac.tipo_documento AND fad.documento = fac.documento)
				WHERE
					fac.documento = documento
				) vista

			WHERE
				fac.documento = vista.numero_remesa;

			RAISE NOTICE 'FF PC PF PG PL RE ND PM documento: % doc_tipo_rel : %', documento, doc_tipo_rel;

			ELSE IF (prefix IN ('NM')) THEN

				SELECT
					INTO doc_tipo_rel fac.ref1 || '#' || fac.tipo_ref1
				FROM
					con.factura fac
				WHERE
					fac.documento = documento;

			        RAISE NOTICE 'NM documento: % doc_tipo_rel : %', documento, doc_tipo_rel;

				ELSE IF (prefix IN ('PP')) THEN

					SELECT
						INTO doc_tipo_rel os.numero_operacion || '#' || os.tipo_operacion
					FROM
						con.factura fac
					INNER JOIN
						fin.orden_servicio_detalle os ON (os.factura_cxc = fac.documento)
					WHERE
						fac.documento = documento;

					RAISE NOTICE 'PP documento: % doc_tipo_rel : %', documento, doc_tipo_rel;

					ELSE IF (prefix IN ('R0','G0','VA')) THEN

						SELECT
							INTO doc_tipo_rel fac.documento || '#' || fac.tipo_documento
						FROM
							con.factura fac
						WHERE
							fac.documento = documento;

						RAISE NOTICE 'R0 G0 VA documento: % doc_tipo_rel : %', documento, doc_tipo_rel;
					END IF;
				END IF;
			END IF;
		END IF;
	END IF;

	IF doc_tipo_rel IS NULL OR doc_tipo_rel = '' THEN

		SELECT
			INTO doc_tipo_rel fac.documento || '#' || fac.tipo_documento
		FROM
			con.factura fac
		WHERE
			fac.documento = documento;

		RAISE NOTICE 'IS NULL OR VACIO documento: % doc_tipo_rel : %', documento, doc_tipo_rel;

		IF doc_tipo_rel IS NULL OR doc_tipo_rel = '' THEN

			doc_tipo_rel :=  documento || '#' || type_doc;

			RAISE NOTICE 'IS NULL OR VACIO documento: % doc_tipo_rel : %', documento, doc_tipo_rel;

		END IF;

	END IF;

ELSE IF (UPPER(tipo) = 'CXP') THEN

	RAISE NOTICE 'tipo : %', tipo;

	IF (prefix IN ('FP','PM')) THEN

		SELECT
			INTO doc_tipo_rel cxp.documento_relacionado || '#' || cxp.tipo_documento_rel
		FROM
			fin.cxp_doc cxp
		INNER JOIN
			negocios neg ON (neg.cod_neg = cxp.documento_relacionado)
		WHERE
			cxp.documento = documento;

		RAISE NOTICE 'FP PM documento: % doc_tipo_rel : %', documento, doc_tipo_rel;

		ELSE IF (prefix IN ('AB')) THEN

			SELECT
				INTO doc_tipo_rel cxp.documento || '#' || cxp.tipo_documento
			FROM
				fin.cxp_doc cxp,
				(
				SELECT
					DISTINCT factura_contratista
				FROM
					fin.cxp_doc cxp
				INNER JOIN
					app_accord  app ON (app.factura_bonificacion = cxp.documento)
				WHERE
					cxp.documento = documento
				)vista
			WHERE
				cxp.documento = vista.factura_contratista;

			RAISE NOTICE 'AB documento: % doc_tipo_rel : %', documento, doc_tipo_rel;

			ELSE IF (prefix IN ('AR')) THEN

				SELECT
					INTO doc_tipo_rel cxp.documento || '#' || cxp.tipo_documento
				FROM
					fin.cxp_doc cxp,
					(
					SELECT
						DISTINCT factura_contratista
					FROM
						fin.cxp_doc cxp
					INNER JOIN
						app_accord  app ON (app.factura_retencion = cxp.documento)
					WHERE
						cxp.documento = documento
					)vista
				WHERE
					cxp.documento = vista.factura_contratista;

				RAISE NOTICE 'AR documento: % doc_tipo_rel : %', documento, doc_tipo_rel;

				ELSE IF (prefix IN ('PF')) THEN

					SELECT
						INTO doc_tipo_rel cxp.documento || '#' || cxp.tipo_documento
					FROM
						fin.cxp_doc cxp,
						(
						SELECT
							DISTINCT factura_contratista
						FROM
							fin.cxp_doc cxp
						INNER JOIN
							app_accord  app ON (app.factura_formula_provintegral = cxp.documento)
						WHERE
							cxp.documento = documento
						)vista
					WHERE
						cxp.documento = vista.factura_contratista;

					RAISE NOTICE 'PF documento: % doc_tipo_rel : %', documento, doc_tipo_rel;


					ELSE IF (prefix IN ('AP')) THEN

						SELECT
							INTO doc_tipo_rel app.num_os || '#' || 'MS'
						FROM
							fin.cxp_doc cxp
						INNER JOIN
							app_ofertas  app ON (app.factura_app = cxp.documento)
						WHERE
							cxp.documento = documento;

						RAISE NOTICE 'AP documento: % doc_tipo_rel : %', documento, doc_tipo_rel;

						ELSE IF (prefix IN ('EC')) THEN

							SELECT
								INTO doc_tipo_rel app.num_os || '#' || 'MS'
							FROM
								app_ofertas  app
							WHERE
								SPLIT_PART(app.factura_comision_eca,'_',1) =  SPLIT_PART(documento,'_',1);

							RAISE NOTICE 'EC documento: % doc_tipo_rel : %', documento, doc_tipo_rel;

							ELSE IF (prefix IN ('PR')) THEN

								SELECT
									INTO doc_tipo_rel app.num_os || '#' || 'MS'
								FROM
									app_ofertas  app
								WHERE
									app.factura_pro =  documento;

								RAISE NOTICE 'PR documento: % doc_tipo_rel : %', documento, doc_tipo_rel;

								ELSE IF (prefix IN ('CC')) THEN

									doc_tipo_rel :=  documento || '#' || type_doc;

									RAISE NOTICE 'CC documento: % doc_tipo_rel : %', documento, doc_tipo_rel;

									ELSE IF (type_doc IN ('NC','ND')) THEN

										SELECT
											INTO doc_tipo_rel cxp.documento_relacionado || '#' || cxp.tipo_documento_rel
										FROM
											fin.cxp_doc cxp
										WHERE
											cxp.tipo_documento = type_doc AND
											cxp.documento = documento;


										RAISE NOTICE 'NC ND documento: % doc_tipo_rel : %', documento, doc_tipo_rel;


										ELSE IF (prefix ~ '^[0-9]' OR prefix ~ '^E[0-9]') THEN

											SELECT
												INTO doc_tipo_rel os.numero_operacion || '#' || os.tipo_operacion
											FROM
												fin.orden_servicio os
											WHERE
												os.numero_operacion = documento;

											RAISE NOTICE 'OS documento: % doc_tipo_rel : %', documento, doc_tipo_rel;

										END IF;
									END IF;
								END IF;
							END IF;
						END IF;
					END IF;
				END IF;
			END IF;
		END IF;
	END IF;
END IF;

	IF doc_tipo_rel IS NULL OR doc_tipo_rel = '' THEN

		SELECT
			INTO doc_tipo_rel cxp.documento || '#' || cxp.tipo_documento
		FROM
			fin.cxp_doc cxp
		WHERE
			cxp.documento = documento;

		RAISE NOTICE 'IS NULL OR VACIO documento: % doc_tipo_rel : %', documento, doc_tipo_rel;

		IF doc_tipo_rel IS NULL OR doc_tipo_rel = '' THEN

			doc_tipo_rel :=  documento || '#' || type_doc;

		RAISE NOTICE 'IS NULL OR VACIO documento: % doc_tipo_rel : %', documento, doc_tipo_rel;

		END IF;
	END IF;

END IF;

RETURN doc_tipo_rel;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_doc_rel(text, text, text)
  OWNER TO postgres;
