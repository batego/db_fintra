-- Function: administrativo.sp_insert_demandas_proceso_juridico()

-- DROP FUNCTION administrativo.sp_insert_demandas_proceso_juridico();

CREATE OR REPLACE FUNCTION administrativo.sp_insert_demandas_proceso_juridico()
  RETURNS text AS
$BODY$
DECLARE
  result text := 'OK';
 BEGIN



	--1.)Borra tabla con procesos bajo demanda
	DELETE FROM tem.demandas_proceso_juridico;

	--2.)Insertamos la nueva data
	INSERT INTO tem.demandas_proceso_juridico
	SELECT  id_etapa, cedula, nombre, ciudad, direccion, barrio,  telefono, celular,email, negocio,coalesce(id_demanda,'0') as id_demanda, id_und_negocio, und_negocio,id_convenio,
                convenio, fecha_inicio, fecha_marcacion,  dias_transcurridos, num_pagare, niter, vr_negocio,  vr_desembolso, valor_saldo, mora, estado_cartera, coalesce(id_juzgado,0) as id_juzgado,
                coalesce(radicado,'') as radicado, coalesce(docs_generados,'N') as docs_generados
	FROM administrativo.sp_lista_procesos_juridicos(' WHERE etapa_proc_ejec not in('''',0)') as f (id_etapa varchar, cedula varchar, nombre varchar, ciudad varchar, direccion varchar, barrio varchar, telefono varchar,
	celular varchar,email varchar, negocio varchar,id_demanda integer, id_und_negocio integer, und_negocio varchar,id_convenio integer,
	convenio varchar, fecha_inicio date, fecha_marcacion date, dias_transcurridos integer, num_pagare varchar, niter varchar,
	vr_negocio numeric, vr_desembolso numeric, valor_saldo numeric, mora varchar, estado_cartera varchar, id_juzgado integer, radicado varchar, docs_generados varchar);

	--ANALYZE tem.demandas_proceso_juridico ;

RETURN result;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION administrativo.sp_insert_demandas_proceso_juridico()
  OWNER TO postgres;
