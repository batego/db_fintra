-- Function: eg_detalle_liquidador_negocios_ca()

-- DROP FUNCTION eg_detalle_liquidador_negocios_ca();

CREATE OR REPLACE FUNCTION eg_detalle_liquidador_negocios_ca()
  RETURNS SETOF record AS
$BODY$
DECLARE

--retorno text:='';
record_liquidador record;
_factura_mi record;
_factura_cat record;
_factura_cm record;

BEGIN

	FOR record_liquidador IN (SELECT
					substring(neg.cod_neg,1,2)::varchar as tipo_convenio
					,replace(substring(f_desem,1,7),'-','')::varchar as periodo_desembolso
					,replace(substring(dna.fecha::date,1,7),'-','')::varchar as perido_vencimiento
					,id_convenio::integer
					,neg.cod_neg::varchar
					,neg.estado_neg::varchar as estado_negocio
					,cod_cli::varchar
					,fecha_negocio::date
					,vr_negocio::numeric
					,neg.periodo::varchar as perido_contable
					--,f_desem::date as fecha_desembolso
					,replace(f_desem::date,'0099-01-01','0101-01-01')::date as fecha_desembolso
					,dna.fecha::date as fecha_vencimiento
					,dna.item::varchar
					,dna.saldo_inicial::numeric
					,dna.capital::numeric
					,dna.interes::numeric
					,dna.valor::numeric
					,dna.cat::numeric
					,dna.seguro::numeric
					,dna.cuota_manejo::numeric
					,dna.saldo_final::numeric
					,dna.cuota_manejo_causada::varchar
					--,dna.fch_cuota_manejo_causada::date
					,replace(dna.fch_cuota_manejo_causada::date,'0099-01-01','0101-01-01')::date as fch_cuota_manejo_causada
					,dna.interes_causado::varchar
					,dna.fch_interes_causado::date
					,dna.documento_cat::varchar
					,dna.causar::varchar
					,dna.causar_cuota_admin::varchar
					,neg.creation_date::date
					,''::varchar as periodo_cat_causado
					,''::varchar as periodo_int_causado
					,'N'::varchar as cat_anulado_oper
					,'N'::varchar as int_anulado_oper
					,''::varchar as doc_cat_oper
					,''::varchar as doc_int_oper
					,coalesce(neg.num_ciclo,0)
					,coalesce(tem.esquema,'N') as esquema_old
					,ing.tipodoc as tipo_diferido
					,ing.cod as documento_diferido
					,ing.periodo as periodo_contable_diferido
					,ing.reg_status as estado_diferido
					,ing.fecha_doc::date as fecha_ven_diferido
					,''::varchar as periodo_cm_causado
					,''::varchar as cm_anulado_oper
					,''::varchar as doc_cm_oper
					,coalesce(tem2.esquema,'N') as esquemas_old_cm
					,ing.procesado_dif::varchar as procesado_diferido
				FROM negocios neg
				INNER JOIN documentos_neg_aceptado dna on (dna.cod_neg=neg.cod_neg)
				INNER JOIN ing_fenalco ing ON (dna.cod_neg=ing.codneg and ing.fecha_doc::date=dna.fecha::date AND ing.tipodoc  like 'CA%')
				LEFT JOIN tem.negocios_facturacion_old tem on (tem.cod_neg=dna.cod_neg)
				LEFT JOIN tem.negocios_facturacion_old_fenalco tem2 on (tem2.cod_neg=dna.cod_neg)
				WHERE dna.reg_status=''
				AND substring(neg.cod_neg,1,2) not in ('TF','NT','CD')
				AND neg.fecha_negocio::date  between '2017-01-01' AND substring(now(),1,4)||'-12-31'
				AND dna.reg_status=''
				and dna.cod_neg like 'MC%'
				ORDER BY cod_neg,fecha::date
				)

	LOOP
			--raise notice 'xxx %',record_liquidador;
			--select cod_neg from tem.negocios_facturacion_old
		if(record_liquidador.esquema_old='S')then
			SELECT INTO _factura_mi *
			FROM con.factura fac
			WHERE  fac.negasoc= record_liquidador.cod_neg
			AND fac.num_doc_fen= record_liquidador.item
			AND fac.documento LIKE 'MI%' ;
			--AND fac.reg_status !='A' ;

			IF (FOUND) THEN

				IF(_factura_mi.reg_status !='A')THEN

				   -- raise notice '_periodo_mi %',_factura_mi.periodo;
				    record_liquidador.periodo_int_causado:=_factura_mi.periodo;

			        ELSE
				    record_liquidador.int_anulado_oper:='S';
				END IF;

				record_liquidador.doc_int_oper:=_factura_mi.documento;

			END IF;


			SELECT INTO _factura_cat * FROM con.factura fac
			WHERE  fac.negasoc= record_liquidador.cod_neg
			AND fac.num_doc_fen= record_liquidador.item
			AND fac.documento LIKE 'CA%' ;
			--AND fac.reg_status !='A' ;

			IF (FOUND) THEN
				IF(_factura_cat.reg_status !='A')THEN
					--raise notice '_periodo_cat %',_factura_cat.periodo;
					record_liquidador.periodo_cat_causado:=_factura_cat.periodo;
				ELSE
					record_liquidador.cat_anulado_oper:='S';
				END IF;

				record_liquidador.doc_cat_oper:=_factura_cat.documento;

			END IF;

			raise notice ' record_liquidador.cod_neg : % record_liquidador.item : %', record_liquidador.cod_neg,record_liquidador.item;
			SELECT INTO _factura_cm * FROM con.factura fac
			WHERE  fac.negasoc= record_liquidador.cod_neg
			AND fac.num_doc_fen= record_liquidador.item
			AND fac.documento LIKE 'CM%' ;
			--AND fac.reg_status !='A' ;

			IF (FOUND) THEN
				raise notice '_factura_cm : %',_factura_cm;
				IF(_factura_cm.reg_status !='A')THEN
					raise notice '_periodo_cat %',_factura_cm.periodo;
					record_liquidador.periodo_cm_causado:=_factura_cm.periodo;
				ELSE
					record_liquidador.cm_anulado_oper:='S';
				END IF;

				record_liquidador.doc_cm_oper:=_factura_cm.documento;

			END IF;
		ELSE
			RAISE notice ' record_liquidador.cod_neg : % record_liquidador.item : %', record_liquidador.cod_neg,record_liquidador.item;

			SELECT INTO _factura_cm * FROM con.factura fac
			WHERE  fac.negasoc= record_liquidador.cod_neg
			AND fac.num_doc_fen= record_liquidador.item
			AND fac.documento LIKE 'CM%' ;
			--AND fac.reg_status !='A' ;

			IF (FOUND) THEN

				RAISE notice '_factura_cm : %',_factura_cm;
				IF(_factura_cm.reg_status !='A')THEN
					raise notice '_periodo_cat %',_factura_cm.periodo;
					record_liquidador.periodo_cm_causado:=_factura_cm.periodo;
				ELSE
					record_liquidador.cm_anulado_oper:='S';
				END IF;

				record_liquidador.doc_cm_oper:=_factura_cm.documento;

			END IF;

		END IF;

			RETURN NEXT record_liquidador;

	END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_detalle_liquidador_negocios_ca()
  OWNER TO postgres;
