-- Table: ws.ejecuciones_webservice_client_plus

-- DROP TABLE ws.ejecuciones_webservice_client_plus;

CREATE TABLE ws.ejecuciones_webservice_client_plus
(
  last_update timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(40) DEFAULT ''::character varying,
  tabla character varying(50) NOT NULL DEFAULT ''::character varying,
  minuto integer NOT NULL DEFAULT 99,
  pk integer NOT NULL DEFAULT nextval('ws.ejecuciones_webservice_clientplus_pk_seq'::regclass), -- pk
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE ws.ejecuciones_webservice_client_plus
  OWNER TO postgres;
COMMENT ON TABLE ws.ejecuciones_webservice_client_plus
  IS 'minutos de tablas gestionadas por el web service';
COMMENT ON COLUMN ws.ejecuciones_webservice_client_plus.pk IS 'pk';


