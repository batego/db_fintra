-- Table: mc_sl_121205

-- DROP TABLE mc_sl_121205;

CREATE TABLE mc_sl_121205
(
  reg_status character varying(1),
  dstrct character varying(6),
  numero_solicitud integer,
  tipo character varying(1),
  ocupacion character varying(15),
  actividad_economica character varying(60),
  nombre_empresa character varying(150),
  nit character varying(15),
  direccion character varying(100),
  ciudad character varying(6),
  departamento character varying(6),
  telefono character varying(15),
  extension character varying(10),
  cargo character varying(60),
  fecha_ingreso timestamp without time zone,
  tipo_contrato character varying(20),
  salario numeric(15,2),
  celular character varying(15),
  email character varying(100),
  eps character varying(100),
  tipo_afiliacion character varying(15),
  direccion_cobro character varying(100),
  otros_ingresos numeric(15,2),
  concepto_otros_ing character varying(150),
  gastos_manutencion numeric(15,2),
  gastos_creditos numeric(15,2),
  gastos_arriendo numeric(15,2),
  creation_date timestamp without time zone,
  creation_user character varying(50),
  last_update timestamp without time zone,
  user_update character varying(50),
  id_persona character varying(15),
  secuencia integer
)
WITH (
  OIDS=FALSE
);
ALTER TABLE mc_sl_121205
  OWNER TO postgres;

