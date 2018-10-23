-- Table: sendmail

-- DROP TABLE sendmail;

CREATE TABLE sendmail
(
  id integer NOT NULL DEFAULT nextval(('"sendmail_id_seq"'::text)::regclass),
  recstatus character(1) NOT NULL DEFAULT 'A'::bpchar,
  emailcode character varying(10) NOT NULL DEFAULT ''::character varying,
  emailfrom text NOT NULL,
  emailto text NOT NULL,
  emailcopyto text NOT NULL,
  emailsubject character varying(100) NOT NULL DEFAULT ''::character varying,
  emailbody text NOT NULL,
  lastupdat timestamp without time zone NOT NULL DEFAULT now(),
  sendername text NOT NULL DEFAULT ''::text,
  remarks text NOT NULL DEFAULT ''::text,
  tipo character(1) NOT NULL DEFAULT 'I'::bpchar, -- Indica si es correo Interno o Externo
  adjunto bytea, -- Campo donde se guardaran los datos adjuntos de un email
  nombrearchivo character varying(60) NOT NULL DEFAULT ''::character varying, -- Nombre del archivo adjunto
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE sendmail
  OWNER TO postgres;
GRANT ALL ON TABLE sendmail TO postgres;
GRANT SELECT ON TABLE sendmail TO msoto;
COMMENT ON COLUMN sendmail.tipo IS 'Indica si es correo Interno o Externo';
COMMENT ON COLUMN sendmail.adjunto IS 'Campo donde se guardaran los datos adjuntos de un email';
COMMENT ON COLUMN sendmail.nombrearchivo IS 'Nombre del archivo adjunto';


