-- Table: recaudo.recaudos_diccionario

-- DROP TABLE recaudo.recaudos_diccionario;

CREATE TABLE recaudo.recaudos_diccionario
(
  formato character varying(15) NOT NULL DEFAULT ''::character varying,
  tipo_referencia character varying(20) NOT NULL,
  codigo character varying(3) NOT NULL,
  descripcion text DEFAULT ''::text,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE recaudo.recaudos_diccionario
  OWNER TO postgres;

