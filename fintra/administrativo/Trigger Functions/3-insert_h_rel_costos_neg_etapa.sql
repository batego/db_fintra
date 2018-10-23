-- Function: administrativo.insert_h_rel_costos_neg_etapa()

-- DROP FUNCTION administrativo.insert_h_rel_costos_neg_etapa();

CREATE OR REPLACE FUNCTION administrativo.insert_h_rel_costos_neg_etapa()
  RETURNS "trigger" AS
$BODY$DECLARE

 descripcion character varying;

BEGIN

        IF (TG_OP = 'INSERT') THEN
             descripcion:= 'SE ASIGNA COSTO PARA EL PROCESO';
        ELSIF (TG_OP = 'UPDATE') THEN
             descripcion:= 'SE ACTUALIZA COSTO DEL PROCESO';
	ELSE
	     descripcion:= 'SE DESASIGNA COSTO DEL PROCESO';
	END IF;

        IF (TG_OP = 'DELETE') THEN
                INSERT INTO administrativo.h_rel_costos_neg_etapa (reg_status, dstrct, id_etapa, negocio, id_costo, valor,
		last_update, user_update, creation_date, creation_user, h_creation_date, h_comment)
		VALUES (OLD.reg_status, OLD.dstrct, OLD.id_etapa, OLD.negocio, OLD.id_costo, OLD.valor, OLD.last_update,
		OLD.user_update, OLD.creation_date, OLD.creation_user, now(), descripcion);
        ELSE
                INSERT INTO administrativo.h_rel_costos_neg_etapa (reg_status, dstrct, id_etapa, negocio, id_costo, valor,
		last_update, user_update, creation_date, creation_user, h_creation_date, h_comment)
		VALUES (NEW.reg_status, NEW.dstrct, NEW.id_etapa, NEW.negocio, NEW.id_costo, NEW.valor, NEW.last_update,
		NEW.user_update, NEW.creation_date, NEW.creation_user, now(), descripcion);
        END IF;

RETURN NEW;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION administrativo.insert_h_rel_costos_neg_etapa()
  OWNER TO postgres;
