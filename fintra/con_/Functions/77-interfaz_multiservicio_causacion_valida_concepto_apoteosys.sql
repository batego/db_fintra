-- Function: con.interfaz_multiservicio_causacion_valida_concepto_apoteosys(integer)

-- DROP FUNCTION con.interfaz_multiservicio_causacion_valida_concepto_apoteosys(integer);

CREATE OR REPLACE FUNCTION con.interfaz_multiservicio_causacion_valida_concepto_apoteosys(_mc_____numero____b integer)
  RETURNS text AS
$BODY$

DECLARE
	validacion_ boolean:=false;
	SECUENCIA_GEN INTEGER;

BEGIN

	select
		into validacion_
		count(b.MC_____CODIGO____CD_____B)>1
	from (select
			MC_____CODIGO____CD_____B
		from
			con.mc_cd_endoso____
		where
			procesado='N' and
			MC_____CODIGO____TD_____B='DIAR' and
			MC_____CODIGO____CD_____B in('CIFN','CIFM') and
			mc_____numero____b=_mc_____numero____b
	group by MC_____CODIGO____CD_____B) as b;

	IF(validacion_=true)THEN
		SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_EGRESO_APOTEOSYS');

		update
			con.mc_cd_endoso____
		set
			mc_____numero____b=SECUENCIA_GEN
		where
			MC_____CODIGO____TD_____B='DIAR' and
			MC_____CODIGO____CD_____B in('CIFN') and
			mc_____numero____b=_mc_____numero____b;

	End if;

return 'ACTUALIZADO-CIFN: '||SECUENCIA_GEN;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_multiservicio_causacion_valida_concepto_apoteosys(integer)
  OWNER TO postgres;
