-- Table: ws.ws_datos_tablas_plus9

-- DROP TABLE ws.ws_datos_tablas_plus9;

CREATE TABLE ws.ws_datos_tablas_plus9
(
  nombre_tabla character varying(100) NOT NULL,
  nombre_campo character varying(100) NOT NULL,
  es_last_update character varying(1),
  es_fecha_envio character varying(1),
  es_pk character varying(1),
  es_fecha_anulacion character varying(1),
  condicion text,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE ws.ws_datos_tablas_plus9
  OWNER TO postgres;

