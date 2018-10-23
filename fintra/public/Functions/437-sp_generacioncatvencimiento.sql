-- Function: sp_generacioncatvencimiento(character varying, character varying)

-- DROP FUNCTION sp_generacioncatvencimiento(character varying, character varying);

CREATE OR REPLACE FUNCTION sp_generacioncatvencimiento(numero_ciclo character varying, periodo_fac character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE

	FacturaCat record;
	miHoy date;

BEGIN

	miHoy = now()::date; --'2015-01-01'; | now()::date;

	FOR FacturaCat IN

		select
		     c.prefijo_cxc_cat::varchar
		     ,n.cod_cli::varchar
		     ,cu.nombre_largo::varchar as nomb_cuenta
		     ,d.fecha::timestamp
		     ,d.cat::numeric
		     ,c.impuesto::varchar
		     ,d.item::varchar
		     ,c.cuenta_cat::varchar
		     ,n.dist::varchar
		     ,f.documento::varchar
		     ,f.cmc::varchar
		     ,miHoy::date as fecha_doc
		     ,n.cod_neg::varchar
		from negocios n
		inner join  documentos_neg_aceptado d on (n.cod_neg=d.cod_neg)
		inner join convenios c on (n.id_convenio=c.id_convenio)
		inner join con.cuentas cu on (cu.cuenta=c.cuenta_cat)
		inner join con.factura f on (f.negasoc=n.cod_neg and fecha_vencimiento=d.fecha and f.descripcion!= c.prefijo_cxc_interes and f.descripcion!=c.prefijo_cxc_cat and f.descripcion!='')
		where n.estado_neg='T'
		      and c.tipo='Microcredito'
		      and c.cat=true
		      and f.reg_status=''
		and replace(substring(d.fecha,1,7),'-','')  = periodo_fac
		and d.documento_cat = ''
		and f.valor_saldo > 0
		and n.creation_date::date < '2017-06-05'::date
		--and d.causar='S'
		and n.num_ciclo = numero_ciclo

	LOOP

	        RETURN NEXT FacturaCat;

	END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_generacioncatvencimiento(character varying, character varying)
  OWNER TO postgres;
