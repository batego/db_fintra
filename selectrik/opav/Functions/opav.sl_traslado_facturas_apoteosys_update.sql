-- Function: opav.sl_traslado_facturas_apoteosys_update(numeric)

-- DROP FUNCTION opav.sl_traslado_facturas_apoteosys_update(numeric);

CREATE OR REPLACE FUNCTION opav.sl_traslado_facturas_apoteosys_update(estado_ numeric)
  RETURNS text AS
$BODY$

DECLARE
_resultado text:= 'Error';
_rec record;
_temp text:='';
BEGIN


			UPDATE  OPAV.SL_TRASLADO_FACTURAS_APOTEOSYS  SET TRASLADO_FINTRA = ESTADO_ WHERE DOCUMENTO IN(
				SELECT
					documento
				FROM dblink('dbname=fintra port=5432 host=localhost user=postgres password=bdversion17'::text, '
						select
							id,
							id_solicitud,
							centro_costo_ingreso,
							centro_costo_gasto,
							documento,
							traslado_selectrik,
							traslado_fintra,
							descripcion
						from CON.SL_TRASLADO_FACTURAS_APOTEOSYS where traslado_fintra =' || estado_ ||';
				'::text) as a(id numeric,  id_solicitud character varying,  centro_costo_ingreso character varying,  centro_costo_gasto character varying,  documento character varying,  traslado_selectrik character varying,  traslado_fintra character varying,  descripcion character varying));


_resultado:= 'OK';
return _resultado;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sl_traslado_facturas_apoteosys_update(numeric)
  OWNER TO postgres;
