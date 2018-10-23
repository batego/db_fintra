-- Table: opav.sl_apoteosys_fase_oc

-- DROP TABLE opav.sl_apoteosys_fase_oc;

CREATE TABLE opav.sl_apoteosys_fase_oc
(
  id serial NOT NULL,
  nombre character varying(90) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(90) NOT NULL DEFAULT ''::character varying,
  creation_user character varying(10),
  creation_date timestamp without time zone DEFAULT now(),
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_apoteosys_fase_oc
  OWNER TO postgres;
