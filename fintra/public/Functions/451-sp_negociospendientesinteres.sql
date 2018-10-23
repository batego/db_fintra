-- Function: sp_negociospendientesinteres(character varying)

-- DROP FUNCTION sp_negociospendientesinteres(character varying);

CREATE OR REPLACE FUNCTION sp_negociospendientesinteres(negocio character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE
	VarFACcc TEXT;
	VarFACcg TEXT;
	CountDocum CHARACTER VARYING;
	FacturasCapital record;
	FacturaGeneradora record;
	mNegocio record;
	Convenio record;

BEGIN

	FOR mNegocio IN
		select * from negocios where cod_neg = negocio LOOP
	END LOOP;


	FOR Convenio IN

		select id_convenio,nombre,tipo,redescuento,aval_anombre,intermediario_aval
		,prefijo_negocio
		,prefijo_cxp
		,prefijo_nc_gmf
		,prefijo_nc_aval
		,prefijo_diferidos
		,prefijo_endoso
		,prefijo_cxc_interes
		,'CXC_INTERES_FID'::varchar as prefijo_cxc_interes_fid
		,prefijo_cxp_central
		,prefijo_cxc_cat
		,prefijo_cxc_aval
		,prefijo_cxp_avalista
		,prefijo_end_fiducia
		,hc_end_fiducia
		,prefijo_dif_fiducia
		,hc_dif_fiducia
		,cuenta_dif_fiducia
		,cuenta_interes
		from convenios where id_convenio = mNegocio.id_convenio LOOP
	END LOOP;

	FOR FacturasCapital IN

		select *
		from con.factura f, documentos_neg_aceptado d
		where f.negasoc = d.cod_neg
		      and d.causar='S'
		      and d.interes_causado != d.interes
		      and f.fecha_vencimiento = d.fecha
		      and f.descripcion not in ('','CXC AVAL',Convenio.prefijo_cxc_interes_fid,Convenio.prefijo_cxc_interes, Convenio.prefijo_cxc_cat)
		      and f.reg_status=''
		      and f.negasoc = mNegocio.cod_neg
		order by f.fecha_vencimiento LOOP

		IF ( Convenio.tipo = 'Consumo' and Convenio.redescuento and Convenio.aval_anombre and Convenio.intermediario_aval ) THEN

			--IF ( FacturasCapital.descripcion != Convenio.prefijo_cxc_interes and FacturasCapital.descripcion != Convenio.prefijo_cxc_cat ) THEN

			IF ( substring(FacturasCapital.documento,1,2) = 'FC' OR substring(FacturasCapital.documento,1,2) = 'FG' ) THEN

				VarFACcc := 'CC'||substring(FacturasCapital.documento,3);
				VarFACcg := 'CG'||substring(FacturasCapital.documento,3);

				SELECT INTO CountDocum count(0)::integer from con.factura where documento in (VarFACcc,VarFACcg);

				IF ( CountDocum > 0 ) THEN

					--SE CREA UNA CI
					FOR FacturaGeneradora IN
						select
						     mNegocio.id_convenio::varchar
						     ,Convenio.prefijo_cxc_interes_fid::varchar
						     ,mNegocio.cod_cli::varchar
						     ,cu.nombre_largo::varchar
						     ,FacturasCapital.fecha::date
						     ,FacturasCapital.interes::numeric
						     ,FacturasCapital.interes_causado::numeric
						     ,FacturasCapital.item::varchar
						     ,Convenio.cuenta_interes::varchar
						     ,mNegocio.dist::varchar
						     ,f.documento::varchar
						     ,f.cmc::varchar
						     ,now()::date as fecha_doc
						     ,mNegocio.cod_neg::varchar
						     ,f.fecha_vencimiento::date
						     ,Convenio.tipo
						     ,FacturasCapital.saldo_inicial::numeric
						     ,mNegocio.tasa::numeric
						     ,FacturasCapital.fch_interes_causado::date
						     ,cl.nomcli::varchar as cliente
						from con.factura f
						     inner join cliente cl on ( cl.nit = mNegocio.cod_cli )
						     inner join con.cuentas cu on ( cu.cuenta = Convenio.cuenta_interes )
						where f.documento in (VarFACcc,VarFACcg) LOOP

					     RETURN NEXT FacturaGeneradora;
					END LOOP;

				ELSE
					--SE CREA UNA FI
					FOR FacturaGeneradora IN
						select
						     mNegocio.id_convenio::varchar
						     ,Convenio.prefijo_cxc_interes::varchar
						     ,mNegocio.cod_cli::varchar
						     ,cu.nombre_largo::varchar
						     ,FacturasCapital.fecha::date
						     ,FacturasCapital.interes::numeric
						     ,FacturasCapital.interes_causado::numeric
						     ,FacturasCapital.item::varchar
						     ,Convenio.cuenta_interes::varchar
						     ,mNegocio.dist::varchar
						     ,f.documento::varchar
						     ,f.cmc::varchar
						     ,now()::date as fecha_doc
						     ,mNegocio.cod_neg::varchar
						     ,f.fecha_vencimiento::date
						     ,Convenio.tipo
						     ,FacturasCapital.saldo_inicial::numeric
						     ,mNegocio.tasa::numeric
						     ,FacturasCapital.fch_interes_causado::date
						     ,cl.nomcli::varchar as cliente
						from con.factura f
						     inner join cliente cl on ( cl.nit = mNegocio.cod_cli )
						     inner join con.cuentas cu on ( cu.cuenta = Convenio.cuenta_interes )
						where f.documento = FacturasCapital.documento LOOP

					     RETURN NEXT FacturaGeneradora;
					END LOOP;

				END IF;

			END IF;
			--END IF;

		ELSIF ( Convenio.tipo = 'Microcredito' ) THEN

			--SE CREA UNA MI
			FOR FacturaGeneradora IN
				select
				     mNegocio.id_convenio::varchar
				     ,Convenio.prefijo_cxc_interes::varchar
				     ,mNegocio.cod_cli::varchar
				     ,cu.nombre_largo::varchar
				     ,FacturasCapital.fecha::date
				     ,FacturasCapital.interes::numeric
				     ,FacturasCapital.interes_causado::numeric
				     ,FacturasCapital.item::varchar
				     ,Convenio.cuenta_interes::varchar
				     ,mNegocio.dist::varchar
				     ,f.documento::varchar
				     ,f.cmc::varchar
				     ,now()::date as fecha_doc
				     ,mNegocio.cod_neg::varchar
				     ,f.fecha_vencimiento::date
				     ,Convenio.tipo
				     ,FacturasCapital.saldo_inicial::numeric
				     ,mNegocio.tasa::numeric
				     ,FacturasCapital.fch_interes_causado::date
				     ,cl.nomcli::varchar as cliente
				     ,f.concepto
				from con.factura f
				     inner join cliente cl on ( cl.nit = mNegocio.cod_cli )
				     inner join con.cuentas cu on ( cu.cuenta = Convenio.cuenta_interes )
				where f.documento = FacturasCapital.documento LOOP

			     RETURN NEXT FacturaGeneradora;
			END LOOP;

		END IF;

	END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_negociospendientesinteres(character varying)
  OWNER TO postgres;
