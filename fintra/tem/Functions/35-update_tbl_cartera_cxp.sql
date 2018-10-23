-- Function: tem.update_tbl_cartera_cxp()

-- DROP FUNCTION tem.update_tbl_cartera_cxp();

CREATE OR REPLACE FUNCTION tem.update_tbl_cartera_cxp()
  RETURNS text AS
$BODY$DECLARE
BEGIN
DELETE FROM tem.tbl_cartera_cxp;
INSERT INTO tem.tbl_cartera_cxp
select proveedor,fc.tipo_documento,fc.handle_code,SUM(vlr_saldo) as valor ,case when NOW()::date-fecha_vencimiento < 0 then 'CORRIENTE'
					when NOW()::date-fecha_vencimiento between 0 and 30 then 'DE 1 A 30'
					when NOW()::date-fecha_vencimiento between 31 and 60 then 'DE 31 A 60'
					when NOW()::date-fecha_vencimiento between 61 and 90 then 'DE 61 A 90'
					when NOW()::date-fecha_vencimiento between 91 and 120 then 'DE 91 A 120'
					when NOW()::date-fecha_vencimiento between 121 and 180 then 'DE 121 A 180'
					when NOW()::date-fecha_vencimiento between 181 and 365 then 'DE 181 A 365'
					when NOW()::date-fecha_vencimiento > 365 then 'MAYOR A 1 AÑO'
				       END as rango


from fin.cxp_doc fc left join con.cmc_doc cm ON(cm.tipodoc=fc.tipo_documento and  fc.handle_code=cm.cmc and cm.dstrct='FINV' )
WHERE fc.reg_status=''
	     GROUP BY proveedor,fc.tipo_documento,fc.handle_code,case when NOW()::date-fecha_vencimiento < 0 then 'CORRIENTE'
		  when NOW()::date-fecha_vencimiento between 0 and 30 then 'DE 1 A 30'
		  when NOW()::date-fecha_vencimiento between 31 and 60 then 'DE 31 A 60'
		  when NOW()::date-fecha_vencimiento between 61 and 90 then 'DE 61 A 90'
		  when NOW()::date-fecha_vencimiento between 91 and 120 then 'DE 91 A 120'
		  when NOW()::date-fecha_vencimiento between 121 and 180 then 'DE 121 A 180'
		  when NOW()::date-fecha_vencimiento between 181 and 365 then 'DE 181 A 365'
		  when NOW()::date-fecha_vencimiento > 365 then 'MAYOR A 1 AÑO'
	     END;

  RETURN '';
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION tem.update_tbl_cartera_cxp()
  OWNER TO postgres;
