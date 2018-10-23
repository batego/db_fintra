-- Function: mc_cuotas_manejo(character varying)

-- DROP FUNCTION mc_cuotas_manejo(character varying);

CREATE OR REPLACE FUNCTION mc_cuotas_manejo(negocio character varying)
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
		select * from negocios where cod_neg = negocio 
	LOOP
		raise notice 'mNegocio%',mNegocio;
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
		,cuenta_cuota_manejo
		from convenios where id_convenio = mNegocio.id_convenio 
	LOOP 
		raise notice 'Convenio%',Convenio;
	END LOOP;

	FOR FacturasCapital IN 

		select *
		from con.factura f, documentos_neg_aceptado d
		where f.negasoc = d.cod_neg
		      --and d.causar='S'
		      and d.causar_cuota_admin ='S'
		      and d.cuota_manejo_causada != d.cuota_manejo
		      and f.fecha_vencimiento = d.fecha 
		      and f.descripcion not in ('','CXC AVAL',Convenio.prefijo_cxc_interes_fid,Convenio.prefijo_cxc_interes, Convenio.prefijo_cxc_cat,'CXC_CUOT_MANEJO')
		      and f.reg_status='' 
		      and f.negasoc = mNegocio.cod_neg
		order by f.fecha_vencimiento LOOP

		IF ( Convenio.tipo = 'Consumo' ) THEN
	
			FOR FacturaGeneradora IN 
				select 
				     mNegocio.id_convenio::varchar
				     ,'CXC_CUOT_MANEJO'::varchar as prefijo_cxc_cuota_manejo
				     ,mNegocio.cod_cli::varchar
				     ,cu.nombre_largo::varchar 
				     ,FacturasCapital.fecha::date
				     ,FacturasCapital.cuota_manejo::numeric
				     ,FacturasCapital.cuota_manejo_causada::numeric
				     ,FacturasCapital.item::varchar
				     ,Convenio.cuenta_cuota_manejo::varchar 
				     ,mNegocio.dist::varchar
				     ,f.documento::varchar
				     ,f.cmc::varchar 
				     ,now()::date as fecha_doc 
				     ,mNegocio.cod_neg::varchar 
				     ,f.fecha_vencimiento::date 
				     ,Convenio.tipo
				     ,FacturasCapital.saldo_inicial::numeric 
				     ,mNegocio.tasa::numeric 
				     ,FacturasCapital.fch_cuota_manejo_causada::date
				     ,cl.nomcli::varchar as cliente
				     ,f.concepto
				from con.factura f
				     inner join cliente cl on ( cl.nit = mNegocio.cod_cli )
				     inner join con.cuentas cu on ( cu.cuenta = Convenio.cuenta_cuota_manejo )
				where f.documento = FacturasCapital.documento LOOP
				
			     RETURN NEXT FacturaGeneradora;
			END LOOP;		

		END IF;
	
	END LOOP;
		
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION mc_cuotas_manejo(character varying)
  OWNER TO postgres;

