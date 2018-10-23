-- Function: sp_totalabonos(character varying)

-- DROP FUNCTION sp_totalabonos(character varying);

CREATE OR REPLACE FUNCTION sp_totalabonos(negocioref character varying)
  RETURNS numeric AS
$BODY$

DECLARE

	CarteraGeneral record;
	FacturaActual record;
	BankPay record;
	ValorAbono numeric;


BEGIN

	ValorAbono = 0;

	FOR CarteraGeneral IN

		select negasoc::varchar as negocio,
		       nit::varchar as cedula,
		       ''::varchar as nombre_cliente,
		       num_doc_fen::varchar as cuota,
		       documento::varchar, --''::varchar as documento,  --documento::varchar,
		       fecha_vencimiento::date,
		       (now()::date-fecha_vencimiento)::numeric AS dias_vencidos,
		       valor_factura::numeric,
		       0::numeric as valor_ingreso
		from con.factura f
		where negasoc = NegocioRef
		and reg_status = ''
		--and descripcion != 'CXC AVAL'
		and substring(documento,1,2) not in ('CP','FF','DF')
		and replace(substring(f.fecha_vencimiento,1,7),'-','')::numeric <= replace(substring(now(),1,7),'-','')::numeric
		order by num_doc_fen::numeric,creation_date

	LOOP
		--if ( and devuelta != 'S' and corficolombiana != 'S' )
		--RECAUDO Y ENTIDAD DEL PAGO
		FOR BankPay IN

			select i.num_ingreso, i.descripcion_ingreso, i.branch_code, i.bank_account_no, i.fecha_ingreso, i.fecha_consignacion, sum(id.valor_ingreso) as mingreso
			from con.ingreso_detalle id, con.ingreso i
			where id.num_ingreso = i.num_ingreso
			and id.dstrct = i.dstrct
			and id.tipo_documento = i.tipo_documento
			and id.dstrct = 'FINV'
			and id.tipo_documento in ('ING','ICA')
			and i.reg_status = ''
			and id.reg_status = ''
			and id.documento = (SELECT documento from con.factura where documento = CarteraGeneral.documento and tipo_documento in ('FAC','NDC') and reg_status = '' and endoso_fenalco !='S' and devuelta != 'S' and corficolombiana != 'S') --CarteraGeneral.documento
			--and replace(substring(i.fecha_consignacion,1,7),'-','') <= PeriodoAsignacion
			group by i.num_ingreso, i.descripcion_ingreso, i.branch_code, i.bank_account_no, i.fecha_ingreso, i.fecha_consignacion

		LOOP
			if found then

				ValorAbono:= ValorAbono + BankPay.mingreso;

			end if;

		END LOOP;


	END LOOP;
	RETURN  ValorAbono;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_totalabonos(character varying)
  OWNER TO postgres;
