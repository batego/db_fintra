-- Function: con.cambiar_cuentas_reestructuracion_micro_ca_mi()

-- DROP FUNCTION con.cambiar_cuentas_reestructuracion_micro_ca_mi();

CREATE OR REPLACE FUNCTION con.cambiar_cuentas_reestructuracion_micro_ca_mi()
  RETURNS "trigger" AS
$BODY$
DECLARE

negocioViejo varchar:='';

BEGIN


	SELECT into negocioViejo negocio_base from rel_negocios_reestructuracion
      	where negocio_reestructuracion =(SELECT negasoc FROM con.factura  where documento=NEW.documento and tipo_documento='FAC')
	and negocio_reestructuracion like 'MC%';

	PERFORM * from con.factura where negasoc=negocioViejo AND cmc='VM' ;
	   IF(FOUND)THEN
	     raise notice 'entro';

		if(NEW.documento LIKE 'MI%')then --MI

			UPDATE con.factura_detalle SET codigo_cuenta_contable='93950703', user_update='ADMIREES'
			where documento =NEW.documento
			and codigo_cuenta_contable='I010130014169'
			and tipo_documento='FAC';


		elsif(NEW.documento LIKE 'CA%')then --CA

			UPDATE con.factura_detalle SET codigo_cuenta_contable='93950704', user_update='ADMIREES'
			where documento =NEW.documento
			and codigo_cuenta_contable IN ('I010130014144','24080109')
			and tipo_documento='FAC';

		end if;

	   end if;


  RETURN NEW;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.cambiar_cuentas_reestructuracion_micro_ca_mi()
  OWNER TO postgres;
