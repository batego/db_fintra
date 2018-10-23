-- Table: opav.contratistas_aires

-- DROP TABLE opav.contratistas_aires;

CREATE TABLE opav.contratistas_aires
(
  contratista character varying(5) NOT NULL,
  nombre character varying(100) NOT NULL,
  tipo character varying(1) NOT NULL,
  num_tecnicos integer NOT NULL DEFAULT 0,
  ronda integer NOT NULL DEFAULT 0,
  reg_status character varying(1) DEFAULT ''::character varying,
  creation_user character varying(10),
  creation_date timestamp without time zone DEFAULT now(),
  user_update character varying(10),
  last_update timestamp without time zone DEFAULT now(),
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT "FK_contratista" FOREIGN KEY (contratista)
      REFERENCES opav.app_contratistas (id_contratista) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.contratistas_aires
  OWNER TO postgres;
