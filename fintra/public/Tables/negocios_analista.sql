-- Table: negocios_analista

-- DROP TABLE negocios_analista;

CREATE TABLE negocios_analista
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  cod_neg character varying(15) NOT NULL,
  secuencia integer NOT NULL,
  analista character varying(10) NOT NULL DEFAULT ''::character varying,
  fecha timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT "negociosFK" FOREIGN KEY (cod_neg)
      REFERENCES negocios (cod_neg) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE negocios_analista
  OWNER TO postgres;
GRANT ALL ON TABLE negocios_analista TO postgres;
GRANT SELECT ON TABLE negocios_analista TO msoto;

