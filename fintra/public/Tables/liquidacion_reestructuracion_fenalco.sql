-- Table: liquidacion_reestructuracion_fenalco

-- DROP TABLE liquidacion_reestructuracion_fenalco;

CREATE TABLE liquidacion_reestructuracion_fenalco
(
  id serial NOT NULL,
  id_rop integer NOT NULL,
  fecha timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  cuota character varying(20) NOT NULL DEFAULT ''::character varying,
  saldo_inicial numeric(11,2) NOT NULL,
  capital numeric(11,2) NOT NULL,
  interes numeric(11,2) NOT NULL,
  custodia numeric(11,2) NOT NULL,
  seguro numeric(11,2) NOT NULL,
  remesa numeric(11,2) NOT NULL,
  valor_cuota numeric(11,2) NOT NULL,
  saldo_final numeric(11,2) NOT NULL,
  creation_user character varying(20) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  dias integer NOT NULL DEFAULT 0,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_id_rop FOREIGN KEY (id_rop)
      REFERENCES recibo_oficial_pago (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE liquidacion_reestructuracion_fenalco
  OWNER TO postgres;
GRANT ALL ON TABLE liquidacion_reestructuracion_fenalco TO postgres;
GRANT SELECT ON TABLE liquidacion_reestructuracion_fenalco TO msoto;

