-- Function: get_tiempos_fabrica(timestamp without time zone, timestamp without time zone)

-- DROP FUNCTION get_tiempos_fabrica(timestamp without time zone, timestamp without time zone);

CREATE OR REPLACE FUNCTION get_tiempos_fabrica(timestamp without time zone, timestamp without time zone)
  RETURNS text AS
$BODY$
declare
fecha_uno ALIAS for $1;
fecha_dos ALIAS for $2;
fecha text;

BEGIN
---obtenemos la primera fehca de pago y el dia de la primera couta partir del codigo del negocio---

     ---Preguntamos si la diferencai entre la fehca de sulicitud y la de liquidacion es mayor o igual a un dia
    SELECT  INTO  fecha   CASE WHEN to_char(age($1, $2),'DD') >= '01' THEN
		      --preguntamos si es mayor a un dia por que es sabado
		      CASE WHEN

			 --Inicio de la condicion para negocios hechos el sabado y liquidados el lunes--
			 EXTRACT(DOW FROM  $2) = 6  --preguntamos si es sabado -0 al 6
			 AND ($1 > substring($2,1,10)||'16:00') --preguntamos si es despues de 16:00 horas
			 AND to_char(age($1, $2),'DD') = '01' --preguntamos si la diferencia es un dia entre la fechas
			 AND (EXTRACT(DOW FROM  $1)=1 AND--=1 --preguntamos si se liquido un lunes
			     (SELECT festivo FROM fin.dias_festivos f where substring(f.fecha,1,10)=to_char($1,'YYYY-MM-DD') ) = false )--que no sea festivo
			 --fin de la condicion.--

			  THEN

			      to_char(($1 - $2) + (to_char(age($1 , $2)*24 ,'DD')||' hour')::interval - '40 hours'::interval ,'HH24:MI:ss')

			  ELSE
			   --negocios fecha solicitud es un sabado y se liquidad despues del lunes
			      CASE WHEN
				       EXTRACT(DOW FROM  $2) = 6 AND
				       EXTRACT(DOW FROM  $1) > 1 AND
				       ($1 < substring($1,1,10)||'19:00')
				   THEN

					    to_char(($1 - $2) +
					    (to_char(age($1 , $2)*24 ,'DD')||' hour')::interval -
					    ((EXTRACT(DOW FROM  $1 )-1)*13||' hour'::varchar)::interval - '40 hour'::interval,'HH24:MI:ss')
			           ELSE
                                          CASE
						   WHEN EXTRACT(DOW FROM  $2) = 5 AND (EXTRACT(DOW FROM  $1) >= 1 and EXTRACT(DOW FROM  $1) !=6 ) AND to_char(age( $1 , $2),'DD')<'08' THEN

						    to_char(($1 - $2) +
						    (to_char(age($1 , $2)*24 ,'DD')||' hour')::interval -
						    ((EXTRACT(DOW FROM  $1 )-1)*13||' hour'::varchar)::interval - '53 hour'::interval,'HH24:MI:ss')

						   WHEN to_char(age( $1 , $2),'DD')> '01' AND to_char(age( $1 , $2),'DD')<'08' THEN

						    to_char(($1 - $2) +
						    (to_char(age($1 , $2)*24 ,'DD')||' hour')::interval -
						    ((to_char(age($1,$2),'DD')::integer -1)*13||' hour'::varchar)::interval ,'HH24:MI:ss')

						   WHEN to_char(age( $1 , $2),'DD')>='08' AND to_char(age( $1 , $2),'DD')<'16' THEN
						    to_char(($1 - $2) +
						    (to_char(age($1 , $2)*24 ,'DD')||' hour')::interval -
						    ((to_char(age($1,$2),'DD')::integer -1)*13||' hour'::varchar)::interval -'40 hour'::interval,'HH24:MI:ss')

						   WHEN to_char(age( $1 , $2),'DD')>='16' AND to_char(age( $1 , $2),'DD')<'24' THEN

						    to_char(($1 - $2) +
						    (to_char(age($1 , $2)*24 ,'DD')||' hour')::interval -
						    ((to_char(age($1,$2),'DD')::integer -1)*13||' hour'::varchar)::interval -'80 hour'::interval,'HH24:MI:ss')

						   WHEN to_char(age( $1 , $2),'DD')>='24' AND to_char(age( $1 , $2),'DD')<'31' THEN

						     to_char(($1 - $2) +
						    (to_char(age($1 , $2)*24 ,'DD')||' hour')::interval -
						    ((to_char(age($1,$2),'DD')::integer -1)*13||' hour'::varchar)::interval -'120 hour'::interval,'HH24:MI:ss')

						  WHEN to_char(age( $1 , $2),'DD') = '01' AND to_char(age( $1 , $2),'HH24') < '13'  THEN

					            to_char( ($1 - $2)+
					            (to_char(age ($1,$2)*24 ,'DD')||' hour')::interval- '13 hour' ::interval, 'HH24:MI:ss')

						  WHEN to_char(age( $1 , $2),'DD') = '01' AND to_char(age( $1 , $2),'HH24') > '13'  THEN

						     to_char( ($1 - $2)+
					            (to_char(age ($1,$2)*24 ,'DD')||' hour')::interval -
					            (($1 ::DATE- $2::DATE)*13||' hour')::interval, 'HH24:MI:ss')



					   END

				   END

			   END

                 ELSE
                         CASE WHEN $2 <( substring($2,1,10)||'20:00') AND $1 < (substring($2,1,10)||'20:00')
                              THEN
                                    to_char( $1 ::timestamp -  $2 ::timestamp,'HH24:MI:SS')
                              ELSE
                                 CASE WHEN $2 < (substring($2,1,10)||'19:00') AND $1 >= (substring($1,1,10)||'08:00')
                                      THEN
					 to_char(age($1, $2)- '13 hour','HH24:mi:ss')
                                      END
                              END



             END as "TIEMPO (HH:mm:ss)" ;





RETURN fecha;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_tiempos_fabrica(timestamp without time zone, timestamp without time zone)
  OWNER TO postgres;
