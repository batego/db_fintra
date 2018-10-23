-- Function: eg_liquidador_api(numeric, integer, date, integer, character varying)

-- DROP FUNCTION eg_liquidador_api(numeric, integer, date, integer, character varying);

CREATE OR REPLACE FUNCTION eg_liquidador_api(valornegocio numeric, numcuotas integer, fechaitem date, idconvenio integer, afiliado character varying)
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

	--esto es para el calculo del aval del negocio..
	select into rangosAvalRecord ceil(dias_ini/30)AS ini, floor(dias_fin/30) , round(porcentaje_aval/100,3) as porcentaje_aval
				    from condiciones_aval ca
				    join condiciones_aval_rangos car
				      on ca.id_aval = car.id_aval
				    where id_prov_convenio = (SELECT id_prov_convenio FROM prov_convenio WHERE id_convenio =idconvenio and reg_status!='A' and nit_proveedor=afiliado limit 1)
				      and tipo_titulo in ('01','02','03')
				      and plazo_primer_titulo =30
				      and propietario = false;

	SELECT INTO recordProconvenio * FROM convenios
	WHERE id_convenio=idconvenio AND reg_status='' ;



        raise notice 'tasa interes : %',recordProconvenio.tasa_interes;
        /* ***************************
         * Calculo de tasas goblales *
         *****************************/

	tasaInteres :=recordProconvenio.tasa_interes / 100;
	interesEA := POW(1 + tasaInteres, 12) - 1;
        vlrSeguro = recordConvenio.valor_seguro / numcuotas ;
	capital := valornegocio;
	saldoinicial := capital;
	seguroItem := vlrSeguro;
	custodiaItem := 0;
        remesaItem :=0;
        cuota_manejo:=(SELECT valor FROM apicredit.cuota_manejo  where id_convenio=idconvenio);

        raise notice 'cuaota manejo: %',cuota_manejo;

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

			raise notice 'capital: %',interesItem;

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

			saldoinicial := saldofinal;

			--Calcular valor del aval...
			raise notice 'valor aval: % porc: %',  round(((retorno.capital+retorno.interes)*rangosAvalRecord.porcentaje_aval)*(recordImpuesto.porcentaje1/100)),rangosAvalRecord.porcentaje_aval;
			_valorAval:=round(((retorno.capital+retorno.interes)*rangosAvalRecord.porcentaje_aval));
			retorno.no_aval:=_valorAval+(_valorAval*(recordImpuesto.porcentaje1/100));

			RETURN NEXT  retorno;


		END LOOP ;

 RETURN;

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_liquidador_api(numeric, integer, date, integer, character varying)
  OWNER TO postgres;
