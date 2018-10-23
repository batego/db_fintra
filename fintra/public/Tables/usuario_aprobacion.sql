-- Table: usuario_aprobacion

-- DROP TABLE usuario_aprobacion;

CREATE TABLE usuario_aprobacion
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_agencia character varying(10) NOT NULL DEFAULT ''::character varying,
  tabla character varying(20) NOT NULL DEFAULT ''::character varying, -- nombre de la tabla aprobar
  usuario_aprobacion character varying(20) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE usuario_aprobacion
  OWNER TO postgres;
GRANT ALL ON TABLE usuario_aprobacion TO postgres;
GRANT SELECT ON TABLE usuario_aprobacion TO msoto;
COMMENT ON TABLE usuario_aprobacion
  IS 'tabla almacena el login de usuario, tabla y agencias que puede autorizar';
COMMENT ON COLUMN usuario_aprobacion.tabla IS 'nombre de la tabla aprobar';


