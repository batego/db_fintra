-- Table: ex_orden_trabajo

-- DROP TABLE ex_orden_trabajo;

CREATE TABLE ex_orden_trabajo
(
  id_orden character varying(15) NOT NULL DEFAULT ''::character varying,
  id_oferta character varying(15) DEFAULT ''::character varying,
  observaciones text DEFAULT ''::text,
  nic character varying(10) DEFAULT ''::character varying,
  last_update timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10) DEFAULT ''::character varying,
  user_update character varying(10) DEFAULT ''::character varying,
  reg_status character varying(1) DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE ex_orden_trabajo
  OWNER TO postgres;
GRANT ALL ON TABLE ex_orden_trabajo TO postgres;
GRANT SELECT ON TABLE ex_orden_trabajo TO msoto;

