-- Table: ws.ms_interface_accord_ftv

-- DROP TABLE ws.ms_interface_accord_ftv;

CREATE TABLE ws.ms_interface_accord_ftv
(
  id_accion character varying(12) NOT NULL,
  id_orden numeric(10,0) NOT NULL,
  consecutivo character varying(30),
  id_contratista character varying(5) NOT NULL,
  acciones character varying(250) NOT NULL,
  total_prev1 numeric(15,0),
  last_update_finv timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  fecha_envio_ws timestamp without time zone,
  fecha_registro timestamp without time zone NOT NULL,
  por_actualizar numeric(1,0) NOT NULL DEFAULT 0,
  valor_materiales numeric(15,2),
  valor_mano_obra numeric(15,2),
  valor_otros numeric(15,2),
  simbolo_variable character varying(50),
  fact_conformada character varying(40) DEFAULT ''::character varying,
  eca_oferta numeric(15,2) DEFAULT 0,
  oferta numeric(15,2) DEFAULT 0,
  f_facturado_cliente character varying(20) DEFAULT '--'::character varying,
  exf_facturado_cliente character varying(20) DEFAULT ''::character varying,
  aiu_administracion numeric(15,2) NOT NULL DEFAULT 0,
  aiu_imprevistos numeric(15,2) NOT NULL DEFAULT 0,
  aiu_utilidad numeric(15,2) NOT NULL DEFAULT 0,
  factura_contratista character varying(10) DEFAULT ''::character varying,
  comentario character varying(50) DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE ws.ms_interface_accord_ftv
  OWNER TO postgres;

-- Trigger: appaccordinsert on ws.ms_interface_accord_ftv

-- DROP TRIGGER appaccordinsert ON ws.ms_interface_accord_ftv;

CREATE TRIGGER appaccordinsert
  AFTER INSERT
  ON ws.ms_interface_accord_ftv
  FOR EACH ROW
  EXECUTE PROCEDURE tablaaccionesasecundariainsert();

-- Trigger: appaccordupdate on ws.ms_interface_accord_ftv

-- DROP TRIGGER appaccordupdate ON ws.ms_interface_accord_ftv;

CREATE TRIGGER appaccordupdate
  AFTER UPDATE
  ON ws.ms_interface_accord_ftv
  FOR EACH ROW
  EXECUTE PROCEDURE tablaaccionesasecundariaupdate();


