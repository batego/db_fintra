-- Function: etes.sp_fechapagarfintra(integer, character varying)

-- DROP FUNCTION etes.sp_fechapagarfintra(integer, character varying);

CREATE OR REPLACE FUNCTION etes.sp_fechapagarfintra(_idmanifiesto integer, _tipo_anticipo character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE

	ManifiestoCarga record;
	DesctosPlanilla record;

	ValorNetoAnticipo numeric = 0;
	PercDescto numeric = 0;
	ValorDescto numeric = 0;
	TotalDesctos numeric = 0;

	IdManifiestoCarga integer := 0;
	_IsReanticipo varchar = '';
	FechaPagoConvenido varchar;
	DiasConvenidoPago numeric := 0;

	retorno varchar;

BEGIN

	--select into FechaPagoConvenido '2015-08-24 00:00:00'::date; -- + interval '4 day';
	--retorno = FechaPagoConvenido;


----3.  Poner las fechas del rango actual para actualizar *-*
	--select * from etes.manifiesto_carga order by id;
	--select fecha_corrida, fecha_pago_fintra, * from etes.manifiesto_carga where creation_date::date between '2018-07-02' and '2018-07-04' order by id
	--*--update etes.manifiesto_carga set fecha_corrida = '2018-07-05 00:00:00', fecha_pago_fintra = '2018-07-05 00:00:00' where creation_date::date between '2018-07-02' and '2018-07-04';

	--select * from etes.manifiesto_reanticipos order by id
	--select fecha_corrida, fecha_pago_fintra, * from etes.manifiesto_reanticipos where creation_date::date between  '2018-07-02' and '2018-07-04' order by id
	---*--update etes.manifiesto_reanticipos set fecha_corrida = '2018-05-17 00:00:00', fecha_pago_fintra = '2018-05-18 00:00:00' where creation_date::date between  '2018-07-02' and '2018-07-04';


	/*
	select documento, referencia_1, referencia_2, (select fecha_corrida from etes.manifiesto_carga where planilla = con.factura.referencia_2) as fecha_corrida from con.factura where referencia_2 in (select planilla from etes.manifiesto_carga where creation_date::date between '2017-10-12' and '2017-10-15')


----2.  Poner las fechas del rango actual para actualizar
	select * from con.factura
	--update con.factura set referencia_1 = '2018-07-05 00:00:00'
	where documento in (
		select documento from con.factura where referencia_2 in (select planilla from etes.manifiesto_carga where creation_date::date between '2018-08-23' and '2018-08-26')
		union all
		select documento from con.factura where referencia_2 in (select planilla from etes.manifiesto_reanticipos where creation_date::date between   '2018-08-23' and '2018-08-26')
	)
	*/

----1.  Poner las fechas correctas del proximo rango
	FOR ManifiestoCarga IN
		select
		''::varchar as fechacorrida,
		''::varchar as fechapagofintra
	LOOP

		ManifiestoCarga.fechacorrida = '2018-08-27 00:00:00'::date;
		ManifiestoCarga.fechapagofintra = '2018-08-31 00:00:00'::date;

		RETURN NEXT ManifiestoCarga;

	END LOOP;


END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.sp_fechapagarfintra(integer, character varying)
  OWNER TO postgres;
