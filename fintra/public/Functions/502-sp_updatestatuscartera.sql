-- Function: sp_updatestatuscartera()

-- DROP FUNCTION sp_updatestatuscartera();

CREATE OR REPLACE FUNCTION sp_updatestatuscartera()
  RETURNS text AS
$BODY$

DECLARE

        RsNegociosPrime record;
	NegociOthers record;
	retorno text:='OK';

 BEGIN
		FOR RsNegociosPrime IN

				select t.negasoc as negocio, nit, t.rango, t.valor_saldo, t.id_convenio, e.id, e.nombre, CASE WHEN e.id = 3 THEN '1' ELSE '' END AS etapa
				FROM (
					SELECT
						negasoc,
						nit,
						CASE
							WHEN maxdia >= 361 THEN 8
							WHEN maxdia >= 181 THEN 7
							WHEN maxdia >= 121 THEN 6
							WHEN maxdia >= 91 THEN  5
							WHEN maxdia >= 61 THEN 4
							WHEN maxdia >= 31 THEN 3
							WHEN maxdia >= 1 THEN 2
							WHEN maxdia <= 0 THEN 1
						ELSE 0 END AS rango,
						valor_saldo,
						id_convenio
					FROM (
						SELECT max(now()::date-(fecha_vencimiento)) as maxdia, negasoc, fra.nit, sum(valor_saldo) as valor_saldo, id_convenio
						FROM con.factura fra
						INNER JOIN negocios neg ON fra.negasoc = neg.cod_neg
						WHERE fra.dstrct = 'FINV'
						      AND fra.valor_saldo > 0
						      AND fra.reg_status = ''
						      AND fra.negasoc not in('')
						      AND substring(fra.documento,1,2) not in ('CP','FF','DF')
						      AND negocio_rel = '' AND negocio_rel_seguro = '' AND negocio_rel_gps = ''
						      AND estado_neg in ('T','A')
						      AND actividad in ('DES','FOR')
						      AND estado_cartera not in('3','4') AND etapa_proc_ejec in('','0')
						      --and id_convenio = 42
						      --AND estado_cartera = '' AND etapa_proc_ejec = '' AND fecha_marcacion_cartera is null
						GROUP BY negasoc,nit,id_convenio
					) as tabla2
				) as t
				INNER JOIN administrativo.rel_und_estado_cartera r
					ON t.rango=r.id_intervalo_mora
				AND r.id_unidad_negocio in (SELECT id_unid_negocio
							    FROM rel_unidadnegocio_convenios run
							    INNER JOIN unidad_negocio un on (run.id_unid_negocio=un.id)
							    WHERE ref_1= 'und_proc_ejec' AND id_convenio=t.id_convenio)
				INNER JOIN administrativo.estados_cartera e ON e.id=r.id_estado_cartera
				--where nombre = 'Jurídica' -- 'Activa' | 'Jurídica' | 'Pre-Demanda' | 'Prejurídica'
				order by e.id
		LOOP

			/**ACTUALIZO LOS NEGOCIOS PADRES**/
			UPDATE negocios
			SET
				estado_cartera = RsNegociosPrime.id,
				etapa_proc_ejec = '0',
				fecha_marcacion_cartera = now()
			WHERE cod_neg = RsNegociosPrime.negocio;

                        if found then
				UPDATE con.foto_cartera
				SET estado_cartera = RsNegociosPrime.id
				WHERE negasoc = RsNegociosPrime.negocio
				AND periodo_lote = replace(substring(now(),1,7),'-','')::numeric
				and reg_status='' and tipo_documento in ('FAC','NDC');
			end if;

			/**ACTUALIZO LOS NEGOCIOS HIJOS**/
			raise notice 'NegocioPadre: %', RsNegociosPrime.negocio;
			FOR NegociOthers IN SELECT cod_neg from negocios where RsNegociosPrime.negocio in (negocio_rel, negocio_rel_seguro, negocio_rel_gps) LOOP

				raise notice 'NegocioHijo: %', NegociOthers.cod_neg;
				UPDATE negocios
				SET
					estado_cartera = RsNegociosPrime.id,
					etapa_proc_ejec = '0',
					fecha_marcacion_cartera = now()
				WHERE cod_neg = NegociOthers.cod_neg;

				if found then
					UPDATE con.foto_cartera
					SET estado_cartera = RsNegociosPrime.id
					WHERE negasoc = NegociOthers.cod_neg AND periodo_lote = replace(substring(now(),1,7),'-','')::numeric
				        and reg_status='' and tipo_documento in ('FAC','NDC');
				end if;

			END LOOP;

		END LOOP;

		RETURN retorno;

  END;
  $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_updatestatuscartera()
  OWNER TO postgres;
