-- Function: reversar_recaudos(text)

-- DROP FUNCTION reversar_recaudos(text);

CREATE OR REPLACE FUNCTION reversar_recaudos(text)
  RETURNS text AS
$BODY$DECLARE
  inicios_cxcs1 ALIAS FOR $1;
  respuesta TEXT;
  inicios_cxcs TEXT;
BEGIN
SELECT INTO inicios_cxcs REPLACE (inicios_cxcs1, ',', ''',''') ;
/*
CREATE TABLE copia.factura90916 AS SELECT * FROM con.factura;
CREATE TABLE copia.ingreso90916 AS SELECT * FROM con.ingreso;
CREATE TABLE copia.ingreso_detalle90916 AS SELECT * FROM con.ingreso_detalle;
CREATE TABLE copia.comprobante90916 AS SELECT * FROM con.comprobante;
CREATE TABLE copia.comprodet90916 AS SELECT * FROM con.comprodet;
CREATE TABLE copia.recaudo_eca_desfasado90916 AS SELECT * FROM recaudo_eca_desfasado;
CREATE TABLE copia.intereses_mora_eca90916 AS SELECT * FROM intereses_mora_eca;
CREATE TABLE copia.recaudo_eca90916 AS SELECT * FROM recaudo_eca;
*/
UPDATE con.factura
SET fecha_ultimo_pago='0099-01-01',valor_abono=0,valor_saldo=valor_factura,valor_abonome=0,valor_saldome=valor_factura,zona=''
WHERE SUBSTR(documento,1,7) IN (inicios_cxcs);

UPDATE con.ingreso
SET reg_status='A'
WHERE num_ingreso IN (SELECT num_ingreso
	FROM con.ingreso_detalle
	WHERE SUBSTR(factura,1,7) IN (inicios_cxcs));

UPDATE con.ingreso_detalle
SET reg_status='A'
WHERE SUBSTR(factura,1,7) IN (inicios_cxcs);

DELETE FROM con.comprobante
WHERE tipodoc='ING' AND numdoc IN (SELECT num_ingreso
	FROM con.ingreso_detalle
	WHERE SUBSTR(factura,1,7) IN (inicios_cxcs));

DELETE FROM con.comprodet
WHERE tipodoc='ING' AND numdoc IN (SELECT num_ingreso
	FROM con.ingreso_detalle
	WHERE SUBSTR(factura,1,7) IN (inicios_cxcs));

DELETE FROM recaudo_eca_desfasado
WHERE SUBSTR(documento_cxc,1,7) IN (inicios_cxcs);

DELETE FROM intereses_mora_eca;

UPDATE recaudo_eca_desfasado
SET procesado='NO';

UPDATE recaudo_eca
SET reg_status='A' , saldo=valor,fecha_cruce='0099-01-01 00:00:00',factura=''
WHERE SUBSTR(cxc_excel,1,7) IN (inicios_cxcs) AND comentario!='' ;

 SELECT INTO respuesta ' Proceso ejecutado.'	;
RETURN respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION reversar_recaudos(text)
  OWNER TO postgres;
