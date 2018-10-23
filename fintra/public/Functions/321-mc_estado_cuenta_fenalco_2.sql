-- Function: mc_estado_cuenta_fenalco_2(character varying, character varying, date)

-- DROP FUNCTION mc_estado_cuenta_fenalco_2(character varying, character varying, date);

CREATE OR REPLACE FUNCTION mc_estado_cuenta_fenalco_2(codigo_neg character varying, distrito character varying, fecha_corte date)
  RETURNS SETOF record AS
$BODY$
DECLARE

listaFacturas record;
infoNegAval record;
infoDocNegAceptAval record;
valor_saldo_factura numeric;
unidadNegocio integer;
financia_aval_ boolean;
tasa numeric;
porcgac numeric;
fechaD int;
valorInterXDia numeric;
valorInterXGenerado numeric;

fecha1 varchar;
fecha2 varchar;

valNegAvalSin numeric = 0;
valorCuota numeric = 0;
SaldoVencido_ numeric := 0 ;
capitaCuotasFacturadas_ numeric = 0;
totalSeguro_ numeric = 0;
totalGastoCobranza_ numeric = 0;
totalIxM_ numeric = 0;
TotalPagar_ numeric = 0;
varlorTotal_ numeric := 0;
valorCuotaCaval numeric := 0;

BEGIN

	--SELECT INTO fechaAnterior fecha_negocio FROM negocios WHERE cod_neg= codigo_neg;
	select into infoNegAval *  FROM negocios  where negocio_rel = codigo_neg;
	select into financia_aval_ financia_aval  FROM negocios  where cod_neg = codigo_neg;
	select into valNegAvalSin valor_aval from negocios 
	inner join convenios conv on (conv.id_convenio = negocios.id_convenio)
	INNER JOIN rel_unidadnegocio_convenios ruc ON (conv.id_convenio = ruc.id_convenio)
	INNER JOIN unidad_negocio uneg ON (uneg.id = ruc.id_unid_negocio)
	where uneg.descripcion IN ('MICROCREDITO','EDUCATIVO FA & FB','CONSUMO  FA & FB','LIBRANZA')
	and cod_neg in(codigo_neg)
	and (select count(*)from negocios where negocio_rel = codigo_neg)= 0;

	if (valNegAvalSin is null) then 
		valNegAvalSin = 0;
	end if;
	
   --raise notice 'infoNegAval: %',infoNegAval.cod_neg;

   FOR listaFacturas IN (
			 
			SELECT ''::varchar as factura 
			       ,fecha::DATE
			       ,neg.id_convenio::varchar as convenio
			       ,item::varchar
			       ,(fecha_corte::DATE-fecha::DATE) as dias_mora
			       ,sum (saldo_inicial)::numeric
			       ,sum (valor)::numeric as valor_cuota
			       ,0.00::NUMERIC AS valor_saldo_cuota
			       ,sum (capital)::numeric AS capital
			       ,sum (interes)::numeric as interes
			       ,sum (seguro)::numeric as seguro
			       ,sum (cat)::numeric as mipyme
			       ,sum (dna.cuota_manejo)::numeric as cuota_manejo
			       ,0.00::numeric as interes_mora
			       ,0.00::numeric as gac
			       ,0.00::numeric as valor_saldo_global_cuota
			       ,CASE WHEN (fecha_corte::DATE-fecha::DATE) > 0 THEN 'VENCIDA'
				    WHEN  (fecha_corte::DATE-fecha::DATE) < -29 THEN 'FUTURA'
				    WHEN  (fecha_corte::DATE-fecha::DATE) BETWEEN -29 AND 0 THEN 'CORRIENTE' END::varchar
				AS estado
			  FROM documentos_neg_aceptado dna  
			  INNER JOIN negocios neg on (neg.cod_neg=dna.cod_neg)
			  WHERE neg.cod_neg in( codigo_neg,infoNegAval.cod_neg) AND neg.estado_neg in ('T','A')
                          group by fecha,neg.id_convenio,item
			  order by fecha asc 
			
			)
	LOOP	
		
		--select * from documentos_neg_aceptado limit 2
		--1.)calcular valor saldo cuota
		SELECT into listaFacturas.factura documento 
		FROM con.factura fac
		WHERE negasoc in (codigo_neg,infoNegAval.cod_neg ) 
		AND num_doc_fen::integer = listaFacturas.item::integer 
		AND substring(fac.documento,1,2) not in ('CP','FF','DF') 
		AND fac.reg_status !='A';
	
		SELECT into valor_saldo_factura sum (valor_saldo) 
		FROM con.factura fac
		WHERE negasoc in (codigo_neg,infoNegAval.cod_neg ) 
		AND num_doc_fen::integer = listaFacturas.item::integer 
		AND substring(fac.documento,1,2) not in ('CP','FF','DF') 
		AND fac.reg_status !='A';

		raise notice 'item: %',listaFacturas.item;
		listaFacturas.valor_saldo_cuota:= valor_saldo_factura;
		--raise notice 'valor_saldo_cuota: %',listaFacturas.valor_saldo_cuota;
		
		--se suma el valor del aval sin financiar en la primera cuota
 		if (valNegAvalSin > 0 and listaFacturas.item = 1)then
 			raise notice 'listaFacturas.valor_cuota: %,valNegAvalSin: %',listaFacturas.valor_cuota,valNegAvalSin;
 			valorCuota := listaFacturas.valor_cuota;
 			listaFacturas.valor_cuota := (valNegAvalSin + valorCuota);
 		end if;

		if (valor_saldo_factura > 0 )then 
			if(listaFacturas.fecha < fecha_corte)then 
				raise notice 'entro: %',listaFacturas.item;
				--2.)cacular interes x mora
				if(listaFacturas.dias_mora > 0)then
					select into tasa tasa_interes from convenios where id_convenio = listaFacturas.convenio;
					listaFacturas.interes_mora :=  round(((listaFacturas.valor_cuota * tasa)/100 * (fecha_corte::date - listaFacturas.fecha::date)/30),2);
					raise notice 'valor_cuota: %,interes_mora: %',listaFacturas.valor_cuota,listaFacturas.interes_mora;
				end if;
				
				--3.)calcular Gasto de cobranza
				SELECT INTO unidadNegocio id_unid_negocio FROM rel_unidadnegocio_convenios where id_convenio in (listaFacturas.convenio) and id_unid_negocio in (1,2,3,4,8,10);
				
				SELECT INTO porcgac coalesce(porcentaje,'0') 
				FROM sanciones_condonaciones 
				WHERE id_tipo_acto = 1 AND id_unidad_negocio  =  unidadNegocio
				AND periodo = replace(substring(now(),1,7),'-','')::numeric 
				AND listaFacturas.dias_mora BETWEEN dias_rango_ini AND dias_rango_fin 
				AND categoria = 'GAC' group by porcentaje, dias_rango_ini, dias_rango_fin;
				
				--raise notice 'porcgac: %',porcgac;
				IF FOUND THEN
					listaFacturas.gac := round(((listaFacturas.valor_cuota * porcgac)/100) ,2);
				else
					listaFacturas.gac := 0.00;
				end if;
				
				--4.)calcular el saldo global
				listaFacturas.valor_saldo_global_cuota := round((listaFacturas.capital + listaFacturas.interes + listaFacturas.cuota_manejo + listaFacturas.seguro + listaFacturas.interes_mora + listaFacturas.gac + listaFacturas.mipyme+valNegAvalSin),2);
				raise notice '**listaFacturas.valor_saldo_global_cuota: %',listaFacturas.valor_saldo_global_cuota;
			ELSE 	
				fecha1 :=replace((substring (listaFacturas.fecha,1,7)),'-','');
				fecha2 := replace((substring (fecha_corte,1,7)),'-','');
				--raise notice 'fecha1 : %,fecha2corte : %',fecha1,fecha2;
				
				if ( replace((substring (listaFacturas.fecha,1,7)),'-','') <= replace((substring (fecha_corte,1,7)),'-',''))then 
					raise notice 'entro si : %',listaFacturas.item;
					fechaD := (extract (days from (listaFacturas.fecha-(listaFacturas.fecha + interval '0 year -1 mons'))))::int;
					valorInterXDia := listaFacturas.interes/fechaD;
					valorInterXGenerado := round ((valorInterXDia * (extract (days from (fecha_corte -(listaFacturas.fecha + interval '0 year -1 mons'))))::int),2);
					--listaFacturas.valor_saldo_global_cuota := listaFacturas.capital + valorInterXGenerado + listaFacturas.cuota_manejo + listaFacturas.mipyme + listaFacturas.seguro +valNegAvalSin;
					  listaFacturas.valor_saldo_global_cuota := listaFacturas.capital + valorInterXGenerado  + listaFacturas.mipyme + listaFacturas.seguro +valNegAvalSin;
				else 
					if (listaFacturas.estado = 'FUTURA')then 
						listaFacturas.valor_saldo_global_cuota := listaFacturas.capital;
					else
					
						fechaD := (extract (days from (listaFacturas.fecha-(listaFacturas.fecha + interval '0 year -1 mons'))))::int;
						valorInterXDia := listaFacturas.interes/fechaD;
						valorInterXGenerado := round ((valorInterXDia * (extract (days from (fecha_corte -(listaFacturas.fecha + interval '0 year -1 mons'))))::int),2);
						if (valNegAvalSin > 0 and listaFacturas.item = 1)then --Se agrega porque cuando no hay aval sale null
							listaFacturas.valor_saldo_global_cuota := listaFacturas.capital + listaFacturas.mipyme + valorInterXGenerado +valNegAvalSin +listaFacturas.seguro;
						else
							listaFacturas.valor_saldo_global_cuota := listaFacturas.capital + listaFacturas.mipyme + valorInterXGenerado +listaFacturas.seguro;
						end if;
						raise notice 'listaFacturas.valor_saldo_global_cuota : %',listaFacturas.valor_saldo_global_cuota;	
					end if;	
								
				end if;
				
			end if;
		
		end if;
		
 --		raise notice 'dias_mora: %',listaFacturas.dias_mora;
 --		raise notice 'tasa: %',tasa;
 --		raise notice 'interes_mora: %',listaFacturas.interes_mora;
 --		raise notice 'gac: %',listaFacturas.gac;
 --		raise notice 'valor_saldo_global_cuota: %',listaFacturas.valor_saldo_global_cuota;

		--Si el valor saldo global es igual a 0 este esta pagado
		if (listaFacturas.valor_saldo_global_cuota = 0)then
		
			listaFacturas.estado := 'PAGADO';
		end if;

	RETURN NEXT listaFacturas;
	
   END LOOP; 

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION mc_estado_cuenta_fenalco_2(character varying, character varying, date)
  OWNER TO postgres;

