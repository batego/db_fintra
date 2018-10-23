-- Table: ws.ws_datos_tablas

-- DROP TABLE ws.ws_datos_tablas;

CREATE TABLE ws.ws_datos_tablas
(
  nombre_tabla character varying(100) NOT NULL DEFAULT ''::character varying, -- nombre de la tabla
  nombre_campo character varying(100) NOT NULL DEFAULT ''::character varying, -- nombre de uno de los campos de la tabla
  es_last_update character varying(1) DEFAULT 'N'::character varying, -- dice si el campo tiene la ultima fecha en la que se modifico el registro de la tabla
  es_fecha_envio character varying(1) DEFAULT 'N'::character varying, -- dice si el campo tiene la ultima fecha en la que se envio el registro del server al cliente
  es_pk character varying(1) DEFAULT 'N'::character varying, -- campo que dice si nombre_campo hace parte de la llave primaria de nombre_tabla
  es_fecha_anulacion character varying(1) DEFAULT 'N'::character varying, -- dice si el campo tiene la fecha en la que el registro fue anulado
  condicion text DEFAULT ''::text, -- Sin procesar o Procesando para estado_client
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE ws.ws_datos_tablas
  OWNER TO postgres;
COMMENT ON TABLE ws.ws_datos_tablas
  IS 'tabla que contiene la informacion de las tablas asociadas al web service.';
COMMENT ON COLUMN ws.ws_datos_tablas.nombre_tabla IS 'nombre de la tabla';
COMMENT ON COLUMN ws.ws_datos_tablas.nombre_campo IS 'nombre de uno de los campos de la tabla';
COMMENT ON COLUMN ws.ws_datos_tablas.es_last_update IS 'dice si el campo tiene la ultima fecha en la que se modifico el registro de la tabla';
COMMENT ON COLUMN ws.ws_datos_tablas.es_fecha_envio IS 'dice si el campo tiene la ultima fecha en la que se envio el registro del server al cliente';
COMMENT ON COLUMN ws.ws_datos_tablas.es_pk IS 'campo que dice si nombre_campo hace parte de la llave primaria de nombre_tabla';
COMMENT ON COLUMN ws.ws_datos_tablas.es_fecha_anulacion IS 'dice si el campo tiene la fecha en la que el registro fue anulado';
COMMENT ON COLUMN ws.ws_datos_tablas.condicion IS 'Sin procesar o Procesando para estado_client';


