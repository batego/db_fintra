-- Function: sp_ejecucion_foto_ciclo_pagos(character varying, numeric)

-- DROP FUNCTION sp_ejecucion_foto_ciclo_pagos(character varying, numeric);

CREATE OR REPLACE FUNCTION sp_ejecucion_foto_ciclo_pagos(periodo_foto character varying, nciclo numeric)
  RETURNS text AS
$BODY$
DECLARE

 resp TEXT;
 Ciclo record;

BEGIN
        resp='';

	SELECT INTO Ciclo * FROM con.ciclos_facturacion WHERE periodo = periodo_foto and num_ciclo = nciclo;

	IF FOUND THEN
		INSERT INTO con.foto_ciclo_pagos (periodo_lote,id_ciclo,id_convenio,reg_status, dstrct,
		tipo_documento, documento, nit, codcli, concepto, fecha_negocio,fecha_factura, fecha_vencimiento, fecha_ultimo_pago, descripcion,
		valor_factura, valor_abono, valor_saldo, valor_facturame, valor_abonome, valor_saldome, forma_pago, transaccion,
		fecha_contabilizacion, creation_date_cxc, creation_user, cmc, periodo, negasoc, num_doc_fen, agencia_cobro
		)
		SELECT
		Ciclo.periodo, Ciclo.id, n.id_convenio,f.reg_status, f.dstrct,
		f.tipo_documento, f.documento, f.nit, f.codcli, f.concepto, n.fecha_negocio,f.fecha_factura, f.fecha_vencimiento, f.fecha_ultimo_pago, f.descripcion,
		f.valor_factura, f.valor_abono, f.valor_saldo, f.valor_facturame, f.valor_abonome, f.valor_saldome, f.forma_pago, f.transaccion,
		f.fecha_contabilizacion, now() as creation_date_cxc, f.creation_user, f.cmc, f.periodo, f.negasoc,f.num_doc_fen, f.agencia_cobro
		from con.factura f
		inner join negocios n on f.negasoc=n.cod_neg
		where f.reg_status != 'A'
		and f.dstrct = 'FINV'
		--and f.negasoc='FA16247'
		and f.tipo_documento in ('FAC','NDC')
		and substring(f.documento,1,2) not in ('NM','PM','RM','IPM','INM','IRM','RE','PP','EF','R0')
		and f.negasoc in (select cod_neg from negocios where dist='FINV' and num_ciclo = nciclo)
		order by f.negasoc,f.fecha_vencimiento;

		ANALYZE con.foto_ciclo_pagos;

		resp='OK';
	else
		resp='NO EXISTEN CICLOS DE FACTURACION CONFIGURADOS PARA EL PERIODO SELECCIONADO.';
	END IF;

  RETURN resp;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_ejecucion_foto_ciclo_pagos(character varying, numeric)
  OWNER TO postgres;
