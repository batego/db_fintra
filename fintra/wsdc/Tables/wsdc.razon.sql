-- Table: wsdc.razon

-- DROP TABLE wsdc.razon;

CREATE TABLE wsdc.razon
(
  id serial NOT NULL,
  score_id integer NOT NULL,
  codigo character varying NOT NULL,
  user_update character varying NOT NULL,
  creation_user character varying NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT score_razon_fk FOREIGN KEY (score_id)
      REFERENCES wsdc.score (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.razon
  OWNER TO postgres;

