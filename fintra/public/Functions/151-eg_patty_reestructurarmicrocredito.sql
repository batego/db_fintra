-- Function: eg_patty_reestructurarmicrocredito(character varying)

-- DROP FUNCTION eg_patty_reestructurarmicrocredito(character varying);

CREATE OR REPLACE FUNCTION eg_patty_reestructurarmicrocredito(negociobase character varying)
  RETURNS text AS
$BODY$

DECLARE

retorno varchar:='CARTERA_FINTRA';
negocioViejo varchar:='';
nro_ingreso varchar:='';

BEGIN

	SELECT into negocioViejo negocio_base from rel_negocios_reestructuracion  where negocio_reestructuracion =negociobase;

	raise notice 'negocioViejo : %',negocioViejo;
	--1.)Verificamos si el negocio base esta en cuentas de orden es decir con cmc = 'VM' .
	PERFORM * from con.factura where negasoc=negocioViejo AND cmc='VM' ;
	   IF(FOUND)THEN
		raise notice 'ENTRO ESTA COPA';
		retorno:='CARTERA_VENDIDA';
		--VAMOS A CAMBIAR LAS CUETAS DE LOS SIGUIENTES DOCUMENTOS...
		/**
		* -Nota ajuste capital reestructuracion cabecera
		* -Nota ajuste capital detalle (Gasto Cobranza e Interes Moratorio)
		* -Nota seguro
		* -facturas mi y cat del negocio viejo
		* -Negocio queda hay en veremos...
		* -cuentas de la nueva cartera y hc (Capital, Cat, MI)
		*/

		--A.)
		--NOTA AJUSTE FACTURA CAPITAL POR REESTRUCTURACION
		select into nro_ingreso num_ingreso from con.ingreso WHERE descripcion_ingreso='AJUSTE FACTURA CAPITAL POR REESTRUCTURACION'
		and tipo_referencia_1='NEG' AND referencia_1=negocioViejo ;

		--ACTUALIZAMOS LA CABECERA DEL INGRESO CON LA CUENTA DE ORDEN : 93950521.
		update con.ingreso set cuenta='93950521'
		where num_ingreso=nro_ingreso
		and cuenta='23051101'
		and tipo_referencia_1='NEG' AND descripcion_ingreso='AJUSTE FACTURA CAPITAL POR REESTRUCTURACION'
		AND referencia_1=negocioViejo ;

		--ACTUALIZAMOS EL DETALLE DEL INGRESO  CON LA CUENTA DE ORDEN : 93950702 GAC .
		update con.ingreso_detalle set cuenta='93950702'
		where num_ingreso=nro_ingreso
		and cuenta='I010130014235'
		and tipo_referencia_1='NEG'
		AND referencia_1=negocioViejo ;

		--ACTUALIZAMOS EL DETALLE DEL INGRESO  CON LA CUENTA DE ORDEN : 93950701 IxM .
		update con.ingreso_detalle set cuenta='93950701'
		where num_ingreso=nro_ingreso
		and cuenta='I010130014174'
		and tipo_referencia_1='NEG'
		AND referencia_1=negocioViejo ;


		--B.)NOTA DE SEGURO
		nro_ingreso:='';
		select into nro_ingreso num_ingreso from con.ingreso WHERE descripcion_ingreso='AJUSTE FACTURAS DE SEGURO POR REESTRUCTURACION'
		and tipo_referencia_1='NEG' AND referencia_1=negocioViejo ;

		--ACTUALIZAMOS LA CABECERA DEL INGRESO CON LA CUENTA DE ORDEN : 93950521.
		update con.ingreso set cuenta='93950522'
		where num_ingreso=nro_ingreso
		and cuenta='28150702'
		and tipo_referencia_1='NEG' AND descripcion_ingreso='AJUSTE FACTURAS DE SEGURO POR REESTRUCTURACION'
		AND referencia_1=negocioViejo ;

		--C.)ACTUALIZAMOS EL CAT Y MI GENERADO EN LA NOTA DE HAROLD.
		--Interes MI
		UPDATE con.factura_detalle SET codigo_cuenta_contable='93950703'
		where documento in (select documento from con.factura where
					negasoc=negocioViejo and tipo_documento='FAC'
					AND substring(documento,1,2)='MI' and cmc='CA'
					and descripcion='CXC_INTERES_MC_REESTRUCTURACION')
		and codigo_cuenta_contable='I010130014169'
		and descripcion='INTERESES REESTRUCTURACION';

		UPDATE con.factura set cmc='VM'
		where negasoc=negocioViejo
		and tipo_documento='FAC'
		AND substring(documento,1,2)='MI' and cmc='CA'
		and descripcion='CXC_INTERES_MC_REESTRUCTURACION' ;

		--SEGURO CAT
		UPDATE con.factura_detalle SET codigo_cuenta_contable='93950704'
		where documento in (select documento from con.factura where
					negasoc=negocioViejo and tipo_documento='FAC'
					AND substring(documento,1,2)='CA' and cmc='CA'
					and descripcion='CXC_CAT_MC_REESTRUCTURACION')
		and codigo_cuenta_contable IN ('I010130014144','24080109')
		and descripcion IN ('IMPUESTO CAT REESTRUCTURACION','IVA CAT REESTRUCTURACION');

		UPDATE con.factura set cmc='VM'
		where negasoc=negocioViejo
		and tipo_documento='FAC'
		AND substring(documento,1,2)='CA' and cmc='CA'
		and descripcion='CXC_CAT_MC_REESTRUCTURACION' ;

		--D.)CAMBIAMOS LA CUENTA DE LA NUEVA CARTERA...

		update con.factura_detalle  set  codigo_cuenta_contable ='83251021'
		where documento in (select documento from con.factura where negasoc=negociobase and cmc='CA' AND substring(documento,1,2)='MC')
		and codigo_cuenta_contable='13050801'; --'MC00351'

		update con.factura_detalle  set  codigo_cuenta_contable ='93950522'
		where documento in (select documento from con.factura where negasoc=negociobase and cmc='CA' AND substring(documento,1,2)='MC')
		and codigo_cuenta_contable='28150702'; --'MC00351'

		update con.factura set cmc='VM'
		where negasoc=negociobase and cmc='CA'
		AND substring(documento,1,2)='MC'
		and tipo_documento='FAC' ;

	   end if;



	return retorno;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_patty_reestructurarmicrocredito(character varying)
  OWNER TO postgres;
