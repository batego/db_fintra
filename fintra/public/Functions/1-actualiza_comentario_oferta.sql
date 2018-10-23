-- Function: actualiza_comentario_oferta(text)

-- DROP FUNCTION actualiza_comentario_oferta(text);

CREATE OR REPLACE FUNCTION actualiza_comentario_oferta(text)
  RETURNS text AS
$BODY$DECLARE

  doc TEXT;

BEGIN
  doc = 'Actualizado';
 update opav.ofertas set comentario = 'REFINANCIADO' where num_os=$1;


  RETURN doc;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION actualiza_comentario_oferta(text)
  OWNER TO postgres;
COMMENT ON FUNCTION actualiza_comentario_oferta(text) IS 'actualizar comentario oferta.';
