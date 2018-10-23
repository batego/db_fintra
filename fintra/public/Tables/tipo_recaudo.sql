-- Table: tipo_recaudo

-- DROP TABLE tipo_recaudo;

CREATE TABLE tipo_recaudo
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  descripcion character varying(50) NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tipo_recaudo
  OWNER TO postgres;
GRANT ALL ON TABLE tipo_recaudo TO postgres;
GRANT SELECT ON TABLE tipo_recaudo TO msoto;

