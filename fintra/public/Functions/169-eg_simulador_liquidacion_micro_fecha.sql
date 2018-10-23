-- Function: eg_simulador_liquidacion_micro_fecha(numeric, integer, date, character varying, character varying, date)

-- DROP FUNCTION eg_simulador_liquidacion_micro_fecha(numeric, integer, date, character varying, character varying, date);

CREATE OR REPLACE FUNCTION eg_simulador_liquidacion_micro_fecha(valornegocio numeric, numcuotas integer, fechaitem date, tipo_cuota character varying, idconvenio character varying, fecha_system date)
  RETURNS SETOF documentos_neg_aceptado AS
$BODY$
DECLARE

	retorno documentos_neg_aceptado;

	recordConvenio record;
	recordImpuesto record;
	fechaAnterior DATE := fecha_system::date;

	capital NUMERIC := 0;
	saldoinicial NUMERIC := 0;
	saldofinal NUMERIC := 0;
	capitalItem NUMERIC:= 0;
	capacitacionItem NUMERIC :=0;
	valorCuota NUMERIC:= 0;
	interesItem NUMERIC:= 0;
	seguroItem NUMERIC := 0;
	catItem NUMERIC:= 0;
	dias INTEGER :=0;
	diasAcomulado INTEGER:=0;

	interesEA NUMERIC:= 0;
	tasaInteres NUMERIC :=0;
	tasaCAT NUMERIC :=0;
	tasaImpuesto NUMERIC :=0;
	fechaAux DATE :=fechaItem;
	fechaItems DATE ;

	vpTotal NUMERIC := 0;
	vp  NUMERIC := 0;



BEGIN

	/* *********************************
	 * Buscamos de reestructuracion ****
	 ***********************************/
        SELECT INTO recordConvenio tasa_interes,
		porcentaje_cat,
		valor_capacitacion,
		valor_seguro,
		valor_central,
		cat,
		impuesto
 	FROM convenios
	WHERE id_convenio= idconvenio;

	SELECT INTO recordImpuesto
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


        /* ***************************
         * Calculo de tasas goblales *
         *****************************/

	tasaInteres :=recordConvenio.tasa_interes / 100;
	interesEA := POW(1 + tasaInteres, 12) - 1;
	tasaCAT:= (recordConvenio.porcentaje_cat / 100);
	tasaImpuesto:=(recordImpuesto.porcentaje1 / 100 );

        /* *****************************
         * Capital Fijo Cuota Variable *
         *******************************/
	IF (tipo_cuota = 'CPFCTV') THEN

		/* *****************************
		* Seteamos valores iniciales  *
		*******************************/

		capital := valornegocio;
		saldoinicial := capital;
		seguroItem := recordConvenio.valor_seguro;
		capacitacionItem := ROUND(recordConvenio.valor_capacitacion/numCuotas);
		capitalItem := ROUND(capital / numCuotas);

		IF(recordConvenio.cat) THEN

		  catItem = ROUND((( tasaCAT * valornegocio)* ( tasaImpuesto + 1)) / numCuotas);

		END IF;

		/* ***********************************************************
		* hacemos un loop con las cuaotas para realizar los calculos *
		*************************************************************/
		FOR i IN 1..numCuotas LOOP

			IF (i = numCuotas) THEN

			  capitalItem = capital - capitalItem * (numCuotas - 1);
                          capacitacionItem = recordConvenio.valor_capacitacion - capacitacionItem * (numCuotas - 1);

			END IF;

			IF( i = 1)THEN

			 fechaItems :=fechaItem ;

			ELSE

			  fechaItems :=fechaAux + INTERVAL '1 month';
			  fechaAux := fechaItems;

			END IF;

			dias:= fechaItems - fechaAnterior ; --fecha anterior el la fecha de liquidacion
			diasAcomulado :=diasAcomulado + dias ;

			interesItem := ROUND(saldoinicial * POW(1 + interesEA, ( dias / 360 ::numeric)) - saldoinicial);
			fechaAnterior :=fechaItems ;

			valorCuota := capitalItem + interesItem + capacitacionItem + catItem + seguroItem;

			IF(i = 1)THEN

			  valorCuota := valorCuota  + recordConvenio.valor_central;

			END IF;

			saldofinal = saldoinicial - capitalItem;

			/* *********************************************************
			* Seteamos valores de la liquidacion y retornamos la fila  *
			************************************************************/
			retorno.fecha := fechaItems;
			retorno.item := i ;
			retorno.saldo_inicial:= saldoinicial;
			retorno.seguro := seguroItem ;
			retorno.capacitacion := capacitacionItem;
			retorno.capital := capitalItem;
			retorno.cat := catItem;
			retorno.interes := interesItem;
			retorno.valor := valorCuota;
			retorno.saldo_final := saldofinal ;
			retorno.dias := diasAcomulado;

			saldoinicial := saldofinal;

			RETURN NEXT  retorno;

		END LOOP;

	/* *****************************
         * Cuota Fija Capital Variable *
         *******************************/
	ELSIF(tipo_cuota = 'CTFCPV') THEN

		capital := valornegocio;
		saldoinicial := capital;
		seguroItem := recordConvenio.valor_seguro;
		capacitacionItem = ROUND(recordConvenio.valor_capacitacion / numCuotas);

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

		IF(recordConvenio.cat) THEN

		  catItem = ROUND((( tasaCAT * valornegocio)* ( tasaImpuesto + 1)) / numCuotas);

		END IF;

		/* ***********************************************************
		* hacemos un loop con las cuaotas para realizar los calculos *
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
		         capacitacionItem := recordConvenio.valor_capacitacion - capacitacionItem * (numCuotas - 1);

			END IF;

			valorCuota := (capital / vpTotal) + capacitacionItem + catItem + seguroItem;

			IF(i = 1)THEN

			  valorCuota := valorCuota  + recordConvenio.valor_central;

			END IF;

			saldofinal:= saldoinicial - capitalItem;

			/* *********************************************************
			* Seteamos valores de la liquidacion y retornamos la fila  *
			************************************************************/
			retorno.fecha := fechaItems;
			retorno.item := i ;
			retorno.saldo_inicial:= saldoinicial;
			retorno.seguro := seguroItem ;
			retorno.capacitacion := capacitacionItem;
			retorno.capital := capitalItem;
			retorno.cat := catItem;
			retorno.interes := interesItem;
			retorno.valor := valorCuota;
			retorno.saldo_final := saldofinal ;
			retorno.dias := diasAcomulado;

			saldoinicial := saldofinal;

			RETURN NEXT  retorno;


		END LOOP ;

	END IF;

 RETURN;

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_simulador_liquidacion_micro_fecha(numeric, integer, date, character varying, character varying, date)
  OWNER TO postgres;
