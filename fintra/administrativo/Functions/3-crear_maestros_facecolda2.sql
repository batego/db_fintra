-- Function: administrativo.crear_maestros_facecolda2(character varying)

-- DROP FUNCTION administrativo.crear_maestros_facecolda2(character varying);

CREATE OR REPLACE FUNCTION administrativo.crear_maestros_facecolda2(usuario character varying)
  RETURNS boolean AS
$BODY$
DECLARE

retorno boolean:=true;
recordFasecolda record;
numero_lote varchar:='';

BEGIN

	/******************************************************
	 *	1.)administrativo.tipo_servicio               *
	 *	2.)administrativo.novedades_fasecolda         *
	 *	3.)administrativo.marca_vehuculo              *
	 *	4.)administrativo.referencia_1                *
	 *	5.)administrativo.referencia_2                *
	 *	6.)administrativo.referencia_3                *
	 *	7.)administrativo.clase_vehiculo              *
	 *	                   			      *
	 *	9.)administrativo.informacion_fasecolda       *
	 *                                                    *
	 *****************************************************
	 *      :::ESTADOS CONTROL DE ARCHIVO:::	      *
	 *      P: PROCESADO				      *
	 *      L: CARGADO PARA PROCESAR (LOAD) 	      *
	 *      F: FALLIDO 				      *
	 ******************************************************/

	--0.)Se busca el lote cargado para procesarlo
	SELECT into numero_lote lote_carga from administrativo.control_lote_fasecolda  where estado='L' AND fecha_subida::date=now()::date ;

	if(numero_lote is not null and (select count(0) from administrativo.archivo_fasecolda ) > 0) then

		--1.)administrativo.tipo_servicio
		raise notice 'PASO 1.';
		INSERT INTO administrativo.tipo_servicio(
			    reg_status, dstrct, lote_carga, descripcion, creation_date,
			    creation_user, last_update, user_update)
		select ''::varchar AS reg_status,'FINV'::varchar as dstrct,numero_lote,servicio ,now() as creation_date,
		      usuario::varchar,'0099-01-01 00:00:00'::timestamp without time zone as last_update,''::varchar as user_update
		from administrativo.archivo_fasecolda group by  servicio ;

		--2.)administrativo.novedades_fasecolda
		raise notice 'PASO 2.';
		INSERT INTO administrativo.novedades_fasecolda(
		    reg_status, dstrct, lote_carga, codigo, descripcion, creation_date,
		    creation_user, last_update, user_update)
		select ''::varchar AS reg_status,'FINV'::varchar as dstrct,numero_lote,lpad(count(0),2,'0') as codigo,novedad,now() as creation_date,
		       usuario::varchar,'0099-01-01 00:00:00'::timestamp without time zone as last_update,''::varchar as user_update
		from administrativo.archivo_fasecolda group by novedad ;


		--3.)administrativo.marca_vehuculo
		raise notice 'PASO 3.';
		INSERT INTO administrativo.marca_vehuculo(
		    reg_status, dstrct, lote_carga, marca, creation_date, creation_user,
		    last_update, user_update)
		select ''::varchar AS reg_status,'FINV'::varchar as dstrct,numero_lote,marca,now() as creation_date,usuario::varchar,
		       '0099-01-01 00:00:00'::timestamp without time zone as last_update,''::varchar as user_update
		 from administrativo.archivo_fasecolda group by marca ;

		--4.)administrativo.referencia_1
		raise notice 'PASO 4.';
		INSERT INTO administrativo.referencia_1(
		    reg_status, dstrct, lote_carga, descripcion, creation_date,
		    creation_user, last_update, user_update)
		select ''::varchar AS reg_status,'FINV'::varchar as dstrct,numero_lote,referencia1,now() as creation_date,
		       usuario::varchar,'0099-01-01 00:00:00'::timestamp without time zone as last_update,''::varchar as user_update
		 from administrativo.archivo_fasecolda group by referencia1 ;

		--5.)administrativo.referencia_2
		raise notice 'PASO 5.';
		INSERT INTO administrativo.referencia_2(
			    reg_status, dstrct, lote_carga, descripcion,
			    id_referencia1,peso,
			    creation_date, creation_user, last_update, user_update)
		select ''::varchar AS reg_status,'FINV'::varchar as dstrct,numero_lote,referencia2,
		      (select id from administrativo.referencia_1 where descripcion=referencia1 and lote_carga=numero_lote) as referencia_1, peso::numeric,
		      now() as creation_date,usuario::varchar,'0099-01-01 00:00:00'::timestamp without time zone as last_update,''::varchar as user_update
		      from administrativo.archivo_fasecolda group by referencia1,referencia2,peso::numeric order by referencia1 ;

		--6.)administrativo.referencia_3
		raise notice 'PASO 6.';
		INSERT INTO administrativo.referencia_3(
			    reg_status, dstrct, lote_carga, descripcion,id_referencia1,id_referencia2,
			    importado, id_servicio, potencia, tipo_caja, cilindraje, nacionalidad,
			    capacidad_pasajeros, capacidad_carga, puertas, aire_acondicionado,
			    ejes, estado, combustible, transmision, um, peso_categoria,
			    creation_date, creation_user, last_update, user_update)
		select ''::varchar AS reg_status,'FINV'::varchar as dstrct,numero_lote,referencia3,
                        (select id from administrativo.referencia_1 where descripcion=af.referencia1 and lote_carga=numero_lote) as referencia_1,
		        (select ref2.id from administrativo.referencia_2  ref2
		         inner join administrativo.referencia_1  ref1 on (ref1.id=ref2.id_referencia1)
		         where ref2.descripcion=af.referencia2 and ref1.descripcion=af.referencia1 and ref2.peso::numeric=af.peso::numeric and ref2.lote_carga=numero_lote
		         ) as referencia_2,
		        cast (af.importado::numeric as integer),
			(select id from administrativo.tipo_servicio  where descripcion=af.servicio and lote_carga=numero_lote) as id_servicio,--tabla
			af.potencia,af.tipocaja,af.cilindraje,af.nacionalidad,af.capacidadpasajeros,
			af.capacidadcarga,af.puertas,af.aireacondicionado,af.ejes,
			af.estado,af.combustible,af.transmision,af.um,af.pesocategoria,
		        now() as creation_date,usuario::varchar,'0099-01-01 00:00:00'::timestamp without time zone as last_update,''::varchar as user_update
		from administrativo.archivo_fasecolda af
		group by af.referencia1,af.referencia2,af.referencia3,af.peso, af.importado,af.servicio,
			af.potencia,af.tipocaja,af.cilindraje,af.nacionalidad,af.capacidadpasajeros,
			af.capacidadcarga,af.puertas,af.aireacondicionado,af.ejes,af.estado,af.combustible,
			af.transmision,af.um,af.pesocategoria;

		--7.)administrativo.vehiculo
		raise notice 'PASO 7.';
		INSERT INTO administrativo.vehiculo(
			reg_status, dstrct, lote_carga,estado, id_marca, clase, id_referencia1,id_referencia2,referencia3,
			codigo, homologo_codigo, id_novedad, "1970", "1971", "1972",
			"1973", "1974", "1975", "1976", "1977", "1978", "1979", "1980",
			"1981", "1982", "1983", "1984", "1985", "1986", "1987", "1988",
			"1989", "1990", "1991", "1992", "1993", "1994", "1995", "1996",
			"1997", "1998", "1999", "2000", "2001", "2002", "2003", "2004",
			"2005", "2006", "2007", "2008", "2009", "2010", "2011", "2012",
			"2013", "2014", "2015", "2016", "2017", "2018", "2019", "2020",
			"2021", "2022", "2023", "2024", "2025", "2026", "2027", "2028",
			"2029", "2030", bcpp,
			creation_date, creation_user, last_update, user_update)

		select ''::varchar AS reg_status,'FINV'::varchar as dstrct,numero_lote,af.estado,
			(select id from administrativo.marca_vehuculo m where m.marca=af.marca and m.lote_carga=numero_lote) as id_marca,
			clase,
			--referencia1
			(select id from administrativo.referencia_1  where descripcion=af.referencia1 and lote_carga=numero_lote) as id_referencia1,
			--referencia2
			(select ref2.id from administrativo.referencia_2  ref2
		         inner join administrativo.referencia_1  ref1 on (ref1.id=ref2.id_referencia1)
		         where ref2.descripcion=af.referencia2 and ref1.descripcion=af.referencia1 and ref2.peso::numeric=af.peso::numeric and ref2.lote_carga=numero_lote
		         )as id_referencia2,
		        --referencia3
			af.referencia3,

			af.codigo,
			af.homologocodigo,
			(select id from administrativo.novedades_fasecolda where descripcion=af.novedad  and lote_carga=numero_lote) as  id_novedad,
			"1970"::NUMERIC, "1971"::NUMERIC, "1972"::NUMERIC, "1973"::NUMERIC, "1974"::NUMERIC,
			"1975"::NUMERIC, "1976"::NUMERIC, "1977"::NUMERIC, "1978"::NUMERIC, "1979"::NUMERIC, "1980"::NUMERIC, "1981"::NUMERIC, "1982"::NUMERIC,
			"1983"::NUMERIC, "1984"::NUMERIC, "1985"::NUMERIC, "1986"::NUMERIC, "1987"::NUMERIC, "1988"::NUMERIC, "1989"::NUMERIC, "1990"::NUMERIC,
			"1991"::NUMERIC, "1992"::NUMERIC, "1993"::NUMERIC, "1994"::NUMERIC, "1995"::NUMERIC, "1996"::NUMERIC, "1997"::NUMERIC, "1998"::NUMERIC,
			"1999"::NUMERIC, "2000"::NUMERIC, "2001"::NUMERIC, "2002"::NUMERIC, "2003"::NUMERIC, "2004"::NUMERIC, "2005"::NUMERIC, "2006"::NUMERIC,
			"2007"::NUMERIC, "2008"::NUMERIC, "2009"::NUMERIC, "2010"::NUMERIC, "2011"::NUMERIC, "2012"::NUMERIC, "2013"::NUMERIC, "2014"::NUMERIC,
			"2015"::NUMERIC, "2016"::NUMERIC, "2017"::NUMERIC, "2018"::NUMERIC, "2019"::NUMERIC, "2020"::NUMERIC, "2021"::NUMERIC, "2022"::NUMERIC,
			"2023"::NUMERIC, "2024"::NUMERIC, "2025"::NUMERIC, "2026"::NUMERIC, "2027"::NUMERIC, "2028"::NUMERIC, "2029"::NUMERIC, "2030"::NUMERIC,
			af.bcpp::NUMERIC,
			now() as creation_date,usuario::varchar,'0099-01-01 00:00:00'::timestamp without time zone as last_update,''::varchar as user_update
		from administrativo.archivo_fasecolda af
		group by af.estado,af.clase,
			 af.marca,
			 af.referencia1,
			 af.referencia2,
			 af.referencia3,
			 af.peso,
			 af.codigo,
			 af.homologocodigo,
			 af.novedad,
			 "1970", "1971", "1972", "1973", "1974",
			 "1975", "1976", "1977", "1978", "1979", "1980", "1981", "1982",
			 "1983", "1984", "1985", "1986", "1987", "1988", "1989", "1990",
			 "1991", "1992", "1993", "1994", "1995", "1996", "1997", "1998",
			 "1999", "2000", "2001", "2002", "2003", "2004", "2005", "2006",
			 "2007", "2008", "2009", "2010", "2011", "2012", "2013", "2014",
			 "2015", "2016", "2017", "2018", "2019", "2020", "2021", "2022",
			 "2023", "2024", "2025", "2026", "2027", "2028", "2029", "2030",
			 af.bcpp::numeric
			 ,af.importado,af.servicio,
			 af.potencia,af.tipocaja,af.cilindraje,af.nacionalidad,af.capacidadpasajeros,
			 af.capacidadcarga,af.puertas,af.aireacondicionado,af.ejes,af.estado,af.combustible,
			 af.transmision,af.um,af.pesocategoria;


		--8.)actualizamos el estado del control de lote
		update administrativo.control_lote_fasecolda set estado='P'  where estado='L' and lote_carga=numero_lote  AND fecha_subida::date=now()::date ;

	else
	  retorno:=false;
	end if;

	--11.)borramos el archivo fasecolda.
	TRUNCATE TABLE administrativo.archivo_fasecolda ;

return retorno;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION administrativo.crear_maestros_facecolda2(character varying)
  OWNER TO postgres;
