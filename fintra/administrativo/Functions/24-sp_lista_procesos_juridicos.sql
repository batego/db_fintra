-- Function: administrativo.sp_lista_procesos_juridicos(character varying)

-- DROP FUNCTION administrativo.sp_lista_procesos_juridicos(character varying);

CREATE OR REPLACE FUNCTION administrativo.sp_lista_procesos_juridicos(filtro character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE

 listaNegocios record;
 SQL TEXT;
 sumaSaldo numeric;

 _NegAval varchar := '';
 _NegSeguro varchar := '';
 _NegVehiculo varchar := '';

 BEGIN
    SQL:= 'SELECT       id_etapa::varchar,
                        cedula::varchar,
			nombre::varchar,
			ciudad::varchar,
			direccion::varchar,
			barrio::varchar ,
			telefono::varchar ,
			celular::varchar ,
			email::varchar ,
			negocio::varchar,
			id_demanda::integer,
			id_und_negocio::integer,
			und_negocio::varchar,
			id_convenio::integer,
			convenio::varchar,
			fecha_inicio::date as fecha_inicio,
			fecha_marcacion::date,
			dias_transcurridos::integer,
			num_pagare::varchar,
			niter::varchar,
			vr_negocio::numeric,
			vr_desembolso::numeric,
			vlr_saldo as valor_saldo,
			m.descripcion::varchar as mora,
			estado_cartera::varchar as estado_cartera,
			id_juzgado::integer,
			radicado::varchar,
			docs_generados::varchar

                   FROM(
			    SELECT
                                    neg.etapa_proc_ejec as id_etapa,
				    neg.cod_cli as cedula,
				    sp.nombre,
				    ciu.nomciu  as ciudad,
				    direccion,
				    barrio,
				    telefono,
				    celular,
				    email,
				    neg.cod_neg as negocio,
				    d.id as id_demanda,
				    un.id as id_und_negocio,
				    un.descripcion as und_negocio,
				    neg.id_convenio,
				    c.nombre as convenio,
				    fecha_inicio_etapa as fecha_inicio,
				    fecha_marcacion_cartera as fecha_marcacion,
				    (now()::date-fecha_inicio_etapa::date) as dias_transcurridos,
				    num_pagare,
				    get_nombp(neg.nit_tercero)  as niter,
				    vr_negocio,
				    vr_desembolso,
				    t.vlr_saldo,
				    t.rango,
				    ec.nombre as estado_cartera,
				    id_juzgado,
				    radicado,
				    docs_generados

				FROM negocios as neg
				INNER JOIN solicitud_aval s on (s.cod_neg=neg.cod_neg AND s.reg_status='''')
				INNER JOIN solicitud_persona sp ON sp.numero_solicitud = s.numero_solicitud  AND sp.reg_status='''' AND sp.tipo = ''S''
				INNER JOIN ciudad ciu ON ciu.codciu = sp.ciudad
				LEFT JOIN administrativo.demanda d ON d.negocio = neg.cod_neg
				INNER JOIN (
					SELECT  fra.nit as cedula,sum(valor_saldo) as vlr_saldo,
						CASE WHEN max(now()::date-(fecha_vencimiento)) >= 361 THEN 8
						     WHEN max(now()::date-(fecha_vencimiento)) >= 181 THEN 7
						     WHEN max(now()::date-(fecha_vencimiento)) >= 121 THEN 6
						     WHEN max(now()::date-(fecha_vencimiento)) >= 91 THEN 5
						     WHEN max(now()::date-(fecha_vencimiento)) >= 61 THEN 4
						     WHEN max(now()::date-(fecha_vencimiento)) >= 31 THEN 3
						     WHEN max(now()::date-(fecha_vencimiento)) >= 1 THEN 2
						     WHEN max(now()::date-(fecha_vencimiento)) <= 0 THEN 1
						ELSE 0 END AS rango,
						   fra.negasoc
					    FROM con.factura fra
						--INNER JOIN negocios neg on neg.cod_neg = fra.negasoc
						WHERE  fra.dstrct = ''FINV''  --AND tipo_documento= ''FAC''
						AND fra.valor_saldo > 0
						AND fra.reg_status = ''''
						AND fra.negasoc !=''''
						AND substring(fra.documento,1,2) not in (''CP'',''FF'',''DF'')
                                                AND fra.fecha_vencimiento::date < now()::date
						GROUP BY
						fra.nit,fra.negasoc
						order by fra.nit,fra.negasoc
                      ) as t ON (t.cedula=neg.cod_cli and t.negasoc=neg.cod_neg)
			INNER JOIN administrativo.rel_und_estado_cartera r  ON t.rango=r.id_intervalo_mora
			AND r.id_unidad_negocio in (SELECT id_unid_negocio FROM rel_unidadnegocio_convenios run
						    INNER JOIN unidad_negocio un on (run.id_unid_negocio=un.id)
						    WHERE ref_1= ''und_proc_ejec'' AND id_convenio=neg.id_convenio)
			INNER JOIN unidad_negocio un ON un.id = r.id_unidad_negocio
			INNER JOIN convenios c ON c.id_convenio = neg.id_convenio
			INNER JOIN administrativo.estados_cartera ec ON ec.id = neg.estado_cartera ' || filtro ||'
			AND estado_cartera in(3,4) AND negocio_rel = '''' AND negocio_rel_seguro = '''' AND negocio_rel_gps = ''''
						AND estado_neg in(''T'',''A'') and actividad in  (''DES'',''FOR'')) as tabla
			INNER JOIN administrativo.intervalos_mora m ON m.id = tabla.rango '  ; raise notice 'SQL: %',SQL;

	FOR listaNegocios IN EXECUTE SQL LOOP

		sumaSaldo = 0;
		raise notice '/*----------------------INICIO----------------------*/  Negocio:: % Valor saldo : %',listaNegocios.negocio,listaNegocios.valor_saldo;
		raise notice 'id_und_negocio: %, und_negocio: %',listaNegocios.id_und_negocio, listaNegocios.und_negocio;

		--1.)Negocio aval.

		SELECT INTO _NegAval cod_neg from negocios where negocio_rel=listaNegocios.negocio and estado_neg in ('T','A') ;

		if FOUND then
			--raise notice 'A';
			SELECT into sumaSaldo coalesce(sum(valor_saldo),0) as valor_saldo
			from con.factura fra
			WHERE  fra.dstrct = 'FINV'
			AND tipo_documento in ('FAC','NDC')
			AND fra.valor_saldo > 0
			AND fra.reg_status = ''
			AND substring(fra.documento,1,2) not in ('CP','FF','DF')
			AND fra.fecha_vencimiento::date < now()::date
			AND negasoc = _NegAval;

			raise notice 'negocio valor aval : %', sumaSaldo;

		end if;

		if ( listaNegocios.id_und_negocio in (3,9) ) then

			--2.)Negocio seguro.
			SELECT INTO _NegSeguro  cod_neg from negocios where negocio_rel_seguro=listaNegocios.negocio and estado_neg in ('T','A');

			if FOUND then
				raise notice 'B';
				SELECT into sumaSaldo (coalesce(sum(valor_saldo),0)+sumaSaldo) as valor_saldo
				FROM con.factura fra
				WHERE  fra.dstrct = 'FINV'
					AND tipo_documento in ('FAC','NDC')
					AND fra.valor_saldo > 0
					AND fra.reg_status = ''
					AND substring(fra.documento,1,2) not in ('CP','FF','DF')
					AND fra.fecha_vencimiento::date < now()::date
					AND negasoc =_NegSeguro;

				raise notice 'negocio valor seguro : %', sumaSaldo;

			end if;

			--3.)Negocio gps.
			SELECT INTO _NegVehiculo  cod_neg from negocios where negocio_rel_gps=listaNegocios.negocio and estado_neg in ('T','A')  ;

			if FOUND then
				raise notice 'C';
				SELECT into sumaSaldo (coalesce(sum(valor_saldo),0)+sumaSaldo) as valor_saldo
				from con.factura fra
				WHERE  fra.dstrct = 'FINV'
				AND tipo_documento in ('FAC','NDC')
				AND fra.valor_saldo > 0
				AND fra.reg_status = ''
				AND substring(fra.documento,1,2) not in ('CP','FF','DF')
				AND fra.fecha_vencimiento::date < now()::date
				--AND replace(substring(fra.fecha_vencimiento,1,7),'-','')::numeric <= replace(substring(now(),1,7),'-','')::numeric
				AND negasoc = _NegVehiculo;

				raise notice 'negocio valor gps : %', sumaSaldo;

			end if;
		end if;

		listaNegocios.valor_saldo := listaNegocios.valor_saldo+sumaSaldo;

		--raise notice '/*--------------------FIN----------------------------*/ VALOR SALDO FINAL :%', listaNegocios.valor_saldo;

		RETURN NEXT listaNegocios;

	END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION administrativo.sp_lista_procesos_juridicos(character varying)
  OWNER TO postgres;
