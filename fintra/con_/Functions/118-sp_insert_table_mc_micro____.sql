-- Function: con.sp_insert_table_mc_micro____(con.type_insert_mc)

-- DROP FUNCTION con.sp_insert_table_mc_micro____(con.type_insert_mc);

CREATE OR REPLACE FUNCTION con.sp_insert_table_mc_micro____(mctype con.type_insert_mc)
  RETURNS text AS
$BODY$

DECLARE

BEGIN

/*****************************************************
*INSERTA EN LA TABLA MC____ A PARTIR DE UN TYPE      *
*autor:@egonzalez				     *
*fecha: 2017-05-19				     *
******************************************************/

INSERT INTO con.mc_micro____(
            mc_____codigo____contab_b, mc_____codigo____td_____b, mc_____codigo____cd_____b,
            mc_____secuinte__dcd____b, mc_____fecha_____b, mc_____numero____b,
            mc_____secuinte__b, mc_____codigo____pf_____b, mc_____numero____period_b,
            mc_____codigo____pc_____b, mc_____codigo____cpc____b, mc_____codigo____pp_____det_b,
            mc_____codigo____pf_____det_b, mc_____codigo____rpppf__det_b,
            mc_____codigo____cu_____b, mc_____identific_tercer_b, mc_____codigo____refere_b,
            mc_____codigo____ds_____b, mc_____numdocsop_b, mc_____numevenc__b,
            mc_____numecuot__b, mc_____fechemis__b, mc_____fechvenc__b, mc_____fechdesc__b,
            mc_____valodesc__b, mc_____porcdesc__b, mc_____referenci_b, mc_____valoiva___b,
            mc_____valorete__b, mc_____base______b, mc_____fectascam_b, mc_____debmonori_b,
            mc_____cremonori_b, mc_____debmonloc_b, mc_____cremonloc_b, mc_____numunideb_b,
            mc_____numunicre_b, mc_____indtipmov_b, mc_____indmovrev_b, mc_____observaci_b,
            mc_____fechorcre_b, mc_____autocrea__b, mc_____fehoulmo__b, mc_____autultmod_b,
            mc_____usuaauto__b, mc_____codigo____tdsp___b, mc_____numero____dsp____b,
            mc_____codigo____pf_____dsp_b, mc_____baseorig__b, mc_____codigo____pf_____dif_b,
            mc_____numero____period_dif_b, mc_____innoejpr__b, mc_____prefprov__b,
            mc_____tipotran__b, mc_____numetran__b, mc_____codigo____client_b,
            mc_____codigo____dircli_b, mc_____codigo____sucurs_b, mc_____codigo____vended_b,
            mc_____codigo____cobrad_b, mc_____porcomven_b, mc_____porcomcob_b,
            mc_____valimpcon_b, tercer_codigo____tit____b, tercer_nombcort__b,
            tercer_nombexte__b, tercer_apellidos_b, tercer_codigo____tt_____b,
            tercer_direccion_b, tercer_codigo____ciudad_b, tercer_telefono1_b,
            tercer_tipogiro__b, tercer_codigo____ef_____b, tercer_sucursal__b,
            tercer_numecuen__b



            )
    VALUES (
            mctype.mc_____codigo____contab_b, mctype.mc_____codigo____td_____b, mctype.mc_____codigo____cd_____b,
            mctype.mc_____secuinte__dcd____b, mctype.mc_____fecha_____b, mctype.mc_____numero____b,
            mctype.mc_____secuinte__b, mctype.mc_____codigo____pf_____b, mctype.mc_____numero____period_b,
            mctype.mc_____codigo____pc_____b, mctype.mc_____codigo____cpc____b, mctype.mc_____codigo____pp_____det_b,
            mctype.mc_____codigo____pf_____det_b, mctype.mc_____codigo____rpppf__det_b,
            mctype.mc_____codigo____cu_____b, mctype.mc_____identific_tercer_b, mctype.mc_____codigo____refere_b,
            mctype.mc_____codigo____ds_____b, mctype.mc_____numdocsop_b, mctype.mc_____numevenc__b,
            mctype.mc_____numecuot__b, mctype.mc_____fechemis__b, mctype.mc_____fechvenc__b, mctype.mc_____fechdesc__b,
            mctype.mc_____valodesc__b, mctype.mc_____porcdesc__b, mctype.mc_____referenci_b, mctype.mc_____valoiva___b,
            mctype.mc_____valorete__b, mctype.mc_____base______b, mctype.mc_____fectascam_b, mctype.mc_____debmonori_b,
            mctype.mc_____cremonori_b, mctype.mc_____debmonloc_b, mctype.mc_____cremonloc_b, mctype.mc_____numunideb_b,
            mctype.mc_____numunicre_b, mctype.mc_____indtipmov_b, mctype.mc_____indmovrev_b, mctype.mc_____observaci_b,
            mctype.mc_____fechorcre_b, mctype.mc_____autocrea__b, mctype.mc_____fehoulmo__b, mctype.mc_____autultmod_b,
            mctype.mc_____usuaauto__b, mctype.mc_____codigo____tdsp___b, mctype.mc_____numero____dsp____b,
            mctype.mc_____codigo____pf_____dsp_b, mctype.mc_____baseorig__b, mctype.mc_____codigo____pf_____dif_b,
            mctype.mc_____numero____period_dif_b, mctype.mc_____innoejpr__b, mctype.mc_____prefprov__b,
            mctype.mc_____tipotran__b, mctype.mc_____numetran__b, mctype.mc_____codigo____client_b,
            mctype.mc_____codigo____dircli_b, mctype.mc_____codigo____sucurs_b, mctype.mc_____codigo____vended_b,
            mctype.mc_____codigo____cobrad_b, mctype.mc_____porcomven_b, mctype.mc_____porcomcob_b,
            mctype.mc_____valimpcon_b, mctype.tercer_codigo____tit____b, mctype.tercer_nombcort__b,
            mctype.tercer_nombexte__b, mctype.tercer_apellidos_b, mctype.tercer_codigo____tt_____b,
            mctype.tercer_direccion_b, mctype.tercer_codigo____ciudad_b, mctype.tercer_telefono1_b,
            mctype.tercer_tipogiro__b, mctype.tercer_codigo____ef_____b, mctype.tercer_sucursal__b,
            mctype.tercer_numecuen__b);

RETURN 'S';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.sp_insert_table_mc_micro____(con.type_insert_mc)
  OWNER TO postgres;
