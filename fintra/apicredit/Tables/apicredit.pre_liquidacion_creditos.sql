-- Table: apicredit.pre_liquidacion_creditos

-- DROP TABLE apicredit.pre_liquidacion_creditos;

CREATE TABLE apicredit.pre_liquidacion_creditos
(
  id serial NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  numero_solicitud integer NOT NULL,
  fecha timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  dias integer NOT NULL DEFAULT 0,
  cuota character varying(20) NOT NULL DEFAULT ''::character varying,
  saldo_inicial numeric(11,2) NOT NULL,
  capital numeric(11,2) NOT NULL,
  interes numeric(11,2) NOT NULL,
  custodia numeric(11,2) NOT NULL,
  seguro numeric(11,2) NOT NULL,
  remesa numeric(11,2) NOT NULL,
  valor_cuota numeric(11,2) NOT NULL,
  saldo_final numeric(11,2) NOT NULL,
  valor_aval numeric(11,2) NOT NULL,
  cuota_manejo numeric(11,2) NOT NULL,
  creation_user character varying(50) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT fk_id_solicitus FOREIGN KEY (numero_solicitud)
      REFERENCES solicitud_aval (numero_solicitud) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE apicredit.pre_liquidacion_creditos
  OWNER TO postgres;

