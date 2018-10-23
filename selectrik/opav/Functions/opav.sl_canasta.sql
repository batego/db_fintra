-- Function: opav.sl_canasta(integer, integer, integer, character varying, integer, character varying)

-- DROP FUNCTION opav.sl_canasta(integer, integer, integer, character varying, integer, character varying);

CREATE OR REPLACE FUNCTION opav.sl_canasta(id_solicitud_ integer, id_movimiento_ integer, tipo_entrada_ integer, documento_origen_ character varying, id_causal_ integer, usuario_ character varying)
  RETURNS text AS
$BODY$

DECLARE
_resultado text:= 'Error';
_total numeric := 0;
_lote character varying :='';
_id_canasta integer;
_ltwbs record;
_monto_debito numeric:= 0;
_monto_credito numeric:= 0;

BEGIN
	--Buscamos la cabecera de la canasta si no existe la crea
	INSERT INTO opav.sl_canasta_proyectos (
		    id_solicitud, presupuesto_comercial, total_debitado, total_acreditado,saldo_canasta, creation_date, creation_user)
		    select   id_solicitud_, 0, 0 , 0 , 0 ,now() , usuario_
		    WHERE  not exists
		    (select id_solicitud  from opav.sl_canasta_proyectos where id_solicitud =id_solicitud_);

	--Obtenemos el id_canasta_proyecto.
	select
		id into  _id_canasta
	from
		opav.sl_canasta_proyectos
	where
		id_solicitud =id_solicitud_;






	IF(documento_origen_ ilike '%LTWBS%') THEN

		FOR _ltwbs IN

			SELECT * FROM opav.sl_wbs_modificaciones  WHERE no_lote = documento_origen_

		LOOP

			IF(_ltwbs.movimiento= 2) THEN

				_monto_debito := _monto_debito + _ltwbs.valor_insumo_total;


				insert into opav.sl_canasta_detalle
					(id_canasta , lote_transaccion, documento_origen,
					responsable, id_tipo_entrada, id_causal, id_tipo_movimiento,
					fecha_transaccion, tipo_insumo, codigo_insumo, descripcion_insumo,
					id_unidad_medida, nombre_unidad_insumo, cantidad_afectada, costo_presupuestado,
					costo_unitario_compra, monto_debitado, monto_acreditado, creation_date,
					creation_user)
				values
					(_id_canasta , 0 , documento_origen_ ,
					usuario_ , tipo_entrada_ ,  id_causal_ , 2 ,
					NOW() , _ltwbs.tipo_insumo ,  _ltwbs.id_insumo , _ltwbs.descripcion_insumo,
					_ltwbs.unidad_medida_insumo ,  _ltwbs.nombre_unidad_insumo , _ltwbs.cantidad_insumo_total , _ltwbs.costo_personalizado,
					0 , _ltwbs.valor_insumo_total , 0 , now() , usuario_);

			END IF;



		END LOOP;

		update opav.sl_canasta_proyectos
		set
			total_acreditado = total_acreditado +  _monto_credito ,
			total_debitado = total_debitado + _monto_debito
		 where id_solicitud = id_solicitud;

	ELSE



	END IF;

	raise notice '_monto_debito :%', _monto_debito;





_resultado:= 'OK';
return _resultado;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sl_canasta(integer, integer, integer, character varying, integer, character varying)
  OWNER TO postgres;
