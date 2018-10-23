-- Function: eg_generar_extracto_reestructuracion(text[], character varying)

-- DROP FUNCTION eg_generar_extracto_reestructuracion(text[], character varying);

CREATE OR REPLACE FUNCTION eg_generar_extracto_reestructuracion(in_array text[], usuario character varying)
  RETURNS text AS
$BODY$
DECLARE

 negocioIn varchar:='';
 tipo_negocio varchar:='';
 capital numeric:=0;
 interes numeric:=0;
 intXmora numeric:=0;
 gac numeric:=0;
 totalIn numeric:=0;

 id_concepto_rec record;
 sumaConceptos numeric:=0;
 _cod_rop_real integer:=0;
 UnidadNeg integer:=0;
 periodoRop varchar:=0;
 vcto_rop date;
 ClienteRec record;
 sqlExtractoDetalle varchar:='';
 retorno varchar:='';
_porcentaje numeric:=0;
_valor_concepto varchar:='';
_aplicarDes varchar:='';
_validarROP boolean:=true;

BEGIN
	FOR i IN 1 .. (array_upper(in_array, 1)-1)
	LOOP

	      RAISE NOTICE 'indice i: % indice j: % valor : %',i,1, in_array[i][1]; --negocio
              RAISE NOTICE 'indice i: % indice j: % valor : %',i,2, in_array[i][2]; --tipo_negocio
              RAISE NOTICE 'indice i: % indice j: % valor : %',i,3, in_array[i][3]; --capital
              RAISE NOTICE 'indice i: % indice j: % valor : %',i,4, in_array[i][4]; --interes
              RAISE NOTICE 'indice i: % indice j: % valor : %',i,5, in_array[i][5]; --intXmora
              RAISE NOTICE 'indice i: % indice j: % valor : %',i,6, in_array[i][6]; --gac
              RAISE NOTICE 'indice i: % indice j: % valor : %',i,7, in_array[i][7]; --total
              RAISE NOTICE 'indice i: % indice j: % valor : %',i,8, in_array[i][8]; --porcentanje

		negocioIn :=in_array[i][1];
		tipo_negocio :=in_array[i][2];
		capital :=replace(in_array[i][3],',','');
		interes :=replace(in_array[i][4],',','');
		intXmora :=replace(in_array[i][5],',','');
		gac :=replace(in_array[i][6],',','');
		totalIn :=replace(in_array[i][7],',','');

                IF((tipo_negocio='PADRE' OR tipo_negocio='EDUCATIVO') AND _validarROP)THEN

                    _validarROP:=false;
                    RAISE NOTICE 'se ejecuta solo una vez ';
                    UnidadNeg := sp_uneg_negocio(negocioIn)::numeric;
                    periodoRop := replace(substring(now(),1,7),'-','');
                    vcto_rop := now()::date + '2 day'::interval;

                    /* *********************************************
		     ******** INFORMACION BASICA DEL CLIENTE ********/
                     SELECT INTO ClienteRec nit,nomcli,direccion,ciudad FROM cliente WHERE nit = (SELECT COD_CLI FROM negocios where cod_neg = negocioIn);


		    INSERT INTO recibo_oficial_pago (cod_rop, id_unidad_negocio, periodo_rop, vencimiento_rop, negocio,cedula,nombre_cliente,
						    direccion,ciudad,cuotas_vencidas,cuotas_pendientes, dias_vencidos, subtotal, total_sanciones,
						    total_descuentos, total,total_abonos, creation_date, creation_user, last_update, user_update, observacion)
		     VALUES('',UnidadNeg,periodoRop,vcto_rop,negocioIn,ClienteRec.nit,ClienteRec.nomcli,ClienteRec.direccion,ClienteRec.ciudad,'0','0/0','0',0,0,0,0,0,now(),usuario,now(),usuario,'')
		     RETURNING id INTO _cod_rop_real  ;

		     retorno:=_cod_rop_real;
                     raise notice '_cod_rop_real: %',_cod_rop_real;

                END IF;


               FOR j IN 1 .. (array_upper(in_array, 2)-1) LOOP

			_porcentaje:= in_array[i][8]::numeric;

                         IF(j > 2 AND j < 7)THEN
                                _valor_concepto:= replace(in_array[i][j],',','');
				IF(j=3)THEN--capital--CAP
				  raise notice 'CAP %',in_array[i][1];
                                  SELECT INTO id_concepto_rec * FROM  sp_concepto_unidad(sp_uneg_negocio(in_array[i][1])::numeric,'CAP') as coco(id_concepto integer, descrip varchar);
                                  SELECT INTO _aplicarDes aplica_incial FROM configuracion_descuentos_obligaciones obl where obl.concepto='CAP' and obl.tipo_negocio=in_array[i][2]::varchar and obl.periodo=replace(substring(now(),1,7),'-','');
					IF(_aplicarDes='S')THEN
					   _valor_concepto:=(ROUND(replace(in_array[i][j],',','')::NUMERIC * (_porcentaje/100 )))::varchar;
                                          ELSE
                                           _porcentaje:=100;
					  END IF;
				END IF;
				IF(j=4)THEN--interes--INT
				   raise notice 'INT %',in_array[i][1];
				   SELECT INTO id_concepto_rec * FROM  sp_concepto_unidad(sp_uneg_negocio(in_array[i][1])::numeric,'INT') as coco(id_concepto integer, descrip varchar);
				   SELECT INTO _aplicarDes aplica_incial FROM configuracion_descuentos_obligaciones obl where obl.concepto='INT' and obl.tipo_negocio=in_array[i][2]::varchar and obl.periodo=replace(substring(now(),1,7),'-','');
					IF(_aplicarDes='S')THEN
					   _valor_concepto:=(ROUND(replace(in_array[i][j],',','')::NUMERIC * (_porcentaje/100 )))::varchar;
					ELSE
					   _porcentaje:=100;
					END IF;
				END IF;
				IF(j=5)THEN--intXmora--IXM
				     raise notice 'IXM % ',in_array[i][1];
                                     SELECT INTO id_concepto_rec * FROM  sp_concepto_unidad(sp_uneg_negocio(in_array[i][1])::numeric,'IXM') as coco(id_concepto integer, descrip varchar);
					SELECT INTO _aplicarDes aplica_incial FROM configuracion_descuentos_obligaciones obl where obl.concepto='IXM' and obl.tipo_negocio=in_array[i][2]::varchar and obl.periodo=replace(substring(now(),1,7),'-','');
					IF(_aplicarDes='S')THEN
					   _valor_concepto:=(ROUND(replace(in_array[i][j],',','')::NUMERIC * (_porcentaje/100 )))::varchar;
					ELSE
                                            _porcentaje:=100;
					END IF;
				END IF;
				IF(j=6)THEN--gac-GAC
				   raise notice 'GAC % ',in_array[i][1];
                                   SELECT INTO id_concepto_rec * FROM  sp_concepto_unidad(sp_uneg_negocio(in_array[i][1])::numeric,'GAC') as coco(id_concepto integer, descrip varchar);
					SELECT INTO _aplicarDes aplica_incial FROM configuracion_descuentos_obligaciones obl where obl.concepto='GAC' and obl.tipo_negocio=in_array[i][2]::varchar and obl.periodo=replace(substring(now(),1,7),'-','');
					IF(_aplicarDes='S')THEN
					   _valor_concepto:=(ROUND(replace(in_array[i][j],',','')::NUMERIC * (_porcentaje/100 )))::varchar;
					ELSE
                                           _porcentaje:=100;
					END IF;
				END IF;

                                RAISE NOTICE '_valor_concepto : %',_valor_concepto;



		sqlExtractoDetalle:=sqlExtractoDetalle||'INSERT INTO detalle_rop (id_rop, id_conceptos_recaudo, descripcion, cuota, dias_vencidos, fecha_factura_padre,
								fecha_vencimiento_padre, fecha_ultimo_pago, items, valor_concepto, valor_descuento, valor_ixm,
								valor_descuento_ixm, valor_gac, valor_descuento_gac, valor_abono, valor_saldo, creation_date, creation_user, negocio,porcentaje_cta_inicial)
								VALUES (_current_codrop,'||id_concepto_rec.id_concepto||', '''||id_concepto_rec.descrip||''', ''0'', ''0'', ''0099-01-01'',
								''0099-01-01'','''',1,'|| _valor_concepto||', 0, 0, 0, 0, 0, 0, '|| _valor_concepto||', now(), '''||usuario||''','''||in_array[i][1]||''','||_porcentaje||');';


			END IF;
               END LOOP;
	END LOOP;

	   /* *********************************************************
	   ************REMPLAZAMOS EL ID_ROP POR EL DE LA CABEZERA******/
           sqlExtractoDetalle:=REPLACE(sqlExtractoDetalle,'_current_codrop',_cod_rop_real);
	  execute sqlExtractoDetalle;

           /* ***********************************************************
	   ************ACTUALIZAMOS LA CABECERA DEL RECIBO OFICIAL*******/
	   SELECT INTO sumaConceptos SUM(valor_concepto) FROM detalle_rop WHERE id_rop =_cod_rop_real;
           raise notice '_cod_rop :%',_cod_rop_real;
	   UPDATE  recibo_oficial_pago SET
                   cod_rop = OVERLAY('EPR0000000' PLACING _cod_rop_real FROM 11 - length(_cod_rop_real) FOR length(_cod_rop_real)),
		   subtotal=sumaConceptos,
                   total=sumaConceptos
           WHERE   id=_cod_rop_real;

RETURN retorno;

EXCEPTION

	WHEN foreign_key_violation THEN
		RAISE EXCEPTION 'La institución no puede ser borrada, existen dependencias para este registro.';
		retorno:='FAIL' ;
		return retorno;

	WHEN unique_violation THEN
		RAISE EXCEPTION 'Error Insertando en la bd, ya existe en la base de datos.';
		retorno:='FAIL' ;
		return retorno;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_generar_extracto_reestructuracion(text[], character varying)
  OWNER TO postgres;
