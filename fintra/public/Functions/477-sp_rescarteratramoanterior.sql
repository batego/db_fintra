-- Function: sp_rescarteratramoanterior(numeric, character varying, character varying)

-- DROP FUNCTION sp_rescarteratramoanterior(numeric, character varying, character varying);

CREATE OR REPLACE FUNCTION sp_rescarteratramoanterior(periodoasignacion numeric, unidadnegocio character varying, agenteext character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE

	CarteraTotales record;
	CarteraGeneral record;
	TramoAval record;
	CarteraWtramoAnterior record;
	CarteraWtramoAnteriorList record;
	NegocioArray record;
	s record;

	PercValorAsignado numeric;
	PercCantAsignado numeric;
	_TramoAnterior numeric;
	PeriodoTramo numeric;
	PeriodoTramoAnterior numeric;
	Cnt numeric;
	ContaVerify numeric;
	Restador numeric;
	VarOid numeric;

	CadAgentes varchar;
	periodo_corte varchar;
	FechaCortePeriodo varchar;
	FechaCortePeriodoAnt varchar;
	Business varchar;
	Compara varchar;
	temporaly varchar;
	FirstTime varchar;

BEGIN

	Business = '';
	Compara = '';
	temporaly = '';

	if ( substring(PeriodoAsignacion,5) = '01' ) then
		PeriodoTramo = substring(PeriodoAsignacion,1,4)::numeric-1||'12';
		_TramoAnterior = substring(PeriodoAsignacion,1,4)::numeric-1||'12';
	else
		PeriodoTramo = PeriodoAsignacion::numeric - 1;
		_TramoAnterior = PeriodoAsignacion::numeric - 1;
	end if;

	--PeriodoTramo = PeriodoAsignacion::numeric - 1;
	PeriodoTramoAnterior = PeriodoTramo::numeric - 1;
	--_TramoAnterior = PeriodoAsignacion::numeric - 1;

	ContaVerify = 0;

	select into FechaCortePeriodo to_char(to_timestamp(substring(PeriodoTramo,1,4)::numeric || '-' || to_char(substring(PeriodoTramo,5,2)::numeric,'FM00') || '-01', 'YYYY-MM-DD') + INTERVAL '1 month' - INTERVAL '1 days', 'YYYY-MM-DD');
	select into FechaCortePeriodoAnt to_char(to_timestamp(substring(PeriodoTramoAnterior,1,4)::numeric || '-' || to_char(substring(PeriodoTramoAnterior,5,2)::numeric,'FM00') || '-01', 'YYYY-MM-DD') + INTERVAL '1 month' - INTERVAL '1 days', 'YYYY-MM-DD');

	TRUNCATE tem.tramo_anterior;
	DELETE FROM tem.tabla_array WHERE creation_date::date < now()::date and modulo_cartera = 'TRAMO_ANTERIOR';
	DELETE FROM tem.tabla_array WHERE useruse = AgenteExt and modulo_cartera = 'TRAMO_ANTERIOR';

	FirstTime = 'First';

	select into CarteraTotales sum(valor_asignado)::numeric as valor_asignado, count(0)::numeric as total_asignado
	from (
		select
		sum(valor_saldo)::numeric as valor_asignado
		from con.foto_cartera
		where periodo_lote = PeriodoAsignacion
		and valor_saldo > 0
		and reg_status = ''
		and dstrct = 'FINV'
		and tipo_documento in ('FAC','NDC')
		and substring(documento,1,2) not in ('CP','FF','DF')
		and id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio in (select id from unidad_negocio where id = UnidadNegocio))
		and (SELECT count(0) from negocios where cod_neg = con.foto_cartera.negasoc and negocio_rel = '') > 0
		group by negasoc

	union all
		select
		sum(valor_saldo)::numeric as valor_asignado
		from con.foto_cartera
		where periodo_lote = PeriodoAsignacion
		and valor_saldo > 0
		and reg_status = ''
		and dstrct = 'FINV'
		and tipo_documento in ('FAC','NDC')
		and substring(documento,1,2) not in ('CP','FF','DF')
		and id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio in (select id from unidad_negocio where id = UnidadNegocio))
		and (SELECT count(0) from negocios where cod_neg = con.foto_cartera.negasoc and negocio_rel = '') = 0
	) a;

	select into Restador count(0) --into ContaVerify coalesce(count(0),0)
	from con.foto_cartera
	where periodo_lote = PeriodoAsignacion
	and valor_saldo > 0
	and reg_status = ''
	and dstrct = 'FINV'
	and tipo_documento in ('FAC','NDC')
	and substring(documento,1,2) not in ('CP','FF','DF')
	and id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio in (select id from unidad_negocio where id = UnidadNegocio))
	and (SELECT count(0) from negocios where cod_neg = con.foto_cartera.negasoc and negocio_rel = '') = 0;
	if found then
		ContaVerify = 1;
	end if;


	FOR CarteraGeneral IN

		select

		vencimiento_mayor::varchar,
		sum(valor_asignado)::varchar as vlr_asignado,
		''::varchar as perc_valor_asignado,
		count(0)::numeric AS cantidad_asignada,
		''::varchar as perc_cantidad_asignado,

		''::varchar as tramo_anterior,
		0::numeric as sumaTramo_anterior,
		0::numeric as cantTramo_anterior,

		''::varchar as max_reg_tramo,
		''::varchar as usuario

		from (

			select
			sum(valor_saldo)::numeric as valor_asignado,
				(
				SELECT
					CASE WHEN maxdia >= 365 THEN '8- MAYOR A 1 AÑO'
					     WHEN maxdia >= 181 THEN '7- ENTRE 180 Y 360'
					     WHEN maxdia >= 121 THEN '6- ENTRE 121 Y 180'
					     WHEN maxdia >= 91 THEN '5- ENTRE 91 Y 120'
					     WHEN maxdia >= 61 THEN '4- ENTRE 61 Y 90'
					     WHEN maxdia >= 31 THEN '3- ENTRE 31 Y 60'
					     WHEN maxdia >= 1 THEN '2- 1 A 30'
					     WHEN maxdia <= 0 THEN '1- CORRIENTE'
						ELSE '0' END AS rango
				FROM (
					 SELECT max(FechaCortePeriodo::date-(fecha_vencimiento)) as maxdia
					 FROM con.foto_cartera fra
					 WHERE fra.dstrct = 'FINV'
						  AND fra.valor_saldo > 0
						  AND fra.reg_status = ''
						  AND fra.negasoc = con.foto_cartera.negasoc
						  AND fra.tipo_documento in ('FAC','NDC')
						  AND fra.periodo_lote = PeriodoAsignacion
					 GROUP BY negasoc

				) tabla2
				) as vencimiento_mayor

			from con.foto_cartera
			where periodo_lote = PeriodoAsignacion
			and valor_saldo > 0
			and reg_status = ''
			and dstrct = 'FINV'
			and tipo_documento in ('FAC','NDC')
			and substring(documento,1,2) not in ('CP','FF','DF')
			and id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio in (select id from unidad_negocio where id = UnidadNegocio))
			and (SELECT count(0) from negocios where cod_neg = con.foto_cartera.negasoc and negocio_rel = '') > 0
			group by negasoc


		) c
		group by vencimiento_mayor LOOP

		PercValorAsignado = ((CarteraGeneral.vlr_asignado::numeric / CarteraTotales.valor_asignado)*100)::numeric(5,2);
		PercCantAsignado = ((CarteraGeneral.cantidad_asignada::numeric / CarteraTotales.total_asignado)*100)::numeric(5,2);

		----------------------------------------------------------------------------------------------------------------------------------------------------------------
		SELECT INTO TramoAval vencimiento_mayor, valor_asignado::numeric
		FROM (

			select

				(
				SELECT
					CASE WHEN maxdia >= 365 THEN '8- MAYOR A 1 AÑO'
					     WHEN maxdia >= 181 THEN '7- ENTRE 180 Y 360'
					     WHEN maxdia >= 121 THEN '6- ENTRE 121 Y 180'
					     WHEN maxdia >= 91 THEN '5- ENTRE 91 Y 120'
					     WHEN maxdia >= 61 THEN '4- ENTRE 61 Y 90'
					     WHEN maxdia >= 31 THEN '3- ENTRE 31 Y 60'
					     WHEN maxdia >= 1 THEN '2- 1 A 30'
					     WHEN maxdia <= 0 THEN '1- CORRIENTE'
						ELSE '0' END AS rango
				FROM (
					 SELECT max(FechaCortePeriodo::date-(fecha_vencimiento)) as maxdia
					 FROM con.foto_cartera fra
					 WHERE fra.dstrct = 'FINV'
						  AND fra.valor_saldo > 0
						  AND fra.reg_status = ''
						  AND fra.negasoc = con.foto_cartera.negasoc
						  AND fra.tipo_documento in ('FAC','NDC')
						  AND fra.periodo_lote = PeriodoAsignacion
					 GROUP BY negasoc

				) tabla2
				) as vencimiento_mayor,
				sum(valor_saldo)::numeric as valor_asignado

			from con.foto_cartera
			where periodo_lote = PeriodoAsignacion
			and valor_saldo > 0
			and reg_status = ''
			and dstrct = 'FINV'
			and tipo_documento in ('FAC','NDC')
			and substring(documento,1,2) not in ('CP','FF','DF')
			and id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio in (select id from unidad_negocio where id = UnidadNegocio))
			and negasoc in (

					SELECT cod_neg from negocios where negocio_rel in (
						select negasoc
						from con.foto_cartera
						where periodo_lote = PeriodoAsignacion
						and valor_saldo > 0
						and reg_status = ''
						and dstrct = 'FINV'
						and tipo_documento in ('FAC','NDC')
						and substring(documento,1,2) not in ('CP','FF','DF')
						and id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio in (select id from unidad_negocio where id = UnidadNegocio))
						and (SELECT count(0) from negocios where cod_neg = con.foto_cartera.negasoc and negocio_rel = '') > 0
						group by negasoc
					)

			)
			group by vencimiento_mayor
		) c
		where vencimiento_mayor = CarteraGeneral.vencimiento_mayor;

		IF FOUND THEN

			--CarteraGeneral.vlr_asignado = CarteraGeneral.vlr_asignado::numeric + TramoAval.valor_asignado::numeric;

		END IF;
		----------------------------------------------------------------------------------------------------------------------------------------------------------------
		----------------------------------------------------------------------------------------------------------------------------------------------------------------
		Cnt = 0;

		insert into tem.tramo_anterior
			select
			''::varchar as vencimiento_mayor,
			''::varchar as vlr_asignado,
			''::varchar as perc_valor_asignado,
			0::numeric as cantidad_asignada,
			''::varchar as perc_cantidad_asignado,

			tramo_anterior::varchar, --''::varchar as tramo_anterior,
			sum(sumaTramo_anterior)::numeric as sumaTramo_anterior, --0::numeric as sumaTramo_anterior,
			count(0)::numeric as cantTramo_anterior, --count(0)::numeric as cantTramo_anterior, --0::numeric as cantTramo_anterior,

			''::varchar as max_reg_tramo,
			''::varchar as usuario




			from (
				select
					(
					SELECT
						CASE WHEN maxdia >= 365 THEN '8- MAYOR A 1 AÑO'
						     WHEN maxdia >= 181 THEN '7- ENTRE 180 Y 360'
						     WHEN maxdia >= 121 THEN '6- ENTRE 121 Y 180'
						     WHEN maxdia >= 91 THEN '5- ENTRE 91 Y 120'
						     WHEN maxdia >= 61 THEN '4- ENTRE 61 Y 90'
						     WHEN maxdia >= 31 THEN '3- ENTRE 31 Y 60'
						     WHEN maxdia >= 1 THEN '2- 1 A 30'
						     WHEN maxdia <= 0 THEN '1- CORRIENTE'
							ELSE '0' END AS rango
					FROM (
						 SELECT max(FechaCortePeriodo::date-(fecha_vencimiento)) as maxdia
						 FROM con.foto_cartera fra
						 WHERE fra.dstrct = 'FINV'
							  AND fra.valor_saldo > 0
							  AND fra.reg_status = ''
							  AND fra.negasoc = con.foto_cartera.negasoc
							  AND fra.tipo_documento in ('FAC','NDC')
							  AND fra.periodo_lote = PeriodoAsignacion
						 GROUP BY negasoc

					) tabla2
					) as vencimiento_mayor,

					(
					SELECT
						CASE WHEN maxdia >= 361 THEN '8- MAYOR A 1 AÑO'
						     WHEN maxdia >= 181 THEN '7- ENTRE 180 Y 360'
						     WHEN maxdia >= 121 THEN '6- ENTRE 121 Y 180'
						     WHEN maxdia >= 91 THEN '5- ENTRE 91 Y 120'
						     WHEN maxdia >= 61 THEN '4- ENTRE 61 Y 90'
						     WHEN maxdia >= 31 THEN '3- ENTRE 31 Y 60'
						     WHEN maxdia >= 1 THEN '2- 1 A 30'
						     WHEN maxdia <= 0 THEN '1- CORRIENTE'
							ELSE '0' END AS rango
					FROM (
						 SELECT max(FechaCortePeriodoAnt::date-fecha_vencimiento) as maxdia
						 FROM con.foto_cartera fra
						 WHERE fra.dstrct = 'FINV'
							  AND fra.valor_saldo > 0
							  AND fra.reg_status = ''
							  AND fra.negasoc = con.foto_cartera.negasoc --'MC03657'
							  AND fra.tipo_documento in ('FAC','NDC')
							  AND fra.periodo_lote = _TramoAnterior
						 GROUP BY negasoc

					) tabla3
					) as tramo_anterior,



					(
					select valor_saldo from (
						SELECT
							CASE WHEN maxdia >= 361 THEN '8- MAYOR A 1 AÑO'
							     WHEN maxdia >= 181 THEN '7- ENTRE 180 Y 360'
							     WHEN maxdia >= 121 THEN '6- ENTRE 121 Y 180'
							     WHEN maxdia >= 91 THEN '5- ENTRE 91 Y 120'
							     WHEN maxdia >= 61 THEN '4- ENTRE 61 Y 90'
							     WHEN maxdia >= 31 THEN '3- ENTRE 31 Y 60'
							     WHEN maxdia >= 1 THEN '2- 1 A 30'
							     WHEN maxdia <= 0 THEN '1- CORRIENTE'
								ELSE '0' END AS rango, valor_saldo
						FROM (
							 SELECT max(FechaCortePeriodoAnt::date-fecha_vencimiento) as maxdia, sum(valor_saldo) as valor_saldo
							 FROM con.foto_cartera fra
							 WHERE fra.dstrct = 'FINV'
								  AND fra.valor_saldo > 0
								  AND fra.reg_status = ''
								  AND fra.negasoc = con.foto_cartera.negasoc --'MC03600'
								  AND fra.tipo_documento in ('FAC','NDC')
								  AND fra.periodo_lote = _TramoAnterior
							 GROUP BY negasoc

						) c
					) z
					) as sumaTramo_anterior


				from con.foto_cartera
				where periodo_lote = PeriodoAsignacion
				and valor_saldo > 0
				and reg_status = ''
				and dstrct = 'FINV'
				and tipo_documento in ('FAC','NDC')
				and substring(documento,1,2) not in ('CP','FF','DF')
				and id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio in (select id from unidad_negocio where id = UnidadNegocio))
				and (SELECT count(0) from negocios where cod_neg = con.foto_cartera.negasoc and negocio_rel = '') > 0
				group by negasoc

			) c

			where vencimiento_mayor = CarteraGeneral.vencimiento_mayor
			group by vencimiento_mayor,tramo_anterior;

			--s = pgstattuple(CarteraWtramoAnterior.vencimiento_mayor);
			--CarteraWtramoAnterior.fechaCorte = s.tuple_count;

			update tem.tramo_anterior
				set
				vencimiento_mayor = CarteraGeneral.vencimiento_mayor,
				vlr_asignado = CarteraGeneral.vlr_asignado,
				cantidad_asignada = CarteraGeneral.cantidad_asignada,
				perc_valor_asignado = PercValorAsignado,
				perc_cantidad_asignado = PercCantAsignado,
				usuario = AgenteExt,
				marca_vencimiento_mayor = CarteraGeneral.vencimiento_mayor,
				max_reg_tramo = (select count(0) from tem.tramo_anterior u where vencimiento_mayor = '')
			where vencimiento_mayor = '';

		----------------------------------------------------------------------------------------------------------------------------------------------------------------
		----------------------------------------------------------------------------------------------------------------------------------------------------------------

		-- select * from SP_ResCarteraTramoAnterior(201407,'13','hcuello') as coco(vencimiento_mayor varchar, valor_asignado varchar, perc_valor_asignado varchar, cantidad_asignada numeric, perc_cantidad_asignada varchar, tramo_anterior varchar, sumaTramo_anterior numeric, cantTramo_anterior numeric, max_reg_tramo varchar, marca_vencimiento_mayor varchar, usuario varchar, marca varchar) order by marca_vencimiento_mayor,tramo_anterior;


	END LOOP;

	update tem.tramo_anterior set tramo_anterior = '0- NUEVOS', sumatramo_anterior = 0 where usuario = AgenteExt and tramo_anterior is null;

	FOR CarteraWtramoAnterior IN select oid::varchar,* from tem.tramo_anterior where usuario = AgenteExt order by vencimiento_mayor,tramo_anterior LOOP

		--VALIDADOR
		--select into NegocioArray campo_compara from tem.tabla_array where useruse = AgenteExt and campo_compara = CarteraWtramoAnterior.vencimiento_mayor;
		select into NegocioArray campo_compara from tem.tabla_array where useruse = AgenteExt and campo_compara = CarteraWtramoAnterior.vencimiento_mayor and modulo_cartera = 'TRAMO_ANTERIOR';

		if ( FirstTime = 'First' ) then

			--insert into tem.tabla_array (useruse, campo_compara) values(AgenteExt, CarteraWtramoAnterior.vencimiento_mayor);
			insert into tem.tabla_array (useruse, dstrct, modulo_cartera, creation_date, campo_compara) values(AgenteExt, 'FINV', 'TRAMO_ANTERIOR', now(), CarteraWtramoAnterior.vencimiento_mayor);
			VarOid = CarteraWtramoAnterior.oid;
			FirstTime = 'NoMore';
			update tem.tramo_anterior set marca = 'X' where oid = VarOid;

		elsif ( NOT FOUND ) then

			--insert into tem.tabla_array (useruse, campo_compara) values(AgenteExt, CarteraWtramoAnterior.vencimiento_mayor);
			insert into tem.tabla_array (useruse, dstrct, modulo_cartera, creation_date, campo_compara) values(AgenteExt, 'FINV', 'TRAMO_ANTERIOR', now(), CarteraWtramoAnterior.vencimiento_mayor);
			VarOid = CarteraWtramoAnterior.oid;
			update tem.tramo_anterior set marca = 'X' where oid = VarOid;


		end if;

	END LOOP;

	update tem.tramo_anterior
		set
		vencimiento_mayor = '',
		vlr_asignado = '',
		cantidad_asignada = 0,
		perc_valor_asignado = '',
		perc_cantidad_asignado = ''
	where usuario = AgenteExt and marca != 'X';

	FOR CarteraWtramoAnteriorList IN select vencimiento_mayor, vlr_asignado, perc_valor_asignado, cantidad_asignada, perc_cantidad_asignado, tramo_anterior, sumaTramo_anterior, canttramo_anterior, max_reg_tramo, marca_vencimiento_mayor, usuario, marca from tem.tramo_anterior where usuario = AgenteExt order by marca_vencimiento_mayor,tramo_anterior LOOP
		RETURN NEXT CarteraWtramoAnteriorList;
	END LOOP;


END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_rescarteratramoanterior(numeric, character varying, character varying)
  OWNER TO postgres;
