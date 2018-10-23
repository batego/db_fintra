-- Function: etes.validar_cupo_transportadora(integer)

-- DROP FUNCTION etes.validar_cupo_transportadora(integer);

CREATE OR REPLACE FUNCTION etes.validar_cupo_transportadora(idtransportadora integer)
  RETURNS boolean AS
$BODY$
DECLARE
retorno boolean:=false;
saldoCartera numeric:=0;
saldoCupo numeric:=0;
BEGIN
	--1)Buscamos el saldo en cartera de la transportadora.
	SELECT into saldoCartera sum(valor_saldo)as saldo_cartera
		from (
			SELECT
				cxc_corrida,
				fecha_corrida,
				fecha_pago_fintra,
				fac.valor_saldo
			FROM (
				SELECT
				agencia.id_transportadora,
				anticipo.reg_status,
				anticipo.planilla,
				anticipo.cxc_corrida,
				anticipo.fecha_corrida::DATE,
				anticipo.fecha_pago_fintra::DATE
				FROM etes.manifiesto_carga  as anticipo
				INNER JOIN etes.agencias AS agencia on (agencia.id=anticipo.id_agencia)
				where anticipo.reg_status='' AND anticipo.dstrct='FINV' and anticipo.cxc_corrida!=''
				union all
				SELECT
				agencia.id_transportadora,
				reanticipos.reg_status,
				reanticipos.planilla as planilla_reanticipo,
				reanticipos.cxc_corrida,
				reanticipos.fecha_corrida::DATE,
				reanticipos.fecha_pago_fintra::DATE
				From  etes.manifiesto_reanticipos as reanticipos
				inner join etes.manifiesto_carga  as anticipo on (anticipo.id=reanticipos.id_manifiesto_carga and reanticipos.reg_status='' and anticipo.reg_status='' AND anticipo.dstrct='FINV' )
				INNER JOIN etes.agencias AS agencia on (agencia.id=anticipo.id_agencia)
				where reanticipos.cxc_corrida!=''
			)tabla
			INNER JOIN con.factura fac on (fac.documento=tabla.cxc_corrida)
			where id_transportadora =idtransportadora --AND fecha_pago_fintra::DATE < NOW()::DATE
			AND fac.reg_status='' and fac.dstrct='FINV'
			group by
			cxc_corrida,
			fecha_corrida,
			fecha_pago_fintra,
			fac.valor_saldo
			ORDER BY fecha_pago_fintra DESC
	)mytabla;

	--verificamos que no se existan corridas
	if(saldoCartera is null and (SELECT count(0) FROM etes.manifiesto_carga  where cxc_corrida !='' and reg_status='')=0)then
		saldoCartera:=0;
	end if;

	--ralizamos la diferencia entre el cupo asignado - el saldo en cartera.
        SELECT into saldoCupo (cupo_rotativo-saldoCartera) FROM etes.transportadoras  where id=idtransportadora;
	raise notice 'saldo Cartera :%',saldoCartera;
	raise notice 'saldo Cupo:%',saldoCupo;

	if(saldoCupo >= 0 )then
	   retorno:=true;
	end if;

RETURN retorno;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.validar_cupo_transportadora(integer)
  OWNER TO postgres;
