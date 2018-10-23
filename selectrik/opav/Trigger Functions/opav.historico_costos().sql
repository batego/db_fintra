-- Function: opav.historico_costos()

-- DROP FUNCTION opav.historico_costos();

CREATE OR REPLACE FUNCTION opav.historico_costos()
  RETURNS "trigger" AS
$BODY$
DECLARE

BEGIN
    IF TG_OP = 'UPDATE' THEN
	INSERT INTO opav.app_historico_costo_proveedor(
		id_proveedor_materiales, fecha_ultima_compra,
		costo_base, costo_dscto, costo_total,
		creation_user, user_update, last_update)
	VALUES (OLD.id, now(),
		OLD.costo_base, OLD.costo_dscto, OLD.costo_total,
		OLD.user_update, COALESCE(NEW.user_update,''), now());
	RETURN NEW;
    ELSEIF TG_OP = 'INSERT' THEN
	RETURN NEW;
    ELSE
	INSERT INTO opav.app_historico_costo_proveedor(
		id_proveedor_materiales, fecha_ultima_compra,
		costo_base, costo_dscto, costo_total,
		creation_user, user_update, last_update)
	VALUES (OLD.id, now(),
		OLD.costo_base, OLD.costo_dscto, OLD.costo_total,
		OLD.user_update, OLD.user_update, now());
	RETURN OLD;
    END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.historico_costos()
  OWNER TO postgres;
