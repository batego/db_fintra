-- Function: con.eg_recaudo_xunidad(character varying, character varying)

-- DROP FUNCTION con.eg_recaudo_xunidad(character varying, character varying);

CREATE OR REPLACE FUNCTION con.eg_recaudo_xunidad(_periodo character varying, _unidadnego character varying)
  RETURNS SETOF con.rs_datos_recaudo AS
$BODY$

DECLARE

 rs con.rs_datos_recaudo;
 recordPagos record ;
 recordNeg record;
 _aux VARCHAR:='';
 _unidadAuxiliar VARCHAR:='';
 _negocio VARCHAR:='';

 --DECLARAMOS EL CURSOR
 cursor_recaudo CURSOR(_periodo varchar) FOR (SELECT substring(idet.periodo,1,4) as anio,
						      idet.periodo,
						      substring(ing.fecha_consignacion,1,4) as anio_consignacion,
						      replace(substring(ing.fecha_consignacion,1,7),'-','') as periodo_consignacion,
						      ing.branch_code,
						      ing.bank_account_no,
						      ing.num_ingreso,
						      ing.tipo_documento,
						      ing.creation_date,
						      idet.nitcli,
						      get_nombc(idet.nitcli) AS nombre_cliente,
						      ing.fecha_consignacion,
						      idet.cuenta,
						      idet.documento,
						      idet.tipo_doc,
						      sum(idet.valor_ingreso) as valor_ingreso,
						      idet.creation_user,
						      idet.procesado_ica,
						      fac.num_doc_fen as cuota,
						      idet.descripcion
						FROM con.ingreso ing
						INNER JOIN con.ingreso_detalle idet ON (ing.num_ingreso=idet.num_ingreso AND ing.tipo_documento=idet.tipo_documento)
						LEFT JOIN con.factura fac on (fac.documento=idet.documento AND 	fac.tipo_documento=idet.tipo_doc AND fac.negasoc !='')
						WHERE branch_code in ('SUPEREFECTIVO','BANCOLOMBIA','BANCO OCCIDENTE'
										     ,'BCO COLPATRIA','CAJA TESORERIA','CAJA UNIATONOMA'
										     ,'FID COLP RECFEN','FENALCO ATLANTI','BANCOLMBIA MC','EFECTY')
						AND bank_account_no in ('SUPEREFECTIVO','CA','CC','CTE 802027144','BARRANQUILLA'
											,'UNIATONOMA','FIDCOLP REC FENALCO','CORFICOLOMBIANA'
									,'MICROCREDITO','EFECTY','CAJA')
						AND idet.reg_status=''
						AND idet.cuenta not in ('23050128','23809904')
						--AND idet.num_ingreso in ('IA525520')
						AND COALESCE(idet.procesado_ica,'N') = 'N'
						AND ing.fecha_consignacion::DATE > '2016-12-31'::DATE
						AND idet.periodo=_periodo::varchar
						AND idet.nitcli IN (SELECT cod_cli FROM negocios WHERE estado_neg='T' group by cod_cli)
						GROUP BY
						      idet.periodo,
						      ing.branch_code,
						      ing.bank_account_no,
						      ing.num_ingreso,
						      ing.tipo_documento,
						      ing.creation_date,
						      idet.nitcli,
						      ing.fecha_consignacion,
						      idet.cuenta,
						      idet.documento,
						      idet.tipo_doc,
						      idet.creation_user,
						      idet.procesado_ica,
						      fac.num_doc_fen,
						      idet.descripcion
						ORDER BY
						ing.num_ingreso,
						ing.fecha_consignacion,
						idet.periodo,
						branch_code,
						documento desc
				);


BEGIN
	raise notice '__periodo : %',_periodo;
	--ABRIMOS EL CURSOR SIN PARAMETROS
	OPEN cursor_recaudo(_periodo) ;
	<<_loop>>
	LOOP
		-- FETCH FILA EN MY RECORD O TYPE
		FETCH cursor_recaudo INTO recordPagos;
		-- EXIT CUANDO NO HAY MAS FILAS
		EXIT WHEN NOT FOUND;


		SELECT INTO recordNeg un.descripcion, neg.cod_neg FROM con.factura fac
		INNER JOIN negocios neg ON (neg.cod_neg=fac.negasoc)
		INNER JOIN rel_unidadnegocio_convenios rneg on (rneg.id_convenio=neg.id_convenio)
		INNER JOIN unidad_negocio un on (un.id=rneg.id_unid_negocio)
		WHERE documento=recordPagos.documento AND tipo_documento IN ('FAC','NDC') AND un.id in (1,2,3,4,6,7,8,9,10,21,22,30,31);

		RAISE NOTICE 'recordNeg.descripcion %',recordNeg.descripcion;
		IF(_aux='')THEN
			_aux:=recordPagos.num_ingreso;
			IF(recordNeg.descripcion IS NOT NULL) THEN
				_unidadAuxiliar:=recordNeg.descripcion;
				_negocio:=recordNeg.cod_neg;
			END IF;
		ELSIF (_aux=recordPagos.num_ingreso)THEN
		raise notice 'eeeeeee';
		        _aux:=recordPagos.num_ingreso;
			IF(recordNeg.descripcion IS NOT NULL) THEN
				_unidadAuxiliar:=recordNeg.descripcion;
				_negocio:=recordNeg.cod_neg;
			END IF;
		ELSIF (_aux!=recordPagos.num_ingreso)THEN
			_aux:=recordPagos.num_ingreso;
			IF(recordNeg.descripcion IS NOT NULL) THEN
				_unidadAuxiliar:=recordNeg.descripcion;
				_negocio:=recordNeg.cod_neg;
			ELSE
				_unidadAuxiliar:='';
				_negocio:='';
			END IF;
		END IF;

		raise notice 'recordPagos.num_ingreso := % _unidadAuxiliar:= % ',recordPagos.num_ingreso,_unidadAuxiliar;


		 IF(recordPagos.documento ='')THEN
			recordNeg.descripcion:=_unidadAuxiliar;--'Interes x mora';
			recordNeg.cod_neg:=_negocio;
		END IF;


		--CUENTAS IXM
-- 		IF(recordPagos.cuenta IN ('I010140014170','I010130014170','93950702','94350301','I010130024170'))THEN
-- 			recordNeg.descripcion:='Interes x mora';
-- 			recordNeg.cod_neg:=_negocio;
-- 		END IF;
--
-- 		-- CUENTAS GAC.
-- 		IF(recordPagos.cuenta IN ('I010140014205','I010130014205','28150531','28150530','93950701','94350302'))THEN
-- 			recordNeg.descripcion:='Gastos cobranza';
-- 			recordNeg.cod_neg:=_negocio;
-- 		END IF;
--
-- 		--SALDO A FAVOR
-- 		IF(recordPagos.cuenta IN ('23809504','I010130014225','I010140014225'))THEN
-- 		         recordNeg.descripcion:='Saldo a favor';
-- 			 recordNeg.cod_neg:=_negocio;
-- 		END IF;

		rs.anio:=recordPagos.anio;
		rs.periodo:=recordPagos.periodo;
	        rs.anio_consignacion:=recordPagos.anio_consignacion;
		rs.periodo_consignacion:=recordPagos.periodo_consignacion;
		rs.banco:=recordPagos.branch_code;
		rs.sucursal :=recordPagos.bank_account_no;
		rs.num_ingreso :=recordPagos.num_ingreso;
		rs.tipo_documento :=recordPagos.tipo_documento;
		rs.creation_date :=recordPagos.creation_date;
		rs.nitcli :=recordPagos.nitcli;
		rs.nombre_cliente:=recordPagos.nombre_cliente;
		rs.fecha_consignacion :=recordPagos.fecha_consignacion;
		rs.cuenta :=recordPagos.cuenta;
		rs.documento :=recordPagos.documento;
		rs.tipo_doc :=recordPagos.tipo_doc;
		rs.valor_ingreso :=recordPagos.valor_ingreso;
		rs.unidad_negocio :=recordNeg.descripcion;
		rs.negocio :=recordNeg.cod_neg;
		rs.cuota :=recordPagos.cuota;
		rs.descripcion:=recordPagos.descripcion;
		rs.negocio :=recordNeg.cod_neg;
		rs.cuenta_banco:=COALESCE((SELECT codigo_cuenta FROM banco  WHERE branch_code =recordPagos.branch_code AND bank_account_no=recordPagos.bank_account_no ),'00000000');
		rs.creation_user :=recordPagos.creation_user ;

		IF(recordNeg.descripcion =_unidadNego)THEN
			RETURN NEXT rs;
		END IF;

	END LOOP  _loop ;

	--CERRAMOS EL CURSOR
	CLOSE cursor_recaudo;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.eg_recaudo_xunidad(character varying, character varying)
  OWNER TO postgres;
