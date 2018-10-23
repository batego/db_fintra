-- Table: con.subledger

-- DROP TABLE con.subledger;

CREATE TABLE con.subledger
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(15) NOT NULL DEFAULT ''::character varying,
  cuenta character varying(25) NOT NULL DEFAULT ''::character varying, -- numero de cuenta contable
  tipo_subledger character varying(2) NOT NULL DEFAULT ''::character varying, -- codigo de subledger
  id_subledger character varying(15) NOT NULL DEFAULT ''::character varying, -- numero de identificacion
  nombre character varying(100) NOT NULL DEFAULT ''::character varying, -- Nombre de la identificacion
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  base character varying(3) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE con.subledger
  OWNER TO postgres;
GRANT ALL ON TABLE con.subledger TO postgres;
GRANT SELECT ON TABLE con.subledger TO msoto;
COMMENT ON TABLE con.subledger
  IS 'Tabla que almacena las cuentas auxiliares';
COMMENT ON COLUMN con.subledger.cuenta IS 'numero de cuenta contable';
COMMENT ON COLUMN con.subledger.tipo_subledger IS 'codigo de subledger';
COMMENT ON COLUMN con.subledger.id_subledger IS 'numero de identificacion';
COMMENT ON COLUMN con.subledger.nombre IS 'Nombre de la identificacion';


