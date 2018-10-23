-- Function: sp_diasmora(character varying)

-- DROP FUNCTION sp_diasmora(character varying);

CREATE OR REPLACE FUNCTION sp_diasmora(nit character varying)
  RETURNS text AS
$BODY$DECLARE

	_respuesta TEXT;
	dias_mora integer:=0;


BEGIN



                 SELECT INTO dias_mora max(now()::date-(fecha_vencimiento)) as maxdia
				 --SELECT FechaCortePeriodo::date-fecha_vencimiento as maxdia
				 FROM con.factura fra
				 WHERE fra.dstrct = 'FINV'
					  AND fra.valor_saldo > 0
					  AND fra.reg_status = ''
					  AND fra.negasoc in (select n.cod_neg from negocios n
								inner join solicitud_aval sa on sa.cod_neg=n.cod_neg
								inner join solicitud_persona sp on sp.numero_solicitud=sa.numero_solicitud
				where sp.tipo='C' and sp.identificacion = nit and n.estado_neg = 'T')
					  --AND fra.documento = CarteraGeneral.documento
					  AND fra.tipo_documento = 'FAC'
					  GROUP BY negasoc;

 RETURN dias_mora;

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_diasmora(character varying)
  OWNER TO postgres;
