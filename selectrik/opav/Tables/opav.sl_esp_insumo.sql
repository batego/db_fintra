-- Table: opav.sl_esp_insumo

-- DROP TABLE opav.sl_esp_insumo;

CREATE TABLE opav.sl_esp_insumo
(
  id serial NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  id_valor_predeterminado integer NOT NULL,
  id_material integer NOT NULL,
  id_especificacion integer NOT NULL,
  valor_especificacion text,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_sl_esp_insumo1 FOREIGN KEY (id_valor_predeterminado)
      REFERENCES opav.sl_valores_predeterminados (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_sl_esp_insumo2 FOREIGN KEY (id_material)
      REFERENCES opav.sl_insumo (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_sl_esp_material4 FOREIGN KEY (id_especificacion)
      REFERENCES opav.sl_especificacion (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_esp_insumo
  OWNER TO postgres;
