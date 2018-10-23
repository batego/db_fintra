-- Table: opav.ofertas_consi

-- DROP TABLE opav.ofertas_consi;

CREATE TABLE opav.ofertas_consi
(
  id_solicitud character varying(15) NOT NULL,
  id_consideracion serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ' '::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ' '::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ' '::character varying,
  num_consideracion character varying(3) NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.ofertas_consi
  OWNER TO postgres;
