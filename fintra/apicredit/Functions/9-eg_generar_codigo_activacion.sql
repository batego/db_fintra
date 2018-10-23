-- Function: apicredit.eg_generar_codigo_activacion(integer)

-- DROP FUNCTION apicredit.eg_generar_codigo_activacion(integer);

CREATE OR REPLACE FUNCTION apicredit.eg_generar_codigo_activacion(length integer)
  RETURNS text AS
$BODY$
DECLARE
  chars text[] := '{0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}';
  result text := '';
  i integer := 0;

BEGIN

  if length < 0 then
    raise exception 'longitud dada no puede ser inferior a 0';
  end if;
  for i in 1..length loop
    result := result || chars[1+random()*(array_upper(chars, 1)-1)];
  end loop;


RETURN result;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION apicredit.eg_generar_codigo_activacion(integer)
  OWNER TO postgres;
