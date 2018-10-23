-- Table: opav.sl_rel_estados_etapas

-- DROP TABLE opav.sl_rel_estados_etapas;

CREATE TABLE opav.sl_rel_estados_etapas
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_estado_actual integer,
  id_estado_destino integer,
  id_etapa_destino integer,
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_estados_ofertas FOREIGN KEY (id_estado_destino)
      REFERENCES opav.sl_estados_etapas_ofertas (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_rel_estados_etapas
  OWNER TO postgres;
