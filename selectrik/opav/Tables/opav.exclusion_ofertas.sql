-- Table: opav.exclusion_ofertas

-- DROP TABLE opav.exclusion_ofertas;

CREATE TABLE opav.exclusion_ofertas
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  codcli character varying(10) NOT NULL DEFAULT ''::character varying,
  nombre_cliente character varying(100) NOT NULL DEFAULT ''::character varying,
  num_os character varying(15) NOT NULL DEFAULT ''::character varying,
  id_solicitud character varying(15) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.exclusion_ofertas
  OWNER TO postgres;
