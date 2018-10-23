-- Function: administrativo.info_fasecolda(character varying, character varying, character varying, character varying, character varying)

-- DROP FUNCTION administrativo.info_fasecolda(character varying, character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION administrativo.info_fasecolda(marcavehiculo character varying, clase_vehiculo character varying, referencia_1 character varying, referencia_2 character varying, referencia_3 character varying)
  RETURNS SETOF administrativo.type_info_fasecolda AS
$BODY$
DECLARE

 _fasecolda administrativo.type_info_fasecolda;
 rs record;
 periodo varchar='';
 anios integer;
 query varchar:=0;

BEGIN


        for anios in 1970..2030 loop
	   periodo:=periodo||'"'||anios||'",';
        end loop;
	raise notice 'periodo: %',periodo;

	query:='SELECT
			carro.codigo
			,mar.marca
			,carro.clase
			,ser.descripcion as servicio
			,ref1.descripcion as ref1
			,ref2.descripcion as ref2
			,ref3.descripcion as ref3
			,'||periodo||'
                        bcpp
			,ref3.nacionalidad
			,ref3.potencia
			,ref3.tipo_caja
			,ref3.cilindraje
			,ref3.capacidad_pasajeros
			,ref3.capacidad_carga
			,ref3.puertas
			,ref3.aire_acondicionado
			,ref3.ejes
			,ref3.combustible
			,ref3.transmision
			,carro.estado
		FROM administrativo.vehiculo carro
			inner join administrativo.marca_vehuculo  mar on (carro.id_marca=mar.id)
			inner join administrativo.referencia_1 ref1 on (carro.id_referencia1=ref1.id)
			inner join administrativo.referencia_2 ref2 on (carro.id_referencia1=ref2.id_referencia1)
			inner join administrativo.referencia_3 ref3 on (carro.id_referencia1=ref3.id_referencia1 and  ref2.id=ref3.id_referencia2
									and carro.id_referencia2=ref3.id_referencia2 and carro.referencia3=ref3.descripcion)
			inner join administrativo.tipo_servicio ser on (ser.id=ref3.id_servicio)
		where mar.marca='''||marcaVehiculo||''' and ref1.descripcion='''||referencia_1||
		    ''' AND ref2.descripcion='''||trim(SUBSTRING(referencia_2,0, case when strpos(referencia_2,': peso')=0 then 50 else strpos(referencia_2,': peso') end ))||''' and ref3.descripcion='''||referencia_3||
		    ''' AND UPPER(carro.clase)='''||UPPER(clase_vehiculo)||'''
			AND carro.lote_carga =(select max(lote_carga) from  administrativo.control_lote_fasecolda where reg_status='''' and estado=''P'' )
		group by
			carro.lote_carga
			,carro.codigo
			,mar.marca
			,carro.clase
			,ser.descripcion
			,ref1.descripcion
			,ref2.descripcion
			,ref3.descripcion,
			 "1970", "1971", "1972", "1973", "1974",
			 "1975", "1976", "1977", "1978", "1979", "1980", "1981", "1982",
			 "1983", "1984", "1985", "1986", "1987", "1988", "1989", "1990",
			 "1991", "1992", "1993", "1994", "1995", "1996", "1997", "1998",
			 "1999", "2000", "2001", "2002", "2003", "2004", "2005", "2006",
			 "2007", "2008", "2009", "2010", "2011", "2012", "2013", "2014",
			 "2015", "2016", "2017", "2018", "2019", "2020", "2021", "2022",
			 "2023", "2024", "2025", "2026", "2027", "2028", "2029", "2030"
			,bcpp
			,ref3.nacionalidad
			,ref3.potencia
			,ref3.tipo_caja
			,ref3.cilindraje
			,ref3.capacidad_pasajeros
			,ref3.capacidad_carga
			,ref3.puertas
			,ref3.aire_acondicionado
			,ref3.ejes
			,ref3.combustible
			,ref3.transmision
			,carro.estado
		order by codigo';


	for rs in  execute query loop

                raise notice '%',rs.nacionalidad;

		_fasecolda.estado:=rs.estado;
		_fasecolda.codigo:=rs.codigo;
		_fasecolda.marca:=rs.marca;
		_fasecolda.clase:=rs.clase ;
		_fasecolda.servicio:=rs.servicio;
		_fasecolda.ref1:=rs.ref1;
		_fasecolda.ref2:=rs.ref2;
		_fasecolda.ref3:=rs.ref3;
		_fasecolda.periodo_1970 := rs."1970"*1000;
		_fasecolda.periodo_1971 := rs."1971"*1000;
		_fasecolda.periodo_1972 := rs."1972"*1000;
		_fasecolda.periodo_1973 := rs."1973"*1000;
		_fasecolda.periodo_1974 := rs."1974"*1000;
		_fasecolda.periodo_1975 := rs."1975"*1000;
		_fasecolda.periodo_1976 := rs."1976"*1000;
		_fasecolda.periodo_1977 := rs."1977"*1000;
		_fasecolda.periodo_1978 := rs."1978"*1000;
		_fasecolda.periodo_1979 := rs."1979"*1000;
		_fasecolda.periodo_1980 := rs."1980"*1000;
		_fasecolda.periodo_1981 := rs."1981"*1000;
		_fasecolda.periodo_1982 := rs."1982"*1000;
		_fasecolda.periodo_1983 := rs."1983"*1000;
		_fasecolda.periodo_1984 := rs."1984"*1000;
		_fasecolda.periodo_1985 := rs."1985"*1000;
		_fasecolda.periodo_1986 := rs."1986"*1000;
		_fasecolda.periodo_1987 := rs."1987"*1000;
		_fasecolda.periodo_1988 := rs."1988"*1000;
		_fasecolda.periodo_1989 := rs."1989"*1000;
		_fasecolda.periodo_1990 := rs."1990"*1000;
		_fasecolda.periodo_1991 := rs."1991"*1000;
		_fasecolda.periodo_1992 := rs."1992"*1000;
		_fasecolda.periodo_1993 := rs."1993"*1000;
		_fasecolda.periodo_1994 := rs."1994"*1000;
		_fasecolda.periodo_1995 := rs."1995"*1000;
		_fasecolda.periodo_1996 := rs."1996"*1000;
		_fasecolda.periodo_1997 := rs."1997"*1000;
		_fasecolda.periodo_1998 := rs."1998"*1000;
		_fasecolda.periodo_1999 := rs."1999"*1000;
		_fasecolda.periodo_2000 := rs."2000"*1000;
		_fasecolda.periodo_2001 := rs."2001"*1000;
		_fasecolda.periodo_2002 := rs."2002"*1000;
		_fasecolda.periodo_2003 := rs."2003"*1000;
		_fasecolda.periodo_2004 := rs."2004"*1000;
		_fasecolda.periodo_2005 := rs."2005"*1000;
		_fasecolda.periodo_2006 := rs."2006"*1000;
		_fasecolda.periodo_2007 := rs."2007"*1000;
		_fasecolda.periodo_2008 := rs."2008"*1000;
		_fasecolda.periodo_2009 := rs."2009"*1000;
		_fasecolda.periodo_2010 := rs."2010"*1000;
		_fasecolda.periodo_2011 := rs."2011"*1000;
		_fasecolda.periodo_2012 := rs."2012"*1000;
		_fasecolda.periodo_2013 := rs."2013"*1000;
		_fasecolda.periodo_2014 := rs."2014"*1000;
		_fasecolda.periodo_2015 := rs."2015"*1000;
                _fasecolda.periodo_2016 := rs."2016"*1000;
		_fasecolda.periodo_2017 := rs."2017"*1000;
		_fasecolda.periodo_2018 := rs."2018"*1000;
		_fasecolda.periodo_2019 := rs."2019"*1000;
		_fasecolda.periodo_2020 := rs."2020"*1000;
		_fasecolda.periodo_2021 := rs."2021"*1000;
		_fasecolda.periodo_2022 := rs."2022"*1000;
		_fasecolda.periodo_2023 := rs."2023"*1000;
		_fasecolda.periodo_2024 := rs."2024"*1000;
		_fasecolda.periodo_2025 := rs."2025"*1000;
		_fasecolda.periodo_2026 := rs."2026"*1000;
		_fasecolda.periodo_2027 := rs."2027"*1000;
		_fasecolda.periodo_2028 := rs."2028"*1000;
		_fasecolda.periodo_2029 := rs."2029"*1000;
		_fasecolda.periodo_2030 := rs."2030"*1000;
		_fasecolda.bcpp:=rs.bcpp;
		_fasecolda.nacionalidad:=rs.nacionalidad;
		_fasecolda.potencia:=rs.potencia;
		_fasecolda.tipo_caja:=rs.tipo_caja;
		_fasecolda.cilinadraje:=rs.cilindraje;
		_fasecolda.pasajeros:=rs.capacidad_pasajeros;
		_fasecolda.carga:=rs.capacidad_carga;
		_fasecolda.puertas:=rs.puertas;
		_fasecolda.aire:=rs.aire_acondicionado;
		_fasecolda.ejes:=rs.ejes;
		_fasecolda.combustible:=rs.combustible;
		_fasecolda.transmision=rs.transmision;



		return next _fasecolda;


	end loop;





END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION administrativo.info_fasecolda(character varying, character varying, character varying, character varying, character varying)
  OWNER TO postgres;
