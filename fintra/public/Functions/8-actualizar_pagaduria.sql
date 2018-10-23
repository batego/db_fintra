-- Function: actualizar_pagaduria(character varying, character varying, character varying, character varying, character varying)

-- DROP FUNCTION actualizar_pagaduria(character varying, character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION actualizar_pagaduria(negocio_ character varying, cliente_ character varying, pagaduria_ character varying, usuario_ character varying, comentario_ character varying)
  RETURNS text AS
$BODY$
DECLARE
		respuesta   VARCHAR := 'Pagaduría Actualizada';
		formulario  VARCHAR;
		formularios RECORD;

BEGIN
		--Se actualiza solo la pagaduría perteneciente a ese negocio
		IF negocio_ != 'n'
		THEN
				SELECT INTO formulario numero_solicitud
				FROM solicitud_aval
				WHERE cod_neg = negocio_;
				RAISE NOTICE 'formulario: %', formulario;

				--Se actualiza el filtro libranza
				UPDATE filtro_libranza
				SET id_empresa_pagaduria = (SELECT id
				                            FROM pagadurias
				                            WHERE documento = pagaduria_),
						last_update          = now(), user_update = usuario_
				WHERE numero_solicitud = formulario;
				RAISE NOTICE 'formulario: %', negocio_;

				--Se actualiza en la solicitud
				UPDATE solicitud_aval
				SET afiliado = pagaduria_, last_update = now(), user_update = usuario_
				WHERE cod_neg = negocio_;

				--Se actualiza en el negocio
				UPDATE negocios
				SET nit_tercero = pagaduria_, uptade_date = now(), update_user = usuario_
				WHERE cod_neg = negocio_;

				--Se inserta el registro para la trazabilidad
				INSERT INTO trazabilidad_pagadurias (cod_neg, pagaduria, usuario, comentarios)
				VALUES (negocio_, pagaduria_, usuario_, comentario_);

		ELSEIF cliente_ != 'n'        --Se actualiza la pagaduría de todos los negocios del cliente
				THEN
						FOR formularios IN SELECT
								                   numero_solicitud,
								                   cod_neg
						                   FROM solicitud_aval
						                   WHERE afiliado = cliente_ AND reg_status = '' LOOP
								RAISE NOTICE 'formulario: %', formularios.numero_solicitud;

								--Se actualiza el filtro libranza
								UPDATE filtro_libranza
								SET id_empresa_pagaduria = (SELECT id
								                            FROM pagadurias
								                            WHERE documento = pagaduria_),
										last_update          = now(), user_update = usuario_
								WHERE numero_solicitud = formularios.numero_solicitud;

								--Se actualiza en la solicitud
								UPDATE solicitud_aval
								SET afiliado = pagaduria_, last_update = now(), user_update = usuario_
								WHERE cod_neg = formularios.cod_neg;

								--Se actualiza en el negocio
								UPDATE negocios
								SET nit_tercero = pagaduria_, uptade_date = now(), update_user = usuario_
								WHERE cod_neg = formularios.cod_neg;

								--Se inserta el registro para la trazabilidad
								INSERT INTO trazabilidad_pagadurias (cod_neg, pagaduria, usuario, comentarios)
								VALUES (formularios.cod_neg, pagaduria_, usuario_, comentario_);
						END LOOP;
		END IF;

		RETURN respuesta;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION actualizar_pagaduria(character varying, character varying, character varying, character varying, character varying)
  OWNER TO postgres;
