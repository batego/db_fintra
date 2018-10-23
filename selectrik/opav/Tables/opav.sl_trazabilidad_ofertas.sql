-- Table: opav.sl_trazabilidad_ofertas

-- DROP TABLE opav.sl_trazabilidad_ofertas;

CREATE TABLE opav.sl_trazabilidad_ofertas
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_solicitud integer,
  id_etapa_oferta integer,
  consideracion text,
  causal text,
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  estado integer,
  inicio timestamp without time zone,
  fin timestamp without time zone,
  delta_time interval DEFAULT '00:00:00'::interval,
  estado_fin integer
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_trazabilidad_ofertas
  OWNER TO postgres;
