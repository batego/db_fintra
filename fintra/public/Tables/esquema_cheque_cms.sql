-- Table: esquema_cheque_cms

-- DROP TABLE esquema_cheque_cms;

CREATE TABLE esquema_cheque_cms
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  banco character varying(30) NOT NULL DEFAULT ''::character varying, -- Banco
  campo character varying(15) NOT NULL DEFAULT ''::character varying, -- Nombre del campo de dato
  top numeric(4,2) NOT NULL DEFAULT 0, -- Distancia desde el borde superior
  leftt numeric(4,2) NOT NULL DEFAULT 0, -- Distancia desde el borde izquierdo
  creation_date timestamp without time zone NOT NULL DEFAULT '2007-03-28 18:04:50.806708'::timestamp without time zone,
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE esquema_cheque_cms
  OWNER TO postgres;
GRANT ALL ON TABLE esquema_cheque_cms TO postgres;
GRANT SELECT ON TABLE esquema_cheque_cms TO msoto;
COMMENT ON TABLE esquema_cheque_cms
  IS 'Ubicacion de los datos del cheque en CENTIMETROS, top y left';
COMMENT ON COLUMN esquema_cheque_cms.banco IS 'Banco';
COMMENT ON COLUMN esquema_cheque_cms.campo IS 'Nombre del campo de dato';
COMMENT ON COLUMN esquema_cheque_cms.top IS 'Distancia desde el borde superior';
COMMENT ON COLUMN esquema_cheque_cms.leftt IS 'Distancia desde el borde izquierdo';


