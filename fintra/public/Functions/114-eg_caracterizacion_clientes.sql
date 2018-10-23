-- Function: eg_caracterizacion_clientes(integer)

-- DROP FUNCTION eg_caracterizacion_clientes(integer);

CREATE OR REPLACE FUNCTION eg_caracterizacion_clientes(_unidadnegocio integer)
  RETURNS SETOF rs_clasificacion_cliente AS
$BODY$

DECLARE

 rs rs_clasificacion_cliente;
 recordNegocios record ;
 recordDeudor record;
 recordCodeudor record;
 _periodo integer:=0;
 _cuotasRestantes integer:=0;

 --DECLARAMOS EL CURSOR
 cursor_negocios CURSOR(_unidadNegocio integer, _periodo integer) FOR (SELECT
								      _unidadNegocio as id_unidad_negocio,
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
								      round(sum(valor_abono)*100/sum(valor_factura),2) as porcentaje,
								      ''::VARCHAR AS altura_mora_maxima ,
								      0.0::numeric as valor_preaprobado,
								      ''::varchar as clasificacion,
								      eg_altura_mora_periodo(fac.negasoc,_periodo,1,0) as altura_mora_actual,
								      0::integer as cuotas_xpagar,
								      0::integer as cuotas_pagadas
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
											and substring(cod_neg,1,2) IN ('FA','FB','MC','LB')
											and neg.negocio_rel_seguro='' and neg.negocio_rel_gps='' and neg.id_convenio in (select id_convenio from rel_unidadnegocio_convenios
																					 where id_unid_negocio in (select id from unidad_negocio where id = _unidadNegocio))
											group by  cod_cli
									)t on (t.negocio=n.cod_neg and n.creation_date::date=t.fecha  and t.nit=n.cod_cli)

								)neg ON  (neg.cod_neg=fac.negasoc AND neg.cod_cli=fac.nit)
								INNER JOIN cliente cl on (cl.nit= fac.nit )
								LEFT JOIN fecha_ultimo_pago_view fupview ON (fac.negasoc=fupview.negasoc )
								WHERE  fac.negasoc!=''
								AND fac.reg_status=''
								AND fac.dstrct='FINV'
								AND fac.tipo_documento='FAC'
								--AND fac.descripcion !='CXC AVAL'
								AND substring(fac.documento,1,2) not in ('CP','FF','DF')
								--AND CASE WHEN corficolombiana='S' AND endoso_fiducia ='N' THEN FALSE ELSE TRUE END
								AND (NOW()::DATE - coalesce(fupview.fecha::DATE,now()::date)) <=180 --se realiza cambio de fecha null
								GROUP BY
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
									fupview.fecha
									);


BEGIN
	/***********************************************************************************************************************************
	* Clasificacion de clientes por tipo
	*
	* -Validaciones Generales  aplicables a todos los clientes (realizadas al momento de crear el cursor)
	* 	1. Tiempo inactivo con Fintra < 6 meses
	*	2. d. A fecha de la solicitud el cliente de be estar al día con su obligación.
	*
	* -Validaciones segun la tipificacion
	*	1.)Tipo 1:
	*		a. Mora Max en su último crédito con Fintra debe ser de 30 días.
	*		b. En la fecha de la solicitud debe tener cancelado el 70% del crédito actual Ej: 4/6 o 9/12
	*		c. Se le podrá incrementar hasta el 30% del monto de su crédito actual o anterior
	*
	*	2.)Tipo 2:
	*		a. Mora Max en su último crédito con Fintra debe estar en el rango de entre 31 y 60 días.
	*		b. En la fecha de la solicitud debe tener cancelado el 70% del crédito actual Ej: 4/6 o 9/12
	*		c. Se le podrá incrementar hasta el 10% del monto de su crédito actual o anterior
	*
	*	3.)Tipo 3:
	*		a. Mora Max en su último crédito con Fintra debe estar en el rango de entre 61 y 90 días.
	*		b. En la fecha de la solicitud debe tener cancelado el 90% del crédito actual Ej: 5/6 o 11/12
	*		c. Se le podrá incrementar hasta el 0% del monto de su crédito actual o anterior
	*
	*	4.)Tipo 4:
	*		Son los clientes que le pagaron a Fintra con una mora superior a 90 días, por lo tanto serán negados de entrada.
	*
	*************************************************************************************************************************************/

	_periodo:=(SELECT REPLACE(SUBSTRING(now(),1,7),'-',''))::INTEGER;
	raise notice '_periodo: %',_periodo;
	--ABRIMOS EL CURSOR SIN PARAMETROS
	OPEN cursor_negocios(_unidadNegocio,_periodo) ;
	<<_loop>>
	LOOP
		-- FETCH FILA EN MY RECORD O TYPE
		FETCH cursor_negocios INTO recordNegocios;
		-- EXIT CUANDO NO HAY MAS FILAS
		EXIT WHEN NOT FOUND;


		--0.)CALCULAMOS EL NUMERO DE CUOTAS.
		recordNegocios.cuotas:=(SELECT count(0) FROM documentos_neg_aceptado  WHERE cod_neg =recordNegocios.negasoc AND reg_status='');

		--1.)CUOTAS VENCIDAD DEL CREDITO
		recordNegocios.cuotas_xpagar:=(SELECT count(*) FROM con.factura
						WHERE negasoc =recordNegocios.negasoc
						AND valor_saldo >0
						AND reg_status=''
						AND dstrct='FINV'
						AND tipo_documento='FAC'
						AND descripcion !='CXC AVAL'
						AND substring(documento,1,2) not in ('CP','FF','DF','CM','MI','CA')
					     );

		--2.)CUOTAS PAGADAS DE UN CREDITO
		recordNegocios.cuotas_pagadas:=recordNegocios.cuotas-recordNegocios.cuotas_xpagar;

		--3.)CALCULAMOS NUMERO DE CUOTAS RESTANTES
		_cuotasRestantes:=recordNegocios.cuotas-recordNegocios.cuotas_pagadas;

		--4.)ALTURA DE MORA MAXIMA EN TODO EL CREDITO ACTUAL (MODO 5 :SALDO > 0)
		recordNegocios.altura_mora_maxima :=(SELECT coalesce(max(sp_fecha_corte_foto(substring(periodo_lote,1,4),substring(periodo_lote,5)::integer)::date-(fecha_vencimiento)),0) as maxdia
							FROM con.foto_cartera fra
							WHERE fra.dstrct = 'FINV'
							AND fra.reg_status=''
							AND fra.valor_saldo > 0
							AND fra.negasoc = recordNegocios.negasoc
							AND fra.nit = recordNegocios.cedula_deudor
							AND fra.tipo_documento in ('FAC','NDC')
							AND substring(fra.documento,1,2) not in ('CP','FF','DF'));

		--recordNegocios.altura_mora_maxima=eg_altura_mora_periodo(recordNegocios.cedula_deudor,201412,5,0);
		--raise notice 'recordNegocios.altura_mora : % recordNegocios.cedula_deudor: %',recordNegocios.altura_mora_maxima,recordNegocios.cedula_deudor;

		--5)DEFINIMOS EL TIPO CLIENTE POR LA ALTURA DE MORA MAXIMA Y CUOTAS PAGADAS
		IF(recordNegocios.altura_mora_maxima::INTEGER <= 30 AND recordNegocios.altura_mora_actual in ('1- CORRIENTE','2- 1 A 30') AND _cuotasRestantes <=2 )THEN ---TIPO 1

			recordNegocios.clasificacion:='TIPO 1';
			recordNegocios.valor_preaprobado :=eg_valor_preaprobado(recordNegocios.vr_negocio,_unidadNegocio,recordNegocios.clasificacion);

		ELSIF((recordNegocios.altura_mora_maxima::INTEGER BETWEEN 31 AND 60) AND recordNegocios.altura_mora_actual in ('1- CORRIENTE','2- 1 A 30')  AND _cuotasRestantes <=2)THEN ---TIPO 2

			recordNegocios.clasificacion:='TIPO 2';
			recordNegocios.valor_preaprobado :=eg_valor_preaprobado(recordNegocios.vr_negocio,_unidadNegocio,recordNegocios.clasificacion);
		--(recordNegocios.altura_mora_maxima::INTEGER  BETWEEN 61 AND  90)  AND recordNegocios.altura_mora_actual='1- CORRIENTE' AND _cuotasRestantes <=1
		ELSIF((recordNegocios.altura_mora_maxima::INTEGER  BETWEEN 61 AND  90)  AND recordNegocios.altura_mora_actual IN ('1- CORRIENTE','2- 1 A 30','3- ENTRE 31 Y 60') AND _cuotasRestantes <=1)THEN ---TIPO 3

			recordNegocios.clasificacion:='TIPO 3';
			recordNegocios.valor_preaprobado :=eg_valor_preaprobado(recordNegocios.vr_negocio,_unidadNegocio,recordNegocios.clasificacion);

		ELSIF((recordNegocios.altura_mora_maxima::INTEGER  BETWEEN 61 AND  90) AND recordNegocios.altura_mora_actual NOT IN ('1- CORRIENTE','2- 1 A 30','3- ENTRE 31 Y 60')   )THEN
		         recordNegocios.clasificacion:='TIPO 4';

		ELSIF((recordNegocios.altura_mora_maxima::INTEGER > 90))THEN ---TIPO 4
			recordNegocios.clasificacion:='TIPO 4';

		ELSIF(recordNegocios.altura_mora_maxima::INTEGER <= 0 AND recordNegocios.altura_mora_actual='1- CORRIENTE' AND recordNegocios.cuotas_pagadas >= ROUND(recordNegocios.cuotas/2))THEN --P TIPO 1 mas del 50% de cuotas
			recordNegocios.clasificacion:='P TIPO 1';

		ELSIF(recordNegocios.altura_mora_maxima::INTEGER <= 30 AND recordNegocios.altura_mora_actual='1- CORRIENTE' AND recordNegocios.cuotas_pagadas >= ROUND(recordNegocios.cuotas/2))THEN --P TIPO 2 mas del 50% de cuotas
			recordNegocios.clasificacion:='P TIPO 2';

		ELSIF((recordNegocios.altura_mora_maxima::INTEGER BETWEEN 0 AND 60) AND  recordNegocios.altura_mora_actual !='1- CORRIENTE' AND  _cuotasRestantes >= ROUND(recordNegocios.cuotas/2))THEN --P TIPO 3 menos del 50% cuotas
			recordNegocios.clasificacion:='P TIPO 3';

		ELSIF((recordNegocios.altura_mora_maxima::INTEGER BETWEEN 61 AND 90) AND  recordNegocios.altura_mora_actual !='1- CORRIENTE' AND  _cuotasRestantes >=ROUND(recordNegocios.cuotas/2))THEN --P TIPO 4 menos del 50% cuotas
			recordNegocios.clasificacion:='P TIPO 4';

		ELSIF(recordNegocios.altura_mora_maxima::INTEGER <= 30 AND recordNegocios.altura_mora_actual='1- CORRIENTE' AND recordNegocios.cuotas_pagadas <= ROUND(recordNegocios.cuotas/2))THEN --CLIENTE NUEVO
			recordNegocios.clasificacion:='C NUEVO';

		ELSE
			recordNegocios.clasificacion:='SIN CRITERIOS DE TIPO PARA CLASIFICAR';
		END IF;

		recordNegocios.altura_mora_maxima:=eg_altura_mora_periodo(recordNegocios.negasoc,201412,3,recordNegocios.altura_mora_maxima::INTEGER);

		--6.)BUSCAMOS LA UNFORMACION DEL DEUDOR Y CODEUDOR

		SELECT into recordDeudor tipo,barrio,ciudad,email,telefono,celular,direccion FROM solicitud_aval sa
		inner join solicitud_persona sp on (sa.numero_solicitud=sp.numero_solicitud)
		where sa.cod_neg=recordNegocios.negasoc and id_convenio=recordNegocios.id_convenio and sp.tipo='S' ;

		SELECT into recordCodeudor identificacion,nombre,barrio,ciudad,email,telefono,celular,direccion FROM solicitud_aval sa
		inner join solicitud_persona sp on (sa.numero_solicitud=sp.numero_solicitud)
		where sa.cod_neg=recordNegocios.negasoc and id_convenio=recordNegocios.id_convenio and sp.tipo in ('E','C' );

		--6.)INFORMACION DEUDOR
		recordNegocios.barrio:=recordDeudor.barrio;
		recordNegocios.ciudad:=(SELECT nomciu from ciudad  where codciu=recordDeudor.ciudad);
		recordNegocios.email:=recordDeudor.email;
		recordNegocios.celular:=recordDeudor.celular;

		--7.)INFORMACION CODEUDOR---
		recordNegocios.cedula_codeudor:=recordCodeudor.identificacion;
		recordNegocios.nombre_codeudor:=recordCodeudor.nombre;
		recordNegocios.telefono_codeudor:=recordCodeudor.telefono;
		recordNegocios.celular_codeudor:=recordCodeudor.celular;

		rs:=recordNegocios;
		RETURN NEXT rs;

	END LOOP  _loop ;

	--CERRAMOS EL CURSOR
	CLOSE cursor_negocios;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_caracterizacion_clientes(integer)
  OWNER TO postgres;
