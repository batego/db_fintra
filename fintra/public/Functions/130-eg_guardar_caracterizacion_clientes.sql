-- Function: eg_guardar_caracterizacion_clientes(character varying)

-- DROP FUNCTION eg_guardar_caracterizacion_clientes(character varying);

CREATE OR REPLACE FUNCTION eg_guardar_caracterizacion_clientes(_creation_user character varying)
  RETURNS text AS
$BODY$

DECLARE
_contador integer:=0;
_idUnidadegocio INTEGER:=0;
_nombreUnidad VARCHAR:='';
_periodo INTEGER :=(SELECT REPLACE(SUBSTRING(now(),1,7),'-',''))::INTEGER;
rs TEXT:='/*********************************************** LOG DE PROCESOS CLASIFICACION CLIENTES **********************************************/ '||E'\n';

BEGIN

	raise notice '_periodo: %',_periodo;

	FOR _idUnidadegocio IN SELECT id FROM unidad_negocio WHERE ref_4 !='' --AND cod in ('EDUB','EDUA')
	LOOP
		_contador=_contador+1;
		select into _nombreUnidad descripcion from unidad_negocio where id = _idUnidadegocio;

		PERFORM * from administrativo.clasificacion_clientes_fintracredit where periodo=_periodo and id_unidad_negocio=_idUnidadegocio;
		IF (NOT FOUND )THEN

			INSERT INTO administrativo.clasificacion_clientes_fintracredit(
				    id_unidad_negocio, periodo, negasoc,
				    cedula_deudor, nombre_deudor, telefono, celular, direccion, barrio,
				    ciudad, email, cedula_codeudor, nombre_codeudor, telefono_codeudor,
				    celular_codeudor, id_convenio, afiliado, tipo, fecha_desembolso,
				    clasificacion, fecha_ult_pago, dias_ultimo_pago, altura_mora_maxima,
				    altura_mora_actual, numero_cuotas, cuotas_pagadas, cuotas_xpagar,
				    cuotas_restantes_xpagar, vr_negocio, valor_factura, valor_saldo,
				    porcentaje_cump, valor_preaprobado,creation_user)
			SELECT  id_unidad_negocio, periodo, negasoc,
				cedula_deudor, nombre_deudor, telefono, celular, direccion, barrio,
				ciudad, email, cedula_codeudor, nombre_codeudor, telefono_codeudor,
				celular_codeudor, id_convenio, afiliado, tipo, fecha_desembolso,
				clasificacion, fecha_ult_pago, dias_pagos as dias_ultimo_pago, altura_mora_maxima,
				altura_mora_actual,  cuotas as numero_cuotas, cuotas_pagadas, cuotas_xpagar,
				(cuotas-cuotas_pagadas) as cuotas_restantes_xpagar, vr_negocio, valor_factura, valor_saldo,
				porcentaje as porcentaje_cump , valor_preaprobado ,_creation_user

			FROM eg_caracterizacion_clientes(_idUnidadegocio)
			--WHERE clasificacion !='SIN CRITERIOS DE TIPO PARA CLASIFICAR'
			ORDER BY Clasificacion,altura_mora_maxima,altura_mora_actual,porcentaje,negasoc;

			rs=rs||_contador ||'.) SE HA GENERADO EL PREAPROBADO DEL MES PARA LA UNIDAD DE NEGOCIO '||_nombreUnidad||' EN EL PERIODO '||_periodo ||E'\n';



		ELSE
			rs=rs||_contador ||'.) YA ESTA GENERADO EL PREAPROBADO DEL MES PARA LA UNIDAD DE NEGOCIO '||_nombreUnidad||' EN EL PERIODO '||_periodo||E'\n';
		END IF;
	END LOOP;


	return rs;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_guardar_caracterizacion_clientes(character varying)
  OWNER TO postgres;
