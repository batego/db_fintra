-- Function: eg_buscar_planillas_transferencia(character varying, character varying)

-- DROP FUNCTION eg_buscar_planillas_transferencia(character varying, character varying);

CREATE OR REPLACE FUNCTION eg_buscar_planillas_transferencia(sql character varying, banco character varying)
  RETURNS SETOF rs_planillas_transferencia AS
$BODY$
DECLARE

 recordAnticipos record;
 recordReferido record;
 rs rs_planillas_transferencia;
 recordTablaBanco record;

 bancoIN varchar:='';
 aplicarValores text :='';
 secuencias numeric:=0;


BEGIN


  FOR recordAnticipos IN execute sql LOOP

	/* *****************************
	 *   Validamos los bancos.      *
	********************************/

	IF( Banco = 'OCCIDENTE' OR Banco = '23' ) THEN
                bancoIN:='BANCO OCCIDENTE';
        ELSIF( Banco = '' OR Banco = '07' OR Banco ='7B' )THEN
                bancoIN:='BANCOLOMBIA';
        ELSE
           bancoIN:=Banco;
        END IF;

	 raise notice 'Banco in :%',bancoIN;

        /* *******************************************
	 *   APLICAMOS LOS VALORES DE COMISIONES     *
	**********************************************/
        IF(TRIM(recordAnticipos.nit_cuenta)='')THEN

                raise notice 'nit_cuenta :%',recordAnticipos.nit_cuenta;

		/*Actualizamos los bancos de trasnferencia */
		UPDATE  fin.anticipos_pagos_terceros as apt
			SET
			 apt.banco          = bct.banco,
			 apt.sucursal       = bct.sucursal,
			 apt.nombre_cuenta  = bct.nombre_cuenta,
			 apt.cuenta         = bct.cuenta,
			 apt.tipo_cuenta    = bct.tipo_cuenta,
			 apt.nit_cuenta     = bct.cedula_cuenta

		FROM    fin.bancostransferencias as bct
		WHERE	apt.id     =  recordAnticipos.id
			AND  bct.nit   =  recordAnticipos.pla_owner
			AND  bct.primaria   =  'S'
			AND  apt.reg_status='';
		RAISE NOTICE 'APLICAR VALORES ID PLANILLA : % , PLA_OWNER : %',recordAnticipos.id,recordAnticipos.pla_owner;
		SELECT INTO aplicarValores  eg_aplicar_valores(recordAnticipos.id, recordAnticipos.pla_owner, recordAnticipos.reanticipo, recordAnticipos.descripcion,
				    recordAnticipos.vlr, recordAnticipos.tipo_cuenta, recordAnticipos.banco, BancoIN);
		raise notice 'nit_cuenta :%',recordAnticipos.nit_cuenta;
                raise notice 'bct.tipo_cuenta :%',bct.tipo_cuenta;
                raise notice 'aplicarValores :%',aplicarValores;
        END IF;


        IF(recordAnticipos.secuencia = 0)THEN
             raise notice 'transferencia :%',recordAnticipos.secuencia;
	     bancoIN:= recordAnticipos.banco_transferencia;
	     SELECT INTO aplicarValores eg_aplicar_valores(recordAnticipos.id, recordAnticipos.pla_owner, recordAnticipos.reanticipo, recordAnticipos.descripcion,
				    recordAnticipos.vlr, recordAnticipos.tipo_cuenta, recordAnticipos.banco, BancoIN);

	ELSIF( secuencias =0 )THEN

	       raise notice 'secuencia no existente :%',recordAnticipos.secuencia;
	       secuencias:= recordAnticipos.secuencia;
	       bancoIN:= recordAnticipos.banco_transferencia;

	       SELECT INTO aplicarValores eg_aplicar_valores(recordAnticipos.id, recordAnticipos.pla_owner, recordAnticipos.reanticipo, recordAnticipos.descripcion,
				    recordAnticipos.vlr, recordAnticipos.tipo_cuenta, recordAnticipos.banco, BancoIN);

               raise notice 'Pronto Pago :%',aplicarValores;


	ELSIF(secuencias = recordAnticipos.secuencia) THEN
	       raise notice 'secuencia ya existente :%',recordAnticipos.secuencia;
	       secuencias:= recordAnticipos.secuencia;
              SELECT INTO aplicarValores eg_aplicar_valores2(recordAnticipos.id,  recordAnticipos.pla_owner, recordAnticipos.reanticipo, recordAnticipos.vlr);

        ELSE
	       raise notice 'secuencia cambio de secuencia :%',recordAnticipos.secuencia;
	       secuencias:= recordAnticipos.secuencia;
	       bancoIN:= recordAnticipos.banco_transferencia;

	       SELECT INTO aplicarValores eg_aplicar_valores(recordAnticipos.id, recordAnticipos.pla_owner, recordAnticipos.reanticipo, recordAnticipos.descripcion,
				    recordAnticipos.vlr, recordAnticipos.tipo_cuenta, recordAnticipos.banco, BancoIN);

               raise notice 'Pronto Pago nuevo :%',aplicarValores;

        END IF;

 END LOOP ;

/* **************************
   Retornamos los datos *****
*****************************/

 FOR recordAnticipos IN execute sql LOOP

	/* *************************************
	  Buscamos la informacion del referido**
	****************************************/

	SELECT INTO recordReferido ASESOR_COMERCIAL,
			    REFERENCIADO,
			    STATUS,
			    OBSERVACION
	FROM eg_llenar_referido_planilla (recordAnticipos.pla_owner) as referido (LEYENDA varchar, CONTENIDO varchar,
											ASESOR_COMERCIAL varchar,REFERENCIADO varchar,
											STATUS varchar, OBSERVACION varchar);


   	rs:=recordAnticipos;
        rs.asesor:=recordReferido.ASESOR_COMERCIAL;
	rs.referenciado:=recordReferido.REFERENCIADO;
	rs.status:=recordReferido.STATUS;
	rs.obs:=recordReferido.OBSERVACION;

	RETURN NEXT rs;

  END LOOP;

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_buscar_planillas_transferencia(character varying, character varying)
  OWNER TO postgres;
