-- Function: actualizar_consulta_terceros_resumen()

-- DROP FUNCTION actualizar_consulta_terceros_resumen();

CREATE OR REPLACE FUNCTION actualizar_consulta_terceros_resumen()
  RETURNS text AS
$BODY$DECLARE
  respuesta TEXT;

BEGIN
respuesta='nada.' ;
--create table copia.terceros20100413 as select * from  tem.terceros ;
drop table tem.terceros ;
create table tem.terceros as
select
  a.tipodoc,
  a.numdoc,
  a.grupo_transaccion,
  a.transaccion,
  a.periodo,
  a.cuenta,
  a.detalle,
  a.valor_debito,
  a.valor_credito,
  a.tercero,
  a.tipodoc_rel,
  a.documento_rel,
  case
    when substr(a.cuenta,1,1) in ('I','C','G') then b.cta_cierre
    else a.cuenta
  end as cta_cierre
from
  con.comprodet a,
  con.cuentas b
where
  substr(a.cuenta,1,1) in ('1','2','4','5','I','C','G')  and
  a.periodo <= '200912' and
  a.cuenta = b.cuenta;


--create table copia.terceros_resumen20100413 as select * from  tem.terceros_resumen ;
drop table tem.terceros_resumen ;
create table tem.terceros_resumen as
select
  a.tercero,
  b.nombre,
  a.cta_cierre,
  c.nombre_corto,
  a.valor_neto
from
   (select
     a.tercero,
     a.cta_cierre,
     sum(valor_debito-valor_credito) as valor_neto
   from
     tem.terceros  a
   group by
     a.tercero,
     a.cta_cierre ) a
   left outer join
   nit b on (b.cedula = a.tercero)
   left outer join
   con.cuentas c on (c.cuenta = a.cta_cierre)

where
   a.cta_cierre = c.cuenta and
   a.valor_neto != 0 ;

respuesta='proceso ejecutado.' ;

  RETURN respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION actualizar_consulta_terceros_resumen()
  OWNER TO postgres;
COMMENT ON FUNCTION actualizar_consulta_terceros_resumen() IS 'actualizar las tablas tem.terceros y tem.terceros_resumen';
