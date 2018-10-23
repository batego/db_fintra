-- Function: tem.dv_valorsaldo_aval(character varying)

-- DROP FUNCTION tem.dv_valorsaldo_aval(character varying);

CREATE OR REPLACE FUNCTION tem.dv_valorsaldo_aval(negociorel character varying)
  RETURNS SETOF record AS
$BODY$

	DECLARE

		CarteraGeneral record;
		DetalleSancion record;

		unidadnegocio varchar;

	BEGIN



		FOR CarteraGeneral IN

			SELECT  NEGOCIOS.COD_NEG::VARCHAR AS NEGOCIO,
				UN.DESCRIPCION::VARCHAR AS LINEA_NEGOCIO,
				CO.NOMBRE::VARCHAR AS CONVENIO,
				SUM(VALOR_SALDO)::NUMERIC AS VALOR_VENCIDO,
				--0::NUMERIC AS intereses_mora,
				--0::NUMERIC AS gastos_cobranza,
				0::NUMERIC AS VALOR_A_PAGAR
			FROM CON.FACTURA FRA
			LEFT JOIN NEGOCIOS ON (NEGOCIOS.COD_NEG=FRA.NEGASOC)
			INNER JOIN UNIDAD_NEGOCIO UN ON (UN.ID = SP_UNEG_NEGOCIO(NEGOCIOS.COD_NEG))
			INNER JOIN CONVENIOS CO ON CO.ID_CONVENIO=NEGOCIOS.ID_CONVENIO
			WHERE FRA.DSTRCT = 'FINV'
					    --AND FRA.TIPO_DOCUMENTO = 'FAC'
					    AND FRA.VALOR_SALDO != 0
					    AND NEGOCIOS.COD_NEG = negociorel
					   -- OR  NEGOCIO_REL_SEGURO = negociorel
					    --OR NEGOCIO_REL_GPS = negociorel)
					    AND FRA.REG_STATUS != 'A'
					    AND NUM_DOC_FEN NOT LIKE '%-%' AND NUM_DOC_FEN NOT LIKE '%A%' AND NUM_DOC_FEN NOT LIKE '%F%'
					    AND NUM_DOC_FEN NOT LIKE '%G%' AND NUM_DOC_FEN NOT LIKE '%I%' AND NUM_DOC_FEN NOT LIKE '%K%'
					    AND NUM_DOC_FEN NOT LIKE '%L%' AND  NUM_DOC_FEN != ''


			GROUP BY NEGOCIOS.COD_NEG, UN.DESCRIPCION, CO.NOMBRE

		LOOP


			unidadnegocio:= (SELECT sp_uneg_negocio(CarteraGeneral.negocio));
			raise notice 'CarteraGeneral.negocio: %',CarteraGeneral.negocio;

			FOR  DetalleSancion IN
				SELECT
				SUM(INTERES_MORA) AS INTERES_MORA,
				SUM(GASTO_COBRANZA) AS GASTO_COBRANZA
			    FROM TEM.DV_DETALLECARTERAXSANCION((REPLACE(SUBSTRING(NOW(),1,7),'-',''))::INTEGER,unidadnegocio,CarteraGeneral.negocio) AS COCO(NEGOCIO VARCHAR, CEDULA VARCHAR, NOMBRE_CLIENTE VARCHAR, CUOTA VARCHAR, DOCUMENTO VARCHAR, FECHA_VENCIMIENTO DATE, DIAS_VENCIDOS NUMERIC, VENCIMIENTO_MAYOR VARCHAR, STATUS VARCHAR, VALOR_ASIGNADO NUMERIC, DEBIDO_COBRAR NUMERIC, INTERES_MORA NUMERIC,GASTO_COBRANZA NUMERIC )
				GROUP BY
				NEGOCIO

			LOOP

			--CarteraGeneral.interes_mora= DetalleSancion.INTERES_MORA;
			--CarteraGeneral.gasto_cobranza= DetalleSancion.GASTO_COBRANZA;

			CarteraGeneral.valor_a_pagar:= CarteraGeneral.valor_vencido + DetalleSancion.interes_mora + DetalleSancion.gasto_cobranza ;
			--CarteraGeneral.dias_vencidos:= DetalleSancion.dias_vencidos_hoy;

			END LOOP;

			RETURN NEXT CarteraGeneral;

		END LOOP;

	END;

	$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION tem.dv_valorsaldo_aval(character varying)
  OWNER TO postgres;
