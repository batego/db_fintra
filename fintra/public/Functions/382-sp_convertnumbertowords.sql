-- Function: sp_convertnumbertowords(numeric)

-- DROP FUNCTION sp_convertnumbertowords(numeric);

CREATE OR REPLACE FUNCTION sp_convertnumbertowords(num numeric)
  RETURNS character varying AS
$BODY$
--	Función que crea devuelve la cadena de texto en castellano que corresponde a un numero.
--  parámetros: número con 2 decimales, máximo 999.999.999,99.
--  Autor: Conxita Marín, cmarin@..., www.dims.com.

DECLARE
	d varchar[];
	f varchar[];
	g varchar[];
	numt varchar;
	txt varchar;
	a integer;
	a1 integer;
	a2 integer;
	n integer;
	p integer;
BEGIN
	-- Máximo 999.999.999,99
	if num > 999999999.99 then
		return '---';
	end if;
	txt = '';
	d = array[' un',' dos',' tres',' cuatro',' cinco',' seis',' siete',' ocho',' nueve',' diez',' once','
doce',' trece',' catorce',' quince',
		' dieciseis',' diecisiete',' dieciocho',' diecinueve',' veinte',' veintiun',' veintidos', '
veintitres', ' veinticuatro', ' veinticinco',
		' veintiseis',' veintisiete',' veintiocho',' veintinueve'];
	f = array ['','',' treinta',' cuarenta',' cincuenta',' sesenta',' setenta',' ochenta', ' noventa'];
	g= array [' ciento',' doscientos',' trescientos',' cuatrocientos',' quinientos',' seiscientos','
setecientos',' ochocientos',' novecientos'];
	numt = lpad(num::numeric(12,2),12,'0');
	numt = translate(numt,'.,','');
	-- Trato 4 grupos: millones, miles, unidades y decimales
	p = 1;
	for i in 1..4 loop
		if i < 4 then
			n = substring(numt from p for 3);
		else
			n = substring(numt from p for 2);
		end if;
		p = p + 3;
		if i = 4 then
			if txt = '' then
				txt = ' cero';
			end if;
			if n > 0 then
			-- Empieza con los decimales
				txt = txt || ' con';
			end if;
		end if;
		-- Centenas
		if n > 99 then
			a = substring(n from 1 for 1);
			a1 = substring(n from 2 for 2);
			if a = 1 then
				if a1 = 0 then
					txt = txt || ' cien';
				else
					txt = txt || ' ciento';
				end if;
			else
				txt = txt || g[a];
			end if;
		else
			a1 = n;
		end if;
		-- Decenas
		a = a1;
		if a > 0 then
			if a < 30 then
				if a = 21 and (i = 3 or i = 4) then
					txt = txt || ' veintiuno';
				elsif n = 1 and i = 2 then
					txt = txt;
				elsif a = 1 and (i = 3 or i = 4)then
					txt = txt || ' uno';
				else
					txt = txt || d[a];
				end if;
			else
				a1 = substring(a from 1 for 1);
				a2 = substring(a from 2 for 1);
				if a2 = 1 and (i = 3 or i = 4) then
						txt = txt || f[a1] || ' y' || ' uno';
				else
					if a2 <> 0 then
						txt = txt || f[a1] || ' y' || d[a2];
					else
						txt = txt || f[a1];
					end if;
				end if;
			end if;
		end if;
		if n > 0 then
			if i = 1 then
				if n = 1 then
					txt = txt || ' millón';
				else
					txt = txt || ' millones';
				end if;
			elsif i = 2 then
				txt = txt || ' mil';
			end if;
		end if;
	end loop;
    RETURN upper(txt);
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_convertnumbertowords(numeric)
  OWNER TO postgres;
