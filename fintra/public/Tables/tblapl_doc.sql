-- Table: tblapl_doc

-- DROP TABLE tblapl_doc;

CREATE TABLE tblapl_doc
(
  reg_status character(1) NOT NULL DEFAULT ''::bpchar,
  dstrct character varying(4) NOT NULL DEFAULT 'TSP'::character varying,
  aplicacion character varying(10) NOT NULL DEFAULT ''::character varying, -- Codigo de la aplicacion.
  documento character varying(15) NOT NULL DEFAULT ''::character varying, -- Codigo del documento.
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE tblapl_doc
  OWNER TO postgres;
GRANT ALL ON TABLE tblapl_doc TO postgres;
GRANT SELECT ON TABLE tblapl_doc TO msoto;
COMMENT ON TABLE tblapl_doc
  IS 'Tabla donde se registra en que programas (aplicaciones) se utiliza un tipo de documento determinado (remesas,planillas,cedula,libreta militar, etc).';
COMMENT ON COLUMN tblapl_doc.aplicacion IS 'Codigo de la aplicacion.';
COMMENT ON COLUMN tblapl_doc.documento IS 'Codigo del documento.';


