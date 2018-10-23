-- Function: dv_negocioscartas(character varying, character varying)

-- DROP FUNCTION dv_negocioscartas(character varying, character varying);

CREATE OR REPLACE FUNCTION dv_negocioscartas(_linea_negocio character varying, _estados character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE
  _listaNegocios RECORD;
  _funcion RECORD;


  CarteraGeneral record;
  FechaCortePeriodo varchar;
  PeriodoTramo numeric;
  periodoasignacion numeric := replace(substring(now()::date,1,7),'-','');
  VencimientoMayor varchar;

BEGIN

  FOR _listaNegocios IN (
	SELECT
	un.descripcion AS linea_negocio,
	''::varchar as convenio,
	''::varchar AS rango,
	''::varchar AS vencimiento_mayor,
	sp.identificacion AS cedula,
	cl.nombre AS nombre,
	sp.primer_nombre,
	--(cl.telefono||' - '||cl.telefono1||' - '||cl.celular)::text AS telefonos,
	(cli.telcontacto)::text AS telefonos,
	cl.direccion,
	cl.barrio,
	(SELECT nomciu FROM ciudad WHERE ciudad.codciu = cl.codciu) AS ciudad,
	(SELECT department_name FROM estado WHERE department_code = cl.coddpto) AS departamento,
	--(cl.e_mail||'; '||cl.e_mail2)::varchar AS correo_electronico,
	sp.email AS correo_electronico,
	cd.tipo AS tipo_cod,
	cd.identificacion AS cedula_cod,
	cd.nombre AS nombre_cod,
	cd.telefonos AS telefono_cod,
	cd.direccion AS direccion_cod,
	cd.barrio AS barrio_cod,
	cd.ciudad AS ciudad_cod,
	cd.departamento AS departamento_cod,
	cd.correo_electronico AS correo_cod,
	-----------------------PRINCIAL-----------------------------
	neg.cod_neg AS negocios_principal,
	''::varchar AS factura_principal,
	''::varchar AS cuota_principal,
	''::varchar AS fecha_vencimiento_principal,
	''::varchar AS dia_vencimiento_principal,
	''::varchar AS dias_mora_principal,
	''::varchar AS dias_mora_foto,
	''::varchar AS estado_principal,
	0::numeric AS valor_factura_principal,
	0::numeric AS valor_abono_principal,
	0::numeric AS valor_saldo_principal,
	0::numeric AS valor_capital_principal,
	0::numeric AS valor_interes_principal,
	0::numeric AS valor_ixm_principal,
	0::numeric AS valor_gac_principal,
	0::numeric AS total_principal,
	----------------------AVAL---------------------------
	''::varchar AS negocios_aval,
	''::varchar AS factura_aval,
	''::varchar AS cuota_aval,
	''::varchar AS fecha_vencimiento_aval,
	''::varchar AS dias_mora_aval,
	''::varchar AS estado_aval,
	0::numeric AS valor_factura_aval,
	0::numeric AS valor_abono_aval,
	0::numeric AS valor_saldo_aval,
	0::numeric AS valor_capital_aval,
	0::numeric AS valor_interes_aval,
	0::numeric AS valor_ixm_aval,
	0::numeric AS valor_gac_aval,
	0::numeric AS total_aval,
	--------------------SEGURO--------------------------------
	''::varchar AS negocios_seguro,
	''::varchar AS factura_seguro,
	''::varchar AS cuota_seguro,
	''::varchar AS fecha_vencimiento_seguro,
	''::varchar AS dias_mora_seguro,
	''::varchar AS estado_seguro,
	0::numeric AS valor_factura_seguro,
	0::numeric AS valor_abono_seguro,
	0::numeric AS valor_saldo_seguro,
	0::numeric AS valor_capital_seguro,
	0::numeric AS valor_interes_seguro,
	0::numeric AS valor_ixm_seguro,
	0::numeric AS valor_gac_seguro,
	0::numeric AS total_seguro,
	---------------------GPS-------------------------------
	''::varchar AS negocios_gps,
	''::varchar AS factura_gps,
	''::varchar AS cuota_gps,
	''::varchar AS fecha_vencimiento_gps,
	''::varchar AS dias_mora_gps,
	''::varchar AS estado_gps,
	0::numeric AS valor_factura_gps,
	0::numeric AS valor_abono_gps,
	0::numeric AS valor_saldo_gps,
	0::numeric AS valor_capital_gps,
	0::numeric AS valor_interes_gps,
	0::numeric AS valor_ixm_gps,
	0::numeric AS valor_gac_gps,
	0::numeric AS total_gps
	FROM negocios neg
	INNER JOIN solicitud_aval sa ON neg.cod_neg = sa.cod_neg
	INNER JOIN solicitud_persona sp ON sa.numero_solicitud = sp.numero_solicitud AND sp.tipo='S'
	INNER JOIN nit cl ON cl.cedula = sp.identificacion
	INNER JOIN cliente cli ON cli.nit=cl.cedula
	INNER JOIN (
		SELECT
		sola.cod_neg AS cod_neg,
		CASE WHEN solc.tipo = 'C' THEN 'CODEUDOR'
		     WHEN sole.tipo = 'E' THEN 'ESTUDIANTE'
		     WHEN soly.tipo = 'S' THEN 'CONYUGUE'
		     ELSE ''
		END AS tipo,
		COALESCE(solc.nombre,sole.nombre,(soly.primer_apellido_cony||' '||soly.primer_nombre_cony)) AS nombre,
		COALESCE(solc.identificacion,sole.identificacion,soly.id_cony) AS identificacion,
		COALESCE(solc.telefono||' - '||solc.celular, sole.telefono||' - '||sole.celular, soly.telefono_cony||' - '||soly.celular_cony)::varchar AS telefonos,
		COALESCE(solc.direccion,sole.direccion,soly.direccion_cony) AS direccion,
		COALESCE(solc.barrio,sole.barrio,'') AS barrio,
		(SELECT nomciu FROM ciudad WHERE ciudad.codciu = COALESCE(solc.ciudad,sole.ciudad,'')) AS ciudad,
		(SELECT department_name FROM estado WHERE department_code = COALESCE(solc.departamento,sole.departamento,'')) AS departamento,
		--COALESCE(solc.email,sole.email,soly.email_cony) AS correo_electronico
		COALESCE(soly.email,solc.email,sole.email) AS correo_electronico
		FROM solicitud_aval sola
		LEFT JOIN solicitud_persona solc ON sola.numero_solicitud = solc.numero_solicitud AND solc.tipo = 'C'
		LEFT JOIN solicitud_persona sole ON sola.numero_solicitud = sole.numero_solicitud AND sole.tipo = 'E'
		LEFT JOIN solicitud_persona soly ON sola.numero_solicitud = soly.numero_solicitud AND soly.tipo = 'S'
	) cd ON cd.cod_neg = neg.cod_neg
	INNER JOIN unidad_negocio un ON (id = sp_uneg_negocio(neg.cod_neg) AND un.descripcion ~* trim(_linea_negocio)
	)
	WHERE (neg.negocio_rel = '' AND neg.negocio_rel_seguro='' AND neg.negocio_rel_gps = '')
	--and neg.cod_neg ='FA05800'
	and neg.periodo between '201701' and '201701'
  ) LOOP

	RAISE NOTICE '%',_listaNegocios.negocios_principal;

    if ( substring(periodoasignacion,5) = '01' ) then
			PeriodoTramo = substring(periodoasignacion,1,4)::numeric-1||'12';
		else
			PeriodoTramo = periodoasignacion::numeric - 1;
		end if;

	select into FechaCortePeriodo to_char(to_timestamp(substring(PeriodoTramo,1,4)::numeric || '-' || to_char(substring(PeriodoTramo,5,2)::numeric,'FM00') || '-01', 'YYYY-MM-DD') + INTERVAL '1 month' - INTERVAL '1 days', 'YYYY-MM-DD');


	FOR CarteraGeneral IN

			(select negasoc::varchar as negocio,
			       --nit::varchar as cedula,
			       --''::varchar as nombre_cliente,
			       --num_doc_fen::varchar as cuota,
			       --documento::varchar,
			       --fecha_vencimiento::date,
			       (FechaCortePeriodo::date-fecha_vencimiento)::varchar as dias_vencidos,
			       co.nombre as convenio
			       --''::varchar as vencimiento_mayor,
			       --'-'::varchar as status,
			       --valor_saldo::numeric,
			       --0::numeric as debido_cobrar,
			       --0::numeric as interes_mora,
			       --0::numeric as gasto_cobranza
			from con.foto_cartera f
			inner join negocios n on n.cod_neg=f.negasoc
			inner join convenios co on co.id_convenio=n.id_convenio
			where negasoc != '' --CarteraGeneral.negocio
			and periodo_lote = PeriodoAsignacion
			and f.reg_status = ''
			--and descripcion != 'CXC AVAL'
			and substring(documento,1,2) not in ('CP','FF','DF')
			and valor_saldo > 0
			and replace(substring(f.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoAsignacion
			and f.fecha_vencimiento < now()
			and num_doc_fen not like '%-%' and num_doc_fen not like '%A%' and num_doc_fen not like '%F%'
			and num_doc_fen not like '%G%' and num_doc_fen not like '%I%' and num_doc_fen not like '%K%'
			and num_doc_fen not like '%L%' and  num_doc_fen != ''
			and negasoc = _listaNegocios.negocios_principal
			--and nit = '72285695'
			and negocio_rel =''
			and estado_neg = 'T'
			and num_aval != ''
			--and num_fac_venta_aval != ''
			--and negasoc IN ('FA22251','FA15040','FA00158','FA00159','NG20303')
			order by num_doc_fen::numeric,f.creation_date)

		LOOP

		_listaNegocios.dias_mora_foto = CarteraGeneral.dias_vencidos;
		_listaNegocios.convenio = CarteraGeneral.convenio;

		END LOOP;


    FOR _funcion IN (
    SELECT
    documento,cuota,fecha_vencimiento,substring(fecha_vencimiento,9,2) AS dia,dias_mora,estado,valor_factura,valor_abono,valor_saldo,valor_saldo_capital,valor_saldo_interes,IxM,GaC,suma_saldos
    FROM SP_EstadoCuentaNegocioCartas(_listaNegocios.negocios_principal, _estados::integer) as factura (documento varchar,negocio varchar,cuota varchar,fecha_vencimiento date,dias_mora numeric,estado varchar,tipo_negocio varchar,valor_factura numeric, valor_abono numeric,valor_saldo numeric,valor_unitario_capital numeric,valor_unitario_interes numeric,valor_saldo_capital numeric,valor_saldo_interes numeric,IxM numeric,GaC numeric,suma_saldos numeric)
    )
    LOOP
	_listaNegocios.factura_principal = _funcion.documento;
	_listaNegocios.cuota_principal = _funcion.cuota;
	_listaNegocios.fecha_vencimiento_principal = _funcion.fecha_vencimiento;
	_listaNegocios.dia_vencimiento_principal = _funcion.dia;

	IF _listaNegocios.dias_mora_principal = '' THEN
	    _listaNegocios.dias_mora_principal = _funcion.dias_mora;
	END IF;

	_listaNegocios.estado_principal = _funcion.estado;
	RAISE NOTICE '%',_listaNegocios.estado_principal;
	_listaNegocios.valor_factura_principal = _listaNegocios.valor_factura_principal + _funcion.valor_factura;
	_listaNegocios.valor_abono_principal = _listaNegocios.valor_abono_principal + _funcion.valor_abono;
	_listaNegocios.valor_saldo_principal = _listaNegocios.valor_saldo_principal + _funcion.valor_saldo;
	_listaNegocios.valor_capital_principal = _listaNegocios.valor_capital_principal + _funcion.valor_saldo_capital;
	_listaNegocios.valor_interes_principal = _listaNegocios.valor_interes_principal + _funcion.valor_saldo_interes;
	_listaNegocios.valor_ixm_principal = _listaNegocios.valor_ixm_principal + _funcion.IxM;
	_listaNegocios.valor_gac_principal = _listaNegocios.valor_gac_principal + _funcion.GaC;
	_listaNegocios.total_principal = _listaNegocios.total_principal + _funcion.suma_saldos;
    END LOOP;

    IF (_listaNegocios.total_principal > 0 ) AND (_estados = '2' OR (_estados = '1' AND _listaNegocios.estado_principal = 'CORRIENTE')) THEN
	SELECT INTO _listaNegocios.rango
		CASE WHEN _listaNegocios.dias_mora_principal::integer >= 365 THEN 'MAYOR A 1 ANIO'
		WHEN _listaNegocios.dias_mora_principal::integer >= 181 THEN 'ENTRE 180 Y 360'
		WHEN _listaNegocios.dias_mora_principal::integer >= 121 THEN 'ENTRE 121 Y 180'
		WHEN _listaNegocios.dias_mora_principal::integer >= 91 THEN 'ENTRE 91 Y 120'
		WHEN _listaNegocios.dias_mora_principal::integer >= 61 THEN 'ENTRE 61 Y 90'
		WHEN _listaNegocios.dias_mora_principal::integer >= 31 THEN 'ENTRE 31 Y 60'
		WHEN _listaNegocios.dias_mora_principal::integer >= 1 THEN 'ENTRE 1 A 30'
		WHEN _listaNegocios.dias_mora_principal::integer <= 0 THEN 'CORRIENTE'
		ELSE '0' END;

	SELECT INTO VencimientoMayor
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
				 --SELECT FechaCortePeriodo::date-fecha_vencimiento as maxdia
				 FROM con.foto_cartera fra
				 WHERE fra.dstrct = 'FINV'
					  AND fra.valor_saldo > 0
					  AND fra.reg_status = ''
					  AND fra.negasoc = CarteraGeneral.negocio
					  --AND fra.documento = CarteraGeneral.documento
					  AND fra.tipo_documento = 'FAC'
					  AND fra.periodo_lote = PeriodoAsignacion
				 GROUP BY negasoc

			) tabla2;

			_listaNegocios.vencimiento_mayor = VencimientoMayor;

	--AVAL
	SELECT INTO _listaNegocios.negocios_aval cod_neg FROM negocios where negocio_rel=_listaNegocios.negocios_principal limit 1;
	RAISE NOTICE 'aval %',_listaNegocios.negocios_aval;
	IF FOUND THEN
	    SELECT INTO
	    --_listaNegocios.factura_aval,
	    _listaNegocios.cuota_aval,
	    _listaNegocios.fecha_vencimiento_aval,
	    _listaNegocios.dias_mora_aval,
	    --_listaNegocios.estado_aval,
	    _listaNegocios.valor_factura_aval,
	    _listaNegocios.valor_abono_aval,
	    _listaNegocios.valor_saldo_aval,
	    _listaNegocios.valor_capital_aval,
	    _listaNegocios.valor_interes_aval,
	    _listaNegocios.valor_ixm_aval,
	    _listaNegocios.valor_gac_aval,
	    _listaNegocios.total_aval

	    MAX(cuota),MAX(fecha_vencimiento),MAX(dias_mora),SUM(valor_factura),SUM(valor_abono),SUM(valor_saldo),SUM(valor_saldo_capital),SUM(valor_saldo_interes),SUM(IxM),SUM(GaC),SUM(suma_saldos)
	    FROM SP_EstadoCuentaNegocioCartas(_listaNegocios.negocios_aval, _estados::integer) as factura (documento varchar,negocio varchar,cuota varchar,fecha_vencimiento date,dias_mora numeric,estado varchar,
	    tipo_negocio varchar,valor_factura numeric, valor_abono numeric,valor_saldo numeric,valor_unitario_capital numeric,valor_unitario_interes numeric,valor_saldo_capital numeric,valor_saldo_interes numeric,IxM numeric,GaC numeric,suma_saldos numeric);

	END IF;
	--SEGURO
	SELECT INTO _listaNegocios.negocios_seguro cod_neg FROM negocios where negocio_rel_seguro=_listaNegocios.negocios_principal limit 1;
	RAISE NOTICE 'seguro %',_listaNegocios.negocios_seguro;
	IF FOUND THEN
	    SELECT INTO
	    --_listaNegocios.factura_seguro,
	    _listaNegocios.cuota_seguro,
	    _listaNegocios.fecha_vencimiento_seguro,
	    _listaNegocios.dias_mora_seguro,
	    --_listaNegocios.estado_seguro,
	    _listaNegocios.valor_factura_seguro,
	    _listaNegocios.valor_abono_seguro,
	    _listaNegocios.valor_saldo_seguro,
	    _listaNegocios.valor_capital_seguro,
	    _listaNegocios.valor_interes_seguro,
	    _listaNegocios.valor_ixm_seguro,
	    _listaNegocios.valor_gac_seguro,
	    _listaNegocios.total_seguro

	     MAX(cuota),MAX(fecha_vencimiento),MAX(dias_mora),SUM(valor_factura),SUM(valor_abono),SUM(valor_saldo),SUM(valor_saldo_capital),SUM(valor_saldo_interes),SUM(IxM),SUM(GaC),SUM(suma_saldos)
	    FROM SP_EstadoCuentaNegocioCartas(_listaNegocios.negocios_seguro, _estados::integer) as factura (documento varchar,negocio varchar,cuota varchar,fecha_vencimiento date,dias_mora numeric,estado varchar,
	    tipo_negocio varchar,valor_factura numeric, valor_abono numeric,valor_saldo numeric,valor_unitario_capital numeric,valor_unitario_interes numeric,valor_saldo_capital numeric,valor_saldo_interes numeric,IxM numeric,GaC numeric,suma_saldos numeric);

	END IF;
	--GPS
	SELECT INTO _listaNegocios.negocios_gps cod_neg FROM negocios where negocio_rel_gps=_listaNegocios.negocios_principal limit 1;
	RAISE NOTICE 'gps %',_listaNegocios.negocios_gps;
	IF FOUND THEN
	    SELECT INTO
	    --_listaNegocios.factura_gps,
	    _listaNegocios.cuota_gps,
	    _listaNegocios.fecha_vencimiento_gps,
	    _listaNegocios.dias_mora_gps,
	    --_listaNegocios.estado_gps,
	    _listaNegocios.valor_factura_gps,
	    _listaNegocios.valor_abono_gps,
	    _listaNegocios.valor_saldo_gps,
	    _listaNegocios.valor_capital_gps,
	    _listaNegocios.valor_interes_gps,
	    _listaNegocios.valor_ixm_gps,
	    _listaNegocios.valor_gac_gps,
	    _listaNegocios.total_gps

	    MAX(cuota),MAX(fecha_vencimiento),MAX(dias_mora),SUM(valor_factura),SUM(valor_abono),SUM(valor_saldo),SUM(valor_saldo_capital),SUM(valor_saldo_interes),SUM(IxM),SUM(GaC),SUM(suma_saldos)
	    FROM SP_EstadoCuentaNegocioCartas(_listaNegocios.negocios_gps, _estados::integer) as factura (documento varchar,negocio varchar,cuota varchar,fecha_vencimiento date,dias_mora numeric,estado varchar,
	    tipo_negocio varchar,valor_factura numeric, valor_abono numeric,valor_saldo numeric,valor_unitario_capital numeric,valor_unitario_interes numeric,valor_saldo_capital numeric,valor_saldo_interes numeric,IxM numeric,GaC numeric,suma_saldos numeric);
	END IF;

	RETURN NEXT _listaNegocios;
    END IF;
  END LOOP;

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION dv_negocioscartas(character varying, character varying)
  OWNER TO postgres;
