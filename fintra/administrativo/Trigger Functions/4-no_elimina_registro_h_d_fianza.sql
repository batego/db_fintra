-- Function: administrativo.no_elimina_registro_h_d_fianza()

-- DROP FUNCTION administrativo.no_elimina_registro_h_d_fianza();

CREATE OR REPLACE FUNCTION administrativo.no_elimina_registro_h_d_fianza()
  RETURNS "trigger" AS
$BODY$DECLARE
  BEGIN

   INSERT into tem.hist_auditoria(id_historico_deducciones_fianza, operacion, ip) values(OLD.id, TG_OP, inet_client_addr()::varchar);
   --
   -- Esta funcion es usada para proteger datos en un tabla
   -- No se permitira el borrado de filas si la usamos
   -- en un disparador de tipo BEFORE / row-level
   --

   RETURN NULL;
  END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION administrativo.no_elimina_registro_h_d_fianza()
  OWNER TO postgres;
