-- Function: etes.colocacion_fintra_logistica(character varying, character varying, character varying, integer)

-- DROP FUNCTION etes.colocacion_fintra_logistica(character varying, character varying, character varying, integer);

CREATE OR REPLACE FUNCTION etes.colocacion_fintra_logistica(manifiesto character varying, fecha_inicio character varying, fecha_final character varying, id_estacion integer)
  RETURNS SETOF etes.type_colocacion_logistica AS
$BODY$
DECLARE

 recordColocacion record;
 retorno etes.type_colocacion_logistica ;
 _planilla varchar:='';
 _disponibleVenta numeric:=0;

BEGIN

  for recordColocacion in
			SELECT
				     anticipo.id
				    ,anticipo.periodo
				    ,trans.razon_social as transportadora
				    ,agencia.nombre_agencia
				    ,propietario.cod_proveedor as cedula_propietario
				    ,propietario.nombre as propietario
				    ,conductor.cod_proveedor as cedula_conductor
				    ,conductor.nombre as conductor
				    ,vehiculo.placa
				    ,conductor.sucursal
				    ,anticipo.origen
				    ,anticipo.destino
				    ,anticipo.planilla
				    ,to_char(ventas.fecha_venta::timestamp,'YYYY-MM-DD HH24:MM:SS')::timestamp as fecha_venta
				    ,to_char(anticipo.creation_date::timestamp,'YYYY-MM-DD HH24:MM:SS')::timestamp as fecha_anticipo
				    ,eg_obtenerhorafecha(ventas.fecha_venta,anticipo.creation_date)as tiempo_legalizacion
				    ,anticipo.valor_neto_anticipo+coalesce((select sum(mr.valor_reanticipo) from etes.manifiesto_reanticipos mr where mr.reg_status = '' and mr.id_manifiesto_carga=anticipo.id),0)  as valor_anticipo
				    ,anticipo.valor_descuentos_fintra+coalesce((select sum(mr.valor_descuentos_fintra) from etes.manifiesto_reanticipos mr where mr.reg_status = '' and mr.id_manifiesto_carga=anticipo.id),0) as descuentos_fintra
				    ,anticipo.valor_desembolsar+coalesce((select sum(mr.valor_desembolsar) from etes.manifiesto_reanticipos mr where mr.reg_status = '' and mr.id_manifiesto_carga=anticipo.id),0) as valor_consignacion
				    ,anticipo.reanticipo
				    ,ventas.num_venta
				    ,estacion.nombre_eds
				    ,ventas.kilometraje
				    ,producto.descripcion
				    ,coalesce(precio_producto_xunidadmedida,0) as precioxUnidad
				    ,coalesce(ventas.cantidad_suministrada,0) as cantidad_suministrada
				    ,coalesce(sum(ventas.total_venta),0) as total_venta
				    ,0.0::numeric as disponible --((anticipo.valor_desembolsar+coalesce((select sum(valor_desembolsar) from etes.manifiesto_reanticipos where reg_status = '' and planilla ilike anticipo.planilla||'%'),0)) - coalesce (sum(ventas.total_venta),0)) as disponible
			FROM etes.manifiesto_carga as anticipo
			    INNER JOIN etes.agencias as agencia on(agencia.id=anticipo.id_agencia)
			    INNER JOIN etes.vehiculo as vehiculo on(vehiculo.id=anticipo.id_vehiculo)
			    INNER JOIN etes.transportadoras as trans on (agencia.id_transportadora=trans.id)
			    INNER JOIN etes.conductor as conductor on (anticipo.id_conductor=conductor.id)
			    INNER JOIN etes.propietario as propietario on (vehiculo.id_propietario=propietario.id)
			    LEFT JOIN etes.ventas_eds as ventas on (anticipo.id = ventas.id_manifiesto_carga)
			    LEFT JOIN etes.estacion_servicio as estacion on (estacion.id = ventas.id_eds)
                            left join etes.productos_es  as producto on (ventas.id_producto=producto.id)
			WHERE
				anticipo.reg_status = '' --and anticipo.planilla=planilla
				and case when ( fecha_inicio !='' and fecha_inicio !='' ) then  anticipo.creation_date::date  between fecha_inicio::date AND fecha_final::date else true end
				and case when id_estacion != 0 then estacion.id =id_estacion else true end
				and case when manifiesto !='' then anticipo.planilla=manifiesto else true end
			GROUP BY
			     anticipo.id
			    ,anticipo.periodo
			    ,trans.razon_social
			    ,agencia.nombre_agencia
			    ,propietario.cod_proveedor
			    ,propietario.nombre
			    ,conductor.cod_proveedor
			    ,conductor.nombre
			    ,vehiculo.placa
			    ,conductor.sucursal
			    ,anticipo.origen
			    ,anticipo.destino
			    ,anticipo.planilla
			    ,ventas.fecha_venta
			    ,anticipo.creation_date
			    ,anticipo.valor_neto_anticipo
			    ,anticipo.valor_descuentos_fintra
			    ,anticipo.valor_desembolsar
			    ,anticipo.reanticipo
			    ,ventas.num_venta
			    ,estacion.nombre_eds
			    ,ventas.kilometraje
			    ,producto.descripcion
			    ,precio_producto_xunidadmedida
			    ,ventas.cantidad_suministrada
			order by planilla,fecha_venta

  loop

        raise notice 'valor_anticipo : %',recordColocacion.valor_anticipo;

	if(_planilla='')then

		_planilla:=recordColocacion.planilla;
		_disponibleVenta:=recordColocacion.valor_consignacion-recordColocacion.total_venta;

        elsif (_planilla=recordColocacion.planilla) then

		recordColocacion.valor_anticipo:=0.0;
                recordColocacion.descuentos_fintra:=0.0;
                recordColocacion.valor_consignacion:=0.0;
		 _disponibleVenta:=_disponibleVenta-recordColocacion.total_venta;

        else
		_planilla:=recordColocacion.planilla;
		_disponibleVenta:=recordColocacion.valor_consignacion-recordColocacion.total_venta;
	end if;
		raise NOTICE '_disponibleVenta : %',_disponibleVenta;
                recordColocacion.disponible:= _disponibleVenta;
		retorno:=recordColocacion;

          return next retorno;
  end loop;



END $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.colocacion_fintra_logistica(character varying, character varying, character varying, integer)
  OWNER TO postgres;
