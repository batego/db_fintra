-- Function: administrativo.sp_actualiza_estado_cartera()

-- DROP FUNCTION administrativo.sp_actualiza_estado_cartera();

CREATE OR REPLACE FUNCTION administrativo.sp_actualiza_estado_cartera()
  RETURNS text AS
$BODY$

DECLARE

       	negociosRecord record;
        SQL TEXT;
	retorno text:='OK';
        good text:='';

BEGIN
       SQL =' select   t.negasoc,nit,t.rango,t.valor_saldo,t.id_convenio, e.id, e.nombre, CASE WHEN e.id = 3 THEN ''1'' ELSE '''' END AS etapa FROM
                       ( SELECT
			negasoc,nit,CASE WHEN maxdia >= 361 THEN 8
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
				 SELECT max(now()::date-(fecha_vencimiento)) as maxdia,negasoc,fra.nit,sum(valor_saldo) as valor_saldo, id_convenio
				 FROM con.factura fra  INNER JOIN negocios neg
				 ON fra.negasoc=neg.cod_neg
				 WHERE fra.dstrct = ''FINV''
					  AND fra.valor_saldo > 0
					  AND fra.reg_status = ''''
					  AND fra.negasoc not in('''')
					  AND substring(fra.documento,1,2) not in (''CP'',''FF'',''DF'')
				 GROUP BY negasoc,nit,id_convenio

			) as tabla2 ) as t INNER JOIN administrativo.rel_und_estado_cartera r  ON t.rango=r.id_intervalo_mora AND
			                   r.id_unidad_negocio in(SELECT id_unid_negocio FROM rel_unidadnegocio_convenios run
				           INNER JOIN unidad_negocio un on (run.id_unid_negocio=un.id)
				           WHERE ref_1= ''und_proc_ejec'' AND id_convenio=t.id_convenio)
                                           INNER JOIN administrativo.estados_cartera e ON e.id=r.id_estado_cartera
                                           order by e.id ';
      --raise notice 'sql: %',SQL;
        FOR negociosRecord IN EXECUTE SQL LOOP

                --raise notice 'Negocio: %, Id: %, EstadoCartera: % Etapa: %',negociosRecord.negasoc,negociosRecord.id,negociosRecord.nombre,negociosRecord.etapa;
                update negocios set estado_cartera=negociosRecord.id, etapa_proc_ejec = '0', fecha_marcacion_cartera = now() WHERE cod_neg = negociosRecord.negasoc;

        END LOOP;


	RETURN retorno;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION administrativo.sp_actualiza_estado_cartera()
  OWNER TO postgres;
