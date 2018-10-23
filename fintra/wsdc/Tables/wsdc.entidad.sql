-- Table: wsdc.entidad

-- DROP TABLE wsdc.entidad;

CREATE TABLE wsdc.entidad
(
  codigo_suscriptor character varying NOT NULL,
  nombre_suscriptor character varying,
  nit character varying,
  contrato character varying, -- 1 - Con contrato, 0 - Sin contrato
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying NOT NULL,
  creation_user character varying NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.entidad
  OWNER TO postgres;
COMMENT ON COLUMN wsdc.entidad.contrato IS '1 - Con contrato, 0 - Sin contrato';


