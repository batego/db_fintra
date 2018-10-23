-- Table: ws.back_ms_interface_accord_ftv

-- DROP TABLE ws.back_ms_interface_accord_ftv;

CREATE TABLE ws.back_ms_interface_accord_ftv
(
  id_accion character varying(12),
  id_orden numeric(10,0),
  consecutivo character varying(30),
  id_contratista character varying(5),
  acciones character varying(250),
  total_prev1 numeric(15,0),
  last_update_finv timestamp without time zone,
  fecha_envio_ws timestamp without time zone,
  fecha_registro timestamp without time zone,
  por_actualizar numeric(1,0),
  valor_materiales numeric(15,2),
  valor_mano_obra numeric(15,2),
  valor_otros numeric(15,2),
  simbolo_variable character varying(50),
  fact_conformada character varying(40),
  eca_oferta numeric(15,2),
  oferta numeric(15,2),
  f_facturado_cliente character varying(20),
  exf_facturado_cliente character varying(20),
  aiu_administracion numeric(15,2),
  aiu_imprevistos numeric(15,2),
  aiu_utilidad numeric(15,2),
  factura_contratista character varying(10),
  comentario character varying(50),
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE ws.back_ms_interface_accord_ftv
  OWNER TO postgres;

