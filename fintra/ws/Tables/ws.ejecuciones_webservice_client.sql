-- Table: ws.ejecuciones_webservice_client

-- DROP TABLE ws.ejecuciones_webservice_client;

CREATE TABLE ws.ejecuciones_webservice_client
(
  last_update timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(40) DEFAULT ''::character varying,
  tabla character varying(50) NOT NULL DEFAULT ''::character varying,
  minuto integer NOT NULL DEFAULT 99,
  pk serial NOT NULL, -- pk
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE ws.ejecuciones_webservice_client
  OWNER TO postgres;
COMMENT ON TABLE ws.ejecuciones_webservice_client
  IS 'minutos de tablas gestionadas por el web service';
COMMENT ON COLUMN ws.ejecuciones_webservice_client.pk IS 'pk';


