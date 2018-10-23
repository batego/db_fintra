-- Function: tem.dv_reporte_aplicacion_pagos_negocio(character varying)

-- DROP FUNCTION tem.dv_reporte_aplicacion_pagos_negocio(character varying);

CREATE OR REPLACE FUNCTION tem.dv_reporte_aplicacion_pagos_negocio(negocio character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE

	RsPagos RECORD;
	vlr_factura NUMERIC := 0;

BEGIN

	FOR RsPagos IN

			SELECT
				negasoc,
				num_doc_fen::NUMERIC ,
				fecha_vencimiento,
				fecha_ingreso,
				i.num_ingreso,
				0.00::NUMERIC as valor_factura,
				ROUND(vlr_ingreso)::NUMERIC,
				ROUND(sum(valor_ingreso)) AS  valor_aplicado,
				0.00::NUMERIC AS ixm,
				0.00::NUMERIC AS gac,
				ROUND(sum(f.valor_saldo))::NUMERIC AS valor_saldo
				--,(fecha_ingreso-fecha_vencimiento) as dias_mora
				FROM con.ingreso i
			INNER JOIN con.ingreso_detalle id ON id.num_ingreso=i.num_ingreso
			LEFT JOIN con.factura f ON f.documento=id.documento
			WHERE f.negasoc = negocio AND id.documento !='' AND id.tipo_doc='FAC'
			GROUP BY negasoc, num_doc_fen,fecha_vencimiento,fecha_ingreso,vlr_ingreso,i.num_ingreso
			ORDER BY num_doc_fen



	LOOP
		raise notice 'negasoc: %',RsPagos.negasoc;
                SELECT INTO vlr_factura ROUND(sum(valor_factura)) from con.factura where negasoc = RsPagos.negasoc and num_doc_fen= RsPagos.num_doc_fen group by num_doc_fen;

		RsPagos.ixm:= COALESCE((SELECT ROUND(sum(valor_ingreso))
					FROM con.ingreso_detalle
					WHERE num_ingreso=RsPagos.num_ingreso AND reg_status='' AND documento=''
					AND cuenta IN ('I010130014170','I010140014170')),0);

		RsPagos.gac:= COALESCE((SELECT ROUND(sum(valor_ingreso))
					FROM con.ingreso_detalle
					WHERE num_ingreso=RsPagos.num_ingreso AND reg_status='' AND documento=''
					AND cuenta IN ('I010130014205','I010140014205','28150531')),0);

		RsPagos.valor_factura := vlr_factura;
		raise notice 'P:: %',RsPagos;


		RETURN NEXT RsPagos;

	END LOOP;


END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION tem.dv_reporte_aplicacion_pagos_negocio(character varying)
  OWNER TO postgres;
