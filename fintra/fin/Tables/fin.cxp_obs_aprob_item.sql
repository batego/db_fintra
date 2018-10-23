-- Table: fin.cxp_obs_aprob_item

-- DROP TABLE fin.cxp_obs_aprob_item;

CREATE TABLE fin.cxp_obs_aprob_item
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(15) NOT NULL DEFAULT ''::character varying,
  proveedor character varying(15) NOT NULL DEFAULT ''::character varying,
  tipo_documento character varying(15) NOT NULL DEFAULT ''::character varying,
  documento character varying(30) NOT NULL DEFAULT ''::character varying,
  item character varying(30) NOT NULL DEFAULT ''::character varying,
  observacion_autorizador text NOT NULL DEFAULT ''::text, -- observaciones del autorizador
  fecha_ob_autorizador date NOT NULL DEFAULT '0099-01-01'::date, -- fecha en que realiza las observaciones el autorizador
  usuario_ob_autorizador character varying(15) NOT NULL DEFAULT ''::character varying, -- login del usuario autorizador que realiza las observaciones
  fecha_ob_pagador date NOT NULL DEFAULT '0099-01-01'::date, -- fecha en que realiza las observaciones el pagador
  usuario_ob_pagador character varying(15) NOT NULL DEFAULT ''::character varying, -- login del usuario aprobador que realiza las observaciones
  ob_registra_factura text NOT NULL DEFAULT ''::character varying, -- observaciones de quien registra la factura
  fecha_ob_reg_factura date NOT NULL DEFAULT '0099-01-01'::date, -- fecha en que realiza las observaciones el que registra la factura
  usuario_ob_reg_factura character varying(15) NOT NULL DEFAULT ''::character varying, -- login del usuario registrador la factura que realiza las observaciones
  observacion_pagador text NOT NULL DEFAULT ''::text, -- observaciones del pagador
  cierre_observacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  last_update timestamp without time zone NOT NULL DEFAULT (now())::timestamp without time zone,
  user_update character varying NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT (now())::timestamp without time zone,
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  base character varying(3) DEFAULT ''::character varying,
  textoactivo character varying(1) NOT NULL DEFAULT ''::character varying -- Campo que indica si una observacion esta activa
)
WITH (
  OIDS=TRUE
);
ALTER TABLE fin.cxp_obs_aprob_item
  OWNER TO postgres;
COMMENT ON TABLE fin.cxp_obs_aprob_item
  IS 'Observaciones de Aprobacion de Items';
COMMENT ON COLUMN fin.cxp_obs_aprob_item.observacion_autorizador IS 'observaciones del autorizador';
COMMENT ON COLUMN fin.cxp_obs_aprob_item.fecha_ob_autorizador IS 'fecha en que realiza las observaciones el autorizador';
COMMENT ON COLUMN fin.cxp_obs_aprob_item.usuario_ob_autorizador IS 'login del usuario autorizador que realiza las observaciones';
COMMENT ON COLUMN fin.cxp_obs_aprob_item.fecha_ob_pagador IS 'fecha en que realiza las observaciones el pagador';
COMMENT ON COLUMN fin.cxp_obs_aprob_item.usuario_ob_pagador IS 'login del usuario aprobador que realiza las observaciones';
COMMENT ON COLUMN fin.cxp_obs_aprob_item.ob_registra_factura IS 'observaciones de quien registra la factura';
COMMENT ON COLUMN fin.cxp_obs_aprob_item.fecha_ob_reg_factura IS 'fecha en que realiza las observaciones el que registra la factura';
COMMENT ON COLUMN fin.cxp_obs_aprob_item.usuario_ob_reg_factura IS 'login del usuario registrador la factura que realiza las observaciones';
COMMENT ON COLUMN fin.cxp_obs_aprob_item.observacion_pagador IS 'observaciones del pagador';
COMMENT ON COLUMN fin.cxp_obs_aprob_item.textoactivo IS 'Campo que indica si una observacion esta activa';


