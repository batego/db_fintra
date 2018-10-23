-- Table: series_cheque_usuarios

-- DROP TABLE series_cheque_usuarios;

CREATE TABLE series_cheque_usuarios
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id character varying(15) NOT NULL DEFAULT ''::character varying, -- Identificador de la serie
  concepto character varying(30) NOT NULL DEFAULT ''::character varying, -- Concepto de la serie, anticipo o cxp
  usuario character varying(30) NOT NULL DEFAULT ''::character varying, -- Usuario permitido a usar la serie
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE series_cheque_usuarios
  OWNER TO postgres;
GRANT ALL ON TABLE series_cheque_usuarios TO postgres;
GRANT SELECT ON TABLE series_cheque_usuarios TO msoto;
COMMENT ON COLUMN series_cheque_usuarios.id IS 'Identificador de la serie';
COMMENT ON COLUMN series_cheque_usuarios.concepto IS 'Concepto de la serie, anticipo o cxp';
COMMENT ON COLUMN series_cheque_usuarios.usuario IS 'Usuario permitido a usar la serie';


