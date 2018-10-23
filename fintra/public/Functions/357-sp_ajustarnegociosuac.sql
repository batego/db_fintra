-- Function: sp_ajustarnegociosuac()

-- DROP FUNCTION sp_ajustarnegociosuac();

CREATE OR REPLACE FUNCTION sp_ajustarnegociosuac()
  RETURNS text AS
$BODY$

DECLARE

	NegociosCorregir record;
	FacturasxCuota record;

	mcad TEXT;

	BolsaNG numeric;
	BolsaINT numeric;
	BolsaINTemp numeric;
	BolsaCAP numeric;

	_numero_factura CHARACTER VARYING;
	_auxiliar CHARACTER VARYING;

BEGIN

	mcad = 'TERMINADO!';

	FOR NegociosCorregir IN

		select
			fc.negasoc,
			sum(valor_factura) as valor_factura, sum(valor_abono) as valor_abono, sum(valor_saldo) as valor_saldo
		from con.foto_cartera fc
		where fc.periodo_lote = '201511'
		      and substring(fc.documento,1,2) = 'CK'
		      --and fc.negasoc = 'CD00003'
		      and fc.id_convenio =42
		      and valor_abono > 0
		      --and valor_saldo not in (-1,0,1)
		group by fc.negasoc
		order by negasoc

	LOOP

		BolsaNG = 0;
		BolsaINT = 0;
		BolsaINTemp = 0;
		BolsaCAP = 0;

		FOR FacturasxCuota IN

			select
				fc.negasoc, fc.codcli, fc.nit, fc.documento, fc.num_doc_fen, fc.fecha_vencimiento,
				fc.valor_factura, fc.valor_abono, fc.valor_saldo,
				fd.valor_unitario as capital, (fc.valor_factura - fd.valor_unitario) as intereses
			from con.foto_cartera fc, con.factura_detalle fd
			where fc.documento = fd.documento and
			fc.periodo_lote = '201511'
			--and fc.negasoc = 'CD00003' --NegociosCorregir.negasoc --'CD00767' | 'CD00003'
			and fc.id_convenio = 42
			and fd.descripcion = 'CAPITAL'
			order by fc.negasoc, fc.num_doc_fen

		LOOP

			if ( FacturasxCuota.valor_saldo > 0 ) then --FacturasxCuota.valor_saldo > 0

				BolsaNG = BolsaNG + FacturasxCuota.valor_saldo;

				if ( FacturasxCuota.valor_factura != FacturasxCuota.valor_saldo ) then

					if ( FacturasxCuota.valor_abono >= FacturasxCuota.intereses ) then
						--NO SUMA | Elimina el concepto de interes y actualiza el valor de capital por el saldo
						--DELETE FROM con.comprodet where numdoc = FacturasxCuota.documento and detalle = 'INTERESES' and cuenta = '13050920';
						--UPDATE con.comprodet SET valor_credito = round(FacturasxCuota.valor_saldo) where numdoc = FacturasxCuota.documento and detalle = 'CAPITAL' and cuenta = '13050920';
						--UPDATE con.comprodet SET valor_debito = round(FacturasxCuota.valor_saldo) where numdoc = FacturasxCuota.documento and cuenta = '13050921';

					elsif ( FacturasxCuota.valor_abono < FacturasxCuota.intereses ) then
						--SI SUMA
						BolsaINTemp = FacturasxCuota.intereses - FacturasxCuota.valor_abono;
						BolsaINT = BolsaINT + (FacturasxCuota.intereses - FacturasxCuota.valor_abono);
						--INSERT INTO ing_fenalco(dstrct,cod,codneg,valor,nit,creation_user,base,fecha_doc,cmc) values ('FINV', get_lcod_ing('IF',substring(FacturasxCuota.negasoc,3)::integer||FacturasxCuota.num_doc_fen), FacturasxCuota.negasoc, round(BolsaINTemp), FacturasxCuota.nit, 'HCUELLO', 'COL', FacturasxCuota.fecha_vencimiento, '01');
						--UPDATE con.comprodet SET valor_credito = round(BolsaINTemp) where numdoc = FacturasxCuota.documento and detalle = 'INTERESES' and cuenta = '13050920';

					end if;
				else
					BolsaINT = BolsaINT + FacturasxCuota.intereses;
					--INSERT INTO ing_fenalco(dstrct,cod,codneg,valor,nit,creation_user,base,fecha_doc,cmc) values ('FINV', get_lcod_ing('IF',substring(FacturasxCuota.negasoc,3)::integer||FacturasxCuota.num_doc_fen), FacturasxCuota.negasoc, round(FacturasxCuota.intereses), FacturasxCuota.nit, 'HCUELLO', 'COL', FacturasxCuota.fecha_vencimiento, '01');
				end if;

			elsif ( FacturasxCuota.valor_saldo <= 0 ) then

				DELETE FROM con.comprodet where numdoc = FacturasxCuota.documento and tipodoc = 'FAC';
				DELETE FROM con.comprobante where numdoc = FacturasxCuota.documento and tipodoc = 'FAC';


			end if;

		END LOOP;

		BolsaCAP = BolsaNG - BolsaINT;

		if ( BolsaNG != 0 and BolsaINT != 0 and BolsaCAP != 0 ) then

			--UPDATE con.comprodet SET valor_debito = BolsaNG WHERE numdoc = NegociosCorregir.negasoc AND cuenta = '13050920';
			--UPDATE con.comprodet SET valor_credito = BolsaINT WHERE numdoc = NegociosCorregir.negasoc AND cuenta = '27050575';
			--UPDATE con.comprodet SET valor_credito = BolsaCAP WHERE numdoc = NegociosCorregir.negasoc AND cuenta = '23053001';
		end if;

	END LOOP;

	RETURN mcad;

END
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_ajustarnegociosuac()
  OWNER TO postgres;
