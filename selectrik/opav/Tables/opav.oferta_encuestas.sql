-- Table: opav.oferta_encuestas

-- DROP TABLE opav.oferta_encuestas;

CREATE TABLE opav.oferta_encuestas
(
  id_solicitud character varying(15) NOT NULL DEFAULT ''::character varying,
  pregunta1 text NOT NULL DEFAULT ''::text,
  pregunta2 text NOT NULL DEFAULT ''::text,
  pregunta3 text NOT NULL DEFAULT ''::text,
  pregunta4 text NOT NULL DEFAULT ''::text,
  pregunta5 text NOT NULL DEFAULT ''::text,
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10) DEFAULT ''::character varying,
  user_update character varying(10) DEFAULT ''::character varying,
  reg_status character varying(1) DEFAULT ''::character varying,
  last_update timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  tipo character varying(15) NOT NULL DEFAULT ''::character varying,
  serie integer NOT NULL,
  pregunta6 character varying(1) DEFAULT ''::character varying,
  pregunta7 character varying(1) DEFAULT ''::character varying,
  pregunta8 character varying(1) DEFAULT ''::character varying,
  pregunta9 character varying(1) DEFAULT ''::character varying,
  pregunta10 character varying(1) DEFAULT ''::character varying,
  pregunta11 character varying(1) DEFAULT ''::character varying,
  pregunta12 character varying(1) DEFAULT ''::character varying,
  pregunta13 character varying(1) DEFAULT ''::character varying,
  pregunta14 character varying(1) DEFAULT ''::character varying,
  pregunta15 character varying(1) DEFAULT ''::character varying,
  pregunta16 character varying(1) DEFAULT ''::character varying,
  comentario text DEFAULT ''::text,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT "FK_ofertas" FOREIGN KEY (id_solicitud)
      REFERENCES opav.ofertas (id_solicitud) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.oferta_encuestas
  OWNER TO postgres;
