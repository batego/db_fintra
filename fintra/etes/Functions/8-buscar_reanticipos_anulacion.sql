-- Function: etes.buscar_reanticipos_anulacion(character varying, character varying, character varying)

-- DROP FUNCTION etes.buscar_reanticipos_anulacion(character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION etes.buscar_reanticipos_anulacion(planill character varying, cod_empresa character varying, cod_agencia character varying)
  RETURNS SETOF etes.manifiesto_reanticipos AS
$BODY$

DECLARE

  recordAgenciaTransportadora record;
  recordManifiesto record;
  recordReanticipos record;
  recordOUT record;
  rs etes.manifiesto_reanticipos;
  totalVenta numeric :=0;
  resta numeric :=0 ;
  filtro text :='0';
  sql text :='';


BEGIN

	/********** BUSCAMOS EL ID AGENCIA y TRANSPORTADORA*************/
	SELECT INTO recordAgenciaTransportadora a.id as idAgencia , t.id as idTransportadora FROM etes.agencias a
	INNER JOIN etes.transportadoras t ON (a.id_transportadora=t.id)
	WHERE a.cod_agencia=cod_agencia AND t.cod_transportadora=cod_empresa  AND a.reg_status='' AND t.reg_status='' ;
	RAISE NOTICE 'recordAgenciaTransportadora %',recordAgenciaTransportadora.idAgencia;
	/********** BUSCAMOS EL ID DEL ANTICIPO PADRE EN LA TABLA MANIFIESTOS *************/
	SELECT INTO recordManifiesto * FROM etes.manifiesto_carga
	WHERE planilla=planill AND id_agencia=recordAgenciaTransportadora.idAgencia and  reg_status='' ;

	/********** BUSCAMOS SI EXISTEN VENTAS PARA EL MANIFIESTO *************/
	SELECT INTO totalVenta coalesce(sum(total_venta),0.0)  FROM etes.ventas_eds where id_manifiesto_carga=recordManifiesto.id AND reg_status='';

	resta:=recordManifiesto.valor_desembolsar::NUMERIC - totalVenta::NUMERIC ;

	IF(resta < 0)THEN

	  resta:=resta * -1;

		FOR recordReanticipos IN (SELECT ra.*
					  FROM etes.manifiesto_reanticipos as ra
					  INNER JOIN etes.manifiesto_carga as mc on (ra.id_manifiesto_carga=mc.id and mc.reg_status='')
					  WHERE mc.id =recordManifiesto.id and ra.reg_status='' and ra.transferido ='N')

		LOOP
			resta:=recordReanticipos.valor_desembolsar - resta;

			IF(resta >=0)THEN
			 filtro:= filtro||recordReanticipos.id ;
			 EXIT;
			ELSE
			 filtro:= filtro||recordReanticipos.id||',';
			END IF;

		END LOOP;

	END IF;


       raise notice 'filtro : %',filtro;

        IF(recordManifiesto.id IS NULL) THEN
            recordManifiesto.id=0;
        END IF;

       sql:='SELECT ra.*
	    FROM etes.manifiesto_reanticipos as ra
	    INNER JOIN etes.manifiesto_carga as mc on (ra.id_manifiesto_carga=mc.id and mc.reg_status='''')
	    WHERE mc.id ='||recordManifiesto.id||' and ra.reg_status='''' and ra.transferido =''N'' and ra.id not in ('||filtro||')';

	RAISE NOTICE 'sql %',sql;
	FOR recordOUT IN EXECUTE sql LOOP
           rs:=recordOUT;
           RETURN NEXT rs;
	END LOOP;

     RETURN ;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.buscar_reanticipos_anulacion(character varying, character varying, character varying)
  OWNER TO postgres;
