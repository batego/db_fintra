-- Function: insert_presolicitud_trazanegocio()

-- DROP FUNCTION insert_presolicitud_trazanegocio();

CREATE OR REPLACE FUNCTION insert_presolicitud_trazanegocio()
  RETURNS text AS
$BODY$
DECLARE
Presolicitudes record;
retorno text:='OK';
       
BEGIN	
        
        --Consultamos las presolicitudes

        FOR Presolicitudes IN
        
		SELECT numero_solicitud, 
		       entidad, 
		       afiliado, 
		       valor_cuota, 
		       valor_aval, 
		       fecha_credito, 
		       monto_credito, 
		       numero_cuotas, 
		       fecha_pago, 
		       tipo_identificacion, 
		       identificacion, 
		       fecha_expedicion, 
		       primer_nombre, 
		       primer_apellido, 
		       fecha_nacimiento, 
		       email, 
		       ingresos_usuario, 
		       id_convenio, 
		       CASE WHEN estado_sol='P' THEN 'PRE APROBADO'
			    WHEN estado_sol='R' THEN 'RECHAZADO'
			    WHEN estado_sol='B' THEN 'ERROR CALCULO BURO'
			    WHEN estado_sol='S' THEN 'MONTO SUGERIDO'
			    WHEN estado_sol='C' THEN 'NO COMPLETADO'
			    WHEN estado_sol='Z' THEN 'ZONA GRIS'
			END AS estado_solicitud,
		       codigorespuesta, 
		       score, clasificacion, comentario, empresa, etapa, acepta_terminos, 
		       extracto_electronico, recoge_firmas, asesor, creation_date, creation_user, 
		       last_update, user_update, total_obligaciones_financieras, total_gastos_familiares, 
		       telefono, financia_aval, tipo_cliente, ciudad, lat, lng, rechazo_operaciones, 
		       departamento
		  FROM apicredit.pre_solicitudes_creditos
		  --WHERE numero_solicitud in (select numero_solicitud from solicitud_aval)
		  WHERE entidad = 'MICROCREDITO'
		  

	LOOP	  


        --Insertamos detalle cxp
        INSERT INTO apicredit.pre_solicitudes_trazabilidad(dstrct, numero_solicitud, estado, actividad, usuario, fecha)
	VALUES ('FINV',Presolicitudes.numero_solicitud, Presolicitudes.estado_solicitud,'PRESOL',Presolicitudes.creation_user,Presolicitudes.creation_date);
	raise notice 'numero_solicitud: %', Presolicitudes.numero_solicitud;

       
       

       

       END LOOP;

       RETURN retorno;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION insert_presolicitud_trazanegocio()
  OWNER TO postgres;

