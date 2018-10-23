-- Function: mc_cuotasmanejofacturar(character varying, character varying)

-- DROP FUNCTION mc_cuotasmanejofacturar(character varying, character varying);

CREATE OR REPLACE FUNCTION mc_cuotasmanejofacturar(negocio_ character varying, documento_ character varying)
  RETURNS boolean AS
$BODY$

DECLARE
repuesta boolean := false;
informacionNegocioCuota record;

valor numeric;

numeroDocumemtoCXC varchar;

BEGIN
	--CONSULTAMOS LA INFROMACION DE DOCUEMNTOS NEG ACEPTADOS
	FOR informacionNegocioCuota IN 
		select 
		neg.cod_cli::varchar
		,neg.fecha_negocio::varchar
		,dna.item::varchar
		,dna.cuota_manejo::numeric 
		,dna.cuota_manejo_causada::numeric
		,fac.concepto::varchar
		,dna.fecha::date
		,'CXC_CUOT_MANEJO'::varchar as prefijo_cxc_cuota_manejo
		,fac.negasoc::varchar
		,conv.hc_cuota_manejo::varchar
		,conv.cuenta_cuota_manejo::varchar
		,cu.nombre_largo::varchar
		,fac.documento
		from negocios neg
		inner join documentos_neg_aceptado dna on (neg.cod_neg=dna.cod_neg)
		inner join convenios conv on (neg.id_convenio=conv.id_convenio)
		inner join con.factura fac on (fac.negasoc=neg.cod_neg  and fac.descripcion!= conv.prefijo_cxc_interes and fac.descripcion!=conv.prefijo_cxc_cat and fac.descripcion!='' and fac.descripcion != 'CXC_CUOT_MANEJO')
		inner join con.cuentas cu on ( cu.cuenta = Conv.cuenta_cuota_manejo )
		where
		neg.estado_neg='T' 
		and  conv.tipo='Consumo' 
		and fac.reg_status=''
		and fac.reg_status='' 
		and fac.fecha_vencimiento=dna.fecha 
		and neg.cod_neg= negocio_
		and fac.documento = documento_

	
	LOOP
		raise notice 'informacionNegocioCuota%',informacionNegocioCuota;

		--CALCULAMOS EL VALOR 
		valor:= informacionNegocioCuota.cuota_manejo - informacionNegocioCuota.cuota_manejo_causada;
		raise notice 'valor: %',valor;

		--OBTENEMOS NUMERO DE DOCUEMNTO DE FACTURA
		select into numeroDocumemtoCXC get_lcod('CXC_CUOT_MANEJO');
		raise notice 'numeroDocumemtoCXC: %',numeroDocumemtoCXC;
		
		
		--CREAMOS LA CABECERA CXC
		insert into con.factura(
			tipo_documento,documento,nit,codcli,concepto,fecha_factura,fecha_vencimiento,
			descripcion,valor_factura,valor_tasa,moneda,cantidad_items,forma_pago,agencia_facturacion,
			agencia_cobro,creation_date,creation_user,valor_facturame,valor_saldo,valor_saldome,negasoc,base,
			num_doc_fen,tipo_ref1,ref1,cmc,dstrct)
		values(
			'FAC',numeroDocumemtoCXC,informacionNegocioCuota.cod_cli,get_codnit(informacionNegocioCuota.cod_cli),informacionNegocioCuota.concepto,now(),informacionNegocioCuota.fecha,
			informacionNegocioCuota.prefijo_cxc_cuota_manejo,valor,1,'PES',1,'CREDITO','OP',
			'BQ',now(),'ADMIN',valor,valor,valor,informacionNegocioCuota.negasoc,'COL',
			informacionNegocioCuota.item,'','',informacionNegocioCuota.hc_cuota_manejo,'FINV');

		--CREAMOS EL DETALLE CXC
			insert into con.factura_detalle(
			tipo_documento,documento,item,nit,concepto,descripcion,cantidad,
			valor_unitario,valor_item,valor_tasa,moneda,creation_date,creation_user,valor_unitariome,
			valor_itemme,numero_remesa,base,auxiliar,codigo_cuenta_contable,dstrct)
		values(
			'FAC',numeroDocumemtoCXC,1,informacionNegocioCuota.cod_cli,informacionNegocioCuota.concepto,informacionNegocioCuota.nombre_largo,1,
			valor,valor,1,'PES',now(),'ADMIN',valor,
			valor,informacionNegocioCuota.documento,'COL','RD-',informacionNegocioCuota.cuenta_cuota_manejo,'FINV');

		valor:= valor +  informacionNegocioCuota.cuota_manejo_causada;

		--ACTUALIZAMOS EN LA TABLA 
		UPDATE documentos_neg_aceptado set 
			cuota_manejo_causada=valor, fch_cuota_manejo_causada=NOW()
		WHERE 
			cod_neg=informacionNegocioCuota.negasoc 
			and item=informacionNegocioCuota.item;
		repuesta:= true;
	END LOOP;
	

	
RETURN repuesta;
	
		
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION mc_cuotasmanejofacturar(character varying, character varying)
  OWNER TO postgres;

