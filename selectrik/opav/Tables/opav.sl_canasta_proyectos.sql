-- Table: opav.sl_canasta_proyectos

-- DROP TABLE opav.sl_canasta_proyectos;

CREATE TABLE opav.sl_canasta_proyectos
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_solicitud character varying(50) NOT NULL DEFAULT ''::character varying,
  presupuesto_comercial numeric(15,4) NOT NULL DEFAULT 0,
  presupuesto_ejecucion numeric(15,4) NOT NULL DEFAULT 0,
  total_debitado numeric(15,4) NOT NULL DEFAULT 0,
  total_acreditado numeric(15,4) NOT NULL DEFAULT 0,
  saldo_canasta numeric(15,4) NOT NULL DEFAULT 0,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_canasta_proyectos
  OWNER TO postgres;
