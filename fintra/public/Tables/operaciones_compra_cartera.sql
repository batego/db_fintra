-- Table: operaciones_compra_cartera

-- DROP TABLE operaciones_compra_cartera;

CREATE TABLE operaciones_compra_cartera
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_tipo_operacion_libranza integer,
  descripcion character varying(200),
  id_tipo_documento integer,
  hc_cabecera character varying(25) NOT NULL DEFAULT ''::character varying,
  cuenta_cabecera character varying(25) NOT NULL DEFAULT ''::character varying,
  cuenta_detalle character varying(25) NOT NULL DEFAULT ''::character varying,
  visible character varying(1) NOT NULL DEFAULT 'S'::character varying,
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_lb_opelib_id FOREIGN KEY (id_tipo_operacion_libranza)
      REFERENCES tipo_operacion_libranza (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_lb_tdocumento_id FOREIGN KEY (id_tipo_documento)
      REFERENCES tipo_documento (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE operaciones_compra_cartera
  OWNER TO postgres;
GRANT ALL ON TABLE operaciones_compra_cartera TO postgres;

