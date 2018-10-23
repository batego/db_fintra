-- Table: opav.dias_pago

-- DROP TABLE opav.dias_pago;

CREATE TABLE opav.dias_pago
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  valor integer NOT NULL DEFAULT 0,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.dias_pago
  OWNER TO postgres;
