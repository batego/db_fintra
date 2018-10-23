-- Table: ws.ms_interface_contratistas_ftv

-- DROP TABLE ws.ms_interface_contratistas_ftv;

CREATE TABLE ws.ms_interface_contratistas_ftv
(
  id_contratista character varying(5) NOT NULL,
  descripcion character varying(60) NOT NULL,
  last_update_finv timestamp without time zone,
  fecha_envio_ws timestamp without time zone,
  por_actualizar numeric(1,0) NOT NULL DEFAULT 0,
  nit character varying(15),
  exid_contratista character varying(5) DEFAULT ''::character varying,
  comentario character varying(50) DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE ws.ms_interface_contratistas_ftv
  OWNER TO postgres;

