-- Function: sp_solduplicacionintereses()

-- DROP FUNCTION sp_solduplicacionintereses();

CREATE OR REPLACE FUNCTION sp_solduplicacionintereses()
  RETURNS SETOF record AS
$BODY$
--RETURNS text AS $HYS$

DECLARE
	VarFI TEXT;
	VarCI TEXT;
	CIdb CHARACTER VARYING;
	VarFACcc TEXT;
	VarFACcg TEXT;
	CountDocum CHARACTER VARYING;
	FacturasFI record;
	QryCasos record;
	FactRem con.factura_detalle;
	RemDetalle integer;
	mcad TEXT;
	vfacs numeric;
	message TEXT;


BEGIN

	DROP TABLE IF EXISTS MisFacturas;

	CREATE TEMPORARY TABLE MisFacturas AS
		select reg_status, negasoc, concepto, documento, creation_date, fecha_factura, fecha_vencimiento, descripcion, valor_factura, valor_abono, fecha_ultimo_pago, valor_saldo, fecha_contabilizacion
		,(select numero_remesa from con.factura_detalle where documento = con.factura.documento) as numero_remesa
		,(select fecha_vencimiento from con.factura f where f.documento = (select numero_remesa from con.factura_detalle where documento = con.factura.documento)) as vence_remesa
		,(select interes from documentos_neg_aceptado where cod_neg = con.factura.negasoc and fecha = (select fecha_vencimiento from con.factura ff where ff.documento = (select numero_remesa from con.factura_detalle where documento = con.factura.documento))) as interes_liquidado
		from con.factura
		where substring(documento,1,2) = 'FI'
		order by documento;

	FOR FacturasFI IN select * from MisFacturas LOOP

		CIdb := '';
		VarFI := FacturasFI.documento;

		IF ( substring(FacturasFI.numero_remesa,1,2) = 'CC' OR substring(FacturasFI.numero_remesa,1,2) = 'CG' ) THEN

			--Busco su CI Respectiva
			VarCI := 'CI'||substring(FacturasFI.documento,3);
			SELECT INTO CIdb documento from con.factura where documento = VarCI;

			IF ( CIdb != '' ) THEN --SI LA CI EXISTE

				--Debe Permanecer - Ya fue anulada x el proceso CI!
				FOR QryCasos IN select reg_status::varchar, negasoc::varchar, concepto::varchar, documento::varchar, creation_date::varchar, fecha_factura::varchar, fecha_vencimiento::varchar, descripcion::varchar, valor_factura::varchar, valor_abono::varchar, fecha_ultimo_pago::varchar, valor_saldo::varchar, fecha_contabilizacion::varchar, 'PERMANECE! - YA SE LE GENERO CI MANUAL'::varchar as accion, FacturasFI.numero_remesa::varchar as remesa, FacturasFI.interes_liquidado::numeric as interes_liquidado, '-'::varchar as otrasfac, '0'::numeric as valor_facts_ci from con.factura where documento = VarFI LOOP
				    RETURN NEXT QryCasos;
				END LOOP;

			ELSE -- SI LA CI NO EXISTE

				--Esa FI es candidata para el proceso manual de CI! OJO!: BUSCAR OTRAS FACTURAS CI QUE AFECTEN A ESE DOCUMENTO RELACIONADO!
				mcad := '';
				vfacs = 0;
				message := '';

				SELECT INTO RemDetalle count(0)::integer from con.factura_detalle where numero_remesa = FacturasFI.numero_remesa and documento != VarFI and dstrct = 'FINV' and tipo_documento = 'FAC';

				IF ( RemDetalle = 0 ) THEN

					message := 'CANDIDATA PARA PROCESO DE CI MANUAL';

				ELSE
					FOR FactRem IN select * from con.factura_detalle where numero_remesa = FacturasFI.numero_remesa and documento != VarFI and dstrct = 'FINV' and tipo_documento = 'FAC' LOOP

						IF ( substring(FactRem.documento,1,2) = 'CI' ) THEN
							mcad := mcad || FactRem.documento || ':' || FactRem.valor_unitario || '-';
							vfacs := vfacs + FactRem.valor_unitario;
						END IF;

					END LOOP;
					message := 'A ESTUDIO - TIENE CI - DEBEN ELIMINARSE';

				END IF;

				FOR QryCasos IN select reg_status::varchar, negasoc::varchar, concepto::varchar, documento::varchar, creation_date::varchar, fecha_factura::varchar, fecha_vencimiento::varchar, descripcion::varchar, valor_factura::varchar, valor_abono::varchar, fecha_ultimo_pago::varchar, valor_saldo::varchar, fecha_contabilizacion::varchar, message::varchar as accion, FacturasFI.numero_remesa::varchar as remesa, FacturasFI.interes_liquidado::numeric as interes_liquidado, mcad::varchar as otrasfac, vfacs::numeric as valor_facts_ci from con.factura where documento = VarFI LOOP
				    RETURN NEXT QryCasos;
				END LOOP;

			END IF;


		ELSIF ( substring(FacturasFI.numero_remesa,1,2) = 'FC' OR substring(FacturasFI.numero_remesa,1,2) = 'FG' ) THEN

			VarFACcc := 'CC'||substring(FacturasFI.numero_remesa,3);
			VarFACcg := 'CG'||substring(FacturasFI.numero_remesa,3);

			SELECT INTO CountDocum count(0)::integer from con.factura where documento in (VarFACcc,VarFACcg);

			IF ( CountDocum = 0 ) THEN --La factura NO fue cargada a fiducia

				--Debe Permanecer!::CONFIABLE!
				FOR QryCasos IN select reg_status::varchar, negasoc::varchar, concepto::varchar, documento::varchar, creation_date::varchar, fecha_factura::varchar, fecha_vencimiento::varchar, descripcion::varchar, valor_factura::varchar, valor_abono::varchar, fecha_ultimo_pago::varchar, valor_saldo::varchar, fecha_contabilizacion::varchar, 'PERMANECE! - NO HA SIDO CARGADA A FIDUCIA!'::varchar as accion, FacturasFI.numero_remesa::varchar as remesa, FacturasFI.interes_liquidado::numeric as interes_liquidado, '-'::varchar as otrasfac, '0'::numeric as valor_facts_ci from con.factura where documento = VarFI LOOP
				    RETURN NEXT QryCasos;
				END LOOP;

			ELSE --La factura SI fue cargada a fiducia

				--AVERIGUA SI TIENE CI
				VarCI := 'CI'||substring(FacturasFI.documento,3);
				SELECT INTO CIdb documento from con.factura where documento = VarCI;

				IF ( CIdb != '' ) THEN --SI TIENE CI

					--Debe Permanecer!
					FOR QryCasos IN select reg_status::varchar, negasoc::varchar, concepto::varchar, documento::varchar, creation_date::varchar, fecha_factura::varchar, fecha_vencimiento::varchar, descripcion::varchar, valor_factura::varchar, valor_abono::varchar, fecha_ultimo_pago::varchar, valor_saldo::varchar, fecha_contabilizacion::varchar, 'PERMANECE! - YA SE LE GENERO CI MANUAL'::varchar as accion, FacturasFI.numero_remesa::varchar as remesa, FacturasFI.interes_liquidado::numeric as interes_liquidado, '-'::varchar as otrasfac, '0'::numeric as valor_facts_ci from con.factura where documento = VarFI LOOP
					    RETURN NEXT QryCasos;
					END LOOP;

				ELSE --SI NO TIENE CI

					--Debe eliminarse esa FI::CONFIABLE
					FOR QryCasos IN select reg_status::varchar, negasoc::varchar, concepto::varchar, documento::varchar, creation_date::varchar, fecha_factura::varchar, fecha_vencimiento::varchar, descripcion::varchar, valor_factura::varchar, valor_abono::varchar, fecha_ultimo_pago::varchar, valor_saldo::varchar, fecha_contabilizacion::varchar, 'ELIMINAR FI - no ci y no cargada a fiducia'::varchar as accion, FacturasFI.numero_remesa::varchar as remesa, FacturasFI.interes_liquidado::numeric as interes_liquidado, '-'::varchar as otrasfac, '0'::numeric as valor_facts_ci from con.factura where documento = VarFI LOOP
					    RETURN NEXT QryCasos;
					END LOOP;

				END IF;

			END IF;

		END IF;


	END LOOP;


	--RETURN mcad;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_solduplicacionintereses()
  OWNER TO postgres;
