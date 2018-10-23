-- Function: opav.sp_crearmovimientodespacho(character varying)

-- DROP FUNCTION opav.sp_crearmovimientodespacho(character varying);

CREATE OR REPLACE FUNCTION opav.sp_crearmovimientodespacho(_dispatch character varying)
  RETURNS SETOF opav.rs_ordencs AS
$BODY$

DECLARE

	result opav.rs_OrdenCS;

	rsDsptch record;
	rsOCompra record;
	rsOCompraDetalle record;
	ComparaDespacho record;

	Sepuede integer;
	ResultLinea numeric := 0;
	NCSchild integer := 0;

	NoEntry varchar;
	NoOCchild varchar;
	resultado varchar;

BEGIN
	-- Procedimiento que genera el movimiento contables del despacho.
	 select into resultado con.interfaz_sl_inventario_bodega_principal_entrada(_dispatch);

	result.resultado_accion = 'NEGATIVO';

	SELECT INTO rsDsptch * FROM opav.sl_despacho_ocs WHERE cod_despacho = _Dispatch;
	SELECT INTO rsOCompra * FROM opav.sl_orden_compra_servicio WHERE cod_ocs = rsDsptch.cod_ocs;
	--SELECT INTO rsOCompraDetalle * FROM opav.sl_ocs_detalle WHERE id_ocs = rsOCompra.id and id = _IdDetalleInsumo;

	--PREGUNTAR SI LA ORDEN ESTA COMPLETA O LE FALTAN DESPACHOS.
	select into ComparaDespacho
		--id,
		--id_despacho,
		--cod_despacho,
		--cod_ocs,id_ocs,
		SUM(ocd.cantidad_solicitada) AS cantidad_solicitada,
		--ocd.costo_unitario_compra,
		--ocd.costo_total_compra,
		SUM(despacho.cantidad_recibida) AS cantidad_recibida
		--despacho.costo_unitario_recibido,
		--despacho.costo_total_recibido
	from opav.sl_ocs_detalle ocd
		left join (
		      select cod_despacho, id_despacho, cod_ocs, id_ocs_detalle, dsp.cantidad_recibida, dsp.costo_unitario_recibido, dsp.costo_total_recibido
		      from opav.sl_despacho_ocs d, opav.sl_despacho_detalle dsp
		      where d.id = dsp.id_despacho
		      ) despacho ON (ocd.id = despacho.id_ocs_detalle)
	where
	id_ocs = (select id from opav.sl_orden_compra_servicio where cod_ocs = rsDsptch.cod_ocs) --'OC00002'
	and ocd.cantidad_solicitada > 0;

	raise notice 'cantidad_solicitada: %', ComparaDespacho.cantidad_solicitada;
	raise notice 'cantidad_recibida: %', ComparaDespacho.cantidad_recibida;

	raise notice '_Dispatch: %', _Dispatch;

	IF ( ComparaDespacho.cantidad_solicitada >= ComparaDespacho.cantidad_recibida ) THEN

		raise notice 'A';
		--INSERTAR EN LA TABLA DE INVENTARIO EL MOVIMIENTO (Entrada)
		NoEntry := opav.SP_EntradasxDespacho(_Dispatch, rsDsptch.responsable);
		raise notice 'NoEntry: %', NoEntry;

		--CREAR LA SUBORDEN DE COMPRA & MARCARLA PARA QUE VIAJE A APOTEOSYS (Funcion de Wsiado)
		SELECT INTO NCSchild count(0)
		FROM opav.sl_orden_compra_servicio
		WHERE cod_ocs ilike rsDsptch.cod_ocs||'%'
		--AND EL CAMPO DE CONTROL != '?'
		AND reg_status = '';

		raise notice 'NCSchild: %', NCSchild;

		--SE CREA LA SUBORDEN DE COMPRA
		NoOCchild := opav.SP_CrearSubOcs(_Dispatch);

		--MOVER KARDEX:
		PERFORM opav.sp_moverkardex(NoOCchild,_Dispatch);

		--PASAR LA subOC A LA TABLA DE WSIADO QUE PASA HACIA APOTEOSYS.
		--PERFORM opav.sl_apoteosys_migracion_oc_provintegral(NoOCchild); --NoOCchild | rsDsptch.cod_ocs
		PERFORM opav.sl_apoteosys_migracion_oc_selectrik(NoOCchild); --NoOCchild | rsDsptch.cod_ocs

		--MARCO LA OC PADRE (Marcada como no debe pasarse a Apoteosys)
		UPDATE opav.sl_orden_compra_servicio SET pasar_apoteosys = 'N', estado_inclusion = 'N' WHERE cod_ocs = rsDsptch.cod_ocs;

		--MARCO LA OC HIJA (Como que fue pasada a Apoteosys)
		UPDATE opav.sl_orden_compra_servicio SET pasar_apoteosys = 'S', estado_inclusion = 'S' WHERE cod_ocs = NoOCchild;

	ELSIF ( ComparaDespacho.cantidad_solicitada < ComparaDespacho.cantidad_recibida ) THEN
		raise notice 'C';

		--MARCAR EL DESPACHO COMO ANORMAL
		--UPDATE DESPACHO

	END IF;

	RETURN NEXT result;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_crearmovimientodespacho(character varying)
  OWNER TO postgres;
