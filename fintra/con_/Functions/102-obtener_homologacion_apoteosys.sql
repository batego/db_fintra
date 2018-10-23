-- Function: con.obtener_homologacion_apoteosys(character varying, character varying, character varying, character varying, integer)

-- DROP FUNCTION con.obtener_homologacion_apoteosys(character varying, character varying, character varying, character varying, integer);

CREATE OR REPLACE FUNCTION con.obtener_homologacion_apoteosys(character varying, character varying, character varying, character varying, integer)
  RETURNS text AS
$BODY$DECLARE

proceso_ ALIAS FOR $1;
tipo_doc_fintra_ ALIAS FOR $2;
cuenta_fintra_ ALIAS FOR $3;
agencia_fintra_ ALIAS FOR $4;
tipo ALIAS FOR $5;
cuenta varchar:='';
ccosto varchar:='';
documento_sop_ varchar:='';
numero_doc_sop_ varchar:='';
numero_venc_ varchar:='';
fecha_emision_ varchar:='';
fecha_vencimiento_ varchar:='';

  dato TEXT;

  BEGIN

	select
	into
		cuenta,ccosto, documento_sop_, numero_doc_sop_, numero_venc_, fecha_emision_, fecha_vencimiento_
		cuenta_apo, centro_costo_apo, documento_sop, numero_doc_sop, numero_venc, fecha_emision, fecha_vencimiento
	from
		con.homolacion_interface
	where
		proceso=proceso_ and
		tipo_doc_fintra=tipo_doc_fintra_ and
		cuenta_fintra=cuenta_fintra_ and
		agencia_fintra like coalesce(agencia_fintra_,'%');

	if(tipo=1)then
		dato:=cuenta;
	elsif(tipo=2)then
		dato:=ccosto;
	elsif(tipo=3)then
		dato:=documento_sop_;
	elsif(tipo=4)then
		dato:=numero_doc_sop_;
	elsif(tipo=5)then
		dato:=numero_venc_;
	elsif(tipo=6)then
		dato:=fecha_emision_;
	else
		dato:=fecha_vencimiento_;
	End If;

 RETURN dato;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.obtener_homologacion_apoteosys(character varying, character varying, character varying, character varying, integer)
  OWNER TO postgres;
