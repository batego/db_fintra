-- Type: type_ofertas

-- DROP TYPE type_ofertas;

CREATE TYPE type_ofertas AS
   (id_solicitud character varying,
    id_cliente character varying,
    id_oferta character varying,
    num_os character varying,
    descripcion text,
    last_update timestamp without time zone,
    creation_date timestamp without time zone,
    creation_user character varying,
    user_update character varying,
    reg_status character varying,
    nic character varying,
    fecha_entrega_oferta timestamp without time zone,
    creacion_fecha_entrega_oferta timestamp without time zone,
    usuario_entrega_oferta character varying,
    tipo_solicitud character varying,
    tipodistribucion character varying,
    noesvaloragregado integer,
    nombre_solicitud character varying,
    user_oferta character varying,
    fecha_oferta timestamp without time zone,
    consecutivo_oferta character varying,
    otras_consideraciones text,
    consideraciones text,
    esoficial character varying,
    otras_anulaciones text,
    user_generate character varying,
    aviso character varying,
    fecha_validacion_cartera timestamp without time zone,
    estudio_cartera character varying,
    interventor character varying,
    responsable character varying,
    comentario text,
    fecha_inicial_oferta timestamp without time zone,
    dstrct character varying,
    id_tipo_trabajo integer,
    id_tipo_negocio integer);
ALTER TYPE type_ofertas
  OWNER TO postgres;
