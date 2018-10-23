-- Function: administrativo.insert_h_d_fianza()

-- DROP FUNCTION administrativo.insert_h_d_fianza();

CREATE OR REPLACE FUNCTION administrativo.insert_h_d_fianza()
  RETURNS "trigger" AS
$BODY$DECLARE


BEGIN

	INSERT into tem.hist_auditoria(id_historico_deducciones_fianza, operacion, ip) values(NEW.id, TG_OP, inet_client_addr()::varchar);

 IF (TG_OP = 'INSERT') THEN

	INSERT INTO tem.historico_deducciones_fianza (id,reg_status,dstrct,periodo_corte,nit_empresa_fianza,nit_cliente,documento_relacionado,
													negocio,plazo,valor_negocio,valor_desembolsado,subtotal_fianza,valor_iva,valor_fianza,fecha_vencimiento,id_unidad_negocio,
													id_convenio,creation_user,creation_date,agencia)
		VALUES(NEW.ID, NEW.reg_status,NEW.dstrct,NEW.periodo_corte,NEW.nit_empresa_fianza,NEW.nit_cliente,NEW.documento_relacionado,
				NEW.negocio,NEW.plazo,NEW.valor_negocio,NEW.valor_desembolsado,NEW.subtotal_fianza,NEW.valor_iva,NEW.valor_fianza,NEW.fecha_vencimiento,
				NEW.id_unidad_negocio,NEW.id_convenio,NEW.creation_user,NEW.creation_date,NEW.agencia);

 END IF;

RETURN NEW;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION administrativo.insert_h_d_fianza()
  OWNER TO postgres;
