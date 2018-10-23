-- Function: mc_legalizacion_cxp_cabecera(character varying, character varying, numeric, character varying, character varying, character varying)

-- DROP FUNCTION mc_legalizacion_cxp_cabecera(character varying, character varying, numeric, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION mc_legalizacion_cxp_cabecera(documento_ character varying, nums_factura_ character varying, valor_legalizar_ numeric, cod_anticipo_ character varying, usuario_ character varying, autorozador_ character varying)
  RETURNS boolean AS
$BODY$

DECLARE 

respuesta boolean :=false;

anticipoxlegalizar RECORD;
infoFacturarel RECORD;
infoFacturarelDET RECORD;


  BEGIN


	--BUSCAMOS LOS ANTICIPOS QUE ESTAN SIN LEGALIZAR
	FOR anticipoxlegalizar IN  
		SELECT 
			cod_anticipo::varchar,
			empleado::varchar,
			concepto::varchar,
			banco::varchar,
			sucursal::varchar,
			valor_anticipo::numeric,
			num_factura::varchar,
			num_cxp::varchar,
			tipo_num_doc_leg::varchar,
			num_doc_legalizado::varchar,
			tipo_anticipo::varchar
		FROM anticipos_caja_menor 
		WHERE reg_status =''
		AND cod_anticipo = cod_anticipo_
		AND legalizado ='N' 

	LOOP

		raise notice 'anticipoxlegalizar: %',anticipoxlegalizar;
		
		SELECT INTO infoFacturarel   * FROM con.factura where documento = nums_factura_ and tipo_documento = 'FAC' and dstrct = 'FINV'; 
		SELECT INTO infoFacturarelDET  * FROM con.factura_detalle where documento = nums_factura_ and tipo_documento = 'FAC' and dstrct = 'FINV'; 
		raise notice 'infoFacturarel: %',infoFacturarel; 

		--CREAMOS LA CABECERA DE LA CXP
		INSERT INTO fin.cxp_doc(
			reg_status,dstrct, proveedor, tipo_documento, documento, descripcion,agencia,
			handle_code, aprobador, moneda,
			vlr_neto, vlr_total_abonos, vlr_saldo, vlr_neto_me, vlr_total_abonos_me, vlr_saldo_me,
			creation_date, creation_user, base, moneda_banco,fecha_documento, fecha_vencimiento,
			tipo_documento_rel, documento_relacionado,tipo_referencia_2,referencia_2, banco,sucursal)
		VALUES (
			'','FINV', infoFacturarel.nit, 'FAP', documento_, 'LEGALIZACION DEL ANTICPO: '||anticipoxlegalizar.cod_anticipo, 'OP', 
			infoFacturarel.cmc, autorozador_, 'PES', 
			valor_legalizar_, 0, valor_legalizar_, valor_legalizar_, 0, valor_legalizar_,
			now(), usuario_, 'COL','PES', NOW(),NOW(),
			'LCM', anticipoxlegalizar.cod_anticipo, 'LCM', anticipoxlegalizar.cod_anticipo,anticipoxlegalizar.banco,anticipoxlegalizar.sucursal);


		respuesta:= true;

	END LOOP;
		
   	return respuesta;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION mc_legalizacion_cxp_cabecera(character varying, character varying, numeric, character varying, character varying, character varying)
  OWNER TO postgres;

