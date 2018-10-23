-- Table: con.pto_gastos_admin

-- DROP TABLE con.pto_gastos_admin;

CREATE TABLE con.pto_gastos_admin
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  cuenta character varying(13) NOT NULL DEFAULT ''::character varying, -- Codigo de la cuenta.
  ano character varying(4) NOT NULL DEFAULT ''::character varying, -- Ano de los valores presupuestados y ejecutados.
  vr_presupuestado_1 moneda, -- Valor presupuestado 1.
  vr_presupuestado_2 moneda, -- Valor presupuestado 2.
  vr_presupuestado_3 moneda, -- Valor presupuestado 3.
  vr_presupuestado_4 moneda, -- Valor presupuestado 4.
  vr_presupuestado_5 moneda, -- Valor presupuestado 5.
  vr_presupuestado_6 moneda, -- Valor presupuestado 6.
  vr_presupuestado_7 moneda, -- Valor presupuestado 7.
  vr_presupuestado_8 moneda, -- Valor presupuestado 8.
  vr_presupuestado_9 moneda, -- Valor presupuestado 9.
  vr_presupuestado_10 moneda, -- Valor presupuestado 10.
  vr_presupuestado_11 moneda, -- Valor presupuestado 11.
  vr_presupuestado_12 moneda, -- Valor presupuestado 12.
  vr_ejecutado_1 moneda, -- Valor ejecutado 1.
  vr_ejecutado_2 moneda, -- Valor ejecutado 2.
  vr_ejecutado_3 moneda, -- Valor ejecutado 3.
  vr_ejecutado_4 moneda, -- Valor ejecutado 4.
  vr_ejecutado_5 moneda, -- Valor ejecutado 5.
  vr_ejecutado_6 moneda, -- Valor ejecutado 6.
  vr_ejecutado_7 moneda, -- Valor ejecutado 7.
  vr_ejecutado_8 moneda, -- Valor ejecutado 8.
  vr_ejecutado_9 moneda, -- Valor ejecutado 9.
  vr_ejecutado_10 moneda, -- Valor ejecutado 10.
  vr_ejecutado_11 moneda, -- Valor ejecutado 11.
  vr_ejecutado_12 moneda, -- Valor ejecutado 12.
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE con.pto_gastos_admin
  OWNER TO postgres;
GRANT ALL ON TABLE con.pto_gastos_admin TO postgres;
GRANT SELECT ON TABLE con.pto_gastos_admin TO msoto;
COMMENT ON TABLE con.pto_gastos_admin
  IS 'Tabla donde se registran el presupuesto de los gastos administrativos.';
COMMENT ON COLUMN con.pto_gastos_admin.cuenta IS 'Codigo de la cuenta.';
COMMENT ON COLUMN con.pto_gastos_admin.ano IS 'Ano de los valores presupuestados y ejecutados.';
COMMENT ON COLUMN con.pto_gastos_admin.vr_presupuestado_1 IS 'Valor presupuestado 1.';
COMMENT ON COLUMN con.pto_gastos_admin.vr_presupuestado_2 IS 'Valor presupuestado 2.';
COMMENT ON COLUMN con.pto_gastos_admin.vr_presupuestado_3 IS 'Valor presupuestado 3.';
COMMENT ON COLUMN con.pto_gastos_admin.vr_presupuestado_4 IS 'Valor presupuestado 4.';
COMMENT ON COLUMN con.pto_gastos_admin.vr_presupuestado_5 IS 'Valor presupuestado 5.';
COMMENT ON COLUMN con.pto_gastos_admin.vr_presupuestado_6 IS 'Valor presupuestado 6.';
COMMENT ON COLUMN con.pto_gastos_admin.vr_presupuestado_7 IS 'Valor presupuestado 7.';
COMMENT ON COLUMN con.pto_gastos_admin.vr_presupuestado_8 IS 'Valor presupuestado 8.';
COMMENT ON COLUMN con.pto_gastos_admin.vr_presupuestado_9 IS 'Valor presupuestado 9.';
COMMENT ON COLUMN con.pto_gastos_admin.vr_presupuestado_10 IS 'Valor presupuestado 10.';
COMMENT ON COLUMN con.pto_gastos_admin.vr_presupuestado_11 IS 'Valor presupuestado 11.';
COMMENT ON COLUMN con.pto_gastos_admin.vr_presupuestado_12 IS 'Valor presupuestado 12.';
COMMENT ON COLUMN con.pto_gastos_admin.vr_ejecutado_1 IS 'Valor ejecutado 1.';
COMMENT ON COLUMN con.pto_gastos_admin.vr_ejecutado_2 IS 'Valor ejecutado 2.';
COMMENT ON COLUMN con.pto_gastos_admin.vr_ejecutado_3 IS 'Valor ejecutado 3.';
COMMENT ON COLUMN con.pto_gastos_admin.vr_ejecutado_4 IS 'Valor ejecutado 4.';
COMMENT ON COLUMN con.pto_gastos_admin.vr_ejecutado_5 IS 'Valor ejecutado 5.';
COMMENT ON COLUMN con.pto_gastos_admin.vr_ejecutado_6 IS 'Valor ejecutado 6.';
COMMENT ON COLUMN con.pto_gastos_admin.vr_ejecutado_7 IS 'Valor ejecutado 7.';
COMMENT ON COLUMN con.pto_gastos_admin.vr_ejecutado_8 IS 'Valor ejecutado 8.';
COMMENT ON COLUMN con.pto_gastos_admin.vr_ejecutado_9 IS 'Valor ejecutado 9.';
COMMENT ON COLUMN con.pto_gastos_admin.vr_ejecutado_10 IS 'Valor ejecutado 10.';
COMMENT ON COLUMN con.pto_gastos_admin.vr_ejecutado_11 IS 'Valor ejecutado 11.';
COMMENT ON COLUMN con.pto_gastos_admin.vr_ejecutado_12 IS 'Valor ejecutado 12.';


