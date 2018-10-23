-- Function: actualizar_referencias_ag()

-- DROP FUNCTION actualizar_referencias_ag();

CREATE OR REPLACE FUNCTION actualizar_referencias_ag()
  RETURNS integer AS
$BODY$
DECLARE

    detalle RECORD;

    m_tipodoc character(5):= '';
    m_numdoc  character(30):= '';
    m_grupo_transaccion numeric:= 0;
    m_transaccion numeric:= 0;
    m_valor_debito numeric(14,2) := 0.00;



BEGIN

    FOR detalle IN select * from tem.egreso_ag

    LOOP

	 select into  m_tipodoc , m_numdoc, m_grupo_transaccion, m_transaccion, m_valor_debito
	   tipodoc, numdoc, grupo_transaccion, transaccion, valor_debito
	 from
	   tem.movimiento_23050118 a
	 where
	   a.referencia_2 = detalle.planilla and
	   a.document_no = '' and
	   a.valor_debito = detalle.vlr
	 limit 1 ;


	 if m_tipodoc is not null then

	   update
	     tem.movimiento_23050118 a
	   set
	     document_no = detalle.document_no,
	     item = detalle.item_no
	   where
	     a.tipodoc = m_tipodoc and
             a.numdoc = m_numdoc and
             a.grupo_transaccion = m_grupo_transaccion and
             a.transaccion = m_transaccion  ;

	 end if;

    END LOOP;

    RETURN 1;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION actualizar_referencias_ag()
  OWNER TO postgres;
