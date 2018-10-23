-- Table: cobros_metrotel

-- DROP TABLE cobros_metrotel;

CREATE TABLE cobros_metrotel
(
  zona numeric NOT NULL DEFAULT 0.00,
  numero numeric NOT NULL DEFAULT 0.00,
  tipo_mov character varying NOT NULL,
  fecha timestamp with time zone NOT NULL,
  cod_cliente numeric NOT NULL DEFAULT 0.00,
  ciclo numeric NOT NULL DEFAULT 0.00,
  cap_ant numeric NOT NULL DEFAULT 0.00,
  cap_act numeric NOT NULL DEFAULT 0.00,
  int_corr numeric NOT NULL DEFAULT 0.00,
  cuo_cap numeric NOT NULL DEFAULT 0.00,
  cuo_seg numeric NOT NULL DEFAULT 0.00,
  int_mor numeric NOT NULL DEFAULT 0.00,
  est_credito character varying,
  total_cuota numeric NOT NULL DEFAULT 0.00,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE cobros_metrotel
  OWNER TO postgres;
GRANT ALL ON TABLE cobros_metrotel TO postgres;
GRANT SELECT ON TABLE cobros_metrotel TO msoto;

