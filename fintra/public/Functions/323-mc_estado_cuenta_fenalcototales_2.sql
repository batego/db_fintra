-- Function: mc_estado_cuenta_fenalcototales_2(character varying, character varying, date)

-- DROP FUNCTION mc_estado_cuenta_fenalcototales_2(character varying, character varying, date);

CREATE OR REPLACE FUNCTION mc_estado_cuenta_fenalcototales_2(codigo_neg character varying, distrito character varying, fecha_corte date)
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

SaldoVencido_ numeric := 0 ;
capitaCuotasFacturadas_ numeric = 0;
totalSeguro_ numeric = 0;
totalGastoCobranza_ numeric = 0;
totalIxM_ numeric = 0;
TotalPagar_ numeric = 0;
varlorTotal_ numeric := 0;
totalMipyme_ numeric := 0;
numcuotasvencidas_ numeric:= 0;
totalcuotas_ numeric := 0;
cuotaspendientes_ numeric := 0;
diasmora_ numeric := 0;
interes_ numeric := 0;
valorCapital_ numeric := 0;
capitalFuturo_ numeric := 0;
cuotasvencidas_ numeric := 0.00;
interescuotafutura_ numeric := 0;
ixmvencidas_ numeric := 0;
catfuturo_ numeric := 0;
cuotaAdminfuturo_ numeric := 0;
valNegAvalSin numeric = 0;
valorCuota numeric = 0;
facturasVencidas record;
_ConceptRec record;
facturasVencidas_ record;
valorAbono numeric := 0;
valorFactura numeric := 0;

BEGIN

	
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
	

	select into resultado 
			0.00::numeric as valorCapital
			,0.00::numeric as interes
			,0.00::numeric as totalSeguro 
			,0.00::numeric as totalGastoCobranza 
			,0.00::numeric as totalIxM 
			,0.00::numeric as totalMipyme	
			,0.00::numeric as cuotasvencidas
			,0.00::numeric as valorCuotaActual 
			,0.00::numeric as capitalFuturo 
			,0.00::numeric as interescuotafutura  
			,0.00::numeric as cuotaAdminfuturo 
			,0.00::numeric as TotalPagar 
			,''::varchar as cuotaspendientes 
			,0.00::numeric as diasmora
			,0.00::numeric as catfuturo;			
				
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
			       ,0.00::numeric as valor_saldo_factura
			       --,valor_factura
			       ,CASE WHEN (fecha_corte::DATE-fecha::DATE) > 0 THEN 'VENCIDA'
				    WHEN  (fecha_corte::DATE-fecha::DATE) < -30 THEN 'FUTURA'
				    WHEN  (fecha_corte::DATE-fecha::DATE) BETWEEN -30 AND 0 THEN 'CORRIENTE' END::varchar
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


		--SELECT into valorFactura valor from documentos_neg_aceptado where cod_neg = codigo_neg and item = 1;
		--raise notice 'valorFactura: %',valorFactura;
		
		--if(listaFacturas.valor_saldo_cuota < valorFactura) then 
			SELECT into valorAbono sum (valor_abono) 
			FROM con.factura fac
			WHERE negasoc in (codigo_neg,infoNegAval.cod_neg ) 
			AND num_doc_fen::integer = listaFacturas.item::integer 
			AND substring(fac.documento,1,2) not in ('CP','FF','DF') 
			AND valor_saldo >0
			AND fac.reg_status !='A';
			
		--end if;
		
		raise notice 'valor_saldo_cuota: %',listaFacturas.valor_saldo_cuota;
		--Se suma el valor del aval sin financiar en la primera cuota
		if (valNegAvalSin > 0 and listaFacturas.item = 1)then
			raise notice 'listaFacturas.valor_cuota: %,valNegAvalSin: %',listaFacturas.valor_cuota,valNegAvalSin;
			valorCuota := listaFacturas.valor_cuota;
			listaFacturas.valor_cuota := (valNegAvalSin + valorCuota);
		end if;
		if (listaFacturas.valor_saldo_cuota > 0)then 
		
			cuotaspendientes_ := cuotaspendientes_ + 1;
			if (listaFacturas.estado = 'VENCIDA' )then 
				numcuotasvencidas_:= numcuotasvencidas_ + 1;
				cuotasvencidas_ := cuotasvencidas_ + listaFacturas.valor_saldo_cuota;
				raise notice 'cuotasvencidas_: %',cuotasvencidas_;
			end if;	


			
			if(listaFacturas.fecha <= fecha_corte)then 
			
				if (valNegAvalSin > 0 and listaFacturas.item = 1)then
					valorCapital_ := valorCapital_ + listaFacturas.capital + listaFacturas.cuota_manejo + listaFacturas.seguro +valNegAvalSin;
					
				else
					valorCapital_ := valorCapital_ + listaFacturas.capital + listaFacturas.cuota_manejo + listaFacturas.seguro - valorAbono;
				end if;
				raise notice '1*1valorCapital_: %',valorCapital_;
				
				interes_:= interes_ + listaFacturas.interes;
				
				if (listaFacturas.estado = 'CORRIENTE')then 
					resultado.valorCuotaActual := listaFacturas.valor_cuota;
				
				end if;
				--2.)cacular interes x mora
				if(listaFacturas.dias_mora > 0)then
					diasmora_ := diasmora_ + listaFacturas.dias_mora;
					select into tasa tasa_interes from convenios where id_convenio = listaFacturas.convenio;
					listaFacturas.interes_mora :=  round(((listaFacturas.valor_saldo_cuota * tasa)/100 * (fecha_corte::date - listaFacturas.fecha::date)/30),2);
				
				end if;
				
				--3.)calcular Gasto de cobranza
				SELECT INTO unidadNegocio id_unid_negocio FROM rel_unidadnegocio_convenios where id_convenio in (listaFacturas.convenio) and id_unid_negocio in (1,2,3,4,8,10,22,30,31);

				---FACTURAS VENCIDAS

				SELECT into facturasVencidas documento, fecha_vencimiento from con.factura where negasoc = codigo_neg and fecha_vencimiento < fecha_corte and valor_saldo > 0; 
				--raise notice 'facturasVencidas : %',facturasVencidas;	
				--raise notice 'unidadNegocio : %',unidadNegocio;
				
				if (unidadNegocio in (1)) then
				raise notice '****entro2: ';	

					SELECT INTO _ConceptRec * FROM conceptos_recaudo 
					WHERE prefijo = substring(facturasVencidas.documento,1,2) 
					AND (fecha_corte - facturasVencidas.fecha_vencimiento ) BETWEEN dias_rango_ini AND dias_rango_fin 
					AND id_unidad_negocio = unidadNegocio;
					
				else 
			
					
					SELECT into facturasVencidas_ documento, descripcion
					from con.factura_detalle 
					where documento in (select documento 
							    from con.factura  
							    where negasoc = codigo_neg and fecha_vencimiento < fecha_corte and valor_saldo > 0) and descripcion ilike 'CAPITAL%'
					order by descripcion; 

					raise notice 'facturasVencidas_ : %',facturasVencidas_;			    

					SELECT INTO _ConceptRec * FROM conceptos_recaudo 
					WHERE prefijo = substring(facturasVencidas_.descripcion,1,10) 
					AND (fecha_corte - facturasVencidas.fecha_vencimiento ) BETWEEN dias_rango_ini AND dias_rango_fin 
					AND id_unidad_negocio = unidadNegocio;

				end if; 

				
				
				SELECT INTO porcgac coalesce(porcentaje,'0') 
				FROM sanciones_condonaciones 
				WHERE id_tipo_acto = 1 AND id_conceptos_recaudo = _ConceptRec.id 
				AND id_unidad_negocio  =  unidadNegocio
				AND periodo = replace(substring(now(),1,7),'-','')::numeric 
				AND listaFacturas.dias_mora BETWEEN dias_rango_ini AND dias_rango_fin 
				AND categoria = 'GAC' group by porcentaje, dias_rango_ini, dias_rango_fin;
				
				raise notice '_ConceptRec : %',_ConceptRec;	
				raise notice 'porcgac : %',porcgac;
				
				IF FOUND THEN
					listaFacturas.gac := round(((listaFacturas.valor_saldo_cuota * porcgac)/100) ,2);
				else
					listaFacturas.gac := 0.00;
				end if;

				


				--4.)calcular el saldo global
				if (valNegAvalSin > 0 and listaFacturas.item = 1)then
					listaFacturas.valor_saldo_global_cuota := round((listaFacturas.capital + listaFacturas.interes + listaFacturas.cuota_manejo + listaFacturas.seguro + listaFacturas.interes_mora + listaFacturas.gac + listaFacturas.mipyme+valNegAvalSin),2);
				else
					listaFacturas.valor_saldo_global_cuota := round((listaFacturas.capital + listaFacturas.interes + listaFacturas.cuota_manejo + listaFacturas.seguro + listaFacturas.interes_mora + listaFacturas.gac + listaFacturas.mipyme),2);
					listaFacturas.valor_saldo_global_cuota := listaFacturas.valor_saldo_global_cuota - valorAbono;
					/*raise notice '/**listaFacturas.capital : %',listaFacturas.capital;
					raise notice '/**listaFacturas.interes : %',listaFacturas.interes;
					raise notice '/**listaFacturas.cuota_manejo : %',listaFacturas.cuota_manejo;
					raise notice '/**listaFacturas.seguro : %',listaFacturas.seguro;
					raise notice '/**listaFacturas.interes_mora : %',listaFacturas.interes_mora;
					raise notice '/**listaFacturas.gac : %',listaFacturas.gac;
					raise notice '/**listaFacturas.mipyme : %',listaFacturas.mipyme;
					raise notice '/**listaFacturas.item : %',listaFacturas.item;*/
				end if;
				
				
			ELSE 	
				raise notice 'entro2: ';
				fecha1 :=replace((substring (listaFacturas.fecha,1,7)),'-','');
				fecha2 := replace((substring (fecha_corte,1,7)),'-','');
				
			
				
				if ( replace((substring (listaFacturas.fecha,1,7)),'-','') = replace((substring (fecha_corte,1,7)),'-',''))then 
				
					fechaD := (extract (days from (listaFacturas.fecha-(listaFacturas.fecha + interval '0 year -1 mons'))))::int;
					valorInterXDia := listaFacturas.interes/fechaD;
					valorInterXGenerado := round ((valorInterXDia * (extract (days from (fecha_corte -(listaFacturas.fecha + interval '0 year -1 mons'))))::int),2);
					if (valNegAvalSin > 0 and listaFacturas.item = 1)then
						listaFacturas.valor_saldo_global_cuota := listaFacturas.capital + valorInterXGenerado + listaFacturas.cuota_manejo + listaFacturas.mipyme + listaFacturas.seguro + valNegAvalSin;
					else 
						listaFacturas.valor_saldo_global_cuota := listaFacturas.capital + valorInterXGenerado + listaFacturas.cuota_manejo + listaFacturas.mipyme + listaFacturas.seguro;
					end if;	
					interes_:= interes_ + valorInterXGenerado;
					--valorCapital_ := valorCapital_ + listaFacturas.capital + listaFacturas.cuota_manejo + listaFacturas.seguro;
					valorCapital_ := valorCapital_ + listaFacturas.capital  + listaFacturas.seguro;
					raise notice '2*2valorCapital_: %',valorCapital_;
					--raise notice 'interes_: % valorInterXDia: % dias: %',interes_,valorInterXDia,((extract (days from (fecha_corte -(listaFacturas.fecha + interval '0 year -1 mons'))))::int);
					if (listaFacturas.estado = 'FUTURA')then 
						interescuotafutura_ := interescuotafutura_ + valorInterXGenerado;
						cuotaAdminfuturo_ := cuotaAdminfuturo_ + listaFacturas.cuota_manejo + listaFacturas.mipyme + listaFacturas.seguro;
					end if;
			
				else	
	
					if (listaFacturas.estado = 'FUTURA')then 
						listaFacturas.valor_saldo_global_cuota := listaFacturas.capital;
						valorCapital_ := valorCapital_ + listaFacturas.capital;
						
						raise notice '3*3valorCapital_: %',valorCapital_;
			
						
						
					else
					
						fechaD := (extract (days from (listaFacturas.fecha-(listaFacturas.fecha + interval '0 year -1 mons'))))::int;
						valorInterXDia := listaFacturas.interes/fechaD;
						valorInterXGenerado := round ((valorInterXDia * (extract (days from (fecha_corte -(listaFacturas.fecha + interval '0 year -1 mons'))))::int),2);
						if (valNegAvalSin > 0 and listaFacturas.item = 1)then
							listaFacturas.valor_saldo_global_cuota := listaFacturas.capital + listaFacturas.mipyme + valorInterXGenerado + listaFacturas.seguro + valNegAvalSin;	
						else 
							listaFacturas.valor_saldo_global_cuota := listaFacturas.capital + listaFacturas.mipyme + valorInterXGenerado + listaFacturas.seguro;	
						end if;
						valorCapital_ := valorCapital_ + listaFacturas.capital;
						raise notice '4*4valorCapital_: %',valorCapital_;
						interes_:= interes_ + valorInterXGenerado;
						--raise notice 'capital: %,valorInterXGenerado: %,mipyme: %',listaFacturas.capital,valorInterXGenerado,listaFacturas.mipyme;
						--raise notice 'listaFacturas.capital: %',listaFacturas.capital;
						--raise notice 'valorCuotaActual FUTURA : %',resultado.valorCuotaActual;
						

					end if;	
					
				end if;
				
			end if;
			
		
		end if;

		/*if (listaFacturas.estado = 'VENCIDA')then 
			totalMipyme_ :=  listaFacturas.mipyme;
			raise notice '+Vencida totalMipyme_: %',totalMipyme_;			
		end if;*/--Agregado el 17/01/2018
		
		if (listaFacturas.estado = 'FUTURA')then 

			capitalFuturo_ := capitalFuturo_ + listaFacturas.capital;
			raise notice '+capitalFuturo_: %',capitalFuturo_;			
			totalMipyme_ := totalMipyme_ + listaFacturas.mipyme;
			
			
		end if;

		if (listaFacturas.estado = 'CORRIENTE')then 

				--totalMipyme_ := totalMipyme_ + listaFacturas.mipyme; --Aqui sumo el cat corriente porque no lo incluia
				totalSeguro_ := totalSeguro_ + listaFacturas.seguro; --Agrego el seguro porque no lo incluia
				
		
		end if;	

		
		
		if ( ((replace((substring (listaFacturas.fecha,1,7)),'-',''))::int <= (replace((substring (fecha_corte,0,8)),'-',''))::int) and listaFacturas.estado in ( 'FUTURA'))then 
			totalSeguro_ := totalSeguro_ + listaFacturas.seguro;

		end if;
		
		totalGastoCobranza_ := totalGastoCobranza_ + listaFacturas.gac;
		totalIxM_ := totalIxM_ + listaFacturas.interes_mora;
		
		
 --		raise notice 'valorCuotaActual: %',resultado.valorCuotaActual;
-- 		raise notice 'SaldoVencido: %',resultado.SaldoVencido;
-- 		raise notice 'capitaCuotasFacturadas: %',resultado.capitaCuotasFacturadas;
-- 		raise notice 'totalSeguro: %',resultado.totalSeguro;
-- 		raise notice 'totalGastoCobranza: %',resultado.totalGastoCobranza;
-- 		raise notice 'totalIxM: %',resultado.totalIxM;
-- 		raise notice 'mipyme: %',resultado.totalMipyme;
-- 		raise notice 'interes_total: %',interes_;
	
		
		/*if(listaFacturas.fecha > fecha_corte)then
			varlorTotal_ := capitalFuturo_;
		else */
		
			varlorTotal_ := varlorTotal_ + listaFacturas.valor_saldo_global_cuota;
			--raise notice '*/*listaFacturas.valor_saldo_global_cuota : %',listaFacturas.valor_saldo_global_cuota ;
			--raise notice '*varlorTotal_: %',varlorTotal_;
			--raise notice '*listaFacturas.item: %',listaFacturas.item;

			if (listaFacturas.estado = 'CORRIENTE')then 
				resultado.valorCuotaActual := listaFacturas.valor_saldo_global_cuota;-- -  listaFacturas.seguro; --Se agrega pq  lo suma d mas
				--resultado.valorCuotaActual := listaFacturas.valor_cuota;--Modifique este porque no mostraba el valor real de la cuota actual
					raise notice 'listaFacturas.valor_saldo_global_cuota : %',listaFacturas.valor_saldo_global_cuota;
				if(listaFacturas.fecha > fecha_corte)then
					resultado.valorCuotaActual := listaFacturas.valor_saldo_global_cuota-  listaFacturas.seguro - listaFacturas.mipyme;-- - listaFacturas.cuota_manejo; --Se agrega esto porque no debe cobrar CM si no se ha vencido la cuota
					--resultado.valorCuotaActual := listaFacturas.valor_cuota;
					varlorTotal_ := varlorTotal_;-- - listaFacturas.cuota_manejo;--Se agrega esto porque no debe cobrar CM si no se ha vencido la cuota
		--			
				else
				--if(listaFacturas.fecha = fecha_corte) then
					resultado.valorCuotaActual :=listaFacturas.valor_cuota;
				end if;
				
			end if;
		--end if;

	END LOOP; 
	
	varlorTotal_ = varlorTotal_ + totalMipyme_ - valorAbono;-- - listaFacturas.mipyme;-- -listaFacturas.seguro;-- - listaFacturas.mipyme; -- + listaFacturas.seguro; -- Aqui resto el cat corriente porque lo sume en la linea 266
	--raise notice '**///valorAbono: %',valorAbono;	
	
	--resultado.SaldoVencido := SaldoVencido_;
	
	resultado.valorCapital := valorCapital_ + listaFacturas.mipyme;-- +listaFacturas.cuota_manejo; --Agregue el cat porque no lo sumaba
	--raise notice 'resultado.valorCapital : %',resultado.valorCapital ;
	resultado.interes := interes_;
	resultado.totalSeguro := totalSeguro_;
	--raise notice 'resultado.totalSeguro : %',resultado.totalSeguro ;	
	resultado.totalGastoCobranza := totalGastoCobranza_;
	resultado.totalIxM := totalIxM_;
	resultado.totalMipyme := totalMipyme_;
	resultado.cuotasvencidas := cuotasvencidas_;
	--raise notice 'resultado.cuotasvencidas : %',resultado.cuotasvencidas ;		
	resultado.TotalPagar := varlorTotal_;-- - 2612.19;
	resultado.cuotaspendientes := cuotaspendientes_|| ' de '||totalcuotas_ ;
	resultado.diasmora := diasmora_;
	resultado.capitalFuturo := capitalFuturo_;
	raise notice 'resultado.capitalFuturo: %',resultado.capitalFuturo;
	resultado.interescuotafutura := interescuotafutura_;
	resultado.cuotaAdminfuturo := cuotaAdminfuturo_;
	raise notice 'resultado.TotalPagar: %',resultado.TotalPagar;
	RETURN next resultado;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION mc_estado_cuenta_fenalcototales_2(character varying, character varying, date)
  OWNER TO postgres;

