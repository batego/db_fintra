-- Table: app_clientes

-- DROP TABLE app_clientes;

CREATE TABLE app_clientes
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
  last_update_finv timestamp without time zone,
  contacto character varying(80) DEFAULT ''::character varying,
  cargo character varying(80) DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE app_clientes
  OWNER TO postgres;
GRANT ALL ON TABLE app_clientes TO postgres;
GRANT SELECT ON TABLE app_clientes TO msoto;

-- Trigger: clienteappafinvt on app_clientes

-- DROP TRIGGER clienteappafinvt ON app_clientes;

CREATE TRIGGER clienteappafinvt
  AFTER INSERT OR UPDATE
  ON app_clientes
  FOR EACH ROW
  EXECUTE PROCEDURE clienteappafinv();


