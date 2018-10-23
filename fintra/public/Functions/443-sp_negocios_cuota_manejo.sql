-- Function: sp_negocios_cuota_manejo(character varying, character varying)

-- DROP FUNCTION sp_negocios_cuota_manejo(character varying, character varying);

CREATE OR REPLACE FUNCTION sp_negocios_cuota_manejo(numero_ciclo character varying, periodo_fac character varying)
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
			select
				'CXC_CUOT_MANEJO'::varchar as prefijo_cxc_cuota_manejo,
				n.cod_cli::varchar,
				cu.nombre_largo::varchar as nomb_cuenta,
				d.fecha::timestamp,
				d.cuota_manejo::numeric,
				d.cuota_manejo_causada::numeric,
				d.item::varchar,
				c.cuenta_cuota_manejo::varchar,
				n.dist::varchar,
				f.documento::varchar,
				f.cmc::varchar,
				now()::date as fecha_doc,
				n.cod_neg::varchar,
				n.fecha_liquidacion as fecha_ant,
				d.saldo_inicial::numeric,
				n.tasa::numeric,
				d.fch_cuota_manejo_causada::timestamp,
				c.tipo::varchar,
				f.concepto::varchar
			FROM negocios n
			    inner join  documentos_neg_aceptado d on (n.cod_neg=d.cod_neg)
			    inner join convenios c on (n.id_convenio=c.id_convenio)
			    inner join con.cuentas cu on (cu.cuenta=c.cuenta_cuota_manejo)
			    inner join con.factura f on (f.negasoc=n.cod_neg and fecha_vencimiento=d.fecha and f.descripcion!= c.prefijo_cxc_interes and f.descripcion!=c.prefijo_cxc_cat and f.descripcion not in ('CXC_CUOT_MANEJO','CXC AVAL') and f.descripcion!='')
			WHERE   n.estado_neg='T' and c.tipo='Consumo'  and f.reg_status=''
				and n.id_convenio in (select id_convenio from unidad_negocio unid
						      inner join rel_unidadnegocio_convenios conv on (conv.id_unid_negocio=unid.id)
						      where ref_4 in ('FENALCO_ATL','FENALCO_BOL') and id_convenio !=19)
				and replace(substring(d.fecha,1,7),'-','') = periodo_fac --x
				and d.cuota_manejo_causada!=d.cuota_manejo
				and f.valor_saldo > 0
				and d.cuota_manejo >0
				and f.reg_status=''
				--and d.causar='S'
				and n.num_ciclo = numero_ciclo --x
				and d.causar_cuota_admin ='S'
				--AND negasoc in ('FA33263','FA33291','FA33386','FA33426','FA33413','FA33265','FA33313','FA33317','FA33434','FA33267','FA33299','FA33429','FA33518','FB04550')
				ORDER BY cod_neg
		)

	LOOP
		IF ( FacturasCapital.tipo = 'Consumo' ) THEN
			return next FacturasCapital;
		END IF;

	END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_negocios_cuota_manejo(character varying, character varying)
  OWNER TO postgres;
