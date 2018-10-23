-- Table: convenios_fiducias

-- DROP TABLE convenios_fiducias;

CREATE TABLE convenios_fiducias
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_convenio integer NOT NULL,
  nit_fiducia character varying(15) NOT NULL DEFAULT ''::character varying,
  prefijo_end_fiducia character varying(15) NOT NULL,
  hc_end_fiducia character varying(6) NOT NULL,
  prefijo_dif_fiducia character varying(15) NOT NULL,
  hc_dif_fiducia character varying(6) NOT NULL,
  cuenta_dif_fiducia character varying(30) NOT NULL,
  creation_user character varying(10) NOT NULL,
  user_update character varying(10) NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone
)
WITH (
  OIDS=FALSE
);
ALTER TABLE convenios_fiducias
  OWNER TO postgres;
GRANT ALL ON TABLE convenios_fiducias TO postgres;
GRANT SELECT ON TABLE convenios_fiducias TO msoto;

