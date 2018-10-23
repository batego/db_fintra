-- Function: eg_simulador_liquidacion_fenalco(numeric, integer, date, character varying, character varying)

-- DROP FUNCTION eg_simulador_liquidacion_fenalco(numeric, integer, date, character varying, character varying);

CREATE OR REPLACE FUNCTION eg_simulador_liquidacion_fenalco(valornegocio numeric, numcuotas integer, fechaitem date, idconvenio character varying, afiliado character varying)
  RETURNS SETOF documentos_neg_aceptado AS
$BODY$
DECLARE

	retorno documentos_neg_aceptado;

	recordConvenio record;
	--recordImpuesto record;
	recordProconvenio record;
	fechaAnterior DATE := now()::date;

	capital NUMERIC := 0;
	saldoinicial NUMERIC := 0;
	saldofinal NUMERIC := 0;
	capitalItem NUMERIC:= 0;
	custodiaItem NUMERIC :=0;
	valorCuota NUMERIC:= 0;
	interesItem NUMERIC:= 0;
	seguroItem NUMERIC := 0;
	remesaItem NUMERIC:= 0;
	dias INTEGER :=0;
	diasAcomulado INTEGER:=0;

	interesEA NUMERIC:= 0;
	tasaInteres NUMERIC :=0;
	vlrSeguro NUMERIC :=0;
	tasaImpuesto NUMERIC :=0;
        df NUMERIC :=0;
	fechaAux DATE :=fechaItem;
	fechaItems DATE ;

	vpTotal NUMERIC := 0;
	vp  NUMERIC := 0;



BEGIN

	/* ***********************************************
	 * Buscamos convenio, proconvenio e impuestos ****
	 *************************************************/
        SELECT INTO recordConvenio tasa_interes,
		porcentaje_cat,
		valor_capacitacion,
		valor_seguro,
		valor_central,
		cat,
		impuesto
 	FROM convenios
	WHERE id_convenio= idconvenio;

/*	SELECT INTO recordImpuesto
                tipo_impuesto,
                codigo_impuesto,
                porcentaje1 * ind_signo AS porcentaje1,
                porcentaje2,
                concepto,
                descripcion,
                cod_cuenta_contable
            FROM
                tipo_de_impuesto
            WHERE
                dstrct  = 'FINV'
                AND codigo_impuesto = recordConvenio.impuesto
                AND TO_CHAR(fecha_vigencia, 'YYYY') = TO_CHAR(now(), 'YYYY');
----------------------------------------------------------------------------------------
	SELECT INTO recordProconvenio
		    tasa_interes,
		    valor_custodia
            FROM prov_convenio
            WHERE id_convenio =idconvenio and reg_status!='A' and nit_proveedor=afiliado;*/

	SELECT INTO recordProconvenio * FROM convenios
	WHERE id_convenio=idconvenio AND reg_status='' ;



        raise notice 'tasa interes : %',recordProconvenio.tasa_interes;
        /* ***************************
         * Calculo de tasas goblales *
         *****************************/

	tasaInteres :=recordProconvenio.tasa_interes / 100;
	interesEA := POW(1 + tasaInteres, 12) - 1;
        vlrSeguro = recordConvenio.valor_seguro / numcuotas ;
	--tasaImpuesto:=(recordImpuesto.porcentaje1 / 100 );
	capital := valornegocio;
	saldoinicial := capital;
	seguroItem := vlrSeguro;
	custodiaItem := 0;
        remesaItem :=0;

		FOR i IN 1..numcuotas LOOP

	        	IF( i = 1)THEN

		           fechaItems :=fechaItem ;

		        ELSE

			  fechaItems :=fechaAux + INTERVAL '1 month';
			  fechaAux := fechaItems;

			END IF;

			dias:= fechaItems - fechaAnterior ;--fecha anterior el la fecha de liquidacion

			vp := POW(1 + interesEA, (-dias / 360 ::numeric));
			vpTotal := vpTotal + vp;

		END LOOP;


		/* ***********************************************************
		* hacemos un loop con las cuotas para realizar los calculos *
		*************************************************************/
		fechaAux :=fechaItem;
		FOR i IN 1..numCuotas LOOP

			IF( i = 1)THEN

		           fechaItems :=fechaItem ;

		        ELSE

			  fechaItems :=fechaAux + INTERVAL '1 month';
			  fechaAux := fechaItems;

			--	RAISE NOTICE 'FECHAS %',fechaItems;

			END IF;

			--RAISE NOTICE 'FECHAS %',fechaItems;

			dias:= fechaItems - fechaAnterior ; --fecha anterior el la fecha de liquidacion
			diasAcomulado:=diasAcomulado + dias ;

			interesItem := ROUND(saldoinicial * POW(1 + interesEA, ( dias / 360 ::numeric) ) - saldoinicial);
			fechaAnterior :=fechaItems ;

			capitalItem := ROUND((capital / vpTotal) - interesItem);

			/* ******************************
			* Esto es para la ultima cuota	*
			*********************************/
			IF(i = numCuotas AND i != 1) THEN
			   capitalItem := saldofinal;
		        END IF;

			valorCuota := ROUND((capital / vpTotal) + seguroItem + remesaItem) ;

			IF(i = numCuotas)THEN
			 df := (capitalItem + seguroItem + custodiaItem + remesaItem + interesItem)-valorCuota;
			 interesItem := (interesItem-df);
			END IF;

			saldofinal:= saldoinicial - capitalItem;

			/* *********************************************************
			* Seteamos valores de la liquidacion y retornamos la fila  *
			************************************************************/
			retorno.item := i ;
			retorno.fecha := fechaItems;
			retorno.saldo_inicial:= saldoinicial;
			retorno.capital := capitalItem;
			retorno.interes := interesItem;
			retorno.custodia := custodiaItem;
			retorno.seguro := seguroItem ;
                        retorno.remesa :=remesaItem;
			retorno.valor := valorCuota;
			retorno.saldo_final := saldofinal ;
			retorno.dias := diasAcomulado;

			saldoinicial := saldofinal;

			RETURN NEXT  retorno;


		END LOOP ;


 RETURN;

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_simulador_liquidacion_fenalco(numeric, integer, date, character varying, character varying)
  OWNER TO postgres;
