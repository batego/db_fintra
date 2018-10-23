-- Table: doc.ofertaxproveedor

-- DROP TABLE doc.ofertaxproveedor;

CREATE TABLE doc.ofertaxproveedor
(
  nit_proveedor character varying(15) NOT NULL,
  dstrct character varying(4) NOT NULL,
  cod_material character varying(10) NOT NULL,
  reg_status character varying(1) DEFAULT ''::character varying,
  precio numeric(15,2) DEFAULT 0.0,
  last_update timestamp without time zone DEFAULT (now())::timestamp without time zone,
  user_update character varying(15) DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE doc.ofertaxproveedor
  OWNER TO postgres;

