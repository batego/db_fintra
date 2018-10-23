-- Table: ws.ms_clientes_ftv

-- DROP TABLE ws.ms_clientes_ftv;

CREATE TABLE ws.ms_clientes_ftv
(
  id_cliente numeric(10,0) NOT NULL,
  nic numeric(7,0) NOT NULL,
  nit character varying(15),
  tipo_identificacion character varying(2),
  nombre_cliente character varying(60) NOT NULL,
  zona character varying(20) NOT NULL,
  ciudad character varying(60) NOT NULL,
  sector character varying(20) NOT NULL,
  direccion character varying(60),
  telefono character varying(15),
  celular character varying(15),
  ejecutivo_cta character varying(60),
  fecha_envio_ws timestamp without time zone,
  por_actualizar numeric(1,0) NOT NULL,
  last_update_finv timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  contacto character varying(80) DEFAULT ''::character varying,
  cargo character varying(80) DEFAULT ''::character varying,
  comentario character varying(50) DEFAULT ''::character varying,
  descripcione text DEFAULT ''::text,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE ws.ms_clientes_ftv
  OWNER TO postgres;

-- Trigger: appclientinsert on ws.ms_clientes_ftv

-- DROP TRIGGER appclientinsert ON ws.ms_clientes_ftv;

CREATE TRIGGER appclientinsert
  AFTER INSERT
  ON ws.ms_clientes_ftv
  FOR EACH ROW
  EXECUTE PROCEDURE tablaclientsasecundariainsert();
ALTER TABLE ws.ms_clientes_ftv DISABLE TRIGGER appclientinsert;

-- Trigger: appclientupdate on ws.ms_clientes_ftv

-- DROP TRIGGER appclientupdate ON ws.ms_clientes_ftv;

CREATE TRIGGER appclientupdate
  AFTER UPDATE
  ON ws.ms_clientes_ftv
  FOR EACH ROW
  EXECUTE PROCEDURE tablaclienteasecundariaupdate();


