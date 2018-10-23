-- Table: opav.auditoria_modulo

-- DROP TABLE opav.auditoria_modulo;

CREATE TABLE opav.auditoria_modulo
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  nombre character varying(150) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(150) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.auditoria_modulo
  OWNER TO postgres;
