-- Function: sp_pruebaconceptosrecaudos(date, character varying, date, date)

-- DROP FUNCTION sp_pruebaconceptosrecaudos(date, character varying, date, date);

CREATE OR REPLACE FUNCTION sp_pruebaconceptosrecaudos(fecha_hoy date, periodo_corriente character varying, vcto_rop date, pagar_antesde date)
  RETURNS SETOF record AS
$BODY$

DECLARE

	mcad TEXT;
	Mensaje TEXT;
	MsgPagueseAntes TEXT;
        MsgEstadoCredito TEXT;

	CarteraxCliente record;
	CarteraxCuota record;
	NegocioAvales record;
	NegocioSeguros record;
	ClienteRec record;
	--RecaudoxCuota record;
	_ConceptRec record;
	_Sancion record;
	_DetalleRopCondonar record;
	_Condonacion record;
	FchLastPay record;
	_TotalCuotasPendientes record;
	CarteraxCuotaAval record;
	CarteraxCuotaSeguro record;
	CarteraxCabeceraCta record;

	--IngresoxCuota numeric;
	_cod_rop numeric;
	_Current_codrop numeric;
	_Base numeric;
	_IxM numeric;
	_GaC numeric;
	_CxCta numeric;
	_Tasa numeric;
	_ValidarExistencia numeric;
	BolsaSaldo numeric;
	Diferencia numeric;
	VlDetFactura numeric;


	_TotalCuotas numeric;
	_TotalCuotasFaltantes numeric;
	_CtasPentesFaltantes numeric;
	_ConsolidarConcepto numeric;

	account integer;

	_SumIxM numeric;
	_SumGaC numeric;
	_SumBase numeric;
	_SumCxCta numeric;
	_SumDebidoCobrar numeric;

	CodRop varchar;
	periodo_corriente varchar;
	VerifyDetails varchar;
	CedulaExtemporanea varchar;

	FechaCalculoInteres date;

BEGIN

	mcad = 'TERMINADO!';
	CodRop = '';

	periodo_corriente = replace(substring(fecha_hoy,1,7),'-','');

	FOR CarteraxCliente IN

		select id_convenio, negasoc
		,count(0)-1 as total_cuotas_vencidas
		,(fecha_hoy-min(fecha_vencimiento)::DATE) as min_dias_ven
		FROM con.foto_cartera f
		WHERE f.reg_status = ''
			and f.dstrct = 'FINV'
			and f.tipo_documento in ('FAC','NDC')
			and f.id_convenio in (16,26)
			and f.valor_saldo > 0
			and replace(substring(f.fecha_vencimiento,1,7),'-','')::numeric <= periodo_corriente::numeric
			and f.periodo_lote = periodo_corriente::numeric
			and ( (select financia_aval from negocios where cod_neg = f.negasoc) = 't' or ( (select financia_aval from negocios where cod_neg = f.negasoc) = 'f' and (select negocio_rel from negocios where cod_neg = f.negasoc) = '' ) )
			--and f.negasoc not in ('FA11527','FA07892','FA11592','FA11601','FA11350','FA11324','FA07454','FA10945','FA08447','FA11434','FA11248','FA11532','FA08759','FA07786','FA04961','FA04960','FA10813','FA10814') --,  'FA11677','FA11601','FA12096','FA11434','FA11894','FA11839','FA11731','FA10945'
			and substring(f.documento,1,2) not in ('CP','FF')
			--and f.negasoc = 'FA06107'
			group by id_convenio, negasoc LOOP

			--CREACION CABECERA DEL EXTRACTO
			FOR CarteraxCabeceraCta IN

				SELECT
					f.negasoc as negocio,
					f.documento,
					f.num_doc_fen as cuota,
					f.valor_saldo,
					f.fecha_factura,
					f.fecha_vencimiento
				FROM con.foto_cartera f
				WHERE   f.reg_status = ''
					and f.dstrct = 'FINV'
					and f.tipo_documento in ('FAC','NDC')
					and f.valor_saldo > 0
					and f.negasoc = CarteraxCliente.negasoc
					and replace(substring(f.fecha_vencimiento,1,7),'-','')::numeric <= periodo_corriente
					and substring(f.documento,1,2) not in ('CP','FF')
					and f.periodo_lote = periodo_corriente::numeric

			LOOP

				BolsaSaldo = CarteraxCabeceraCta.valor_saldo;

				FOR CarteraxCuota IN

					SELECT negocio::varchar,
					       cedula::varchar,
					       documento::varchar,
					       prefijo::varchar,
					       cuota::varchar,
					       fecha_factura::varchar,
					       fecha_vencimiento::varchar,
					       sum(valor_saldo)::numeric as valor_saldo,
					       (fecha_hoy-fecha_vencimiento::DATE)::numeric AS dias_vencidos,
					       ''::varchar as concepto,
					       ''::varchar as sancion
					       FROM (

							SELECT
								f.negasoc::varchar as negocio,
								f.nit::varchar AS cedula,
								f.documento::varchar,
								fr.descripcion::varchar as prefijo,
								f.num_doc_fen::varchar as cuota,
								f.fecha_factura::varchar,
								f.fecha_vencimiento::varchar,
								fr.valor_unitario::numeric as valor_saldo --f.valor_saldo,
							FROM con.foto_cartera f, con.factura_detalle fr
							WHERE   f.documento = fr.documento
								and f.reg_status = ''
								and f.dstrct = 'FINV'
								and f.tipo_documento in ('FAC','NDC')
								and fr.reg_status = ''
								and fr.dstrct = 'FINV'
								and fr.tipo_documento in ('FAC','NDC')
								and f.valor_saldo > 0
								and f.negasoc = CarteraxCabeceraCta.negocio
								and f.num_doc_fen = CarteraxCabeceraCta.cuota
								and substring(f.documento,1,2) not in ('CP','FF')
								and replace(substring(f.fecha_vencimiento,1,7),'-','')::numeric <= periodo_corriente
								and f.periodo_lote = periodo_corriente::numeric
						) as c
					GROUP BY negocio, cedula, documento, prefijo, cuota, fecha_vencimiento, fecha_factura, dias_vencidos
					ORDER BY cuota::numeric

				LOOP

					_IxM = 0;
					_CxCta = 0;
					_Base = 0;
					_GaC = 0;

					-----------------------------------------------------------------------------------------------------------------------
					VerifyDetails = 'N';
					Diferencia = BolsaSaldo - CarteraxCuota.valor_saldo; --valor_unitario

					if ( Diferencia <= 0 and BolsaSaldo > 0) then

						VlDetFactura = BolsaSaldo;
						_Base = VlDetFactura;

						BolsaSaldo = BolsaSaldo - CarteraxCuota.valor_saldo; --valor_unitario
						VerifyDetails = 'S';

					elsif ( Diferencia > 0 and BolsaSaldo > 0 ) then

						VlDetFactura = CarteraxCuota.valor_saldo;
						_Base = VlDetFactura;

						BolsaSaldo = BolsaSaldo - CarteraxCuota.valor_saldo; --valor_unitario
						VerifyDetails = 'S';

					end if;

					-----------------------------------------------------------------------------------------------------------------------

					if ( VerifyDetails = 'S' ) then

						--BASES
						--_Base = CarteraxCuota.valor_saldo;

						--SUMA DE BASES
						_SumBase = _SumBase + _Base;

						--Conceptos
						SELECT INTO _ConceptRec * FROM conceptos_recaudo WHERE prefijo = CarteraxCuota.prefijo AND CarteraxCuota.dias_vencidos BETWEEN dias_rango_ini AND dias_rango_fin and id_unidad_negocio = 3;
						if found then CarteraxCuota.concepto = _ConceptRec.id; end if;

						--Sanciones
						FOR _Sancion IN SELECT * FROM sanciones_condonaciones WHERE id_tipo_acto = 1 AND id_conceptos_recaudo = _ConceptRec.id AND CarteraxCuota.dias_vencidos BETWEEN dias_rango_ini AND dias_rango_fin AND periodo = periodo_corriente and id_unidad_negocio = 3 LOOP
							if found then CarteraxCuota.sancion = _Sancion.id; end if;
						END LOOP; --_Sancion

					end if;

					RETURN NEXT CarteraxCuota;

				END LOOP; --CarteraxCuota


			END LOOP;




	END LOOP; --CarteraxCliente

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_pruebaconceptosrecaudos(date, character varying, date, date)
  OWNER TO postgres;
