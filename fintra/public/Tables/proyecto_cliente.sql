-- Table: proyecto_cliente

-- DROP TABLE proyecto_cliente;

CREATE TABLE proyecto_cliente
(
  reg_status character varying NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  proyecto character varying(15) NOT NULL DEFAULT ''::character varying, -- Nombre del proyecto.
  codcli character varying(10) NOT NULL DEFAULT ''::character varying, -- Codigo del cliente
  tipo character varying(2) NOT NULL DEFAULT ''::character varying, -- Tipo de cliente.
  descripcion character varying(45) NOT NULL DEFAULT ''::character varying, -- Descripcion del tipo de cliente
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE proyecto_cliente
  OWNER TO postgres;
GRANT ALL ON TABLE proyecto_cliente TO postgres;
GRANT SELECT ON TABLE proyecto_cliente TO msoto;
COMMENT ON TABLE proyecto_cliente
  IS 'Tabla donde se registran los distintos tipos de cliente para cada proyecto';
COMMENT ON COLUMN proyecto_cliente.proyecto IS 'Nombre del proyecto.';
COMMENT ON COLUMN proyecto_cliente.codcli IS 'Codigo del cliente';
COMMENT ON COLUMN proyecto_cliente.tipo IS 'Tipo de cliente.';
COMMENT ON COLUMN proyecto_cliente.descripcion IS 'Descripcion del tipo de cliente';


