-- Function: administrativo.sp_creademanda(character varying, character varying, character varying, character varying, character varying)

-- DROP FUNCTION administrativo.sp_creademanda(character varying, character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION administrativo.sp_creademanda(empresa character varying, codigo_negocio character varying, nit character varying, valorsaldo character varying, usuariocrea character varying)
  RETURNS text AS
$BODY$

DECLARE
        idDemanda integer;
        resultId integer;
        estado_proc_ini integer;
       	configDocsRecord record;
 	configDocsDetRecord record;
        dataToFillEmpresaRecord record;
        dataToFillRepLegalRecord record;
        dataToFillAbogadoRecord record;
        dataToFillDocsRecord record;
        dataToFillCodeudorRecord record;
	retorno text:='OK';
        good text:='';
        idcodeudor text:='';
        infocodeudor text:='';
        notifcodeudor text:='';
        fecha_mora text:='';
	_valorsaldo numeric;
	_valorabono numeric:=0;
	_valorpretension numeric;

BEGIN

	_valorsaldo = valorsaldo::numeric;


	--Calculamos valor abono para el negocio dado
	select into _valorabono sp_totalAbonos(codigo_negocio);


        if (NOT EXISTS(select * from administrativo.demanda where negocio = codigo_negocio AND reg_status = '')) then
			--Se inserta en tabla demanda
			INSERT INTO administrativo.demanda (id_etapa,negocio,nitDemandado,estado_proceso,creation_user) values(1,codigo_negocio,nit,0,usuariocrea)  RETURNING id INTO idDemanda;

			select into dataToFillEmpresaRecord tgen.referencia as tipo_identificacion, replace(to_char(documento::BIGINT,'FM999,999,999,999,999'),',','.') as identificacion,nombre,dep.department_name as departamento,
			ciu.nomciu as ciudad, direccion, telefono, tel_extension as ext, celular, email, tarjeta_profesional,
			doc_lugar_exped as lugar_exped from administrativo.actores_proceso_juridico act
			INNER JOIN tablagen tgen ON tgen.table_code = act.tipo_documento AND table_type in ('TIPID')
			INNER JOIN ciudad ciu ON ciu.codciu = act.codciu
			INNER JOIN estado dep ON dep.department_code = act.coddpto WHERE tipo_actor = 1;

			select into dataToFillRepLegalRecord tgen.referencia as tipo_identificacion, replace(to_char(documento::BIGINT,'FM999,999,999,999,999'),',','.') AS identificacion,nombre,dep.department_name as departamento,
			ciu.nomciu as ciudad,direccion, telefono, tel_extension as ext, celular, email, tarjeta_profesional,
			doc_lugar_exped as lugar_exped from administrativo.actores_proceso_juridico act
			INNER JOIN tablagen tgen ON tgen.table_code = act.tipo_documento AND table_type in ('TIPID')
			INNER JOIN ciudad ciu ON ciu.codciu = act.codciu
			INNER JOIN estado dep ON dep.department_code = act.coddpto WHERE tipo_actor = 2;

			select into dataToFillAbogadoRecord tgen.referencia as tipo_identificacion, replace(to_char(documento::BIGINT,'FM999,999,999,999,999'),',','.') AS identificacion,nombre,dep.department_name as departamento,
			ciu.nomciu as ciudad,direccion, telefono, tel_extension as ext, celular, email, tarjeta_profesional,
			doc_lugar_exped as lugar_exped from administrativo.actores_proceso_juridico act
			INNER JOIN tablagen tgen ON tgen.table_code = act.tipo_documento AND table_type in ('TIPID')
			INNER JOIN ciudad ciu ON ciu.codciu = act.codciu
			INNER JOIN estado dep ON dep.department_code = act.coddpto WHERE tipo_actor = 3;


			--Obtenemos datos del demandado
			select into dataToFillDocsRecord    tgen.referencia as tipo_identificacion, sp.tipo_id as tipo_identificacion, replace(to_char(sp.identificacion::BIGINT,'FM999,999,999,999,999'),',','.') as identificacion,
							    sp.primer_nombre||' '||sp.segundo_nombre||' '||sp.primer_apellido||' '||sp.segundo_apellido as nombre,
							    depexp.department_name as departamento_exped, ciuexp.nomciu as ciudad_exped, sp.genero, dep.department_name as departamento, ciu.nomciu as ciudad,
							    sp.direccion, sp.barrio, sp.telefono, ''::character varying as  ext, coalesce(sp.celular,'') as celular, coalesce(sp.email,'') as email, coalesce(sl.nombre_empresa,'') as nombre_empresa,
							    coalesce(num_pagare,'') as num_pagare, extract(DAY FROM fecha_negocio)||' de '||mes.descripcion||' de '||extract(YEAR FROM fecha_negocio) AS  fecha_negocio, coalesce(vr_desembolso,0) as vr_desembolso,
							    coalesce(vr_negocio,0) as vr_negocio, CASE WHEN neg.id_convenio IN(16) THEN 'mixto' ELSE 'singular' END AS tipo_proceso FROM negocios neg
							    INNER JOIN solicitud_aval s ON (s.cod_neg=neg.cod_neg) AND s.reg_status=''
							    INNER JOIN solicitud_persona sp ON sp.numero_solicitud = s.numero_solicitud AND sp.reg_status='' AND sp.tipo in('S')
							    INNER JOIN solicitud_laboral sl ON sl.numero_solicitud =  s.numero_solicitud AND sl.tipo='S' AND sl.reg_status = ''
							    INNER JOIN tablagen tgen ON tgen.table_code = sp.tipo_id AND table_type in ('TIPID')
							    INNER JOIN ciudad ciu ON ciu.codciu = sp.ciudad
							    INNER JOIN ciudad ciuexp ON ciuexp.codciu = sp.ciudad_expedicion_id
							    INNER JOIN estado dep ON dep.department_code = ciu.coddpt
							    INNER JOIN estado depexp ON depexp.department_code = ciuexp.coddpt
							    INNER JOIN "meses_año" mes ON mes.id = extract(MONTH FROM fecha_negocio)
							    WHERE neg.cod_neg=codigo_negocio AND s.reg_status='';

                        --Obtenemos fecha a partir la cual negocio entro en mora
			select into fecha_mora extract(DAY FROM fecha_vencimiento)||' de '||mes.descripcion||' de '||extract(YEAR FROM fecha_vencimiento) as fecha_vencimiento from (select min(fecha_vencimiento) as fecha_vencimiento from con.factura  fra
                            WHERE  fra.dstrct = 'FINV'  --AND tipo_documento= 'FAC'
			    AND fra.valor_saldo > 0
			    AND fra.reg_status = ''
			    AND fra.negasoc !=''--neg.cod_neg
			    AND substring(fra.documento,1,2) not in ('CP','FF','DF')
			    and fra.negasoc = codigo_negocio order by fecha_vencimiento) t
                            INNER JOIN "meses_año" mes ON mes.id = extract(MONTH FROM t.fecha_vencimiento);

			--Validamos si hay abonos realizados para el negocio dado
			IF _valorabono > 0 THEN
			   _valorpretension = _valorsaldo;
                        ELSE
			   _valorpretension = dataToFillDocsRecord.vr_desembolso;
			END IF;


		       --Obtenemos configuracion inicial documentos asociados al proceso de demanda
			--Demanda
			FOR configDocsRecord IN
				select  * from administrativo.config_docs_demanda where tipo_doc in(1,2,3)
			LOOP
			     --Insertamos en tabla demanda_docs
			       INSERT INTO administrativo.demanda_docs (id_demanda,tipo_doc,header_info,initial_info,footer_info,signing_info,footer_page,aux_1,aux_2,aux_3,aux_4,aux_5)
			       VALUES (idDemanda,configDocsRecord.tipo_doc,configDocsRecord.header_info,configDocsRecord.initial_info,configDocsRecord.footer_info,configDocsRecord.signing_info,
			       configDocsRecord.footer_page,configDocsRecord.aux_1,configDocsRecord.aux_2,configDocsRecord.aux_3,configDocsRecord.aux_4,configDocsRecord.aux_5) RETURNING id INTO resultId;

   	                        FOR configDocsDetRecord IN
				   SELECT tipo, titulo, nombre, descripcion FROM administrativo.config_docs_demanda_det where id_tipo_doc = configDocsRecord.tipo_doc ORDER BY tipo, id
			        LOOP
			                --Si no tiene abono se verifica si no esta marcado con la condicion especial CE01
			                IF _valorabono > 0 OR (_valorabono = 0 AND NOT EXISTS(SELECT * FROM administrativo.rel_condiciones_item_demanda WHERE id_condicion='CE01' AND id_item = configDocsDetRecord.nombre))  THEN
					    INSERT INTO administrativo.demanda_docs_det (id_demanda_doc, tipo, titulo, descripcion) values(resultId, configDocsDetRecord.tipo,configDocsDetRecord.titulo,configDocsDetRecord.descripcion);
                                        END IF;
			        END LOOP;

			--Actualizamos variables
			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P01', dataToFillEmpresaRecord.identificacion), initial_info = replace(initial_info, 'P01', dataToFillEmpresaRecord.identificacion),
						footer_info = replace(footer_info, 'P01', dataToFillEmpresaRecord.identificacion), signing_info = replace(signing_info, 'P01', dataToFillEmpresaRecord.identificacion),
						footer_page = replace(footer_page, 'P01', dataToFillEmpresaRecord.identificacion), aux_1 = replace(aux_1, 'P01', dataToFillEmpresaRecord.identificacion),
						aux_2 = replace(aux_2, 'P01', dataToFillEmpresaRecord.identificacion), aux_3 = replace(aux_3, 'P01', dataToFillEmpresaRecord.identificacion),
						aux_4 = replace(aux_4, 'P01', dataToFillEmpresaRecord.identificacion), aux_5 = replace(aux_5, 'P01', dataToFillEmpresaRecord.identificacion)
						WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P02', dataToFillEmpresaRecord.nombre), initial_info = replace(initial_info, 'P02', dataToFillEmpresaRecord.nombre),
					footer_info = replace(footer_info, 'P02', dataToFillEmpresaRecord.nombre), signing_info = replace(signing_info, 'P02', dataToFillEmpresaRecord.nombre),
					footer_page = replace(footer_page, 'P02', dataToFillEmpresaRecord.nombre), aux_1 = replace(aux_1, 'P02', dataToFillEmpresaRecord.nombre),
					aux_2 = replace(aux_2, 'P02', dataToFillEmpresaRecord.nombre), aux_3 = replace(aux_3, 'P02', dataToFillEmpresaRecord.nombre),
					aux_4 = replace(aux_4, 'P02', dataToFillEmpresaRecord.nombre), aux_5 = replace(aux_5, 'P02', dataToFillEmpresaRecord.nombre)
					WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P03', dataToFillEmpresaRecord.direccion), initial_info = replace(initial_info, 'P03', dataToFillEmpresaRecord.direccion),
						footer_info = replace(footer_info, 'P03', dataToFillEmpresaRecord.direccion), signing_info = replace(signing_info, 'P03', dataToFillEmpresaRecord.direccion),
						footer_page = replace(footer_page, 'P03', dataToFillEmpresaRecord.direccion), aux_1 = replace(aux_1, 'P03', dataToFillEmpresaRecord.direccion),
						aux_2 = replace(aux_2, 'P03', dataToFillEmpresaRecord.direccion), aux_3 = replace(aux_3, 'P03', dataToFillEmpresaRecord.direccion),
						aux_4 = replace(aux_4, 'P03', dataToFillEmpresaRecord.direccion), aux_5 = replace(aux_5, 'P03', dataToFillEmpresaRecord.direccion)
						WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P04', dataToFillEmpresaRecord.departamento), initial_info = replace(initial_info, 'P04', dataToFillEmpresaRecord.departamento),
						footer_info = replace(footer_info, 'P04', dataToFillEmpresaRecord.departamento), signing_info = replace(signing_info, 'P04', dataToFillEmpresaRecord.departamento),
						footer_page = replace(footer_page, 'P04', dataToFillEmpresaRecord.departamento), aux_1 = replace(aux_1, 'P04', dataToFillEmpresaRecord.departamento),
						aux_2 = replace(aux_2, 'P04', dataToFillEmpresaRecord.departamento), aux_3 = replace(aux_3, 'P04', dataToFillEmpresaRecord.departamento),
						aux_4 = replace(aux_4, 'P04', dataToFillEmpresaRecord.departamento), aux_5 = replace(aux_5, 'P04', dataToFillEmpresaRecord.departamento)
						WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P05', dataToFillEmpresaRecord.ciudad), initial_info = replace(initial_info, 'P05', dataToFillEmpresaRecord.ciudad),
						footer_info = replace(footer_info, 'P05', dataToFillEmpresaRecord.ciudad), signing_info = replace(signing_info, 'P05', dataToFillEmpresaRecord.ciudad),
						footer_page = replace(footer_page, 'P05', dataToFillEmpresaRecord.ciudad), aux_1 = replace(aux_1, 'P05', dataToFillEmpresaRecord.ciudad),
						aux_2 = replace(aux_2, 'P05', dataToFillEmpresaRecord.ciudad), aux_3 = replace(aux_3, 'P05', dataToFillEmpresaRecord.ciudad),
						aux_4 = replace(aux_4, 'P05', dataToFillEmpresaRecord.ciudad), aux_5 = replace(aux_5, 'P05', dataToFillEmpresaRecord.ciudad)
						WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P06', dataToFillEmpresaRecord.telefono), initial_info = replace(initial_info, 'P06', dataToFillEmpresaRecord.telefono),
						footer_info = replace(footer_info, 'P06', dataToFillEmpresaRecord.telefono), signing_info = replace(signing_info, 'P06', dataToFillEmpresaRecord.telefono),
						footer_page = replace(footer_page, 'P06', dataToFillEmpresaRecord.telefono), aux_1 = replace(aux_1, 'P06', dataToFillEmpresaRecord.telefono),
						aux_2 = replace(aux_2, 'P06', dataToFillEmpresaRecord.telefono), aux_3 = replace(aux_3, 'P06', dataToFillEmpresaRecord.telefono),
						aux_4 = replace(aux_4, 'P06', dataToFillEmpresaRecord.telefono), aux_5 = replace(aux_5, 'P06', dataToFillEmpresaRecord.telefono)
						WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P07', dataToFillEmpresaRecord.ext), initial_info = replace(initial_info, 'P07', dataToFillEmpresaRecord.ext),
						footer_info = replace(footer_info, 'P07', dataToFillEmpresaRecord.ext), signing_info = replace(signing_info, 'P07', dataToFillEmpresaRecord.ext),
						footer_page = replace(footer_page, 'P07', dataToFillEmpresaRecord.ext), aux_1 = replace(aux_1, 'P07', dataToFillEmpresaRecord.ext),
						aux_2 = replace(aux_2, 'P07', dataToFillEmpresaRecord.ext), aux_3 = replace(aux_3, 'P07', dataToFillEmpresaRecord.ext),
						aux_4 = replace(aux_4, 'P07', dataToFillEmpresaRecord.ext), aux_5 = replace(aux_5, 'P07', dataToFillEmpresaRecord.ext)
						WHERE id = resultId;

			 UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P08', dataToFillEmpresaRecord.email), initial_info = replace(initial_info, 'P08', dataToFillEmpresaRecord.email),
						footer_info = replace(footer_info, 'P08', dataToFillEmpresaRecord.email), signing_info = replace(signing_info, 'P08', dataToFillEmpresaRecord.email),
						footer_page = replace(footer_page, 'P08', dataToFillEmpresaRecord.email), aux_1 = replace(aux_1, 'P08', dataToFillEmpresaRecord.email),
						aux_2 = replace(aux_2, 'P08', dataToFillEmpresaRecord.email), aux_3 = replace(aux_3, 'P08', dataToFillEmpresaRecord.email),
						aux_4 = replace(aux_4, 'P08', dataToFillEmpresaRecord.email), aux_5 = replace(aux_5, 'P08', dataToFillEmpresaRecord.email)
						WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P09', dataToFillRepLegalRecord.tipo_identificacion), initial_info = replace(initial_info, 'P09', dataToFillRepLegalRecord.tipo_identificacion),
						footer_info = replace(footer_info, 'P09', dataToFillRepLegalRecord.tipo_identificacion), signing_info = replace(signing_info, 'P09', dataToFillRepLegalRecord.tipo_identificacion),
						footer_page = replace(footer_page, 'P09', dataToFillRepLegalRecord.tipo_identificacion), aux_1 = replace(aux_1, 'P09', dataToFillRepLegalRecord.tipo_identificacion),
						aux_2 = replace(aux_2, 'P09', dataToFillRepLegalRecord.tipo_identificacion), aux_3 = replace(aux_3, 'P09', dataToFillRepLegalRecord.tipo_identificacion),
						aux_4 = replace(aux_4, 'P09', dataToFillRepLegalRecord.tipo_identificacion), aux_5 = replace(aux_5, 'P09', dataToFillRepLegalRecord.tipo_identificacion)
						WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P10', dataToFillRepLegalRecord.identificacion), initial_info = replace(initial_info, 'P10', dataToFillRepLegalRecord.identificacion),
						footer_info = replace(footer_info, 'P10', dataToFillRepLegalRecord.identificacion), signing_info = replace(signing_info, 'P10', dataToFillRepLegalRecord.identificacion),
						footer_page = replace(footer_page, 'P10', dataToFillRepLegalRecord.identificacion), aux_1 = replace(aux_1, 'P10', dataToFillRepLegalRecord.identificacion),
						aux_2 = replace(aux_2, 'P10', dataToFillRepLegalRecord.identificacion), aux_3 = replace(aux_3, 'P10', dataToFillRepLegalRecord.identificacion),
						aux_4 = replace(aux_4, 'P10', dataToFillRepLegalRecord.identificacion), aux_5 = replace(aux_5, 'P10', dataToFillRepLegalRecord.identificacion)
						WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P11', dataToFillRepLegalRecord.nombre), initial_info = replace(initial_info, 'P11', dataToFillRepLegalRecord.nombre),
						footer_info = replace(footer_info, 'P11', dataToFillRepLegalRecord.nombre), signing_info = replace(signing_info, 'P11', dataToFillRepLegalRecord.nombre),
						footer_page = replace(footer_page, 'P11', dataToFillRepLegalRecord.nombre), aux_1 = replace(aux_1, 'P11', dataToFillRepLegalRecord.nombre),
						aux_2 = replace(aux_2, 'P11', dataToFillRepLegalRecord.nombre), aux_3 = replace(aux_3, 'P11', dataToFillRepLegalRecord.nombre),
						aux_4 = replace(aux_4, 'P11', dataToFillRepLegalRecord.nombre), aux_5 = replace(aux_5, 'P11', dataToFillRepLegalRecord.nombre)
						WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P12', dataToFillRepLegalRecord.lugar_exped), initial_info = replace(initial_info, 'P12', dataToFillRepLegalRecord.lugar_exped),
						footer_info = replace(footer_info, 'P12', dataToFillRepLegalRecord.lugar_exped), signing_info = replace(signing_info, 'P12', dataToFillRepLegalRecord.lugar_exped),
						footer_page = replace(footer_page, 'P12', dataToFillRepLegalRecord.lugar_exped), aux_1 = replace(aux_1, 'P12', dataToFillRepLegalRecord.lugar_exped),
						aux_2 = replace(aux_2, 'P12', dataToFillRepLegalRecord.lugar_exped), aux_3 = replace(aux_3, 'P12', dataToFillRepLegalRecord.lugar_exped),
						aux_4 = replace(aux_4, 'P12', dataToFillRepLegalRecord.lugar_exped), aux_5 = replace(aux_5, 'P12', dataToFillRepLegalRecord.lugar_exped)
						WHERE id = resultId;

		       UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P13', dataToFillRepLegalRecord.direccion), initial_info = replace(initial_info, 'P13', dataToFillRepLegalRecord.direccion),
						footer_info = replace(footer_info, 'P13', dataToFillRepLegalRecord.direccion), signing_info = replace(signing_info, 'P13', dataToFillRepLegalRecord.direccion),
						footer_page = replace(footer_page, 'P13', dataToFillRepLegalRecord.direccion), aux_1 = replace(aux_1, 'P13', dataToFillRepLegalRecord.direccion),
						aux_2 = replace(aux_2, 'P13', dataToFillRepLegalRecord.direccion), aux_3 = replace(aux_3, 'P13', dataToFillRepLegalRecord.direccion),
						aux_4 = replace(aux_4, 'P13', dataToFillRepLegalRecord.direccion), aux_5 = replace(aux_5, 'P13', dataToFillRepLegalRecord.direccion)
						WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P14', dataToFillRepLegalRecord.departamento), initial_info = replace(initial_info, 'P14', dataToFillRepLegalRecord.departamento),
						footer_info = replace(footer_info, 'P14', dataToFillRepLegalRecord.departamento), signing_info = replace(signing_info, 'P14', dataToFillRepLegalRecord.departamento),
						footer_page = replace(footer_page, 'P14', dataToFillRepLegalRecord.departamento), aux_1 = replace(aux_1, 'P14', dataToFillRepLegalRecord.departamento),
						aux_2 = replace(aux_2, 'P14', dataToFillRepLegalRecord.departamento), aux_3 = replace(aux_3, 'P14', dataToFillRepLegalRecord.departamento),
						aux_4 = replace(aux_4, 'P14', dataToFillRepLegalRecord.departamento), aux_5 = replace(aux_5, 'P14', dataToFillRepLegalRecord.departamento)
						WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P15', dataToFillRepLegalRecord.ciudad), initial_info = replace(initial_info, 'P15', dataToFillRepLegalRecord.ciudad),
						footer_info = replace(footer_info, 'P15', dataToFillRepLegalRecord.ciudad), signing_info = replace(signing_info, 'P15', dataToFillRepLegalRecord.ciudad),
						footer_page = replace(footer_page, 'P15', dataToFillRepLegalRecord.ciudad), aux_1 = replace(aux_1, 'P15', dataToFillRepLegalRecord.ciudad),
						aux_2 = replace(aux_2, 'P15', dataToFillRepLegalRecord.ciudad), aux_3 = replace(aux_3, 'P15', dataToFillRepLegalRecord.ciudad),
						aux_4 = replace(aux_4, 'P15', dataToFillRepLegalRecord.ciudad), aux_5 = replace(aux_5, 'P15', dataToFillRepLegalRecord.ciudad)
						WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P16', dataToFillRepLegalRecord.telefono), initial_info = replace(initial_info, 'P16', dataToFillRepLegalRecord.telefono),
						footer_info = replace(footer_info, 'P16', dataToFillRepLegalRecord.telefono), signing_info = replace(signing_info, 'P16', dataToFillRepLegalRecord.telefono),
						footer_page = replace(footer_page, 'P16', dataToFillRepLegalRecord.telefono), aux_1 = replace(aux_1, 'P16', dataToFillRepLegalRecord.telefono),
						aux_2 = replace(aux_2, 'P16', dataToFillRepLegalRecord.telefono), aux_3 = replace(aux_3, 'P16', dataToFillRepLegalRecord.telefono),
						aux_4 = replace(aux_4, 'P16', dataToFillRepLegalRecord.telefono), aux_5 = replace(aux_5, 'P16', dataToFillRepLegalRecord.telefono)
						WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P17', dataToFillRepLegalRecord.ext), initial_info = replace(initial_info, 'P17', dataToFillRepLegalRecord.ext),
						footer_info = replace(footer_info, 'P17', dataToFillRepLegalRecord.ext), signing_info = replace(signing_info, 'P17', dataToFillRepLegalRecord.ext),
						footer_page = replace(footer_page, 'P17', dataToFillRepLegalRecord.ext), aux_1 = replace(aux_1, 'P17', dataToFillRepLegalRecord.ext),
						aux_2 = replace(aux_2, 'P17', dataToFillRepLegalRecord.ext), aux_3 = replace(aux_3, 'P17', dataToFillRepLegalRecord.ext),
						aux_4 = replace(aux_4, 'P17', dataToFillRepLegalRecord.ext), aux_5 = replace(aux_5, 'P17', dataToFillRepLegalRecord.ext)
						WHERE id = resultId;

			 UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P18', dataToFillRepLegalRecord.email), initial_info = replace(initial_info, 'P18', dataToFillRepLegalRecord.email),
						footer_info = replace(footer_info, 'P18', dataToFillRepLegalRecord.email), signing_info = replace(signing_info, 'P18', dataToFillRepLegalRecord.email),
						footer_page = replace(footer_page, 'P18', dataToFillRepLegalRecord.email), aux_1 = replace(aux_1, 'P18', dataToFillRepLegalRecord.email),
						aux_2 = replace(aux_2, 'P18', dataToFillRepLegalRecord.email), aux_3 = replace(aux_3, 'P18', dataToFillRepLegalRecord.email),
						aux_4 = replace(aux_4, 'P18', dataToFillRepLegalRecord.email), aux_5 = replace(aux_5, 'P18', dataToFillRepLegalRecord.email)
						WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P19', dataToFillRepLegalRecord.celular), initial_info = replace(initial_info, 'P19', dataToFillRepLegalRecord.celular),
					footer_info = replace(footer_info, 'P19', dataToFillRepLegalRecord.celular), signing_info = replace(signing_info, 'P19', dataToFillRepLegalRecord.celular),
					footer_page = replace(footer_page, 'P19', dataToFillRepLegalRecord.celular), aux_1 = replace(aux_1, 'P19', dataToFillRepLegalRecord.celular),
					aux_2 = replace(aux_2, 'P19', dataToFillRepLegalRecord.celular), aux_3 = replace(aux_3, 'P19', dataToFillRepLegalRecord.celular),
					aux_4 = replace(aux_4, 'P19', dataToFillRepLegalRecord.celular), aux_5 = replace(aux_5, 'P19', dataToFillRepLegalRecord.celular)
					WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P20', dataToFillAbogadoRecord.tipo_identificacion), initial_info = replace(initial_info, 'P20', dataToFillAbogadoRecord.tipo_identificacion),
							footer_info = replace(footer_info, 'P20', dataToFillAbogadoRecord.tipo_identificacion), signing_info = replace(signing_info, 'P20', dataToFillAbogadoRecord.tipo_identificacion),
							footer_page = replace(footer_page, 'P20', dataToFillAbogadoRecord.tipo_identificacion), aux_1 = replace(aux_1, 'P20', dataToFillAbogadoRecord.tipo_identificacion),
							aux_2 = replace(aux_2, 'P20', dataToFillAbogadoRecord.tipo_identificacion), aux_3 = replace(aux_3, 'P20', dataToFillAbogadoRecord.tipo_identificacion),
							aux_4 = replace(aux_4, 'P20', dataToFillAbogadoRecord.tipo_identificacion), aux_5 = replace(aux_5, 'P20', dataToFillAbogadoRecord.tipo_identificacion)
							WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P21', dataToFillAbogadoRecord.identificacion), initial_info = replace(initial_info, 'P21', dataToFillAbogadoRecord.identificacion),
						footer_info = replace(footer_info, 'P21', dataToFillAbogadoRecord.identificacion), signing_info = replace(signing_info, 'P21', dataToFillAbogadoRecord.identificacion),
						footer_page = replace(footer_page, 'P21', dataToFillAbogadoRecord.identificacion), aux_1 = replace(aux_1, 'P21', dataToFillAbogadoRecord.identificacion),
						aux_2 = replace(aux_2, 'P21', dataToFillAbogadoRecord.identificacion), aux_3 = replace(aux_3, 'P21', dataToFillAbogadoRecord.identificacion),
						aux_4 = replace(aux_4, 'P21', dataToFillAbogadoRecord.identificacion), aux_5 = replace(aux_5, 'P21', dataToFillAbogadoRecord.identificacion)
						WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P22', dataToFillAbogadoRecord.nombre), initial_info = replace(initial_info, 'P22', dataToFillAbogadoRecord.nombre),
						footer_info = replace(footer_info, 'P22', dataToFillAbogadoRecord.nombre), signing_info = replace(signing_info, 'P22', dataToFillAbogadoRecord.nombre),
						footer_page = replace(footer_page, 'P22', dataToFillAbogadoRecord.nombre), aux_1 = replace(aux_1, 'P22', dataToFillAbogadoRecord.nombre),
						aux_2 = replace(aux_2, 'P22', dataToFillAbogadoRecord.nombre), aux_3 = replace(aux_3, 'P22', dataToFillAbogadoRecord.nombre),
						aux_4 = replace(aux_4, 'P22', dataToFillAbogadoRecord.nombre), aux_5 = replace(aux_5, 'P22', dataToFillAbogadoRecord.nombre)
						WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P23', dataToFillAbogadoRecord.lugar_exped), initial_info = replace(initial_info, 'P23', dataToFillAbogadoRecord.lugar_exped),
						footer_info = replace(footer_info, 'P23', dataToFillAbogadoRecord.lugar_exped), signing_info = replace(signing_info, 'P23', dataToFillAbogadoRecord.lugar_exped),
						footer_page = replace(footer_page, 'P23', dataToFillAbogadoRecord.lugar_exped), aux_1 = replace(aux_1, 'P23', dataToFillAbogadoRecord.lugar_exped),
						aux_2 = replace(aux_2, 'P23', dataToFillAbogadoRecord.lugar_exped), aux_3 = replace(aux_3, 'P23', dataToFillAbogadoRecord.lugar_exped),
						aux_4 = replace(aux_4, 'P23', dataToFillAbogadoRecord.lugar_exped), aux_5 = replace(aux_5, 'P23', dataToFillAbogadoRecord.lugar_exped)
						WHERE id = resultId;

		       UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P24', dataToFillAbogadoRecord.direccion), initial_info = replace(initial_info, 'P24', dataToFillAbogadoRecord.direccion),
						footer_info = replace(footer_info, 'P24', dataToFillAbogadoRecord.direccion), signing_info = replace(signing_info, 'P24', dataToFillAbogadoRecord.direccion),
						footer_page = replace(footer_page, 'P24', dataToFillAbogadoRecord.direccion), aux_1 = replace(aux_1, 'P24', dataToFillAbogadoRecord.direccion),
						aux_2 = replace(aux_2, 'P24', dataToFillAbogadoRecord.direccion), aux_3 = replace(aux_3, 'P24', dataToFillAbogadoRecord.direccion),
						aux_4 = replace(aux_4, 'P24', dataToFillAbogadoRecord.direccion), aux_5 = replace(aux_5, 'P24', dataToFillAbogadoRecord.direccion)
						WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P25', dataToFillAbogadoRecord.departamento), initial_info = replace(initial_info, 'P25', dataToFillAbogadoRecord.departamento),
						footer_info = replace(footer_info, 'P25', dataToFillAbogadoRecord.departamento), signing_info = replace(signing_info, 'P25', dataToFillAbogadoRecord.departamento),
						footer_page = replace(footer_page, 'P25', dataToFillAbogadoRecord.departamento), aux_1 = replace(aux_1, 'P25', dataToFillAbogadoRecord.departamento),
						aux_2 = replace(aux_2, 'P25', dataToFillAbogadoRecord.departamento), aux_3 = replace(aux_3, 'P25', dataToFillAbogadoRecord.departamento),
						aux_4 = replace(aux_4, 'P25', dataToFillAbogadoRecord.departamento), aux_5 = replace(aux_5, 'P25', dataToFillAbogadoRecord.departamento)
						WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P26', dataToFillAbogadoRecord.ciudad), initial_info = replace(initial_info, 'P26', dataToFillAbogadoRecord.ciudad),
						footer_info = replace(footer_info, 'P26', dataToFillAbogadoRecord.ciudad), signing_info = replace(signing_info, 'P26', dataToFillAbogadoRecord.ciudad),
						footer_page = replace(footer_page, 'P26', dataToFillAbogadoRecord.ciudad), aux_1 = replace(aux_1, 'P26', dataToFillAbogadoRecord.ciudad),
						aux_2 = replace(aux_2, 'P26', dataToFillAbogadoRecord.ciudad), aux_3 = replace(aux_3, 'P26', dataToFillAbogadoRecord.ciudad),
						aux_4 = replace(aux_4, 'P26', dataToFillAbogadoRecord.ciudad), aux_5 = replace(aux_5, 'P26', dataToFillAbogadoRecord.ciudad)
						WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P27', dataToFillAbogadoRecord.telefono), initial_info = replace(initial_info, 'P27', dataToFillAbogadoRecord.telefono),
						footer_info = replace(footer_info, 'P27', dataToFillAbogadoRecord.telefono), signing_info = replace(signing_info, 'P27', dataToFillAbogadoRecord.telefono),
						footer_page = replace(footer_page, 'P27', dataToFillAbogadoRecord.telefono), aux_1 = replace(aux_1, 'P27', dataToFillAbogadoRecord.telefono),
						aux_2 = replace(aux_2, 'P27', dataToFillAbogadoRecord.telefono), aux_3 = replace(aux_3, 'P27', dataToFillAbogadoRecord.telefono),
						aux_4 = replace(aux_4, 'P27', dataToFillAbogadoRecord.telefono), aux_5 = replace(aux_5, 'P27', dataToFillAbogadoRecord.telefono)
						WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P28', dataToFillAbogadoRecord.ext), initial_info = replace(initial_info, 'P28', dataToFillAbogadoRecord.ext),
						footer_info = replace(footer_info, 'P28', dataToFillAbogadoRecord.ext), signing_info = replace(signing_info, 'P28', dataToFillAbogadoRecord.ext),
						footer_page = replace(footer_page, 'P28', dataToFillAbogadoRecord.ext), aux_1 = replace(aux_1, 'P28', dataToFillAbogadoRecord.ext),
						aux_2 = replace(aux_2, 'P28', dataToFillAbogadoRecord.ext), aux_3 = replace(aux_3, 'P28', dataToFillAbogadoRecord.ext),
						aux_4 = replace(aux_4, 'P28', dataToFillAbogadoRecord.ext), aux_5 = replace(aux_5, 'P28', dataToFillAbogadoRecord.ext)
						WHERE id = resultId;

			 UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P29', dataToFillAbogadoRecord.email), initial_info = replace(initial_info, 'P29', dataToFillAbogadoRecord.email),
						footer_info = replace(footer_info, 'P29', dataToFillAbogadoRecord.email), signing_info = replace(signing_info, 'P29', dataToFillAbogadoRecord.email),
						footer_page = replace(footer_page, 'P29', dataToFillAbogadoRecord.email), aux_1 = replace(aux_1, 'P29', dataToFillAbogadoRecord.email),
						aux_2 = replace(aux_2, 'P29', dataToFillAbogadoRecord.email), aux_3 = replace(aux_3, 'P29', dataToFillAbogadoRecord.email),
						aux_4 = replace(aux_4, 'P29', dataToFillAbogadoRecord.email), aux_5 = replace(aux_5, 'P29', dataToFillAbogadoRecord.email)
						WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P30', dataToFillAbogadoRecord.celular), initial_info = replace(initial_info, 'P30', dataToFillAbogadoRecord.celular),
					footer_info = replace(footer_info, 'P30', dataToFillAbogadoRecord.celular), signing_info = replace(signing_info, 'P30', dataToFillAbogadoRecord.celular),
					footer_page = replace(footer_page, 'P30', dataToFillAbogadoRecord.celular), aux_1 = replace(aux_1, 'P30', dataToFillAbogadoRecord.celular),
					aux_2 = replace(aux_2, 'P30', dataToFillAbogadoRecord.celular), aux_3 = replace(aux_3, 'P30', dataToFillAbogadoRecord.celular),
					aux_4 = replace(aux_4, 'P30', dataToFillAbogadoRecord.celular), aux_5 = replace(aux_5, 'P30', dataToFillAbogadoRecord.celular)
					WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P31', dataToFillAbogadoRecord.tarjeta_profesional), initial_info = replace(initial_info, 'P31', dataToFillAbogadoRecord.tarjeta_profesional),
					footer_info = replace(footer_info, 'P31', dataToFillAbogadoRecord.tarjeta_profesional), signing_info = replace(signing_info, 'P31', dataToFillAbogadoRecord.tarjeta_profesional),
					footer_page = replace(footer_page, 'P31', dataToFillAbogadoRecord.tarjeta_profesional), aux_1 = replace(aux_1, 'P31', dataToFillAbogadoRecord.tarjeta_profesional),
					aux_2 = replace(aux_2, 'P31', dataToFillAbogadoRecord.tarjeta_profesional), aux_3 = replace(aux_3, 'P31', dataToFillAbogadoRecord.tarjeta_profesional),
					aux_4 = replace(aux_4, 'P31', dataToFillAbogadoRecord.tarjeta_profesional), aux_5 = replace(aux_5, 'P31', dataToFillAbogadoRecord.tarjeta_profesional)
					WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P32', dataToFillDocsRecord.tipo_identificacion), initial_info = replace(initial_info, 'P32', dataToFillDocsRecord.tipo_identificacion),
						footer_info = replace(footer_info, 'P32', dataToFillDocsRecord.tipo_identificacion), signing_info = replace(signing_info, 'P32', dataToFillDocsRecord.tipo_identificacion),
						footer_page = replace(footer_page, 'P32', dataToFillDocsRecord.tipo_identificacion), aux_1 = replace(aux_1, 'P32', dataToFillDocsRecord.tipo_identificacion),
						aux_2 = replace(aux_2, 'P32', dataToFillDocsRecord.tipo_identificacion), aux_3 = replace(aux_3, 'P32', dataToFillDocsRecord.tipo_identificacion),
						aux_4 = replace(aux_4, 'P32', dataToFillDocsRecord.tipo_identificacion), aux_5 = replace(aux_5, 'P32', dataToFillDocsRecord.tipo_identificacion)
						WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P33', dataToFillDocsRecord.identificacion), initial_info = replace(initial_info, 'P33', dataToFillDocsRecord.identificacion),
						footer_info = replace(footer_info, 'P33', dataToFillDocsRecord.identificacion), signing_info = replace(signing_info, 'P33', dataToFillDocsRecord.identificacion),
						footer_page = replace(footer_page, 'P33', dataToFillDocsRecord.identificacion), aux_1 = replace(aux_1, 'P33', dataToFillDocsRecord.identificacion),
						aux_2 = replace(aux_2, 'P33', dataToFillDocsRecord.identificacion), aux_3 = replace(aux_3, 'P33', dataToFillDocsRecord.identificacion),
						aux_4 = replace(aux_4, 'P33', dataToFillDocsRecord.identificacion), aux_5 = replace(aux_5, 'P33', dataToFillDocsRecord.identificacion)
						WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P34', dataToFillDocsRecord.nombre), initial_info = replace(initial_info, 'P34', dataToFillDocsRecord.nombre),
						footer_info = replace(footer_info, 'P34', dataToFillDocsRecord.nombre), signing_info = replace(signing_info, 'P34', dataToFillDocsRecord.nombre),
						footer_page = replace(footer_page, 'P34', dataToFillDocsRecord.nombre), aux_1 = replace(aux_1, 'P34', dataToFillDocsRecord.nombre),
						aux_2 = replace(aux_2, 'P34', dataToFillDocsRecord.nombre), aux_3 = replace(aux_3, 'P34', dataToFillDocsRecord.nombre),
						aux_4 = replace(aux_4, 'P34', dataToFillDocsRecord.nombre), aux_5 = replace(aux_5, 'P34', dataToFillDocsRecord.nombre)
						WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P35', dataToFillDocsRecord.ciudad_exped), initial_info = replace(initial_info, 'P35', dataToFillDocsRecord.ciudad_exped),
						footer_info = replace(footer_info, 'P35', dataToFillDocsRecord.ciudad_exped), signing_info = replace(signing_info, 'P35', dataToFillDocsRecord.ciudad_exped),
						footer_page = replace(footer_page, 'P35', dataToFillDocsRecord.ciudad_exped), aux_1 = replace(aux_1, 'P35', dataToFillDocsRecord.ciudad_exped),
						aux_2 = replace(aux_2, 'P35', dataToFillDocsRecord.ciudad_exped), aux_3 = replace(aux_3, 'P35', dataToFillDocsRecord.ciudad_exped),
						aux_4 = replace(aux_4, 'P35', dataToFillDocsRecord.ciudad_exped), aux_5 = replace(aux_5, 'P35', dataToFillDocsRecord.ciudad_exped)
						WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P36', dataToFillDocsRecord.direccion), initial_info = replace(initial_info, 'P36', dataToFillDocsRecord.direccion),
				footer_info = replace(footer_info, 'P36', dataToFillDocsRecord.direccion), signing_info = replace(signing_info, 'P36', dataToFillDocsRecord.direccion),
				footer_page = replace(footer_page, 'P36', dataToFillDocsRecord.direccion), aux_1 = replace(aux_1, 'P36', dataToFillDocsRecord.direccion),
				aux_2 = replace(aux_2, 'P36', dataToFillDocsRecord.direccion), aux_3 = replace(aux_3, 'P36', dataToFillDocsRecord.direccion),
				aux_4 = replace(aux_4, 'P36', dataToFillDocsRecord.direccion), aux_5 = replace(aux_5, 'P36', dataToFillDocsRecord.direccion)
				WHERE id = resultId;


			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P37', dataToFillDocsRecord.departamento), initial_info = replace(initial_info, 'P37', dataToFillDocsRecord.departamento),
				footer_info = replace(footer_info, 'P37', dataToFillDocsRecord.departamento), signing_info = replace(signing_info, 'P37', dataToFillDocsRecord.departamento),
				footer_page = replace(footer_page, 'P37', dataToFillDocsRecord.departamento), aux_1 = replace(aux_1, 'P37', dataToFillDocsRecord.departamento),
				aux_2 = replace(aux_2, 'P37', dataToFillDocsRecord.departamento), aux_3 = replace(aux_3, 'P37', dataToFillDocsRecord.departamento),
				aux_4 = replace(aux_4, 'P37', dataToFillDocsRecord.departamento), aux_5 = replace(aux_5, 'P37', dataToFillDocsRecord.departamento)
				WHERE id = resultId;


			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P38', dataToFillDocsRecord.ciudad), initial_info = replace(initial_info, 'P38', dataToFillDocsRecord.ciudad),
				footer_info = replace(footer_info, 'P38', dataToFillDocsRecord.ciudad), signing_info = replace(signing_info, 'P38', dataToFillDocsRecord.ciudad),
				footer_page = replace(footer_page, 'P38', dataToFillDocsRecord.ciudad), aux_1 = replace(aux_1, 'P38', dataToFillDocsRecord.ciudad),
				aux_2 = replace(aux_2, 'P38', dataToFillDocsRecord.ciudad), aux_3 = replace(aux_3, 'P38', dataToFillDocsRecord.ciudad),
				aux_4 = replace(aux_4, 'P38', dataToFillDocsRecord.ciudad), aux_5 = replace(aux_5, 'P38', dataToFillDocsRecord.ciudad)
				WHERE id = resultId;


			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P39', dataToFillDocsRecord.telefono), initial_info = replace(initial_info, 'P39', dataToFillDocsRecord.telefono),
				footer_info = replace(footer_info, 'P39', dataToFillDocsRecord.telefono), signing_info = replace(signing_info, 'P39', dataToFillDocsRecord.telefono),
				footer_page = replace(footer_page, 'P39', dataToFillDocsRecord.telefono), aux_1 = replace(aux_1, 'P39', dataToFillDocsRecord.telefono),
				aux_2 = replace(aux_2, 'P39', dataToFillDocsRecord.telefono), aux_3 = replace(aux_3, 'P39', dataToFillDocsRecord.telefono),
				aux_4 = replace(aux_4, 'P39', dataToFillDocsRecord.telefono), aux_5 = replace(aux_5, 'P39', dataToFillDocsRecord.telefono)
				WHERE id = resultId;


			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P40', dataToFillDocsRecord.ext), initial_info = replace(initial_info, 'P40', dataToFillDocsRecord.ext),
				footer_info = replace(footer_info, 'P40', dataToFillDocsRecord.ext), signing_info = replace(signing_info, 'P40', dataToFillDocsRecord.ext),
				footer_page = replace(footer_page, 'P40', dataToFillDocsRecord.ext), aux_1 = replace(aux_1, 'P40', dataToFillDocsRecord.ext),
				aux_2 = replace(aux_2, 'P40', dataToFillDocsRecord.ext), aux_3 = replace(aux_3, 'P40', dataToFillDocsRecord.ext),
				aux_4 = replace(aux_4, 'P40', dataToFillDocsRecord.ext), aux_5 = replace(aux_5, 'P40', dataToFillDocsRecord.ext)
				WHERE id = resultId;


			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P41', dataToFillDocsRecord.email), initial_info = replace(initial_info, 'P41', dataToFillDocsRecord.email),
				footer_info = replace(footer_info, 'P41', dataToFillDocsRecord.email), signing_info = replace(signing_info, 'P41', dataToFillDocsRecord.email),
				footer_page = replace(footer_page, 'P41', dataToFillDocsRecord.email), aux_1 = replace(aux_1, 'P41', dataToFillDocsRecord.email),
				aux_2 = replace(aux_2, 'P41', dataToFillDocsRecord.email), aux_3 = replace(aux_3, 'P41', dataToFillDocsRecord.email),
				aux_4 = replace(aux_4, 'P41', dataToFillDocsRecord.email), aux_5 = replace(aux_5, 'P41', dataToFillDocsRecord.email)
				WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P42', dataToFillDocsRecord.celular), initial_info = replace(initial_info, 'P42', dataToFillDocsRecord.celular),
				footer_info = replace(footer_info, 'P42', dataToFillDocsRecord.celular), signing_info = replace(signing_info, 'P42', dataToFillDocsRecord.celular),
				footer_page = replace(footer_page, 'P42', dataToFillDocsRecord.celular), aux_1 = replace(aux_1, 'P42', dataToFillDocsRecord.celular),
				aux_2 = replace(aux_2, 'P42', dataToFillDocsRecord.celular), aux_3 = replace(aux_3, 'P42', dataToFillDocsRecord.celular),
				aux_4 = replace(aux_4, 'P42', dataToFillDocsRecord.celular), aux_5 = replace(aux_5, 'P42', dataToFillDocsRecord.celular)
				WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P43', dataToFillDocsRecord.nombre_empresa), initial_info = replace(initial_info, 'P43', dataToFillDocsRecord.nombre_empresa),
				footer_info = replace(footer_info, 'P43', dataToFillDocsRecord.nombre_empresa), signing_info = replace(signing_info, 'P43', dataToFillDocsRecord.nombre_empresa),
				footer_page = replace(footer_page, 'P43', dataToFillDocsRecord.nombre_empresa), aux_1 = replace(aux_1, 'P43', dataToFillDocsRecord.nombre_empresa),
				aux_2 = replace(aux_2, 'P43', dataToFillDocsRecord.nombre_empresa), aux_3 = replace(aux_3, 'P43', dataToFillDocsRecord.nombre_empresa),
				aux_4 = replace(aux_4, 'P43', dataToFillDocsRecord.nombre_empresa), aux_5 = replace(aux_5, 'P43', dataToFillDocsRecord.nombre_empresa)
				WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P44', dataToFillDocsRecord.fecha_negocio), initial_info = replace(initial_info, 'P44', dataToFillDocsRecord.fecha_negocio),
				footer_info = replace(footer_info, 'P44', dataToFillDocsRecord.fecha_negocio), signing_info = replace(signing_info, 'P44', dataToFillDocsRecord.fecha_negocio),
				footer_page = replace(footer_page, 'P44', dataToFillDocsRecord.fecha_negocio), aux_1 = replace(aux_1, 'P44', dataToFillDocsRecord.fecha_negocio),
				aux_2 = replace(aux_2, 'P44', dataToFillDocsRecord.fecha_negocio), aux_3 = replace(aux_3, 'P44', dataToFillDocsRecord.fecha_negocio),
				aux_4 = replace(aux_4, 'P44', dataToFillDocsRecord.fecha_negocio), aux_5 = replace(aux_5, 'P44', dataToFillDocsRecord.fecha_negocio)
				WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P45', dataToFillDocsRecord.num_pagare), initial_info = replace(initial_info, 'P45', dataToFillDocsRecord.num_pagare),
				footer_info = replace(footer_info, 'P45', dataToFillDocsRecord.num_pagare), signing_info = replace(signing_info, 'P45', dataToFillDocsRecord.num_pagare),
				footer_page = replace(footer_page, 'P45', dataToFillDocsRecord.num_pagare), aux_1 = replace(aux_1, 'P45', dataToFillDocsRecord.num_pagare),
				aux_2 = replace(aux_2, 'P45', dataToFillDocsRecord.num_pagare), aux_3 = replace(aux_3, 'P45', dataToFillDocsRecord.num_pagare),
				aux_4 = replace(aux_4, 'P45', dataToFillDocsRecord.num_pagare), aux_5 = replace(aux_5, 'P45', dataToFillDocsRecord.num_pagare)
				WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P46', sp_convertNumberToWords(_valorsaldo)), initial_info = replace(initial_info, 'P46', sp_convertNumberToWords(_valorsaldo)),
				footer_info = replace(footer_info, 'P46', sp_convertNumberToWords(_valorsaldo)), signing_info = replace(signing_info, 'P46', sp_convertNumberToWords(_valorsaldo)),
				footer_page = replace(footer_page, 'P46', sp_convertNumberToWords(_valorsaldo)), aux_1 = replace(aux_1, 'P46', sp_convertNumberToWords(_valorsaldo)),
				aux_2 = replace(aux_2, 'P46', sp_convertNumberToWords(_valorsaldo)), aux_3 = replace(aux_3, 'P46', sp_convertNumberToWords(_valorsaldo)),
				aux_4 = replace(aux_4, 'P46', sp_convertNumberToWords(_valorsaldo)), aux_5 = replace(aux_5, 'P46', sp_convertNumberToWords(_valorsaldo))
				WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P47', to_char(_valorsaldo,'LFM9,999,999,999.00')), initial_info = replace(initial_info, 'P47', to_char(_valorsaldo,'LFM9,999,999,999.00')),
				footer_info = replace(footer_info, 'P47', to_char(_valorsaldo,'LFM9,999,999,999.00')), signing_info = replace(signing_info, 'P47', to_char(_valorsaldo,'LFM9,999,999,999.00')),
				footer_page = replace(footer_page, 'P47', to_char(_valorsaldo,'LFM9,999,999,999.00')), aux_1 = replace(aux_1, 'P47', to_char(_valorsaldo,'LFM9,999,999,999.00')),
				aux_2 = replace(aux_2, 'P47', to_char(_valorsaldo,'LFM9,999,999,999.00')), aux_3 = replace(aux_3, 'P47', to_char(_valorsaldo,'LFM9,999,999,999.00')),
				aux_4 = replace(aux_4, 'P47', to_char(_valorsaldo,'LFM9,999,999,999.00')), aux_5 = replace(aux_5, 'P47', to_char(_valorsaldo,'LFM9,999,999,999.00'))
				WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P48', sp_convertNumberToWords(dataToFillDocsRecord.vr_negocio)), initial_info = replace(initial_info, 'P48', sp_convertNumberToWords(dataToFillDocsRecord.vr_negocio)),
				footer_info = replace(footer_info, 'P48', sp_convertNumberToWords(dataToFillDocsRecord.vr_negocio)), signing_info = replace(signing_info, 'P48', sp_convertNumberToWords(dataToFillDocsRecord.vr_negocio)),
				footer_page = replace(footer_page, 'P48', sp_convertNumberToWords(dataToFillDocsRecord.vr_negocio)), aux_1 = replace(aux_1, 'P48', sp_convertNumberToWords(dataToFillDocsRecord.vr_negocio)),
				aux_2 = replace(aux_2, 'P48', sp_convertNumberToWords(dataToFillDocsRecord.vr_negocio)), aux_3 = replace(aux_3, 'P48', sp_convertNumberToWords(dataToFillDocsRecord.vr_negocio)),
				aux_4 = replace(aux_4, 'P48', sp_convertNumberToWords(dataToFillDocsRecord.vr_negocio)), aux_5 = replace(aux_5, 'P48', sp_convertNumberToWords(dataToFillDocsRecord.vr_negocio))
				WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P49', to_char(dataToFillDocsRecord.vr_negocio,'LFM9,999,999,999.00')), initial_info = replace(initial_info, 'P49', to_char(dataToFillDocsRecord.vr_negocio,'LFM9,999,999,999.00')),
				footer_info = replace(footer_info, 'P49', to_char(dataToFillDocsRecord.vr_negocio,'LFM9,999,999,999.00')), signing_info = replace(signing_info, 'P49', to_char(dataToFillDocsRecord.vr_negocio,'LFM9,999,999,999.00')),
				footer_page = replace(footer_page, 'P49', to_char(dataToFillDocsRecord.vr_negocio,'LFM9,999,999,999.00')), aux_1 = replace(aux_1, 'P49', to_char(_valorsaldo,'LFM9,999,999,999.00')),
				aux_2 = replace(aux_2, 'P49', to_char(dataToFillDocsRecord.vr_negocio,'LFM9,999,999,999.00')), aux_3 = replace(aux_3, 'P49', to_char(dataToFillDocsRecord.vr_negocio,'LFM9,999,999,999.00')),
				aux_4 = replace(aux_4, 'P49', to_char(dataToFillDocsRecord.vr_negocio,'LFM9,999,999,999.00')), aux_5 = replace(aux_5, 'P49', to_char(dataToFillDocsRecord.vr_negocio,'LFM9,999,999,999.00'))
				WHERE id = resultId;


			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P50', sp_convertNumberToWords(dataToFillDocsRecord.vr_desembolso)), initial_info = replace(initial_info, 'P50', sp_convertNumberToWords(dataToFillDocsRecord.vr_desembolso)),
				footer_info = replace(footer_info, 'P50', sp_convertNumberToWords(dataToFillDocsRecord.vr_desembolso)), signing_info = replace(signing_info, 'P50', sp_convertNumberToWords(dataToFillDocsRecord.vr_desembolso)),
				footer_page = replace(footer_page, 'P50', sp_convertNumberToWords(dataToFillDocsRecord.vr_desembolso)), aux_1 = replace(aux_1, 'P50', sp_convertNumberToWords(dataToFillDocsRecord.vr_desembolso)),
				aux_2 = replace(aux_2, 'P50', sp_convertNumberToWords(dataToFillDocsRecord.vr_desembolso)), aux_3 = replace(aux_3, 'P50', sp_convertNumberToWords(dataToFillDocsRecord.vr_desembolso)),
				aux_4 = replace(aux_4, 'P50', sp_convertNumberToWords(dataToFillDocsRecord.vr_desembolso)), aux_5 = replace(aux_5, 'P50', sp_convertNumberToWords(dataToFillDocsRecord.vr_desembolso))
				WHERE id = resultId;

			 UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P51',to_char(dataToFillDocsRecord.vr_desembolso,'LFM9,999,999,999.00')), initial_info = replace(initial_info, 'P51', to_char(dataToFillDocsRecord.vr_desembolso,'LFM9,999,999,999.00')),
				footer_info = replace(footer_info, 'P51', to_char(dataToFillDocsRecord.vr_desembolso,'LFM9,999,999,999.00')), signing_info = replace(signing_info, 'P51', to_char(dataToFillDocsRecord.vr_desembolso,'LFM9,999,999,999.00')),
				footer_page = replace(footer_page, 'P51', to_char(dataToFillDocsRecord.vr_desembolso,'LFM9,999,999,999.00')), aux_1 = replace(aux_1, 'P51', to_char(dataToFillDocsRecord.vr_desembolso,'LFM9,999,999,999.00')),
				aux_2 = replace(aux_2, 'P51', to_char(dataToFillDocsRecord.vr_desembolso,'LFM9,999,999,999.00')), aux_3 = replace(aux_3, 'P51', to_char(dataToFillDocsRecord.vr_desembolso,'LFM9,999,999,999.00')),
				aux_4 = replace(aux_4, 'P51', to_char(dataToFillDocsRecord.vr_desembolso,'LFM9,999,999,999.00')), aux_5 = replace(aux_5, 'P51', to_char(dataToFillDocsRecord.vr_desembolso,'LFM9,999,999,999.00'))
				WHERE id = resultId;

		        UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P52', upper(dataToFillDocsRecord.tipo_proceso)), initial_info = replace(initial_info, 'P52', dataToFillDocsRecord.tipo_proceso),
				footer_info = replace(footer_info, 'P52', dataToFillDocsRecord.tipo_proceso), signing_info = replace(signing_info, 'P52', dataToFillDocsRecord.tipo_proceso),
				footer_page = replace(footer_page, 'P52', dataToFillDocsRecord.tipo_proceso), aux_1 = replace(aux_1, 'P52', dataToFillDocsRecord.tipo_proceso),
				aux_2 = replace(aux_2, 'P52', dataToFillDocsRecord.tipo_proceso), aux_3 = replace(aux_3, 'P52', dataToFillDocsRecord.tipo_proceso),
				aux_4 = replace(aux_4, 'P52', dataToFillDocsRecord.tipo_proceso), aux_5 = replace(aux_5, 'P52', dataToFillDocsRecord.tipo_proceso)
				WHERE id = resultId;



			--Actualizamos detalle documentos
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P01', dataToFillEmpresaRecord.identificacion) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P02', dataToFillEmpresaRecord.nombre) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P03', dataToFillEmpresaRecord.direccion) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P04', dataToFillEmpresaRecord.departamento) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P05', dataToFillEmpresaRecord.ciudad) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P06', dataToFillEmpresaRecord.telefono) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P07', dataToFillEmpresaRecord.ext) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P08', dataToFillEmpresaRecord.email) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P09',  dataToFillRepLegalRecord.tipo_identificacion) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P10', dataToFillRepLegalRecord.identificacion) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P11', dataToFillRepLegalRecord.nombre) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P12', dataToFillRepLegalRecord.lugar_exped) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P13', dataToFillRepLegalRecord.direccion) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P14', dataToFillRepLegalRecord.departamento) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P15', dataToFillRepLegalRecord.ciudad) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P16', dataToFillRepLegalRecord.telefono) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P17', dataToFillRepLegalRecord.ext) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P18', dataToFillRepLegalRecord.email) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P19', dataToFillRepLegalRecord.celular) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P20', dataToFillAbogadoRecord.tipo_identificacion) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P21', dataToFillAbogadoRecord.identificacion) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P22', dataToFillAbogadoRecord.nombre) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P23', dataToFillAbogadoRecord.lugar_exped) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P24', dataToFillAbogadoRecord.direccion) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P25', dataToFillAbogadoRecord.departamento) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P26', dataToFillAbogadoRecord.ciudad) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P27', dataToFillAbogadoRecord.telefono) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P28', dataToFillAbogadoRecord.ext) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P29', dataToFillAbogadoRecord.email) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P30', dataToFillAbogadoRecord.celular) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P31', dataToFillAbogadoRecord.tarjeta_profesional) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P32', dataToFillDocsRecord.tipo_identificacion) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P33', dataToFillDocsRecord.identificacion) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P34', dataToFillDocsRecord.nombre) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P35', dataToFillDocsRecord.ciudad_exped) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P36', dataToFillDocsRecord.direccion) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P37', dataToFillDocsRecord.departamento) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P38', dataToFillDocsRecord.ciudad) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P39', dataToFillDocsRecord.telefono) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P40', dataToFillDocsRecord.ext) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P41', dataToFillDocsRecord.email) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P42', dataToFillDocsRecord.celular) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P43', dataToFillDocsRecord.nombre_empresa) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P44', dataToFillDocsRecord.fecha_negocio) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P45', dataToFillDocsRecord.num_pagare) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P46', sp_convertNumberToWords(_valorsaldo)) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P47', to_char(_valorsaldo,'LFM9,999,999,999.00')) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P48', sp_convertNumberToWords(dataToFillDocsRecord.vr_negocio)) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P49', to_char(dataToFillDocsRecord.vr_negocio,'LFM9,999,999,999.00')) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P50', sp_convertNumberToWords(dataToFillDocsRecord.vr_desembolso)) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P51', to_char(dataToFillDocsRecord.vr_desembolso,'LFM9,999,999,999.00')) WHERE id_demanda_doc = resultId;
                        UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P52', dataToFillDocsRecord.tipo_proceso) WHERE id_demanda_doc = resultId;

                         --Obtenemos datos del codeudor si lo tiene
			select into dataToFillCodeudorRecord    tgen.referencia as tipo_identificacion, replace(to_char(sp.identificacion::BIGINT,'FM999,999,999,999,999'),',','.') as identificacion,
								sp.primer_nombre||' '||sp.segundo_nombre||' '||sp.primer_apellido||' '||sp.segundo_apellido as nombre,  depexp.department_name as departamento_exped,
								ciuexp.nomciu as ciudad_exped, sp.genero, dep.department_name as departamento, ciu.nomciu as ciudad, sp.direccion, sp.barrio, sp.telefono,
								''::character varying as  ext, coalesce(sp.celular,'') as celular, coalesce(sp.email,'') as email, coalesce(sl.nombre_empresa,'') as nombre_empresa,
								CASE WHEN sp.genero = 'F' THEN 'la señora ' ELSE 'el señor ' END AS tipo_persona
								from solicitud_aval s
								INNER JOIN solicitud_persona sp ON sp.numero_solicitud = s.numero_solicitud AND sp.reg_status='' AND sp.tipo in('C','E')
								LEFT JOIN solicitud_laboral sl ON sl.numero_solicitud =  s.numero_solicitud AND sl.tipo = sp.tipo AND sl.reg_status = ''
								INNER JOIN tablagen tgen ON tgen.table_code = sp.tipo_id AND table_type in ('TIPID')
								INNER JOIN ciudad ciu ON ciu.codciu = sp.ciudad
								INNER JOIN ciudad ciuexp ON ciuexp.codciu = sp.ciudad_expedicion_id
								INNER JOIN estado dep ON dep.department_code = ciu.coddpt
								INNER JOIN estado depexp ON depexp.department_code = ciuexp.coddpt
								WHERE (s.cod_neg= codigo_negocio) AND s.reg_status='' ORDER BY sp.tipo LIMIT 1;


			IF FOUND THEN

                                idcodeudor:= 'Y '||dataToFillCodeudorRecord.nombre||' (C.C. '||dataToFillCodeudorRecord.identificacion||')';
	                        notifcodeudor:= ', y '||dataToFillCodeudorRecord.tipo_persona||' '||dataToFillCodeudorRecord.nombre||', en la '||dataToFillCodeudorRecord.direccion||', en '||dataToFillCodeudorRecord.ciudad||', cel. '||dataToFillCodeudorRecord.celular||', correo electrónico '||dataToFillCodeudorRecord.email;
                                infocodeudor:= ' y '||dataToFillCodeudorRecord.nombre||', mayor de edad y vecino de Barranquilla, identificado con '||dataToFillCodeudorRecord.tipo_identificacion||' No. '||dataToFillCodeudorRecord.identificacion;


				UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P53', dataToFillCodeudorRecord.tipo_identificacion), initial_info = replace(initial_info, 'P53', dataToFillCodeudorRecord.tipo_identificacion),
					footer_info = replace(footer_info, 'P53', dataToFillCodeudorRecord.tipo_identificacion), signing_info = replace(signing_info, 'P53', dataToFillCodeudorRecord.tipo_identificacion),
					footer_page = replace(footer_page, 'P53', dataToFillCodeudorRecord.tipo_identificacion), aux_1 = replace(aux_1, 'P53', dataToFillCodeudorRecord.tipo_identificacion),
					aux_2 = replace(aux_2, 'P53', dataToFillCodeudorRecord.tipo_identificacion), aux_3 = replace(aux_3, 'P53', dataToFillCodeudorRecord.tipo_identificacion),
					aux_4 = replace(aux_4, 'P53', dataToFillCodeudorRecord.tipo_identificacion), aux_5 = replace(aux_5, 'P53', dataToFillCodeudorRecord.tipo_identificacion)
					WHERE id = resultId;

				UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P54', dataToFillCodeudorRecord.identificacion), initial_info = replace(initial_info, 'P54', dataToFillCodeudorRecord.identificacion),
							footer_info = replace(footer_info, 'P54', dataToFillCodeudorRecord.identificacion), signing_info = replace(signing_info, 'P54', dataToFillCodeudorRecord.identificacion),
							footer_page = replace(footer_page, 'P54', dataToFillCodeudorRecord.identificacion), aux_1 = replace(aux_1, 'P54', dataToFillCodeudorRecord.identificacion),
							aux_2 = replace(aux_2, 'P54', dataToFillCodeudorRecord.identificacion), aux_3 = replace(aux_3, 'P54', dataToFillCodeudorRecord.identificacion),
							aux_4 = replace(aux_4, 'P54', dataToFillCodeudorRecord.identificacion), aux_5 = replace(aux_5, 'P54', dataToFillCodeudorRecord.identificacion)
							WHERE id = resultId;

				UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P55', ' y '||dataToFillCodeudorRecord.nombre), initial_info = replace(initial_info, 'P55', ' y '||dataToFillCodeudorRecord.nombre),
							footer_info = replace(footer_info, 'P55', ' y '||dataToFillCodeudorRecord.nombre), signing_info = replace(signing_info, 'P55', ' y '||dataToFillCodeudorRecord.nombre),
							footer_page = replace(footer_page, 'P55', ' y '||dataToFillCodeudorRecord.nombre), aux_1 = replace(aux_1, 'P55', ' y '||dataToFillCodeudorRecord.nombre),
							aux_2 = replace(aux_2, 'P55', ' y '||dataToFillCodeudorRecord.nombre), aux_3 = replace(aux_3, 'P55', ' y '||dataToFillCodeudorRecord.nombre),
							aux_4 = replace(aux_4, 'P55', ' y '||dataToFillCodeudorRecord.nombre), aux_5 = replace(aux_5, 'P55', ' y '||dataToFillCodeudorRecord.nombre)
							WHERE id = resultId;

				UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P56', dataToFillCodeudorRecord.ciudad_exped), initial_info = replace(initial_info, 'P56', dataToFillCodeudorRecord.ciudad_exped),
							footer_info = replace(footer_info, 'P56', dataToFillCodeudorRecord.ciudad_exped), signing_info = replace(signing_info, 'P56', dataToFillCodeudorRecord.ciudad_exped),
							footer_page = replace(footer_page, 'P56', dataToFillCodeudorRecord.ciudad_exped), aux_1 = replace(aux_1, 'P56', dataToFillCodeudorRecord.ciudad_exped),
							aux_2 = replace(aux_2, 'P56', dataToFillCodeudorRecord.ciudad_exped), aux_3 = replace(aux_3, 'P56', dataToFillCodeudorRecord.ciudad_exped),
							aux_4 = replace(aux_4, 'P56', dataToFillCodeudorRecord.ciudad_exped), aux_5 = replace(aux_5, 'P56', dataToFillCodeudorRecord.ciudad_exped)
							WHERE id = resultId;

				UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P57', idcodeudor), initial_info = replace(initial_info, 'P57', idcodeudor),
											footer_info = replace(footer_info, 'P57', idcodeudor), signing_info = replace(signing_info, 'P57', idcodeudor),
											footer_page = replace(footer_page, 'P57', idcodeudor), aux_1 = replace(aux_1, 'P57', idcodeudor),
											aux_2 = replace(aux_2, 'P57', idcodeudor), aux_3 = replace(aux_3, 'P57', idcodeudor),
											aux_4 = replace(aux_4, 'P57', idcodeudor), aux_5 = replace(aux_5, 'P57', idcodeudor)
											WHERE id = resultId;

				UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P58', notifcodeudor), initial_info = replace(initial_info, 'P58', notifcodeudor),
											footer_info = replace(footer_info, 'P58', notifcodeudor), signing_info = replace(signing_info, 'P58', notifcodeudor),
											footer_page = replace(footer_page, 'P58', notifcodeudor), aux_1 = replace(aux_1, 'P58', notifcodeudor),
											aux_2 = replace(aux_2, 'P58', notifcodeudor), aux_3 = replace(aux_3, 'P58', notifcodeudor),
											aux_4 = replace(aux_4, 'P58', notifcodeudor), aux_5 = replace(aux_5, 'P58', notifcodeudor)
											WHERE id = resultId;

				UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P59', infocodeudor), initial_info = replace(initial_info, 'P59', infocodeudor),
											footer_info = replace(footer_info, 'P59', infocodeudor), signing_info = replace(signing_info, 'P59', infocodeudor),
											footer_page = replace(footer_page, 'P59', infocodeudor), aux_1 = replace(aux_1, 'P59', infocodeudor),
											aux_2 = replace(aux_2, 'P59', infocodeudor), aux_3 = replace(aux_3, 'P59', infocodeudor),
											aux_4 = replace(aux_4, 'P59', infocodeudor), aux_5 = replace(aux_5, 'P59', infocodeudor)
											WHERE id = resultId;

                                UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P53', dataToFillCodeudorRecord.tipo_identificacion) WHERE id_demanda_doc = resultId;
				UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P54', dataToFillCodeudorRecord.identificacion) WHERE id_demanda_doc = resultId;
				UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P55', ' y '||dataToFillCodeudorRecord.nombre) WHERE id_demanda_doc = resultId;
				UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P56', dataToFillCodeudorRecord.ciudad_exped) WHERE id_demanda_doc = resultId;
				UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P57', idcodeudor) WHERE id_demanda_doc = resultId;
				UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P58', notifcodeudor) WHERE id_demanda_doc = resultId;
				UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P59', infocodeudor) WHERE id_demanda_doc = resultId;

			ELSE
				UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P53', ''), initial_info = replace(initial_info, 'P53', ''),
					footer_info = replace(footer_info, 'P53', ''), signing_info = replace(signing_info, 'P53', ''),
					footer_page = replace(footer_page, 'P53', ''), aux_1 = replace(aux_1, 'P53', ''),
					aux_2 = replace(aux_2, 'P53', ''), aux_3 = replace(aux_3, 'P53', ''),
					aux_4 = replace(aux_4, 'P53', ''), aux_5 = replace(aux_5, 'P53', '')
					WHERE id = resultId;

				UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P54', ''), initial_info = replace(initial_info, 'P54', ''),
							footer_info = replace(footer_info, 'P54', ''), signing_info = replace(signing_info, 'P54', ''),
							footer_page = replace(footer_page, 'P54', ''), aux_1 = replace(aux_1, 'P54', ''),
							aux_2 = replace(aux_2, 'P54', ''), aux_3 = replace(aux_3, 'P54', ''),
							aux_4 = replace(aux_4, 'P54', ''), aux_5 = replace(aux_5, 'P54', '')
							WHERE id = resultId;

				UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P55', ''), initial_info = replace(initial_info, 'P55', ''),
							footer_info = replace(footer_info, 'P55', ''), signing_info = replace(signing_info, 'P55', ''),
							footer_page = replace(footer_page, 'P55', ''), aux_1 = replace(aux_1, 'P55', ''),
							aux_2 = replace(aux_2, 'P55', ''), aux_3 = replace(aux_3, 'P55', ''),
							aux_4 = replace(aux_4, 'P55', ''), aux_5 = replace(aux_5, 'P55', '')
							WHERE id = resultId;

				UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P56', ''), initial_info = replace(initial_info, 'P56', ''),
							footer_info = replace(footer_info, 'P56', ''), signing_info = replace(signing_info, 'P56', ''),
							footer_page = replace(footer_page, 'P56', ''), aux_1 = replace(aux_1, 'P56', ''),
							aux_2 = replace(aux_2, 'P56', ''), aux_3 = replace(aux_3, 'P56', ''),
							aux_4 = replace(aux_4, 'P56', ''), aux_5 = replace(aux_5, 'P56', '')
							WHERE id = resultId;

				UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P57', idcodeudor), initial_info = replace(initial_info, 'P57', idcodeudor),
										footer_info = replace(footer_info, 'P57', idcodeudor), signing_info = replace(signing_info, 'P57', idcodeudor),
										footer_page = replace(footer_page, 'P57', idcodeudor), aux_1 = replace(aux_1, 'P57', idcodeudor),
										aux_2 = replace(aux_2, 'P57', idcodeudor), aux_3 = replace(aux_3, 'P57', idcodeudor),
										aux_4 = replace(aux_4, 'P57', idcodeudor), aux_5 = replace(aux_5, 'P57', idcodeudor)
										WHERE id = resultId;

				UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P58', notifcodeudor), initial_info = replace(initial_info, 'P58', notifcodeudor),
														footer_info = replace(footer_info, 'P58', notifcodeudor), signing_info = replace(signing_info, 'P58', notifcodeudor),
														footer_page = replace(footer_page, 'P58', notifcodeudor), aux_1 = replace(aux_1, 'P58', notifcodeudor),
														aux_2 = replace(aux_2, 'P58', notifcodeudor), aux_3 = replace(aux_3, 'P58', notifcodeudor),
														aux_4 = replace(aux_4, 'P58', notifcodeudor), aux_5 = replace(aux_5, 'P58', notifcodeudor)
														WHERE id = resultId;

				UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P59', infocodeudor), initial_info = replace(initial_info, 'P59', infocodeudor),
											footer_info = replace(footer_info, 'P59', infocodeudor), signing_info = replace(signing_info, 'P59', infocodeudor),
											footer_page = replace(footer_page, 'P59', infocodeudor), aux_1 = replace(aux_1, 'P59', infocodeudor),
											aux_2 = replace(aux_2, 'P59', infocodeudor), aux_3 = replace(aux_3, 'P59', infocodeudor),
											aux_4 = replace(aux_4, 'P59', infocodeudor), aux_5 = replace(aux_5, 'P59', infocodeudor)
											WHERE id = resultId;


				UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P53', '') WHERE id_demanda_doc = resultId;
				UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P54', '') WHERE id_demanda_doc = resultId;
				UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P55', '') WHERE id_demanda_doc = resultId;
				UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P56', '') WHERE id_demanda_doc = resultId;
				UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P57', idcodeudor) WHERE id_demanda_doc = resultId;
				UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P58', notifcodeudor) WHERE id_demanda_doc = resultId;
				UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P59', infocodeudor) WHERE id_demanda_doc = resultId;
			END IF;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P60', sp_convertNumberToWords(_valorpretension)), initial_info = replace(initial_info, 'P60', sp_convertNumberToWords(_valorpretension)),
						footer_info = replace(footer_info, 'P60', sp_convertNumberToWords(_valorpretension)), signing_info = replace(signing_info, 'P60', sp_convertNumberToWords(_valorpretension)),
						footer_page = replace(footer_page, 'P60', sp_convertNumberToWords(_valorpretension)), aux_1 = replace(aux_1, 'P60', sp_convertNumberToWords(_valorpretension)),
						aux_2 = replace(aux_2, 'P60', sp_convertNumberToWords(_valorpretension)), aux_3 = replace(aux_3, 'P60', sp_convertNumberToWords(_valorpretension)),
						aux_4 = replace(aux_4, 'P60', sp_convertNumberToWords(_valorpretension)), aux_5 = replace(aux_5, 'P60', sp_convertNumberToWords(_valorpretension))
						WHERE id = resultId;

			 UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P61',to_char(_valorpretension,'LFM9,999,999,999.00')), initial_info = replace(initial_info, 'P61', to_char(_valorpretension,'LFM9,999,999,999.00')),
				footer_info = replace(footer_info, 'P61', to_char(_valorpretension,'LFM9,999,999,999.00')), signing_info = replace(signing_info, 'P61', to_char(_valorpretension,'LFM9,999,999,999.00')),
				footer_page = replace(footer_page, 'P61', to_char(_valorpretension,'LFM9,999,999,999.00')), aux_1 = replace(aux_1, 'P61', to_char(_valorpretension,'LFM9,999,999,999.00')),
				aux_2 = replace(aux_2, 'P61', to_char(_valorpretension,'LFM9,999,999,999.00')), aux_3 = replace(aux_3, 'P61', to_char(_valorpretension,'LFM9,999,999,999.00')),
				aux_4 = replace(aux_4, 'P61', to_char(_valorpretension,'LFM9,999,999,999.00')), aux_5 = replace(aux_5, 'P61', to_char(_valorpretension,'LFM9,999,999,999.00'))
				WHERE id = resultId;

			UPDATE administrativo.demanda_docs SET header_info = replace(header_info, 'P62', fecha_mora), initial_info = replace(initial_info, 'P62', fecha_mora),
					footer_info = replace(footer_info, 'P62', fecha_mora), signing_info = replace(signing_info, 'P62', fecha_mora),
					footer_page = replace(footer_page, 'P62', fecha_mora), aux_1 = replace(aux_1, 'P62', fecha_mora),
					aux_2 = replace(aux_2, 'P62', fecha_mora), aux_3 = replace(aux_3, 'P62', fecha_mora),
					aux_4 = replace(aux_4, 'P62', fecha_mora), aux_5 = replace(aux_5, 'P62', fecha_mora)
					WHERE id = resultId;

		        UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P60', sp_convertNumberToWords(_valorpretension)) WHERE id_demanda_doc = resultId;
			UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P61', to_char(_valorpretension,'LFM9,999,999,999.00')) WHERE id_demanda_doc = resultId;
                        UPDATE administrativo.demanda_docs_det SET descripcion = replace(descripcion, 'P62', fecha_mora) WHERE id_demanda_doc = resultId;

			END LOOP;

	END IF;

	RETURN retorno;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION administrativo.sp_creademanda(character varying, character varying, character varying, character varying, character varying)
  OWNER TO postgres;
