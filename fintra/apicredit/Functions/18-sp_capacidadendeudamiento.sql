-- Function: apicredit.sp_capacidadendeudamiento(integer)

-- DROP FUNCTION apicredit.sp_capacidadendeudamiento(integer);

CREATE OR REPLACE FUNCTION apicredit.sp_capacidadendeudamiento(_num_sol integer)
  RETURNS text AS
$BODY$

DECLARE

	EndeudamientoSol record;
	RsPreSolicitud record;
	--Rsdna record;

	PorcEndeudamiento numeric := 0;
	GastosPersonales numeric := 0;
	EndeudamMasCuota numeric := 0;
	EndeudamSinCuota numeric := 0;
	MontoEndeudamiento numeric := 0;
	MontoSugerido numeric := 0;
	CuotaSugerida numeric := 0;
	GastGeneral numeric := 0.40;

	NitEmpresaConsultora varchar := '';

	Respuesta varchar := '0%';

BEGIN

	select into RsPreSolicitud * from apicredit.pre_solicitudes_creditos where numero_solicitud = _num_sol;

	--select into Rsdna * from documentos_neg_aceptado where cod_neg = (select cod_neg from solicitud_aval where numero_solicitud = _num_sol) and item = '1';
	--select into Rsdna *, valor_cuota as valor from apicredit.pre_liquidacion_creditos where numero_solicitud = _num_sol and cuota = '1';
	--select * from documentos_neg_aceptado where cod_neg = (select cod_neg from solicitud_aval where numero_solicitud = 81815);

	IF ( RsPreSolicitud.entidad = 'FENALCO_BOL' ) THEN
		NitEmpresaConsultora = '8904800244';
	ELSIF ( RsPreSolicitud.entidad = 'FENALCO_ATL' ) THEN
		NitEmpresaConsultora = '8901009858';
	ELSE
		NitEmpresaConsultora = '8020220161';
	END IF;
	--raise notice 'entidad: %, identificacion: %', RsPreSolicitud.entidad, RsPreSolicitud.identificacion;

	SELECT INTO EndeudamientoSol
		sum(cupo_valor_inicial) as endeudamiento_total,
		sum(saldo_actual) as endeudamiento_actual,
		sum(saldo_mora) as saldo_mora,
		sum(cuota) as valor_cuota
	FROM (
		(
		select
			coalesce(sum(vcc.valor_inicial),0) as cupo_valor_inicial,
			coalesce(sum(vcc.saldo_actual),0) as saldo_actual,
			coalesce(sum(vcc.saldo_mora),0) as saldo_mora,
			coalesce(sum(vcc.cuota),0) as cuota
		from  wsdc.cuenta_cartera cca
		left join wsdc.codigo ce on ce.web_service='H' and ce.tabla='cod_estado' and ce.codigo=cca.estado
		left join wsdc.codigo cg on cg.web_service='H' and cg.tabla='garante_cartera' and cg.codigo=cca.garante
		left join wsdc.codigo ct on ct.web_service='H' and ct.tabla='tipo_cuenta_cartera' and ct.codigo=cca.tipo_cuenta
		left join  wsdc.valor vcc on vcc.id_padre = cca.id and vcc.tipo_padre='CCA'
		where
		    ce.descripcion='Vigente' and
		    cca.tipo_identificacion=1 and
		    cca.identificacion = RsPreSolicitud.identificacion
		    and cca.nit_empresa=NitEmpresaConsultora
		)
		union all
		(
		select
			coalesce(sum(vtc.cupo),0) as cupo_valor_inicial,
			coalesce(sum(vtc.saldo_actual),0) as saldo_actual,
			coalesce(sum(vtc.saldo_mora),0) as saldo_mora,
			coalesce(sum(vtc.cuota),0) as cuota
		from wsdc.tarjeta_credito tc
		left join wsdc.codigo c on c.web_service='H' and c.tabla='cod_estado' and c.codigo=tc.estado
		left join  wsdc.valor vtc on vtc.id_padre = tc.id and vtc.tipo_padre='TCR'
		where
		c.descripcion = 'Vigente' and
		tc.amparada='f' and
		tc.tipo_identificacion=1 and
		tc.identificacion = RsPreSolicitud.identificacion and tc.nit_empresa=NitEmpresaConsultora
		)
	) c;

	--raise notice 'endeudamiento_actual: %, ingresos_usuario: %', EndeudamientoSol.valor_cuota, RsPresolicitud.ingresos_usuario;

	GastosPersonales = round(RsPreSolicitud.ingresos_usuario::numeric * GastGeneral);
	--raise notice 'GastosPersonales: %, ValorCuota: %', GastosPersonales, RsPresolicitud.valor_cuota;

	EndeudamMasCuota = EndeudamientoSol.valor_cuota::numeric + RsPreSolicitud.valor_cuota::numeric + GastosPersonales;
	--raise notice 'EndeudamMasCuota: %', EndeudamMasCuota;
	--EndeudamMasCuota = EndeudamientoSol.valor_cuota::numeric + Rsdna.valor::numeric + GastosPersonales;

	EndeudamSinCuota = EndeudamientoSol.valor_cuota::numeric + GastosPersonales;

	PorcEndeudamiento = round((EndeudamMasCuota::numeric / RsPreSolicitud.ingresos_usuario::numeric) * 100);

	--raise notice 'EndeudamMasCuota: %, PorcEndeudamiento: %', EndeudamMasCuota, PorcEndeudamiento;
	--raise notice 'EndeudamientoHDC: %, Cuota: %, GastosPersonales: %', EndeudamientoSol.valor_cuota, Rsdna.valor::numeric, GastosPersonales;

	Respuesta = PorcEndeudamiento::varchar || '%';

	return Respuesta;


end;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION apicredit.sp_capacidadendeudamiento(integer)
  OWNER TO postgres;
