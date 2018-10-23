-- Function: tem.dv_accion_nm(character varying, character varying, numeric, character varying, character varying)

-- DROP FUNCTION tem.dv_accion_nm(character varying, character varying, numeric, character varying, character varying);

CREATE OR REPLACE FUNCTION tem.dv_accion_nm(_accion character varying, _descripcion character varying, _valoritem numeric, _cuenta character varying, _cxp_final character varying)
  RETURNS text AS
$BODY$

DECLARE

    factura_nm record;

BEGIN

    IF( _DESCRIPCION ILIKE 'APLICA FORMULA DE LA ACCION%')THEN
	return _cxp_final;
    END IF;

    IF( _DESCRIPCION ILIKE 'APLICA FACTORING DE LA ACCION%')THEN
       return _cxp_final;
    END IF;


    select into factura_nm *
       from (
        select
            fac.documento::varchar,
            substring(fac.documento,position('_'in fac.documento)+1,length(fac.documento))::integer AS cuota,
            fdet.descripcion::varchar,
            fdet.referencia_1::varchar as accion,
            codigo_cuenta_contable::varchar as cuenta ,
            valor_unitario::numeric
        from con.factura_detalle fdet
        inner join con.factura fac on (fac.documento=fdet.documento and fac.tipo_documento=fdet.tipo_documento)
        where
        fdet.referencia_1=_accion and
        --fdet.descripcion ilike trim(substring(_descripcion, 1,20))||'%' and
        --fdet.valor_unitario=_valoritem and
        fdet.codigo_cuenta_contable=_cuenta and
        --fdet.documento not in (select documento from tem.control_items_nm where descripcion = fdet.descripcion) and
        fdet.reg_status='' and
        fac.reg_status='' and
        fdet.concepto  in ('218','234')
        order by  fac.documento

        )t order by cuota limit 1;

    raise notice 'factura_nm: %',factura_nm.documento;
    if(factura_nm.documento is not null)then
        INSERT INTO tem.control_items_nm(
            documento, cuota, descripcion, accion, cuenta, valor_unitario)
            VALUES (factura_nm.documento,factura_nm.cuota, factura_nm.descripcion, factura_nm.accion, factura_nm.cuenta,factura_nm.valor_unitario);

    end if;

    RETURN factura_nm.documento;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION tem.dv_accion_nm(character varying, character varying, numeric, character varying, character varying)
  OWNER TO postgres;
