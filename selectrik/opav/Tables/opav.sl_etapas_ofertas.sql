-- Table: opav.sl_etapas_ofertas

-- DROP TABLE opav.sl_etapas_ofertas;

CREATE TABLE opav.sl_etapas_ofertas
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  nombre_etapa character varying(50),
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_etapas_ofertas
  OWNER TO postgres;
