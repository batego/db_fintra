-- Table: ws.log_sorpresas_ws

-- DROP TABLE ws.log_sorpresas_ws;

CREATE TABLE ws.log_sorpresas_ws
(
  fecha timestamp without time zone, -- fec
  tabla character varying(50) DEFAULT ''::character varying, -- tabla
  llave_primaria text DEFAULT ''::text, -- pk
  mensaje text DEFAULT ''::text, -- msg
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE ws.log_sorpresas_ws
  OWNER TO postgres;
COMMENT ON TABLE ws.log_sorpresas_ws
  IS 'sorpresas del web service';
COMMENT ON COLUMN ws.log_sorpresas_ws.fecha IS 'fec';
COMMENT ON COLUMN ws.log_sorpresas_ws.tabla IS 'tabla';
COMMENT ON COLUMN ws.log_sorpresas_ws.llave_primaria IS 'pk';
COMMENT ON COLUMN ws.log_sorpresas_ws.mensaje IS 'msg';


