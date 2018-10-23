-- Function: apicredit.eg_liquidador_creditos(numeric, integer, date, integer)

-- DROP FUNCTION apicredit.eg_liquidador_creditos(numeric, integer, date, integer);

CREATE OR REPLACE FUNCTION apicredit.eg_liquidador_creditos(valornegocio numeric, numcuotas integer, fechaitem date, idconvenio integer)
  RETURNS SETOF documentos_neg_aceptado AS
$BODY$
DECLARE

	retorno documentos_neg_aceptado;

	recordConvenio record;
	recordImpuesto record;
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
	cuota_manejo numeric:=0;
	_valorAval numeric:=0;
	tasaImpuesto NUMERIC :=0;
        df NUMERIC :=0;
	fechaAux DATE :=fechaItem;
	fechaItems DATE ;

	vpTotal NUMERIC := 0;
	vp  NUMERIC := 0;

	-----Variables para el calculo del aval---
        rangosAvalRecord record;
        _valorFianzaAval numeric:=0 ;



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

	SELECT  INTO recordImpuesto
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
                AND codigo_impuesto = 'IVA02'
                AND TO_CHAR(fecha_vigencia, 'YYYY') = TO_CHAR(now(), 'YYYY');


	SELECT INTO recordProconvenio * FROM convenios
	WHERE id_convenio=idconvenio AND reg_status='' ;



        raise notice 'tasa interes : %',recordProconvenio.tasa_interes;

	/* **********************************
	* Calculo del valor de la fianza    *
	*************************************/
	SELECT INTO _valorFianzaAval
		CASE WHEN porcentaje_comision > 0 THEN round((valornegocio*porcentaje_comision/100)*(1+porcentaje_iva/100))
		  ELSE round((numcuotas*valornegocio*valor_comision/1000000)*(1+porcentaje_iva/100))
		 END AS valor
	FROM configuracion_factor_por_millon cf
	INNER JOIN unidad_negocio un ON cf.id_unidad_negocio = un.id
	INNER JOIN rel_unidadnegocio_convenios run on (run.id_unid_negocio=un.id)
	WHERE id_unid_negocio in((select id_unid_negocio from rel_unidadnegocio_procinterno
	WHERE id_proceso_interno = (select id from proceso_interno where descripcion = 'COBRANZA ESTRATEGICA'))) AND id_convenio=idconvenio
	AND numcuotas BETWEEN plazo_inicial AND plazo_final;



        /* ***************************
         * Calculo de tasas goblales *
         *****************************/

	tasaInteres :=recordProconvenio.tasa_interes / 100;
	interesEA := POW(1 + tasaInteres, 12) - 1;
        vlrSeguro = recordConvenio.valor_seguro / numcuotas ;
	capital := valornegocio+_valorFianzaAval;
	saldoinicial := capital;
	seguroItem := vlrSeguro;
	custodiaItem := 0;
        remesaItem :=0;
        cuota_manejo:=(SELECT valor FROM apicredit.cuota_manejo  where id_convenio=idconvenio);

        raise notice 'valornegocio %',valornegocio;
        raise notice 'cuaota manejo: %',cuota_manejo;
        raise notice '_valorFianzaAval: %',_valorFianzaAval;
        raise notice 'capital inicial: %',capital;

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

			valorCuota := ROUND((capital / vpTotal) + seguroItem + remesaItem + cuota_manejo) ;

			IF(i = numCuotas)THEN
			 df := (capitalItem + seguroItem + custodiaItem + remesaItem + interesItem + cuota_manejo)-valorCuota;
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
			retorno.cuota_manejo:=cuota_manejo;
			retorno.valor_aval:=_valorFianzaAval;

			saldoinicial := saldofinal;

			RETURN NEXT  retorno;


		END LOOP ;

 RETURN;

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION apicredit.eg_liquidador_creditos(numeric, integer, date, integer)
  OWNER TO postgres;
