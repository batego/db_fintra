-- Function: mc_duracion_negocio_etapa(character varying, character varying)

-- DROP FUNCTION mc_duracion_negocio_etapa(character varying, character varying);

CREATE OR REPLACE FUNCTION mc_duracion_negocio_etapa(negocio_ character varying, etapa_ character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE

informacion record;
trazabilidad record;
fechas_ varchar[];

tiempo varchar;
calculoParcial varchar;

calculo interval;
subTotalDias interval;

dias numeric;
hora numeric;
horaHoy numeric;
horasNoche numeric :=7;
horasDia numeric := 8;
sumHoras numeric;

BEGIN		
		select into trazabilidad * from negocios_trazabilidad where cod_neg = negocio_ order by fecha desc limit 1;
		trazabilidad.fecha := '2017-02-18 11:00:00';
		raise notice 'trazabilidad: %',trazabilidad;

		dias := (select count(0) 
			from fin.dias_festivos 
			where fecha::date between trazabilidad.fecha::date and now()::date 
			and festivo = false)::numeric;
			
		raise notice 'dias: %',dias;

		hora:= (extract(hour from  trazabilidad.fecha))::numeric;
		horaHoy:= (extract(hour from  now()))::numeric;
		raise notice 'hora: %',hora;
		raise notice 'horaHoy: %',horaHoy;
		
		if(dias = 1)then
			
			if(hora < 12 and horaHoy >=14)then
				calculo := (now()-trazabilidad.fecha)-interval ' 1 hour 30 min 0 s';
				raise notice 'calculo despues: %',calculo;
			else
				calculo := (now()-trazabilidad.fecha);
			end if;

		else 
			--dias:= dias -1;
			--raise notice 'dias: %',dias;
			
			SELECT into fechas_ 
			ARRAY(
				SELECT fecha 
				from fin.dias_festivos 
				where fecha::date between trazabilidad.fecha::date and now()::date 
				and festivo = false
				);
			raise notice 'fechas_: %',fechas_;
			
			for i in 1.. 
				dias
			loop 
				if (i=1)then 
					raise notice 'entro SI 1';
					if(EXTRACT(DOW FROM trazabilidad.fecha)=6)then
						calculo := (substring (trazabilidad.fecha,1,11)||'12:30:00')::timestamp -trazabilidad.fecha ;
 					else
						if(hora < 12)then
							calculo := ((substring (trazabilidad.fecha,1,11)||'18:00:00')::timestamp - trazabilidad.fecha)-('1 hour 30 min 0 s')::interval ;
						else
							calculo := ((substring (trazabilidad.fecha,1,11)||'18:00:00')::timestamp - trazabilidad.fecha);
						end if;
						
					end if;
					raise notice 'calculo: %',calculo||' '||i;
 				else		
					raise notice 'entro SI 2';
					if (i = dias)then 
						raise notice 'entro SI 2.1';
						if(EXTRACT(DOW FROM fechas_[i]::date ) = 6)then
							raise notice 'entro SI 2.1.1';
							calculo := calculo +((substring (now(),1,11)||'12:30:00')::timestamp - (substring (fechas_[i],1,11)||'08:00:00')::timestamp)::interval ;
							
						else	
							raise notice 'entro SI 2.1.2';
							if((extract(hour from  now()))::numeric > 18)then
								calculo := calculo + ((substring (now(),1,11)||'18:00:00')::timestamp - (substring (fechas_[i],1,11)||'08:00:00')::timestamp)::interval ;
							else 
								calculo := calculo+ (now()::timestamp - (substring (fechas_[i],1,11)||'08:00:00')::timestamp)::interval ;
							end if;
							
						end if;
					else
						raise notice 'entro SI 2.2';
						if(EXTRACT(DOW FROM fechas_[i]::date ) = 6)then
							calculo := calculo + ((substring (fechas_[i],1,11)||'12:30:00')::timestamp - (substring (fechas_[i],1,11)||'08:00:00')::timestamp )::interval;
						else
						
						subTotalDias := (((substring (fechas_[i]::date ,1,11)||' 18:00:00')::timestamp)-(substring (fechas_[i],1,11)||' 08:00:00')::timestamp)-('1 hour 30 min 0 s')::interval ;
						calculo := calculo + subTotalDias;
				
						end if;
						raise notice 'subTotalDias: %',subTotalDias;
						
					end if;
					
					
					raise notice 'calculo: %',calculo||' '||i;
				end if;
				
				
			end loop;
			raise notice 'calculo final: %',calculo;

		end if;
		
		--tiempo := calculo;
			

			
		
		
		for informacion in 
			select  trazabilidad.cod_neg::varchar as negocio, trazabilidad.fecha::varchar as fecha_ingreso, tiempo::varchar 
		loop

		  return next informacion;
		end loop;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION mc_duracion_negocio_etapa(character varying, character varying)
  OWNER TO postgres;

