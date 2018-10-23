-- Function: sp_detallecartera(numeric, character varying, character varying)

-- DROP FUNCTION sp_detallecartera(numeric, character varying, character varying);

CREATE OR REPLACE FUNCTION sp_detallecartera(periodoasignacion numeric, unidadnegocio character varying, negocioref character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE

	CarteraGeneral record;
	ClienteRec record;
	FacturaActual record;
	NegocioAvales record;

	FechaCortePeriodo varchar;
	VencimientoMayor varchar;

	PeriodoTramo numeric;

BEGIN

	if ( substring(periodoasignacion,5) = '01' ) then
		PeriodoTramo = substring(periodoasignacion,1,4)::numeric-1||'12';
	else
		PeriodoTramo = periodoasignacion::numeric - 1;
	end if;

	--PeriodoTramo = PeriodoAsignacion::numeric - 1;

	select into FechaCortePeriodo to_char(to_timestamp(substring(PeriodoTramo,1,4)::numeric || '-' || to_char(substring(PeriodoTramo,5,2)::numeric,'FM00') || '-01', 'YYYY-MM-DD') + INTERVAL '1 month' - INTERVAL '1 days', 'YYYY-MM-DD');

	FOR CarteraGeneral IN

		select negasoc::varchar as negocio,
		       nit::varchar as cedula,
		       ''::varchar as nombre_cliente,
		       num_doc_fen::varchar as cuota,
		       documento::varchar,
		       fecha_vencimiento::date,
		       (FechaCortePeriodo::date-fecha_vencimiento)::numeric AS dias_vencidos,
		       ''::varchar as vencimiento_mayor,
		       '-'::varchar as status,
		       valor_saldo::numeric,
		       0::numeric as debido_cobrar
		from con.foto_cartera f
		where negasoc = NegocioRef
		and periodo_lote = PeriodoAsignacion
		and reg_status = ''
		--and descripcion != 'CXC AVAL'
		and substring(documento,1,2) not in ('CP','FF','DF')
		and valor_saldo > 0
		and replace(substring(f.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoAsignacion
		order by num_doc_fen::numeric,creation_date

	LOOP

		SELECT INTO ClienteRec nomcli FROM cliente WHERE nit = CarteraGeneral.cedula;
		CarteraGeneral.nombre_cliente = ClienteRec.nomcli;

		SELECT INTO FacturaActual valor_saldo FROM con.factura WHERE documento = CarteraGeneral.documento;
		CarteraGeneral.debido_cobrar = FacturaActual.valor_saldo;

		SELECT INTO VencimientoMayor
			CASE WHEN maxdia >= 365 THEN '8- MAYOR A 1 AÑO'
			     WHEN maxdia >= 181 THEN '7- ENTRE 180 Y 360'
			     WHEN maxdia >= 121 THEN '6- ENTRE 121 Y 180'
			     WHEN maxdia >= 91 THEN '5- ENTRE 91 Y 120'
			     WHEN maxdia >= 61 THEN '4- ENTRE 61 Y 90'
			     WHEN maxdia >= 31 THEN '3- ENTRE 31 Y 60'
			     WHEN maxdia >= 1 THEN '2- 1 A 30'
			     WHEN maxdia <= 0 THEN '1- CORRIENTE'
				ELSE '0' END AS rango
		FROM (
			 SELECT max(FechaCortePeriodo::date-(fecha_vencimiento)) as maxdia
			 --SELECT FechaCortePeriodo::date-fecha_vencimiento as maxdia
			 FROM con.foto_cartera fra
			 WHERE fra.dstrct = 'FINV'
				  AND fra.valor_saldo > 0
				  AND fra.reg_status = ''
				  AND fra.negasoc = NegocioRef
				  --AND fra.documento = CarteraGeneral.documento
				  AND fra.tipo_documento = 'FAC'
				  AND fra.periodo_lote = PeriodoAsignacion
			 GROUP BY negasoc

		) tabla2;

		CarteraGeneral.vencimiento_mayor = VencimientoMayor;

		RETURN NEXT CarteraGeneral;

	END LOOP;

	--NEGOCIO DE AVAL
	---------------------------------------------------------------------------------------------------
	SELECT INTO NegocioAvales cod_neg from negocios where negocio_rel = NegocioRef;

	IF FOUND THEN

		FOR CarteraGeneral IN

			select negasoc::varchar as negocio,
			       nit::varchar as cedula,
			       ''::varchar as nombre_cliente,
			       num_doc_fen::varchar as cuota,
			       documento::varchar,
			       fecha_vencimiento::date,
			       (FechaCortePeriodo::date-fecha_vencimiento)::numeric AS dias_vencidos,
			       ''::varchar as vencimiento_mayor,
			       '-'::varchar as status,
			       valor_saldo::numeric,
			       0::numeric as debido_cobrar
			from con.foto_cartera f
			where negasoc = NegocioAvales.cod_neg
			and periodo_lote = PeriodoAsignacion
			and reg_status = ''
			--and descripcion != 'CXC AVAL'
			and substring(documento,1,2) not in ('CP','FF','DF')
			and valor_saldo > 0
			and replace(substring(f.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoAsignacion
			order by num_doc_fen::numeric,creation_date

		LOOP

			SELECT INTO ClienteRec nomcli FROM cliente WHERE nit = CarteraGeneral.cedula;
			CarteraGeneral.nombre_cliente = ClienteRec.nomcli;

			SELECT INTO FacturaActual valor_saldo FROM con.factura WHERE documento = CarteraGeneral.documento;
			CarteraGeneral.debido_cobrar = FacturaActual.valor_saldo;

			CarteraGeneral.vencimiento_mayor = VencimientoMayor;

			RETURN NEXT CarteraGeneral;

		END LOOP;

	END IF;

	--NEGOCIO DE SEGURO
	---------------------------------------------------------------------------------------------------
	SELECT INTO NegocioAvales negocio_seguro as cod_neg from tem.seguros_vehiculos where ciclo_fecha = '2014-05-14' and negocio_vehiculo = NegocioRef;
	IF FOUND THEN

		FOR CarteraGeneral IN

			select negasoc::varchar as negocio,
			       nit::varchar as cedula,
			       ''::varchar as nombre_cliente,
			       num_doc_fen::varchar as cuota,
			       documento::varchar,
			       fecha_vencimiento::date,
			       (FechaCortePeriodo::date-fecha_vencimiento)::numeric AS dias_vencidos,
			       ''::varchar as vencimiento_mayor,
			       '-'::varchar as status,
			       valor_saldo::numeric,
			       0::numeric as debido_cobrar
			from con.foto_cartera f
			where negasoc = NegocioAvales.cod_neg
			and periodo_lote = PeriodoAsignacion
			and reg_status = ''
			--and descripcion != 'CXC AVAL'
			and substring(documento,1,2) not in ('CP','FF','DF')
			and valor_saldo > 0
			and replace(substring(f.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoAsignacion
			order by num_doc_fen::numeric,creation_date

		LOOP

			SELECT INTO ClienteRec nomcli FROM cliente WHERE nit = CarteraGeneral.cedula;
			CarteraGeneral.nombre_cliente = ClienteRec.nomcli;

			SELECT INTO FacturaActual valor_saldo FROM con.factura WHERE documento = CarteraGeneral.documento;
			CarteraGeneral.debido_cobrar = FacturaActual.valor_saldo;

			CarteraGeneral.vencimiento_mayor = VencimientoMayor;

			RETURN NEXT CarteraGeneral;

		END LOOP;

	END IF;


END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_detallecartera(numeric, character varying, character varying)
  OWNER TO postgres;
