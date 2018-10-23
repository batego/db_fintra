-- Function: mc_estado_cuenta_fenalcototales(character varying, character varying, date)

-- DROP FUNCTION mc_estado_cuenta_fenalcototales(character varying, character varying, date);

CREATE OR REPLACE FUNCTION mc_estado_cuenta_fenalcototales(codigo_neg character varying, distrito character varying, fecha_corte date)
  RETURNS SETOF record AS
$BODY$
DECLARE

listaFacturas record;
infoNegAval record;
infoDocNegAceptAval record;
resultado record;

unidadNegocio integer;
financia_aval_ boolean;
tasa numeric;
porcgac numeric;
fechaD int;
valorInterXDia numeric;
valorInterXGenerado numeric;

fecha1 varchar;
fecha2 varchar;

valorCuotaActual_ numeric;
SaldoVencido_ numeric := 0 ;
capitaCuotasFacturadas_ numeric = 0;
totalSeguro_ numeric = 0;
totalGastoCobranza_ numeric = 0;
totalIxM_ numeric = 0;
TotalPagar_ numeric = 0;
varlorTotal_ numeric := 0;
totalMipyme_ numeric := 0;
cuotasvencidas_ numeric:= 0;
totalcuotas_ numeric := 0;
cuotaspendientes_ numeric := 0;
diasmora_ numeric := 0;
interes_ numeric := 0;
valorC_ numeric := 0;

BEGIN

   --SELECT INTO fechaAnterior fecha_negocio FROM negocios WHERE cod_neg= codigo_neg;
   select into infoNegAval *  FROM negocios  where negocio_rel = codigo_neg;
   select into financia_aval_ financia_aval  FROM negocios  where cod_neg = codigo_neg;
   --raise notice 'infoNegAval: %',infoNegAval.cod_neg;

	select into resultado 0.00::numeric as valorCuotaActual 
			,0.00::numeric as valorC 
			,0.00::numeric as SaldoVencido 
			,0.00::numeric as capitaCuotasFacturadas 
			,0.00::numeric as totalSeguro 
			,0.00::numeric as interes
			,0.00::numeric as totalGastoCobranza 
			,0.00::numeric as totalIxM 
			,0.00::numeric as totalMipyme	
			,0.00::numeric as TotalPagar
			,0::numeric as cuotasvencidas	
			,0::varchar as cuotaspendientes
			,0::numeric as diasmora;	
	
			

	FOR listaFacturas IN (
			 
			SELECT fecha::DATE
			       ,neg.id_convenio::varchar as convenio
			       ,item::varchar
			       ,(fecha_corte::DATE-fecha::DATE) as dias_mora
			       ,sum (saldo_inicial)::numeric
			       ,sum (valor)::numeric as valor_cuota
			       ,0.00::numeric as valor_saldo_cuota
			       ,sum (capital)::numeric AS capital
			       ,sum (interes)::numeric as interes
			       ,sum (seguro)::numeric as seguro
			       ,sum (cat)::numeric as mipyme
			       ,sum (dna.cuota_manejo)::numeric as cuota_manejo
			       ,0.00::numeric as interes_mora
			       ,0.00::numeric as gac
			       ,0.00::numeric as valor_saldo_global_cuota
			       ,CASE WHEN (now()::DATE-fecha::DATE) > 0 THEN 'VENCIDA'
				    WHEN  (now()::DATE-fecha::DATE) < -30 THEN 'FUTURA'
				    WHEN  (now()::DATE-fecha::DATE) BETWEEN -30 AND 0 THEN 'CORRIENTE' END::varchar
				AS estado
			  FROM documentos_neg_aceptado dna  
			  INNER JOIN negocios neg on (neg.cod_neg=dna.cod_neg)
			  WHERE neg.cod_neg in( codigo_neg,infoNegAval.cod_neg) AND neg.estado_neg in ('T','A')
                          group by fecha,neg.id_convenio,item
			  order by fecha asc 
			
			)
	LOOP	
		totalcuotas_ := totalcuotas_ + 1;

		--1.)calcular valor saldo cuota
		SELECT into listaFacturas.valor_saldo_cuota sum (valor_saldo) 
		FROM con.factura fac
		WHERE negasoc in (codigo_neg,infoNegAval.cod_neg ) 
		AND num_doc_fen::integer = listaFacturas.item::integer 
		AND substring(fac.documento,1,2) not in ('CP','FF','DF') 
		AND fac.reg_status !='A';

		--raise notice 'valor_saldo_cuota: %',listaFacturas.valor_saldo_cuota;
		
		if (listaFacturas.valor_saldo_cuota > 0)then 
			cuotaspendientes_ := cuotaspendientes_ + 1;

			if (listaFacturas.estado = 'VENCIDA' )then 
				cuotasvencidas_:=cuotasvencidas_ + 1;
			end if;	
			
			if(listaFacturas.fecha < fecha_corte)then 
				interes_:= interes_ + listaFacturas.interes;

				if (listaFacturas.estado = 'CORRIENTE')then 
					resultado.valorCuotaActual := listaFacturas.valor_saldo_cuota;
					resultado.valorC := listaFacturas.capital;
				end if;
				
				--2.)cacular interes x mora
				if(listaFacturas.dias_mora > 0)then
					diasmora_ := diasmora_ + listaFacturas.dias_mora;
					select into tasa tasa_interes from convenios where id_convenio = listaFacturas.convenio;
					--raise notice 'tasa: %',tasa;
					listaFacturas.interes_mora :=  round(((listaFacturas.valor_saldo_cuota * tasa)/100 * (fecha_corte::date - listaFacturas.fecha::date)/30),2);
					--raise notice 'listaFacturas.interes_mora: %',listaFacturas.interes_mora;
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
					listaFacturas.gac := round(((listaFacturas.valor_saldo_cuota * porcgac)/100) ,2);
				else
					listaFacturas.gac := 0.00;
				end if;
				
				--4.)calcular el saldo global
				listaFacturas.valor_saldo_global_cuota := round((listaFacturas.valor_saldo_cuota + listaFacturas.interes_mora + listaFacturas.gac + listaFacturas.mipyme),2);
				--raise notice 'listaFacturas.valor_saldo_global_cuota: %',listaFacturas.valor_saldo_global_cuota; 
			ELSE 	
				fecha1 :=replace((substring (listaFacturas.fecha,1,7)),'-','');
				fecha2 := replace((substring (fecha_corte,1,7)),'-','');
				--raise notice 'fecha1 : %,fecha2corte : %',fecha1,fecha2;

				if ( replace((substring (listaFacturas.fecha,1,7)),'-','') <= replace((substring (fecha_corte,1,7)),'-',''))then 
-- 					raise notice 'entro si : %',listaFacturas.item;
					fechaD := (extract (days from (listaFacturas.fecha-(listaFacturas.fecha + interval '0 year -1 mons'))))::int;
					valorInterXDia := listaFacturas.interes/fechaD;
					valorInterXGenerado := round ((valorInterXDia * (extract (days from (fecha_corte -(listaFacturas.fecha + interval '0 year -1 mons'))))::int),2);
					listaFacturas.valor_saldo_global_cuota := listaFacturas.capital + valorInterXGenerado + listaFacturas.cuota_manejo + listaFacturas.mipyme;
					interes_:= interes_ + valorInterXGenerado;
					--raise notice 'capital: %,valorInterXGenerado: %,cuota_manejo: %',listaFacturas.capital,valorInterXGenerado,listaFacturas.cuota_manejo; 
				else 
-- 					raise notice 'entro no : %',listaFacturas.item;
					fechaD := (extract (days from (listaFacturas.fecha-(listaFacturas.fecha + interval '0 year -1 mons'))))::int;
					valorInterXDia := listaFacturas.interes/fechaD;
					valorInterXGenerado := round ((valorInterXDia * (extract (days from (fecha_corte -(listaFacturas.fecha + interval '0 year -1 mons'))))::int),2);
					listaFacturas.valor_saldo_global_cuota := listaFacturas.capital + listaFacturas.mipyme + valorInterXGenerado;	
					interes_:= interes_ + valorInterXGenerado;			
				end if;
				--raise notice 'listaFacturas.valor_saldo_global_cuota: %',listaFacturas.valor_saldo_global_cuota; 

			end if;
				if (listaFacturas.estado = 'CORRIENTE')then 
					resultado.valorCuotaActual := listaFacturas.valor_saldo_global_cuota;
				end if;
		end if;



		if (listaFacturas.estado = 'VENCIDA')then 
			SaldoVencido_ := SaldoVencido_ + listaFacturas.valor_saldo_cuota;
		end if;	
	
		if (listaFacturas.estado = 'FUTURA')then 
			capitaCuotasFacturadas_ := capitaCuotasFacturadas_ + listaFacturas.capital;
		end if;	
		
		if ( (replace((substring (listaFacturas.fecha,1,7)),'-',''))::int <= (replace((substring (fecha_corte,0,8)),'-',''))::int)then 
			totalSeguro_ := totalSeguro_ + listaFacturas.seguro;
		end if;
		
		totalGastoCobranza_ := totalGastoCobranza_ + listaFacturas.gac;
		totalIxM_ := totalIxM_ + listaFacturas.interes_mora;
		totalMipyme_ := totalMipyme_ + listaFacturas.mipyme;
		
-- 		raise notice 'valorCuotaActual: %',resultado.valorCuotaActual;
-- 		raise notice 'SaldoVencido: %',resultado.SaldoVencido;
-- 		raise notice 'capitaCuotasFacturadas: %',resultado.capitaCuotasFacturadas;
-- 		raise notice 'totalSeguro: %',resultado.totalSeguro;
-- 		raise notice 'totalGastoCobranza: %',resultado.totalGastoCobranza;
-- 		raise notice 'totalIxM: %',resultado.totalIxM;
-- 		raise notice 'mipyme: %',resultado.totalMipyme;
-- 		raise notice 'interes_total: %',interes_;

		
		varlorTotal_ := varlorTotal_ + listaFacturas.valor_saldo_global_cuota;

	END LOOP; 
	--raise notice 'cuotasvencidas_: %',cuotasvencidas_;
	resultado.SaldoVencido := SaldoVencido_;
	resultado.capitaCuotasFacturadas := capitaCuotasFacturadas_;
	resultado.totalSeguro := totalSeguro_;
	resultado.totalGastoCobranza := totalGastoCobranza_;
	resultado.totalIxM := totalIxM_;
	resultado.totalMipyme := totalMipyme_;
	resultado.TotalPagar := varlorTotal_;
	resultado.cuotasvencidas := cuotasvencidas_;
	resultado.cuotaspendientes := cuotaspendientes_|| ' de '||totalcuotas_ ;
	resultado.diasmora := diasmora_;
	resultado.interes := interes_;
	RETURN next resultado;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION mc_estado_cuenta_fenalcototales(character varying, character varying, date)
  OWNER TO postgres;

