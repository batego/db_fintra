-- Table: opav.sl_auditoria_selectrik

-- DROP TABLE opav.sl_auditoria_selectrik;

CREATE TABLE opav.sl_auditoria_selectrik
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  ticket character varying(8) NOT NULL DEFAULT ''::character varying,
  auditoria_modulo integer,
  titulo character varying(100) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(500) NOT NULL DEFAULT ''::character varying,
  solucion character varying(500) NOT NULL DEFAULT ''::character varying,
  tablas_afectadas character varying(500) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_auditoria_selectrik
  OWNER TO postgres;
