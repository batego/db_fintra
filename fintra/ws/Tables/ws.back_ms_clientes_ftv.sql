-- Table: ws.back_ms_clientes_ftv

-- DROP TABLE ws.back_ms_clientes_ftv;

CREATE TABLE ws.back_ms_clientes_ftv
(
  id_cliente numeric(10,0),
  nic numeric(7,0),
  nit character varying(15),
  tipo_identificacion character varying(2),
  nombre_cliente character varying(60),
  zona character varying(20),
  ciudad character varying(60),
  sector character varying(20),
  direccion character varying(60),
  telefono character varying(15),
  celular character varying(15),
  ejecutivo_cta character varying(60),
  fecha_envio_ws timestamp without time zone,
  por_actualizar numeric(1,0),
  last_update_finv timestamp without time zone,
  contacto character varying(80),
  cargo character varying(80),
  comentario character varying(50),
  descripcione text,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE ws.back_ms_clientes_ftv
  OWNER TO postgres;

