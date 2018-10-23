-- Function: administrativo.dv_generar_extracto_estadocuenta(character varying, date, character varying)

-- DROP FUNCTION administrativo.dv_generar_extracto_estadocuenta(character varying, date, character varying);

CREATE OR REPLACE FUNCTION administrativo.dv_generar_extracto_estadocuenta(negocio_ character varying, fecha_corte date, usuario character varying)
  RETURNS text AS
$BODY$
DECLARE

estado_cuenta record;
estado_cuenta_detalle record;
datos_cliente record;
id_concepto_rec record;
id_estado_cuenta_det integer [];
id_ecd integer;
_id_rop integer;
cod_rop_ integer:=0;
UnidadNeg integer:=0;
retorno varchar:='';
conceptos_ varchar[]= array['SEG','CAP','INT','IXM','GAC','CAT','AVA'];
periodoRop varchar:=0;
sql_detalle_rop  varchar:='';
concepto_ varchar;
desc_concepto_ varchar;
vcto_rop date;
total_sanciones_ numeric:=0;
valor_concepto numeric:=0;
sum_concepto numeric := 0;

BEGIN
	UnidadNeg := sp_uneg_negocio(negocio_)::numeric;
	periodoRop := replace(substring(now(),1,7),'-','');
	vcto_rop := fecha_corte::date;

	SELECT INTO datos_cliente nit,nomcli,direccion,ciudad FROM cliente WHERE nit = (SELECT cod_cli FROM negocios where cod_neg = negocio_);
	--RAISE NOTICE 'UnidadNeg % periodoRop % vcto_rop %',UnidadNeg,periodoRop,vcto_rop;

	--SE BUSCA LOS VALORES GENERALES DEL ESTADO DE CUENTA
	select into estado_cuenta_detalle *
		FROM mc_estado_cuenta_fenalcoTotales_2(negocio_, 'FINV',fecha_corte::date) as factura (
						valorCapital numeric
						,interes numeric
						,totalSeguro numeric
						,totalGastoCobranza numeric
						,totalIxM numeric
						,totalMipyme numeric
						,cuotasvencidas numeric
						,valorCuotaActual numeric
						,capitalFuturo numeric
						,interescuotafutura numeric
						,cuotaAdminfuturo numeric
						--,valorAval numeric
						,TotalPagar numeric
						,cuotaspendientes varchar
						,diasmora numeric
						,catfuturo numeric
	);
	raise notice 'estado_cuenta_detalle %',estado_cuenta_detalle;
	--raise notice 'estado_cuenta_detalle.TotalPagar %',estado_cuenta_detalle.TotalPagar;
	--total_sanciones_ := estado_cuenta_detalle.totalIxM + estado_cuenta_detalle.totalGastoCobranza;
	--RAISE NOTICE 'total_sanciones_ %',total_sanciones_;

	--INSERTA EN LA TABLA ROP OBTENIEDO EL ID
	INSERT INTO recibo_oficial_pago (
		cod_rop, id_unidad_negocio, periodo_rop, vencimiento_rop, negocio, cedula, nombre_cliente,
		direccion, ciudad, cuotas_vencidas, cuotas_pendientes, dias_vencidos,
		subtotal, total_sanciones, total_descuentos, total,total_abonos, creation_date, creation_user, last_update, user_update, observacion)
	VALUES('', UnidadNeg, periodoRop, vcto_rop, negocio_, datos_cliente.nit, datos_cliente.nomcli,
		datos_cliente.direccion, datos_cliente.ciudad, 0, estado_cuenta_detalle.cuotaspendientes, estado_cuenta_detalle.diasmora,
		estado_cuenta_detalle.TotalPagar, estado_cuenta_detalle.TotalPagar , 0, estado_cuenta_detalle.TotalPagar, 0 ,now(), usuario, now(), usuario, '')
	RETURNING id INTO _id_rop;
	RAISE NOTICE '_id_rop %',_id_rop;


	--RECORREMOS EL ARRAY DE CONCEPTOS SEGUNEL VALOR SE HALLA EL VALOR DEL CONCEPTO Y SE CONTRUYE EL SQL: INSERT DETALLE_ROP
	for i in 1..
		array_upper(conceptos_, 1)
	loop
		SELECT INTO id_concepto_rec * FROM  sp_concepto_unidad(sp_uneg_negocio(negocio_)::numeric, conceptos_[i]) as coco(id_concepto integer, descrip varchar);
		--raise notice 'id_concepto_rec%',id_concepto_rec;
		if (id_concepto_rec.descrip !='')then
			raise notice 'id_concepto_rec % coi%',id_concepto_rec,conceptos_[i];
			if (conceptos_[i] ='INT')then
				valor_concepto:= round(estado_cuenta_detalle.interes);
				--RAISE NOTICE 'valor_concepto int %',valor_concepto;
			end if;
			if (conceptos_[i] ='CAP')then
				valor_concepto:= round(estado_cuenta_detalle.valorCapital);
				--RAISE NOTICE 'valor_concepto cap %',valor_concepto;
			end if;
			if (conceptos_[i] ='SEG')then
				valor_concepto:= round(estado_cuenta_detalle.totalSeguro);
				--RAISE NOTICE 'valor_concepto SEGURO %',valor_concepto;
			end if;
			if (conceptos_[i] ='GAC')then
				valor_concepto:= round(estado_cuenta_detalle.totalGastoCobranza);
				--RAISE NOTICE 'valor_concepto gac %',valor_concepto;
			end if;
			if (conceptos_[i] ='IXM')then
				valor_concepto:= round(estado_cuenta_detalle.totalIxM);
				--RAISE NOTICE 'valor_concepto ixm %',valor_concepto;
			end if;
			if (conceptos_[i] ='CAT')then
				valor_concepto:= round(estado_cuenta_detalle.totalMipyme);
				--RAISE NOTICE 'valor_concepto ixm %',valor_concepto;
			end if;

			--if (conceptos_[i] ='AVA')then --Se agrego porque no sumaba aval
				--valor_concepto:= round(estado_cuenta_detalle.valorAval);
				--RAISE NOTICE 'valor_concepto aval %',valor_concepto;
			--end if;

			sum_concepto:= sum_concepto + valor_concepto;
			--RAISE NOTICE 'sum_concepto final %',sum_concepto;
			if (conceptos_[i] ='CAT' and estado_cuenta_detalle.totalMipyme > 0)then
				sql_detalle_rop := sql_detalle_rop||'INSERT INTO detalle_rop (
				id_rop, id_conceptos_recaudo, descripcion, cuota, dias_vencidos, fecha_factura_padre,
				fecha_vencimiento_padre, fecha_ultimo_pago, items, valor_concepto, valor_descuento, valor_ixm,
				valor_descuento_ixm, valor_gac, valor_descuento_gac, valor_abono, valor_saldo, creation_date, creation_user, negocio)
				VALUES ('||_id_rop||', '''||id_concepto_rec.id_concepto||''', '''||id_concepto_rec.descrip||''', 0,'''||estado_cuenta_detalle.diasmora||''', ''0099-01-01'',
				''0099-01-01'','''',1,'||valor_concepto||', 0, 0, 0, 0, 0, 0,'||valor_concepto||', now(),'''|| usuario||''', '''||negocio_||''');';
			elsif (conceptos_[i] !='CAT')then
				sql_detalle_rop := sql_detalle_rop||'INSERT INTO detalle_rop (
				id_rop, id_conceptos_recaudo, descripcion, cuota, dias_vencidos, fecha_factura_padre,
				fecha_vencimiento_padre, fecha_ultimo_pago, items, valor_concepto, valor_descuento, valor_ixm,
				valor_descuento_ixm, valor_gac, valor_descuento_gac, valor_abono, valor_saldo, creation_date, creation_user, negocio)
				VALUES ('||_id_rop||', '''||id_concepto_rec.id_concepto||''', '''||id_concepto_rec.descrip||''', 0,'''||estado_cuenta_detalle.diasmora||''', ''0099-01-01'',
				''0099-01-01'','''',1,'||valor_concepto||', 0, 0, 0, 0, 0, 0,'||valor_concepto||', now(),'''|| usuario||''', '''||negocio_||''');';
			end if;
		end if;
		RAISE NOTICE 'sum_concepto %',sum_concepto;
	end loop;

	execute sql_detalle_rop;

	--SE ACTUALIZA EL CODIFO ROP
	UPDATE  recibo_oficial_pago SET
		cod_rop = OVERLAY('EEC0000000' PLACING _id_rop FROM 11 - length(_id_rop) FOR length(_id_rop)),subtotal = ROUND(sum_concepto),total_sanciones = ROUND(sum_concepto),
		total = ROUND(sum_concepto)
	WHERE   id =_id_rop;


	for estado_cuenta in
		SELECT * FROM mc_estado_cuenta_fenalco_2(negocio_,'FINV',fecha_corte::date) as factura (
					   factura varchar
                                           ,fecha DATE
                                           ,convenio varchar
                                           ,item VARCHAR
                                           ,dias_mora INTEGER
                                           ,saldo_inicial numeric
                                           ,valor_cuota numeric
                                           ,valor_saldo_cuota numeric
                                           ,capital numeric
                                           ,interes numeric
                                           ,seguro numeric
                                           ,mipyme numeric
                                           ,cuota_manejo numeric
                                           ,interes_mora numeric
                                           ,gac numeric
                                           ,valor_saldo_global_cuota numeric
                                           ,estado varchar
            )order by factura.item::numeric
	loop
		--RAISE NOTICE 'estado_cuenta%',estado_cuenta;
		INSERT INTO administrativo.estado_cuenta_detalle(
		             cod_estado_cuenta, factura, fecha, convenio,
		             item, dias_mora, saldo_inicial, valor_cuota, valor_saldo_cuota,
		             capital, interes, seguro, mipyme, cuota_manejo, interes_mora,
		             gac, valor_saldo_global_cuota, estado, creation_date, creation_user
		       )
		       values (
			_id_rop,estado_cuenta.factura, estado_cuenta.fecha, estado_cuenta.convenio,
			estado_cuenta.item, estado_cuenta.dias_mora, estado_cuenta.saldo_inicial,estado_cuenta.valor_cuota, estado_cuenta.valor_saldo_cuota,
			estado_cuenta.capital, estado_cuenta.interes, estado_cuenta.seguro, estado_cuenta.mipyme, estado_cuenta.cuota_manejo, estado_cuenta.interes_mora,
		        estado_cuenta.gac, estado_cuenta.valor_saldo_global_cuota,estado_cuenta. estado, now(), usuario
		       );
		--RETURNING id INTO id_ecd;
		--id_estado_ceanta_det = array_prepend( id_ecd, id_estado_cuanta_det);

	end loop;
	--RAISE NOTICE 'id_estado_cuanta_det: %',id_estado_cuenta_det;

	INSERT INTO administrativo.estado_cuenta(
		cod_estado_cuenta, cliente, negocio, valorcapital, interes, totalseguro,
		totalgastocobranza, totalixm, totalmipyme, cuotasvencidas,
		valorcuotaactual, capitalfuturo, interescuotafutura,
		cuotaadminfuturo, cuotaspendientes, diasmora,
		catfuturo, creation_date, creation_user)
	VALUES (
		_id_rop, datos_cliente.nit, negocio_, estado_cuenta_detalle.valorCapital, estado_cuenta_detalle.interes, estado_cuenta_detalle.totalSeguro,
		estado_cuenta_detalle.totalGastoCobranza, estado_cuenta_detalle.totalIxM,estado_cuenta_detalle.totalMipyme, estado_cuenta_detalle.cuotasvencidas,
		estado_cuenta_detalle.valorCuotaActual, estado_cuenta_detalle.capitalFuturo, estado_cuenta_detalle.interescuotafutura,
		estado_cuenta_detalle.cuotaadminfuturo, estado_cuenta_detalle.cuotaspendientes, estado_cuenta_detalle.diasmora,
		estado_cuenta_detalle.catfuturo, now(), usuario);


retorno = _id_rop;

RETURN retorno;

-- EXCEPTION
--
-- 	WHEN foreign_key_violation THEN
-- 		RAISE EXCEPTION 'La institución no puede ser borrada, existen dependencias para este registro.';
-- 		retorno:='FAIL' ;
-- 		return retorno;
--
-- 	WHEN unique_violation THEN
-- 		RAISE EXCEPTION 'Error Insertando en la bd, ya existe en la base de datos.';
-- 		retorno:='FAIL' ;
-- 		return retorno;
--
END
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION administrativo.dv_generar_extracto_estadocuenta(character varying, date, character varying)
  OWNER TO postgres;
