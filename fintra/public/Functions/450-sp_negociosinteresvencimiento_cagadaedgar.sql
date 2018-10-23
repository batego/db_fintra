-- Function: sp_negociosinteresvencimiento_cagadaedgar()

-- DROP FUNCTION sp_negociosinteresvencimiento_cagadaedgar();

CREATE OR REPLACE FUNCTION sp_negociosinteresvencimiento_cagadaedgar()
  RETURNS SETOF record AS
$BODY$

DECLARE
	VarFACcc TEXT;
	VarFACcg TEXT;
	CountDocum CHARACTER VARYING;
	FacturasCapital record;
	FacturaGeneradora record;

	miHoy date;

BEGIN

	miHoy = now()::date; --'2015-01-01' | now()::date;

	FOR FacturasCapital IN

		(
		--Microcredito
		select c.prefijo_cxc_interes, 'NO_APLICA'::varchar as prefijo_cxc_interes_fid, n.cod_cli, cu.nombre_largo as nomb_cuenta, d.fecha, d.interes, d.interes_causado, d.item,
		c.cuenta_interes, n.dist, f.documento, f.cmc, miHoy::date as fecha_doc, n.cod_neg, n.fecha_liquidacion as fecha_ant, d.saldo_inicial, n.tasa, d.fch_interes_causado, c.tipo
		from negocios n
			inner join  documentos_neg_aceptado d on (n.cod_neg=d.cod_neg)
			inner join convenios c on (n.id_convenio=c.id_convenio)
			inner join con.cuentas cu on (cu.cuenta=c.cuenta_interes)
			inner join con.factura f on (f.negasoc=n.cod_neg and fecha_vencimiento=d.fecha and f.descripcion!= c.prefijo_cxc_interes and f.descripcion!=c.prefijo_cxc_cat and f.descripcion!='')
		where  n.estado_neg='T' and c.tipo='Microcredito'  and f.reg_status=''
			/*
			and case when c.cat=true then n.cod_neg not in (
									select distinct n.cod_neg from con.factura f
									inner join negocios n on (n.cod_neg=f.negasoc)
									inner join convenios c on (n.id_convenio=c.id_convenio)
									where c.tipo='Microcredito'
									and (now()::date-f.fecha_vencimiento)>30 and f.valor_saldo >0  and f.reg_status=''
								       )
			    else  c.cat=false end*/
			and d.fecha between '2016-02-01'::date and '2016-02-29'::date --between '2015-01-01'::date and '2015-01-31'::date |||  = miHoy::date
			and d.interes_causado!=d.interes
			and f.valor_saldo > 0
			and f.reg_status=''
			and d.causar='S'
		)
		union all
		(
		--Consumo
		select c.prefijo_cxc_interes, 'CXC_INTERES_FID'::varchar as prefijo_cxc_interes_fid, n.cod_cli,cu.nombre_largo as nomb_cuenta, d.fecha, d.interes, d.interes_causado, d.item,
		c.cuenta_interes, n.dist, f.documento, f.cmc, miHoy::date as fecha_doc, n.cod_neg, n.fecha_liquidacion as fecha_ant, d.saldo_inicial, n.tasa, d.fch_interes_causado
		,c.tipo
		from negocios n
		inner join  documentos_neg_aceptado d on (n.cod_neg=d.cod_neg)
		inner join convenios c on (n.id_convenio=c.id_convenio)
		inner join con.cuentas cu on (cu.cuenta=c.cuenta_interes)
		inner join con.factura f on (f.negasoc=n.cod_neg and fecha_vencimiento=d.fecha and f.descripcion!= c.prefijo_cxc_interes and f.descripcion!=c.prefijo_cxc_cat and f.descripcion != 'CXC AVAL')
		where  n.estado_neg='T' and c.tipo='Consumo' and c.redescuento and c.aval_anombre and c.intermediario_aval
		and d.fecha=miHoy::date and d.interes_causado!=d.interes and f.reg_status='' and d.causar='S'
		) LOOP

		IF ( FacturasCapital.tipo = 'Consumo' ) THEN
			/*
			IF ( substring(FacturasCapital.documento,1,2) = 'FC' OR substring(FacturasCapital.documento,1,2) = 'FG' ) THEN

				VarFACcc := 'CC'||substring(FacturasCapital.documento,3);
				VarFACcg := 'CG'||substring(FacturasCapital.documento,3);

				SELECT INTO CountDocum count(0)::integer from con.factura where documento in (VarFACcc,VarFACcg);

				IF ( CountDocum > 0 ) THEN

					--SE CREA UNA CI
					FOR FacturaGeneradora IN
						select
						     FacturasCapital.prefijo_cxc_interes_fid::varchar
 						     ,FacturasCapital.cod_cli::varchar
						     ,FacturasCapital.nomb_cuenta::varchar
						     ,FacturasCapital.fecha::timestamp
						     ,FacturasCapital.interes::numeric
						     ,FacturasCapital.interes_causado::numeric
						     ,FacturasCapital.item::varchar
						     ,FacturasCapital.cuenta_interes::varchar
						     ,FacturasCapital.dist::varchar
						     ,f.documento::varchar
						     ,f.cmc::varchar
						     ,now()::date as fecha_doc
						     ,FacturasCapital.cod_neg::varchar
						     ,FacturasCapital.fecha_ant::timestamp
						     ,FacturasCapital.saldo_inicial::numeric
						     ,FacturasCapital.tasa::numeric
						     ,FacturasCapital.fch_interes_causado::timestamp
						from con.factura f where f.documento = FacturasCapital.documento LOOP

					     RETURN NEXT FacturaGeneradora;
					END LOOP;

				ELSE
					--SE CREA UNA FI
					FOR FacturaGeneradora IN
						select
						     FacturasCapital.prefijo_cxc_interes::varchar
                                                     ,FacturasCapital.cod_cli::varchar
						     ,FacturasCapital.nomb_cuenta::varchar
						     ,FacturasCapital.fecha::timestamp
						     ,FacturasCapital.interes::numeric
						     ,FacturasCapital.interes_causado::numeric
						     ,FacturasCapital.item::varchar
						     ,FacturasCapital.cuenta_interes::varchar
						     ,FacturasCapital.dist::varchar
						     ,f.documento::varchar
						     ,f.cmc::varchar
						     ,now()::date as fecha_doc
						     ,FacturasCapital.cod_neg::varchar
						     ,FacturasCapital.fecha_ant::timestamp
						     ,FacturasCapital.saldo_inicial::numeric
						     ,FacturasCapital.tasa::numeric
						     ,FacturasCapital.fch_interes_causado::timestamp
						from con.factura f where f.documento = FacturasCapital.documento LOOP
					     RETURN NEXT FacturaGeneradora;
					END LOOP;

				END IF;

			END IF;
			*/
		ELSIF ( FacturasCapital.tipo = 'Microcredito' ) THEN

			--SE CREA UNA MI
			FOR FacturaGeneradora IN
				select
				     FacturasCapital.prefijo_cxc_interes::varchar
				     ,FacturasCapital.cod_cli::varchar
				     ,FacturasCapital.nomb_cuenta::varchar
				     ,FacturasCapital.fecha::timestamp
				     ,FacturasCapital.interes::numeric
				     ,FacturasCapital.interes_causado::numeric
				     ,FacturasCapital.item::varchar
				     ,FacturasCapital.cuenta_interes::varchar
				     ,FacturasCapital.dist::varchar
				     ,f.documento::varchar
				     ,f.cmc::varchar
				     ,miHoy::date as fecha_doc
				     ,FacturasCapital.cod_neg::varchar
				     ,FacturasCapital.fecha_ant::timestamp
				     ,FacturasCapital.saldo_inicial::numeric
				     ,FacturasCapital.tasa::numeric
				     ,FacturasCapital.fch_interes_causado::timestamp
				from con.factura f where f.documento = FacturasCapital.documento LOOP
			     RETURN NEXT FacturaGeneradora;
			END LOOP;

		END IF;

	END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_negociosinteresvencimiento_cagadaedgar()
  OWNER TO postgres;
