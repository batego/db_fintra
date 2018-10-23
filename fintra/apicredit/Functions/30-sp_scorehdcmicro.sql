-- Function: apicredit.sp_scorehdcmicro(integer, character varying)

-- DROP FUNCTION apicredit.sp_scorehdcmicro(integer, character varying);

CREATE OR REPLACE FUNCTION apicredit.sp_scorehdcmicro(_numero_solicitud integer, _huella character varying)
  RETURNS text AS
$BODY$

DECLARE

respuesta varchar := '{}';
exclusion varchar:='';
recordPresolicitud record;
recordPersonas record;
recordCuentaCartera record;
recordTarjetaCredito record;
flag boolean;
fechahoy integer;
fechaapert integer;
micr varchar[]:='{MCR}';
abierta varchar[]:='{01,13,14,15,16,17,18,19,20,
		     21,22,23,24,25,26,27,28,29,
		     30,31,32,33,34,35,36,37,38,
		     39,40,41,45,47}';

diasmoramicro integer:=0;
moras integer:=0;
a integer:=0;
utilizacion_cuenta_cartera_a_fecha numeric;
cupocc numeric:=0;
saldocc numeric:=0;
cupotc numeric:=0;
saldotc numeric:=0;
recordInfoAgreResumen record;
nCuentasMicro integer:=0;
contador integer:=0;
fechaCom integer:=0;
maxExpMIC integer:=0;
edad varchar;

--variables calculos...
diasmoramicro_cal integer;
utilizacion_cuenta_cartera_a_fecha_cal integer;
creditosActulesNegativos_cal integer;
creditosCerrados_cal integer;
maxExpMIC_cal integer;
edad_cal integer;
saldoTotal_cal numeric;
nCuentasMicro_cal integer;
_score integer;
_baseSalarioMinimo NUMERIC:=(SELECT salario_minimo_mensual FROM salario_minimo  where ano=substring(current_date,1,4));
idconvenio varchar;
_estado_sol varchar;
_comentarios varchar;
_flagCarteraCastigada boolean:=false;


BEGIN


	--1.) informacion basica de la presolicitud de credito.
	SELECT INTO recordPresolicitud numero_solicitud,
	       entidad,
	       monto_credito,
	       valor_cuota,
	       numero_cuotas,
	       fecha_pago,
	       identificacion,
	       fecha_expedicion,
	       primer_nombre,
	       primer_apellido,
	       fecha_nacimiento,
	       email,
	       ciudad,
	       asesor
       FROM apicredit.pre_solicitudes_creditos WHERE numero_solicitud=_numero_solicitud ;


       --Buscamos el convenio.
	idconvenio :=COALESCE((SELECT id_convenio FROM convenios
				WHERE tipo='Microcredito'
				AND id_convenio not in (37,41,15,40)
				AND round(recordPresolicitud.monto_credito/_baseSalarioMinimo,2) BETWEEN monto_minimo AND monto_maximo
				AND agencia IN (SELECT coddpt FROM  ciudad  where codciu=recordPresolicitud.ciudad)),0);

	raise notice 'idconvenio : %',idconvenio;

	--Informacion persona HDC+
	SELECT INTO recordPersonas
	       tipo_identificacion,
	       identificacion,
	       estado_id,
	       fecha_expedicion_id,
	       ciudad_id,
	       departamento_id,
	       nombre,
	       nombre_completo,
	       primer_apellido,
	       segundo_apellido,
	       genero,
	       edad_min,
	       edad_max,
	       trim(tipo_cliente) as tipo_cliente
        FROM wsdc.persona WHERE identificacion=recordPresolicitud.identificacion  AND  nit_empresa='8020220161' ;

        RAISE notice 'recordPersonas.identificacion : %',recordPersonas.identificacion;

        --2.0)Validacion cliente tipo 7
        IF(recordPersonas.tipo_cliente='09')THEN
		UPDATE apicredit.pre_solicitudes_creditos
		   SET estado_sol = 'R',
		       score = 0.0,
		       comentario ='RECHAZO CLIENTE TIPO 7',
		       id_convenio=idconvenio::integer,
		       last_update = now(),
		       user_update =recordPresolicitud.asesor
		WHERE numero_solicitud = _numero_solicitud;

		RETURN '{"respuesta":"R","valor":"'||recordPresolicitud.monto_credito||'"}';
        END IF;

	/**inicio de las exclusiones **/
	--2.1)Exclusion clientes diferentes a personas naturales
	IF(recordPersonas.tipo_identificacion IN ('2','3'))THEN
		exclusion:='excluir';
	END IF;

	--2.2) Exclusion de clientes diferentes a personas con documento vigente
	IF(recordPersonas.estado_id != '00' and exclusion != 'excluir')THEN
		exclusion:='excluir';
	END IF;

	--2.3) Exclusion de clientes no bancarizados
	flag:=false;
	FOR  recordCuentaCartera IN
				    SELECT
				       cca.id,
				       cca.bloqueada,
				       cca.entidad,
				       cca.numero_obligacion,
				       cca.fecha_apertura,
				       cca.fecha_vencimiento,
				       cca.comportamiento,
				       CASE WHEN STRPOS(cca.comportamiento, 'C')=0 THEN 'N' ELSE 'S' END AS cartera_castigada,
				       CASE WHEN STRPOS(cca.comportamiento,'D')=0 THEN 'N' ELSE 'S' END AS dudoso_recaudo,
				       cca.forma_pago,
				       cca.situacion_titular,
				       cca.oficina,
				       cca.ultima_actualizacion,
				       cca.cod_suscriptor,
				       cca.tipo_identificacion,
				       cca.identificacion,
				       cca.tipo_cuenta as caract_tipo_cuenta,
				       cca.tipo_obligacion as caract_tipo_obligacion,
				       cca.tipo_contrato as caract_tipo_contrato,
				       cca.ejecucion_contrato as caract_ejecucion_contrato,
				       cca.ejecucion_contrato as caract_ejecucion_contrato,
				       cca.garante as caract_calidad_deudor,
				       cca.estado_origen,
				       cca.estado as estado_pago,
				       cca.estado_cuenta,
				       cca.nit_empresa,
				       v.valor_inicial,
				       v.cupo,
				       v.saldo_actual,
				       v.saldo_mora,
				       v.cuota,
				       v.cuotas_canceladas,
				       v.total_cuotas,
				       v.maxima_mora as dias_mora
				FROM wsdc.cuenta_cartera cca
				INNER JOIN wsdc.valor v  on (v.id_padre=cca.id and tipo_padre='CCA')
				WHERE cca.identificacion=recordPresolicitud.identificacion  AND  cca.nit_empresa='8020220161'

	LOOP
		--clientes no bancarizados
		IF(recordCuentaCartera.caract_calidad_deudor ='00' AND recordCuentaCartera.estado_pago  not in ('45','47')) THEN
			flag:=true;
		END IF;

		--clientes con cuentas en el sector real
		fechahoy:= TO_CHAR(NOW(), 'YYYY')::INTEGER *12 + TO_CHAR(NOW(), 'MM')::INTEGER;
		fechaapert := TO_CHAR(recordCuentaCartera.fecha_apertura, 'YYYY')::INTEGER *12 + TO_CHAR(recordCuentaCartera.fecha_apertura, 'MM')::INTEGER;

		IF(recordCuentaCartera.caract_tipo_cuenta not in ('CVE','CTU','CMU','CEL','ALI','CMZ','COM','FER') or  (fechahoy-fechaapert) >6)THEN
			flag:=true;
		END IF;

		--validacion cartera castigada o dudoso recaudo.
		IF recordCuentaCartera.cartera_castigada ='S' OR recordCuentaCartera.dudoso_recaudo='S' THEN
			flag:=false;
			_flagCarteraCastigada:=true;
			EXIT;
		END IF;

	END LOOP;

	IF flag=false AND exclusion !='excluir' THEN exclusion:='excluir'; END IF;


	/**fin  de las exclusiones **/
	RAISE notice '..:::Resultado variables de exclusion:::..';
	RAISE notice '2.0) Flag := %',flag;
	RAISE notice '2.1) Exclusion := %',exclusion;
	RAISE notice '';

	--3.0) Seleccion y construccion de caracteristicas del modelo.
	RAISE notice '..:::Definiciones Generales Para Las Caracteristicas:::..';
	RAISE notice '3.0) micr := %',micr;
	RAISE notice '3.1) abierta := %',abierta;

	--3.2)Caracteristicas del modelo

	diasmoramicro :=-999;
	moras :=0;
	a:=0;
	flag:= FALSE;

	utilizacion_cuenta_cartera_a_fecha:=-999;
	cupocc :=0;
	saldocc :=0;
	nCuentasMicro=-999;

	fechaCom=0;
	fechahoy:= TO_CHAR(NOW(), 'YYYY')::INTEGER *12 + TO_CHAR(NOW(), 'MM')::INTEGER;
	maxExpMIC=-999;
	FOR  recordCuentaCartera IN
				    SELECT
				       cca.id,
				       cca.bloqueada,
				       cca.entidad,
				       cca.numero_obligacion,
				       cca.fecha_apertura,
				       cca.fecha_vencimiento,
				       cca.comportamiento,
				       cca.forma_pago,
				       cca.situacion_titular,
				       cca.oficina,
				       cca.ultima_actualizacion,
				       cca.cod_suscriptor,
				       cca.tipo_identificacion,
				       cca.identificacion,
				       cca.tipo_cuenta AS caract_tipo_cuenta,
				       cca.tipo_obligacion AS caract_tipo_obligacion,
				       cca.tipo_contrato AS caract_tipo_contrato,
				       cca.ejecucion_contrato AS caract_ejecucion_contrato,
				       cca.ejecucion_contrato AS caract_ejecucion_contrato,
				       cca.garante AS caract_calidad_deudor,
				       cca.estado_origen,
				       cca.estado AS estado_pago,
				       cca.estado_cuenta,
				       cca.nit_empresa,
				       v.valor_inicial,
				       v.cupo,
				       v.saldo_actual,
				       v.saldo_mora,
				       v.cuota,
				       v.cuotas_canceladas,
				       v.total_cuotas,
				       v.maxima_mora AS dias_mora
				FROM wsdc.cuenta_cartera cca
				INNER JOIN wsdc.valor v  ON (v.id_padre=cca.id AND tipo_padre='CCA')
				WHERE cca.identificacion=recordPresolicitud.identificacion  AND  cca.nit_empresa='8020220161'

	LOOP

		--dias mora micro
		IF(recordcuentacartera.caract_tipo_cuenta = ANY(micr) AND recordcuentacartera.estado_pago= ANY(abierta) )THEN
			flag=TRUE;
			contador:=contador+1;
			IF(recordcuentacartera.dias_mora IS NOT NULL)THEN
			    raise notice 'recordcuentacartera.dias_mora:  %',recordcuentacartera.dias_mora;
			    moras:= moras+recordcuentacartera.dias_mora ;
			    a :=a+1;
			END IF;
		END IF;
		raise notice 'recordCuentaCartera.fecha_apertura:  %',recordCuentaCartera.fecha_apertura;
		--utilizacion cuenta cartera a la fecha
		IF(recordcuentacartera.estado_pago= ANY(abierta))THEN
			IF recordcuentacartera.valor_inicial IS NOT NULl  THEN
				cupocc:=cupocc+recordcuentacartera.valor_inicial;
			END IF;

			IF recordcuentacartera.saldo_actual IS NOT NULL  THEN
				saldocc:=saldocc+recordcuentacartera.saldo_actual;
			END IF;

		END IF;



		--maxExpMic # meses desde la apertura de la cuenta de microcredito
		fechaapert:=TO_CHAR(recordCuentaCartera.fecha_apertura, 'YYYY')::INTEGER *12 + TO_CHAR(recordCuentaCartera.fecha_apertura, 'MM')::INTEGER;
		IF recordcuentacartera.caract_tipo_cuenta = ANY(micr) THEN
			IF fechaCom > (fechahoy-fechaapert) THEN
				maxExpMIC:=fechahoy-fechaapert;
				fechaCom:=fechahoy-fechaapert;
			END IF;
		END IF;

	END LOOP;

	IF flag THEN diasmoramicro:=moras/a ; nCuentasMicro:=contador; END IF;


	--Saldos tarjetas de credito.
	FOR recordTarjetaCredito IN
					SELECT
					       tc.entidad,
					       tc.ultima_actualizacion,
					       tc.numero,
					       tc.fecha_apertura,
					       tc.fecha_vencimiento,
					       tc.comportamiento,
					       tc.amparada,
					       tc.forma_pago,
					       tc.bloqueada,
					       tc.estado as estado_pago,
					       tc.estado_origen,
					       v.valor_inicial,
					       v.cupo as cupo_total,
					       v.saldo_actual,
					       v.saldo_mora,
					       v.cuota,
					       v.cuotas_canceladas,
					       v.total_cuotas,
					       v.maxima_mora AS dias_mora
					FROM wsdc.tarjeta_credito tc
					INNER JOIN wsdc.valor v  ON (v.id_padre=tc.id AND v.tipo_padre='TCR')
					WHERE tc.identificacion=recordPresolicitud.identificacion  AND  tc.nit_empresa='8020220161'

	LOOP

		IF(recordTarjetaCredito.estado_pago= ANY(abierta))THEN
			IF recordTarjetaCredito.cupo_total IS NOT NULl  THEN
				cupotc:=cupotc+recordTarjetaCredito.cupo_total;
			END IF;

			IF recordTarjetaCredito.saldo_actual IS NOT NULL  THEN
				saldotc:=saldotc+recordTarjetaCredito.saldo_actual;
			END IF;

		END IF;

	END LOOP;

	IF (cupocc+cupotc )>0 THEN utilizacion_cuenta_cartera_a_fecha=ROUND((saldocc+saldotc)/(cupocc+cupotc),2)*100; END IF;


	--) Creditos Actuales Negativos, creditos_cerrados, saldo_total

	SELECT INTO recordInfoAgreResumen
	       COALESCE(rspr.creditosactualesnegativos,'-999')::NUMERIC AS creditosActulesNegativos,
	       COALESCE(rspr.creditoscerrados,'-999')::NUMERIC AS creditosCerrados ,
	       COALESCE(infrs.saldototal,'-999')::NUMERIC AS saldoTotal
	FROM wsdc.infoagr_rs_principales rspr
	INNER JOIN wsdc.infoagr_rs_saldos infrs ON (infrs.identificacion=rspr.identificacion AND rspr.nit_empresa=infrs.nit_empresa)
	WHERE rspr.identificacion=recordPresolicitud.identificacion AND rspr.nit_empresa='8020220161' ;

	raise notice '3.2) convertir saldoTotal : % en terminos de salirios minimos : %',recordInfoAgreResumen.saldoTotal,round((recordInfoAgreResumen.saldoTotal*1000)/_baseSalarioMinimo,2);
	recordInfoAgreResumen.saldoTotal:=round((recordInfoAgreResumen.saldoTotal*1000)/_baseSalarioMinimo,2);


	--Edad
	IF recordPersonas.edad_min !='' AND recordPersonas.edad_max !=''THEN
		edad:=trim(recordPersonas.edad_min)||'-'||trim(recordPersonas.edad_max);
	ELSIF (recordPersonas.edad_min !='') THEN
		edad:=trim(recordPersonas.edad_min);
	ELSE
		edad:='-999';
	END IF;

	RAISE notice '3.3) diasmoramicro := %',diasmoramicro;
	RAISE notice '3.4) cupocc := %',cupocc;
	RAISE notice '3.5) saldocc := %',saldocc;
	RAISE notice '3.6) cupotc := %',cupotc;
	RAISE notice '3.7) saldotc := %',saldotc;
	RAISE notice '3.8) utilizacion_cuenta_cartera_a_fecha (saldocc/cupocc)*100 := %',utilizacion_cuenta_cartera_a_fecha;
	RAISE notice '3.9) creditosActulesNegativos := %',recordInfoAgreResumen.creditosActulesNegativos;
	RAISE notice '3.10) recordInfoAgreResumen.creditosCerrados:= %',recordInfoAgreResumen.creditosCerrados;
	RAISE notice '3.11) saldoTotal := %',recordInfoAgreResumen.saldoTotal;
	RAISE notice '3.12) nCuentasMicro := %',nCuentasMicro;
	RAISE notice '3.13) maxExpMIC := %',maxExpMIC;
	RAISE notice '3.14) Edad := %',edad;

        RAISE notice '';

	--4.) puntuacion...

	--dias mora calculo
	IF diasmoramicro <= 0 THEN
		diasmoramicro_cal:=40;
	ELSE
		diasmoramicro_cal:=-53;
	END IF;

	--utilizacion cuenta cartera calculo
	IF utilizacion_cuenta_cartera_a_fecha < 0 THEN

		utilizacion_cuenta_cartera_a_fecha_cal:=40;

	ELSIF utilizacion_cuenta_cartera_a_fecha <=24.9 THEN

		utilizacion_cuenta_cartera_a_fecha_cal:=182;

	ELSIF utilizacion_cuenta_cartera_a_fecha <=60 THEN

		utilizacion_cuenta_cartera_a_fecha_cal:=103;

	ELSIF utilizacion_cuenta_cartera_a_fecha <=80 THEN

		utilizacion_cuenta_cartera_a_fecha_cal:=40;
	ELSE
		utilizacion_cuenta_cartera_a_fecha_cal:=15;
	END IF;

	--creditos actuales negativos calculo
	IF recordInfoAgreResumen.creditosActulesNegativos <= 0 THEN
	       creditosActulesNegativos_cal:=40;
	ELSE
	       creditosActulesNegativos_cal:=-66;
	END IF;

	--creditos cerrados calculo
	IF recordInfoAgreResumen.creditosCerrados <=6 THEN
		creditosCerrados_cal:=40;
	ELSIF recordInfoAgreResumen.creditosCerrados <=17 THEN
		creditosCerrados_cal:=75;
	ELSE
	       creditosCerrados_cal:=156;
	END IF;

	--maxExpmic_cal
	IF maxExpMIC <0 OR (maxExpMIC > 24 AND maxExpMIC <=63) THEN
		maxExpMIC_cal:=40;
									--ELSIF maxExpMIC <= 9 THEN
									--	maxExpMIC_cal:=-144;
	ELSIF maxExpMIC <= 24 THEN
		maxExpMIC_cal:=-11;
	ELSE
		maxExpMIC_cal:=72;
	END IF;

	-- edad calculo
	IF edad='18-21' or edad='22-28' THEN
		edad_cal:=40;
	ELSIF edad='-999' or edad='29-35' OR edad='36-45' OR edad='45-55' THEN
		edad_cal:=85;
	ELSE
		edad_cal:=110;
	END IF;

	--saldo total calculo
	IF recordInfoAgreResumen.saldoTotal < 0 THEN
		saldoTotal_cal:=40;
	ELSIF recordInfoAgreResumen.saldoTotal =0 THEN
		saldoTotal_cal:=102;
	ELSIF recordInfoAgreResumen.saldoTotal <=2.29 THEN
		saldoTotal_cal:=66;
	ELSE
		saldoTotal_cal:=40;

	END IF;

	--numero cuentas micro

	IF nCuentasMicro <= 1 THEN
		nCuentasMicro_cal:=40;
	ELSIF nCuentasMicro <=2 THEN
		nCuentasMicro_cal:=-57;
	ELSE
		nCuentasMicro_cal=-62;
	END IF;

	--score final
	IF exclusion='excluir' THEN
		_score:=-999;
	ELSE
		_score:=284 + diasmoramicro_cal + utilizacion_cuenta_cartera_a_fecha_cal + creditosActulesNegativos_cal +
				creditosCerrados_cal + maxExpMIC_cal + edad_cal + saldoTotal_cal + nCuentasMicro_cal ;

	END IF;

	--guarda el resultado de la variables


	INSERT INTO apicredit.historico_score_micro(
		    reg_status, s_numero_solicitud, s_identificacion,s_exclusion, s_base_score,
		    s_diasmoramicro_cal, s_utilizacion_cuenta_cartera_a_fecha_cal,
		    s_creditosactulesnegativos_cal, s_creditoscerrados_cal, s_maxexpmic_cal,
		    s_edad_cal, s_saldototal_cal, s_ncuentasmicro_cal,s_score_total,s_creation_date)
	    VALUES ('', _numero_solicitud, recordPresolicitud.identificacion,exclusion, 284,
		    diasmoramicro_cal, utilizacion_cuenta_cartera_a_fecha_cal,
		    creditosActulesNegativos_cal, creditosCerrados_cal, maxExpMIC_cal,
		    edad_cal, saldoTotal_cal, nCuentasMicro_cal,_score,NOW());



	RAISE notice '.......::::::::Puntuacion y calculos::::::::.......';
	RAISE notice 'Base inicial : 284';
	RAISE notice 'diasmoramicro_cal : %',diasmoramicro_cal;
	RAISE notice 'utilizacion_cuenta_cartera_a_fecha_cal : %',utilizacion_cuenta_cartera_a_fecha_cal;
	RAISE notice 'creditosActulesNegativos_cal : %',creditosActulesNegativos_cal;
	RAISE notice 'creditosCerrados_cal : %',creditosCerrados_cal;
	RAISE notice 'maxExpMIC_cal : %',maxExpMIC_cal;
	RAISE notice 'edad_cal : %',edad_cal;
	RAISE notice 'saldoTotal_cal : %',saldoTotal_cal;
	RAISE notice 'nCuentasMicro_cal : %',nCuentasMicro_cal;
	RAISE notice 'Suma total_score : %',_score;

	--VALIDACIONES SCORE
	IF(_score >= 574)THEN
		_estado_sol:='P';
		_comentarios:='Pre Aprobado';
	ELSIF(_score BETWEEN 565 AND 573 )THEN
		_estado_sol:='Z';
		_comentarios:='Zona Gris';
	ELSIF (_score < 564) THEN
		_estado_sol:='R';
		_comentarios:='Rechazado';
	END IF;

	--validacion zona gris para clietes no bancarizados y sector real (cambio realizado por solicitud de wsarez)
	IF(flag=false and _flagCarteraCastigada=false)THEN
	    _estado_sol:='Z';
	    _comentarios:='Zona Gris';
	END IF;

       --validacion cartera castigada y dudoso recaudo.
	IF(flag=false and _flagCarteraCastigada=true)THEN
	    _estado_sol:='R';
	    _comentarios:='Rechazado';
	END IF;


	raise notice '_estado_sol : %',_estado_sol;
	--ACTUALIZAR LA TABLA apicredit.pre_solicitudes_creditos. los campos: estado_sol: P/Z/R, score: puntaje, causal: F02, comentarios: blabla blabla
	UPDATE apicredit.pre_solicitudes_creditos
	   SET estado_sol = _estado_sol,
	       score = _score, comentario =_comentarios,
	       id_convenio=idconvenio::integer,
	       last_update = now(),
	       user_update =recordPresolicitud.asesor
        WHERE numero_solicitud = _numero_solicitud;

        respuesta := '{"respuesta":"'||_estado_sol||'","valor":"'||recordPresolicitud.monto_credito||'"}';


	RETURN respuesta;


end;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION apicredit.sp_scorehdcmicro(integer, character varying)
  OWNER TO postgres;
