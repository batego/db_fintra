-- Table: con.historico_traslado_fiducia

-- DROP TABLE con.historico_traslado_fiducia;

CREATE TABLE con.historico_traslado_fiducia
(
  id serial NOT NULL,
  creation_date timestamp with time zone,
  usuario_traslado character varying(60),
  documento character varying(11),
  reg_status character varying(1),
  dstrct character varying(4),
  nit character varying(15),
  codcli character varying(10),
  cmc character varying(6),
  clasificacion1 character varying(6),
  cuenta_detalle_factura character varying(30)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.historico_traslado_fiducia
  OWNER TO postgres;
GRANT ALL ON TABLE con.historico_traslado_fiducia TO postgres;
GRANT SELECT ON TABLE con.historico_traslado_fiducia TO msoto;

