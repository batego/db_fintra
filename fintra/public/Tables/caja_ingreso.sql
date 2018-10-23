-- Table: caja_ingreso

-- DROP TABLE caja_ingreso;

CREATE TABLE caja_ingreso
(
  id serial NOT NULL, -- id para los ingresos
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL,
  agencia character varying(10) NOT NULL, -- Agencia a la que ingresa el dinero
  fecha timestamp without time zone NOT NULL, -- Fecha del ingreso
  num_ingreso character varying(11) NOT NULL, -- Numero del ingreso generado
  valor double precision NOT NULL, -- Valor del ingreso
  recibido character varying(1) NOT NULL DEFAULT 'N'::character varying, -- 'S' si ya se recibió el dinero en la agencia o 'N' si aun esta en canje.
  usuario_recibido character varying, -- Usuario que recibió el dinero
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE caja_ingreso
  OWNER TO postgres;
GRANT ALL ON TABLE caja_ingreso TO postgres;
GRANT SELECT ON TABLE caja_ingreso TO msoto;
COMMENT ON TABLE caja_ingreso
  IS 'Tabla para registrar los ingresos de dinero en las cajas';
COMMENT ON COLUMN caja_ingreso.id IS 'id para los ingresos';
COMMENT ON COLUMN caja_ingreso.agencia IS 'Agencia a la que ingresa el dinero';
COMMENT ON COLUMN caja_ingreso.fecha IS 'Fecha del ingreso';
COMMENT ON COLUMN caja_ingreso.num_ingreso IS 'Numero del ingreso generado';
COMMENT ON COLUMN caja_ingreso.valor IS 'Valor del ingreso';
COMMENT ON COLUMN caja_ingreso.recibido IS '''S'' si ya se recibió el dinero en la agencia o ''N'' si aun esta en canje.';
COMMENT ON COLUMN caja_ingreso.usuario_recibido IS 'Usuario que recibió el dinero';


