-- Table: solicitud_transacciones

-- DROP TABLE solicitud_transacciones;

CREATE TABLE solicitud_transacciones
(
  reg_status character varying(1) DEFAULT ''::character varying,
  dstrct character varying(6) DEFAULT ''::character varying,
  numero_solicitud integer NOT NULL DEFAULT 0,
  tipo character varying(1) NOT NULL DEFAULT 'S'::character varying,
  id_persona character varying(15) DEFAULT ''::character varying,
  transacciones_al_extanjero character varying(1) DEFAULT 'N'::character varying,
  importaciones character varying(1) DEFAULT 'N'::character varying,
  exportaciones character varying(1) DEFAULT 'N'::character varying,
  inversiones character varying(1) DEFAULT 'N'::character varying,
  giros character varying(1) DEFAULT 'N'::character varying,
  prestamos character varying(1) DEFAULT 'N'::character varying,
  otras_transacciones character varying(1) DEFAULT 'N'::character varying,
  pago_cuenta_exterior character varying(1) DEFAULT 'N'::character varying,
  banco character varying(100) DEFAULT ''::character varying,
  cuenta character varying(25) DEFAULT ''::character varying,
  pais character varying(100) DEFAULT ''::character varying,
  ciudad character varying(100) DEFAULT 'N'::character varying,
  moneda character varying(10) DEFAULT 'PES'::character varying,
  tipo_pro character varying(10) DEFAULT ''::character varying,
  monto numeric(15,2) DEFAULT 0,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(50) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(50) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE solicitud_transacciones
  OWNER TO postgres;
GRANT ALL ON TABLE solicitud_transacciones TO postgres;
GRANT SELECT ON TABLE solicitud_transacciones TO msoto;

