-- Function: business_intelligence.eg_analisis_colocaciones(date, date)

-- DROP FUNCTION business_intelligence.eg_analisis_colocaciones(date, date);

CREATE OR REPLACE FUNCTION business_intelligence.eg_analisis_colocaciones(_startseasondate date, _endseasondate date)
  RETURNS SETOF business_intelligence.rs_datos_colocaciones AS
$BODY$

DECLARE

 rs business_intelligence.rs_datos_colocaciones;
 recordNegocios record ;
 recordNegociosNuevos record;
 sw boolean:=true;
 contadorClientes integer:=0;

 --DECLARAMOS EL CURSOR
 cursor_negocios CURSOR(_startSeasonDate date, _endSeasonDate date) FOR (SELECT cod_cli,
									       REPLACE(SUBSTRING(f_desem,1,7),'-','') AS periodo_negocio,
									       get_nombc(cod_cli) as nombre_cliente,
									       id_convenio,
									       CASE WHEN id_convenio = 17 THEN 'EDUCATIVO FA'
									            ELSE 'EDUCATIVO FB' END AS unidad_negocio,
									       sum(vr_negocio) AS valor_negocio,
									       sum(valor_aval) AS valor_aval,
									       count(0) AS numero_creditos
									FROM negocios
									WHERE estado_neg='T'
									AND id_convenio in (17,31)  AND negocio_rel=''
									AND f_desem BETWEEN _startSeasonDate AND _endSeasonDate
									GROUP BY
									cod_cli,
									id_convenio,
									REPLACE(SUBSTRING(f_desem,1,7),'-','')
									ORDER BY cod_cli
									);


BEGIN
	--ABRIMOS EL CURSOR SIN PARAMETROS
	OPEN cursor_negocios(_startSeasonDate,_endSeasonDate) ;
	<<_loop>>
	LOOP
		-- FETCH FILA EN MY RECORD O TYPE
		FETCH cursor_negocios INTO recordNegocios;
		-- EXIT CUANDO NO HAY MAS FILAS
		EXIT WHEN NOT FOUND;

		--raise notice 'recordNegocios : %',recordNegocios;

		--SELECT estado_neg,* FROM negocios WHERE cod_cli=recordNegocios.cod_cli AND creation_date::DATE >_endSeasonDate;
		rs.identificacion := recordNegocios.cod_cli;
		rs.periodo_negocio := recordNegocios.periodo_negocio;
		rs.nombre_cliente :=recordNegocios.nombre_cliente;
		rs.unidad_negocio :=recordNegocios.unidad_negocio;
		rs.valor_negocio :=recordNegocios.valor_negocio;
		rs.valor_aval := recordNegocios.valor_aval ;
		rs.numero_creditos := recordNegocios.numero_creditos;

		SELECT INTO rs.tipo_cliente COALESCE((SELECT clasificacion
					     FROM administrativo.clasificacion_clientes_fintracredit
					     WHERE cedula_deudor=recordNegocios.cod_cli
					     AND id_convenio IN (17,31) ORDER BY periodo::INTEGER DESC LIMIT 1),'SIN_CLASIFICAR') AS tipo_cliente;

		FOR recordNegociosNuevos IN (SELECT  cod_neg as negocio_nuevo
						    ,REPLACE(SUBSTRING(fecha_negocio,1,7),'-','') AS periodo
						    ,CASE WHEN estado_neg='R' THEN 'RECHAZADO'
							    WHEN estado_neg='P' THEN 'ACEPTADO'
							    WHEN estado_neg='V' THEN 'AVALADO'
							    WHEN estado_neg='A' THEN 'APROBADO'
							    WHEN estado_neg='T' THEN 'TRANSFERIDO'
							    WHEN estado_neg='D' THEN 'DESISTIDO'
							    WHEN estado_neg IS NULL THEN '' END  AS  estado_neg
						    ,vr_negocio as valor_negocio
						FROM negocios
					     WHERE cod_cli=recordNegocios.cod_cli  AND negocio_rel='' and id_convenio=recordNegocios.id_convenio
					     AND creation_date::DATE >_endSeasonDate::date )
		LOOP
			sw:=false;

			IF(contadorClientes > 0)THEN
				rs.valor_negocio :=0;
				rs.valor_aval :=0 ;
			END IF;

			rs.periodo_nuevo_negocio:=recordNegociosNuevos.periodo;
			rs.estado_nuevo_negocio := recordNegociosNuevos.estado_neg;
			rs.cod_negocio_nuevo:= recordNegociosNuevos.negocio_nuevo;
			rs.valor_negocio_nuevo:=recordNegociosNuevos.valor_negocio;

			contadorClientes:=contadorClientes+1;

			RETURN NEXT rs;

	        END LOOP;
		raise notice 'sw := %',sw;
	        IF(sw)THEN
		    RETURN NEXT rs;
	        END IF;

		sw:=true;
		rs.cod_negocio_nuevo:='';
		rs.estado_nuevo_negocio:='';
		rs.periodo_nuevo_negocio:= '';
		rs.tipo_cliente:='';
		rs.valor_negocio_nuevo:=0.00;
		contadorClientes:=0;

	END LOOP  _loop ;

	--CERRAMOS EL CURSOR
	CLOSE cursor_negocios;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION business_intelligence.eg_analisis_colocaciones(date, date)
  OWNER TO postgres;
