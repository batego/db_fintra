-- Table: fin.cupo_banco

-- DROP TABLE fin.cupo_banco;

CREATE TABLE fin.cupo_banco
(
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  banco character varying(15) NOT NULL, -- Codigo del banco que otorga el crédito
  linea_cupo character varying(30) NOT NULL, -- Linea de crédito: cupo de negocio
  cupo double precision NOT NULL, -- Cupo de credito que asignó el banco
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fin.cupo_banco
  OWNER TO postgres;
COMMENT ON COLUMN fin.cupo_banco.banco IS 'Codigo del banco que otorga el crédito';
COMMENT ON COLUMN fin.cupo_banco.linea_cupo IS 'Linea de crédito: cupo de negocio';
COMMENT ON COLUMN fin.cupo_banco.cupo IS 'Cupo de credito que asignó el banco';


