-- Function: dv_preaprobados_creditos()

-- DROP FUNCTION dv_preaprobados_creditos();

CREATE OR REPLACE FUNCTION dv_preaprobados_creditos()
  RETURNS SETOF dv_rs_preaprobado AS
$BODY$

DECLARE

 rs dv_rs_preaprobado;
 recordNegocios record ;
 recordDeudor record;
 recordCodeudor record;
 _periodo integer:=0;
 _nombreUnidad varchar :='';
 _cuotasRestantes integer:=0;

 --DECLARAMOS EL CURSOR
 cursor_negocios CURSOR(_periodo integer) FOR (SELECT
								      (sp_uneg_negocio(neg.cod_neg))::integer as id_unidad_negocio,
								      --(sp_uneg_negocio_name(neg.cod_neg)) as unidad_negocio,
								      _periodo as periodo,
								      fac.negasoc,
								      fac.nit as cedula_deudor,
								      cl.nomcli as nombre_deudor,
								      cl.telefono,
								      cl.telcontacto as celular,
								      cl.direccion,
								      ''::varchar as barrio,
								      ''::varchar as ciudad,
								      ''::varchar as email,
								      ''::varchar as cedula_codeudor,
								      ''::varchar as nombre_codeudor,
								      ''::varchar as telefono_codeudor,
								      ''::varchar as celular_codeudor,
								      0::integer as cuotas,
								      neg.id_convenio,
								      get_nombp(neg.nit_tercero) as afiliado,
								      eg_tipo_negocio(fac.negasoc) as tipo,
								      neg.f_desem::date as fecha_desembolso,
								      fupview.fecha as fecha_ult_pago,
								      (NOW()::DATE - fupview.fecha::date) AS dias_ultimmo_pago,
								      neg.vr_negocio,
								      sum(fac.valor_factura) as valor_factura,
								      sum(fac.valor_saldo) as valor_saldo ,
								      round(sum(valor_abono)*100/sum(valor_factura),2) as porcetaje,
								      ''::VARCHAR AS altura_mora,
								      eg_altura_mora_periodo(fac.negasoc,_periodo,1,0) as altura_mora_actual,
								      0.0::numeric as valor_preaprobado,
								      ''::varchar as responsable_cuenta,
								      0::integer as cuotas_xpagar,
								      0::integer as cuotas_pagadas,
								      --,0::integer as cuota_actual
								     (select item from documentos_neg_aceptado  where cod_neg = neg.cod_neg and replace(substring(fecha,1,7),'-','') = replace(substring(now(),1,7),'-','')) as cuota_actual
								     from con.factura fac
								inner join (
									select n.cod_cli,
									       n.cod_neg,
									       n.id_convenio,
									       n.f_desem,
									       n.vr_negocio,
									       n.nit_tercero,
									       n.estado_neg
									from negocios n
									inner join (
											SELECT cod_cli as nit, max(cod_neg) as negocio,max(creation_date::date)as fecha
											from negocios neg
											where estado_neg='T' and neg.negocio_rel=''
											and neg.negocio_rel_seguro='' and neg.negocio_rel_gps='' --and neg.id_convenio in (select id_convenio from rel_unidadnegocio_convenios
											and neg.creation_date::date >='2016-01-01'				--			 where id_unid_negocio in (select id from unidad_negocio where id = _unidadNegocio))
											group by  cod_cli
									)t on (t.negocio=n.cod_neg and n.creation_date::date=t.fecha  and t.nit=n.cod_cli)

								)neg on  (neg.cod_neg=fac.negasoc and neg.cod_cli=fac.nit)
								inner join cliente cl on (cl.nit= fac.nit )
								inner join fecha_ultimo_pago_view fupview on (fac.negasoc=fupview.negasoc)
								where  fac.negasoc!=''
								and fac.reg_status=''
								and fac.dstrct='FINV'
								and fac.tipo_documento='FAC'
								and fac.descripcion !='CXC AVAL'
								AND substring(fac.documento,1,2) not in ('CP','FF','DF')
								AND CASE WHEN corficolombiana='S' AND endoso_fiducia ='N' THEN FALSE ELSE TRUE END
								--and fac.negasoc=_negasoc --linea de prueba
								group by
									fac.negasoc,
									neg.f_desem,
									fac.nit,
									neg.vr_negocio,
									neg.id_convenio,
									neg.nit_tercero,
									cl.nomcli,
									cl.telefono,
									cl.telcontacto,
									cl.direccion,
									fupview.fecha,
									neg.cod_neg
									)
								;


BEGIN


	_periodo:=(select replace(substring(now(),1,7),'-',''))::integer;
	raise notice '_periodo: % ',_periodo;
	--PERFORM * from administrativo.preaprobados_fintra_credit where periodo=_periodo and id_unidad_negocio=_unidadNegocio;
	--IF (NOT FOUND  )THEN
		--ABRIMOS EL CURSOR SIN PARAMETROS
		OPEN cursor_negocios(_periodo) ;
		<<_loop>>
		loop
			-- FETCH FILA EN MY RECORD O TYPE
			FETCH cursor_negocios INTO recordNegocios;
			-- EXIT CUANDO NO HAY MAS FILAS
			EXIT WHEN NOT FOUND;


			raise notice 'recordNegocios.altura_mora_actual: %',recordNegocios.altura_mora_actual;

			--VALIDACIONES 	DE CARTERA AL DIA.
			IF(recordNegocios.altura_mora_actual = '1- CORRIENTE' )	THEN

				--0.)calculamos el numero de cuotas.
					--*.)CUOTAS DEL NEGOCIO
					recordNegocios.cuotas:=(SELECT count(0) from documentos_neg_aceptado  where cod_neg =recordNegocios.negasoc and reg_status='');


					--*.)CUOTAS VENCIDAD DEL CREDITO
					recordNegocios.cuotas_xpagar:=(SELECT count(*) FROM con.factura
									WHERE negasoc =recordNegocios.negasoc
									AND valor_saldo >0
									AND reg_status=''
									AND dstrct='FINV'
									AND tipo_documento='FAC'
									AND descripcion !='CXC AVAL'
									AND substring(documento,1,2) not in ('CP','FF','DF','CM','MI','CA')
									);



					--*.)CUOTAS PAGADAS DE UN CREDITO
					recordNegocios.cuotas_pagadas:=recordNegocios.cuotas-recordNegocios.cuotas_xpagar;

					--*.)CALCULAMOS NUMERO DE CUOTAS RESTANTES
					_cuotasRestantes:=recordNegocios.cuotas-recordNegocios.cuotas_pagadas;

				--1.)Validamos los creditos pagos total y fecha menor igual a 6 meses
				if(recordNegocios.porcetaje = 100.00 and recordNegocios.dias_ultimmo_pago <=180 )then

					--Buscamos la altura de mora para los negocios pagos (Negocio/cedula, periodo, Modo, diaMora)
					raise notice 'recordNegocios.negasoc: %',recordNegocios.cedula_deudor;
					recordNegocios.altura_mora=eg_altura_mora_periodo(recordNegocios.cedula_deudor,201412,6,0);--Se agrega un nuevo modo para la mora maxima del ultimo negocio

					--Validamos que la altura maxima sea 1 a 30
					raise notice 'recordNegocios.altura_moraAAAAAAAA : %',recordNegocios.altura_mora;

					if(recordNegocios.altura_mora::integer <= 30)then

						recordNegocios.altura_mora:= eg_altura_mora_periodo(recordNegocios.negasoc,201412,3,recordNegocios.altura_mora::integer);
						recordNegocios.valor_preaprobado:= eg_valor_preaprobado(recordNegocios.vr_negocio,recordNegocios.id_unidad_negocio,'PREAPROBADO');



						--buscamos la unformacion del deudor y codeudor

						SELECT into recordDeudor tipo,barrio,ciudad,email,telefono,celular,direccion, responsable_cuenta FROM solicitud_aval sa
						inner join solicitud_persona sp on (sa.numero_solicitud=sp.numero_solicitud)
						where sa.cod_neg=recordNegocios.negasoc and id_convenio=recordNegocios.id_convenio and sp.tipo='S' ;

						SELECT into recordCodeudor identificacion,nombre,barrio,ciudad,email,telefono,celular,direccion FROM solicitud_aval sa
						inner join solicitud_persona sp on (sa.numero_solicitud=sp.numero_solicitud)
						where sa.cod_neg=recordNegocios.negasoc and id_convenio=recordNegocios.id_convenio and sp.tipo in ('E','C' );

						--informacion deudor---
						recordNegocios.barrio:=recordDeudor.barrio;
						recordNegocios.ciudad:=(SELECT nomciu from ciudad  where codciu=recordDeudor.ciudad);
						recordNegocios.email:=recordDeudor.email;
						recordNegocios.celular:=recordDeudor.celular;
						recordNegocios.responsable_cuenta:=recordDeudor.responsable_cuenta;


						--informacion codeudor---
						recordNegocios.cedula_codeudor:=recordCodeudor.identificacion;
						recordNegocios.nombre_codeudor:=recordCodeudor.nombre;
						recordNegocios.telefono_codeudor:=recordCodeudor.telefono;
						recordNegocios.celular_codeudor:=recordCodeudor.celular;


						rs:=recordNegocios;
						raise notice 'rs: %',rs;
						return next rs;
						continue _loop WHEN true;

					end if;
				end if ;

				--2.)Validamos los negocios vigentes..

				 if(recordNegocios.dias_ultimmo_pago <=180 AND
						(
							((recordNegocios.cuotas BETWEEN 6 AND 8)  AND _cuotasRestantes <= 2)
								OR ((recordNegocios.cuotas between 9 AND 13) AND _cuotasRestantes <= 3)
									OR (recordNegocios.cuotas >= 14 AND _cuotasRestantes <= 4)
						) )THEN


					--Buscamos la altura de mora para los negocios vigentes (Negocio/cedula, periodo, Modo, diaMora)
					recordNegocios.altura_mora=eg_altura_mora_periodo(recordNegocios.cedula_deudor,201412,6,0);--Se agrega un nuevo modo para la mora maxima del ultimo negocio
					--recordNegocios.altura_mora:=0;
					if(recordNegocios.altura_mora::integer <= 30)then

						recordNegocios.altura_mora:= eg_altura_mora_periodo(recordNegocios.negasoc,201412,3,recordNegocios.altura_mora::integer);
						recordNegocios.valor_preaprobado:= eg_valor_preaprobado(recordNegocios.vr_negocio,recordNegocios.id_unidad_negocio,'PREAPROBADO');

						--buscamos la unformacion del deudor y codeudor

						SELECT into recordDeudor tipo,barrio,ciudad,email,telefono,celular,direccion, responsable_cuenta FROM solicitud_aval sa
						inner join solicitud_persona sp on (sa.numero_solicitud=sp.numero_solicitud)
						where sa.cod_neg=recordNegocios.negasoc and id_convenio=recordNegocios.id_convenio and sp.tipo='S' ;

						SELECT into recordCodeudor identificacion,nombre,barrio,ciudad,email,telefono,celular,direccion FROM solicitud_aval sa
						inner join solicitud_persona sp on (sa.numero_solicitud=sp.numero_solicitud)
						where sa.cod_neg=recordNegocios.negasoc and id_convenio=recordNegocios.id_convenio and sp.tipo in ('E','C' );


						--informacion deudor---
						recordNegocios.barrio:=recordDeudor.barrio;
						recordNegocios.ciudad:=(SELECT nomciu from ciudad  where codciu=recordDeudor.ciudad);
						recordNegocios.email:=recordDeudor.email;
						recordNegocios.celular:=recordDeudor.celular;
						recordNegocios.responsable_cuenta:=recordDeudor.responsable_cuenta;

						--informacion codeudor---
						recordNegocios.cedula_codeudor:=recordCodeudor.identificacion;
						recordNegocios.nombre_codeudor:=recordCodeudor.nombre;
						recordNegocios.telefono_codeudor:=recordCodeudor.telefono;
						recordNegocios.celular_codeudor:=recordCodeudor.celular;


						rs:=recordNegocios;
						return next rs;
					end if;

				end if;
			END IF;

			--raise notice 'Asesor : %',recordNegocios.responsable_cuenta;
		--rs:=recordNegocios;
		--				return next rs;
		end loop  _loop ;


		--CERRAMOS EL CURSOR
		CLOSE cursor_negocios;
	--ELSE
        /*        select into _nombreUnidad descripcion from unidad_negocio where id = _unidadNegocio;
		rs.negasoc:='YA ESTA GENERADO EL PREAPROBADO DEL MES PARA LA UNIDAD DE NEGOCIO '||_nombreUnidad||' EN EL PERIODO '||_periodo;
		rs.id_unidad_negocio:=0;
		return next rs;
	END IF;*/

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION dv_preaprobados_creditos()
  OWNER TO postgres;
