-- Function: sp_renamearchivosmultiservicios()

-- DROP FUNCTION sp_renamearchivosmultiservicios();

CREATE OR REPLACE FUNCTION sp_renamearchivosmultiservicios()
  RETURNS text AS
$BODY$

DECLARE
        nomsize integer;
        extsize integer;
        consecutivo integer;
      	archivosmultiservRecord record;
        nombrearchivosRecord record;
        nomArchivo character varying;
        newNomArchivo character varying;
	retorno text:='OK';
        good text:='';

BEGIN

        FOR archivosmultiservRecord IN

		 /*Obtenemos valores correspondientes a los documentos con nombres de archivos iguales en tabla archivos_multiservicios*/
                 SELECT document, filename FROM archivos_multiservicios group by document,filename having count(0)>1 order by document,filename, count(0)

		LOOP
		       consecutivo = 1;
                       FOR nombrearchivosRecord IN

			 /*Obtenemos los nombres de los archivos repetidos para un negocio dado*/
			 SELECT id,document,filename FROM archivos_multiservicios where document=archivosmultiservRecord.document and filename = archivosmultiservRecord.filename

			LOOP
                                select into extsize,nomsize length(split_part(nombrearchivosRecord.filename, '.', length(nombrearchivosRecord.filename)-length(replace(nombrearchivosRecord.filename, '.', ''))+1)),length(nombrearchivosRecord.filename);
                                select into newNomArchivo case when (nomsize>extsize) THEN
                                   substring(nombrearchivosRecord.filename,1,(nomsize-extsize)-1)||'_'||consecutivo||substring(nombrearchivosRecord.filename,(nomsize-extsize),extsize+1)
                                ELSE
                                   nombrearchivosRecord.filename||'_'||consecutivo
                                END;

                                update archivos_multiservicios set filename = newNomArchivo  where id = nombrearchivosRecord.id  and document=nombrearchivosRecord.document and filename=nombrearchivosRecord.filename;
			        consecutivo = consecutivo + 1;
				--raise notice 'Nombre archivo: %',newNomArchivo;

			END LOOP;


		END LOOP;


	RETURN retorno;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_renamearchivosmultiservicios()
  OWNER TO postgres;
