-- Function: administrativo.insert_h_costos_etapa()

-- DROP FUNCTION administrativo.insert_h_costos_etapa();

CREATE OR REPLACE FUNCTION administrativo.insert_h_costos_etapa()
  RETURNS "trigger" AS
$BODY$DECLARE

    descripcion character varying;
    estadoAprobacion character varying;

BEGIN
	--PERFORM * FROM administrativo.costos_etapa WHERE id=NEW.ID ;
        IF (TG_OP = 'INSERT') THEN
            descripcion:= 'SE INSERTA COSTO PARA LA ETAPA';
        ELSIF (NEW.reg_status='A' AND NEW.reg_status!=OLD.reg_status) THEN
		descripcion:= 'SE ANULO COSTO';
	ELSIF (NEW.reg_status='' AND NEW.reg_status!=OLD.reg_status) THEN
		descripcion:= 'SE ACTIVO COSTO';
	ELSIF (NEW.estado_approv!=OLD.estado_approv) THEN
		select into estadoAprobacion nombre from administrativo.estados_aprob_conceptos WHERE codigo = NEW.estado_approv;
		descripcion:= 'SE CAMBIO ESTADO APROBACION COSTO A '||estadoAprobacion ;
	ELSE
		descripcion:= 'SE ACTUALIZA COSTO';
	END IF;

	INSERT INTO administrativo.historico_costos_etapa  (reg_status, dstrct, id_etapa, concepto, tipo, valor, solo_automotor,
	estado_approv, usuario_approv, fecha_approv, last_update, user_update, creation_date, creation_user, h_creation_date, h_comment)
	VALUES (NEW.reg_status, NEW.dstrct, NEW.id_etapa, NEW.concepto, NEW.tipo,NEW.valor, NEW.solo_automotor, NEW.estado_approv,
	NEW.usuario_approv, NEW.fecha_approv, NEW.last_update, NEW.user_update,NEW.creation_date, NEW.creation_user, now(), descripcion);

RETURN NEW;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION administrativo.insert_h_costos_etapa()
  OWNER TO postgres;
