-- Table: sms

-- DROP TABLE sms;

CREATE TABLE sms
(
  id serial NOT NULL,
  idsms character varying(100) DEFAULT ''::character varying,
  token character varying(100) DEFAULT ''::character varying,
  celular character varying(20) DEFAULT ''::character varying,
  nit character varying(15) DEFAULT ''::character varying,
  sms character varying(300) DEFAULT ''::character varying,
  estado character varying(50) DEFAULT ''::character varying,
  enviado character varying(50) DEFAULT 'N'::character varying,
  fecha_envio timestamp without time zone NOT NULL DEFAULT now(),
  comentario character varying(256) DEFAULT ''::character varying,
  creation_date timestamp without time zone DEFAULT now(),
  creditos double precision DEFAULT 0.00,
  tipo character varying(50) DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE sms
  OWNER TO postgres;
GRANT ALL ON TABLE sms TO postgres;
GRANT SELECT ON TABLE sms TO msoto;

