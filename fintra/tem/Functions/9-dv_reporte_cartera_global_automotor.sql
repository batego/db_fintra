-- Function: tem.dv_reporte_cartera_global_automotor()

-- DROP FUNCTION tem.dv_reporte_cartera_global_automotor();

CREATE OR REPLACE FUNCTION tem.dv_reporte_cartera_global_automotor()
  RETURNS SETOF record AS
$BODY$

	DECLARE

		CarteraGeneral record;
		DetalleSancion record;
		saldoAval numeric:=0;
		vencidoAval numeric:=0;
		unidadnegocio varchar;
		--financia_aval boolean;
		NegocioAvales record;
		NegocioSeguros record;
		NegocioGps record;
		saldoSeguro numeric:=0;
		vencidoSeguro numeric:=0;
		saldoGps numeric:=0;
		vencidoGps numeric:=0;
		totalSeguroVencido numeric:=0;
		totalSeguroSaldo numeric:=0;
		valorVencido numeric:=0;

		_SumDebidoCobrar numeric:=0;
		_SumIxM numeric:=0;
		_SumGaC numeric:=0;
	BEGIN



		FOR CarteraGeneral IN

			SELECT NEGOCIOS.COD_NEG::VARCHAR AS NEGOCIO,
				FRA.NIT::VARCHAR AS CEDULA,
				COALESCE(CLI.NOMCLI, 'NR')::VARCHAR AS NOMBRE_CLIENTE,
				--UPPER(SP.NOMBRE) AS NOMBRE_CLIENTE,
				UPPER(PRIMER_NOMBRE)::VARCHAR AS PRIMER_NOMBRE,
				UN.DESCRIPCION::VARCHAR AS LINEA_NEGOCIO, --UN.ID,
				CO.NOMBRE::VARCHAR AS CONVENIO,
				EG_ALTURA_MORA_PERIODO(NEGOCIOS.COD_NEG, (REPLACE(SUBSTRING(NOW(),1,7),'-',''))::INTEGER, 1, 0)::VARCHAR AS VENCIMIENTO_MAYOR,
				GET_DIA_PAGO(NEGOCIOS.COD_NEG)::INTEGER AS DIA_PAGO,
				0::INTEGER AS DIAS_VENCIDOS,
				--SUM(VALOR_SALDO)::NUMERIC AS VALOR_VENCIDO,
				0::NUMERIC AS VALOR_VENCIDO,
				--0::NUMERIC AS intereses_mora,
				--0::NUMERIC AS gastos_cobranza,
				0::NUMERIC AS VALOR_A_PAGAR,
				SP.DIRECCION::VARCHAR,
				SP.BARRIO::VARCHAR,
				SP.CIUDAD::VARCHAR,
				COALESCE(CLI.TELEFONO ||' - '|| CLI.TELCONTACTO,'NR')::VARCHAR AS TEL,
				UPPER(SP.EMAIL)::VARCHAR AS CORREO_ELECTRONICO,
				CASE WHEN (SELECT MAX(FECHA_ULTIMO_PAGO::DATE) FROM CON.FACTURA WHERE NEGASOC = NEGOCIOS.COD_NEG) = '0099-01-01'
				THEN '0101-01-01'
				ELSE  (SELECT MAX(FECHA_ULTIMO_PAGO::DATE) FROM CON.FACTURA WHERE NEGASOC = NEGOCIOS.COD_NEG)
				END AS FECHA_ULT_PAGO,
				--COALESCE((SELECT MAX(FECHA_ULTIMO_PAGO::DATE) FROM CON.FACTURA WHERE NEGASOC = NEGOCIOS.COD_NEG),'0101-01-01')     AS FECHA_ULT_PAGO,
				COALESCE((SELECT MAX(FECHA_A_PAGAR::DATE) FROM CON.COMPROMISO_PAGO_CARTERA WHERE NEGOCIO = NEGOCIOS.COD_NEG),'0101-01-01')     AS FECHA_ULT_COMPROMISO,
				FINANCIA_AVAL
			FROM CON.FACTURA FRA
			LEFT JOIN CON.CMC_DOC CMC ON ( CMC.CMC = FRA.CMC AND CMC.TIPODOC=FRA.TIPO_DOCUMENTO)
			LEFT JOIN CLIENTE CLI ON ( CLI.CODCLI = FRA.CODCLI )
			LEFT JOIN NEGOCIOS ON (NEGOCIOS.COD_NEG=FRA.NEGASOC)
			LEFT JOIN PROVEEDOR ON (NEGOCIOS.NIT_TERCERO=PROVEEDOR.NIT)
			LEFT JOIN CON.FACTURA_OBSERVACION FO ON (FO.DOCUMENTO=FRA.DOCUMENTO AND FO.CREATION_DATE = (SELECT MAX(O.CREATION_DATE) FROM CON.FACTURA_OBSERVACION AS O WHERE O.DOCUMENTO=FRA.DOCUMENTO) AND  REPLACE(SUBSTRING(FO.CREATION_DATE,1,8),'-','') = REPLACE(SUBSTRING(NOW(),1,8),'-',''))
			LEFT JOIN SOLICITUD_AVAL SA ON (SA.COD_NEG=NEGOCIOS.COD_NEG)
			LEFT JOIN SOLICITUD_PERSONA SP ON (SP.NUMERO_SOLICITUD=SA.NUMERO_SOLICITUD AND SP.TIPO ='S')
			INNER JOIN CONVENIOS CO ON CO.ID_CONVENIO=NEGOCIOS.ID_CONVENIO
			INNER JOIN REL_UNIDADNEGOCIO_CONVENIOS RUC ON RUC.ID_CONVENIO=CO.ID_CONVENIO
			INNER JOIN UNIDAD_NEGOCIO UN ON UN.ID = RUC.ID_UNID_NEGOCIO
			WHERE FRA.DSTRCT = 'FINV'
					    --AND FRA.TIPO_DOCUMENTO = 'FAC'
					    AND FRA.VALOR_SALDO != 0
					    --AND FRA.NIT = '1143451050'
					   -- AND NEGOCIOS.COD_NEG = 'FA32209'
					    --AND NEGOCIOS.COD_CLI =FRA.NIT
					    AND FRA.REG_STATUS != 'A'
					    AND NUM_DOC_FEN NOT LIKE '%-%' AND NUM_DOC_FEN NOT LIKE '%A%' AND NUM_DOC_FEN NOT LIKE '%F%'
					    AND NUM_DOC_FEN NOT LIKE '%G%' AND NUM_DOC_FEN NOT LIKE '%I%' AND NUM_DOC_FEN NOT LIKE '%K%'
					    AND NUM_DOC_FEN NOT LIKE '%L%' AND  NUM_DOC_FEN != ''
					    AND NEGOCIO_REL = ''
					    AND NEGOCIO_REL_SEGURO = ''
					    AND NEGOCIO_REL_GPS = ''
					    AND UN.ID in (3,9) AND UN.REF_4 !=''
					    AND FRA.NIT !='8901009858'
					 --  AND NEGOCIOS.PERIODO = '201701'


			GROUP BY NEGOCIOS.COD_NEG, FRA.NIT, SP.NOMBRE, SP.PRIMER_NOMBRE, CLI.NOMCLI, UN.DESCRIPCION, CO.NOMBRE, SP.DIRECCION, SP.BARRIO, SP.CIUDAD, CLI.TELEFONO, CLI.TELCONTACTO, SP.EMAIL, FINANCIA_AVAL--, UN.ID
			ORDER BY NEGOCIOS.COD_NEG
		LOOP


			unidadnegocio:= (SELECT sp_uneg_negocio(CarteraGeneral.negocio));
			raise notice 'CarteraGeneral.negocio: %',CarteraGeneral.negocio;
			--raise notice 'CarteraGeneral.financia_aval: %',CarteraGeneral.financia_aval;


		_SumDebidoCobrar:=0;
		_SumIxM:=0;
		_SumGaC:=0;


			FOR  DetalleSancion IN
				SELECT
			       -- NEGOCIO
			       -- ,CEDULA
			       -- ,NOMBRE_CLIENTE
				--,CUOTA
				--,FECHA_VENCIMIENTO
				MAX(NOW()::DATE - FECHA_VENCIMIENTO) AS DIAS_VENCIDO_HOY,
				--,VENCIMIENTO_MAYOR
				MAX(DIAS_VENCIDOS) AS DIAS_VENCIDOS,
				--,STATUS
				--,SUM(VALOR_ASIGNADO) AS VALOR_ASIGNADO
				SUM(DEBIDO_COBRAR) AS DEBIDO_COBRAR,
				SUM(INTERES_MORA) AS INTERES_MORA,
				SUM(GASTO_COBRANZA) AS GASTO_COBRANZA
			    FROM TEM.DV_DETALLECARTERAXSANCION((REPLACE(SUBSTRING(NOW(),1,7),'-',''))::INTEGER,unidadnegocio,CarteraGeneral.negocio) AS COCO(NEGOCIO VARCHAR, CEDULA VARCHAR, NOMBRE_CLIENTE VARCHAR, CUOTA VARCHAR, DOCUMENTO VARCHAR, FECHA_VENCIMIENTO DATE, DIAS_VENCIDOS NUMERIC, VENCIMIENTO_MAYOR VARCHAR, STATUS VARCHAR, VALOR_ASIGNADO NUMERIC, DEBIDO_COBRAR NUMERIC, INTERES_MORA NUMERIC,GASTO_COBRANZA NUMERIC )
				GROUP BY
				NEGOCIO

			LOOP



		--CarteraGeneral.valor_vencido:= (SELECT sum(valor_saldo) from con.factura where negasoc = CarteraGeneral.negocio  and  replace(substring(fecha_vencimiento,1,7),'-','')::numeric <= NOW() group by negasoc) + vencidoAval + totalSeguroVencido + vencidoGps;
			_SumDebidoCobrar = _SumDebidoCobrar + DetalleSancion.debido_cobrar;
			_SumGaC = _SumGaC + DetalleSancion.gasto_cobranza;
			_SumIxM = _SumIxM +  DetalleSancion.interes_mora;
			CarteraGeneral.valor_vencido:=_SumDebidoCobrar;-- + vencidoAval + totalSeguroVencido + vencidoGps;

		--valorVencido:= (SELECT sum(valor_saldo) from con.factura where negasoc = CarteraGeneral.negocio and valor_saldo !=0 and  replace(substring(fecha_vencimiento,1,7),'-','')::numeric <= NOW() group by negasoc);
			CarteraGeneral.valor_a_pagar:= CarteraGeneral.valor_vencido + _SumIxM + _SumGaC;-- + saldoAval + totalSeguroSaldo + saldoGps ;
			CarteraGeneral.dias_vencidos:= DetalleSancion.dias_vencido_hoy;


		--DetalleSancion.interes_mora + DetalleSancion.gasto_cobranza
		--raise notice 'valorVencido: %',valorVencido;
		raise notice '_SumDebidoCobrar: %',_SumDebidoCobrar;
		raise notice '_SumGaC: %',_SumGaC;
		raise notice '_SumIxM: %',_SumIxM;
		--raise notice 'saldoGps: %',saldoGps;
		raise notice 'CarteraGeneral.valor_vencido: %',CarteraGeneral.valor_vencido;
		raise notice 'CarteraGeneral.valor_a_pagar: %',CarteraGeneral.valor_a_pagar;
			END LOOP;

			RETURN NEXT CarteraGeneral;

		END LOOP;

	END;

	$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION tem.dv_reporte_cartera_global_automotor()
  OWNER TO postgres;
