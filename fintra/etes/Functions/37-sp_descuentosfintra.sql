-- Function: etes.sp_descuentosfintra(integer, character varying)

-- DROP FUNCTION etes.sp_descuentosfintra(integer, character varying);

CREATE OR REPLACE FUNCTION etes.sp_descuentosfintra(_idmanifiesto integer, tipo_anticipo character varying)
  RETURNS text AS
$BODY$

DECLARE

	ManifiestoCarga record;
	DesctosPlanilla record;
	ReturnFechaPago record;

	ValorNetoAnticipo numeric = 0;
	PercDescto numeric = 0;
	ValorDescto numeric = 0;
	TotalDesctos numeric = 0;

	IdManifiestoCarga integer := 0;
	_IsReanticipo varchar = '';


	retorno text:='OK';

BEGIN

	if ( tipo_anticipo = 'A' ) then

		SELECT INTO ManifiestoCarga *
		,(SELECT id_transportadora FROM etes.agencias WHERE id = mc.id_agencia) AS id_transportadora
		FROM etes.manifiesto_carga mc
		WHERE id = _idmanifiesto;

		ValorNetoAnticipo = ManifiestoCarga.valor_neto_anticipo;
		IdManifiestoCarga = ManifiestoCarga.id;
		_IsReanticipo = 'N';

	elsif ( tipo_anticipo = 'R' ) then

		SELECT INTO ManifiestoCarga *
		,(SELECT id_transportadora FROM etes.agencias WHERE id = (SELECT id_agencia FROM etes.manifiesto_carga WHERE id = mr.id_manifiesto_carga)) AS id_transportadora
		,(select id_proserv from etes.manifiesto_carga where id = mr.id_manifiesto_carga) as id_proserv
		FROM etes.manifiesto_reanticipos mr
		WHERE id = _idmanifiesto;

		ValorNetoAnticipo = ManifiestoCarga.valor_reanticipo;
		IdManifiestoCarga = ManifiestoCarga.id_manifiesto_carga;
		_IsReanticipo = 'S';

	end if;

	raise notice 'ValorNetoAnticipo: %',ValorNetoAnticipo;

	FOR DesctosPlanilla IN

		select *
		from etes.config_productos_descuentos
		where id_transportadora = ManifiestoCarga.id_transportadora
		and id_proserv = ManifiestoCarga.id_proserv
		and reg_status = ''

	LOOP

		if ( DesctosPlanilla.porcentaje_descuento != 0 ) then

			PercDescto = round((ValorNetoAnticipo * (DesctosPlanilla.porcentaje_descuento/100)));
			ValorNetoAnticipo = ValorNetoAnticipo - PercDescto;
			TotalDesctos = TotalDesctos + PercDescto;
			raise notice 'PercDescto: %, ValorNetoAnticipo: %, TotalDesctos: %',PercDescto,ValorNetoAnticipo,TotalDesctos;

			INSERT INTO etes.manifiesto_descuentos(id_manifiesto_carga, planilla, reanticipo, id_productos_descuentos, fecha_aplicacion_descuento, porcentaje_descuento, valor_descuento)
			VALUES (IdManifiestoCarga, ManifiestoCarga.planilla, _IsReanticipo, DesctosPlanilla.id, now(), DesctosPlanilla.porcentaje_descuento, PercDescto);

		end if;

		if ( DesctosPlanilla.valor_descuento != 0 ) then

			ValorDescto = DesctosPlanilla.valor_descuento;
			ValorNetoAnticipo = ValorNetoAnticipo - ValorDescto;
			TotalDesctos = TotalDesctos + ValorDescto;
			raise notice 'ValorDescto: %, ValorNetoAnticipo: %, TotalDesctos: %',ValorDescto,ValorNetoAnticipo,TotalDesctos;

			INSERT INTO etes.manifiesto_descuentos(id_manifiesto_carga, planilla, reanticipo, id_productos_descuentos, fecha_aplicacion_descuento, porcentaje_descuento, valor_descuento)
			VALUES (IdManifiestoCarga, ManifiestoCarga.planilla, _IsReanticipo, DesctosPlanilla.id, now(), 0, ValorDescto);

		end if;

	END LOOP;


	if ( tipo_anticipo = 'A' ) then

		--select into ReturnFechaPago etes.SP_FechaPagarFintra(1, 'A');
		select into ReturnFechaPago * from etes.SP_FechaPagarFintra(_idmanifiesto, 'A') as (fechacorrida varchar, fechapagofintra varchar);
		raise notice 'FECHApago-a: %',ReturnFechaPago;

		UPDATE etes.manifiesto_carga SET valor_descuentos_fintra = TotalDesctos, valor_desembolsar = ValorNetoAnticipo-ManifiestoCarga.valor_comision_intermediario, fecha_corrida = ReturnFechaPago.fechacorrida::date, fecha_pago_fintra = ReturnFechaPago.fechapagofintra::date WHERE id = _idmanifiesto;

	elsif ( tipo_anticipo = 'R' ) then

		--select into ReturnFechaPago etes.SP_FechaPagarFintra(1, 'R');
		select into ReturnFechaPago * from etes.SP_FechaPagarFintra(_idmanifiesto, 'R') as (fechacorrida varchar, fechapagofintra varchar);
		raise notice 'FECHApago-r: %',ReturnFechaPago;

		UPDATE etes.manifiesto_reanticipos SET valor_descuentos_fintra = TotalDesctos, valor_desembolsar = ValorNetoAnticipo-ManifiestoCarga.valor_comision_intermediario, fecha_corrida = ReturnFechaPago.fechacorrida::date,fecha_pago_fintra = ReturnFechaPago.fechapagofintra::date WHERE id = _idmanifiesto;

	end if;


	RETURN retorno;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.sp_descuentosfintra(integer, character varying)
  OWNER TO postgres;
