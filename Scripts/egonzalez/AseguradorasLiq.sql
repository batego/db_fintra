SELECT  sum(capital),sum(interes), sum(capital)+sum(interes) as valorKI
FROM  apicredit.eg_simulador_liquidacion_micro_fecha(4718171::numeric, 18::integer, 
                                                     '2019-01-17'::date, 'CTFCPV'::varchar,'BQ'::varchar, 
                                                     '2018-12-18'::date) as retorno ;
                                                      
SELECT  sum(capital),sum(interes),sum(capital)+sum(interes) as valorKI
FROM  apicredit.eg_simulador_liquidacion_micro_fecha(3275914::numeric, 12::integer, 
                                                     '2018-12-12'::date, 'CTFCPV'::varchar,'BQ'::varchar, 
                                                     '2018-11-12'::date) as retorno ;
                                                    
select '2019-01-17'::date-'30'::interval; 

select * from detalle_poliza_negocio
                                                     
select n.cod_neg,estado_cartera,fecha_liquidacion,sa.renovacion from negocios n
inner join solicitud_aval sa on sa.cod_neg= n.cod_neg
where estado_neg='T' and n.creation_date::DATE='2018-09-06'::DATE                                                     

select * from administrativo.tipo_cobro;
 
select * from documentos_neg_aceptado where cod_neg='MC15277'      ;     

select tasa,* from negocios where cod_neg='MC15277'  ;

select * from solicitud_aval where numero_solicitud=128991;

select '2019-01-17'::date-'2018-07-27'::date;

select  
        suc.id,
        suc.descripcion as nombre_sucursal,
		np.descripcion as nombre_poliza,
		ase.descripcion as nombre_aseguradora,
		tc.descripcion as tipo_cobro,
		tvp.descripcion as tipo_valor,
		a.descripcion as  nombre_afiliado,
		un.descripcion as nombre_unidad_negocio,
		tvp.tipo,
	    tvp.calcular_sobre,
		tvp.valor_absoluto,
		tvp.valor_porcentaje,
		tvp.valor_porc_iva
		--(cuando tipo es P= porcentaje o A = valor Abs , CALCULO_SOBRE='K/KI/NLL' , TIPO=P THEN VALOR_PORCENTAJE ELSE VALOR_ABSOLUTO)
from administrativo.configuracion_poliza conf
inner join administrativo.nuevas_polizas np on np.id=conf.id_poliza
inner join administrativo.aseguradoras ase on ase.id=conf.id_aseguradora
inner join administrativo.tipo_cobro tc on tc.id=conf.id_tipo_cobro 
inner join administrativo.tipo_valor_poliza tvp on tvp.id=conf.id_valor_poliza
inner join sucursales suc on suc.id=conf.id_sucursal
inner join rel_unidad_afiliado rua on rua.id=suc.id_unidad_afiliado
inner join afiliados a on rua.id_afiliado=a.id
inner join unidad_negocio un on un.id=conf.id_unidad_negocio and rua.id_unidad_negocio=conf.id_unidad_negocio
order by suc.id;

--1.) asociar la agencia a la solicitud aval
--2.) Calcular el valor de la poliza para el negocio
--3.) guardar en el campo seguro del liquidador la suma de todas la polizas
--4.) guardar detalle de el calculo de la poliza al momento de formalizar el negocio para fintra credit cuando se crea liquidao reliquida, y en micro cuando se liquida o reliquida. 

SELECT upper(idusuario),
       tipo_usuario,
       nombre,
       idusuario,
       email,
       id_sucursal 
 FROM apicredit.usuarios_portal WHERE (upper(idusuario) = ? OR upper(email)=?) AND claveencr = ? AND reg_status !='I'
 
 select id_sucursal,id_convenio,agencia,* from convenios where id_convenio!=37 and prefijo_negocio='NEG_MICROCRED';
 select * from 
 
select apicredit.sp_scorehdc_educativo(132506::integer, ''::character varying);
select * from apicredit.pre_solicitudes_creditos where numero_solicitud=132506

select  * --count(0) as confirmar_hdc, trim(tipo_cliente)  as tipo_cliente
			from wsdc.persona
			where identificacion = '1129583782' --and  tipo_identificacion = 1 and nit_empresa in ('8020220161')
			group by tipo_cliente ;
