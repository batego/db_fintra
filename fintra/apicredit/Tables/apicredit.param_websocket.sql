-- Table: apicredit.param_websocket

-- DROP TABLE apicredit.param_websocket;

CREATE TABLE apicredit.param_websocket
(
  id serial NOT NULL,
  estado_sol character varying(20) NOT NULL DEFAULT ''::character varying,
  etapa character varying(30) NOT NULL DEFAULT ''::character varying,
  identificacion character varying NOT NULL DEFAULT ''::character varying,
  token character varying(100) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE apicredit.param_websocket
  OWNER TO postgres;

