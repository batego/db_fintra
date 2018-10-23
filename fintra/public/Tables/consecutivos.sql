-- Table: consecutivos

-- DROP TABLE consecutivos;

CREATE TABLE consecutivos
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  nit character varying(20) NOT NULL DEFAULT ''::character varying,
  subst character varying(10) NOT NULL DEFAULT ''::character varying,
  conslet integer NOT NULL DEFAULT 0,
  conspag integer NOT NULL DEFAULT 1,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  substrpagare character varying(10) DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE consecutivos
  OWNER TO postgres;
GRANT ALL ON TABLE consecutivos TO postgres;
GRANT SELECT ON TABLE consecutivos TO msoto;

