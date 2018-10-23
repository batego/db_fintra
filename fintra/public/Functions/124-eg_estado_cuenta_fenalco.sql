-- Function: eg_estado_cuenta_fenalco(character varying, character varying, date)

-- DROP FUNCTION eg_estado_cuenta_fenalco(character varying, character varying, date);

CREATE OR REPLACE FUNCTION eg_estado_cuenta_fenalco(codigo_neg character varying, distrito character varying, fecha_corte date)
  RETURNS SETOF record AS
$BODY$
DECLARE

  listaFacturas record;
  --saldoInteres numeric;
  --saldoCapital numeric;
  --restoAplicacionInt numeric;

  --sumaConceptos numeric;
  --tasaIm record;
  --ixmItem numeric;
  --gacItem numeric;
  --sumaSaldo numeric;
  --fechaAnterior date;
 -- resta numeric;
 -- _cuotaAdmin numeric;

  unidadNegocio integer;
  --porGaC numeric;
  --nuevoInteres numeric;
  --diasInteresCorriente numeric;
  tasa numeric;
  porcgac numeric;



BEGIN

   --SELECT INTO fechaAnterior fecha_negocio FROM negocios WHERE cod_neg= codigo_neg;
   FOR listaFacturas IN (

			SELECT fecha::DATE
			       ,neg.id_convenio::varchar as convenio
			       ,item::varchar
			       ,(fecha_corte::DATE-fecha::DATE) as dias_mora
			       ,saldo_inicial::numeric
			       ,valor::numeric as valor_cuota
			       ,0.00::numeric as valor_saldo_cuota
			       ,capital::numeric
			       ,interes::numeric
			       ,seguro::numeric
			       ,0.00::numeric as interes_mora
			       ,0.00::numeric as gac
			       ,0.00::numeric as valor_saldo_global_cuota
			       ,CASE WHEN (now()::DATE-fecha::DATE) > 0 THEN 'VENCIDA'
				    WHEN  (now()::DATE-fecha::DATE) < -30 THEN 'FUTURA'
				    WHEN  (now()::DATE-fecha::DATE) BETWEEN -30 AND 0 THEN 'CORRIENTE' END::varchar
				AS estado

			  FROM documentos_neg_aceptado dna
			  INNER JOIN negocios neg on (neg.cod_neg=dna.cod_neg)
			  WHERE neg.cod_neg=codigo_neg AND neg.estado_neg in ('T','A')
			  order by fecha asc

			)
	LOOP
		--select * from documentos_neg_aceptado limit 2
		--1.)calcular valor saldo cuota
		SELECT into listaFacturas.valor_saldo_cuota valor_saldo FROM con.factura fac
		WHERE negasoc=codigo_neg AND num_doc_fen::integer=listaFacturas.item::integer AND substring(fac.documento,1,2) not in ('CP','FF','DF') AND fac.reg_status !='A';

		--2.)cacular interes x mora
		if(listaFacturas.dias_mora > 0)then
			select into tasa tasa_interes from convenios where id_convenio = listaFacturas.convenio;
			listaFacturas.interes_mora :=  round(((listaFacturas.valor_saldo_cuota * tasa)/100 * (fecha_corte::date - listaFacturas.fecha::date)/30),2);
		end if;

		--3.)calcular gasto de cobranza

		SELECT INTO unidadNegocio id_unid_negocio FROM rel_unidadnegocio_convenios where id_convenio in (listaFacturas.convenio) and id_unid_negocio in (1,2,3,4,8,10);
		SELECT INTO porcgac coalesce(porcentaje,'0') FROM sanciones_condonaciones
				WHERE id_tipo_acto = 1 AND id_unidad_negocio  =  unidadNegocio
				AND periodo = replace(substring(now(),1,7),'-','')::numeric AND listaFacturas.dias_mora BETWEEN dias_rango_ini AND dias_rango_fin
				AND categoria = 'GAC' group by porcentaje,dias_rango_ini,dias_rango_fin;
		raise notice 'porcgac: %',porcgac;

		IF FOUND THEN
			listaFacturas.gac := round(((listaFacturas.valor_saldo_cuota * porcgac)/100) ,2);
		else
			listaFacturas.gac := 0.00;
		end if;

		--4.)calcular el saldo global
		listaFacturas.valor_saldo_global_cuota := round((listaFacturas.valor_saldo_cuota + listaFacturas.interes_mora + listaFacturas.gac),2);


	RETURN NEXT listaFacturas;

   END LOOP;

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_estado_cuenta_fenalco(character varying, character varying, date)
  OWNER TO postgres;
