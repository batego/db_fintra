-- Function: sp_negociosinteresvencimiento(character varying, character varying)

-- DROP FUNCTION sp_negociosinteresvencimiento(character varying, character varying);

CREATE OR REPLACE FUNCTION sp_negociosinteresvencimiento(numero_ciclo character varying, periodo_fac character varying)
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
		select
			c.prefijo_cxc_interes,
			'NO_APLICA'::varchar as prefijo_cxc_interes_fid,
			n.cod_cli,
			cu.nombre_largo as nomb_cuenta,
			d.fecha,
			d.interes,
			d.interes_causado,
			d.item,
			c.cuenta_interes,
			n.dist,
			f.documento,
			f.cmc,
			miHoy::date as fecha_doc,
			n.cod_neg,
			n.fecha_liquidacion as fecha_ant,
			d.saldo_inicial,
			n.tasa,
			d.fch_interes_causado,
			c.tipo,
			''::varchar as concepto
		from negocios n
			inner join  documentos_neg_aceptado d on (n.cod_neg=d.cod_neg)
			inner join convenios c on (n.id_convenio=c.id_convenio)
			inner join con.cuentas cu on (cu.cuenta=c.cuenta_interes)
			inner join con.factura f on (f.negasoc=n.cod_neg and fecha_vencimiento=d.fecha and f.descripcion!= c.prefijo_cxc_interes and f.descripcion!=c.prefijo_cxc_cat and f.descripcion!='')
		where  n.estado_neg='T' and c.tipo='Microcredito'  and f.reg_status=''
			and replace(substring(d.fecha,1,7),'-','') =periodo_fac
			and d.interes_causado!=d.interes
			and f.valor_saldo > 0
			and f.reg_status=''
			and d.causar='S'
			and n.num_ciclo = numero_ciclo
		)



	LOOP

		IF ( FacturasCapital.tipo = 'Consumo' ) THEN

			raise notice 'CONSUMO';

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
				     ,FacturasCapital.fch_interes_causado::timestamp,
				     FacturasCapital.concepto
				from con.factura f
				where f.documento = FacturasCapital.documento
			LOOP

			     RETURN NEXT FacturaGeneradora;

			END LOOP;

		END IF;

	END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_negociosinteresvencimiento(character varying, character varying)
  OWNER TO postgres;
