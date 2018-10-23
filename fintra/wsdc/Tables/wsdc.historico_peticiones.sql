-- Table: wsdc.historico_peticiones

-- DROP TABLE wsdc.historico_peticiones;

CREATE TABLE wsdc.historico_peticiones
(
  web_service character varying(1) NOT NULL, -- H - Historia de credito, L - localización
  fecha timestamp without time zone NOT NULL, -- Fecha en que se realizó la consulta
  usuario character varying(50) NOT NULL,
  id_consulta character varying NOT NULL, -- Numero de identificacion que se consulto
  tipo_id_consulta smallint NOT NULL, -- Tipo de identificacion que se consulto
  primer_apellido character varying NOT NULL, -- Primer apellido de quien se consulta
  formulario character varying NOT NULL, -- xml con los parametros del formulario
  respuesta character varying, -- Respuesta obtenida por el web service
  creation_user character varying(50) NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(50) NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  nit_empresa character varying NOT NULL DEFAULT '8020220161'::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.historico_peticiones
  OWNER TO postgres;
COMMENT ON COLUMN wsdc.historico_peticiones.web_service IS 'H - Historia de credito, L - localización';
COMMENT ON COLUMN wsdc.historico_peticiones.fecha IS 'Fecha en que se realizó la consulta';
COMMENT ON COLUMN wsdc.historico_peticiones.id_consulta IS 'Numero de identificacion que se consulto';
COMMENT ON COLUMN wsdc.historico_peticiones.tipo_id_consulta IS 'Tipo de identificacion que se consulto';
COMMENT ON COLUMN wsdc.historico_peticiones.primer_apellido IS 'Primer apellido de quien se consulta';
COMMENT ON COLUMN wsdc.historico_peticiones.formulario IS 'xml con los parametros del formulario';
COMMENT ON COLUMN wsdc.historico_peticiones.respuesta IS 'Respuesta obtenida por el web service';


