-- Table: wsdc.reclamo

-- DROP TABLE wsdc.reclamo;

CREATE TABLE wsdc.reclamo
(
  tipo_padre character varying NOT NULL, -- CAH-cuentaAhorro, CCO-cuentaCorriente, TCR-tarjetaCredito, CCA-cuentaCartera
  id_padre character varying NOT NULL,
  tipo_leyenda character varying, -- 1-Reclamo en tramite...
  fecha_cierre timestamp without time zone,
  estado character varying,
  tipo character varying,
  fecha character varying,
  ratificado boolean,
  texto character varying,
  tipo_identificacion smallint NOT NULL,
  identificacion character varying NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying NOT NULL,
  creation_user character varying NOT NULL,
  nit_empresa character varying NOT NULL DEFAULT '8020220161'::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT persona_reclamo_fk FOREIGN KEY (tipo_identificacion, identificacion, nit_empresa)
      REFERENCES wsdc.persona (tipo_identificacion, identificacion, nit_empresa) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.reclamo
  OWNER TO postgres;
COMMENT ON COLUMN wsdc.reclamo.tipo_padre IS 'CAH-cuentaAhorro, CCO-cuentaCorriente, TCR-tarjetaCredito, CCA-cuentaCartera';
COMMENT ON COLUMN wsdc.reclamo.tipo_leyenda IS '1-Reclamo en tramite
2-Reclamo en discución judicial';


