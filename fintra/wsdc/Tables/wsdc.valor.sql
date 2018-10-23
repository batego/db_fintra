-- Table: wsdc.valor

-- DROP TABLE wsdc.valor;

CREATE TABLE wsdc.valor
(
  id serial NOT NULL,
  tipo_padre character varying NOT NULL, -- TCR Tarjeta de credito, CCA Cuenta cartera
  id_padre integer NOT NULL, -- id de la cuenta de cartera o tarjeta de credito a la que pertenece el registro
  valor_inicial double precision,
  cupo double precision,
  saldo_actual double precision,
  saldo_mora double precision,
  cuota double precision,
  cuotas_canceladas integer,
  total_cuotas integer,
  maxima_mora integer,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying NOT NULL,
  creation_user character varying NOT NULL,
  tipo_identificacion smallint NOT NULL,
  identificacion character varying NOT NULL,
  nit_empresa character varying NOT NULL DEFAULT '8020220161'::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT persona_valor_fk FOREIGN KEY (tipo_identificacion, identificacion, nit_empresa)
      REFERENCES wsdc.persona (tipo_identificacion, identificacion, nit_empresa) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.valor
  OWNER TO postgres;
COMMENT ON COLUMN wsdc.valor.tipo_padre IS 'TCR Tarjeta de credito, CCA Cuenta cartera';
COMMENT ON COLUMN wsdc.valor.id_padre IS 'id de la cuenta de cartera o tarjeta de credito a la que pertenece el registro';


