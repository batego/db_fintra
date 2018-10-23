-- Table: wsdc.alivio

-- DROP TABLE wsdc.alivio;

CREATE TABLE wsdc.alivio
(
  tipo_padre character varying NOT NULL, -- CAH-cuentaAhorro, CCO-cuentaCorriente, TCR-tarjetaCredito, CCA-cuentaCartera
  id_padre character varying NOT NULL,
  estado character varying,
  mes character varying,
  tipo_identificacion smallint NOT NULL,
  identificacion character varying NOT NULL,
  creation_user character varying NOT NULL,
  user_update character varying NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  nit_empresa character varying NOT NULL DEFAULT '8020220161'::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT persona_alivio_fk FOREIGN KEY (tipo_identificacion, identificacion, nit_empresa)
      REFERENCES wsdc.persona (tipo_identificacion, identificacion, nit_empresa) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.alivio
  OWNER TO postgres;
COMMENT ON COLUMN wsdc.alivio.tipo_padre IS 'CAH-cuentaAhorro, CCO-cuentaCorriente, TCR-tarjetaCredito, CCA-cuentaCartera';


