-- Table: recaudo.rel_ingreso_rop

-- DROP TABLE recaudo.rel_ingreso_rop;

CREATE TABLE recaudo.rel_ingreso_rop
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_recaudo integer NOT NULL,
  id_rop integer NOT NULL,
  id_unidad_negocio integer NOT NULL DEFAULT 0,
  cartera_en character varying(50) NOT NULL DEFAULT ''::character varying,
  detalle_recaudo integer NOT NULL,
  num_ingreso character varying(11) NOT NULL DEFAULT ''::character varying,
  w_detalle character varying(1) NOT NULL DEFAULT 'N'::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  usuario_aplica character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE recaudo.rel_ingreso_rop
  OWNER TO postgres;

