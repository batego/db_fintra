-- Function: administrativo.mc_generacion_texto_fijo_efecty(character varying[])

-- DROP FUNCTION administrativo.mc_generacion_texto_fijo_efecty(character varying[]);

CREATE OR REPLACE FUNCTION administrativo.mc_generacion_texto_fijo_efecty(negocios_ character varying[])
  RETURNS text AS
$BODY$

declare

_texto text:='';
_cabecera varchar;
_detalleText varchar := '';
_foot varchar := '';
_num_registros numeric;
_total numeric := 0;
_info_negocio record;

begin
	_cabecera:='"01"|DOCUMENTO|TIPODOCUMENTO|VALOR|FECHA|NOMBRES|APELLIDO1|APELLIDO2|TELEFONO|COMENTARIOS|CODIGOPS|PIN\n';
	raise notice '_info_negocio %',array_to_string(negocios_, ',');
	for _info_negocio in
		SELECT
			cod_cli::numeric as cedula_cliente,
			case when nit.tipo_iden = 'CED' then 'CC'::varchar end as tipodoc,
			solpe.primer_nombre||' '||segundo_nombre as nombres,
			solpe.primer_apellido,
			solpe.segundo_apellido,
			solpe.celular,
			get_nombc(cod_cli) as nomcli,
			round(eg.vlr::numeric) as vr_desembolso,
			p.nombre_cuenta,
			p.cedula_cuenta,
			p.tipo_cuenta,
			n.cod_neg
		FROM fin.cxp_doc cxp
		inner join egreso eg on (eg.document_no = cxp.cheque)
		inner JOIN negocios n on (n.cod_neg = cxp.documento_relacionado AND cxp.reg_status = '' AND cxp.dstrct = 'FINV' AND cxp.tipo_documento = 'FAP')
		INNER JOIN proveedor p on (p.nit=cxp.proveedor)
		inner join nit on (nit.cedula = n.cod_cli)
		inner join solicitud_aval aval on (n.cod_neg = aval.cod_neg)
		inner join solicitud_persona solpe on (aval.numero_solicitud = solpe.numero_solicitud and solpe.tipo = 'S')
		WHERE
		--n.estado_neg in('A','PR')
		n.fecha_negocio>='2014-01-01'
		--and cxp.vlr_saldo_me > 0
		AND n.cod_neg=cxp.documento_relacionado
		and cxp.handle_code not in ('AV','BA','FJ','FQ','AY' )
		and n.cod_neg not like 'NG%'
		and referencia_3 != 'CHEQUE'
		and n.cod_neg = any(negocios_::varchar[])
		and cxp.cheque !=''
		ORDER BY n.fecha_ap,cxp.documento
	loop

		_total:= _total + _info_negocio.vr_desembolso;

		_detalleText := _detalleText || '"02"|"'||_info_negocio.cedula_cliente||'"|"'||_info_negocio.tipodoc||'"|'||_info_negocio.vr_desembolso||'|'||substring (now()::timestamp,1,19)||'|"'||_info_negocio.nombres||'"|"'
		||_info_negocio.primer_apellido||'"|"'||_info_negocio.segundo_apellido||'"|"'||_info_negocio.celular||'"|"DESEMBOLSOS"|"900911"|"PIN"\n';


	end loop;

	_foot:='"03"|'||array_upper(negocios_, 1)||'|'||_total||'|';

	_texto:=_cabecera||_detalleText||_foot;

	return _texto;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION administrativo.mc_generacion_texto_fijo_efecty(character varying[])
  OWNER TO postgres;
