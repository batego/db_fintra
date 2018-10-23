-- Table: ws.ms_interface_logofertas_ftv

-- DROP TABLE ws.ms_interface_logofertas_ftv;

CREATE TABLE ws.ms_interface_logofertas_ftv
(
  id_logoferta integer NOT NULL DEFAULT nextval('ws.ms_interface_logofertas_ftv_id_logoferta_seq'::regclass),
  id_orden numeric(10,0) NOT NULL,
  id_estado_actual_negocio numeric(2,0) NOT NULL,
  fecha_asigna_estado timestamp without time zone NOT NULL DEFAULT now(),
  asigna character varying(15) NOT NULL,
  usuario character varying(15),
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE ws.ms_interface_logofertas_ftv
  OWNER TO postgres;

