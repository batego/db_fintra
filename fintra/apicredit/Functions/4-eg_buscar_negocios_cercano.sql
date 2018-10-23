-- Function: apicredit.eg_buscar_negocios_cercano(numeric, numeric, numeric, numeric)

-- DROP FUNCTION apicredit.eg_buscar_negocios_cercano(numeric, numeric, numeric, numeric);

CREATE OR REPLACE FUNCTION apicredit.eg_buscar_negocios_cercano(_baselat numeric, _baselng numeric, lat2 numeric, lng2 numeric)
  RETURNS text AS
$BODY$
DECLARE


  radioTierra numeric := 6371;
  dLat numeric:=0;
  dLng numeric:=0;
  sindLat numeric:=0;
  sindLng numeric:=0;
  va1 numeric:=0;
  va2 numeric:=0;
  distancia numeric:=0;

 BEGIN


        dLat := radians(lat2 - _baselat);
        dLng := radians(lng2 - _baselng);
        sindLat :=sin(dLat / 2);
        sindLng :=sin(dLng / 2);
        va1 := power(sindLat, 2) + power(sindLng, 2)
                * cos(radians(_baselat)) * cos(radians(lat2));

        va2 := 2 * atan2(sqrt(va1), sqrt(1 - va1));
        distancia := radioTierra * va2;

	raise notice 'Kilometros: % Metros : % Pies : %',round(distancia,3),round(distancia*1000,2) ,round(distancia*1000,2) * 3.2808;

RETURN round(distancia,3);

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION apicredit.eg_buscar_negocios_cercano(numeric, numeric, numeric, numeric)
  OWNER TO postgres;
