-- Function: valida_cuota_libranza(integer, numeric)

-- DROP FUNCTION valida_cuota_libranza(integer, numeric);

CREATE OR REPLACE FUNCTION valida_cuota_libranza(_num_solicitud integer, _monto_solicitado numeric)
  RETURNS text AS
$BODY$
Declare
 _solicitud RECORD;
 _vlr_cuota numeric := 0;
 _vlr_seg numeric := 0;
 _vlr_extra numeric := 0;
 _vlr_total numeric := 0;
 _respuesta text;
Begin

select
  into _solicitud
	 s.numero_solicitud, s.estado_sol, f.plazo
	, f.factor_seguro, f.salario, f.descuento_ley, f.extraprima
	, (c.periodo_gracia+1) as periodo_gracia
	, (pow(1+(c.tasa/100),1/12::numeric)-1)::numeric(10,7) as tasa
	, ((f.salario*(1-(f.descuento_ley/100))*c.porcentaje_descuento/100) - c.colchon) ::numeric(16,2) as monto_consumible
from solicitud_aval s
inner join solicitud_persona p
	on p.tipo = 'S' and p.numero_solicitud = s.numero_solicitud and p.reg_status != 'A'
inner join filtro_libranza f
	on f.identificacion = p.identificacion and s.creation_date::date = f.creation_date::date
	and f.reg_status != 'A'
inner join configuracion_libranza c
	on c.id = f.id_configuracion_libranza
Where s.reg_status != 'A' and s.numero_solicitud = _num_solicitud;

RAISE NOTICE 'solicitud: %', _solicitud;

--(valor+(valor*tasa*(per_gracia+1))+(valor*fac_seg*(per_gracia+1)))*(tasa/(1-Math.pow((1+tasa),-plazo)))
_vlr_cuota :=  ((_monto_solicitado
		+(_monto_solicitado*_solicitud.tasa*_solicitud.periodo_gracia)
		+(_monto_solicitado*_solicitud.factor_seguro*_solicitud.periodo_gracia))
		*(_solicitud.tasa/(1-pow(1+_solicitud.tasa,-_solicitud.plazo)))) ::numeric(16,2);

_vlr_seg := (_monto_solicitado * _solicitud.factor_seguro) ::numeric(16,2);
_vlr_extra := (_vlr_seg * (_solicitud.extraprima/100)) ::numeric(16,2);
_vlr_total := _vlr_cuota +_vlr_seg + _vlr_extra;

RAISE NOTICE 'valores % cuota : % :: % :: %', _solicitud.plazo,  _vlr_cuota,_vlr_seg,_vlr_extra;

  if _solicitud.estado_sol = 'R' Then
	_respuesta := 'RECHAZADO';
  elsif _solicitud Is Null or _solicitud.monto_consumible < _vlr_total Then
	_respuesta := 'NOAPROBADO';
  else
	_respuesta := 'OK';
  end if;
 return _respuesta;
End
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION valida_cuota_libranza(integer, numeric)
  OWNER TO postgres;
