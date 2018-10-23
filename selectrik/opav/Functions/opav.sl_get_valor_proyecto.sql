-- Function: opav.sl_get_valor_proyecto(character varying)

-- DROP FUNCTION opav.sl_get_valor_proyecto(character varying);

CREATE OR REPLACE FUNCTION opav.sl_get_valor_proyecto(_id_solicitud character varying)
  RETURNS text AS
$BODY$

DECLARE
retorno text;
begin



SELECT
            case
            ofe.nuevo_modulo
            when 1 then  coo.valor_cotizacion
            else tem.valor_cotizacion
            end into retorno
            /*,case
            ofe.nuevo_modulo
            when 1 then  coo.total
            else tem.total
            end*/
            FROM opav.ofertas as ofe
            left join cliente as cl on(cl.codcli=ofe.id_cliente)
            left join tablagen as tbg on (tbg.table_code=ofe.responsable and tbg.table_type = 'RESPONSABL')
            left join tablagen as tbg2 on (tbg2.table_code=ofe.interventor and tbg2.table_type = 'INTERVENTO')
            left join opav.sl_estado_cartera as car on (ofe.estudio_cartera=car.id)
            left join opav.proyecto_distribucion pd on (ofe.tipo_solicitud = pd.distribucion)
            left join opav.tipo_proyecto tp on (tp.cod_proyecto = pd.proyecto)
            left join opav.sl_etapas_ofertas as est on(est.id=ofe.trazabilidad)
            left join opav.sl_estados_etapas_ofertas as eto on (eto.id = ofe.estado) --comentado mientras tanto
            left join opav.acciones as ac ON (ofe.id_solicitud= ac.id_solicitud and ac.accion_principal = 1 )
            left join opav.sl_cotizacion as coo on (ac.id_accion=coo.id_accion)
            left join tem.sl_cotizacion as tem on (ac.id_accion=tem.id_accion)
            where ofe.id_solicitud=_id_solicitud;


RETURN retorno;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sl_get_valor_proyecto(character varying)
  OWNER TO postgres;
