-- Table: historico_cambios_direccion_clientes

-- DROP TABLE historico_cambios_direccion_clientes;

CREATE TABLE historico_cambios_direccion_clientes
(
  id serial NOT NULL,
  cedula_cliente character varying(15) NOT NULL,
  nombre_anterior character varying(160) NOT NULL DEFAULT ''::character varying,
  direccion_anterior character varying(160) NOT NULL DEFAULT ''::character varying,
  barrio_anterior character varying(50) NOT NULL DEFAULT ''::character varying,
  codciu_anterior character varying(10) NOT NULL DEFAULT ''::character varying,
  coddpto_anterior character varying(10) NOT NULL DEFAULT ''::character varying,
  telefono_anterior character varying(70) NOT NULL DEFAULT ''::character varying,
  celular_anterior character varying(15) NOT NULL DEFAULT ''::character varying,
  nombre_actual character varying(160) NOT NULL DEFAULT ''::character varying,
  direccion_actual character varying(160) NOT NULL DEFAULT ''::character varying,
  barrio_actual character varying(50) NOT NULL DEFAULT ''::character varying,
  codciu_actual character varying(10) NOT NULL DEFAULT ''::character varying,
  coddpto_actual character varying(10) NOT NULL DEFAULT ''::character varying,
  telefono_actual character varying(70) NOT NULL DEFAULT ''::character varying,
  celular_actual character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  observaciones_anterior character varying(500),
  observaciones_actual character varying(500)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE historico_cambios_direccion_clientes
  OWNER TO postgres;
GRANT ALL ON TABLE historico_cambios_direccion_clientes TO postgres;
GRANT SELECT ON TABLE historico_cambios_direccion_clientes TO msoto;

