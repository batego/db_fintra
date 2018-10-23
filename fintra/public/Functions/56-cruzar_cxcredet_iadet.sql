-- Function: cruzar_cxcredet_iadet()

-- DROP FUNCTION cruzar_cxcredet_iadet();

CREATE OR REPLACE FUNCTION cruzar_cxcredet_iadet()
  RETURNS text AS
$BODY$DECLARE
  _group RECORD;
  tipo_documentox TEXT;
  num_ingresox TEXT;
  itemx BIGINT;
BEGIN
	--se consultan los detalles de facturas de las re que salieron de las notas de ajuste
	FOR _group IN SELECT *
		      FROM con.factura_detalle
		      WHERE dstrct='FINV' AND tipo_documento ='FAC' AND SUBSTR(documento,1,4) LIKE 'RE00%'
			AND numero_remesa LIKE 'PM%' AND reg_Status!='A'
			AND (documento_relacionado=documento OR documento_relacionado='')
	LOOP

	INSERT INTO copia.factura_detalle20100205
		SELECT *
		FROM con.factura_detalle fde
		WHERE fde.dstrct='FINV'
			AND fde.tipo_documento=_group.tipo_documento
			AND fde.documento=_group.documento
			AND fde.item=_group.item;

	num_ingresox:=NULL;
			--se busca 1 nota de ajuste sin marca para ese detalle de cxc re con el valor,la fecha de recaudo y la cxc pm
			SELECT INTO tipo_documentox,num_ingresox, itemx
				    id.tipo_documento,id.num_ingreso, id.item
			FROM con.ingreso_detalle id, con.ingreso i
			WHERE id.factura=_group.numero_remesa
				AND _group.descripcion LIKE '%' || SUBSTR(i.fecha_consignacion,1,7) || '%'
				AND _group.valor_item=id.valor_ingreso

				AND id.dstrct='FINV'
				AND id.reg_Status!='A'
				AND id.tipo_documento='ICA'
				AND id.dstrct=i.dstrct
				AND id.tipo_documento=i.tipo_documento
				AND id.num_ingreso=i.num_ingreso
				AND i.reg_status!='A'

				AND (id.ref1 IS NULL OR id.ref1 ='');

			IF (NOT(num_ingresox IS NULL)) THEN	--si se encontrÃ³ 1 nota de ajuste

			    INSERT INTO copia.ingreso_detalle20100205
				SELECT *
				FROM con.ingreso_detalle ide
				WHERE ide.dstrct='FINV'
				AND ide.tipo_documento=tipo_documentox
				AND ide.num_ingreso=num_ingresox
				AND ide.item=itemx;

				UPDATE con.ingreso_detalle idd
				SET ref1=_group.tipo_documento || '__' || _group.documento || '__' || _group.item
				WHERE idd.dstrct='FINV' AND idd.tipo_documento=tipo_documentox AND idd.num_ingreso=num_ingresox
					AND idd.item=itemx
				;	--se marca la nota de ajuste
				UPDATE con.factura_detalle fdd
				SET documento_relacionado=tipo_documentox || '__' || num_ingresox || '__' || itemx
				WHERE fdd.dstrct='FINV'
					AND fdd.tipo_documento=_group.tipo_documento
					AND fdd.documento=_group.documento
					AND fdd.item=_group.item;--se marca el detalle de la cxc re
			END if;

	END LOOP;
	RETURN 'Proceso ejecutado.';
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION cruzar_cxcredet_iadet()
  OWNER TO postgres;
