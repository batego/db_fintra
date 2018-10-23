-- Table: opav.sl_histograma

-- DROP TABLE opav.sl_histograma;

CREATE TABLE opav.sl_histograma
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_solicitud integer,
  id_tipo_insumo integer,
  id_insumo integer,
  periodo_ini date,
  periodo_fin date,
  h_trabajo numeric(4,2),
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_histograma
  OWNER TO postgres;
