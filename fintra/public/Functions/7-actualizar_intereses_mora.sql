-- Function: actualizar_intereses_mora(numeric)

-- DROP FUNCTION actualizar_intereses_mora(numeric);

CREATE OR REPLACE FUNCTION actualizar_intereses_mora(nn numeric)
  RETURNS text AS
$BODY$DECLARE
  id2 INTEGER;
  documento2 TEXT;
  num_ingreso2 TEXT;
  valor_recaudo2 NUMERIC;
  intereses2 NUMERIC;
  cuota_capital2 NUMERIC;
  dias_vencidos2 INTEGER;
  cuota_capital_cancelados NUMERIC;
  intereses_cancelados NUMERIC;
  cuot_cap NUMERIC;
  _tasa TEXT;
  _group RECORD;
BEGIN
	FOR _group IN

	SELECT

	     case
		when fc.fecha_vencimiento>NOW() THEN '0'
		ELSE referencia
	     END as tasa ,

	     REPLACE (TO_CHAR(fc.fecha_vencimiento::DATE,'YYYY-MM'),'-','') AS periodo,documento_cxc,
	     valor_recaudo,
	     intereses,
	     cuota_capital,
	     dias_vencidos,
	     id,
	     num_ingreso

        FROM proc_rec pr

        LEFT JOIN CON.FACTURA fc ON(pr.documento_cxc=fc.documento)
        LEFT JOIN TABLAGEN tg ON (tg.TABLE_TYPE='T_TRI_ECA'
                                  AND REPLACE (TO_CHAR(fc.fecha_vencimiento::DATE,'YYYY-MM'),'-','')=tg.table_code)

        ORDER BY fc.fecha_vencimiento+pr.dias_vencidos LIMIT nn LOOP


		documento2:=_group.documento_cxc;
		valor_recaudo2:=_group.valor_recaudo;
		intereses2:=_group.intereses;
		cuota_capital2:=_group.cuota_capital;
		dias_vencidos2:=_group.dias_vencidos;
		id2:=_group.id;
		num_ingreso2:=_group.num_ingreso;
		_tasa:=_group.tasa;

		if id2 IS NOT NULL THEN

			SELECT INTO intereses_cancelados,cuota_capital_cancelados

				       (SELECT COALESCE (sum(valor),0)
					FROM intereses_mora_eca ime
					WHERE ime.documento=documento2 AND tipo='IC' AND reg_status=''
					)as a,

				       (SELECT COALESCE (sum(valor),0)
					FROM intereses_mora_eca ime
					WHERE ime.documento=documento2 AND tipo='CC' AND reg_status=''
					) as b;

			if intereses2>intereses_cancelados THEN
				if valor_recaudo2>(intereses2-intereses_cancelados) THEN
					INSERT INTO intereses_mora_eca (documento,tipo,dias_vencidos,valor,interes_mora,num_ingreso)
					       VALUES (documento2,'IC',dias_vencidos2,intereses2-intereses_cancelados,0,num_ingreso2);
					valor_recaudo2:=valor_recaudo2-(intereses2-intereses_cancelados);
				ELSE
					INSERT INTO intereses_mora_eca (documento,tipo,dias_vencidos,valor,interes_mora,num_ingreso)
					       VALUES(documento2,'IC',dias_vencidos2,valor_recaudo2,0,num_ingreso2);
					valor_recaudo2:=0;
				END if;
			END if;
			if valor_recaudo2>(cuota_capital2-cuota_capital_cancelados) THEN
				cuot_cap=cuota_capital2-cuota_capital_cancelados;
			ELSE
				cuot_cap=valor_recaudo2;
			END if;

			if cuot_cap!=0 THEN
					INSERT INTO intereses_mora_eca (documento,tipo,dias_vencidos,valor,interes_mora,num_ingreso)
					       VALUES(documento2,'CC',dias_vencidos2,cuot_cap,CASE
												WHEN 0>(cuot_cap*dias_vencidos2*_tasa::NUMERIC/100)/30 THEN
												 0 ELSE (cuot_cap*dias_vencidos2*_tasa::NUMERIC/100)/30 END,num_ingreso2);
			END if;
				UPDATE con.ingreso_detalle
				SET procesado='SI'
				WHERE id=id2;
			END if;
	END LOOP;
	RETURN 'Exitoso!!!';
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION actualizar_intereses_mora(numeric)
  OWNER TO postgres;
