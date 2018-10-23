-- Function: mc_negocio_tiempos_fabrica(timestamp without time zone, timestamp without time zone, character varying)

-- DROP FUNCTION mc_negocio_tiempos_fabrica(timestamp without time zone, timestamp without time zone, character varying);

CREATE OR REPLACE FUNCTION mc_negocio_tiempos_fabrica(timestamp without time zone, timestamp without time zone, negocio_ character varying)
  RETURNS text AS
$BODY$
declare 
fecha_uno ALIAS for $1;
fecha_dos ALIAS for $2;
fecha text;

trazabilidad record;
BEGIN

	select into trazabilidad * from negocios_trazabilidad where cod_neg = negocio_ order by fecha desc limit 1;
	raise notice 'trazabilidad: %',trazabilidad;
	
	SELECT  INTO  fecha   CASE WHEN to_char(age(now(), trazabilidad.fecha),'DD') >= '01' THEN 
				
		CASE WHEN 
			--Inicio de la condicion para negocios hechos el sabado y liquidados el lunes--
			EXTRACT(DOW FROM  trazabilidad.fecha) = 6  --preguntamos si es sabado -0 al 6
			AND (now() > substring(trazabilidad.fecha,1,10)||'12:00') --preguntamos si es despues de 16:00 horas  --aqui
			AND to_char(age(now(), trazabilidad.fecha),'DD') = '01' --preguntamos si la diferencia es un dia entre la fechas
			AND (EXTRACT(DOW FROM  now())=1 AND--=1 --preguntamos si se liquido un lunes
			 (SELECT festivo FROM fin.dias_festivos f where substring(f.fecha,1,10)=to_char(now(),'YYYY-MM-DD') ) = false )--que no sea festivo
			 --fin de la condicion.--
		THEN 
			to_char((now() - trazabilidad.fecha) + (to_char(age(now() , trazabilidad.fecha)*24 ,'DD')||' hour')::interval - '40 hours'::interval ,'HH24:MI:ss')
		  
		ELSE 
		--negocios fecha solicitud es un sabado y se liquidad despues del lunes
			CASE WHEN 
			       EXTRACT(DOW FROM  trazabilidad.fecha) = 6 AND 
			       EXTRACT(DOW FROM  now()) > 1 AND 
			       (now() < substring(now(),1,10)||'18:00') ---aqui
			THEN 

				    to_char((now() - trazabilidad.fecha) +
				    (to_char(age(now() , trazabilidad.fecha)*24 ,'DD')||' hour')::interval -
				    ((EXTRACT(DOW FROM  now() )-1)*13||' hour'::varchar)::interval - '40 hour'::interval,'HH24:MI:ss')
			ELSE
				CASE
					   WHEN EXTRACT(DOW FROM  trazabilidad.fecha) = 5 AND (EXTRACT(DOW FROM  now()) >= 1 and EXTRACT(DOW FROM  now()) !=6 ) AND to_char(age( now() , trazabilidad.fecha),'DD')<'08' THEN 

					    to_char((now() - trazabilidad.fecha) +
					    (to_char(age(now() , trazabilidad.fecha)*24 ,'DD')||' hour')::interval -
					    ((EXTRACT(DOW FROM  now() )-1)*13||' hour'::varchar)::interval - '53 hour'::interval,'HH24:MI:ss')

					   WHEN to_char(age( now() , trazabilidad.fecha),'DD')> '01' AND to_char(age( now() , trazabilidad.fecha),'DD')<'08' THEN 
					    
					    to_char((now() - trazabilidad.fecha) +
					    (to_char(age(now() , trazabilidad.fecha)*24 ,'DD')||' hour')::interval -
					    ((to_char(age(now(),trazabilidad.fecha),'DD')::integer -1)*13||' hour'::varchar)::interval ,'HH24:MI:ss')

					   WHEN to_char(age( now() , trazabilidad.fecha),'DD')>='08' AND to_char(age( now() , trazabilidad.fecha),'DD')<'16' THEN 
					    to_char((now() - trazabilidad.fecha) +
					    (to_char(age(now() , trazabilidad.fecha)*24 ,'DD')||' hour')::interval -
					    ((to_char(age(now(),trazabilidad.fecha),'DD')::integer -1)*13||' hour'::varchar)::interval -'40 hour'::interval,'HH24:MI:ss')

					   WHEN to_char(age( now() , trazabilidad.fecha),'DD')>='16' AND to_char(age( now() , trazabilidad.fecha),'DD')<'24' THEN

					    to_char((now() - trazabilidad.fecha) +
					    (to_char(age(now() , trazabilidad.fecha)*24 ,'DD')||' hour')::interval -
					    ((to_char(age(now(),trazabilidad.fecha),'DD')::integer -1)*13||' hour'::varchar)::interval -'80 hour'::interval,'HH24:MI:ss')

					   WHEN to_char(age( now() , trazabilidad.fecha),'DD')>='24' AND to_char(age( now() , trazabilidad.fecha),'DD')<'31' THEN

					     to_char((now() - trazabilidad.fecha) +
					    (to_char(age(now() , trazabilidad.fecha)*24 ,'DD')||' hour')::interval -
					    ((to_char(age(now(),trazabilidad.fecha),'DD')::integer -1)*13||' hour'::varchar)::interval -'120 hour'::interval,'HH24:MI:ss')

					  WHEN to_char(age( now() , trazabilidad.fecha),'DD') = '01' AND to_char(age( now() , trazabilidad.fecha),'HH24') < '13'  THEN 

					    to_char( (now() - trazabilidad.fecha)+
					    (to_char(age (now(),trazabilidad.fecha)*24 ,'DD')||' hour')::interval- '13 hour' ::interval, 'HH24:MI:ss')

					  WHEN to_char(age( now() , trazabilidad.fecha),'DD') = '01' AND to_char(age( now() , trazabilidad.fecha),'HH24') > '13'  THEN 

					     to_char( (now() - trazabilidad.fecha)+
					    (to_char(age (now(),trazabilidad.fecha)*24 ,'DD')||' hour')::interval -
					    ((now() ::DATE- trazabilidad.fecha::DATE)*13||' hour')::interval, 'HH24:MI:ss')
					  
					    

				   END

			   END

		   END
	
	 ELSE 
		 CASE WHEN trazabilidad.fecha <( substring(trazabilidad.fecha,1,10)||'18:00') AND now() < (substring(trazabilidad.fecha,1,10)||'18:00')
		      THEN   
			    to_char( now() ::timestamp -  trazabilidad.fecha ::timestamp,'HH24:MI:SS')
		      ELSE 
			 CASE WHEN trazabilidad.fecha < (substring(trazabilidad.fecha,1,10)||'18:00') AND now() >= (substring(now(),1,10)||'08:00')
			      THEN
				to_char(age(now(), trazabilidad.fecha)- '13 hour','HH24:mi:ss')
			      END 
		      END
					
	   

     END as "TIEMPO (HH:mm:ss)" ;





RETURN fecha; 
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION mc_negocio_tiempos_fabrica(timestamp without time zone, timestamp without time zone, character varying)
  OWNER TO postgres;

