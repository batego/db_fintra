-- Table: bitacora_ip

-- DROP TABLE bitacora_ip;

CREATE TABLE bitacora_ip
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  usuario character varying(20) NOT NULL DEFAULT ''::character varying,
  ip_address character varying(100) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  latitud character varying(50) NOT NULL DEFAULT ''::character varying,
  longitud character varying(50) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE bitacora_ip
  OWNER TO postgres;

