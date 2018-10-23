-- Table: opav.sl_estado_cartera

-- DROP TABLE opav.sl_estado_cartera;

CREATE TABLE opav.sl_estado_cartera
(
  id character varying(15) NOT NULL,
  nombre character varying(30) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(50) NOT NULL DEFAULT ''::character varying,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT (now())::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE opav.sl_estado_cartera
  OWNER TO postgres;
