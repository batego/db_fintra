-- Function: informacion_nit()

-- DROP FUNCTION informacion_nit();

CREATE OR REPLACE FUNCTION informacion_nit()
  RETURNS SETOF record AS
$BODY$
DECLARE 

  identificacion record;
  informacion record;
  aux record;
  propietario record;

  
BEGIN
 for   propietario in (select p.identificacion as nit , p.id from etes.propietario_estacion p where reg_status= '' )loop 
	select into identificacion ''::varchar as nit,''::varchar as digito_verificacion
	,replace(replace(replace(replace (propietario.nit,'-',''),'.',''),' ',''),'_','')::varchar as nit_completo;

	select into identificacion.nit substring (identificacion.nit_completo,1,9);

	if ( length(identificacion.nit_completo) > 9 ) then
		select into identificacion.digito_verificacion substr(identificacion.nit_completo, 10, 1);
	end if;

	select into informacion 0::integer as cantidad,
			''::character varying as codcli,
			''::character varying as id_propietario,
			''::character varying as idusuario,
			''::character varying as nit_proveedor;
	
	for aux in (select proveedor.nit from proveedor where replace(replace(replace(replace (proveedor.nit,'-',''),'.',''),' ',''),'_','') like identificacion.nit||'%' and reg_status='')
	loop
	informacion.cantidad = informacion.cantidad + 1;
	
	informacion.nit_proveedor = aux.nit;
	
	end loop;

	select into  informacion.codcli  codcli from cliente  where cliente.nit = informacion.nit_proveedor and reg_status ='' and estado ='A';
	select into  informacion.idusuario idusuario from usuarios where usuarios.nit = informacion.nit_proveedor and estado ='A';
	informacion.id_propietario = propietario.id;

	return next informacion;
	end loop ;
END; 
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION informacion_nit()
  OWNER TO postgres;

