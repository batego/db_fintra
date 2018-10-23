-- Table: administrativo.referencia_3

-- DROP TABLE administrativo.referencia_3;

CREATE TABLE administrativo.referencia_3
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  lote_carga character varying(10) NOT NULL,
  descripcion character varying(50) NOT NULL DEFAULT ''::character varying,
  id_referencia1 integer NOT NULL,
  id_referencia2 integer NOT NULL,
  importado character varying(10) NOT NULL DEFAULT ''::character varying,
  id_servicio integer NOT NULL,
  potencia character varying(30) NOT NULL DEFAULT ''::character varying,
  tipo_caja character varying(30) NOT NULL DEFAULT ''::character varying,
  cilindraje character varying(30) NOT NULL DEFAULT ''::character varying,
  nacionalidad character varying(30) NOT NULL DEFAULT ''::character varying,
  capacidad_pasajeros character varying(30) NOT NULL DEFAULT ''::character varying,
  capacidad_carga character varying(30) NOT NULL DEFAULT ''::character varying,
  puertas character varying(30) NOT NULL,
  aire_acondicionado character varying(30) NOT NULL DEFAULT ''::character varying,
  ejes character varying(30) NOT NULL DEFAULT ''::character varying,
  estado character varying(30) NOT NULL DEFAULT ''::character varying,
  combustible character varying(30) NOT NULL DEFAULT ''::character varying,
  transmision character varying(30) NOT NULL DEFAULT ''::character varying,
  um character varying(30) NOT NULL DEFAULT ''::character varying,
  peso_categoria character varying(30) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(20) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_id_servicio FOREIGN KEY (id_servicio)
      REFERENCES administrativo.tipo_servicio (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_referencia_1 FOREIGN KEY (id_referencia1)
      REFERENCES administrativo.referencia_1 (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_referencia_2 FOREIGN KEY (id_referencia2)
      REFERENCES administrativo.referencia_2 (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_referencia_3_lote FOREIGN KEY (lote_carga)
      REFERENCES administrativo.control_lote_fasecolda (lote_carga) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.referencia_3
  OWNER TO postgres;

